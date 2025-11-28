

enum Upgrade{
  UpgradeOneSize
  UpgradeOneDamage
  UpgradeOneCount
  UpgradeOneSpeed
  LearnWeaponTwo
  UpgradeTwoDamage
  UpgradeTwoSpeed
  LearnWeaponThree
  UpgradeWeaponThreeDamage
  UpgradePlayerSpeed
  UpgradePlayerDamageFactor
  Cure
  GetCoin
  GetShield
}derive(Eq,Hash)

struct UpgradeInfo {
  theType : Upgrade
  name : String
  describe : String
}

let allTypes:Map[Upgrade,Bool]=Map::new()

fn createUpgradeInfo(upgrade : Upgrade) -> UpgradeInfo {
  match upgrade{
    UpgradeOneDamage => {theType:upgrade,name:"提升铲子伤害",describe:""}
    UpgradeOneSize => {theType:upgrade,name:"提升铲子大小",describe:"咦，这不符合质量守恒定律！"}
    UpgradeOneCount => {theType:upgrade,name:"获得一把铁铲",describe:"以气御...铲？"}
    UpgradeOneSpeed => {theType:upgrade,name:"提升铲子旋转速度",describe:"天下武功,无坚不破,唯快不破"}
    LearnWeaponTwo=>{theType:upgrade,name:"习得雷法",describe:"以雷霆击碎黑暗！"}
    UpgradeTwoDamage=>{theType:upgrade,name:"提升雷法5点伤害",describe:""}
    UpgradeTwoSpeed=>{theType:upgrade,name:"雷法释放频率提升20%",describe:""}
    LearnWeaponThree=>{theType:upgrade,name:"习得三昧真火",describe:"难道...是传说中的梵诀?"}
    UpgradeWeaponThreeDamage=>{theType:upgrade,name:"提升三昧真火伤害",describe:"吸收了新的异火？"}
    UpgradePlayerSpeed=>{theType:upgrade,name:"提升角色移动速度",describe:"卡其脱离太！"}
    UpgradePlayerDamageFactor=>{theType:upgrade,name:"提升角色20%攻击力",describe:""}
    Cure=>{theType:upgrade,name:"回复30点生命值",describe:""}
    GetCoin=>{theType:upgrade,name:"获得100块灵石",describe:""}
    GetShield=>{theType:upgrade,name:"获得1个护身法器",describe:"可以抵挡一次伤害"}
  }
}


fn generateRandomUpgrades() -> Array[UpgradeInfo] {
  let selected = []
  if gameState.level==0{
    for k,v in allTypes{
      selected.push(createUpgradeInfo(k))
    }
    return selected
  }
  if gameState.level==1{
    allTypes[UpgradePlayerDamageFactor]=true
    allTypes[UpgradePlayerSpeed]=true
    allTypes[GetShield]=true
  }

  if gameState.health<100{
    allTypes[Cure]=true
  }else{
    allTypes[Cure]=false
  }
  let ableTypes = []
  for k,v in allTypes{
    if v{
      ableTypes.push(k)
    }
  }

  if ableTypes.is_empty(){
    ableTypes.push(GetCoin)
  }

  for i = 0; i < 3; i = i + 1 {
    let rand_index = rand.int(limit=ableTypes.length())
    let powerup_type = ableTypes[rand_index]
    selected.push(createUpgradeInfo(powerup_type))
  }
  selected
}

fn displayUpgrades(text_entity : @system.Entity, icon_entity : @system.Entity, index : Int) -> Unit {
  if index < upgradeUI.availableUpgrades.length(){
    let powerup = upgradeUI.availableUpgrades[index]

    // Update text
    let button_text = @sprite.Text::new(
      powerup.name,
      color="white",
      font="10px ThaleahFat",
    )
    let describeText=@sprite.Text::new(
      powerup.describe,
      color="white",
      font="6px ThaleahFat"
    )
    let button_sprite = @sprite.Sprite::from_text(button_text, 102,offset=Vec2D(16,4))
    let describeSprite=@sprite.Sprite::from_text(describeText,102,offset=Vec2D(16,14))
    @sprite.sprites.set(text_entity, button_sprite)
    @sprite.sprites[icon_entity]=describeSprite
  }
}

