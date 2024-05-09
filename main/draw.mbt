let width = 512.0

let height = 256.0

let backg_ : @canvas.HTMLImageElement = {
  let image = @canvas.HTMLImageElement::make()
  image.set_src("images/background.png")
  image
}

let block_ : @canvas.HTMLImageElement = {
  let image = @canvas.HTMLImageElement::make()
  image.set_src("images/blocks.png")
  image
}

let items_ : @canvas.HTMLImageElement = {
  let image = @canvas.HTMLImageElement::make()
  image.set_src("images/items.png")
  image
}

let enemy_ : @canvas.HTMLImageElement = {
  let image = @canvas.HTMLImageElement::make()
  image.set_src("images/enemies.png")
  image
}

let small_ : @canvas.HTMLImageElement = {
  let image = @canvas.HTMLImageElement::make()
  image.set_src("images/mario-small.png")
  image
}

let large_ : @canvas.HTMLImageElement = {
  let image = @canvas.HTMLImageElement::make()
  image.set_src("images/mario-large.png")
  image
}

let panel_ : @canvas.HTMLImageElement = {
  let image = @canvas.HTMLImageElement::make()
  image.set_src("images/panel.png")
  image
}

let ground : @canvas.HTMLImageElement = {
  let image = @canvas.HTMLImageElement::make()
  image.set_src("images/ground.png")
  image
}

let chunk_ : @canvas.HTMLImageElement = {
  let image = @canvas.HTMLImageElement::make()
  image.set_src("images/chunks.png")
  image
}

let score_ : @canvas.HTMLImageElement = {
  let image = @canvas.HTMLImageElement::make()
  image.set_src("images/score.png")
  image
}

fn game_win(canvas2d : @canvas.Canvas2D) -> Unit {
  canvas2d.set_fill_style(Color("black"))
  canvas2d.fill_rect(0.0, 0.0, width, height)
  canvas2d.set_fill_style(Color("white"))
  canvas2d.set_font("20px 'Press Start 2P'")
  canvas2d.fill_text("You win!", 180.0, 128.0)
}

fn game_lose(canvas2d : @canvas.Canvas2D) -> Unit {
  canvas2d.set_fill_style(Color("black"))
  canvas2d.fill_rect(0.0, 0.0, width, height)
  canvas2d.set_fill_style(Color("white"))
  canvas2d.set_font("20px 'Press Start 2P'")
  canvas2d.fill_text("GAME OVER. You lose!", 60.0, 128.0)
}

fn random(l : Int, r : Int) -> Int = "canvas" "random"

fn render_box(
  canvas2d : @canvas.Canvas2D,
  sprite : Sprite,
  posx : Double,
  posy : Double
) -> Unit {
  let (bbox, bboy) = sprite.params.bbox_offset
  let (bbsx, bbsy) = sprite.params.bbox_size
  canvas2d.set_stroke_style(Color("#FF0000"))
  canvas2d.stroke_rect(posx + bbox, posy + bboy, bbsx, bbsy)
}

fn render(
  canvas2d : @canvas.Canvas2D,
  sprite : Sprite,
  posx : Double,
  posy : Double
) -> Unit {
  let (sx, sy) = sprite.params.src_offset
  let (sw, sh) = sprite.params.frame_size
  let (dx, dy) = (posx, posy)
  let (dw, dh) = sprite.params.frame_size
  let sx = sx + sprite.frame.val.to_double() * sw
  canvas2d.draw_image_subpart_with_dimention(
    HTMLImageElement(sprite.img),
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

// (*Draws two background images, which needs to be done because of the
// *constantly changing viewport, which is always at most going to be
// *between two background images.*)
fn draw_bgd(canvas2d : @canvas.Canvas2D, bgd : Sprite, off_x : Double) -> Unit {
  render(canvas2d, bgd, -off_x, 0.0)
  render(canvas2d, bgd, bgd.params.frame_size.0 - off_x, 0.0)
}

fn clear_canvas(canvas2d : @canvas.Canvas2D) -> Unit {
  canvas2d.clear_rect(0.0, 0.0, width, height)
}

fn hud(canvas2d : @canvas.Canvas2D, score : Int, coins : Int) -> Unit {
  canvas2d.set_font("10px 'Press Start 2P'")
  canvas2d.fill_text("Score: \(score)", width - 140.0, 18.0)
  canvas2d.fill_text("Coins: \(coins)", 120.0, 18.0)
}

fn fps(canvas2d : @canvas.Canvas2D, fps : Int) -> Unit {
  canvas2d.set_font("10px 'Press Start 2P'")
  canvas2d.fill_text(fps.to_string(), 10.0, 18.0)
}
