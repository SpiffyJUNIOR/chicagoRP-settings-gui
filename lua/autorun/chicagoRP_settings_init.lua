AddCSLuaFile()

for i, f in pairs(file.Find("chicagoRP_settings/*.lua", "LUA")) do
    if string.Left(f, 3) == "sv_" then
        if SERVER then
            include("chicagoRP_settings/" .. f)
        end
    elseif string.Left(f, 3) == "cl_" then
        if CLIENT then
            include("chicagoRP_settings/" .. f)
        else
            AddCSLuaFile("chicagoRP_settings/" .. f)
        end
    elseif string.Left(f, 3) == "sh_" then
        AddCSLuaFile("chicagoRP_settings/" .. f)
        include("chicagoRP_settings/" .. f)
        print("shared file loaded")
    else
        print("chicagoRP Settings detected unaccounted for lua file '" .. f .. "' - check prefixes!")
    end

    print("chicagoRP Settings successfully loaded!")
end