let playerIdleAnimation : @sprite.Animation = @sprite.Animation::new(
  getIdleFrames("Sprites/Farmer 0.png",width=18,height=20),
  fps=8,
  loop_=true,
)

let playerRunAnimation : @sprite.Animation = @sprite.Animation::new(
  getRunFrames("Sprites/Farmer 0.png",width=18,height=20),
  fps=18,
  loop_=true,
)
let playerDieAnimation: @sprite.Animation = @sprite.Animation::new(
  getDieFrames("Sprites/Farmer 0.png",width=18,height=20),
  fps=4,
  loop_=true,
)


let enemyOneRunAnimation: @sprite.Animation = @sprite.Animation::new(
  getEnemyRunFrames("Sprites/Enemy 1.png",width=18,height=18),
  fps=12,
  loop_=true
)

let enemyOneHurtAnimation:@sprite.Animation = @sprite.Animation::new(
  getEnemyHurtFrames("Sprites/Enemy 1.png",width=18,height=18),
  fps=1,
  loop_=true
)

let enemyTwoRunAnimation: @sprite.Animation = @sprite.Animation::new(
  getEnemyRunFrames("Sprites/Enemy 2.png",width=18,height=18),
  fps=12,
  loop_=true
)

let enemyTwoHurtAnimation:@sprite.Animation = @sprite.Animation::new(
  getEnemyHurtFrames("Sprites/Enemy 2.png",width=18,height=18),
  fps=1,
  loop_=true
)

let enemyThreeRunAnimation: @sprite.Animation = @sprite.Animation::new(
  getEnemyRunFrames("Sprites/Enemy 3.png",width=18,height=18),
  fps=12,
  loop_=true
)

let enemyThreeHurtAnimation:@sprite.Animation = @sprite.Animation::new(
  getEnemyHurtFrames("Sprites/Enemy 3.png",width=18,height=18),
  fps=1,
  loop_=true
)


let flower:@sprite.Sprite=@sprite.Sprite::from_picture(
    @sprite.Picture::new(Vec2D(18.0,18.0),"Sprites/Flower.png",repeat=NoRepeat),
    1,
  )

let playerCollisionLayer : @collision.CollisionLayer = @collision.CollisionLayer::new()
let wallCollisionLayer : @collision.CollisionLayer = @collision.CollisionLayer::new()
let enemyCollisionLayer : @collision.CollisionLayer = @collision.CollisionLayer::new()
let bullet_collision_layer : @collision.CollisionLayer = @collision.CollisionLayer::new()
let expStonelayer : @collision.CollisionLayer = @collision.CollisionLayer::new()

pub fn getIdleFrames(
  sprite_path : String,
  width~ : Double,
  height~ : Double,
) -> Array[@sprite.AnimationFrame] {
  let frames:Array[@sprite.AnimationFrame] = []
  frames.push({
      sprite_path,
      size: Vec2D(width, height),
      offset: Vec2D(0.0,42.0),
  })
  frames.push({
      sprite_path,
      size: Vec2D(width, height),
      offset: Vec2D(19.0,42.0),
  })
  frames.push({
      sprite_path,
      size: Vec2D(width, height),
      offset: Vec2D(38.0,42.0),
  })
  frames.push({
      sprite_path,
      size: Vec2D(width, height),
      offset: Vec2D(0.0,63.0),
  })  
  frames
}

pub fn getRunFrames(
  sprite_path : String,
  width~ : Double,
  height~ : Double,
) -> Array[@sprite.AnimationFrame] {
  let frames:Array[@sprite.AnimationFrame] = []
  frames.push({
      sprite_path,
      size: Vec2D(width, height),
      offset: Vec2D(0.0,0.0),
  })
  frames.push({
      sprite_path,
      size: Vec2D(width, height),
      offset: Vec2D(19.0,0.0),
  })
  frames.push({
      sprite_path,
      size: Vec2D(width, height),
      offset: Vec2D(38.0,0.0),
  })
  frames.push({
      sprite_path,
      size: Vec2D(width, height),
      offset: Vec2D(0.0,21.0),
  })
  frames.push({
      sprite_path,
      size: Vec2D(width, height),
      offset: Vec2D(19.0,21.0),
  })
  frames.push({
      sprite_path,
      size: Vec2D(width, height),
      offset: Vec2D(38.0,21.0),
  })
  
  frames
}

pub fn getDieFrames(
  sprite_path : String,
  width~ : Double,
  height~ : Double,
) -> Array[@sprite.AnimationFrame] {
  let frames:Array[@sprite.AnimationFrame] = []
  frames.push({
      sprite_path,
      size: Vec2D(width, height),
      offset: Vec2D(19.0,63.0),
  })
  frames.push({
      sprite_path,
      size: Vec2D(width, height),
      offset: Vec2D(38.0,63.0),
  })
  
  frames
}

pub fn getEnemyRunFrames(
  sprite_path : String,
  width~ : Double,
  height~ : Double,
) -> Array[@sprite.AnimationFrame] {
  let frames:Array[@sprite.AnimationFrame] = []
  frames.push({
      sprite_path,
      size: Vec2D(width, height),
      offset: Vec2D(0.0,0.0),
  })
  frames.push({
      sprite_path,
      size: Vec2D(width, height),
      offset: Vec2D(19.0,0.0),
  })
  frames.push({
      sprite_path,
      size: Vec2D(width, height),
      offset: Vec2D(38.0,0.0),
  })
  frames.push({
      sprite_path,
      size: Vec2D(width, height),
      offset: Vec2D(0.0,19.0),
  })
  frames.push({
      sprite_path,
      size: Vec2D(width, height),
      offset: Vec2D(19.0,19.0),
  })
  frames.push({
      sprite_path,
      size: Vec2D(width, height),
      offset: Vec2D(38.0,19.0),
  })
  
  frames
}

pub fn getEnemyHurtFrames(
  sprite_path : String,
  width~ : Double,
  height~ : Double,
) -> Array[@sprite.AnimationFrame] {
  let frames:Array[@sprite.AnimationFrame] = []
  frames.push({
      sprite_path,
      size: Vec2D(width, height),
      offset: Vec2D(0.0,38),
  })
  
  frames
}