Cursor = class()

function Cursor:new()
  self.sprite = Sprite("assets/crosshair.png")
  self.sprite:offset("center", "center")

  love.mouse.setVisible(false)
end

function Cursor:gui()
    local x, y = viewport:screenToViewport(love.mouse.getPosition())
    lg.setColor(1, 1, 1)
    self.sprite:draw(x, y)
end
