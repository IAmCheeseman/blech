MeleeSwing = class()

function MeleeSwing:new(x, y, r)
  self.x = x
  self.y = y

  self.kbx = mathx.cos(r)
  self.kby = mathx.sin(r)

  self.shape = shape.halfEllipse(15, 30, r)
  self.body = PhysicsBody(self, world, self.shape)

  self.timer = 0.2

  self.hitlist = {}
end

function MeleeSwing:update(dt)
  local collisions = self.body:getAllCollisions(0, 0, dt, {"damageable"})

  for _, collision in ipairs(collisions) do
    if not self.hitlist[collision.obj] then
      collision.obj:damage(2, self.kbx, self.kby)
      self.hitlist[collision.obj] = true
    end
  end

  self.timer = self.timer - dt
  if self.timer <= 0 then
    world:rem(self)
  end
end

function MeleeSwing:draw(x, y)
  self.body:draw(x, y)
end
