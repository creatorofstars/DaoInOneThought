fn main{
  println("开始")
  @system.App::new()
  .with_canvas_height(720.0)
  .with_canvas_width(960.0)
  .with_image_smooth(false)
  .with_zoom(4.0)
  .with_fps(60)
  .add_plugin(@plugins.default_plugin)
  //.add_plugin(@plugins.debug_plugin)
  .add_system(gameStart, schedule=Startup)
  .add_system(spawnEnemySystem, schedule=Startup)
  .add_system(enemyAI)
  .add_system(timerSystem)
  .add_system(inputSystem)
  .add_system(updateWeapon)
  .add_system(updateWeaponTwo)
  .add_system(updateWeaponThree)
  .run()
}

struct GameState{
  playerEntity : @system.Entity
  shadowEntity:@system.Entity
  coverEntity:@system.Entity
  mut health:Double
  mut shield:Int

  healthText:@sprite.Text
  expText:@sprite.Text
  expBarEntity:@system.Entity
  expBar:@sprite.Sprite

  mut invincible:Bool
  mut gameOver:Bool

  mut timer:Double
  mut timerInt:Int

  mut expNow:Int
  mut level:Int
  mut speed:Double
  mut damageFactor:Double
  mut playing:Bool
}

struct UpgradeUI{
  level_up_entity : @system.Entity
  level_up_box : @sprite.Text
  upgradeButton1Entity: @system.Entity
  upgradeButton2Entity: @system.Entity
  upgradeButton3Entity: @system.Entity
  powerup_icon1_entity : @system.Entity
  powerup_icon2_entity : @system.Entity
  powerup_icon3_entity : @system.Entity
  powerup_bg1_entity : @system.Entity
  powerup_bg2_entity : @system.Entity
  powerup_bg3_entity : @system.Entity
  mut availableUpgrades:Array[UpgradeInfo]
}
let gameState:GameState={
  playerEntity:@system.Entity::new(),
  shadowEntity:@system.Entity::new(),
  coverEntity:@system.Entity::new(),
  health:100.0,
  shield:0,
  healthText:@sprite.Text::new(
    "生命值：100",
    color="white",
    font="6px ThaleahFat",
  ),
  expText:@sprite.Text::new(
    "经验值：0",
    color="white",
    font="6px ThaleahFat",
  ),  
  expBarEntity:@system.Entity::new(),
  expBar:@sprite.Sprite::from_color_rect(
    @sprite.ColorRect::new(Vec2D(240, 2), "gold"),
    100 + 1,
  ),
  invincible:false,
  gameOver:false,
  timer:0.0,
  timerInt:0,
  expNow:0,
  level:0,
  speed:150,
  damageFactor:1.0,
  playing:false,
}

let upgradeUI:UpgradeUI={
  level_up_entity:@system.Entity::new(),
  level_up_box: @sprite.Text::new(
    "升级",
    color="gold",
    font="36px ThaleahFat",
  ),
  upgradeButton1Entity:@system.Entity::new(),
  upgradeButton2Entity:@system.Entity::new(),
  upgradeButton3Entity:@system.Entity::new(),
  powerup_icon1_entity:@system.Entity::new(),
  powerup_icon2_entity:@system.Entity::new(),
  powerup_icon3_entity:@system.Entity::new(),
  powerup_bg1_entity: @system.Entity::new(),
  powerup_bg2_entity: @system.Entity::new(),
  powerup_bg3_entity: @system.Entity::new(),
  availableUpgrades:[]
}
let rand:@random.Rand=@random.Rand::new()
let nextExp:Array[Int]=[4,5,6,7,8,10,12,14,17,21,25,30,35,45,50,55,60,65,70,75,80]

fn gameStart(_delta : Double)->Unit{
  @backend.preload_audio("Audio/Rise.wav")
  @backend.load_font("ThaleahFat", "ThaleahFat.ttf")
  @camera.set_limits(top=0.0, bottom=720, left=0.0, right=960)
  addCover()
  addPlayer()

  
  addHealthText()
  addExpText()
  addExpBar()
  addBackground(Vec2D(960,720))
  addBorder(Vec2D(960,720))
  for x=0.0;x<=50.0;x=x+1.0{
    for y=0.0;y<=50.0;y=y+1.0{
        addGrass(Vec2D(x,y))
    }
  }
  getUpgrade()
  setupUpgradeUI()
}

fn addCover()->Unit{
  let entity=gameState.coverEntity
  let sprite=@sprite.Sprite::from_picture(@sprite.Picture::new(Vec2D(1053,790),"Sprites/Cover.png", repeat=NoRepeat,transform=@smath.Transform::from_scale(0.25,0.25)),
    200,
    offset=Vec2D(-120,-90))
  @sprite.sprites[entity]=sprite
  @position.positions[entity]=Vec2D(480,360)
  @backend.set_time_scale(0.0)
}

