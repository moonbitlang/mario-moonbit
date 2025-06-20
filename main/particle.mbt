///|
struct ParticleParams {
  sprite : Sprite
  lifetime : Int
}

///|
struct Particle {
  params : ParticleParams
  pos : XY
  vel : XY
  acc : XY
  mut kill : Bool
  mut life : Int
}

///|
fn XY::make(x : Double, y : Double) -> XY {
  { x, y }
}

///|
fn make_params(sprite_params : SpriteParams, lifetime : Int) -> ParticleParams {
  { sprite: Sprite::make_(sprite_params), lifetime }
}

///|
fn ParticleParams::with_type(part : Part) -> ParticleParams {
  match part {
    BrickChunkL => make_params(make_particle(part), 300)
    BrickChunkR => make_params(make_particle(part), 300)
    _ => make_params(make_particle(part), 30)
  }
}

///|
fn Particle::make(vel : XY, acc : XY, part : Part, pos : XY) -> Particle {
  let params = ParticleParams::with_type(part)
  { params, pos, vel, acc, kill: false, life: params.lifetime }
}

///|
fn make_score(score : Int, pos : XY) -> Particle {
  let t = match score {
    100 => Part::Score100
    200 => Score200
    400 => Score400
    800 => Score800
    1000 => Score1000
    2000 => Score2000
    4000 => Score4000
    8000 => Score8000
    _ => Score100
  }
  Particle::make({ x: 0.5, y: -0.7 }, { x: 0.0, y: 0.0 }, t, {
    x: pos.x,
    y: pos.y,
  })
}

///|
fn Particle::update_vel(self : Particle) -> Unit {
  self.vel.x += self.acc.x
  self.vel.y += self.acc.y
}

///|
fn Particle::update_pos(self : Particle) -> Unit {
  self.pos.x += self.vel.x
  self.pos.y += self.vel.y
}

///|
fn Particle::process(self : Particle) -> Unit {
  self.life = self.life - 1
  if self.life == 0 {
    self.kill = true
  }
  self.update_vel()
  self.update_pos()
}
