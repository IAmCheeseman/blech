local utf8 = require("utf8")

local font_str = " AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZzÑñ0123456789.,:;!?/\\*[]+-'\""

ui = {}
ui.font = lg.newImageFont("assets/font.png", font_str)
ui.console_font = lg.newFont(24)--lg.newFont("assets/nokia.ttf", 8)
