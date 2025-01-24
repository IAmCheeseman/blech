Enemy = class()

function Enemy:new(x, y)
  self.tags = {"enemy"}

  self.x = x
  self.y = y

  self.vx = 0
  self.vy = 0

  self.max_speed = 70
  self.accel = 10
end

function Enemy:update(dt)
  local player = world:getSingleton("player")
  if not player then
    return
  end

  local dirx, diry = vec.direction(self.x, self.y, player.x, player.y)
  self.vx = mathx.dtLerp(self.vx, dirx * self.max_speed, self.accel, dt)
  self.vy = mathx.dtLerp(self.vy, diry * self.max_speed, self.accel, dt)

  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt
end

function Enemy:draw()
  lg.setColor(1, 0, 0)
  lg.rectangle("fill", -4, -8, 8, 8)
end
