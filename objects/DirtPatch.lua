DirtPatch = class()

function DirtPatch:new(x, y)
  self.x = x
  self.y = y

  self.sort = "floor"

  local s = 64/2
  self.vertices = {
    -s, -s,
     s, -s,
     s, s,
    -s, s,
  }
  self.mesh = lg.newMesh(4, "fan", "dynamic")
  self.mesh:setTexture(lg.newImage("assets/dirt_patch.png"))
end

function DirtPatch:getXy(pos)
  local index = pos * 2 - 1
  return cam:p3d(self.vertices[index], self.vertices[index + 1])
end

function DirtPatch:draw()
  local tlx, tly = self:getXy(1)
  self.mesh:setVertex(1, tlx, tly, 0, 0)
  local trx, try = self:getXy(2)
  self.mesh:setVertex(2, trx, try, 1, 0)
  local brx, bry = self:getXy(3)
  self.mesh:setVertex(3, brx, bry, 1, 1)
  local blx, bly = self:getXy(4)
  self.mesh:setVertex(4, blx, bly, 0, 1)

  lg.setColor(1, 1, 1)
  lg.draw(self.mesh, 0, 0)
end
