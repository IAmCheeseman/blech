lg = love.graphics

love.keyboard.setKeyRepeat(true)
lg.setLineStyle("rough")
lg.setDefaultFilter("nearest", "nearest")

require("util")
require("mathx")
require("tablex")
require("stringx")
require("vec")
require("class")
require("shape")
require("gui")

local loadDirectory = require("loadDirectory")
loadDirectory("classes")
loadDirectory("objects")

cam = Camera()
viewport = Viewport(cam)
gui = Viewport()
world = World(cam)

walk_up = Action():addInput("key", "w")
walk_left = Action():addInput("key", "a")
walk_down = Action():addInput("key", "s")
walk_right = Action():addInput("key", "d")
jump = Action():addInput("key", "space")
shoot = Action():addInput("mouse", 1)
rotate_cam_right = Action()
  :addInput("key", "q")
  :addInput("mouse", 5)
rotate_cam_left = Action()
  :addInput("key", "e")
  :addInput("mouse", 4)

for _=1, 100 do
  local x = love.math.random(-500, 500)
  local y = love.math.random(-500, 500)
  world:add(Tree(x, y))
end

for _=1, 10 do
  world:add(Enemy(100, 0))
end

world:add(Player(0, 0))
world:add(Cursor())
world:add(Console())

function love.update(dt)
  actions.update()
  cam:update(dt)
  world:update(dt)

  if rotate_cam_left:isJustActive() then
    cam.target_r = cam.target_r + mathx.pi / 4
  end
  if rotate_cam_right:isJustActive() then
    cam.target_r = cam.target_r - mathx.pi / 4
  end
end

function love.draw()
  viewport:start()
  lg.clear(0.55, 0.8, 0.5)

  local cx, cy = cam:p3d(cam.x, cam.y)
  lg.push()
  lg.translate(
    mathx.floor(-cx + viewport.screenw / 2),
    mathx.floor(-cy + viewport.screenh / 2), 0)
  world:draw()
  lg.pop()
  viewport:stop()

  gui:start()

  lg.clear(0, 0, 0, 0)
  world:gui()

  do -- compass
    local w = gui.screenw
    local compass_r = 8
    local padding = 4
    local dx, dy = w - compass_r - padding, compass_r + padding
    local cam_r = cam.r - math.pi / 2

    lg.setLineStyle("rough")
    lg.setLineWidth(1)
    lg.circle("line", dx, dy, compass_r)

    lg.setLineWidth(2)
    lg.line(
      dx, dy,
      mathx.round(dx + math.cos(cam_r) * compass_r),
      mathx.round(dy + math.sin(cam_r) * compass_r))
  end

  gui:stop()

  lg.setColor(1, 1, 1)
  viewport:draw()
  gui:draw()

  lg.setColor(1, 1, 1)
  lg.print(("%d FPS"):format(love.timer.getFPS()), 0, 0)
  lg.print(("%f ms"):format(1 / love.timer.getFPS() * 1000), 0, 12)
end

local love_callbacks = {
  "directorydropped",
  "displayrotated",
  "filedropped",
  "focus",
  "mousefocus",
  "resize",
  "visible",
  "keypressed",
  "keyreleased",
  "textedited",
  "textinput",
  "mousemoved",
  "mousepressed",
  "mousereleased",
  "wheelmoved",
  "gamepadaxis",
  "gamepadpressed",
  "gamepadreleased",
  "joystickadded",
  "joystickaxis",
  "joystickhat",
  "joystickpressed",
  "joystickreleased",
  "joystickremoved",
  "touchmoved",
  "touchpressed",
  "touchreleased",
}

for _, callback in ipairs(love_callbacks) do
  love[callback] = function(...)
    world:callEvent(callback, ...)
  end
end

-- These functions need special handling, so they're implemented manually
function love.joystickadded(joystick)
  actions.joystickadded(joystick)
  world:callEvent("joystickadded", joystick)
end

function love.joystickremoved(joystick)
  actions.joystickremoved(joystick)
  world:callEvent("joystickremoved", joystick)
end
