enum Dir1d {
  Left
  Right
} derive(Eq)

enum Dir2d {
  North
  South
  East
  West
}

struct XY {
  mut x : Double
  mut y : Double
}

enum Control {
  Left
  Right
  Up
  Down
}

enum PlayerSize {
  Small
  Large
} derive(Eq)

enum Item {
  Mushroom
  Coin
}

enum Enemy {
  Goomba
  GKoopa
  RKoopa
  GKoopaShell
  RKoopaShell
}

enum Block {
  QBlock(Item)
  QBlockUsed
  Brick
  UnBBlock
  Cloud
  Panel
  Ground
}

enum Player {
  Standing
  Jumping
  Running
  Crouching
}

enum Part {
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

enum Spawn {
  Player(PlayerSize, Player)
  Enemy(Enemy)
  Item(Item)
  Block(Block)
}
