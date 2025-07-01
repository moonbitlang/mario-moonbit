///|
const WIDTH = 512.0

///|
const HEIGHT = 256.0

///|
let map_dim : XY = { x: 2400.0, y: 256.0 }

///|
let viewport : Viewport = Viewport::make({ x: WIDTH, y: HEIGHT }, map_dim)

///|
pub struct St {
  bgd : Sprite
  mut vpt : Viewport
  map : Double
  mut score : Int
  mut coins : Int
  mut multiplier : Int
  mut game_over : Bool
}

///|
/// (* Adds [i] to the score in [state] *)
pub fn St::increase_score(state : St, i : Int) -> Unit {
  state.score = state.score + i
}

///|
pub fn St::new() -> St {
  {
    bgd: make_bgd(),
    vpt: viewport,
    map: map_dim.y,
    score: 0,
    coins: 0,
    multiplier: 1,
    game_over: false,
  }
}

///|
pub fn St::reset(self : St, xy : XY) -> Unit {
  self.vpt = viewport.update(xy)
  self.score = 0
  self.coins = 0
  self.multiplier = 1
  self.game_over = false
}

///|
pub fn St::reset_multiplier(self : St) -> Unit {
  self.multiplier = 1
}

///|
pub fn St::double_multiplier(self : St) -> Unit {
  self.multiplier = self.multiplier * 2
}

///|
pub fn St::game_over(self : St) -> Unit {
  self.game_over = true
}

///|
pub fn St::update_viewport(self : St, xy : XY) -> Unit {
  self.vpt = self.vpt.update(xy)
}

///|
pub fn St::increase_coin(self : St) -> Unit {
  self.coins = self.coins + 1
}
