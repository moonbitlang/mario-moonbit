///|
pub(all) enum Dir1d {
  Left
  Right
} derive(Eq)

///|
pub fn opposite_dir(self : Dir1d) -> Dir1d {
  match self {
    Left => Right
    Right => Left
  }
}

///|
pub(all) enum Dir2d {
  North
  South
  East
  West
}

///|
pub(all) struct XY {
  mut x : Double
  mut y : Double
}

///|
pub fn XY::make(x : Double, y : Double) -> XY {
  { x, y }
}

///|
pub(all) enum Control {
  Left
  Right
  Up
  Down
}
