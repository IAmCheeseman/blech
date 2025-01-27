Gun = class()

function Gun:new(anchor, weapon_id)
  self.weapon_id = weapon_id
  self.weapon = weapons.definitions[weapon_id]

  self.anchor = anchor

  self.x = self.anchor.x
  self.y = self.anchor.y

  self.r = 0
  self.sy = 0

  self.cooldown = 0
end

function Gun:update(dt)
  local sx, sy = cam:xyOnScreen(self.x, self.y)
  local mx, my = love.mouse.getPosition()
  local dirx, diry = vec.direction(sx, sy, mx, my)

  self.r = vec.angle(dirx, diry)
  self.sy = mx < sx and -1 or 1

  local anchor_offset_x, anchor_offset_y
    = cam:rotateXy(0, my < sy and -1 or 1)

  self.x = self.anchor.x + anchor_offset_x
  self.y = self.anchor.y + anchor_offset_y

  self.cooldown = self.cooldown - dt

  if shoot:isActive() and self.cooldown <= 0 then
    local bdx, bdy = cam:rotateXy(dirx, diry)
    local x = self.x + bdx * self.weapon.barrel_length
    local y = self.y + bdy * self.weapon.barrel_length
    local bullet = Bullet(x, y, 300, bdx, bdy)
    world:add(bullet)

    self.cooldown = self.weapon.cooldown
  end
end

function Gun:draw(x, y)
  lg.setColor(1, 1, 1)
  self.weapon.sprite:draw(x, y - (self.weapon.height or 0), self.r, 1, self.sy)
end
