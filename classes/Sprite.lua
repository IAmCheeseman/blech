require("classes.TextureAtlas")
local loadAse = require("ase")

local chunk_layer_data = 0x2004
local chunk_img_data = 0x2005
local chunk_tag_data = 0x2018

local atlas = TextureAtlas(512, 512)

Sprite = class()

function Sprite:new(path)
  self.offsetx = 0
  self.offsety = 0

  self.layers = {}
  self.frames = {}
  self.tags = {}

  self.anim_timer = 0
  self.frame = 1
  self.is_playing = true
  self.is_over = false

  self.width = 0
  self.height = 0

  if path:match("%.ase$") then
    self:_loadAse(path)
  else
    self:_loadFile(path)
  end
end

function Sprite:_loadAse(path)
  local file = loadAse(path)
  self.width = file.header.width
  self.height = file.header.height

  local framei = 1

  lg.push()
  lg.origin()
  lg.setColor(1, 1, 1)

  for _, frame in ipairs(file.header.frames) do
    for _, chunk in ipairs(frame.chunks) do
      if chunk.type == chunk_img_data then -- We have a frame
        local cel = chunk.data
        local buf = love.data.decompress("data", "zlib", cel.data)
        local data = love.image.newImageData(cel.width, cel.height, "rgba8", buf)
        local img = lg.newImage(data)
        local canvas = lg.newCanvas(self.width, self.height)

        lg.setCanvas(canvas)
        lg.draw(img, cel.x, cel.y)
        lg.setCanvas()

        local atlas_id = atlas:addTexture(canvas, nil, path .. framei)
        framei = framei + 1

        table.insert(self.frames, {
          texture = atlas_id,
          duration = frame.frame_duration / 1000,
        })

        img:release()
        data:release()
        canvas:release()
      elseif chunk.type == chunk_layer_data then -- We have a layer
        local data = chunk.data
        if data.type == 0 then
          local layer = {}
          layer.visible = bit.band(data.flags, 1) ~= 0
          layer.a = 1 - data.opacity / 255
          table.insert(self.layers, layer)
          self.layers[data.name] = layer
        else
          error("Unsupported aseprite layer type for '" .. data.name .. "'")
        end
      elseif chunk.type == chunk_tag_data then -- We have a tag
        for i, tag in ipairs(chunk.data.tags) do
          if i == 1 then
            self.active_tag = tag.name
          end

          self.tags[tag.name] = {
            from = tag.from + 1,
            to = tag.to + 1,
          }
        end
      end
    end
  end

  lg.pop()
end

function Sprite:_loadFile(path)
  local img = lg.newImage(path)
  local atlas_id = atlas:addTexture(img, nil, path)

  table.insert(self.frames, {
    texture = atlas_id,
    duration = 1,
  })

  self.width, self.height = img:getDimensions()

  local layer = {}
  layer.visible = true
  layer.a = 1
  table.insert(self.layers, layer)
  self.layers["texture"] = layer
end

function Sprite:offset(x, y)
  if x == "left" then
    self.offsetx = 0
  elseif x == "center" then
    self.offsetx = mathx.ceil(self.width / 2)
  elseif x == "right" then
    self.offsetx = self.width
  elseif is(x, "number") then
    self.offsetx = x
  end

  if y == "top" then
    self.offsety = 0
  elseif y == "center" then
    self.offsety = mathx.ceil(self.height / 2)
  elseif y == "bottom" then
    self.offsety = self.height
  elseif is(y, "number") then
    self.offsety = y
  end

  return self
end

function Sprite:setTag(tag)
  assert(self.tags[tag], "nonexistent tag '" .. tag .. "'")
  self.active_tag = tag
end

function Sprite:isAtTagEnd()
  if not self.active_tag then
    return true
  end

  local tag = self.tags[self.active_tag]
  return self.frame == tag.to
end

function Sprite:update(dt, speed)
  speed = speed or 1

  if self.is_playing then
    local from = 1
    local to = #self.frames
    local frame = self.frames[self.frame]

    if self.active_tag then
      from = self.tags[self.active_tag].from
      to = self.tags[self.active_tag].to
    end

    self.anim_timer = self.anim_timer + dt * speed
    if self.anim_timer >= frame.duration then
      self.anim_timer = 0
      self.frame = self.frame + 1

      if self.frame > to then
        self.is_over = true
      end
    else
      self.is_over = false
    end

    if self.frame < from or self.frame > to then
      self.frame = from
    end
  end
end

function Sprite:draw(x, y, r, sx, sy, kx, ky)
  local layer_count = #self.layers
  local start = self.frame * layer_count - layer_count

  local i = 1
  repeat
    local offset = i
    local layer = self.layers[i]

    if layer.visible then
      atlas:draw(
        self.frames[start + offset].texture, nil,
        mathx.floor(x), mathx.floor(y),
        r, sx, sy, self.offsetx, self.offsety, kx, ky)
    end

    i = i + 1
  until i > layer_count
end
