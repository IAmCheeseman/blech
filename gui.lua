local utf8 = require("utf8")

local font_str = " AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZzÑñ0123456789.,:;!?/\\*[]+-'\""

ui = {}
ui.font = love.graphics.newImageFont("assets/font.png", font_str)
ui.console_font = love.graphics.newFont("assets/nokia.ttf", 8)
