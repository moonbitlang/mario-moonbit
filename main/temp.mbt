// (* Process collision is called to match each of the possible collisions that
// * may occur. Returns a pair of collidable options, representing objects that
// * were created from the existing ones. That is, the first element represents
// * a new item spawned as a result of the first collidable. None indicates that
// * no new item should be spawned. Transformations to existing objects occur
// * mutably, as many changes are side-effectual.*)

///|
fn process_collision(
  dir : @utils.Dir2d,
  c1 : Collidable,
  c2 : Collidable,
  state : St
) -> (Collidable?, Collidable?) {
  match (c1, c2, dir) {
    (
      { target: Player(_), object: o1, .. },
      { target: Enemy(typ), sprite: s2, object: o2 },
      South,
    )
    | (
      { target: Enemy(typ), sprite: s2, object: o2 },
      { target: Player(_), sprite: _, object: o1 },
      North,
    ) => player_attack_enemy(o1, typ, s2, o2, state)
    (
      { target: Player(_), sprite: _, object: o1 },
      { target: Enemy(t2), sprite: s2, object: o2 },
      _,
    )
    | (
      { target: Enemy(t2), sprite: s2, object: o2 },
      { target: Player(_), sprite: _, object: o1 },
      _,
    ) => enemy_attack_player(o1, t2, s2, o2)
    (
      { target: Player(_), sprite: _, object: o1 },
      { target: Item(t2), sprite: _, object: o2 },
      _,
    )
    | (
      { target: Item(t2), sprite: _, object: o2 },
      { target: Player(_), sprite: _, object: o1 },
      _,
    ) =>
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
    (
      { target: Enemy(t1), sprite: s1, object: o1 },
      { target: Enemy(t2), sprite: s2, object: o2 },
      dir,
    ) => col_enemy_enemy(t1, s1, o1, t2, s2, o2, dir)
    (
      { target: Enemy(t1), sprite: s1, object: o1 },
      { target: Block(t2), sprite: _, object: o2 },
      East,
    )
    | (
      { target: Enemy(t1), sprite: s1, object: o1 },
      { target: Block(t2), sprite: _, object: o2 },
      West,
    ) =>
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
    ({ target: Item(_), object: o1, .. }, { target: Block(_), .. }, East)
    | ({ target: Item(_), object: o1, .. }, { target: Block(_), .. }, West) => {
      reverse_left_right(o1)
      (None, None)
    }
    ({ target: Enemy(_), object: o1, .. }, { target: Block(_), .. }, _)
    | ({ target: Item(_), object: o1, .. }, { target: Block(_), .. }, _) => {
      collide_block(true, dir, o1)
      (None, None)
    }
    (
      { target: Player(t1, _), object: o1, .. },
      { target: Block(t), object: o2, .. },
      North,
    ) =>
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
    ({ target: Player(_), object: o1, .. }, { target: Block(t), .. }, _) =>
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
