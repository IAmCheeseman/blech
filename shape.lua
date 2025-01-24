shape = {}

function shape.rect(w, h)
  return {
    0, 0,
    w, 0,
    w, h,
    0, h,
  }
end

function shape.offsetRect(x, y, w, h)
  return {
    x,   y,
    x+w, y,
    x+w, y+h,
    x,   y+h,
  }
end

local function getSegments(rx, ry, segments)
  if segments then
    return segments
  end

  local per = 2 * math.pi * math.sqrt((rx^2 + ry^2) / 2)
  return math.max(8, math.floor(per / 16)) -- do a segment every 8 pixels
end

function shape.circle(r, segments)
  segments = getSegments(r, r, segments)
  local inc = mathx.tau / segments

  local p = {}

  for i=1, segments do
    table.insert(p, math.cos(i*inc) * r)
    table.insert(p, math.sin(i*inc) * r)
  end

  return p
end

function shape.offsetCircle(x, y, r, segments)
  segments = getSegments(r, r, segments)
  local inc = mathx.tau / segments

  local p = {}

  for i=1, segments do
    table.insert(p, x + math.cos(i*inc) * r)
    table.insert(p, y + math.sin(i*inc) * r)
  end

  return p
end

function shape.ellipse(rx, ry, segments)
  segments = getSegments(rx, ry, segments)
  local inc = mathx.tau / segments

  local p = {}

  for i=1, segments do
    table.insert(p, math.cos(i*inc) * rx)
    table.insert(p, math.sin(i*inc) * ry)
  end

  return p
end

function shape.offsetEllipse(x, y, rx, ry, segments)
  segments = getSegments(rx, ry, segments)
  local inc = mathx.tau / segments

  local p = {}

  for i=1, segments do
    table.insert(p, x + math.cos(i*inc) * rx)
    table.insert(p, y + math.sin(i*inc) * ry)
  end

  return p
end
