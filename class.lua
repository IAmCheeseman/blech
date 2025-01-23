local function create(s, ...)
  local inst = setmetatable({}, s)
  try(inst.new, inst, ...)
  return inst
end

local class_mt = {
  __call = create
}

function class()
  local s = setmetatable({}, class_mt)
  s.__index = s
  return s
end
