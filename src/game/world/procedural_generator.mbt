// (*Note: Canvas is 512 by 256 (w*h) -> 32 by 16 blocks*)

// (*Holds obj typ and its coordinates. (int, (x-coord, y-coord))*)
// type obj_coord =  int * (float * float)

///|
let rand : @random.Rand = @random.Rand::new()

///|
fn random(l : Int, r : Int) -> Int {
  l + rand.int(limit=r - l)
}

///| (*Checks if the given location checkloc is already part of the list of locations
///  * in loclist.*)
///
fn[T] mem_loc(
  checkloc : (Double, Double),
  loclist : List[(T, (Double, Double))]
) -> Bool {
  loclist.any(h => checkloc == h.1)
}

///| (*Chooses what type of block should be instantiated given typ number*)
///
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

///| (*Chooses what type of enemy should be instantiated given typ number*)
///
fn choose_enemy_typ(typ : Int) -> Enemy {
  match typ {
    0 => RKoopa
    1 => GKoopa
    2 => Goomba
    _ => abort("Shouldn't reach here")
  }
}

///| (*Optimizes lst such that there are no two items in the list that have the same
///  * coordinates. If there is one, it is removed.*)
///
pub fn[T1, T2] avoid_overlap(
  lst : List[(T1, (Double, Double))],
  currentLst : List[(T2, (Double, Double))]
) -> List[(T1, (Double, Double))] {
  lst.filter(h => not(mem_loc(h.1, currentLst)))
}

///| (*Gets rid of objects with coordinates in the ending frame, within 128 pixels of
///  * the start, at the very top, and two blocks from the ground.*)
///
pub fn[T] trim_edges(
  lst : List[(T, (Double, Double))],
  blockw : Double,
  blockh : Double
) -> List[(T, (Double, Double))] {
  lst.filter(h => {
    let cx = h.1.0
    let cy = h.1.1
    let pixx = blockw * 16.0
    let pixy = blockh * 16.0
    not(cx < 128.0 || pixx - cx < 528.0 || cy == 0.0 || pixy - cy < 48.0)
  })
}

///| (*Generates a stair formation with block typ being dependent on typ. This type
///  * of stair formation requires that the first step be on the ground.*)
///
fn generate_ground_stairs(
  cbx : Double,
  cby : Double,
  typ : Block
) -> List[(Block, (Double, Double))] {
  @list.empty()
  .add((typ, (cbx + 0.0, cby - 0.0)))
  .add((typ, (cbx + 1.0, cby - 0.0)))
  .add((typ, (cbx + 2.0, cby - 0.0)))
  .add((typ, (cbx + 3.0, cby - 0.0)))
  .add((typ, (cbx + 1.0, cby - 1.0)))
  .add((typ, (cbx + 2.0, cby - 1.0)))
  .add((typ, (cbx + 3.0, cby - 1.0)))
  .add((typ, (cbx + 2.0, cby - 2.0)))
  .add((typ, (cbx + 3.0, cby - 2.0)))
  .add((typ, (cbx + 3.0, cby - 3.0)))
}

///| (*Generates a stair formation going upwards.*)
///
fn generate_airup_stairs(
  cbx : Double,
  cby : Double,
  typ : Block
) -> List[(Block, (Double, Double))] {
  @list.empty()
  .add((typ, (cbx + 0.0, cby - 0.0)))
  .add((typ, (cbx + 1.0, cby - 0.0)))
  .add((typ, (cbx + 3.0, cby - 1.0)))
  .add((typ, (cbx + 4.0, cby - 1.0)))
  .add((typ, (cbx + 4.0, cby - 2.0)))
  .add((typ, (cbx + 5.0, cby - 2.0)))
  .add((typ, (cbx + 6.0, cby - 2.0)))
}

///| (*Generates a stair formation going downwards*)
///
fn generate_airdown_stairs(
  cbx : Double,
  cby : Double,
  typ : Block
) -> List[(Block, (Double, Double))] {
  @list.empty()
  .add((typ, (cbx + 0.0, cby + 0.0)))
  .add((typ, (cbx + 1.0, cby + 0.0)))
  .add((typ, (cbx + 2.0, cby + 0.0)))
  .add((typ, (cbx + 2.0, cby + 1.0)))
  .add((typ, (cbx + 3.0, cby + 1.0)))
  .add((typ, (cbx + 5.0, cby + 2.0)))
  .add((typ, (cbx + 6.0, cby + 2.0)))
}

///| (*Generates a cloud block platform with some length num.*)
///
fn generate_clouds(
  cbx : Double,
  cby : Double,
  num : Int
) -> List[(Block, (Double, Double))] {
  if num <= 0 {
    @list.empty()
  } else {
    generate_clouds(cbx + 1.0, cby, num - 1).add((Block::Cloud, (cbx, cby)))
  }
}

///|
pub fn generate_coins(
  block_coord : List[(Block, (Double, Double))]
) -> List[(Item, (Double, Double))] {
  block_coord.filter_map(h => if random(0, 2) == 0 {
    let xc = h.1.0
    let yc = h.1.1
    Some((Coin, (xc, yc - 16.0)))
  } else {
    None
  })
}

