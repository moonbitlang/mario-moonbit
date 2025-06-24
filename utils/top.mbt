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
