function try(fn, ...)
  if type(fn) == "function" then
    return true, fn(...)
  end
  return false
end

function is(val, type_name)
  return type(val) == type_name
end
