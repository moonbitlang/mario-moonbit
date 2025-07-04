///|
let dampen_jump : Double = 4.0

///|
let invuln : Int = 60

///|
fn player_attack_enemy(
  player : Collidable,
  enemy : Collidable,
  state : St
) -> (Collidable?, Collidable?) {
  player.object.invuln = 10
  player.object.jumping = false
  player.object.grounded = true
  guard enemy.target is Enemy(typ)
  match typ {
    GKoopaShell | RKoopaShell => {
      let r2 = evolve_enemy(player.object.dir, enemy)
      player.object.vel.y = -dampen_jump
      player.object.pos.y = player.object.pos.y - 5.0
      (None, r2)
    }
    _ => {
      dec_health(enemy)
      player.object.vel.y = -dampen_jump
      if state.multiplier == 8 {
        state.increase_score(800)
        enemy.object.score = 800
        (None, evolve_enemy(player.object.dir, enemy))
      } else {
        let score = 100 * state.multiplier
        state.increase_score(score)
        enemy.object.score = score
        state.double_multiplier()
        (None, evolve_enemy(player.object.dir, enemy))
      }
    }
  }
}

// (*enemy_attack_player is used when an enemy kills a player.*)

///|
fn enemy_attack_player(
  player : Collidable,
  enemy : Collidable
) -> (Collidable?, Collidable?) {
  guard enemy.target is Enemy(t2)
  match t2 {
    GKoopaShell | RKoopaShell => {
      let r2 = if enemy.object.vel.x == 0.0 {
        evolve_enemy(player.object.dir, enemy)
      } else {
        dec_health(player)
        player.object.invuln = invuln
        None
      }
      (None, r2)
    }
    _ => {
      dec_health(player)
      player.object.invuln = invuln
      (None, None)
    }
  }
}

///|
/// (*In the case that two enemies collide, they are to reverse directions. However,
/// *in the case that one or more of the two enemies is a koopa shell, then
/// *the koopa shell kills the other enemy. *)
fn col_enemy_enemy(
  enemy1 : Collidable,
  enemy2 : Collidable,
  dir : @utils.Dir2d
) -> (Collidable?, Collidable?) {
  guard enemy1.target is Enemy(t1) && enemy2.target is Enemy(t2)
  match (t1, t2) {
    (GKoopaShell, GKoopaShell)
    | (GKoopaShell, RKoopaShell)
    | (RKoopaShell, RKoopaShell)
    | (RKoopaShell, GKoopaShell) => {
      dec_health(enemy1)
      dec_health(enemy2)
      (None, None)
    }
    (RKoopaShell | GKoopaShell, _) =>
      if enemy1.object.vel.x == 0.0 {
        rev_dir(enemy2)
        (None, None)
      } else {
        dec_health(enemy2)
        (None, None)
      }
    (_, RKoopaShell | GKoopaShell) =>
      if enemy2.object.vel.x == 0.0 {
        rev_dir(enemy1)
        (None, None)
      } else {
        dec_health(enemy1)
        (None, None)
      }
    _ =>
      match dir {
        West | East => {
          rev_dir(enemy1)
          rev_dir(enemy2)
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
