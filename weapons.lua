weapons = {}
weapons.definitions = {}

function weapons.create(name, definition)
  assert(
    not weapons.definitions[name], "weapon '" .. name .. "' already exists.")
  weapons.definitions[name] = definition
end

weapons.create("pistol", {
  obj = Gun,
  sprite = Sprite("assets/pistol.png"):offset(-1, "center"),
  cooldown = 0.2,
  damage = 5,
  height = 5,
  barrel_length = 9,
  name = "weapons.pistol"
})
