///| (*Converts list of locations from blocksize to pixelsize by multiplying (x,y) by
///  * 16.*)
///
fn convert_list(
  list : List[(Int, (Double, Double))]
) -> List[(Int, (Double, Double))] {
  list.map(fn(x) { (x.0, (x.1.0 * 16.0, x.1.1 * 16.0)) })
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

///| (*Generates the ending item panel at the end of the level. Games ends upon
///  * collision with player.*)
///
fn generate_panel(blockw : Double, blockh : Double) -> Collidable {
  spawn(Block(Panel), blockw * 16.0 - 256.0, blockh * 16.0 * 2.0 / 3.0)
}

///| (*Converts the obj_coord list called by generate_block_locs to a list of objects
///  * with the coordinates given from the obj_coord list. *)
///
fn convert_to_block_obj(
  lst : List[(Int, (Double, Double))]
) -> List[Collidable] {
  match lst {
    Empty => @list.empty()
    More(h, tail=t) => {
      let sblock_typ = choose_sblock_typ(h.0)
      let ob = spawn(Block(sblock_typ), h.1.0, h.1.1)
      @list.empty().add(ob) + convert_to_block_obj(t)
    }
  }
}

///| (*Converts the obj_coord list called by generate_enemies to a list of objects
///  * with the coordinates given from the obj_coord list. *)
///
fn convert_to_enemy_obj(
  lst : List[(Int, (Double, Double))]
) -> List[Collidable] {
  match lst {
    Empty => @list.empty()
    More(h, tail=t) => {
      let senemy_typ = choose_enemy_typ(h.0)
      let ob = spawn(Enemy(senemy_typ), h.1.0, h.1.1)
      @list.empty().add(ob) + convert_to_enemy_obj(t)
    }
  }
}

///| (*Converts the list of coordinates into a list of Coin objects*)
///
fn convert_to_coin_obj(lst : List[(Int, (Double, Double))]) -> List[Collidable] {
  match lst {
    Empty => @list.empty()
    More(h, tail=t) => {
      let sitem_typ = Item::Coin
      let ob = spawn(Item(sitem_typ), h.1.0, h.1.1)
      @list.empty().add(ob) + convert_to_coin_obj(t)
    }
  }
}

///| (*Procedurally generates a list of collidables given canvas width, height and
///  * context. Arguments block width (blockw) and block height (blockh) are in
///  * block form, not pixels.*)
///
fn generate_helper(blockw : Double, blockh : Double) -> List[Collidable] {
  let block_locs = generate_block_locs(blockw, blockh, 0.0, 0.0)
  let converted_block_locs = trim_edges(
    convert_list(block_locs),
    blockw,
    blockh,
  )
  let obj_converted_block_locs = convert_to_block_obj(converted_block_locs)
  let ground_blocks = generate_ground(blockw, blockh, 0.0)
  let obj_converted_ground_blocks = convert_to_block_obj(ground_blocks)
  let block_locations = block_locs + ground_blocks
  let all_blocks = obj_converted_block_locs + obj_converted_ground_blocks
  let enemy_locs = generate_enemies(
    blockw,
    blockh,
    0.0,
    0.0,
    acc=block_locations,
  )
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
  all_blocks +
  obj_converted_enemies +
  coin_objects +
  obj_enemy_blocks +
  @list.empty().add(obj_panel)
}

///| (*Main function called to procedurally generate the level map. w and h args
///  * are in pixel form. Converts to block form to call generate_helper. Spawns
///  * the list of collidables received from generate_helper to display on canvas.*)
///
fn generate(
  player_count : Int,
  w : Double,
  h : Double
) -> (@list.T[Collidable], @list.T[Collidable]) {
  let blockw = w / 16.0
  let blockh = h / 16.0 - 1.0
  let collide_list = generate_helper(blockw, blockh)
  let mut start = 50.0
  let players = Array::make(player_count, Spawn::Player(Small, Standing)).map(fn(
      s
    ) {
      let c = spawn(s, start, 0.0)
      start = start - 30.0
      c
    })
    |> @list.from_array
  (players, collide_list)
}
