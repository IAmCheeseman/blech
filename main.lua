love.graphics.setLineStyle("rough")
love.graphics.setDefaultFilter("nearest", "nearest")

require("util")
require("mathx")
require("tablex")
require("vec")
require("class")
require("shape")

local loadDirectory = require("loadDirectory")
loadDirectory("classes")
loadDirectory("objects")

cam = Camera()
viewport = Viewport(cam)
gui = Viewport()
world = World(cam)

local north_cam_angle = 0

local tree_sprite = Sprite("assets/tree.ase")
tree_sprite:offset("center", "bottom")

local drawTree = function(self)
  love.graphics.setColor(0, 0, 0, 0.2)
  love.graphics.ellipse("fill", 0, -3, 12, 4)
  love.graphics.setColor(1, 1, 1)
  tree_sprite.frame = self.frame
  tree_sprite:draw(0, 0)
end

for _=1, 100 do
  local x = love.math.random(-500, 500)
  local y = love.math.random(-500, 500)
  local obj = {
    tags = {"env"},
    x = x,
    y = y,
    frame = love.math.random() > 0.99 and 2 or 1,
    draw = drawTree,
  }

  obj.body = PhysicsBody(obj, world, shape.offsetRect(-8, -8, 16, 16))
  world:add(obj)
end

world:add(Enemy(64, 10))

world:add(Player(0, 0))
world:add(Cursor())

function love.update(dt)
  cam:update(dt)
  world:update(dt)

end

function love.wheelmoved(_, y)
  local m = y > 0 and 1 or -1
  cam.target_r = cam.target_r + mathx.rad(5) * m
end

function love.keypressed(key, _, _)
  if key == "e" then
    cam.target_r = cam.target_r + mathx.pi / 4
  end
  if key == "q" then
    cam.target_r = cam.target_r - mathx.pi / 4
  end
end

function love.mousepressed(_, _, button)
  if button == 5 then
    cam.target_r = cam.target_r + mathx.pi / 4
  elseif button == 4 then
    cam.target_r = cam.target_r - mathx.pi / 4
  end
end

function love.draw()
  viewport:start()
  love.graphics.clear(0.55, 0.8, 0.5)

  local cx, cy = cam:p3d(cam.x, cam.y)
  love.graphics.push()
  love.graphics.translate(
    mathx.floor(-cx + viewport.screenw / 2),
    mathx.floor(-cy + viewport.screenh / 2), 0)
  world:draw()
  love.graphics.pop()
  viewport:stop()

  gui:start()

  love.graphics.clear(0, 0, 0, 0)
  world:gui()

  do -- compass
    local w = viewport.screenw
    local compass_r = 8
    local padding = 4
    local dx, dy = w - compass_r - padding, compass_r + padding
    local cam_r = cam.r - math.pi / 2

    love.graphics.setLineStyle("rough")
    love.graphics.setLineWidth(1)
    love.graphics.circle("line", dx, dy, compass_r)

    love.graphics.setLineWidth(2)
    love.graphics.line(
      dx, dy,
      mathx.round(dx + math.cos(cam_r) * compass_r),
      mathx.round(dy + math.sin(cam_r) * compass_r))
  end

  gui:stop()

  love.graphics.setColor(1, 1, 1)
  viewport:draw()
  gui:draw()

  love.graphics.setColor(1, 1, 1)
  love.graphics.print(("%d FPS"):format(love.timer.getFPS()), 0, 0)
  love.graphics.print(("%f ms"):format(1 / love.timer.getFPS() * 1000), 0, 12)
end
