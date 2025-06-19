///|
typealias @list.T as List

///|
let level_width : Double = 2400.0

///|
let level_height : Double = 256.0

///|
let player_count = 2

///|
let temp : (List[Collidable], List[Collidable]) = generate(
  player_count, level_width, level_height,
)

///|
let players : Ref[List[Collidable]] = @ref.new(temp.0)

///|
let objs : List[Collidable] = temp.1

///|
let map_dim : XY = { x: 2400.0, y: 256.0 }

///|
let cwidth = 512.0

///|
let cheight = 256.0

///|
let viewport : Viewport = Viewport::make({ x: cwidth, y: cheight }, map_dim)

///|
let state : St = {
  bgd: make_bgd(),
  vpt: viewport.update(players.val.unsafe_nth(0).get_obj().pos),
  map: map_dim.y,
  score: 0,
  coins: 0,
  multiplier: 1,
  game_over: false,
}

///|
let halt : Ref[Bool] = @ref.new(false)

///|
let lastTime : Ref[Double] = @ref.new(0.0)

///|
let drop_counter : Ref[Double] = @ref.new(0)

///|
let frame_id : Ref[Double] = @ref.new(0)

///|
fn update(time : Double) -> Unit {
  let delta_time = time - lastTime.val
  drop_counter.val += delta_time
  if drop_counter.val > 10 {
    game_update(time)
    drop_counter.val = 0
  }
  lastTime.val = time
  if not(halt.val) {
    frame_id.val = @dom.window().request_animation_frame(update)
  }
}

///|
fn start() -> Unit {
  @dom.window().cancel_animation_frame(frame_id.val)
  state.vpt = viewport.update(players.val.unsafe_nth(0).get_obj().pos)
  state.score = 0
  state.coins = 0
  state.multiplier = 1
  state.game_over = false
  drop_counter.val = 0
  let (players_list, objs_list) = generate(
    player_count, level_width, level_height,
  )
  players.val = players_list
  update_helper(0.0, state, objs_list, @list.empty())
  frame_id.val = @dom.window().request_animation_frame(update)
}

///|
fn main {
  start()
}
