// (* Represents the values of relevant key bindings. *)
///|
struct Keys {
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

///|
struct St {
  bgd : Sprite
  mut vpt : Viewport
  map : Double
  mut score : Int
  mut coins : Int
  mut multiplier : Int
  mut game_over : Bool
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

// (* Adds [i] to the score in [state] *)
///|
fn update_score(state : St, i : Int) -> Unit {
  state.score = state.score + i
}

///|
fn player_attack_enemy(
  o1 : Object,
  typ : Enemy,
  s2 : Sprite,
  o2 : Object,
  state : St
) -> (Collidable?, Collidable?) {
  o1.invuln = 10
  o1.jumping = false
  o1.grounded = true
  match typ {
    GKoopaShell | RKoopaShell => {
      let r2 = evolve_enemy(o1.dir, typ, s2, o2)
      o1.vel.y = -dampen_jump
      o1.pos.y = o1.pos.y - 5.0
      (None, r2)
    }
    _ => {
      dec_health(o2)
      o1.vel.y = -dampen_jump
      if state.multiplier == 8 {
        update_score(state, 800)
        o2.score = 800
        (None, evolve_enemy(o1.dir, typ, s2, o2))
      } else {
        let score = 100 * state.multiplier
        update_score(state, score)
        o2.score = score
        state.multiplier = state.multiplier * 2
        (None, evolve_enemy(o1.dir, typ, s2, o2))
      }
    }
  }
}

// (*enemy_attack_player is used when an enemy kills a player.*)
///|
fn enemy_attack_player(
  o1 : Object,
  t2 : Enemy,
  s2 : Sprite,
  o2 : Object
) -> (Collidable?, Collidable?) {
  match t2 {
    GKoopaShell | RKoopaShell => {
      let r2 = if o2.vel.x == 0.0 {
        evolve_enemy(o1.dir, t2, s2, o2)
      } else {
        dec_health(o1)
        o1.invuln = invuln
        None
      }
      (None, r2)
    }
    _ => {
      dec_health(o1)
      o1.invuln = invuln
      (None, None)
    }
  }
}

// (*In the case that two enemies collide, they are to reverse directions. However,
// *in the case that one or more of the two enemies is a koopa shell, then
// *the koopa shell kills the other enemy. *)
///|
fn col_enemy_enemy(
  t1 : Enemy,
  s1 : Sprite,
  o1 : Object,
  t2 : Enemy,
  s2 : Sprite,
  o2 : Object,
  dir : Dir2d
) -> (Collidable?, Collidable?) {
  match (t1, t2) {
    (GKoopaShell, GKoopaShell)
    | (GKoopaShell, RKoopaShell)
    | (RKoopaShell, RKoopaShell)
    | (RKoopaShell, GKoopaShell) => {
      dec_health(o1)
      dec_health(o2)
      (None, None)
    }
    (RKoopaShell | GKoopaShell, _) =>
      if o1.vel.x == 0.0 {
        rev_dir(o2, t2, s2)
        (None, None)
      } else {
        dec_health(o2)
        (None, None)
      }
    (_, RKoopaShell | GKoopaShell) =>
      if o2.vel.x == 0.0 {
        rev_dir(o1, t1, s1)
        (None, None)
      } else {
        dec_health(o1)
        (None, None)
      }
    _ =>
      match dir {
        West | East => {
          rev_dir(o1, t1, s1)
          rev_dir(o2, t2, s2)
          (None, None)
        }
        _ => (None, None)
      }
  }
}

// (* Run the broad phase object filtering *)
///|
fn broad_phase(
  collid : Collidable,
  all_collids : List[Collidable],
  state : St
) -> List[Collidable] {
  let obj = collid.get_obj()
  all_collids.filter(fn(_c) {
    in_viewport(state.vpt, obj.pos) ||
    collid is Player(_) ||
    out_of_viewport_below(state.vpt, obj.pos.y)
  })
}

// (*narrow_phase of collision is used in order to continuously repeat through
// *each of the collidable objects to constantly check if collisions are
// *occurring.*)
///|
fn narrow_phase(
  c : Collidable,
  cs : List[Collidable],
  state : St
) -> List[Collidable] {
  fn narrow_helper(
    c : Collidable,
    cs : List[Collidable],
    state : St,
    acc : List[Collidable]
  ) -> List[Collidable] {
    match cs {
      Empty => acc
      More(h, tail=t) => {
        let c_obj = c.get_obj()
        let new_objs = if c != h {
          match check_collision(c, h) {
            None => (Option::None, Option::None)
            Some(dir) =>
              if h.get_obj().id != c_obj.id {
                process_collision(dir, c, h, state)
              } else {
                (None, None)
              }
          }
        } else {
          (None, None)
        }
        let acc = match new_objs {
          (None, Some(o)) => acc.add(o)
          (Some(o), None) => acc.add(o)
          (Some(o1), Some(o2)) => acc.add(o2).add(o1)
          (None, None) => acc
        }
        narrow_helper(c, t, state, acc)
      }
    }
  }

  narrow_helper(c, cs, state, @list.empty())
}

// (* This is an optimization setp to determine which objects require narrow phase
// * checking. This excludes static collidables, allowing collision to only be
// * checked with moving objects. This method is called once per collidable.
// * Collision detection proceeds as follows:
// * 1. Broad phase - filter collidables that cannot possibly collide with
// *    this object.
// * 2. Narrow phase - compare against all objects to determine whether there
// *    is a collision, and process the collision.
// * This method returns a list of objects that are created, which should be
// * added to the list of collidables for the next iteration.
// * *)
///|
fn check_collisions(
  collid : Collidable,
  all_collids : List[Collidable],
  state : St
) -> List[Collidable] {
  match collid {
    Block(_, _, _) => @list.empty()
    _ => {
      let broad = broad_phase(collid, all_collids, state)
      narrow_phase(collid, broad, state)
    }
  }
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
  let obj = collid.get_obj()
  let spr = collid.get_sprite()
  obj.invuln = if obj.invuln > 0 { obj.invuln - 1 } else { 0 }
  // (* Prevent position from being updated outside of viewport *)
  let viewport_filter = in_viewport(state.vpt, obj.pos) ||
    collid is Player(_) ||
    out_of_viewport_below(state.vpt, obj.pos.y)
  if not(obj.kill) && viewport_filter {
    obj.grounded = false
    process_obj(obj, state.map)
    // (* Run collision detection if moving object*)
    let evolved = check_collisions(collid, all_collids, state)
    // (* Render and update animation *)
    let vpt_adj_xy = coord_to_viewport(state.vpt, obj.pos)
    render(spr, vpt_adj_xy.x, vpt_adj_xy.y)
    if check_bbox_enabled() {
      render_box(spr, vpt_adj_xy.x, vpt_adj_xy.y)
    }
    if obj.vel.x != 0.0 || not(collid is Enemy(_)) {
      update_animation(spr)
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
  let mut res = @list.empty()
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
    Player(_, s, o) as p => {
      let keys = translate_keys()
      o.crouch = false
      let player = match update_player(o, keys) {
        None => p
        Some((new_typ, new_spr)) => {
          normalize_pos(o.pos, s.params, new_spr.params)
          Player(new_typ, new_spr, o)
        }
      }
      let evolved = update_collidable(state, player, all_collids)
      collid_objs.val += evolved
      player
    }
    _ => {
      let obj = collid.get_obj()
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
    match players.val.find(fn(p) { not(p.get_obj().kill) }) {
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
    match players.val.find(fn(p) { not(p.get_obj().kill) }) {
      None => {
        state.game_over = true
        game_lose()
      }
      Some(p) => {
        let a = p.get_obj().pos
        let p = players.val.rev().find(fn(p) { not(p.get_obj().kill) }).unwrap()
        let b = p.get_obj().pos
        let c = XY::make((a.x + b.x) * 0.5, (a.y + b.y) * 0.5)
        state.vpt = update(state.vpt, c)
        let _ = objs.map(fn(obj) { run_update_collid(state, obj, objs) })
        let _ = parts.map(fn(part) { run_update_particle(state, part) })
        fps(fps_)
        hud(state.score, state.coins)
      }
    }
  }
}

///|
pub fn game_update(t : Double) -> Unit {
  update_helper(t, state, collid_objs.val, particles.val)
}

///|
pub fn keydown_B() -> Unit {
  pressed_keys.bbox = pressed_keys.bbox ^ 1
}

///|
pub fn keydown_up() -> Unit {
  pressed_keys.up = true
}

///|
pub fn keydown_up2() -> Unit {
  pressed_keys.up2 = true
}

///|
pub fn keydown_down() -> Unit {
  pressed_keys.down = true
}

///|
pub fn keydown_down2() -> Unit {
  pressed_keys.down2 = true
}

///|
pub fn keydown_left() -> Unit {
  pressed_keys.left = true
}

///|
pub fn keydown_left2() -> Unit {
  pressed_keys.left2 = true
}

///|
pub fn keydown_right() -> Unit {
  pressed_keys.right = true
}

///|
pub fn keydown_right2() -> Unit {
  pressed_keys.right2 = true
}

///|
pub fn keyup_up() -> Unit {
  pressed_keys.up = false
}

///|
pub fn keyup_up2() -> Unit {
  pressed_keys.up2 = false
}

///|
pub fn keyup_down() -> Unit {
  pressed_keys.down = false
}

///|
pub fn keyup_down2() -> Unit {
  pressed_keys.down2 = false
}

///|
pub fn keyup_left() -> Unit {
  pressed_keys.left = false
}

///|
pub fn keyup_left2() -> Unit {
  pressed_keys.left2 = false
}

///|
pub fn keyup_right() -> Unit {
  pressed_keys.right = false
}

///|
pub fn keyup_right2() -> Unit {
  pressed_keys.right2 = false
}
