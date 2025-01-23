Player = class()

function Player:new(x, y)
  self.tags = {"player"}
  self.sprite = Sprite("assets/player.ase")
  self.sprite:setTag("dwalk")
  self.sprite:offset("center", "bottom")
  self.x = x
  self.y = y
  self.z = 0
  self.sx = 1
  self.vx = 0
  self.vy = 0
  self.vz = 0
  self.gun_cd = 0.2
  self.gun_cdt = 0
end

function Player:update(dt)
  local ix, iy = 0, 0

  local friction = 0.2
  if self.z == 0 then
    if love.keyboard.isDown("w") then iy = iy - 1 end
    if love.keyboard.isDown("a") then ix = ix - 1 end
    if love.keyboard.isDown("s") then iy = iy + 1 end
    if love.keyboard.isDown("d") then ix = ix + 1 end

    friction = 10
    if love.keyboard.isDown("space") then
      self.vz = -200
    end
  end

  ix, iy = vec.normalized(ix, iy)
  ix, iy = cam:rotateXy(ix, iy)

  local max_speed = 150
  self.vx = mathx.dtLerp(self.vx, ix * max_speed, friction, dt)
  self.vy = mathx.dtLerp(self.vy, iy * max_speed, friction, dt)
  self.vz = self.vz + 981 * dt

  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt
  self.z = math.min(self.z + self.vz * dt, 0)

  cam.x = self.x
  cam.y = self.y

  local sx, sy = cam:xyOnScreen(self.x, self.y)
  local mx, my = love.mouse.getPosition()
  local dirx, diry = vec.direction(sx, sy, mx, my)

  self.gun_cdt = self.gun_cdt - dt

  if love.mouse.isDown(1) and self.gun_cdt <= 0 then
    local bdx, bdy = cam:rotateXy(dirx, diry)
    local bullet = Bullet(self.x, self.y, 300, bdx, bdy)
    world:add(bullet)
    self.gun_cdt = self.gun_cd
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

function Player:draw()
  love.graphics.setColor(0, 0, 0, 0.2)
  love.graphics.ellipse("fill", 0, 0, 8, 2)
  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(0, self.z, 0, self.sx, 1)
  love.graphics.line(0, 0, (self.bdx or 0) * 10, (self.bdy or 0) * 10)
end
