///|
pub(all) enum PlayerSize {
  Small
  Large
}

///|
pub(all) enum Item {
  Mushroom
  Coin
}

///|
pub(all) enum Enemy {
  Goomba
  GKoopa
  RKoopa
  GKoopaShell
  RKoopaShell
}

///|
pub(all) enum Block {
  QBlock(Item)
  QBlockUsed
  Brick
  UnBBlock
  Cloud
  Panel
  Ground
}

///|
pub(all) enum Player {
  Standing
  Jumping
  Running
  Crouching
}

///|
pub(all) enum Part {
  GoombaSquish
  BrickChunkL
  BrickChunkR
  Score100
  Score200
  Score400
  Score800
  Score1000
  Score2000
  Score4000
  Score8000
}

///|
pub(all) enum Spawn {
  Player(PlayerSize, Player)
  Enemy(Enemy)
  Item(Item)
  Block(Block)
}