fn setup_powerup_button_with_background(
  button_entity : @system.Entity,
  icon_entity : @system.Entity,
  bg_entity : @system.Entity,
  index : Int
) -> Unit {
  // Position buttons vertically with more spacing
  let button_y =50.0 + index.to_double() * 25.0
  let button_position = @smath.Vec2D(50, button_y)

  // Set up blue background rectangle (render first, lowest z-index)
  let bg_sprite = @sprite.Sprite::from_color_rect(
    @sprite.ColorRect::new(Vec2D(120, 24), "gold"),
    100 + 1,
  )
  @sprite.sprites.set(bg_entity, bg_sprite)

  let bg_position = @smath.Vec2D(50, button_y)
  @position.positions.set(bg_entity, bg_position)
  @ui.uis.set(bg_entity, @ui.Ui::new())

  // Set up text button (render on top of background)
  @position.positions.set(button_entity, button_position)
  @ui.uis.set(button_entity, @ui.Ui::new())

  // Set up icon (positioned to the left of the text)
  let icon_position = @smath.Vec2D(50, button_y)
  @position.positions.set(icon_entity,icon_position)
  @ui.uis.set(icon_entity, @ui.Ui::new())

  // Add clickable area for the button (covers the entire blue background)
  @collision.shapes.set(
    button_entity,
    @collision.CollisionShape::Rect(
      size=@smath.Vec2D(120, 24),
      offset=@smath.Vec2D(0, 0),
    ),
  )

  // Create pickable component for button
  let pickable = @collision.Pickable::new()
  pickable.on_just_pressed(fn(_button) {
     select_powerup(index) 
     })
  @collision.pickables[button_entity] = pickable
}

fn select_powerup(index : Int) -> Unit {
  println("选择了第\{index+1}个升级")
  if index < upgradeUI.availableUpgrades.length() {
    let powerup = upgradeUI.availableUpgrades[index]
    handleUpgrade(powerup.theType)
  }
  resumeGame()
}

fn upgrade()->Unit{
  @backend.set_time_scale(0.0)
  upgradeUI.availableUpgrades=generateRandomUpgrades()
  displayUpgrades(upgradeUI.upgradeButton1Entity,upgradeUI.powerup_icon1_entity,0)
  displayUpgrades(upgradeUI.upgradeButton2Entity,upgradeUI.powerup_icon2_entity,1)
  displayUpgrades(upgradeUI.upgradeButton3Entity,upgradeUI.powerup_icon3_entity,2)

  upgradeUI.level_up_entity.respawn()
  upgradeUI.upgradeButton1Entity.respawn()
  upgradeUI.upgradeButton2Entity.respawn()
  upgradeUI.upgradeButton3Entity.respawn()
  upgradeUI.powerup_icon1_entity.respawn()
  upgradeUI.powerup_icon2_entity.respawn()
  upgradeUI.powerup_icon3_entity.respawn()
  upgradeUI.powerup_bg1_entity.respawn()
  upgradeUI.powerup_bg2_entity.respawn()
  upgradeUI.powerup_bg3_entity.respawn()
}

