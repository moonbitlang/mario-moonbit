let level_width : Double = 2400.0

let level_height : Double = 256.0

let player_count = 2

let temp : (List[Collidable], List[Collidable]) = generate(
  player_count, level_width, level_height,
)

let players : Ref[List[Collidable]] = @ref.ref(temp.0)

let objs : List[Collidable] = temp.1

let map_dim : XY = { x: 2400.0, y: 256.0 }

let cwidth = 512.0

let cheight = 256.0

let viewport : Viewport = Viewport::make({ x: cwidth, y: cheight }, map_dim)

let state : St = {
  bgd: make_bgd(),
  vpt: update(viewport, get_obj(players.val.nth_exn(0)).pos),
  map: map_dim.y,
  score: 0,
  coins: 0,
  multiplier: 1,
  game_over: false,
}

fn init {
  update_helper(0.0, state, objs, List::Nil)
}
