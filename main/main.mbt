let level_width : Double = 2400.0

let level_height : Double = 256.0

let player_count = 2

let players : Ref[@immut/list.List[Collidable]] = @ref.ref(generate_players(player_count))

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

let last : Ref[Int64] = { val: 0L }

let drop_counter : Ref[Int] = { val: 0 }

let drop_interval = 10

fn init {
  @canvas.set_on_key_down(
    fn(event) {
      match event.code() {
        "KeyB" => pressed_keys.bbox = pressed_keys.bbox.lxor(1)
        "ArrowUp" => pressed_keys.up = true
        "KeyW" => pressed_keys.up2 = true
        "ArrowDown" => pressed_keys.down = true
        "KeyS" => pressed_keys.down2 = true
        "ArrowLeft" => pressed_keys.left = true
        "KeyA" => pressed_keys.left2 = true
        "ArrowRight" => pressed_keys.right = true
        "KeyD" => pressed_keys.right2 = true
        "Space" => reset()
        _ => ()
      }
    },
  )
  @canvas.set_on_key_up(
    fn(event) {
      match event.code() {
        "ArrowUp" => pressed_keys.up = false
        "KeyW" => pressed_keys.up2 = false
        "ArrowDown" => pressed_keys.down = false
        "KeyS" => pressed_keys.down2 = false
        "ArrowLeft" => pressed_keys.left = false
        "KeyA" => pressed_keys.left2 = false
        "ArrowRight" => pressed_keys.right = false
        "KeyD" => pressed_keys.right2 = false
        _ => ()
      }
    },
  )
}

fn reset() -> Unit {
  id_counter.val = 0
  players.val = generate_players(player_count)
  let objs : @immut/list.List[Collidable] = generate(level_width, level_height)
  collid_objs.val = objs
  particles.val = @immut/list.List::Nil
  state.vpt = update(viewport, get_obj(players.val.nth_exn(0)).pos)
  state.score = 0
  state.coins = 0
  state.multiplier = 1
  state.game_over = false
}

pub fn entry(canvas : @canvas.Canvas2D, s : Int) -> Unit {
  seed.val = s.to_int64()
  fn update(time : Int64) -> Unit {
    let delta_time = time - last.val
    drop_counter.val += delta_time.to_int()
    if drop_counter.val > drop_interval {
      game_update(canvas, time.to_double())
      drop_counter.val = 0
    }
    last.val = time
    @canvas.request_animation_frame(update) |> ignore
  }

  let objs : @immut/list.List[Collidable] = generate(level_width, level_height)
  update_helper(canvas, 0.0, state, objs, @immut/list.List::Nil)
  @canvas.request_animation_frame(update) |> ignore
}
