MeleeSwing = class()

local sword_swing_sprite = Sprite("assets/sword_swing.ase")
sword_swing_sprite:offset("left", "center")

function MeleeSwing:new(x, y, r)
  self.x = x
  self.y = y
  self.r = r

  self.kbx = mathx.cos(r)
  self.kby = mathx.sin(r)

  self.shape = shape.halfEllipse(15, 30, r)
  self.body = PhysicsBody(self, world, self.shape)

  self.lifetime = 0.2
  self.timer = self.lifetime

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
  local frame = mathx.ceil((1 - self.timer / self.lifetime) * (#sword_swing_sprite.frames - 1))
  sword_swing_sprite.frame = frame

  lg.push()
  lg.translate(x, y)
  lg.scale(1, -0.5)
  lg.rotate(cam.r)
  lg.setColor(0, 0, 0, 0.25)
  sword_swing_sprite:draw(0, 0, self.r - math.pi / 2)
  lg.pop()

  lg.push()
  lg.translate(x, y - 5)
  lg.scale(1, -0.5)
  lg.rotate(cam.r)
  lg.setColor(1, 1, 1)
  sword_swing_sprite:draw(0, 0, self.r - math.pi / 2)
  lg.pop()
end
