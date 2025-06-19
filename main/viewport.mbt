///|
struct Viewport {
  pos : XY
  v_dim : XY
  m_dim : XY
}

///|
fn Viewport::make(v : XY, m : XY) -> Viewport {
  {
    pos: { x: 0.0, y: 0.0 },
    v_dim: { x: v.x, y: v.y },
    m_dim: { x: m.x, y: m.y },
  }
}

///|
fn calc_viewport_point(cc : Double, vc : Double, mc : Double) -> Double {
  let vc_half = vc / 2.0
  @math.minimum(
    @math.maximum(cc - vc_half, 0.0),
    @math.minimum(mc - vc, @double.abs(cc - vc_half)),
  )
}

// (* Returns whether a coordinate pair [pos] is inside the viewport [v] *)
///|
fn Viewport::in_viewport(v : Viewport, pos : XY) -> Bool {
  let margin = 32.0
  let (v_min_x, v_max_x) = (v.pos.x - margin, v.pos.x + v.v_dim.x)
  let (v_min_y, v_max_y) = (v.pos.y - margin, v.pos.y + v.v_dim.y)
  let (x, y) = (pos.x, pos.y)
  x >= v_min_x && x <= v_max_x && y >= v_min_y && y <= v_max_y
}

// (* Returns whether an object is outside of the viewport and below it. This is
// * useful for determining whether to process falling out of screen normally. *)
///|
fn Viewport::out_of_viewport_below(v : Viewport, y : Double) -> Bool {
  let v_max_y = v.pos.y + v.v_dim.y
  y >= v_max_y
}

// (* Converts a x,y [coord] pair in absolute coordinates to coordinates relative
// * to the viewport *)
///|
fn Viewport::coord_to_viewport(viewport : Viewport, coord : XY) -> XY {
  { x: coord.x - viewport.pos.x, y: coord.y - viewport.pos.y }
}

// (* Update the viewport [vpt] given the new center x,y coordinate pair [ctr] *)
///|
fn Viewport::update(vpt : Viewport, ctr : XY) -> Viewport {
  let new_x = calc_viewport_point(ctr.x, vpt.v_dim.x, vpt.m_dim.x)
  let new_y = calc_viewport_point(ctr.y, vpt.v_dim.y, vpt.m_dim.y)
  let pos = { x: new_x, y: new_y }
  { pos, v_dim: vpt.v_dim, m_dim: vpt.m_dim }
}
