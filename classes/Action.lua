local settings = require("settings")

actions = {}

actions.joystick_deadzone = 0.5
actions.using_joystick = false
actions.joysticks = love.joystick.getJoysticks()
actions.defined = {}

function actions.joystickadded(_)
  actions.joysticks = love.joystick.getJoysticks()
end

function actions.joystickremoved(_)
  actions.joysticks = love.joystick.getJoysticks()
end

function actions.update()
  for action, _ in pairs(actions.defined) do
    if not is(action, "string") then
      action:update()
    end
  end
end

Action = class()

function Action:new(action_name, inputs)
  self.action_name = action_name
  self.inputs = settings.keybinds[action_name] or inputs
  self.active = false
  self.just_active = false

  actions.defined[self] = true
  actions.defined[action_name] = self
end

function Action:update()
  self.just_active = false

  if self:isActive() then
    if not self.active then
      self.just_active = true
    end
    self.active = true
  else
    self.active = false
  end
end

function Action:isJustActive()
  return self.just_active
end

function Action:isActive()
  for _, input_opt in ipairs(self.inputs) do
    if input_opt.method == "key" then
      local down = love.keyboard.isDown(input_opt.input)
      if down then
        actions.using_joystick = false
        return true
      end
    elseif input_opt.method == "mouse" then
      local down = love.mouse.isDown(input_opt.input)
      if down then
        actions.using_joystick = false
        return true
      end
    elseif input_opt.method == "gamepad_button" then
      for _, js in actions.joysticks do
        local down = js:isgamepaddown(input_opt.input)
        if down then
          actions.using_joystick = true
          return true
        end
      end

    elseif input_opt.method == "gamepad_button" then
      for _, js in actions.joysticks do
        local axis = js:getGamepadAxis(input_opt.input.axis)
        local down = false
        if math.abs(axis) > actions.joystick_deadzone then
          if input_opt.input.dir > 0 then
            down = axis > 0
          else
            down = axis < 0
          end
        end

        if down then
          actions.using_joystick = true
          return true
        end
      end

    end
  end

  return false
end