///| (*Chooses the form of the blocks to be placed.
///  * When called, leaves a 1 block gap from canvas size.
///  * 1. If current xblock or yblock is greater than canvas width or height
///  *    respectively, return an empty list.
///  * 2. If current xblock or yblock is within 10 blocks of the left and right sides
///  *    of the level map, prevent any objects from being initialized.
///  * 3. Else call helper methods to created block formations and return obj_coord
///  *    list.
/// *)
///
fn choose_block_pattern(
  blockw : Double,
  blockh : Double,
  cbx : Double,
  cby : Double,
  prob : Int
) -> List[(Block, (Double, Double))] {
  if cbx > blockw || cby > blockh {
    @list.empty()
  } else {
    let block_typ = random(0, 4) |> choose_sblock_typ
    let stair_typ = random(0, 2) |> choose_sblock_typ
    let middle_block = if random(0, 5) == 0 {
      Block::QBlock(Mushroom)
    } else {
      stair_typ
    }
    match prob {
      0 =>
        if blockw - cbx > 2.0 {
          @list.empty()
          .add((stair_typ, (cbx, cby)))
          .add((middle_block, (cbx + 1.0, cby)))
          .add((stair_typ, (cbx + 2.0, cby)))
        } else if blockw - cbx > 1.0 {
          @list.empty()
          .add((block_typ, (cbx, cby)))
          .add((block_typ, (cbx + 1.0, cby)))
        } else {
          @list.empty().add((block_typ, (cbx, cby)))
        }
      1 => {
        let num_clouds = random(0, 5) + 5
        if cby < 5.0 {
          generate_clouds(cbx, cby, num_clouds)
        } else {
          @list.empty()
        }
      }
      2 =>
        if blockh - cby == 1.0 {
          generate_ground_stairs(cbx, cby, stair_typ)
        } else {
          @list.empty()
        }
      3 =>
        if stair_typ is Brick && blockh - cby > 3.0 {
          generate_airdown_stairs(cbx, cby, stair_typ)
        } else if blockh - cby > 2.0 {
          generate_airup_stairs(cbx, cby, stair_typ)
        } else {
          @list.empty().add((stair_typ, (cbx, cby)))
        }
      4 =>
        if cby + 3.0 - blockh == 2.0 {
          @list.empty().add((stair_typ, (cbx, cby)))
        } else if cby + 3.0 - blockh == 1.0 {
          @list.empty()
          .add((stair_typ, (cbx, cby)))
          .add((stair_typ, (cbx, cby + 1.0)))
        } else {
          @list.empty()
          .add((stair_typ, (cbx, cby)))
          .add((stair_typ, (cbx, cby + 1.0)))
          .add((stair_typ, (cbx, cby + 2.0)))
        }
      5 => @list.empty().add((Block::QBlock(Mushroom), (cbx, cby)))
      _ => panic()
    }
  }
}

///| (*Generates a list of enemies to be placed on the ground.*)
///
pub fn generate_enemies(
  blockw : Double,
  blockh : Double,
  cbx : Double,
  cby : Double,
  acc : List[(Block, (Double, Double))]
) -> List[(Enemy, (Double, Double))] {
  if cbx > blockw - 32.0 {
    @list.empty()
  } else if cby > blockh - 1.0 || cbx < 15.0 {
    generate_enemies(blockw, blockh, cbx + 1.0, 0.0, acc)
  } else if mem_loc((cbx, cby), acc) || cby == 0.0 {
    generate_enemies(blockw, blockh, cbx, cby + 1.0, acc)
  } else {
    let prob = random(0, 30)
    let enem_prob = 3
    if prob < enem_prob && blockh - 1.0 == cby {
      generate_enemies(blockw, blockh, cbx, cby + 1.0, acc).add(
        (choose_enemy_typ(prob), (cbx * 16.0, cby * 16.0)),
      )
    } else {
      generate_enemies(blockw, blockh, cbx, cby + 1.0, acc)
    }
  }
}

///| (*Generates a list of enemies to be placed upon the block objects.*)
///
pub fn generate_block_enemies(
  block_coord : List[(Block, (Double, Double))]
) -> List[(Enemy, (Double, Double))] {
  block_coord.filter_map(h => if random(0, 20) == 0 {
    let xc = h.1.0
    let yc = h.1.1
    Some((random(0, 3) |> choose_enemy_typ, (xc, yc - 16.0)))
  } else {
    None
  })
}

///| (*Generates an obj_coord list (typ, coordinates) of blocks to be placed.*)
///
pub fn generate_block_locs(
  blockw : Double,
  blockh : Double,
  cbx : Double,
  cby : Double
) -> List[(Block, (Double, Double))] {
  let mut acc = @list.empty()
  for cbx = cbx, cby = cby; cbx <= blockw - 33; {
    if cby > blockh - 1.0 {
      continue cbx + 1.0, 0.0
    } else if mem_loc((cbx, cby), acc) || cby == 0.0 {
      continue cbx, cby + 1.0
    } else {
      let prob = random(0, 100)
      let block_prob = 5
      if prob < block_prob {
        let newacc = choose_block_pattern(blockw, blockh, cbx, cby, prob)
        let undup_lst = avoid_overlap(newacc, acc)
        acc = acc + undup_lst
        continue cbx, cby + 1.0
      } else {
        continue cbx, cby + 1.0
      }
    }
  }
  acc
}

///|
/// Generates the list of brick locations needed to display the ground.
/// 1/10 chance that a ground block is skipped each call to create holes.
///
pub fn generate_ground(
  blockw : Double,
  blockh : Double,
  inc : Double
) -> List[(Block, (Double, Double))] {
  let mut acc = @list.empty()
  for inc = inc; inc <= blockw; inc = inc + 1 {
    if inc > 10 && random(0, 10) == 7 && blockw - inc > 32 {
      continue
    }
    acc = acc + @list.empty().add((Block::Ground, (inc * 16.0, blockh * 16.0)))
  }
  acc
}
