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
fn start() -> Unit {
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

///|
fn main {
  canvas
  .to_html_element()
  .to_element()
  .to_node()
  .to_event_target()
  .add_event_listener("keydown", fn(event) {
    match event.to_ui_event().unwrap().to_keyboard_event().unwrap().code() {
      "Space" => {
        halt.val = false
        start()
      }
      "KeyB" => pressed_keys.bbox = pressed_keys.bbox ^ 1
      "ArrowUp" => pressed_keys.up = true
      "ArrowDown" => pressed_keys.down = true
      "ArrowLeft" => pressed_keys.left = true
      "ArrowRight" => pressed_keys.right = true
      "KeyW" => pressed_keys.up2 = true
      "KeyS" => pressed_keys.down2 = true
      "KeyA" => pressed_keys.left2 = true
      "KeyD" => pressed_keys.right2 = true
      _ => ()
    }
  })
  canvas
  .to_html_element()
  .to_element()
  .to_node()
  .to_event_target()
  .add_event_listener("keyup", fn(event) {
    match event.to_ui_event().unwrap().to_keyboard_event().unwrap().code() {
      "KeyB" => pressed_keys.bbox = pressed_keys.bbox ^ 1
      "ArrowUp" => pressed_keys.up = false
      "ArrowDown" => pressed_keys.down = false
      "ArrowLeft" => pressed_keys.left = false
      "ArrowRight" => pressed_keys.right = false
      "KeyW" => pressed_keys.up2 = false
      "KeyS" => pressed_keys.down2 = false
      "KeyA" => pressed_keys.left2 = false
      "KeyD" => pressed_keys.right2 = false
      _ => ()
    }
  })
  start()
}
