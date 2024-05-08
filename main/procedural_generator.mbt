// (*Note: Canvas is 512 by 256 (w*h) -> 32 by 16 blocks*)

// (*Holds obj typ and its coordinates. (int, (x-coord, y-coord))*)
// type obj_coord =  int * (float * float)

// (*Checks if the given location checkloc is already part of the list of locations
// * in loclist.*)
fn mem_loc(
  checkloc : (Double, Double),
  loclist : List[(Int, (Double, Double))]
) -> Bool {
  match loclist {
    Nil => false
    Cons(h, t) =>
      checkloc.0 == h.1.0 && checkloc.1 == h.1.1 || mem_loc(checkloc, t)
  }
}

// (*Converts list of locations from blocksize to pixelsize by multiplying (x,y) by
// * 16.*)
fn convert_list(
  list : List[(Int, (Double, Double))]
) -> List[(Int, (Double, Double))] {
  list.map(fn(x) { (x.0, (x.1.0 * 16.0, x.1.1 * 16.0)) })
}

// (*Chooses what type of enemy should be instantiated given typ number*)
fn choose_enemy_typ(typ : Int) -> Enemy {
  match typ {
    0 => RKoopa
    1 => GKoopa
    2 => Goomba
    _ => abort("Shouldn't reach here")
  }
}

// (*Chooses what type of block should be instantiated given typ number*)
fn choose_sblock_typ(typ : Int) -> Block {
  match typ {
    0 => Brick
    1 => UnBBlock
    2 => Cloud
    3 => QBlock(Mushroom)
    4 => Ground
    _ => abort("Shouldn't reach here")
  }
}

// (*Optimizes lst such that there are no two items in the list that have the same
// * coordinates. If there is one, it is removed.*)
fn avoid_overlap(
  lst : List[(Int, (Double, Double))],
  currentLst : List[(Int, (Double, Double))]
) -> List[(Int, (Double, Double))] {
  match lst {
    Nil => Nil
    Cons(h, t) =>
      if mem_loc(h.1, currentLst) {
        avoid_overlap(t, currentLst)
      } else {
        Cons(h, avoid_overlap(t, currentLst))
      }
  }
}

// (*Gets rid of objects with coordinates in the ending frame, within 128 pixels of
// * the start, at the very top, and two blocks from the ground.*)
fn trim_edges(
  lst : List[(Int, (Double, Double))],
  blockw : Double,
  blockh : Double
) -> List[(Int, (Double, Double))] {
  match lst {
    Nil => Nil
    Cons(h, t) => {
      let cx = h.1.0
      let cy = h.1.1
      let pixx = blockw * 16.0
      let pixy = blockh * 16.0
      if cx < 128.0 || pixx - cx < 528.0 || cy == 0.0 || pixy - cy < 48.0 {
        trim_edges(t, blockw, blockh)
      } else {
        Cons(h, trim_edges(t, blockw, blockh))
      }
    }
  }
}

// (*Generates a stair formation with block typ being dependent on typ. This type
// * of stair formation requires that the first step be on the ground.*)
fn generate_ground_stairs(
  cbx : Double,
  cby : Double,
  typ : Int
) -> List[(Int, (Double, Double))] {
  let x = List::Nil
  let x = List::Cons((typ, (cbx + 3.0, cby - 3.0)), x)
  let x = List::Cons((typ, (cbx + 3.0, cby - 2.0)), x)
  let x = List::Cons((typ, (cbx + 2.0, cby - 2.0)), x)
  let x = List::Cons((typ, (cbx + 3.0, cby - 1.0)), x)
  let x = List::Cons((typ, (cbx + 2.0, cby - 1.0)), x)
  let x = List::Cons((typ, (cbx + 1.0, cby - 1.0)), x)
  let x = List::Cons((typ, (cbx + 3.0, cby - 0.0)), x)
  let x = List::Cons((typ, (cbx + 2.0, cby - 0.0)), x)
  let x = List::Cons((typ, (cbx + 1.0, cby - 0.0)), x)
  let x = List::Cons((typ, (cbx + 0.0, cby - 0.0)), x)
  x
}

