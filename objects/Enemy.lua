Enemy = class()

function Enemy:new(x, y)
  self.tags = {"enemy", "damageable"}

  self.x = x
  self.y = y

  self.vx = 0
  self.vy = 0

  self.hp = 10

  self.max_speed = 70
  self.accel = 10
  self.body = PhysicsBody(self, world, shape.offsetRect(-4, -4, 8, 8))
end

function Enemy:damage(amount)
  self.hp = self.hp - amount
  if self.hp <= 0 then
    world:rem(self)
  end
end

function Enemy:update(dt)
  local player = world:getSingleton("player")
  if not player then
    return
  end

  local dirx, diry = vec.direction(self.x, self.y, player.x, player.y)
  self.vx = mathx.dtLerp(self.vx, dirx * self.max_speed, self.accel, dt)
  self.vy = mathx.dtLerp(self.vy, diry * self.max_speed, self.accel, dt)

  local pushx, pushy = 0, 0
  for _, collision in ipairs(self.body:getAllCollisions(self.vx, self.vy, dt, {"enemy"})) do
    local enemy = collision.obj
    local edirx, ediry = vec.direction(self.x, self.y, enemy.x, enemy.y)
    pushx = pushx - edirx
    pushy = pushy - ediry
  end
  pushx, pushy = vec.normalized(pushx, pushy)

  self.vx = self.vx + pushx * 10
  self.vy = self.vy + pushy * 10

  self.body:moveAndCollideWithTags(self.vx, self.vy, dt, {"env"})
end

function Enemy:draw(x, y)
  lg.setColor(0, 0, 1)
  lg.rectangle("fill", x - 4, y - 8, 8, 8)
end
