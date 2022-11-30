AddCSLuaFile()

for i, f in pairs(file.Find("chicagorp_settings/*.lua", "LUA")) do
    if string.Left(f, 3) == "sv_" then
        if SERVER then
            include("chicagorp_settings/" .. f)
        end
    elseif string.Left(f, 3) == "cl_" then
        if CLIENT then
            include("chicagorp_settings/" .. f)
        else
            AddCSLuaFile("chicagorp_settings/" .. f)
        end
    elseif string.Left(f, 3) == "sh_" then
        AddCSLuaFile("chicagorp_settings/" .. f)
        include("chicagorp_settings/" .. f)
        print("shared file loaded")
    else
        print("chicagoRP Settings detected unaccounted for lua file '" .. f .. "' - check prefixes!")
    end

    print("chicagoRP Settings successfully loaded!")
end