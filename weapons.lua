weapons = {}
weapons.definitions = {}

function weapons.create(name, definition)
  assert(
    not weapons.definitions[name], "weapon '" .. name .. "' already exists.")
  weapons.definitions[name] = definition
end
