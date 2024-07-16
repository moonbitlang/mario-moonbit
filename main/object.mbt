let friction : Double = 0.9

let gravity : Double = 0.2

let max_y_vel : Double = 4.5

let player_speed : Double = 2.8

let player_jump : Double = 5.7

let player_max_jump : Double = -6.0

let dampen_jump : Double = 4.0

let invuln : Int = 60

struct AABB {
  center : XY
  half : XY
}

struct ObjectParams {
  has_gravity : Bool
  speed : Double
}

let id_counter : Ref[Int] = @ref.new(0)

struct Object {
  params : ObjectParams
  pos : XY
  vel : XY
  id : Int
  mut jumping : Bool
  mut grounded : Bool
  mut dir : Dir1d
  mut invuln : Int
  mut kill : Bool
  mut health : Int
  mut crouch : Bool
  mut score : Int
}

enum Collidable {
  Player(PlayerSize, Sprite, Object)
  Enemy(Enemy, Sprite, Object)
  Item(Item, Sprite, Object)
  Block(Block, Sprite, Object)
}

fn setup_objp2(has_gravity : Bool, speed : Double) -> ObjectParams {
  { has_gravity, speed }
}

fn setup_objp() -> ObjectParams {
  setup_objp2(true, 1.0)
}

fn set_vel_to_speed(self : Object) -> Unit {
  let speed = self.params.speed
  match self.dir {
    Left => self.vel.x = -speed
    Right => self.vel.x = speed
  }
}

fn makeplayer() -> ObjectParams {
  setup_objp2(true, player_speed)
}

fn makeitem(item : Item) -> ObjectParams {
  match item {
    Mushroom => setup_objp()
    Coin => setup_objp2(false, 1.0)
  }
}

fn makeenemy(enemy : Enemy) -> ObjectParams {
  match enemy {
    Goomba => setup_objp()
    GKoopa => setup_objp()
    RKoopa => setup_objp()
    GKoopaShell => setup_objp2(true, 3.0)
    RKoopaShell => setup_objp2(true, 3.0)
  }
}

fn makeblock() -> ObjectParams {
  setup_objp2(false, 1.0)
}

fn make_type(spawn : Spawn) -> ObjectParams {
  match spawn {
    Player(_) => makeplayer()
    Enemy(t) => makeenemy(t)
    Item(t) => makeitem(t)
    Block(_) => makeblock()
  }
}

fn new_id() -> Int {
  id_counter.val += 1
  id_counter.val
}

fn makeobj(
  id : Int,
  dir : Dir1d,
  spawn : Spawn,
  posx : Double,
  posy : Double
) -> (Sprite, Object) {
  let spr = Sprite::make(spawn, dir)
  let params = make_type(spawn)
  let obj : Object = {
    params,
    pos: { x: posx, y: posy },
    vel: { x: 0.0, y: 0.0 },
    id,
    jumping: false,
    grounded: false,
    dir,
    invuln: 0,
    kill: false,
    health: 1,
    crouch: false,
    score: 0,
  }
  (spr, obj)
}

fn spawn(spawnable : Spawn, posx : Double, posy : Double) -> Collidable {
  let (spr, obj) = makeobj(new_id(), Left, spawnable, posx, posy)
  match spawnable {
    Player(typ, _) => Player(typ, spr, obj)
    Enemy(t) => {
      set_vel_to_speed(obj)
      Enemy(t, spr, obj)
    }
    Item(t) => Item(t, spr, obj)
    Block(t) => Block(t, spr, obj)
  }
}

fn get_sprite(self : Collidable) -> Sprite {
  match self {
    Player(_, s, _) | Enemy(_, s, _) | Item(_, s, _) | Block(_, s, _) => s
  }
}

fn get_obj(self : Collidable) -> Object {
  match self {
    Player(_, _, o) | Enemy(_, _, o) | Item(_, _, o) | Block(_, _, o) => o
  }
}

fn is_player(self : Collidable) -> Bool {
  match self {
    Player(_) => true
    _ => false
  }
}

fn is_enemy(self : Collidable) -> Bool {
  match self {
    Enemy(_) => true
    _ => false
  }
}

fn op_equal(self : Collidable, optb : Collidable) -> Bool {
  return self.get_obj().id == optb.get_obj().id
}

fn update_player_keys(player : Object, controls : Control) -> Unit {
  let lr_acc = player.vel.x * 0.2
  match controls {
    Left =>
      if player.crouch.not() {
        if player.vel.x > -player.params.speed {
          player.vel.x = player.vel.x - (0.4 - lr_acc)
        }
        player.dir = Left
      }
    Right =>
      if player.crouch.not() {
        if player.vel.x < player.params.speed {
          player.vel.x = player.vel.x + (0.4 + lr_acc)
        }
        player.dir = Right
      }
    Up =>
      if player.jumping.not() && player.grounded {
        player.jumping = true
        player.grounded = false
        player.vel.y = @math.maximum(
          player.vel.y - (player_jump + @double.abs(player.vel.x * 0.25)),
          player_max_jump,
        )
      }
    Down => if player.jumping.not() && player.grounded { player.crouch = true }
  }
}

