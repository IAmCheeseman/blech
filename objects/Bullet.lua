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
  self.damage = 1

  self.body = PhysicsBody(self, world, shape.offsetRect(-2, -2, 4, 4))
end

function Bullet:update(dt)
  local vx, vy = self.dirx * self.speed, self.diry * self.speed
  local collisions = self.body:getAllCollisions(vx, vy, dt, {"damageable", "env"})
  self.x = self.x + vx * dt
  self.y = self.y + vy * dt

  for _, collision in ipairs(collisions) do
    if collision.tag == "damageable" then
      local kbx, kby = vec.normalized(self.dirx, self.dirx)
      collision.obj:damage(self.damage, kbx, kby)
    end
    world:rem(self)
  end

  self.lifetime = self.lifetime - dt
  if self.lifetime < 0 then
    world:rem(self)
  end
end

function Bullet:draw(x, y)
  lg.setColor(0, 0, 0, 0.2)
  lg.ellipse("fill", x, y, 4, 1)
  lg.setColor(1, 1, 0)
  lg.circle("fill", x, y - 6, 2)
end
