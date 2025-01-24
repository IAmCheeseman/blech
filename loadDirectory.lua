local function loadDirectory(dir, recurse)
  local items = love.filesystem.getDirectoryItems(dir)
  for _, item in ipairs(items) do
    local path = dir .. "/" .. item
    local info = love.filesystem.getInfo(path)
    if info then

      if info.type == "file" then
        if path:match("%.lua$") then
          local require_path = path:gsub("%.lua$", ""):gsub("%/", ".")
          require(require_path)
        end
      elseif info.type == "directory" and recurse then
        loadDirectory(path, recurse)
      end

    end
  end
end

return loadDirectory