fn normalize_pos(pos : XY, p1 : SpriteParams, p2 : SpriteParams) -> Unit {
  let (box1, boy1) = p1.bbox_offset
  let (box2, boy2) = p2.bbox_offset
  let (bw1, bh1) = p1.bbox_size
  let (bw2, bh2) = p2.bbox_size
  pos.x = pos.x - (bw2 + box2) + (bw1 + box1)
  pos.y = pos.y - (bh2 + boy2) + (bh1 + boy1)
}

fn update_player(
  player : Object,
  keys : @immut/list.List[Control]
) -> (PlayerSize, Sprite)? {
  let prev_jumping = player.jumping
  let prev_dir = player.dir
  let prev_vx = @double.abs(player.vel.x)
  keys.each(fn(x) { update_player_keys(player, x) })
  let v = player.vel.x * friction
  let vel_damped = if @double.abs(v) < 0.1 { 0.0 } else { v }
  player.vel.x = vel_damped
  let pl_typ = if player.health <= 1 { PlayerSize::Small } else { Large }
  if prev_jumping.not() && player.jumping {
    Some((pl_typ, Sprite::make(Player(pl_typ, Jumping), player.dir)))
  } else if prev_dir != player.dir || ((prev_vx == 0.0 && @double.abs(
    player.vel.x,
  ) > 0.0) && player.jumping.not()) {
    Some((pl_typ, Sprite::make(Player(pl_typ, Running), player.dir)))
  } else if prev_dir != player.dir && player.jumping && prev_jumping {
    Some((pl_typ, Sprite::make(Player(pl_typ, Jumping), player.dir)))
  } else if player.vel.y == 0.0 && player.crouch {
    Some((pl_typ, Sprite::make(Player(pl_typ, Crouching), player.dir)))
  } else if player.vel.y == 0.0 && player.vel.x == 0.0 {
    Some((pl_typ, Sprite::make(Player(pl_typ, Standing), player.dir)))
  } else {
    None
  }
}

fn update_vel(self : Object) -> Unit {
  if self.grounded {
    self.vel.y = 0.0
  } else if self.params.has_gravity {
    self.vel.y = @math.minimum(
      self.vel.y + gravity + @double.abs(self.vel.y) * 0.01,
      max_y_vel,
    )
  }
}

fn update_pos(self : Object) -> Unit {
  self.pos.x = self.vel.x + self.pos.x
  if self.params.has_gravity {
    self.pos.y = self.vel.y + self.pos.y
  }
}

fn process_obj(obj : Object, mapy : Double) -> Unit {
  obj.update_vel()
  obj.update_pos()
  if obj.pos.y > mapy {
    obj.kill = true
  }
}

fn collide_block(check_x : Bool, dir : Dir2d, obj : Object) -> Unit {
  match dir {
    North => obj.vel.y = -0.001
    South => {
      obj.vel.y = 0.0
      obj.grounded = true
      obj.jumping = false
    }
    East | West => if check_x { obj.vel.x = 0.0 }
  }
}

fn opposite_dir(dir : Dir1d) -> Dir1d {
  match dir {
    Left => Right
    Right => Left
  }
}

fn reverse_left_right(obj : Object) -> Unit {
  obj.vel.x = -obj.vel.x
  obj.dir = opposite_dir(obj.dir)
}

fn evolve_enemy(
  player_dir : Dir1d,
  typ : Enemy,
  spr : Sprite,
  obj : Object
) -> Collidable? {
  match typ {
    GKoopa => {
      let (new_spr, new_obj) = makeobj(
        new_id(),
        obj.dir,
        Enemy(GKoopaShell),
        obj.pos.x,
        obj.pos.y,
      )
      normalize_pos(new_obj.pos, spr.params, new_spr.params)
      Some(Enemy(GKoopaShell, new_spr, new_obj))
    }
    RKoopa => {
      let (new_spr, new_obj) = makeobj(
        new_id(),
        obj.dir,
        Enemy(RKoopaShell),
        obj.pos.x,
        obj.pos.y,
      )
      normalize_pos(new_obj.pos, spr.params, new_spr.params)
      Some(Enemy(RKoopaShell, new_spr, new_obj))
    }
    GKoopaShell | RKoopaShell => {
      obj.dir = player_dir
      if obj.vel.x != 0.0 {
        obj.vel.x = 0.0
      } else {
        set_vel_to_speed(obj)
      }
      None
    }
    _ => {
      obj.kill = true
      None
    }
  }
}

fn rev_dir(o : Object, t : Enemy, s : Sprite) -> Unit {
  reverse_left_right(o)
  let old_params = s.params
  transform_enemy(t, s, o.dir)
  normalize_pos(o.pos, old_params, s.params)
}

fn dec_health(obj : Object) -> Unit {
  let health = obj.health - 1
  if health == 0 {
    obj.kill = true
  } else if obj.invuln == 0 {
    obj.health = health
  }
}

