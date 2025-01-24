Viewport = class()

function Viewport:new(cam)
  self.cam = cam
  self.screenw = 240
  self.screenh = 180

  self.canvas = lg.newCanvas(self.screenw + 1, self.screenh + 1)
end

function Viewport:_getScreenTrans()
  local ww, wh = lg.getDimensions()
  local scale = mathx.min(ww / self.screenw, wh / self.screenh)
  local x = (ww - self.screenw * scale) / 2
  local y = (wh - self.screenh * scale) / 2
  return scale, x, y
end

function Viewport:screenToWorld(x, y)
  local scale, vpx, vpy = self:_getScreenTrans()

  x = x - vpx
  y = y - vpy

  x = mathx.floor(x / scale)
  y = mathx.floor(y / scale)

  x = x - self.cam.x
  y = y - self.cam.y

  return x, y
end

function Viewport:screenToViewport(x, y)
  local scale, vpx, vpy = self:_getScreenTrans()

  x = x - vpx
  y = y - vpy

  x = mathx.floor(x / scale)
  y = mathx.floor(y / scale)

  return x, y
end

function Viewport:start()
  lg.setCanvas(self.canvas)
end

function Viewport:stop()
  lg.setCanvas()
end

function Viewport:draw()
  lg.push()
  lg.origin()
  local scale, x, y = self:_getScreenTrans()

  if self.cam then
    local cx, cy = cam:p3d(self.cam.x, self.cam.y)
    _, cx = mathx.modf(cx)
    _, cy = mathx.modf(cy)
    local q = lg.newQuad(
      cx, cy,
      self.screenw, self.screenh,
      self.screenw + 1, self.screenh + 1)
    lg.draw(self.canvas, q, x, y, 0, scale)
  else
    lg.draw(self.canvas, x, y, 0, scale)
  end

  lg.pop()
end
