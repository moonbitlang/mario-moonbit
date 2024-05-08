struct SpriteParams {
  max_frames : Int
  max_ticks : Int
  img_src : Image
  frame_size : (Double, Double)
  src_offset : (Double, Double)
  bbox_offset : (Double, Double)
  bbox_size : (Double, Double)
  repeat : Bool
}

struct Sprite {
  mut params : SpriteParams
  frame : Ref[Int]
  ticks : Ref[Int]
  mut img : Image
}

fn setup_sprite(repeat : Bool, bbox_offset : (Double, Double),
        bbox_size : (Double, Double), img_src : Image, max_frames : Int,
        max_ticks : Int, frame_size : (Double, Double),
        src_offset : (Double, Double)) -> SpriteParams {
  {
    img_src,
    max_frames,
    max_ticks,
    frame_size,
    src_offset,
    bbox_offset,
    bbox_size,
    repeat,
  }
}

fn setup_sprite_(img_src : Image, max_frames : Int, max_ticks : Int,
        frame_size : (Double, Double), src_offset : (Double, Double)) ->
     SpriteParams {
  {
    img_src,
    max_frames,
    max_ticks,
    frame_size,
    src_offset,
    bbox_offset: (0.0, 0.0),
    bbox_size: frame_size,
    repeat: true,
  }
}

fn make_small_player(player : Player, dir1d : Dir1d) -> SpriteParams {
  match (player, dir1d) {
    (Standing, Left) => setup_sprite(
      true,
      (3.0, 1.0),
      (11.0, 15.0),
      small_,
      1,
      0,
      (16.0, 16.0),
      (0.0, 0.0),
    )
    (Standing, Right) => setup_sprite(
      true,
      (1.0, 1.0),
      (11.0, 15.0),
      small_,
      1,
      0,
      (16.0, 16.0),
      (0.0, 32.0),
    )
    (Jumping, Left) => setup_sprite(
      true,
      (2.0, 1.0),
      (13.0, 15.0),
      small_,
      2,
      10,
      (16.0, 16.0),
      (16.0, 16.0),
    )
    (Jumping, Right) => setup_sprite(
      true,
      (2.0, 1.0),
      (13.0, 15.0),
      small_,
      2,
      10,
      (16.0, 16.0),
      (16.0, 48.0),
    )
    (Running, Left) => setup_sprite(
      true,
      (2.0, 1.0),
      (12.0, 15.0),
      small_,
      3,
      5,
      (16.0, 16.0),
      (16.0, 0.0),
    )
    (Running, Right) => setup_sprite(
      true,
      (2.0, 1.0),
      (12.0, 15.0),
      small_,
      3,
      5,
      (16.0, 16.0),
      (16.0, 32.0),
    )
    (Crouching, _) => setup_sprite(
      true,
      (1.0, 5.0),
      (14.0, 10.0),
      small_,
      1,
      10,
      (16.0, 16.0),
      (0.0, 64.0),
    )
  }
}

fn make_large_player(player : Player, dir1d : Dir1d) -> SpriteParams {
  match (player, dir1d) {
    (Standing, Left) => setup_sprite(
      true,
      (2.0, 1.0),
      (13.0, 25.0),
      large_,
      1,
      0,
      (16.0, 27.0),
      (16.0, 5.0),
    )
    (Standing, Right) => setup_sprite(
      true,
      (1.0, 1.0),
      (13.0, 25.0),
      large_,
      1,
      0,
      (16.0, 26.0),
      (16.0, 69.0),
    )
    (Jumping, Left) => setup_sprite(
      true,
      (2.0, 1.0),
      (12.0, 25.0),
      large_,
      1,
      0,
      (16.0, 26.0),
      (48.0, 6.0),
    )
    (Jumping, Right) => setup_sprite(
      true,
      (2.0, 1.0),
      (12.0, 25.0),
      large_,
      1,
      0,
      (16.0, 26.0),
      (48.0, 70.0),
    )
    (Running, Left) => setup_sprite(
      true,
      (2.0, 1.0),
      (13.0, 25.0),
      large_,
      4,
      10,
      (16.0, 27.0),
      (0.0, 37.0),
    )
    (Running, Right) => setup_sprite(
      true,
      (2.0, 1.0),
      (13.0, 25.0),
      large_,
      4,
      10,
      (16.0, 27.0),
      (0.0, 101.0),
    )
    (Crouching, _) => setup_sprite(
      true,
      (2.0, 10.0),
      (13.0, 17.0),
      large_,
      1,
      0,
      (16.0, 27.0),
      (32.0, 5.0),
    )
  }
}