// (*Used for deleting a block and replacing it with a used block*)
fn evolve_block(obj : Object) -> Collidable {
  dec_health(obj)
  let (new_spr, new_obj) = makeobj(
    new_id(),
    Left,
    Block(QBlockUsed),
    obj.pos.x,
    obj.pos.y,
  )
  Block(QBlockUsed, new_spr, new_obj)
}

// (*Used for spawning items above question mark blocks*)
fn spawn_above(player_dir : Dir1d, obj : Object, typ : Item) -> Collidable {
  let item = spawn(Item(typ), obj.pos.x, obj.pos.y)
  let item_obj = get_obj(item)
  item_obj.pos.y = item_obj.pos.y - get_sprite(item).params.frame_size.1
  item_obj.dir = opposite_dir(player_dir)
  set_vel_to_speed(item_obj)
  item
}

// (*Used to get the bounding box.*)
fn get_aabb(obj : Collidable) -> AABB {
  let spr = get_sprite(obj).params
  let obj = get_obj(obj)
  let (offx, offy) = spr.bbox_offset
  let (box, boy) = (obj.pos.x + offx, obj.pos.y + offy)
  let (sx, sy) = spr.bbox_size
  {
    center: { x: box + sx / 2.0, y: boy + sy / 2.0 },
    half: { x: sx / 2.0, y: sy / 2.0 },
  }
}

fn col_bypass(c1 : Collidable, c2 : Collidable) -> Bool {
  let o1 = get_obj(c1)
  let o2 = get_obj(c2)
  let ctypes = match (c1, c2) {
    (Item(_, _, _), Enemy(_, _, _)) => true
    (Enemy(_, _, _), Item(_, _, _)) | (Item(_, _, _), Item(_, _, _)) => true
    (Player(_, _, o1), Enemy(_, _, _)) => o1.invuln > 0
    _ => false
  }
  o1.kill || o2.kill || ctypes
}

// (*Used for checking if collisions occur. Compares half-widths and half-heights
// *and adjusts for when collisions do occur, by changing position so that
// *a second collision does not occur again immediately. This causes snapping.*)
fn check_collision(c1 : Collidable, c2 : Collidable) -> Dir2d? {
  let b1 = get_aabb(c1)
  let b2 = get_aabb(c2)
  let o1 = get_obj(c1)
  if col_bypass(c1, c2) {
    Option::None
  } else {
    let vx = b1.center.x - b2.center.x
    let vy = b1.center.y - b2.center.y
    let hwidths = b1.half.x + b2.half.x
    let hheights = b1.half.y + b2.half.y
    if @double.abs(vx) < hwidths && @double.abs(vy) < hheights {
      let ox = hwidths - @double.abs(vx)
      let oy = hheights - @double.abs(vy)
      if ox >= oy {
        if vy > 0.0 {
          o1.pos.y = o1.pos.y + oy
          Option::Some(Dir2d::North)
        } else {
          o1.pos.y = o1.pos.y - oy
          Option::Some(Dir2d::South)
        }
      } else if vx > 0.0 {
        o1.pos.x = o1.pos.x + ox
        Option::Some(Dir2d::West)
      } else {
        o1.pos.x = o1.pos.x - ox
        Option::Some(Dir2d::East)
      }
    } else {
      Option::None
    }
  }
}

// (*"Kills" the matched object by setting certain parameters for each.*)
fn kill(collid : Collidable) -> @immut/list.List[Particle] {
  match collid {
    Enemy(t, _, o) => {
      let pos = { x: o.pos.x, y: o.pos.y }
      let score = if o.score > 0 {
        @immut/list.Cons(make_score(o.score, pos), Nil)
      } else {
        Nil
      }
      let remains = match t {
        Goomba =>
          @immut/list.Cons(
            Particle::make(
              { x: 0.0, y: 0.0 },
              { x: 0.0, y: 0.0 },
              GoombaSquish,
              pos,
            ),
            Nil,
          )
        _ => Nil
      }
      score + remains
    }
    Block(t, _, o) =>
      match t {
        Brick => {
          let pos = { x: o.pos.x, y: o.pos.y }
          let p1 = Particle::make(
            XY::make(-5.0, -5.0),
            XY::make(0.0, 0.2),
            BrickChunkL,
            XY::make(pos.x, pos.y),
          )
          let p2 = Particle::make(
            XY::make(-3.0, -4.0),
            XY::make(0.0, 0.2),
            BrickChunkL,
            XY::make(pos.x, pos.y),
          )
          let p3 = Particle::make(
            XY::make(3.0, -4.0),
            XY::make(0.0, 0.2),
            BrickChunkR,
            XY::make(pos.x, pos.y),
          )
          let p4 = Particle::make(
            XY::make(5.0, -5.0),
            XY::make(0.0, 0.2),
            BrickChunkR,
            XY::make(pos.x, pos.y),
          )
          @immut/list.of([p1, p2, p3, p4])
        }
        _ => Nil
      }
    Item(t, _, o) =>
      match t {
        Mushroom => Cons(make_score(o.score, XY::make(o.pos.x, o.pos.y)), Nil)
        _ => Nil
      }
    _ => Nil
  }
}
