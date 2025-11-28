
struct WeaponData{
  entitys:Array[@system.Entity]
  mut size:Double
  mut damage:Double
  mut count:Int
  mut speed:Double
}

let weaponOneData:WeaponData={
  entitys:[],
  size:2.0,
  damage:10.0,
  count:0,
  speed:1.0
}
let weaponOne:@sprite.Sprite=@sprite.Sprite::from_picture(
    @sprite.Picture::new(Vec2D(7.0,18.0),"Sprites/WeaponOne.png", transform=@smath.Transform::from_rotation_deg(0).scale(weaponOneData.size,weaponOneData.size),repeat=NoRepeat),
    9,
  )

let weaponOneDegreeMap:Map[@system.Entity,Double]=Map::new()
fn addWeapon()->Unit{
  weaponOneData.count+=1
  let entity=@system.Entity::new()
  weaponOneData.entitys.push(entity)
  @sprite.sprites[entity]=weaponOne
  @position.positions[entity]=Vec2D(480,360)
  @collision.shapes[entity]=@collision.CollisionShape::Rect(
      size=Vec2D(7,18),
      offset=Vec2D(-7 / 2.0, -18 / 2.0),
    )
  @collision.collision_layers.set(entity, bullet_collision_layer)
  @collision.colliders.set(
      entity,
      @collision.Collider::new(
        @collision.CollisionMask::new([
          enemyCollisionLayer, wallCollisionLayer,
        ]),
      ),
    )

  let area = @collision.Area::new(
    @collision.CollisionMask::new([enemyCollisionLayer]),
  )
  area.on_enter(fn(enemyEntity) {
    if enemies[enemyEntity].hurt{
      return
    }
    enemyHurt(enemyEntity,weaponOneData.damage)

  })
  @collision.areas.set(entity, area)

  for i=0;i<weaponOneData.count;i=i+1{
    weaponOneDegreeMap[weaponOneData.entitys[i]]=(360.0/weaponOneData.count.to_double())*i.to_double()
  }
  
}

fn updateWeapon(delta:Double)->Unit{
  if gameState.gameOver{
    return
  }

  for entity in weaponOneData.entitys{
    weaponOneDegreeMap[entity]=weaponOneDegreeMap[entity]+120.0*weaponOneData.speed*delta
    let weaponOne:@sprite.Sprite=@sprite.Sprite::from_picture(
      @sprite.Picture::new(Vec2D(7.0,18.0),"Sprites/WeaponOne.png", transform=@smath.Transform::from_rotation_deg(weaponOneDegreeMap[entity]).scale(weaponOneData.size,weaponOneData.size),repeat=NoRepeat),
      9,
      offset=Vec2D(-3.5*@math.cos(weaponOneDegreeMap[entity] * (@math.PI / 180.0))*weaponOneData.size,-3.5*@math.sin(weaponOneDegreeMap[entity] * (@math.PI / 180.0))*weaponOneData.size)
    )
    @sprite.sprites[entity]=weaponOne
    @position.positions[entity]=@position.positions[gameState.playerEntity]
    @collision.shapes[entity]= @collision.CollisionShape::Rect(
      size=Vec2D(8*weaponOneData.size,8*weaponOneData.size) ,
      offset=Vec2D((-4-14.0*@math.sin(weaponOneDegreeMap[entity] * (@math.PI / 180.0)))*weaponOneData.size,(-4+14*@math.cos(weaponOneDegreeMap[entity] * (@math.PI / 180.0)))*weaponOneData.size)
    )
    
  }
}


