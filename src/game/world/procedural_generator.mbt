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
fn mem_loc(
  checkloc : (Double, Double),
  loclist : List[(Int, (Double, Double))]
) -> Bool {
  loclist.any(h => checkloc == h.1)
}

///| (*Optimizes lst such that there are no two items in the list that have the same
///  * coordinates. If there is one, it is removed.*)
///
pub fn avoid_overlap(
  lst : List[(Int, (Double, Double))],
  currentLst : List[(Int, (Double, Double))]
) -> List[(Int, (Double, Double))] {
  lst.filter(h => not(mem_loc(h.1, currentLst)))
}

///| (*Gets rid of objects with coordinates in the ending frame, within 128 pixels of
///  * the start, at the very top, and two blocks from the ground.*)
///
pub fn trim_edges(
  lst : List[(Int, (Double, Double))],
  blockw : Double,
  blockh : Double
) -> List[(Int, (Double, Double))] {
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
  typ : Int
) -> List[(Int, (Double, Double))] {
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
  typ : Int
) -> List[(Int, (Double, Double))] {
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
  typ : Int
) -> List[(Int, (Double, Double))] {
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
  typ : Int,
  num : Int
) -> List[(Int, (Double, Double))] {
  if num <= 0 {
    @list.empty()
  } else {
    generate_clouds(cbx + 1.0, cby, typ, num - 1).add((typ, (cbx, cby)))
  }
}

///|
pub fn generate_coins(
  block_coord : List[(Int, (Double, Double))]
) -> List[(Int, (Double, Double))] {
  // (* let place_coin = Random.int 2 in *)
  let place_coin = random(0, 2)
  match block_coord {
    Empty => @list.empty()
    More(h, tail=t) =>
      if place_coin == 0 {
        let xc = h.1.0
        let yc = h.1.1
        @list.empty().add((0, (xc, yc - 16.0))) + generate_coins(t)
      } else {
        generate_coins(t)
      }
  }
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
) -> List[(Int, (Double, Double))] {
  if cbx > blockw || cby > blockh {
    @list.empty()
  } else {
    let block_typ = random(0, 4)
    let stair_typ = random(0, 2)
    let life_block_chance = random(0, 5)
    let middle_block = if life_block_chance == 0 { 3 } else { stair_typ }
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
          generate_clouds(cbx, cby, 2, num_clouds)
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
        if stair_typ == 0 && blockh - cby > 3.0 {
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
      5 => @list.empty().add((3, (cbx, cby)))
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
  acc~ : List[(Int, (Double, Double))] = @list.empty()
) -> List[(Int, (Double, Double))] {
  if cbx > blockw - 32.0 {
    @list.empty()
  } else if cby > blockh - 1.0 || cbx < 15.0 {
    generate_enemies(blockw, blockh, cbx + 1.0, 0.0, acc~)
  } else if mem_loc((cbx, cby), acc) || cby == 0.0 {
    generate_enemies(blockw, blockh, cbx, cby + 1.0, acc~)
  } else {
    let prob = random(0, 30)
    let enem_prob = 3
    if prob < enem_prob && blockh - 1.0 == cby {
      generate_enemies(blockw, blockh, cbx, cby + 1.0, acc~).add(
        (prob, (cbx * 16.0, cby * 16.0)),
      )
    } else {
      generate_enemies(blockw, blockh, cbx, cby + 1.0, acc~)
    }
  }
}

///| (*Generates a list of enemies to be placed upon the block objects.*)
///
pub fn generate_block_enemies(
  block_coord : List[(Int, (Double, Double))]
) -> List[(Int, (Double, Double))] {
  let place_enemy = random(0, 20)
  let enemy_typ = random(0, 3)
  match block_coord {
    Empty => @list.empty()
    More(h, tail=t) =>
      if place_enemy == 0 {
        let xc = h.1.0
        let yc = h.1.1
        @list.empty().add((enemy_typ, (xc, yc - 16.0))) +
        generate_block_enemies(t)
      } else {
        generate_block_enemies(t)
      }
  }
}

///| (*Generates an obj_coord list (typ, coordinates) of blocks to be placed.*)
///
pub fn generate_block_locs(
  blockw : Double,
  blockh : Double,
  cbx : Double,
  cby : Double
) -> List[(Int, (Double, Double))] {
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
) -> List[(Int, (Double, Double))] {
  let mut acc = @list.empty()
  for inc = inc; inc <= blockw; inc = inc + 1 {
    if inc > 10 && random(0, 10) == 7 && blockw - inc > 32 {
      continue
    }
    acc = acc + @list.empty().add((4, (inc * 16.0, blockh * 16.0)))
  }
  acc
}
