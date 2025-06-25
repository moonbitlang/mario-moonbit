///|
typealias @actors.(Enemy, Item, PlayerSize, Spawn, Block)

///|
typealias @sprite.(Sprite, SpriteParams, Particle)

///|
typealias @utils.XY

///|
typealias @viewport.Viewport

///|
typealias @list.T as List

///|
fnalias @draw.(
  game_lose,
  game_win,
  render,
  clear_canvas,
  hud,
  fps,
  render_box,
  draw_bgd
)

///|
fnalias @sprite.make_bgd

///|
fnalias @generator.(
  generate_enemies,
  generate_coins,
  generate_block_enemies,
  generate_block_locs,
  generate_ground,
  trim_edges,
  avoid_overlap
)

///|
let canvas = @draw.canvas
