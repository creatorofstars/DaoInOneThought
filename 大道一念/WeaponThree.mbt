struct WeaponThreeData{
  mut learn:Bool
  mut timer:Double
  mut damage:Double

}

let weaponThreeData:WeaponThreeData={
  learn:false,
  timer:0.0,
  damage:12.0
}

fn updateWeaponThree(delta : Double) -> Unit {
  if gameState.gameOver {
    return
  }
  if !weaponThreeData.learn{
    return
  }

  if weaponThreeData.timer>0.0{
    weaponThreeData.timer-=delta
  }
  if weaponThreeData.timer <= 0 {
    weaponThreeData.timer=1.0
    guard @position.positions.get(gameState.playerEntity) is Some(player_pos)
    let nearest_enemy_pos = findNearestEnemyPosition(player_pos.0)
    match nearest_enemy_pos {
      Some(enemy_pos) =>weaponThreeAttack(enemy_pos)
      None => ()
    }
  }
}

fn weaponThreeAttack(targetPos : @smath.Vec2D)->Unit{
  let entity = @system.Entity::new()
  @sprite.sprites[entity]=@sprite.Sprite::from_picture(
    @sprite.Picture::new(Vec2D(32,32),"Sprites/WeaponThree.png",repeat=NoRepeat,),
    11,
    offset=Vec2D(-16,-16)
  )

  let playerPos=@position.positions[gameState.playerEntity].0
  @position.positions[entity]=playerPos

  let vel = (targetPos - playerPos).normalize().scalar_mul(210)
  @velocity.velocities[entity]=vel

  @collision.shapes[entity]=@collision.CollisionShape::Rect(
    size=Vec2D(18,18),
    offset=Vec2D(-9, -9),
  )
  @collision.collision_layers[entity]=bullet_collision_layer
  @collision.colliders[entity]=@collision.Collider::new(@collision.CollisionMask::new([wallCollisionLayer,]))

  let area = @collision.Area::new(
    @collision.CollisionMask::new([enemyCollisionLayer]),
  )
  area.on_enter(fn(enemyEntity) {
    if enemies[enemyEntity].hurt{
      return
    }
    enemyHurt(enemyEntity,weaponThreeData.damage)
  })
  @collision.areas[entity]=area
  
  @system.timeout(0.5, fn() {
    entity.destroy()
  })
}