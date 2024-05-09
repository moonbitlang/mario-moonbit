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

pub fn start(canvas : @canvas.Canvas2D) -> Unit {
  update_helper(canvas, 0.0, state, objs, List::Nil)
}