// (*Generates a stair formation going upwards.*)
fn generate_airup_stairs(
  cbx : Double,
  cby : Double,
  typ : Int
) -> List[(Int, (Double, Double))] {
  let x = List::Nil
  let x = List::Cons((typ, (cbx + 6.0, cby - 2.0)), x)
  let x = List::Cons((typ, (cbx + 5.0, cby - 2.0)), x)
  let x = List::Cons((typ, (cbx + 4.0, cby - 2.0)), x)
  let x = List::Cons((typ, (cbx + 4.0, cby - 1.0)), x)
  let x = List::Cons((typ, (cbx + 3.0, cby - 1.0)), x)
  let x = List::Cons((typ, (cbx + 1.0, cby - 0.0)), x)
  let x = List::Cons((typ, (cbx + 0.0, cby - 0.0)), x)
  x
}

// (*Generates a stair formation going downwards*)
fn generate_airdown_stairs(
  cbx : Double,
  cby : Double,
  typ : Int
) -> List[(Int, (Double, Double))] {
  let x = List::Nil
  let x = List::Cons((typ, (cbx + 6.0, cby + 2.0)), x)
  let x = List::Cons((typ, (cbx + 5.0, cby + 2.0)), x)
  let x = List::Cons((typ, (cbx + 3.0, cby + 1.0)), x)
  let x = List::Cons((typ, (cbx + 2.0, cby + 1.0)), x)
  let x = List::Cons((typ, (cbx + 2.0, cby + 0.0)), x)
  let x = List::Cons((typ, (cbx + 1.0, cby + 0.0)), x)
  let x = List::Cons((typ, (cbx + 0.0, cby + 0.0)), x)
  x
}

// (*Generates a cloud block platform with some length num.*)
fn generate_clouds(
  cbx : Double,
  cby : Double,
  typ : Int,
  num : Int
) -> List[(Int, (Double, Double))] {
  if num <= 0 {
    List::Nil
  } else {
    List::Cons((typ, (cbx, cby)), generate_clouds(cbx + 1.0, cby, typ, num - 1))
  }
}

fn generate_coins(
  block_coord : List[(Int, (Double, Double))]
) -> List[(Int, (Double, Double))] {
  // (* let place_coin = Random.int 2 in *)
  let place_coin = random(0, 2)
  match block_coord {
    List::Nil => List::Nil
    List::Cons(h, t) =>
      if place_coin == 0 {
        let xc = h.1.0
        let yc = h.1.1
        List::Cons((0, (xc, yc - 16.0)), generate_coins(t))
      } else {
        generate_coins(t)
      }
  }
}

// (*Chooses the form of the blocks to be placed.
// * When called, leaves a 1 block gap from canvas size.
// * 1. If current xblock or yblock is greater than canvas width or height
// *    respectively, return an empty list.
// * 2. If current xblock or yblock is within 10 blocks of the left and right sides
// *    of the level map, prevent any objects from being initialized.
// * 3. Else call helper methods to created block formations and return obj_coord
// *    list.
// **)
fn choose_block_pattern(
  blockw : Double,
  blockh : Double,
  cbx : Double,
  cby : Double,
  prob : Int
) -> List[(Int, (Double, Double))] {
  if cbx > blockw || cby > blockh {
    List::Nil
  } else {
    let block_typ = random(0, 4)
    let stair_typ = random(0, 2)
    let life_block_chance = random(0, 5)
    let middle_block = if life_block_chance == 0 { 3 } else { stair_typ }
    match prob {
      0 =>
        if blockw - cbx > 2.0 {
          List::[
            (stair_typ, (cbx, cby)),
            (middle_block, (cbx + 1.0, cby)),
            (stair_typ, (cbx + 2.0, cby)),
          ]
        } else if blockw - cbx > 1.0 {
          List::[(block_typ, (cbx, cby)), (block_typ, (cbx + 1.0, cby))]
        } else {
          List::[(block_typ, (cbx, cby))]
        }
      1 => {
        let num_clouds = random(0, 5) + 5
        if cby < 5.0 {
          generate_clouds(cbx, cby, 2, num_clouds)
        } else {
          List::Nil
        }
      }
      2 =>
        if blockh - cby == 1.0 {
          generate_ground_stairs(cbx, cby, stair_typ)
        } else {
          List::Nil
        }
      3 =>
        if stair_typ == 0 && blockh - cby > 3.0 {
          generate_airdown_stairs(cbx, cby, stair_typ)
        } else if blockh - cby > 2.0 {
          generate_airup_stairs(cbx, cby, stair_typ)
        } else {
          List::[(stair_typ, (cbx, cby))]
        }
      4 =>
        if cby + 3.0 - blockh == 2.0 {
          List::[(stair_typ, (cbx, cby))]
        } else if cby + 3.0 - blockh == 1.0 {
          List::[(stair_typ, (cbx, cby)), (stair_typ, (cbx, cby + 1.0))]
        } else {
          List::[
            (stair_typ, (cbx, cby)),
            (stair_typ, (cbx, cby + 1.0)),
            (stair_typ, (cbx, cby + 2.0)),
          ]
        }
      5 => List::[(3, (cbx, cby))]
      _ => abort("")
    }
  }
}

