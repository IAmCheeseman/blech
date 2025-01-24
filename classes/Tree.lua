Tree = class()

function Tree:new(x, y)
  self.tags = {"env"}
  self.x = x
  self.y = y

  self.sprite = Sprite("assets/tree.ase")
  self.sprite:offset("center", "bottom")
  self.sprite.frame = love.math.random() > 0.99 and 2 or 1

  self.body = PhysicsBody(self, world, shape.offsetCircle(0, 0, 8))
end

function Tree:draw()
  lg.setColor(0, 0, 0, 0.2)
  lg.ellipse("fill", 0, 2, 12, 4)
  lg.setColor(1, 1, 1)
  self.sprite:draw(0, 5)
end
