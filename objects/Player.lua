Player = class()

player_data = {}

player_data.max_hp = 10
player_data.hp = player_data.max_hp
player_data.ammo_max = {
  light = 64,
  heavy = 32,
  electric = 16,
  explosive = 8,
}
player_data.ammo = {
  light = 32,
  heavy = 16,
  electric = 8,
  explosive = 4,
}

function Player:new(x, y)
  self.tags = {"player"}
  self.sprite = Sprite("assets/player.ase")
  self.sprite:setTag("dwalk")
  self.sprite:offset("center", "bottom")
  self.sprite.layers.hands.visible = false
  self.x = x
  self.y = y
  self.z = 0
  self.sx = 1
  self.vx = 0
  self.vy = 0
  self.vz = 0

  self.body = PhysicsBody(self, world, shape.offsetCircle(0, 0, 4))

  player_data.obj = self
end

function Player:added(world)
  world:add(Gun(self, "pistol"))
end

function Player:update(dt)
  local ix, iy = 0, 0

  local friction = 0.2
  if self.z == 0 then
    if walk_up:isActive() then iy = iy - 1 end
    if walk_left:isActive() then ix = ix - 1 end
    if walk_down:isActive() then iy = iy + 1 end
    if walk_right:isActive() then ix = ix + 1 end

    friction = 15
    if jump:isJustActive() then
      self.vz = -200
    end
  end

  ix, iy = vec.normalized(ix, iy)
  ix, iy = cam:rotateXy(ix, iy)

  local max_speed = 150
  self.vx = mathx.dtLerp(self.vx, ix * max_speed, friction, dt)
  self.vy = mathx.dtLerp(self.vy, iy * max_speed, friction, dt)
  self.vz = self.vz + 981 * dt

  self.body:moveAndCollideWithTags(self.vx, self.vy, dt, {"env"})
  self.z = math.min(self.z + self.vz * dt, 0)

  cam.x = self.x
  cam.y = self.y

  local sx, sy = cam:xyOnScreen(self.x, self.y)
  local mx, my = love.mouse.getPosition()
  local dirx, diry = vec.direction(sx, sy, mx, my)

  if melee:isJustActive() then
    local mdx, mdy = cam:rotateXy(dirx, diry)
    local angle = vec.angle(mdx, mdy)
    world:add(MeleeSwing(self.x, self.y, angle))
  end

  do -- animation
    self.sx = dirx < 0 and -1 or 1
    local dir = diry < 0 and "u" or "d"

    local speed = vec.len(self.vx, self.vy)

    local anim = speed < 5 and "idle" or "walk"
    local anim_name = dir .. anim
    self.sprite:setTag(anim_name)

    self.sprite:update(dt, mathx.max(speed / max_speed, 0.6))
  end
end

function Player:draw(x, y)
  lg.setColor(0, 0, 0, 0.2)
  lg.ellipse("fill", mathx.floor(x), mathx.floor(y), 8, 2)
  lg.setColor(1, 1, 1)
  self.sprite:draw(x, y + self.z, 0, self.sx, 1)
  -- lg.line(0, 0, (self.bdx or 0) * 10, (self.bdy or 0) * 10)
end
