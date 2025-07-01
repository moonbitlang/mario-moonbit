// (* Represents the values of relevant key bindings. *)

///|
priv struct Keys {
  mut up : Bool
  mut up2 : Bool
  mut down : Bool
  mut down2 : Bool
  mut left : Bool
  mut left2 : Bool
  mut right : Bool
  mut right2 : Bool
  mut bbox : Int
}

// (*pressed_keys instantiates the keys.*)

///|
let pressed_keys : Keys = {
  up: false,
  up2: false,
  down: false,
  down2: false,
  left: false,
  left2: false,
  right: false,
  right2: false,
  bbox: 0,
}

///|
let collid_objs : Ref[List[Collidable]] = @ref.new(@list.empty()) // (*List of next iteration collidable objects *)

///|
let particles : Ref[List[Particle]] = @ref.new(@list.empty()) // (*List of next iteration particles *)

///|
let last_time : Ref[Double] = @ref.new(-16.6) // (* Used for calculating fps *)

// (* Calculates fps as the difference between [t0] and [t1] *)

///|
fn calc_fps(t0 : Double, t1 : Double) -> Double {
  let delta = (t1 - t0) / 1000.0
  1.0 / delta
}

// (* Returns whether the bounding box should be drawn *)

///|
fn check_bbox_enabled() -> Bool {
  pressed_keys.bbox == 1
}

// (* update_collidable is the primary update method for collidable objects,
// * checking the collision, updating the object, and drawing to the canvas.*)

///|
fn update_collidable(
  state : St,
  collid : Collidable,
  all_collids : List[Collidable]
) -> List[Collidable] {
  let obj = collid.object
  let spr = collid.sprite
  obj.invuln = if obj.invuln > 0 { obj.invuln - 1 } else { 0 }
  // (* Prevent position from being updated outside of viewport *)
  let viewport_filter = state.vpt.in_viewport(obj.pos) ||
    collid.target is Player(_) ||
    state.vpt.out_of_viewport_below(obj.pos.y)
  if not(obj.kill) && viewport_filter {
    obj.grounded = false
    process_obj(obj, state.map)
    // (* Run collision detection if moving object*)
    let evolved = check_collisions(collid, all_collids, state)
    // (* Render and update animation *)
    let vpt_adj_xy = state.vpt.coord_to_viewport(obj.pos)
    render(spr, vpt_adj_xy.x, vpt_adj_xy.y)
    if check_bbox_enabled() {
      render_box(spr, vpt_adj_xy.x, vpt_adj_xy.y)
    }
    if obj.vel.x != 0.0 || not(collid.target is Enemy(_)) {
      spr.update_animation()
    }
    evolved
  } else {
    @list.empty()
  }
}

// (* Converts a keypress to a list of control keys, allowing more than one key
// * to be processed each frame. *)

///|
fn translate_keys() -> List[Control] {
  let mut res : List[Control] = @list.empty()
  if which.val {
    if pressed_keys.up {
      res = res.add(Up)
    }
    if pressed_keys.down {
      res = res.add(Down)
    }
    if pressed_keys.left {
      res = res.add(Left)
    }
    if pressed_keys.right {
      res = res.add(Right)
    }
  } else {
    if pressed_keys.up2 {
      res = res.add(Up)
    }
    if pressed_keys.down2 {
      res = res.add(Down)
    }
    if pressed_keys.left2 {
      res = res.add(Left)
    }
    if pressed_keys.right2 {
      res = res.add(Right)
    }
  }
  res
}

// (* run_update is used to update all of the collidables at once. Primarily used
// * as a wrapper method. This method is necessary to differentiate between
// * the player collidable and the remaining collidables, as special operations
// * such as viewport centering only occur with the player.*)

///|
fn run_update_collid(
  state : St,
  collid : Collidable,
  all_collids : List[Collidable]
) -> Collidable {
  match collid {
    { target: Player(_, _), .. } as p => {
      let keys = translate_keys()
      p.object.crouch = false
      let player = match update_player(p, keys) {
        None => p
        Some(updated_collid) => updated_collid
      }
      let evolved = update_collidable(state, player, all_collids)
      collid_objs.val += evolved
      player
    }
    _ => {
      let obj = collid.object
      let evolved = update_collidable(state, collid, all_collids)
      if not(obj.kill) {
        collid_objs.val = (collid_objs.val + evolved).add(collid)
      }
      let new_parts = if obj.kill { kill(collid) } else { @list.empty() }
      particles.val += new_parts
      collid
    }
  }
}

