local utf8 = require("utf8")

console = {}

function console.clear()
  local console = world:getSingleton("console")
  console.log = {}
end

function console.log(...)
  local console = world:getSingleton("console")
  local text = {...}
  local msg = ""
  for i, str in ipairs(text) do
    msg = msg .. tostring(str)
    if i ~= #text then
      msg = msg .. "\t"
    end
  end

  console:logText(1, 1, 1, 1, msg)
end

Console = class()

function Console:new()
  self.tags = {"textinput", "keypressed", "console"}

  self.text = ""
  self.log = {}
  self.cursor_blink = 0
  self.is_open = false
end

function Console:update(dt)
  self.cursor_blink = self.cursor_blink + dt
  if self.cursor_blink > 1 then
    self.cursor_blink = self.cursor_blink - 1
  end
end

function Console:textinput(text)
  if self.is_open and text ~= "`" then
    self.text = self.text .. text
  end
end

function Console:logText(r, g, b, a, text)
  table.insert(self.log, {r, g, b, a})
  table.insert(self.log, text .. "\n")

  if #self.log > 30 then
    table.remove(self.log, 1)
    table.remove(self.log, 1)
  end
end

function Console:keypressed(key, _, _)
  if key == "`" then
    self.is_open = not self.is_open
  end

  if not self.is_open then
    return
  end

  if key == "backspace" then
    local byte_offset = utf8.offset(self.text, -1)

    if byte_offset then
      self.text = self.text:sub(1, byte_offset - 1)
    end
  elseif key == "return" then
    if #self.text:gsub("%s", "") == 0 then
      return
    end
    local chunk, compile_error = loadstring(self.text)

    self:logText(0.7, 0.7, 0.7, 1, "> " .. self.text)
    self.text = ""

    if not chunk then
      self:logText(1, 0, 0, 1, compile_error)
      return
    end

    local ok, runtime_error = pcall(chunk)
    if not ok then
      self:logText(1, 0, 0, 1, runtime_error)
    end
  end
end

function Console:gui()
  if not self.is_open then
    return
  end

  local font = ui.console_font

  local w, h = viewport.screenw, viewport.screenh
  local x, y = 8, h - font:getHeight()

  local max_w = w - x
  local w_diff = math.min(0, max_w - font:getWidth(self.text))
  x = x + w_diff

  -- Textinput background
  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.rectangle("fill", 0, 0, w, h)
  love.graphics.rectangle("fill", 0, y, w, font:getHeight())

  -- Textinput text
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(font)
  love.graphics.print(self.text, x, y)

  -- Textinput prompt
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.print(">", 1 + w_diff, y)

  -- Textinput cursor
  if self.cursor_blink > 0.5 then
    local cursor_x = x + font:getWidth(self.text)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(1)
    love.graphics.line(cursor_x, y, cursor_x, y + font:getHeight())
  end

  -- Log
  local log_font = ui.console_font
  local _, wrapped_log = log_font:getWrap(self.log, w)
  local log_h = (#wrapped_log - 1) * log_font:getHeight()

  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(log_font)
  love.graphics.printf(self.log, 0, y - log_h, w, "left")
end
