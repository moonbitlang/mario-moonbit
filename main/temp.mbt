// (* Process collision is called to match each of the possible collisions that
// * may occur. Returns a pair of collidable options, representing objects that
// * were created from the existing ones. That is, the first element represents
// * a new item spawned as a result of the first collidable. None indicates that
// * no new item should be spawned. Transformations to existing objects occur
// * mutably, as many changes are side-effectual.*)
///|
fn process_collision(
  dir : Dir2d,
  c1 : Collidable,
  c2 : Collidable,
  state : St
) -> (Collidable?, Collidable?) {
  match (c1, c2, dir) {
    (Player(_, _, o1), Enemy(typ, s2, o2), South)
    | (Enemy(typ, s2, o2), Player(_, _, o1), North) =>
      player_attack_enemy(o1, typ, s2, o2, state)
    (Player(_, _, o1), Enemy(t2, s2, o2), _)
    | (Enemy(t2, s2, o2), Player(_, _, o1), _) =>
      enemy_attack_player(o1, t2, s2, o2)
    (Player(_, _, o1), Item(t2, _, o2), _)
    | (Item(t2, _, o2), Player(_, _, o1), _) =>
      match t2 {
        Mushroom => {
          dec_health(o2)
          if o1.health == 2 {
            ()
          } else {
            o1.health = o1.health + 1
          }
          o1.vel.x = 0.0
          o1.vel.y = 0.0
          update_score(state, 1000)
          o2.score = 1000
          (None, None)
        }
        Coin => {
          state.coins = state.coins + 1
          dec_health(o2)
          update_score(state, 100)
          (None, None)
        }
      }
    (Enemy(t1, s1, o1), Enemy(t2, s2, o2), dir) =>
      col_enemy_enemy(t1, s1, o1, t2, s2, o2, dir)
    (Enemy(t1, s1, o1), Block(t2, _, o2), East)
    | (Enemy(t1, s1, o1), Block(t2, _, o2), West) =>
      match (t1, t2) {
        (RKoopaShell, Brick) | (GKoopaShell, Brick) => {
          dec_health(o2)
          reverse_left_right(o1)
          (None, None)
        }
        (RKoopaShell, QBlock(typ)) | (GKoopaShell, QBlock(typ)) => {
          let updated_block = evolve_block(o2)
          let spawned_item = spawn_above(o1.dir, o2, typ)
          rev_dir(o1, t1, s1)
          (Some(updated_block), Some(spawned_item))
        }
        (_, _) => {
          rev_dir(o1, t1, s1)
          (None, None)
        }
      }
    (Item(_, _, o1), Block(_), East) | (Item(_, _, o1), Block(_), West) => {
      reverse_left_right(o1)
      (None, None)
    }
    (Enemy(_, _, o1), Block(_), _) | (Item(_, _, o1), Block(_), _) => {
      collide_block(true, dir, o1)
      (None, None)
    }
    (Player(t1, _, o1), Block(t, _, o2), North) =>
      match t {
        QBlock(typ) => {
          let updated_block = evolve_block(o2)
          let spawned_item = spawn_above(o1.dir, o2, typ)
          collide_block(true, dir, o1)
          (Option::Some(spawned_item), Option::Some(updated_block))
        }
        Brick =>
          if t1 == Large {
            collide_block(true, dir, o1)
            dec_health(o2)
            (None, None)
          } else {
            collide_block(true, dir, o1)
            (None, None)
          }
        Panel => {
          state.game_over = true
          game_win()
          (None, None)
        }
        _ => {
          collide_block(true, dir, o1)
          (None, None)
        }
      }
    (Player(_, _, o1), Block(t, _, _), _) =>
      match t {
        Panel => {
          state.game_over = true
          game_win()
          (None, None)
        }
        _ =>
          match dir {
            South => {
              state.multiplier = 1
              collide_block(true, dir, o1)
              (None, None)
            }
            _ => {
              collide_block(true, dir, o1)
              (None, None)
            }
          }
      }
    _ => (None, None)
  }
}
