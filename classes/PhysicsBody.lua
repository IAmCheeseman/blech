PhysicsBody = class()

local function verifyAnchor(anchor, errIndex)
  errIndex = errIndex + 1

  assert(is(anchor.x, "number"), "Expected anchor property 'x' to be number")
  assert(is(anchor.y, "number"), "Expected anchor property 'y' to be number")
end

function PhysicsBody:new(anchor, world, shape)
  verifyAnchor(anchor, 0)
  assert(love.math.isConvex(shape), "Shape must be convex")

  self.anchor = anchor
  self.shape = shape
  self.world = world
end

function PhysicsBody:setShape(shape)
  self.shape = shape

  -- All these cached values get invalidated when you change shape
  self.centerx, self.centery = nil, nil
  self.aabbx, self.aabby = nil, nil
  self.aabbw, self.aabbh = nil, nil
end

function PhysicsBody:getAabb()
  if self.aabbx then
    return
      self.aabbx + self.anchor.x, self.aabby + self.anchor.y,
      self.aabbw, self.aabbh
  end

  local startx, starty = self.shape[1], self.shape[2]
  local endx, endy = startx, starty

  for i=1, #self.shape, 2 do
    local x, y = self.shape[i], self.shape[i+1]

    startx = math.min(startx, x)
    starty = math.min(starty, y)
    endx = math.max(endx, x)
    endy = math.max(endy, y)
  end

  self.aabbx = startx
  self.aabby = starty
  self.aabbw = endx - startx
  self.aabbh = endy - starty

  return
    self.aabbx + self.anchor.x, self.aabby + self.anchor.y,
    self.aabbw, self.aabbh
end

function PhysicsBody:_getSmallestSide()
  local _, _, w, h = self:getAabb()
  return math.min(w, h)
end

function PhysicsBody:getCenter()
  if self.centerx then
    return self.centerx + self.anchor.x, self.centery + self.anchor.y
  end

  local total_points = #self.shape / 2

  local sumx, sumy = 0, 0

  for i=1, #self.shape, 2 do
    sumx = sumx + self.shape[i]
    sumy = sumy + self.shape[i+1]
  end

  self.centerx = sumx / total_points
  self.centery = sumy / total_points

  return self.centerx + self.anchor.x, self.centery + self.anchor.y
end

local function project(body, axisx, axisy)
  local min = vec.dot(
    axisx, axisy,
    body.shape[1] + body.anchor.x, body.shape[2] + body.anchor.y)
  local max = min

  for i=1, #body.shape, 2 do
    local p = vec.dot(
      axisx, axisy,
      body.shape[i] + body.anchor.x, body.shape[i+1] + body.anchor.y)

    if p < min then
      min = p
    elseif p > max then
      max = p
    end
  end

  return min, max
end

local function sat(a, b, check, res)
  for i=1, #check.shape, 2 do
    local startx = check.shape[i] + check.anchor.x
    local starty = check.shape[i+1] + check.anchor.y

    local endx, endy

    if i + 2 > #check.shape then
      endx = check.shape[1] + check.anchor.x
      endy = check.shape[2] + check.anchor.y
    else
      endx = check.shape[i+2] + check.anchor.x
      endy = check.shape[i+3] + check.anchor.y
    end

    local axisx = -(starty - endy)
    local axisy = startx - endx
    axisx, axisy = vec.normalized(axisx, axisy)

    local ap_min, ap_max = project(a, axisx, axisy)
    local bp_min, bp_max = project(b, axisx, axisy)

    if ap_max < bp_min or bp_max < ap_min then
      res.colliding = false
      return res
    end

    local overlap = math.min(ap_max - bp_min, bp_max - ap_min)
    if overlap < res.overlap then
      res.overlap = overlap
      res.axisx = axisx
      res.axisy = axisy
    end
  end

  return res
end

function PhysicsBody:collideWithBody(body)
  local res = {
    colliding = true,
    resolvex = 0,
    resolvey = 0,
    axisx = 0,
    axisy = 0,
    overlap = math.huge
  }

  sat(self, body, self, res)
  if res.colliding then
    sat(self, body, body, res)
  end

  res.resolvex = res.axisx * res.overlap
  res.resolvey = res.axisy * res.overlap

  local scx, scy = self:getCenter()
  local bcx, bcy = body:getCenter()
  local dirx, diry = vec.direction(bcx, bcy, scx, scy)
  if vec.dot(dirx, diry, res.resolvex, res.resolvey) < 0 then
    res.resolvex = -res.resolvex
    res.resolvey = -res.resolvey
  end

  return res
end

function PhysicsBody:_moveAndCollideWithTag(tag)
  local tagged = self.world:getTagged(tag)
  if #tagged == 0 then
    return
  end

  local coll

  for _, obj in ipairs(tagged) do
    if obj.body then
      local res = self:collideWithBody(obj.body)
      if res.colliding then
        self.anchor.x = self.anchor.x + res.resolvex
        self.anchor.y = self.anchor.y + res.resolvey

        coll = res
      end
    end
  end

  return coll
end

function PhysicsBody:moveAndCollideWithTags(vx, vy, dt, tags)
  local coll

  local ax, ay = self.anchor.x, self.anchor.y
  local movex, movey = vx * dt, vy * dt
  local resx, resy = ax + movex, ay + movey

  local dist = vec.distance(self.anchor.x, self.anchor.y, resx, resy)
  local checks = math.ceil(dist / self:_getSmallestSide())

  for i=1, checks do
    local p = i/checks
    self.anchor.x = ax + movex * p
    self.anchor.y = ay + movey * p

    for _, tag in ipairs(tags) do
      coll = self:_moveAndCollideWithTag(tag)
      if coll and coll.colliding then
        return coll
      end
    end
  end

  return coll
end

function PhysicsBody:getAllCollisions(vx, vy, dt, tags)
  local collisions = {}
  local added_set = {}

  local ax, ay = self.anchor.x, self.anchor.y
  local movex = vx * dt
  local movey = vy * dt
  local resx = ax + movex
  local resy = ay + movey

  local dist = vec.distance(self.anchor.x, self.anchor.y, resx, resy)
  local checks = math.max(math.ceil(dist / self:_getSmallestSide()), 1)

  for i=1, checks do
    local p = i/checks
    self.anchor.x = ax + movex * p
    self.anchor.y = ay + movey * p

    for _, tag in ipairs(tags) do
      for _, obj in ipairs(world:getTagged(tag)) do
        local res = self:collideWithBody(obj.body)
        if res.colliding and not added_set[obj] then
          added_set[obj] = true
          res.tag = tag
          res.obj = obj
          table.insert(collisions, res)
        end
      end
    end
  end

  self.anchor.x = ax
  self.anchor.y = ay

  return collisions
end

function PhysicsBody:getVertices()
  local vertices = {}

  for i=1, #self.shape, 2 do
    table.insert(vertices, self.shape[i] + self.anchor.x)
    table.insert(vertices, self.shape[i+1] + self.anchor.y)
  end

  return vertices
end

function PhysicsBody:draw()
  local vertices = {}

  for i=1, #self.shape, 2 do
    local x, y = self.shape[i], self.shape[i+1]
    x, y = self.world.cam:p3d(x, y)
    table.insert(vertices, x)
    table.insert(vertices, y)
  end

  lg.setColor(1, 0, 0, 0.5)
  lg.setLineStyle("rough")
  lg.setLineWidth(1)
  lg.polygon("line", vertices)
end
