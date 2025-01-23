mathx = {}

for k, v in pairs(math) do
  mathx[k] = v
end

mathx.tau = mathx.pi * 2

function mathx.round(x)
  return mathx.floor(x + 0.5)
end

function mathx.lerp(x, y, d)
  return (y - x) * d + x
end

function mathx.dtLerp(x, y, d, dt)
  return (x - y) * 0.5^(dt * d) + y
end

function mathx.fRandom(min, max)
  local r = love.math.random()
  return r * (max - min) + min
end

function mathx.snap(a, s)
  return mathx.floor(a / s) * s
end

function mathx.sign(a)
  if a == 0 then
    return 0
  end

  return a < 0 and -1 or 1
end
