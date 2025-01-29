weapons.create("pistol", {
  obj = Gun,
  sprite = Sprite("assets/pistol.png"):offset(-1, "center"),
  cooldown = 0.2,
  height = 5,
  barrel_length = 9,
  name = "weapons.pistol",
  shoot = function(weapon, x, y, dirx, diry)
    local bullet = Bullet(x, y, 800, dirx, diry)
    bullet.damage = 5
    world:add(bullet)
  end
})