// (*Generates a list of enemies to be placed on the ground.*)
fn generate_enemies(
  blockw : Double,
  blockh : Double,
  cbx : Double,
  cby : Double,
  acc : List[(Int, (Double, Double))]
) -> List[(Int, (Double, Double))] {
  if cbx > blockw - 32.0 {
    List::Nil
  } else if cby > blockh - 1.0 || cbx < 15.0 {
    generate_enemies(blockw, blockh, cbx + 1.0, 0.0, acc)
  } else if mem_loc((cbx, cby), acc) || cby == 0.0 {
    generate_enemies(blockw, blockh, cbx, cby + 1.0, acc)
  } else {
    let prob = random(0, 30)
    let enem_prob = 3
    if prob < enem_prob && blockh - 1.0 == cby {
      List::Cons(
        (prob, (cbx * 16.0, cby * 16.0)),
        generate_enemies(blockw, blockh, cbx, cby + 1.0, acc),
      )
    } else {
      generate_enemies(blockw, blockh, cbx, cby + 1.0, acc)
    }
  }
}

// (*Generates a list of enemies to be placed upon the block objects.*)
fn generate_block_enemies(
  block_coord : List[(Int, (Double, Double))]
) -> List[(Int, (Double, Double))] {
  let place_enemy = random(0, 20)
  let enemy_typ = random(0, 3)
  match block_coord {
    Nil => Nil
    Cons(h, t) =>
      if place_enemy == 0 {
        let xc = h.1.0
        let yc = h.1.1
        List::Cons((enemy_typ, (xc, yc - 16.0)), generate_block_enemies(t))
      } else {
        generate_block_enemies(t)
      }
  }
}

// (*Generates an obj_coord list (typ, coordinates) of blocks to be placed.*)
fn generate_block_locs(
  blockw : Double,
  blockh : Double,
  cbx : Double,
  cby : Double,
  acc : List[(Int, (Double, Double))]
) -> List[(Int, (Double, Double))] {
  if blockw - cbx < 33.0 {
    acc
  } else if cby > blockh - 1.0 {
    generate_block_locs(blockw, blockh, cbx + 1.0, 0.0, acc)
  } else if mem_loc((cbx, cby), acc) || cby == 0.0 {
    generate_block_locs(blockw, blockh, cbx, cby + 1.0, acc)
  } else {
    let prob = random(0, 100)
    let block_prob = 5
    if prob < block_prob {
      let newacc = choose_block_pattern(blockw, blockh, cbx, cby, prob)
      let undup_lst = avoid_overlap(newacc, acc)
      let called_acc = acc + undup_lst
      generate_block_locs(blockw, blockh, cbx, cby + 1.0, called_acc)
    } else {
      generate_block_locs(blockw, blockh, cbx, cby + 1.0, acc)
    }
  }
}

// (*Generates the ending item panel at the end of the level. Games ends upon
// * collision with player.*)
fn generate_panel(blockw : Double, blockh : Double) -> Collidable {
  spawn(Block(Panel), blockw * 16.0 - 256.0, blockh * 16.0 * 2.0 / 3.0)
}

// (*Generates the list of brick locations needed to display the ground.
// * 1/10 chance that a ground block is skipped each call to create holes.*)
fn generate_ground(
  blockw : Double,
  blockh : Double,
  inc : Double,
  acc : List[(Int, (Double, Double))]
) -> List[(Int, (Double, Double))] {
  if inc > blockw {
    acc
  } else if inc > 10.0 {
    let skip = random(0, 10)
    let newacc = acc + List::[(4, (inc * 16.0, blockh * 16.0))]
    if skip == 7 && blockw - inc > 32.0 {
      generate_ground(blockw, blockh, inc + 1.0, acc)
    } else {
      generate_ground(blockw, blockh, inc + 1.0, newacc)
    }
  } else {
    let newacc = acc + List::[(4, (inc * 16.0, blockh * 16.0))]
    generate_ground(blockw, blockh, inc + 1.0, newacc)
  }
}

