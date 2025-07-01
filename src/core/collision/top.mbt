///|
let dampen_jump : Double = 4.0

///|
let invuln : Int = 60

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
        state.increase_score(800)
        o2.score = 800
        (None, evolve_enemy(o1.dir, typ, s2, o2))
      } else {
        let score = 100 * state.multiplier
        state.increase_score(score)
        o2.score = score
        state.double_multiplier()
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
  dir : @utils.Dir2d
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
  let obj = collid.object
  all_collids.filter(fn(_c) {
    state.vpt.in_viewport(obj.pos) ||
    collid.target is Player(_) ||
    state.vpt.out_of_viewport_below(obj.pos.y)
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
        let c_obj = c.object
        let new_objs = if c != h {
          match check_collision(c, h) {
            None => (Option::None, Option::None)
            Some(dir) =>
              if h.object.id != c_obj.id {
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
pub fn check_collisions(
  collid : Collidable,
  all_collids : List[Collidable],
  state : St
) -> List[Collidable] {
  match collid.target {
    Block(_) => @list.empty()
    _ => {
      let broad = broad_phase(collid, all_collids, state)
      narrow_phase(collid, broad, state)
    }
  }
}
