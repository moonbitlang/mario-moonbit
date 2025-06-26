///|
typealias @actors.Enemy

///|
typealias @sprite.(Sprite, Particle)

///|
typealias @utils.(XY, Dir2d)

///|
typealias @viewport.Viewport

///|
typealias @object.(Collidable, Control, Object)

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
fnalias @generator.generate

///|
fnalias @object.(
  evolve_enemy,
  dec_health,
  rev_dir,
  check_collision,
  process_obj,
  update_player,
  kill,
  reverse_left_right,
  evolve_block,
  spawn_above,
  collide_block
)

///|
let canvas = @draw.canvas
