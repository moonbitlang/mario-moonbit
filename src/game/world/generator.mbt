///| (*Converts list of locations from blocksize to pixelsize by multiplying (x,y) by
///  * 16.*)
///
fn[T] convert_list(list : List[(T, (Int, Int))]) -> List[(T, (Double, Double))] {
  list.map(fn(x) { (x.0, (x.1.0.to_double() * 16.0, x.1.1.to_double() * 16.0)) })
}

///| (*Generates the ending item panel at the end of the level. Games ends upon
///  * collision with player.*)
///
fn generate_panel(blockw : Int, blockh : Int) -> Collidable {
  spawn(
    Block(Panel),
    blockw.to_double() * 16.0 - 256.0,
    blockh.to_double() * 16.0 * 2.0 / 3.0,
  )
}

///| (*Converts the obj_coord list called by generate_block_locs to a list of objects
///  * with the coordinates given from the obj_coord list. *)
///
fn convert_to_block_obj(
  lst : List[(Block, (Double, Double))]
) -> List[Collidable] {
  lst.map(h => spawn(Block(h.0), h.1.0, h.1.1))
}

///| (*Converts the obj_coord list called by generate_enemies to a list of objects
///  * with the coordinates given from the obj_coord list. *)
///
fn convert_to_enemy_obj(
  lst : List[(Enemy, (Double, Double))]
) -> List[Collidable] {
  lst.map(h => spawn(Enemy(h.0), h.1.0, h.1.1))
}

///| (*Converts the list of coordinates into a list of Coin objects*)
///
fn convert_to_coin_obj(
  lst : List[(Item, (Double, Double))]
) -> List[Collidable] {
  lst.map(h => spawn(Item(h.0), h.1.0, h.1.1))
}

///| (*Procedurally generates a list of collidables given canvas width, height and
///  * context. Arguments block width (blockw) and block height (blockh) are in
///  * block form, not pixels.*)
///
fn generate_helper(blockw : Int, blockh : Int) -> List[Collidable] {
  // blocks
  let block_locs = generate_block_locs(blockw, blockh, 0, 0)
  let converted_block_locs = block_locs |> trim_edges(blockw, blockh)
  let obj_converted_block_locs = converted_block_locs
    |> convert_list()
    |> convert_to_block_obj()

  // ground
  let ground_blocks = generate_ground(blockw, blockh, 0)
  let obj_converted_ground_blocks = ground_blocks
    |> convert_list()
    |> convert_to_block_obj()
  let block_locations = block_locs + ground_blocks

  // enemies
  let obj_converted_enemies = generate_enemies(
      blockw, blockh, 0, 0, block_locations,
    )
    |> convert_list()
    |> convert_to_enemy_obj()

  // coins
  let coin_locs = generate_coins(converted_block_locs)
  let coin_objects = coin_locs
    |> avoid_overlap(converted_block_locs)
    |> trim_edges(blockw, blockh)
    |> convert_list()
    |> convert_to_coin_obj()

  // enemies on blocks
  let obj_enemy_blocks = converted_block_locs
    |> generate_block_enemies
    |> avoid_overlap(converted_block_locs)
    |> avoid_overlap(coin_locs)
    |> convert_list()
    |> convert_to_enemy_obj()

  // panel
  let obj_panel = generate_panel(blockw, blockh)
  obj_converted_block_locs +
  obj_converted_ground_blocks +
  obj_converted_enemies +
  coin_objects +
  obj_enemy_blocks +
  @list.empty().add(obj_panel)
}

///| (*Main function called to procedurally generate the level map. w and h args
///  * are in pixel form. Converts to block form to call generate_helper. Spawns
///  * the list of collidables received from generate_helper to display on canvas.*)
///
pub fn generate(
  player_count : Int,
  w : Double,
  h : Double
) -> (@list.T[Collidable], @list.T[Collidable]) {
  let blockw = (w / 16.0).to_int()
  let blockh = (h / 16.0 - 1.0).to_int()
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