fn handleUpgrade(upgrade:Upgrade)->Unit{
  match upgrade{
    UpgradeOneDamage => {    
      weaponOneData.damage+=5
      if(weaponOneData.damage)>=35{
        weaponOneData.damage=35
        allTypes[UpgradeOneDamage]=false
      }
      println(weaponOneData.damage)
    }
    UpgradeOneSize => {
      weaponOneData.size+=0.2
      if weaponOneData.size>=3{
        weaponOneData.size=3
        allTypes[UpgradeOneSize]=false
      }
      println(weaponOneData.size)
    }
    UpgradeOneCount => {
      if(weaponOneData.count==0){
        addWeapon()
        allTypes[UpgradeOneDamage]=true
        allTypes[UpgradeOneSize]=true
        allTypes[UpgradeOneSpeed]=true
      }else if(weaponOneData.count<6) {
        addWeapon()
      }else if(weaponOneData.count==6){
        addWeapon()
        allTypes[UpgradeOneCount]=false
      }
    }
    UpgradeOneSpeed =>{
      weaponOneData.speed+=0.4
      if weaponOneData.speed>=3.0{
        weaponOneData.speed=3.0
        allTypes[UpgradeOneSpeed]=false
      }
      println(weaponOneData.speed)
    }
    LearnWeaponTwo=>{
      weaponTwoData.learn=true
      allTypes[LearnWeaponTwo]=false
      
      allTypes[UpgradeTwoDamage]=true
      allTypes[UpgradeTwoSpeed]=true
    }
    UpgradeTwoDamage=>{
      weaponTwoData.damage+=5.0
      if weaponTwoData.damage>=45.0{
        weaponTwoData.damage=45.0
        allTypes[UpgradeTwoDamage]=false
      }
    }
    UpgradeTwoSpeed=>{
      weaponTwoData.speed+=0.2
      if weaponTwoData.speed>=2.0{
        weaponTwoData.speed=2.0
        allTypes[UpgradeTwoSpeed]=false
      }
    }
    LearnWeaponThree=>{
      weaponThreeData.learn=true
      allTypes[LearnWeaponThree]=false

      allTypes[UpgradeWeaponThreeDamage]=true
    }
    UpgradeWeaponThreeDamage=>{
      weaponThreeData.damage+=6
      if weaponThreeData.damage>=42.0{
        weaponThreeData.damage=42.0
        allTypes[UpgradeWeaponThreeDamage]=false
      }
    }
    UpgradePlayerSpeed=>{
      gameState.speed+=50.0
      if gameState.speed>=400.0{
        gameState.speed=400.0
        allTypes[UpgradePlayerSpeed]=false
      }
    }
    UpgradePlayerDamageFactor=>{
      gameState.damageFactor+=0.2
      if gameState.damageFactor>=2.0{
        gameState.damageFactor=2.0
        allTypes[UpgradePlayerDamageFactor]=false
      }
      println(gameState.damageFactor)
    }
    Cure=>{
      if gameState.health+30<100{
        setHealth(gameState.health+30)
      }else{
        setHealth(100)
      }      
    }
    GetCoin=>{
      println("获得100块灵石")
    }
    GetShield=>{
      gameState.shield+=1
      if(gameState.shield>=5){
        gameState.shield=5
        allTypes[GetShield]=false
      }
    }
  }

}


fn setupUpgradeUI() -> Unit {

  // Set up level up text entity
  let level_up_sprite = @sprite.Sprite::from_text(
    upgradeUI.level_up_box,
    102,
  )
  @sprite.sprites.set(upgradeUI.level_up_entity, level_up_sprite)
  let level_up_position = @smath.Vec2D(
    80,
    15,
  )
  @position.positions.set(
    upgradeUI.level_up_entity,
    level_up_position,
  )
  @ui.uis.set(upgradeUI.level_up_entity, @ui.Ui::new())

  // Set up powerup button entities with backgrounds and icons
  setup_powerup_button_with_background(
    upgradeUI.upgradeButton1Entity,
    upgradeUI.powerup_icon1_entity,
    upgradeUI.powerup_bg1_entity,
    0
  )
  setup_powerup_button_with_background(
    upgradeUI.upgradeButton2Entity,
    upgradeUI.powerup_icon2_entity,
    upgradeUI.powerup_bg2_entity,
    1
  )
  setup_powerup_button_with_background(
    upgradeUI.upgradeButton3Entity,
    upgradeUI.powerup_icon3_entity,
    upgradeUI.powerup_bg3_entity,
    2
  )

  // Initially destroy all entities (they'll be respawned when needed)
  upgradeUI.level_up_entity.destroy()
  upgradeUI.upgradeButton1Entity.destroy()
  upgradeUI.upgradeButton2Entity.destroy()
  upgradeUI.upgradeButton3Entity.destroy()
  upgradeUI.powerup_icon1_entity.destroy()
  upgradeUI.powerup_icon2_entity.destroy()
  upgradeUI.powerup_icon3_entity.destroy()
  upgradeUI.powerup_bg1_entity.destroy()
  upgradeUI.powerup_bg2_entity.destroy()
  upgradeUI.powerup_bg3_entity.destroy()
}

fn resumeGame() -> Unit {
  @backend.set_time_scale(1.0)

  upgradeUI.level_up_entity.destroy()
  upgradeUI.upgradeButton1Entity.destroy()
  upgradeUI.upgradeButton2Entity.destroy()
  upgradeUI.upgradeButton3Entity.destroy()
  upgradeUI.powerup_icon1_entity.destroy()
  upgradeUI.powerup_icon2_entity.destroy()
  upgradeUI.powerup_icon3_entity.destroy()
  upgradeUI.powerup_bg1_entity.destroy()
  upgradeUI.powerup_bg2_entity.destroy()
  upgradeUI.powerup_bg3_entity.destroy()
}