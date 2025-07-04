// (* Represents the values of relevant key bindings. *)

///|
priv struct DirKey {
  mut up : Bool
  mut down : Bool
  mut left : Bool
  mut right : Bool
} derive(Default)

///|
priv struct Keys {
  control : Array[DirKey]
  mut bbox : Bool
}

// (*pressed_keys instantiates the keys.*)

///|
let pressed_keys : Keys = {
  control: Array::makei(player_count, _ => DirKey::default()),
  bbox: false,
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

///|
/// (* Returns whether the bounding box should be drawn *)
fn check_bbox_enabled() -> Bool {
  pressed_keys.bbox
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

///|
/// (* Converts a keypress to a list of control keys, allowing more than one key
/// * to be processed each frame. *)
fn translate_keys(index : Int) -> List[Control] {
  let mut res : List[Control] = @list.empty()
  if pressed_keys.control[index].up {
    res = res.add(Up)
  }
  if pressed_keys.control[index].down {
    res = res.add(Down)
  }
  if pressed_keys.control[index].left {
    res = res.add(Left)
  }
  if pressed_keys.control[index].right {
    res = res.add(Right)
  }
  res
}

///|
/// (* run_update is used to update all of the collidables at once. Primarily used
/// * as a wrapper method. This method is necessary to differentiate between
/// * the player collidable and the remaining collidables, as special operations
/// * such as viewport centering only occur with the player.*)
fn run_update_player_collid(
  state : St,
  collid : Collidable,
  all_collids : List[Collidable],
  player_index : Int
) -> Collidable {
  guard collid.target is Player(_, _)
  let keys = translate_keys(player_index)
  collid.object.crouch = false
  let player = match update_player(collid, keys) {
    None => collid
    Some(updated_collid) => updated_collid
  }
  let evolved = update_collidable(state, player, all_collids)
  collid_objs.val += evolved
  player
}

///|
fn run_update_obj_collid(
  state : St,
  collid : Collidable,
  all_collids : List[Collidable]
) -> Unit {
  let obj = collid.object
  let evolved = update_collidable(state, collid, all_collids)
  if obj.kill {
    particles.val += kill(collid)
  } else {
    collid_objs.val = (collid_objs.val + evolved).add(collid)
  }
}

///|
/// (* Primary update function to update and persist a particle *)
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
fn update_helper(
  time : Double,
  state : St,
  objs : List[Collidable],
  parts : List[Particle]
) -> Unit {
  if state.game_over == true {
    if players.val.any(fn(p) { not(p.object.kill) }) {
      game_win()
    } else {
      game_lose()
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
    players.val = players.val.mapi(fn(i, p) {
      run_update_player_collid(state, p, objs, i)
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
        objs.each(fn(obj) { run_update_obj_collid(state, obj, objs) })
        parts.each(fn(part) { run_update_particle(state, part) })
        fps(fps_)
        hud(state.score, state.coins)
      }
    }
  }
}

///|
fn game_update(t : Double) -> Unit {
  update_helper(t, state, collid_objs.val, particles.val)
}
