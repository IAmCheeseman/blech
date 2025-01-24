local utf8 = require("utf8")

stringx = {}

function stringx.getLineCount(str)
  local c = 0
  local len = #str
  for i=1, len do
    if str:sub(i, i) == '\n' then
      c = c + 1
    end
  end

  return c
end

