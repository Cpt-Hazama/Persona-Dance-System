local folder = "persona_dance/"
local files, _ = file.Find(folder .. "*.lua", "LUA")
for _, luaFile in ipairs(files) do
    local filePath = folder .. luaFile
    if SERVER then
        AddCSLuaFile(filePath)
        include(filePath)
    elseif CLIENT then
        include(filePath)
    end
end