fn addPlayer()->Unit{
  let entity = gameState.playerEntity
  @sprite.sprites.set(
    entity,
    @sprite.Sprite::from_animation(
      playerIdleAnimation,
      10,
      offset=Vec2D(-18.0 / 2.0, -20.0 / 2.0),
    ),
  )
  @position.positions.set(entity, Vec2D(480, 360))

  let shadowEntity=gameState.shadowEntity
  @sprite.sprites[shadowEntity]=@sprite.Sprite::from_picture(
    @sprite.Picture::new(Vec2D(10,6),"Sprites/Shadow.png",repeat=NoRepeat,transform=@smath.Transform::from_scale(1.2,1.2)),
    8,
    offset=Vec2D(-12/2,6)
  )
  @position.positions[shadowEntity]=Vec2D(480,360)
  


  @velocity.velocities.set(entity, Vec2D(0.0, 0.0))
  @camera.attach_entity(entity, Vec2D(18 / 2.0, 20 / 2.0))
  @collision.collision_layers.set(entity, playerCollisionLayer)
  @collision.colliders.set(
    entity,
    @collision.Collider::new(
      @collision.CollisionMask::new([
        enemyCollisionLayer,
        wallCollisionLayer
      ]),
    ),
  )
  @collision.shapes.set(
    entity,
    @collision.CollisionShape::Rect(
      size=Vec2D(13, 13),
      offset=Vec2D(-13 / 2.0, -13 / 2.0),
    ),
  )

}


fn addBorder(size : @smath.Vec2D) -> Unit {
  fn add_one_border(pos : @smath.Vec2D, size : @smath.Vec2D) -> Unit {
    let entity = @system.Entity::new()
    @collision.collision_layers.set(entity, wallCollisionLayer)
    let collider = @collision.Collider::new(@collision.CollisionMask::empty())
    @collision.colliders.set(entity, collider)
    @collision.shapes.set(
      entity,
      @collision.CollisionShape::Rect(size~, offset=Vec2D(0.0, 0.0)),
    )
    @position.positions.set(entity, pos)
  }

  add_one_border(Vec2D(-16.0, -16.0), Vec2D(size[X] + 32.0, 16.0))
  add_one_border(Vec2D(-16.0, 0), Vec2D(16.0, size[Y]))
  add_one_border(Vec2D(-16.0, size[Y]), Vec2D(size[X] + 32.0, 16.0))
  add_one_border(Vec2D(size[X], 0), Vec2D(16.0, size[Y]))
}

fn addGrass(pos : @smath.Vec2D)->Unit{
  let temp=rand.double()

  if temp>0.9{
    let grass = @system.Entity::new()
    let sprite = flower
    @sprite.sprites.set(grass, sprite)
    @position.positions.set(
      grass,
      Vec2D(pos[X] * 18.0, pos[Y] * 18.0),
    )
  }

}

fn addBackground(size : @smath.Vec2D) -> Unit {
  let background = @system.Entity::new()
  let background_sprite = @sprite.Sprite::from_picture(
    @sprite.Picture::new(size,"Sprites/Grass.png", repeat=Repeat),
    0,
  )
  @sprite.sprites.set(background, background_sprite)
  @position.positions.set(background, Vec2D(0, 0))
}



fn timerSystem(delta : Double)->Unit{
  if gameState.gameOver{
    return
  }
  gameState.timer+=delta
  gameState.timerInt=gameState.timer.floor().to_int()
  //println(gameState.timerInt)
  if gameState.timerInt>=90{
    gameOver(true)
    gameState.timer=0.0
    gameState.timerInt=0
  }
}


fn inputSystem(_delta : Double)->Unit{
  if gameState.gameOver{
    return
  }

  let vel = @inputs.key_vector(KeyW, KeyS, KeyA, KeyD)
    .normalize()
    .scalar_mul(gameState.speed)
  @velocity.velocities.set(gameState.playerEntity, vel)
  @position.positions[gameState.shadowEntity]=@position.positions[gameState.playerEntity]
  if !vel.equal(@smath.Vec2D::zero()){ 
    if(vel[X]<0){
      let transform= @smath.Transform::flip_x(18)
      @sprite.play_animation(gameState.playerEntity, playerRunAnimation,transform~)
    }else{
      let transform= @smath.Transform::new()
      @sprite.play_animation(gameState.playerEntity, playerRunAnimation,transform~)
    }

  }else{
    @sprite.play_animation(gameState.playerEntity, playerIdleAnimation)
  }

  if @inputs.is_just_pressed(KeyQ){
    upgrade()
  }
  if @inputs.is_mouse_just_pressed(Left) && (gameState.playing==false){
    gameState.playing=true
    @backend.set_time_scale(1.0)
    @backend.play_audio(audio_path="Audio/Rise.mp3",volume=0.45,loop_=true)
    gameState.coverEntity.destroy()
    upgrade()
  }
}

