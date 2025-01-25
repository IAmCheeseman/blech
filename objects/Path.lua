Path = class()

function Path:new(x, y)
  self.x = x
  self.y = y

  self.sort = "floor"

  self.vertices = self:generatePath()
  self.mesh = lg.newMesh(self.vertices, "strip", "static")
  self.mesh:setTexture(lg.newImage("assets/dirt_patch.png"))
end

function Path:generatePath()
  -- TODO: Put this in it's own function?
  local points = {}

  do
    local x = 0
    local y = 0
    local angle = lmath.random() * mathx.tau
    local turn_limit = mathx.pi / 4
    local step_distance = 32

    for _=1, 50 do
      table.insert(points, {
        x = x,
        y = y,
        radius = 16,
        angle = angle,
      })
      angle = angle + mathx.fRandom(-turn_limit, turn_limit)
      x = x + mathx.cos(angle) * step_distance
      y = y + mathx.sin(angle) * step_distance
    end
  end

  -- Generate the path
  local vertices = {}

  for i=1, #points - 1 do
    local cur = points[i]
    local next = points[i + 1]

    local tlx = cur.x + math.cos(cur.angle - math.pi / 2) * cur.radius
    local tly = cur.y + math.sin(cur.angle - math.pi / 2) * cur.radius
    local blx = cur.x + math.cos(cur.angle + math.pi / 2) * cur.radius
    local bly = cur.y + math.sin(cur.angle + math.pi / 2) * cur.radius
    local trx = next.x + math.cos(next.angle - math.pi / 2) * next.radius
    local try = next.y + math.sin(next.angle - math.pi / 2) * next.radius
    local brx = next.x + math.cos(next.angle + math.pi / 2) * next.radius
    local bry = next.y + math.sin(next.angle + math.pi / 2) * next.radius

    table.insert(vertices, {tlx, tly, 0, 0, 1, 1, 1, 1})
    table.insert(vertices, {blx, bly, 0, 1, 1, 1, 1, 1})
    table.insert(vertices, {trx, try, 1, 0, 1, 1, 1, 1})
    table.insert(vertices, {brx, bry, 1, 1, 1, 1, 1, 1})
  end

  return vertices
end

function Path:draw()
  lg.push()
  lg.scale(1, 0.5)
  lg.rotate(-cam.r)

  lg.setColor(1, 1, 1)
  lg.draw(self.mesh, 0, 0)

  lg.setColor(1, 0, 0)
  lg.setLineWidth(1)
  for i=1, #self.vertices - 1 do
    local c = self.vertices[i]
    local n = self.vertices[i+1]

    -- lg.line(c[1], c[2], n[1], n[2])
    -- lg.circle("fill", c[1], c[2], 3)
  end

  lg.pop()
end

