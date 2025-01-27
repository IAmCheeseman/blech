Tree = class()

local shadow = Sprite("assets/tree_shadow.png")
shadow:offset("center", "center")

function Tree:new(x, y)
  self.tags = {"env", "damageable"}
  self.x = x
  self.y = y

  self.hp = 5
  self.skew = 0

  self.sprite = Sprite("assets/tree.ase")
  self.sprite:offset("center", "bottom")
  self.sprite.frame = love.math.random() > 0.9 and 2 or 1

  self.body = PhysicsBody(self, world, shape.offsetCircle(0, 0, 8))
end

function Tree:damage(amount, kbx, kby)
  self.hp = self.hp - amount
  kbx, kby = cam:rotateXy(kbx, kby)
  self.skew = 0.25 * -kbx
  if self.hp <= 0 then
    world:rem(self)
  end
end

function Tree:update(dt)
  self.skew = mathx.dtLerp(self.skew, 0, 5, dt)
end

function Tree:draw(x, y)
  lg.setColor(0, 0, 0, 0.2)
  -- lg.ellipse("fill", x, y + 2, 12, 4)
  shadow:draw(x, y - 4)
  lg.setColor(1, 1, 1)
  self.sprite:draw(x, y + 4, 0, 1, 1, self.skew, 0)
end
