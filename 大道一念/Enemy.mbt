struct Enemy {
  speed : Double
  mut health : Double
  mut hurt : Bool
  runAnim:@sprite.Animation
  hurtAnim:@sprite.Animation
}

let enemiesData:Array[Enemy]=[
  {
    speed:100.0,
    health:15,
    hurt:false,
    runAnim:enemyOneRunAnimation,
    hurtAnim:enemyOneHurtAnimation,
  },
  {
    speed:100.0,
    health:25,
    hurt:false,
    runAnim:enemyTwoRunAnimation,
    hurtAnim:enemyTwoHurtAnimation,
  }, 
  {
    speed:100.0,
    health:35,
    hurt:false,
    runAnim:enemyThreeRunAnimation,
    hurtAnim:enemyThreeHurtAnimation,
  },
]

let enemies : Map[@system.Entity, Enemy] = Map::new()

fn spawnEnemySystem(_delta : Double) -> Unit {
  fn spawn_enemy() -> Unit {
    if gameState.gameOver {
      return
    }

    let enemy = @system.Entity::new()
    let enemyState = enemiesData[rand.int(limit=enemiesData.length())]
    enemies[enemy]={
      speed:enemyState.speed,
      health:enemyState.health*(1+gameState.timer/60.0),
      hurt:enemyState.hurt,
      runAnim:enemyState.runAnim,
      hurtAnim:enemyState.hurtAnim
      }

    let pos = spawners[rand.int(limit=spawners.length())]
    @position.positions.set(enemy, pos)
    @velocity.velocities.set(enemy, @smath.Vec2D::zero())
    // Create sprite and enemy state using data structure
    let sprite = @sprite.Sprite::from_animation(
      enemyState.runAnim,
      10,
      offset=Vec2D(-18.0 / 2.0, -18.0 / 2.0),
    )
    @sprite.sprites.set(enemy, sprite)


    @collision.shapes.set(
      enemy,
      @collision.CollisionShape::Rect(
        size=Vec2D(13.0,13.0),
        offset=Vec2D(-13 / 2.0, -13 / 2.0),
      ),
    )
    @collision.collision_layers.set(enemy, enemyCollisionLayer)
    @collision.colliders.set(
      enemy,
      @collision.Collider::new(
        @collision.CollisionMask::new([
          enemyCollisionLayer, wallCollisionLayer,
        ]),
      ),
    )

    
    
    let area = @collision.Area::new(
      @collision.CollisionMask::new([playerCollisionLayer]),
    )
    @collision.areas.set(enemy, area)
    area.on_enter(fn(e) {
      guard e.is_alive() else { return }
      guard e == gameState.playerEntity else { return }
      if gameState.invincible {
        return
      }
      gameState.invincible = true
      setHealth(gameState.health-10)
      @system.timeout(0.5, fn() {
        gameState.invincible = false
      })
    })
    @system.timeout(1.0/(1.0+gameState.timer/30.0), spawn_enemy)
  }

  spawn_enemy()
}

fn enemyAI(_delta : Double) -> Unit {
  if gameState.gameOver {
    return
  }
  for e, state in enemies {
    guard e.is_alive() else { continue }
    guard @position.positions.get(gameState.playerEntity)
      is Some(playerPosition)
    guard @position.positions.get(e) is Some(position)

    if !state.hurt{
      let dir = playerPosition.0 - position.0
      let vel = dir.normalize().scalar_mul(state.speed)
      @velocity.velocities[e]=vel

      if vel[X]<0{
        let transform=@smath.Transform::flip_x(18)
        @sprite.play_animation(e,state.runAnim,transform~)
      }else{
        let transform=@smath.Transform::new()
        @sprite.play_animation(e,state.runAnim,transform~)
      }
    }
    else{
      let dir = position.0- playerPosition.0
      let vel = dir.normalize().scalar_mul(200)
      @velocity.velocities[e]=vel
    }

  }
}


fn enemyDie(enemyEntity:@system.Entity)->Unit{
  let entity=@system.Entity::new()
  let expStone:@sprite.Sprite=@sprite.Sprite::from_picture(
    @sprite.Picture::new(Vec2D(6.0,6.0),"Sprites/ExpStone.png", repeat=NoRepeat),
    8,
    offset=Vec2D(-3.0,-3.0),
  )
  @sprite.sprites[entity]=expStone
  @position.positions[entity]=@position.positions[enemyEntity]
  @collision.shapes[entity]=@collision.CollisionShape::Rect(
        size=Vec2D(10.0,10.0),
        offset=Vec2D(-5, -5),
    )
  @collision.collision_layers[entity]=expStonelayer
  @collision.colliders[entity]=@collision.Collider::new(@collision.CollisionMask::empty())

  let area=@collision.Area::new(@collision.CollisionMask::new([playerCollisionLayer]))
  @collision.areas[entity]=area
  area.on_enter(fn(e){
    getExp(1)
    entity.destroy()
  })

  enemyEntity.destroy()
  @backend.play_audio(audio_path="Audio/ZombieDie.wav",volume=0.25,loop_=false)

}


fn findNearestEnemyPosition(player_pos : @smath.Vec2D) -> @smath.Vec2D? {
  let mut min = 140.0
  let mut res : @smath.Vec2D? = None
  for e, _enemy in enemies {
    guard e.is_alive() else { continue }
    guard @position.positions.get(e) is Some(enemy_pos)
    let dist = player_pos.distance_to(enemy_pos.0)
    if dist < min {
      min = dist
      res = Some(enemy_pos.0)
    }
  }
  res
}

fn enemyHurt(enemyEntity:@system.Entity,damage:Double)->Unit{
  let entity=@system.Entity::new()
  let text=@sprite.Text::new(
      (damage*gameState.damageFactor).to_int().to_string(),
      color="gold",
      font="12px ThaleahFat"
    )
  let sprite=@sprite.Sprite::from_text(text,15)
  @sprite.sprites[entity]=sprite
  @position.positions[entity]=@position.positions[enemyEntity]
  @system.timeout(0.25,fn(){
    entity.destroy()
  })

  enemies[enemyEntity].health-=damage*gameState.damageFactor
  if(enemies[enemyEntity].health<=0.0){
    enemyDie(enemyEntity)
  }else{
    enemies[enemyEntity].hurt=true
    @system.timeout(0.1,fn() {
       enemies[enemyEntity].hurt=false
    })
    @sprite.play_animation(enemyEntity,enemies[enemyEntity].hurtAnim,loop_=false)
  }

}