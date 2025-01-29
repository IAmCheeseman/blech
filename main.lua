lg = love.graphics
lmath = love.math

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
require("weapons")

local loadDirectory = require("loadDirectory")
loadDirectory("classes")
loadDirectory("objects")
loadDirectory("weapons")

cam = Camera()
viewport = Viewport(cam)
gui = Viewport()
debug_vp = Viewport()
debug_vp:resize(320 * 4, 240 * 4)
world = World(cam)

walk_up = Action("walk_up", {{method="key", input="w"}})
walk_left = Action("walk_left", {{method="key", input="a"}})
walk_down = Action("walk_down", {{method="key", input="s"}})
walk_right = Action("walk_right", {{method="key", input="d"}})
jump = Action("jump", {{method="key", input="space"}})
shoot = Action("shoot", {{method="mouse", input=1}})
melee = Action("melee", {{method="mouse", input=2}})
rotate_cam_right = Action("rotate_cam_right", {
  {method="key", input="q"},
  {method="mouse", input=5},
})
rotate_cam_left = Action("rotate_cam_left", {
  {method="key", input="e"},
  {method="mouse", input=4},
})

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
local console = Console()

world:add(Path(0, 0))

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
  
  console:update(dt)
end

function love.draw()
  viewport:start()
  lg.clear(0.55, 0.8, 0.5)

  local cx, cy = cam:p3d(cam.x, cam.y)
  lg.push()
  lg.setWireframe(console.wireframe or false)
  lg.translate(
    mathx.floor(-cx + viewport.screenw / 2),
    mathx.floor(-cy + viewport.screenh / 2), 0)
  world:draw()
  lg.pop()
  lg.setWireframe(false)
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

  debug_vp:start()

  lg.clear()

  lg.setColor(1, 1, 1)
  local stats = lg.getStats()
  lg.print(("%d FPS"):format(love.timer.getFPS()), 0, 0)
  lg.print(("%f ms"):format(1 / love.timer.getFPS() * 1000), 0, 24)
  lg.print(("%d drawcalls"):format(stats.drawcalls), 0, 48)

  console:gui()

  debug_vp:stop()

  lg.setColor(1, 1, 1)
  viewport:draw()
  gui:draw()
  debug_vp:draw()
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
  "joystickaxis",
  "joystickhat",
  "joystickpressed",
  "joystickreleased",
  "touchmoved",
  "touchpressed",
  "touchreleased",
}

for _, callback in ipairs(love_callbacks) do
  love[callback] = function(...)
    world:callEvent(callback, ...)
    try(console[callback], console, ...)
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
