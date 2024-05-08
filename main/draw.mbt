type Image

fn get_backg() -> Image = "canvas" "get_backg"

fn get_block() -> Image = "canvas" "get_block"

fn get_items() -> Image = "canvas" "get_items"

fn get_enemy() -> Image = "canvas" "get_enemy"

fn get_small() -> Image = "canvas" "get_small"

fn get_large() -> Image = "canvas" "get_large"

fn get_panel() -> Image = "canvas" "get_panel"

fn get_round() -> Image = "canvas" "get_round"

fn get_chunk() -> Image = "canvas" "get_chunk"

fn get_score() -> Image = "canvas" "get_score"

let backg_ : Image = get_backg()

let block_ : Image = get_block()

let items_ : Image = get_items()

let enemy_ : Image = get_enemy()

let small_ : Image = get_small()

let large_ : Image = get_large()

let panel_ : Image = get_panel()

let ground : Image = get_round()

let chunk_ : Image = get_chunk()

let score_ : Image = get_score()

fn game_win() = "canvas" "game_win"

fn game_lose() = "canvas" "game_lose"

fn random(l : Int, r : Int) -> Int = "canvas" "random"

fn render_(img : Image, sx : Double, sy : Double, sw : Double, sh : Double,
        dx : Double, dy : Double, dw : Double, dh : Double) = "canvas" "render"

fn render_box_(a : Double, b : Double, c : Double, d : Double) = "canvas" "render_box"

fn render_box(sprite : Sprite, posx : Double, posy : Double) -> Unit {
  let (bbox, bboy) = sprite.params.bbox_offset
  let (bbsx, bbsy) = sprite.params.bbox_size
  render_box_(posx + bbox, posy + bboy, bbsx, bbsy)
}

fn render(sprite : Sprite, posx : Double, posy : Double) -> Unit {
  let (sx, sy) = sprite.params.src_offset
  let (sw, sh) = sprite.params.frame_size
  let (dx, dy) = (posx, posy)
  let (dw, dh) = sprite.params.frame_size
  let sx = sx + sprite.frame.val.to_double() * sw
  render_(sprite.img, sx, sy, sw, sh, dx, dy, dw, dh)
}

// (*Draws two background images, which needs to be done because of the
// *constantly changing viewport, which is always at most going to be
// *between two background images.*)
fn draw_bgd(bgd : Sprite, off_x : Double) -> Unit {
  render(bgd, -off_x, 0.0)
  render(bgd, bgd.params.frame_size.0 - off_x, 0.0)
}

fn clear_canvas() = "canvas" "clear"

fn hud(score : Int, coins : Int) = "canvas" "draw_hud"

fn fps(fps_val : Int) = "canvas" "draw_fps"