// (*Converts the obj_coord list called by generate_block_locs to a list of objects
// * with the coordinates given from the obj_coord list. *)
fn convert_to_block_obj(
  lst : List[(Int, (Double, Double))]
) -> List[Collidable] {
  match lst {
    Nil => Nil
    Cons(h, t) => {
      let sblock_typ = choose_sblock_typ(h.0)
      let ob = spawn(Block(sblock_typ), h.1.0, h.1.1)
      List::[ob] + convert_to_block_obj(t)
    }
  }
}

// (*Converts the obj_coord list called by generate_enemies to a list of objects
// * with the coordinates given from the obj_coord list. *)
fn convert_to_enemy_obj(
  lst : List[(Int, (Double, Double))]
) -> List[Collidable] {
  match lst {
    Nil => Nil
    Cons(h, t) => {
      let senemy_typ = choose_enemy_typ(h.0)
      let ob = spawn(Enemy(senemy_typ), h.1.0, h.1.1)
      List::[ob] + convert_to_enemy_obj(t)
    }
  }
}

// (*Converts the list of coordinates into a list of Coin objects*)
fn convert_to_coin_obj(lst : List[(Int, (Double, Double))]) -> List[Collidable] {
  match lst {
    Nil => Nil
    Cons(h, t) => {
      let sitem_typ = Item::Coin
      let ob = spawn(Item(sitem_typ), h.1.0, h.1.1)
      List::[ob] + convert_to_coin_obj(t)
    }
  }
}

// (*Procedurally generates a list of collidables given canvas width, height and
// * context. Arguments block width (blockw) and block height (blockh) are in
// * block form, not pixels.*)
fn generate_helper(blockw : Double, blockh : Double) -> List[Collidable] {
  let block_locs = generate_block_locs(blockw, blockh, 0.0, 0.0, Nil)
  let converted_block_locs = trim_edges(
    convert_list(block_locs),
    blockw,
    blockh,
  )
  let obj_converted_block_locs = convert_to_block_obj(converted_block_locs)
  let ground_blocks = generate_ground(blockw, blockh, 0.0, Nil)
  let obj_converted_ground_blocks = convert_to_block_obj(ground_blocks)
  let block_locations = block_locs + ground_blocks
  let all_blocks = obj_converted_block_locs + obj_converted_ground_blocks
  let enemy_locs = generate_enemies(blockw, blockh, 0.0, 0.0, block_locations)
  let obj_converted_enemies = convert_to_enemy_obj(enemy_locs)
  let coin_locs = generate_coins(converted_block_locs)
  let undup_coin_locs = trim_edges(
    avoid_overlap(coin_locs, converted_block_locs),
    blockw,
    blockh,
  )
  let converted_block_coin_locs = converted_block_locs + coin_locs
  let enemy_block_locs = generate_block_enemies(converted_block_locs)
  let undup_enemy_block_locs = avoid_overlap(
    enemy_block_locs, converted_block_coin_locs,
  )
  let obj_enemy_blocks = convert_to_enemy_obj(undup_enemy_block_locs)
  let coin_objects = convert_to_coin_obj(undup_coin_locs)
  let obj_panel = generate_panel(blockw, blockh)
  all_blocks + obj_converted_enemies + coin_objects + obj_enemy_blocks + List::[
    obj_panel,
  ]
}

// (*Main function called to procedurally generate the level map. w and h args
// * are in pixel form. Converts to block form to call generate_helper. Spawns
// * the list of collidables received from generate_helper to display on canvas.*)
pub fn generate(
  player_count : Int,
  w : Double,
  h : Double
) -> (List[Collidable], List[Collidable]) {
  let blockw = w / 16.0
  let blockh = h / 16.0 - 1.0
  let collide_list = generate_helper(blockw, blockh)
  let mut start = 50.0
  let players = Array::make(player_count, Spawn::Player(Small, Standing)).to_list().map(
    fn(s) {
      let c = spawn(s, start, 0.0)
      start = start - 30.0
      c
    },
  )
  (players, collide_list)
}