let spawners : Array[@smath.Vec2D] = [
  Vec2D(16.0, 16.0),
  Vec2D(960.0 - 16.0, 16.0),
  Vec2D(16.0, 720.0 - 16.0),
  Vec2D(960.0 - 16.0, 720.0 - 16.0),
]


fn setHealth(health : Double) -> Unit {
  if gameState.shield>0&&gameState.health>health{
    gameState.shield-=1
    @backend.play_audio(audio_path="Audio/Shield.wav",volume=0.5,loop_=false)
    return
  }
  if gameState.health>health{
    gameState.health = health
    @backend.play_audio(audio_path="Audio/Hit.wav",volume=1.0,loop_=false)
    if gameState.health<=0.0{
      gameOver(false)
    }else{
      gameState.healthText.content = "生命值: " + gameState.health.to_string()
    }
  }else{
    gameState.health = health
    gameState.healthText.content = "生命值: " + gameState.health.to_string()
    @backend.play_audio(audio_path="Audio/Cure.wav",volume=0.5,loop_=false)
  }
  
  
}

fn addHealthText() -> Unit {
  let entity = @system.Entity::new()
  let sprite = @sprite.Sprite::from_text(gameState.healthText, 100)
  @sprite.sprites.set(entity, sprite)
  @position.positions.set(entity, Vec2D(6,6))
  @ui.uis.set(entity, @ui.Ui::new())
}

fn addExpText()->Unit{
  let entity = @system.Entity::new()
  let sprite = @sprite.Sprite::from_text(gameState.expText, 100)
  @sprite.sprites[entity]=sprite
  @position.positions[entity]=Vec2D(6.0,12.0)
  @ui.uis.set(entity, @ui.Ui::new())
}

fn addExpBar()->Unit{
  let entity = gameState.expBarEntity
  let backgroundEntity=@system.Entity::new()

  let sprite=gameState.expBar
  let backgroundSprite=@sprite.Sprite::from_color_rect(
    @sprite.ColorRect::new(Vec2D(240, 2), "black"),
    100,
  )

  @sprite.sprites[entity]=sprite
  @sprite.sprites[backgroundEntity]=backgroundSprite

  @position.positions[entity]=Vec2D(-240,0.0)
  @position.positions[backgroundEntity]=Vec2D(0.0,0.0)

  @ui.uis.set(entity, @ui.Ui::new())
  @ui.uis.set(backgroundEntity, @ui.Ui::new())
}

fn getExp(get:Int)->Unit{
  @backend.play_audio(audio_path="Audio/Exp.wav",volume=0.5,loop_=false)
  gameState.expNow+=get
  
  if gameState.expNow>=nextExp[gameState.level]{
    gameState.expNow-=nextExp[gameState.level]
    gameState.level+=1
    upgrade()
  }
  if gameState.level==nextExp.length(){
    gameState.expText.content="已满级~"
  }else{
    gameState.expText.content=translateLevel()+ " 经验值："+gameState.expNow.to_string()+"/"+nextExp[gameState.level].to_string()
    @position.positions[gameState.expBarEntity]=Vec2D(-240+240*(gameState.expNow.to_double()/nextExp[gameState.level].to_double()),0.0)

  }
  
}

fn getUpgrade()->Unit{  
  allTypes[UpgradeOneCount]=true
  allTypes[LearnWeaponTwo]=true
  allTypes[LearnWeaponThree]=true
}

fn gameOver(victory:Bool)->Unit{
    gameState.gameOver=true
    if victory{
      gameState.healthText.content = "游戏胜利~" 
      @backend.play_audio(audio_path="Audio/Victory.mp3",volume=0.9,loop_=false)
      @sprite.play_animation(gameState.playerEntity, playerIdleAnimation)

      showVictory()
    }else{
      gameState.healthText.content = "游戏结束~"
      @sprite.play_animation(gameState.playerEntity,playerDieAnimation) 
    }
    for e, state in enemies {
      e.destroy()
    }
    for e in weaponOneData.entitys{
      e.destroy()
    }
    
    @velocity.velocities[gameState.playerEntity]=Vec2D(0.0,0.0)
}

fn translateLevel()->String{
  match gameState.level{
    1..=10=>{"筑基期"}
    11..=20=>{"结丹期"}
    21..=30=>{"元婴期"}
    _=>{"无等级"}
  }
}

fn showVictory()->Unit{
  let entity=@system.Entity::new()
  let text=@sprite.Text::new(
    "游戏胜利！",
    color="white",
    font="24px ThaleahFat",
  )
  @sprite.sprites[entity]=@sprite.Sprite::from_text(text,102)
  @position.positions[entity]=Vec2D(75,100)
  @ui.uis.set(entity, @ui.Ui::new())

  let boxEntity=@system.Entity::new()
  @sprite.sprites[boxEntity]=@sprite.Sprite::from_color_rect(
    @sprite.ColorRect::new(Vec2D(240, 38), "gold"),
    100 + 1,)
  @position.positions[boxEntity]=Vec2D(0,90)
  @ui.uis.set(boxEntity, @ui.Ui::new())
}