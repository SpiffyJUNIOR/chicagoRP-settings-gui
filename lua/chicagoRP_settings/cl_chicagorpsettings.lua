list.Set("DesktopWindows", "chicagoRP Settings", {
    title = "Context Menu Icon",
    icon = "icon64/icon.png",
    init = function(icon, window)
        LocalPlayer():ConCommand("chicagoRP_settings")
    end
})

surface.CreateFont("MichromaSmall", { -- wish i didn't have to make three fonts but i think that's a minor sin compared to what other devs do
    font = "Michroma",
    extended = false,
    size = 20,
    weight = 551,
    antialias = true,
    shadow = false
})

surface.CreateFont("MichromaRegular", {
    font = "Michroma",
    extended = false,
    size = 24,
    weight = 550,
    antialias = true,
    shadow = false
})

surface.CreateFont("MichromaHelpText", {
    font = "Michroma",
    extended = false,
    size = 18,
    weight = 550,
    antialias = true,
    shadow = false
})

local blurMat = Material("pp/blurscreen")
local Dynamic = 0

local function BlurBackground(panel)
    if (!IsValid(panel) and !panel:IsVisible()) then return end
    local layers, density, alpha = 1, 1, 255
    local x, y = panel:LocalToScreen(0, 0)
    surface.SetDrawColor(255, 255, 255, alpha)
    surface.SetMaterial(blurMat)
    local FrameRate, Num, Dark = 1 / RealFrameTime(), 5, 150

    for i = 1, Num do
        blurMat:SetFloat("$blur", (i / layers) * density * Dynamic)
        blurMat:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
    end

    surface.SetDrawColor(0, 0, 0, Dark * Dynamic)
    surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
    Dynamic = math.Clamp(Dynamic + (1 / FrameRate) * 7, 0, 1)
end

net.Receive("chicagoRP_settings", function()
    local ply = LocalPlayer()
    local motherFrame = vgui.Create("DFrame")
    local screenwidth = ScrW()
    local screenheight = ScrH()
    local whitetext = (Color(255, 255, 255, 255))
    local redtext = (Color(130, 25, 39, 255))
    motherFrame:SetSize(screenwidth, screenheight)
    motherFrame:SetVisible(true)
    motherFrame:SetDraggable(false)
    motherFrame:ShowCloseButton(false)
    motherFrame:SetTitle("")
    motherFrame:ParentToHUD()

    function motherFrame:Paint(w, h)
        BlurBackground(self)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 10))
    end

    motherFrame:MakePopup()
    motherFrame:Center()

    function motherFrame:OnKeyCodePressed(key)
        if key == KEY_ESCAPE or key == KEY_Q then
            self:Close()
        end
    end

    ---
    local exitButton = vgui.Create("DButton", motherFrame)
    exitButton:SetPos(100, 94)
    exitButton:SetSize(80, 20)
    -- exitButton:SetSize(200, 200)
    exitButton:SetFont("MichromaSmall")
    exitButton:SetText("< GAME")
    exitButton:SetTextColor(redtext)

    function exitButton:DoClick()
        motherFrame:Close()
    end

    function exitButton:Paint(w, h)
        return nil
    end
    ---

    local settingsTitleLabel = vgui.Create("DLabel", motherFrame)
    settingsTitleLabel:SetPos(114, 96)
    settingsTitleLabel:SetSize(150, 50)
    settingsTitleLabel:SetFont("MichromaRegular")
    settingsTitleLabel:SetText("SETTINGS")
    settingsTitleLabel:SetTextColor(whitetext)

    function settingsTitleLabel:Paint(w, h)
        return nil
    end
    ---

    local settingsHelpText = vgui.Create("DLabel", motherFrame)
    settingsHelpText:SetPos(114, 915)
    settingsHelpText:SetSize(1000, 30)
    settingsHelpText:SetFont("MichromaSmall")
    settingsHelpText:SetText("This should not appear when nothing is highlighted.")
    settingsHelpText:SetTextColor(whitetext)

    function settingsHelpText:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end
    ---

    local controlHelpText = vgui.Create("DLabel", motherFrame)
    controlHelpText:SetPos(114, 970)
    controlHelpText:SetSize(170, 30)
    controlHelpText:SetFont("MichromaHelpText")
    controlHelpText:SetText("[ENTER]   SELECT")
    controlHelpText:SetTextColor(redtext)

    function controlHelpText:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end
    ---

    local controlHelpText2 = vgui.Create("DLabel", motherFrame)
    controlHelpText2:SetPos(300, 970)
    controlHelpText2:SetSize(170, 30)
    controlHelpText2:SetFont("MichromaHelpText")
    controlHelpText2:SetText("[ESC]   BACK")
    controlHelpText2:SetTextColor(redtext)

    function controlHelpText2:Paint(w, h)
        return nil
    end
    ---

    local VideoCategory = vgui.Create("DCategoryList", motherFrame)
    VideoCategory:SetPos(114, 400)

    -- The contents can be any panel, even a DPanelList
    local VideoCategoryButton = VideoCategory:Add("Test category with panel contents")
    VideoCategoryButton:SetTall(100)

    local NewImpactEffects = vgui.Create("DCheckBox")
    NewImpactEffects:SetText("Fancy Impact Effects")
    NewImpactEffects:SetPos(314, 300)
    NewImpactEffects:SetValue(true)
    VideoCategoryButton:SetContents(NewImpactEffects)

    VideoCategory:InvalidateLayout(true)
end)















