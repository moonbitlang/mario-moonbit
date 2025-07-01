///|
let dampen_jump : Double = 4.0

///|
let invuln : Int = 60

///|
let level_width : Double = 2400.0

///|
let level_height : Double = 256.0

///|
let player_count = 2

///|
let players : Ref[List[Collidable]] = @ref.new(@list.empty())

///|
let state : St = St::new()

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
pub fn start() -> Unit {
  @dom.window().cancel_animation_frame(frame_id.val)
  let (players_list, objs_list) = generate(
    player_count, level_width, level_height,
  )
  players.val = players_list
  state.reset(players.val.unsafe_nth(0).object.pos)
  drop_counter.val = 0
  update_helper(0.0, state, objs_list, @list.empty())
  frame_id.val = @dom.window().request_animation_frame(update)
}
