World = class()

function World:new(cam)
  self.entitymd = {}
  self.entities = {}
  self.addq = {}
  self.remq = {}

  self.tags = {}
  self.tag_addq = {}
  self.tag_remq = {}

  self.cam = cam
end

function World:isEntityAddQueued(entity)
  local md = self.entitymd[entity]
  if not md then
    return false
  end
  return md.queued == true
end

function World:tag(entity, tag_name)
  local tag = self.tags[tag_name]
  if not tag then
    tag = {}
    self.tags[tag_name] = tag
  end

  assert(not tag[entity], "entity already has tag '" .. tag_name .. "'")
  assert(self.entitymd[entity], "entity not in world")

  table.insert(self.tag_addq, {entity=entity, tag_name=tag_name})
end

function World:untag(entity, tag_name)
  local tag = self.tags[tag_name]
  assert(tag, "tag '" .. tag_name .. "' doesn't exist")
  assert(tag[entity], "entity does not have tag '" .. tag_name .. "'")
  assert(self.entitymd[entity], "entity not in world")

  table.insert(self.tag_remq, {entity=entity, tag_name=tag_name})
end

function World:add(entity)
  table.insert(self.addq, entity)
  self.entitymd[entity] = {
    queued = true,
    index=#self.addq,
    zindex = 0,
  }
end

function World:getZIndex(entity)
  local md = self.entitymd[entity]
  assert(md, "entity not in world")
  return md.zindex
end

function World:rem(entity)
  local md = self.entitymd[entity]
  assert(md, "cannot remove entity not in world")

  if md.queued then
    -- If the object is queued, but not yet added to the world, we shouldn't
    -- fail, rather just remove it from the queue
    tablex.swapRem(self.addq, md.index)
    self.entitymd[entity] = nil
  else
    table.insert(self.remq, entity)
  end
end

function World:_flushTagAddQueue()
  for _, new in ipairs(self.tag_addq) do
    table.insert(self.tags[new.tag_name], new.entity)
    local md = self.entitymd[new.entity]
    md.tags[new.tag_name] = #self.tags[new.tag_name]
  end
  self.tag_addq = {}
end

function World:_removeTag(entity, tag_name)
  local md = self.entitymd[entity]
  assert(md, "entity not in world")
  local _, new = tablex.swapRem(self.tags[tag_name], md.tags[tag_name])
  local nmd = self.entitymd[new]
  nmd.tags[tag_name] = md.tags[tag_name]
  md.tags[tag_name] = nil
end

function World:_flushTagRemQueue()
  for _, new in ipairs(self.tag_remq) do
    self:_removeTag(new.entity, new.tag_name)
  end
  self.tag_remq = {}
end

function World:_flushAddQueue()
  for _, entity in ipairs(self.addq) do
    table.insert(self.entities, entity)
    local index = #self.entities
    local md = self.entitymd[entity]
    md.queued = nil
    md.index = index
    md.tags = {}

    if is(entity.tags, "table") then
      for _, tag in ipairs(entity.tags) do
        self:tag(entity, tag)
      end
      entity.tags = nil
    end
  end
  self.addq = {}
end

function World:_flushRemQueue()
  for _, entity in ipairs(self.remq) do
    local md = self.entitymd[entity]
    assert(md, "cannot remove entity not in world")

    for tag_name, _ in pairs(md.tags) do
      self:_removeTag(entity, tag_name)
    end

    local _, swapped = tablex.swapRem(self.entities, md.index)
    local smd = self.entitymd[swapped]
    assert(smd, "error removing entity from world")
    smd.index = md.index
    self.entitymd[entity] = nil
  end
  self.remq = {}
end

function World:_flush()
  self:_flushAddQueue()

  self:_flushTagAddQueue()
  self:_flushTagRemQueue()

  self:_flushRemQueue()
end

function World:update(dt)
  self:_flush()

  for _, entity in ipairs(self.entities) do
    try(entity.update, entity, dt)
  end
end

function World:callEvent(event, ...)
  local tagged = self:getTagged(event)
  for _, obj in ipairs(tagged) do
    obj[event](obj, ...)
  end
end

function World:getTagged(tag_name)
  if not self.tags[tag_name] then
    return {}
  end
  return self.tags[tag_name]
end

function World:getSingleton(tag_name)
  local tagged = self.tags[tag_name]
  if not tagged or #tagged == 0 then
    return nil
  end
  assert(#tagged == 1, "Tag '" .. tag_name .. "' is not a singleton")
  return tagged[1]
end

function World:draw()
  table.sort(self.entities, function(a, b)
    return self.entitymd[a].zindex < self.entitymd[b].zindex
  end)

  for i, entity in ipairs(self.entities) do
    -- Sorting will mess up the indices, so when we go through to draw them, we
    -- have to correct them
    self.entitymd[entity].index = i

    love.graphics.push()
    if not entity.no_transform then
      local dx, dy = self.cam:p3d(entity.x or 0, entity.y or 0, entity.z or 0)
      self.entitymd[entity].zindex = dy
      love.graphics.translate(mathx.round(dx), mathx.round(dy))
    end
    try(entity.draw, entity)
    love.graphics.pop()
  end
end

function World:gui()
  for _, entity in ipairs(self.entities) do
    try(entity.gui, entity)
  end
end
