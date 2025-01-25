DirtPatch = class()

function DirtPatch:new(x, y)
  self.x = x
  self.y = y

  self.sort = "floor"

  local s = 64/2
  self.mesh = lg.newMesh({
    {-s, -s, 0, 0, 1, 1, 1, 1},
    { s, -s, 1, 0, 1, 1, 1, 1},
    { s,  s, 1, 1, 1, 1, 1, 1},
    {-s,  s, 0, 1, 1, 1, 1, 1},
  }, "fan", "static")

  self.mesh:setTexture(lg.newImage("assets/dirt_patch.png"))
end

function DirtPatch:draw()
  lg.push()
  lg.scale(1, 0.5)
  lg.rotate(-cam.r)

  lg.setColor(1, 1, 1)
  lg.draw(self.mesh, 0, 0)

  lg.pop()
end