// (* Primary update function to update and persist a particle *)

///|
fn run_update_particle(state : St, part : Particle) -> Unit {
  part.process()
  let x = part.pos.x - state.vpt.pos.x
  let y = part.pos.y - state.vpt.pos.y
  render(part.params.sprite, x, y)
  if not(part.kill) {
    particles.val = particles.val.add(part)
  }
}

///|
let which : Ref[Bool] = @ref.new(true)

///|
fn update_helper(
  time : Double,
  state : St,
  objs : List[Collidable],
  parts : List[Particle]
) -> Unit {
  if state.game_over == true {
    match players.val.find(fn(p) { not(p.object.kill) }) {
      None => game_lose()
      Some(_) => game_win()
    }
  } else {
    collid_objs.val = @list.empty()
    particles.val = @list.empty()
    let fps_ = calc_fps(last_time.val, time).to_int()
    last_time.val = time
    clear_canvas()

    // (* Parallax background *)
    let vpos_x_int = (state.vpt.pos.x / 5.0).to_int()
    let bgd_width = state.bgd.params.frame_size.0.to_int()
    draw_bgd(state.bgd, (vpos_x_int % bgd_width).to_double())
    which.val = false
    players.val = players.val.map(fn(p) {
      which.val = not(which.val)
      run_update_collid(state, p, objs)
    })
    match players.val.find(fn(p) { not(p.object.kill) }) {
      None => {
        state.game_over()
        game_lose()
      }
      Some(p) => {
        let a = p.object.pos
        let p = players.val.rev().find(fn(p) { not(p.object.kill) }).unwrap()
        let b = p.object.pos
        let c = XY::make((a.x + b.x) * 0.5, (a.y + b.y) * 0.5)
        state.update_viewport(c)
        let _ = objs.map(fn(obj) { run_update_collid(state, obj, objs) })
        let _ = parts.map(fn(part) { run_update_particle(state, part) })
        fps(fps_)
        hud(state.score, state.coins)
      }
    }
  }
}

///|
fn init {
  canvas
  .to_html_element()
  .to_element()
  .to_node()
  .to_event_target()
  .add_event_listener("keydown", fn(event) {
    match event.to_ui_event().unwrap().to_keyboard_event().unwrap().code() {
      "Space" => {
        halt.val = false
        start()
      }
      "KeyB" => pressed_keys.bbox = pressed_keys.bbox ^ 1
      "ArrowUp" => pressed_keys.up = true
      "ArrowDown" => pressed_keys.down = true
      "ArrowLeft" => pressed_keys.left = true
      "ArrowRight" => pressed_keys.right = true
      "KeyW" => pressed_keys.up2 = true
      "KeyS" => pressed_keys.down2 = true
      "KeyA" => pressed_keys.left2 = true
      "KeyD" => pressed_keys.right2 = true
      _ => ()
    }
  })
  canvas
  .to_html_element()
  .to_element()
  .to_node()
  .to_event_target()
  .add_event_listener("keyup", fn(event) {
    match event.to_ui_event().unwrap().to_keyboard_event().unwrap().code() {
      "KeyB" => pressed_keys.bbox = pressed_keys.bbox ^ 1
      "ArrowUp" => pressed_keys.up = false
      "ArrowDown" => pressed_keys.down = false
      "ArrowLeft" => pressed_keys.left = false
      "ArrowRight" => pressed_keys.right = false
      "KeyW" => pressed_keys.up2 = false
      "KeyS" => pressed_keys.down2 = false
      "KeyA" => pressed_keys.left2 = false
      "KeyD" => pressed_keys.right2 = false
      _ => ()
    }
  })
}

///|
fn game_update(t : Double) -> Unit {
  update_helper(t, state, collid_objs.val, particles.val)
}
