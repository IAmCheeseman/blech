Bullet = class()

function Bullet:new(x, y, speed, dirx, diry)
  if not diry then
    local dir = dirx
    self.dirx = mathx.cos(dir)
    self.diry = mathx.sin(dir)
  else
    self.dirx = dirx or 1
    self.diry = diry or 0
  end

  self.x = x or 0
  self.y = y or 0
  self.speed = speed or 200
  self.lifetime = 3
end

function Bullet:update(dt)
  self.x = self.x + self.dirx * self.speed * dt
  self.y = self.y + self.diry * self.speed * dt
  self.lifetime = self.lifetime - dt
  if self.lifetime < 0 then
    world:rem(self)
  end
end

function Bullet:draw()
  love.graphics.setColor(0, 0, 0, 0.2)
  love.graphics.ellipse("fill", 0, 0, 4, 1)
  love.graphics.setColor(1, 1, 0)
  love.graphics.circle("fill", 0, -6, 2)
end