fn make_enemy(enemy : Enemy, dir1d : Dir1d) -> SpriteParams {
  match (enemy, dir1d) {
    (Goomba, _) => setup_sprite(
      true,
      (1.0, 1.0),
      (14.0, 14.0),
      enemy_,
      2,
      10,
      (16.0, 16.0),
      (0.0, 128.0),
    )
    (GKoopa, Left) => setup_sprite(
      true,
      (4.0, 10.0),
      (11.0, 16.0),
      enemy_,
      2,
      10,
      (16.0, 27.0),
      (0.0, 69.0),
    )
    (RKoopa, Left) => setup_sprite(
      true,
      (4.0, 10.0),
      (11.0, 16.0),
      enemy_,
      2,
      10,
      (16.0, 27.0),
      (0.0, 5.0),
    )
    (GKoopa, Right) => setup_sprite(
      true,
      (1.0, 10.0),
      (11.0, 16.0),
      enemy_,
      2,
      10,
      (16.0, 27.0),
      (32.0, 69.0),
    )
    (RKoopa, Right) => setup_sprite(
      true,
      (1.0, 10.0),
      (11.0, 16.0),
      enemy_,
      2,
      10,
      (16.0, 27.0),
      (32.0, 5.0),
    )
    (GKoopaShell, _) => setup_sprite(
      true,
      (2.0, 2.0),
      (12.0, 13.0),
      enemy_,
      4,
      10,
      (16.0, 16.0),
      (0.0, 96.0),
    )
    (RKoopaShell, _) => setup_sprite(
      true,
      (2.0, 2.0),
      (12.0, 13.0),
      enemy_,
      4,
      10,
      (16.0, 16.0),
      (0.0, 32.0),
    )
  }
}

fn make_item(item : Item) -> SpriteParams {
  match item {
    Coin => setup_sprite(
      true,
      (3.0, 0.0),
      (12.0, 16.0),
      items_,
      3,
      15,
      (16.0, 16.0),
      (0.0, 80.0),
    )
    Mushroom => setup_sprite(
      true,
      (2.0, 0.0),
      (12.0, 16.0),
      items_,
      1,
      0,
      (16.0, 16.0),
      (0.0, 0.0),
    )
  }
}

fn make_block(block : Block) -> SpriteParams {
  match block {
    Brick => setup_sprite_(block_, 5, 10, (16.0, 16.0), (0.0, 0.0))
    QBlock(_) => setup_sprite_(block_, 4, 15, (16.0, 16.0), (0.0, 16.0))
    QBlockUsed => setup_sprite_(block_, 1, 0, (16.0, 16.0), (0.0, 32.0))
    UnBBlock => setup_sprite_(block_, 1, 0, (16.0, 16.0), (0.0, 48.0))
    Cloud => setup_sprite_(block_, 1, 0, (16.0, 16.0), (0.0, 64.0))
    Panel => setup_sprite_(panel_, 3, 15, (26.0, 26.0), (0.0, 0.0))
    Ground => setup_sprite_(ground, 1, 0, (16.0, 16.0), (0.0, 32.0))
  }
}

fn make_particle(particle : Part) -> SpriteParams {
  match particle {
    GoombaSquish => setup_sprite_(enemy_, 1, 0, (16.0, 16.0), (0.0, 144.0))
    BrickChunkL => setup_sprite_(chunk_, 1, 0, (8.0, 8.0), (0.0, 0.0))
    BrickChunkR => setup_sprite_(chunk_, 1, 0, (8.0, 8.0), (8.0, 0.0))
    Score100 => setup_sprite_(score_, 1, 0, (12.0, 8.0), (0.0, 0.0))
    Score200 => setup_sprite_(score_, 1, 0, (12.0, 9.0), (0.0, 9.0))
    Score400 => setup_sprite_(score_, 1, 0, (12.0, 9.0), (0.0, 18.0))
    Score800 => setup_sprite_(score_, 1, 0, (12.0, 9.0), (0.0, 27.0))
    Score1000 => setup_sprite_(score_, 1, 0, (14.0, 9.0), (13.0, 0.0))
    Score2000 => setup_sprite_(score_, 1, 0, (14.0, 9.0), (13.0, 9.0))
    Score4000 => setup_sprite_(score_, 1, 0, (14.0, 9.0), (13.0, 18.0))
    Score8000 => setup_sprite_(score_, 1, 0, (14.0, 9.0), (13.0, 27.0))
  }
}

fn make_player(player_size : PlayerSize, player : Player, dir1d : Dir1d) ->
     SpriteParams {
  match player_size {
    Large => make_large_player(player, dir1d)
    Small => make_small_player(player, dir1d)
  }
}

fn SpriteParams::make(spawn : Spawn, dir1d : Dir1d) -> SpriteParams {
  match spawn {
    Player(x, y) => make_player(x, y, dir1d)
    Enemy(x) => make_enemy(x, dir1d)
    Item(x) => make_item(x)
    Block(x) => make_block(x)
  }
}

fn Sprite::make_(params : SpriteParams) -> Sprite {
  { params, frame: Ref::make(0), ticks: Ref::make(0), img: params.img_src }
}

fn Sprite::make(spawn : Spawn, dir1d : Dir1d) -> Sprite {
  Sprite::make_(SpriteParams::make(spawn, dir1d))
}

fn make_bgd() -> Sprite {
  let params = setup_sprite_(backg_, 1, 0, (512.0, 256.0), (0.0, 0.0))
  Sprite::make_(params)
}

fn transform_enemy(enemy_typ : Enemy, spr : Sprite, dir : Dir1d) -> Unit {
  let params = make_enemy(enemy_typ, dir)
  let img = params.img_src
  spr.params = params
  spr.img = img
}

fn update_animation(spr : Sprite) -> Unit {
  let curr_ticks = spr.ticks.value
  if curr_ticks >= spr.params.max_ticks {
    spr.ticks.value = 0
    if spr.params.repeat {
      spr.frame.value = (spr.frame.value + 1) % spr.params.max_frames
    }
  } else {
    spr.ticks.value = curr_ticks + 1
  }
}
