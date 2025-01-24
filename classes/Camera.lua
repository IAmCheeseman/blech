Camera = class()

function Camera:new()
  self.angle = 2
  self.x = 0
  self.y = 0
  self.r = 0
  self.target_r = 0

  self.rs = 0
  self.rc = 0
  self.rs90 = 0
  self.rc90 = 0
end

function Camera:update(dt)
  self.r = mathx.dtLerp(self.r, self.target_r, 32, dt)
  self.rs = mathx.sin(self.r)
  self.rc = mathx.cos(self.r)
  self.rs90 = mathx.sin(self.r + math.pi / 2)
  self.rc90 = mathx.cos(self.r + math.pi / 2)
end

function Camera:flip()
  cam.target_r = cam.target_r + mathx.pi
end

function Camera:rotateXy(x, y)
  local angle = vec.angle(x, y * self.angle)
  local len = vec.len(x, y)
  return mathx.sin(self.r + angle) * len, mathx.cos(self.r + angle) * len
end

function Camera:p3d(px, py)
  local x = self.rs * px + self.rs90 * py
  local y = (self.rc * px + self.rc90 * py) / self.angle
  return x, y
end

function Camera:xyOnScreen(x, y)
  local cx, cy = self:p3d(self.x, self.y)
  local sx, sy = self:p3d(x, y)
  sx = sx - cx + lg.getWidth() / 2
  sy = sy - cy + lg.getHeight() / 2
  return sx, sy
end
