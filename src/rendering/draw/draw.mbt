///|
const WIDTH = 512.0

///|
const HEIGHT = 256.0

///|
pub fn game_win() -> Unit {
  context.set_fill_style(@js.Union3::from0("black"))
  context.fill_rect(0, 0, WIDTH, HEIGHT)
  context.set_fill_style(@js.Union3::from0("white"))
  context.set_font("20px 'Press Start 2P'")
  context.fill_text("You win!", 180, 128)
}

///|
pub fn game_lose() -> Unit {
  context.set_fill_style(@js.Union3::from0("black"))
  context.fill_rect(0, 0, WIDTH, HEIGHT)
  context.set_fill_style(@js.Union3::from0("white"))
  context.set_font("20px 'Press Start 2P'")
  context.fill_text("GAME OVER. You lose!", 60, 128)
}

///|
fn render_(
  img : Image,
  sx : Double,
  sy : Double,
  sw : Double,
  sh : Double,
  dx : Double,
  dy : Double,
  dw : Double,
  dh : Double
) -> Unit {
  context.draw_image_with_src_and_dst_size(
    img |> @js.Value::cast_from |> @js.Value::cast,
    sx,
    sy,
    sw,
    sh,
    dx,
    dy,
    dw,
    dh,
  )
}

///|
fn render_box_(a : Double, b : Double, c : Double, d : Double) -> Unit {
  context.set_stroke_style(@js.Union3::from0("#FF0000"))
  context.stroke_rect(a, b, c, d)
}

///|
pub fn render_box(sprite : Sprite, posx : Double, posy : Double) -> Unit {
  let (bbox, bboy) = sprite.params.bbox_offset
  let (bbsx, bbsy) = sprite.params.bbox_size
  render_box_(posx + bbox, posy + bboy, bbsx, bbsy)
}

///|
pub fn render(sprite : Sprite, posx : Double, posy : Double) -> Unit {
  let (sx, sy) = sprite.params.src_offset
  let (sw, sh) = sprite.params.frame_size
  let (dx, dy) = (posx, posy)
  let (dw, dh) = sprite.params.frame_size
  let sx = sx + sprite.frame.to_double() * sw
  render_(sprite.img, sx, sy, sw, sh, dx, dy, dw, dh)
}

// (*Draws two background images, which needs to be done because of the
// *constantly changing viewport, which is always at most going to be
// *between two background images.*)

///|
pub fn draw_bgd(bgd : Sprite, off_x : Double) -> Unit {
  render(bgd, -off_x, 0.0)
  render(bgd, bgd.params.frame_size.0 - off_x, 0.0)
}

///|
pub let canvas : @dom.HTMLCanvasElement = @dom.document().get_element_by_id(
    "canvas",
  )
  |> @js.Value::cast_from
  |> @js.Value::cast

///|
let context : @dom.CanvasRenderingContext2D = canvas.get_context("2d")
  |> @js.Value::cast_from
  |> @js.Value::cast

///|
pub fn clear_canvas() -> Unit {
  context.clear_rect(0.0, 0.0, WIDTH, HEIGHT)
}

///|
pub fn hud(score : Int, coins : Int) -> Unit {
  context.set_fill_style(@js.Union3::from0("black"))
  context.set_font("10px 'Press Start 2P'")
  context.fill_text("Score: \{score}", WIDTH - 140, 18)
  context.fill_text("Coins: \{coins}", 120, 18)
}

///|
pub fn fps(fps_val : Int) -> Unit {
  context.set_fill_style(@js.Union3::from0("black"))
  context.set_font("10px 'Press Start 2P'")
  context.fill_text("FPS: \{fps_val}", 10, 18)
}
