util.AddNetworkString("chicagoRP_settings")

hook.Add("PlayerSay", "chicagoRPsettings_PLAYERSAY", function(ply, txt)
    if !IsValid(ply) then return end
    if !ply:Alive() then return end
    local lowerTxt = string.lower(txt)

    if (lowerTxt == "*settings*") then
        ply:EZ_Open_Inventory(ply)

        return ""
    end
end)

function ply:EZ_Open_Inventory(ply)
    net.Start("chicagoRP_settings")
    net.Send(ply)
end

concommand.Add("chicagoRP_settings", function(ply)
    if not (IsValid(ply) and ply:Alive()) then return end
    JMod.EZ_Open_Inventory(ply)
end)