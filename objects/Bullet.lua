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

  self.body = PhysicsBody(self, world, shape.offsetRect(-2, -2, 4, 4))
end

function Bullet:update(dt)
  local vx, vy = self.dirx * self.speed, self.diry * self.speed
  local collisions = self.body:getAllCollisions(vx, vy, dt, {"env"})
  self.x = self.x + vx * dt
  self.y = self.y + vy * dt

  self.lifetime = self.lifetime - dt
  if self.lifetime < 0 or #collisions ~= 0 then
    world:rem(self)
  end
end

function Bullet:draw()
  lg.setColor(0, 0, 0, 0.2)
  lg.ellipse("fill", 0, 0, 4, 1)
  lg.setColor(1, 1, 0)
  lg.circle("fill", 0, -6, 2)
end
