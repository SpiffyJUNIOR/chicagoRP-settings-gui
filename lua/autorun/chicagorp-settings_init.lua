AddCSLuaFile()

for i, f in pairs(file.Find("chicagorp-settings/*.lua", "LUA")) do
    if string.Left(f, 3) == "sv_" then
        if SERVER then include("chicagorp-settings/" .. f) end
    elseif string.Left(f, 3) == "cl_" then
        if CLIENT then
            include("chicagorp-settings/" .. f)
        else
            AddCSLuaFile("chicagorp-settings/" .. f)
        end
    elseif string.Left(f, 3) == "sh_" then
        AddCSLuaFile("chicagorp-settings/" .. f)
        include("chicagorp-settings/" .. f)
    else
        print("chicagoRP Settings detected unaccounted for lua file '" .. f .. "' - check prefixes!")
    end
end