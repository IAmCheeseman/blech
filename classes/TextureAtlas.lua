TextureAtlas = class()

function TextureAtlas:new(width, height)
  self.width = width
  self.height = height

  self.canvas = lg.newCanvas(width, height)

  self.cache = {}
  self.paths = {}
  self.bin = {
    x = 0,
    y = 0,
    width = width,
    height = height,
  }
end

function TextureAtlas:_findNode(root, width, height)
  if root.texture then
    return self:_findNode(root.right, width, height)
        or self:_findNode(root.down, width, height)
  elseif width <= root.width and height <= root.height then
    return root
  end

  return nil
end

function TextureAtlas:_split(node, texture, width, height)
  node.texture = texture

  node.right = {
    x = node.x + width,
    y = node.y,
    width = node.width - width,
    height = height
  }
  node.down = {
    x = node.x,
    y = node.y + height,
    width = node.width,
    height = node.height - height,
  }

  node.width = width
  node.height = height
  return node
end

function TextureAtlas:getData(id)
  return self.cache[id]
end

function TextureAtlas:newQuad(id, x, y, w, h)
  local c = self.cache[id]
  assert(c, "invalid texture atlas cache id")
  return lg.newQuad(c.x + x, c.y + y, w, h, self.width, self.height)
end

function TextureAtlas:addTexture(texture, quad, id)
  if self.paths[id] then
    return self.paths[id]
  end

  if is(texture, "string") then
    texture = lg.newImage(texture)
  end

  local width, height = texture:getDimensions()

  local node = self:_findNode(self.bin, width, height)
  assert(node, "cannot fit image in texture atlas")

  self:_split(node, texture, width, height)
  lg.setCanvas(self.canvas)
  if quad then
    lg.draw(texture, quad, node.x, node.y)
  else
    lg.draw(texture, node.x, node.y)
  end
  lg.setCanvas()

  local atlasquad = lg.newQuad(
    node.x, node.y,
    width, height,
    self.width, self.height)

  local cacheid = #self.cache + 1
  self.cache[cacheid] = {
    quad = atlasquad,
    x = node.x,
    y = node.y,
    width = width,
    height = height,
  }

  self.paths[id] = cacheid
  return cacheid
end

function TextureAtlas:draw(cacheid, quad, x, y, r, sx, sy, ox, oy, kx, ky)
  local cache = self.cache[cacheid]
  assert(cache, "invalid texture atlas cache id")
  lg.draw(self.canvas, quad or cache.quad, x, y, r, sx, sy, ox, oy, kx, ky)
end

function TextureAtlas:_draw_Node(node)
  lg.rectangle("line", node.x, node.y, node.width, node.height)
  if node.right then
    self:_draw_Node(node.right)
    self:_draw_Node(node.down)
  end
end

function TextureAtlas:debugDraw()
  lg.setColor(1, 1, 1)
  lg.draw(self.canvas, 0, 0)
  lg.setColor(1, 0, 0)
  lg.setLineStyle("rough")
  self:_draw_Node(self.bin)
end

function TextureAtlas:drawQuad(quad, x, y, r, sx, sy, ox, oy, kx, ky)
  lg.draw(self.canvas, quad, x, y, r, sx, sy, ox, oy, kx, ky)
end

return TextureAtlas
