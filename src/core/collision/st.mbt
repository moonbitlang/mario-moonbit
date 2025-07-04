///|
/// Process collision is called to match each of the possible collisions that
/// may occur. Returns a pair of collidable options, representing objects that
/// were created from the existing ones. That is, the first element represents
/// a new item spawned as a result of the first collidable. None indicates that
/// no new item should be spawned. Transformations to existing objects occur
/// mutably, as many changes are side-effectual.
fn process_collision(
  dir : Dir2d,
  c1 : Collidable,
  c2 : Collidable,
  state : St
) -> (Collidable?, Collidable?) {
  match (c1.target, c2.target, dir) {
    (Player(_), Enemy(typ), South) =>
      player_attack_enemy(c1.object, typ, c2.sprite, c2.object, state)
    (Enemy(typ), Player(_), North) =>
      player_attack_enemy(c2.object, typ, c1.sprite, c1.object, state)
    (Player(_), Enemy(t2), _) =>
      enemy_attack_player(c1.object, t2, c2.sprite, c2.object)
    (Enemy(t2), Player(_), _) =>
      enemy_attack_player(c2.object, t2, c1.sprite, c1.object)
    (Player(_), Item(t2), _) =>
      match t2 {
        Mushroom => {
          dec_health(c2.object)
          if c1.object.health == 2 {
            ()
          } else {
            c1.object.health = c1.object.health + 1
          }
          c1.object.vel.x = 0.0
          c1.object.vel.y = 0.0
          state.increase_score(1000)
          c2.object.score = 1000
          (None, None)
        }
        Coin => {
          state.increase_coin()
          dec_health(c2.object)
          state.increase_score(100)
          (None, None)
        }
      }
    (Item(t2), Player(_), _) =>
      match t2 {
        Mushroom => {
          dec_health(c1.object)
          if c2.object.health == 2 {
            ()
          } else {
            c2.object.health = c2.object.health + 1
          }
          c2.object.vel.x = 0.0
          c2.object.vel.y = 0.0
          state.increase_score(1000)
          c1.object.score = 1000
          (None, None)
        }
        Coin => {
          state.increase_coin()
          dec_health(c1.object)
          state.increase_score(100)
          (None, None)
        }
      }
    (Enemy(t1), Enemy(t2), dir) =>
      col_enemy_enemy(t1, c1.sprite, c1.object, t2, c2.sprite, c2.object, dir)
    (Enemy(t1), Block(t2), East) | (Enemy(t1), Block(t2), West) =>
      match (t1, t2) {
        (RKoopaShell, Brick) | (GKoopaShell, Brick) => {
          dec_health(c2.object)
          reverse_left_right(c1.object)
          (None, None)
        }
        (RKoopaShell, QBlock(typ)) | (GKoopaShell, QBlock(typ)) => {
          let updated_block = evolve_block(c2.object)
          let spawned_item = spawn_above(c1.object.dir, c2.object, typ)
          rev_dir(c1.object, t1, c1.sprite)
          (Some(updated_block), Some(spawned_item))
        }
        (_, _) => {
          rev_dir(c1.object, t1, c1.sprite)
          (None, None)
        }
      }
    (Item(_), Block(_), East) | (Item(_), Block(_), West) => {
      reverse_left_right(c1.object)
      (None, None)
    }
    (Enemy(_), Block(_), _) => {
      collide_block(true, dir, c1.object)
      (None, None)
    }
    (Item(_), Block(_), _) => {
      collide_block(true, dir, c1.object)
      (None, None)
    }
    (Player(t1, _), Block(t), North) =>
      match t {
        QBlock(typ) => {
          let updated_block = evolve_block(c2.object)
          let spawned_item = spawn_above(c1.object.dir, c2.object, typ)
          collide_block(true, dir, c1.object)
          (Option::Some(spawned_item), Option::Some(updated_block))
        }
        Brick =>
          if t1 is Large {
            collide_block(true, dir, c1.object)
            dec_health(c2.object)
            (None, None)
          } else {
            collide_block(true, dir, c1.object)
            (None, None)
          }
        Panel => {
          state.game_over()
          game_win()
          (None, None)
        }
        _ => {
          collide_block(true, dir, c1.object)
          (None, None)
        }
      }
    (Player(_), Block(t), _) =>
      match t {
        Panel => {
          state.game_over()
          game_win()
          (None, None)
        }
        _ =>
          match dir {
            South => {
              state.reset_multiplier()
              collide_block(true, dir, c1.object)
              (None, None)
            }
            _ => {
              collide_block(true, dir, c1.object)
              (None, None)
            }
          }
      }
    _ => (None, None)
  }
}
