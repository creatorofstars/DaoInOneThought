
struct WeaponTwoData{
  mut learn:Bool
  mut timer:Double
  mut damage:Double
  count:Int
  mut speed:Double
}

let weaponTwoData:WeaponTwoData={
  learn:false,
  timer:1.5,
  damage:20,
  count:1,
  speed:1.0
}


fn updateWeaponTwo(delta : Double) -> Unit {
  if gameState.gameOver {
    return
  }
  if !weaponTwoData.learn{
    return
  }

  if weaponTwoData.timer>0.0{
    weaponTwoData.timer-=delta
  }
  if weaponTwoData.timer <= 0 {
    weaponTwoData.timer=1.5/weaponTwoData.speed
    guard @position.positions.get(gameState.playerEntity) is Some(player_pos)
    let nearest_enemy_pos = findNearestEnemyPosition(player_pos.0)
    match nearest_enemy_pos {
      Some(enemy_pos) =>weaponTwoAttack(enemy_pos)
      None => ()
    }
  }
}


fn weaponTwoAttack(targetPos : @smath.Vec2D) -> Unit {
  @backend.play_audio(audio_path="Audio/ThunderDef.wav",volume=0.5,loop_=false)
  let thunderEntity = @system.Entity::new()
  @sprite.sprites[thunderEntity]=@sprite.Sprite::from_picture(
    @sprite.Picture::new(Vec2D(64,64),"Sprites/WeaponTwo.png",repeat=NoRepeat,transform=@smath.Transform::from_scale(0.5,0.5),),
    11,
    offset=Vec2D(-16,-16)
  )
  @position.positions[thunderEntity]=targetPos
  @collision.shapes[thunderEntity]=@collision.CollisionShape::Rect(
      size=Vec2D(24,24),
      offset=Vec2D(-12, -12),
    )
  @collision.collision_layers[thunderEntity]=bullet_collision_layer
  @collision.colliders[thunderEntity]=@collision.Collider::new(@collision.CollisionMask::new([enemyCollisionLayer, wallCollisionLayer,]))

  let area = @collision.Area::new(
    @collision.CollisionMask::new([enemyCollisionLayer]),
  )
  area.on_enter(fn(enemyEntity) {
    if enemies[enemyEntity].hurt{
      return
    }
    enemyHurt(enemyEntity,weaponTwoData.damage)
  })
  @collision.areas[thunderEntity]=area
  @system.timeout(0.15, fn() {
    thunderEntity.destroy()
  })
}
