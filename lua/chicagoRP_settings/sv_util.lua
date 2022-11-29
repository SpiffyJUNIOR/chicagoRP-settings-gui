util.AddNetworkString("chicagoRP_settings")

hook.Add("PlayerSay", "chicagoRPsettings_PLAYERSAY", function(ply, txt)
    if !IsValid(ply) then return end
    local lowerTxt = string.lower(txt)

    if lowerTxt == "*settings*" then
        net.Start("chicagoRP_settings")
        net.Send(ply)

        return ""
    end
end)

concommand.Add("chicagoRP_settings", function(ply)
    if !IsValid(ply) then return end
    net.Start("chicagoRP_settings")
    net.Send(ply)
end)

print("cl_util loaded")