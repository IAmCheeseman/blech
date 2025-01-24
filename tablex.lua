tablex = {}

function tablex.swapRem(t, i)
  local old = t[i]
  local new = t[#t]

  t[i] = new
  t[#t] = nil

  return old, new
end

function tablex.print(t, i, ts)
  if type(t) ~= "table" then
    return
  end

  i = i or 0
  ts = ts or {}
  if ts[t] or i > 2 then
    io.write("{...}")
    return
  end
  ts[t] = true

  io.write("{\n")
  for k, v in pairs(t) do
    io.write(("\t"):rep(i + 1))
    if type(k) == "string" then
      io.write(k)
    else
      io.write("[" .. tostring(k) .. "]")
    end

    if type(v) == "table" then
      io.write(" = ")
      tablex.print(v, i + 1, ts)
      ts[v] = true
      io.write(", \n")
    elseif type(v) == "string" then
      io.write(" = \"" .. v .. "\",\n")
    else
      io.write(" = " .. tostring(v) .. ",\n")
    end
  end
  io.write(("\t"):rep(i) .. "}")
  if i == 0 then
    io.write("\n")
  end
end
