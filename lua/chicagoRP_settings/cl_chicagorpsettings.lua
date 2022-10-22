list.Set("DesktopWindows", "chicagoRP Settings", {
    title = "chicagoRP Settings",
    icon = "icon64/chicagoRP_settings.png",
    init = function(icon, window)
        LocalPlayer():ConCommand("chicagoRP_settings")
    end
})

print("chicagoRP client LUA loaded!")

-- wish i didn't have to make three fonts but i think that's a minor sin compared to what other devs do
surface.CreateFont("MichromaSmall", { -- check to make sure these aren't being created constantly
    font = "Michroma",
    extended = false,
    size = 20,
    weight = 551,
    antialias = true,
    shadow = false
})

surface.CreateFont("MichromaRegular", { -- check to make sure these aren't being created constantly
    font = "Michroma",
    extended = false,
    size = 24,
    weight = 550,
    antialias = true,
    shadow = false
})

surface.CreateFont("MichromaHelpText", { -- check to make sure these aren't being created constantly
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
    local layers, density, alpha = 1, 1, 80
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

local function DrawOutlinedTexturedRect(panel, w, h, material, thickness) -- figure out how to make gradient mat
    if (!IsValid(panel) and !panel:IsVisible()) then return end
    surface.SetMaterial(material)
    surface.DrawTexturedRectUV(0, 0, w, thickness, 0, 0, 1, 0) -- top
    surface.DrawTexturedRectUV(0, h - thickness, w, thickness, 0, 1, 1, 1) -- bottom
    surface.DrawTexturedRectUV(0, 0, thickness, h, 0, 0, 0, 1) -- left
    surface.DrawTexturedRectUV(w - thickness, 0, thickness, h, 0, 0, 0, 1) -- right
end

local HideHUD = false

hook.Add("HUDPaint", "chicagoRP_HideHUD", function() -- we also need to hide hints and easychat
    if HideHUD then
        return false
    end
end)

local gradient_mat = Material("vgui/gradient-u")

local videoSettingsOptions = {
    [1] = {
        convar = "cl_new_impact_effects",
        max = 1,
        min = 0,
        printname = "Fancy Impact Effects (1)"
    },
    [2] = {
        convar = "kill",
        max = 0,
        min = 0,
        printname = "GET GOOD GET LMAOBOX (2)"
    }
}

local OpenDropdown = nil
local primarytext = (Color(255, 255, 255, 255))
local secondarytext = (Color(130, 25, 39, 255))

net.Receive("chicagoRP_settings", function()
    local ply = LocalPlayer()
    local screenwidth = ScrW()
    local screenheight = ScrH()
    local motherFrame = vgui.Create("DFrame")
    motherFrame:SetSize(screenwidth, screenheight)
    motherFrame:SetVisible(true)
    motherFrame:SetDraggable(false)
    motherFrame:ShowCloseButton(false)
    motherFrame:SetTitle("")
    motherFrame:ParentToHUD()
    HideHUD = true

    if IsValid(ArcCW.InvHUD) then -- also add tfa, cw2, and fas2 compatibility please
        ArcCW.InvHUD:Hide()
    end

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

    function motherFrame:OnClose()
        HideHUD = false
        if IsValid(ArcCW.InvHUD) then
            ArcCW.InvHUD:Show()
        end
    end
    ---

    local exitButton = vgui.Create("DButton", motherFrame)
    exitButton:SetPos(86, 96)
    exitButton:SetSize(80, 20)
    -- exitButton:SetSize(200, 200)
    exitButton:SetFont("MichromaSmall")
    exitButton:SetText("< GAME")
    exitButton:SetTextColor(secondarytext)

    function exitButton:DoClick()
        motherFrame:Close()
    end

    function exitButton:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end
    ---

    local settingsTitleLabel = vgui.Create("DLabel", motherFrame)
    settingsTitleLabel:SetPos(101, 119)
    settingsTitleLabel:SetSize(130, 20)
    settingsTitleLabel:SetFont("MichromaRegular")
    settingsTitleLabel:SetText("SETTINGS")
    settingsTitleLabel:SetTextColor(primarytext)

    function settingsTitleLabel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end
    ---

    local settingsHelpText = vgui.Create("DLabel", motherFrame)
    settingsHelpText:SetPos(100, 935)
    settingsHelpText:SetSize(1000, 30)
    settingsHelpText:SetFont("MichromaSmall")
    settingsHelpText:SetText("This should not appear when nothing is highlighted.")
    settingsHelpText:SetTextColor(primarytext)

    function settingsHelpText:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end
    ---

    local controlHelpText = vgui.Create("DLabel", motherFrame)
    controlHelpText:SetPos(100, 1004)
    controlHelpText:SetSize(160, 30)
    controlHelpText:SetFont("MichromaHelpText")
    controlHelpText:SetText("[ENTER]   SELECT")
    controlHelpText:SetTextColor(secondarytext)

    function controlHelpText:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end
    ---

    local controlHelpText2 = vgui.Create("DLabel", motherFrame)
    controlHelpText2:SetPos(285, 1004)
    controlHelpText2:SetSize(115, 30)
    controlHelpText2:SetFont("MichromaHelpText")
    controlHelpText2:SetText("[ESC]   BACK")
    controlHelpText2:SetTextColor(secondarytext)

    function controlHelpText2:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end
    ---

    local settingsScrollPanel = vgui.Create("DScrollPanel", motherFrame)
    settingsScrollPanel:SetPos(525, 235)
    settingsScrollPanel:SetSize(820, 635)

    function settingsScrollPanel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end

    local settingsScrollBar = settingsScrollPanel:GetVBar() -- mr biden please legalize nuclear bombs
    settingsScrollBar:SetHideButtons(true)
    settingsScrollBar:SetPos(525, 235)
    function settingsScrollBar:Paint(w, h) -- we still need to figure out how to separate the scroll bar from the frame
        draw.RoundedBox(0, 0, 0, w, h, Color(43, 39, 35, 66))
    end
    function settingsScrollBar.btnUp:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end
    function settingsScrollBar.btnDown:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end
    function settingsScrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(76, 76, 74))
    end

    for i = 0, 100 do
        local settingsScrollPanelTestButton = settingsScrollPanel:Add("DButton")
        settingsScrollPanelTestButton:SetText("")
        settingsScrollPanelTestButton:Dock(TOP)
        settingsScrollPanelTestButton:DockMargin(0, 0, 0, 5)
        settingsScrollPanelTestButton:SetSize(800, 50)
        function settingsScrollPanelTestButton:Paint(w, h)
            surface.SetDrawColor(40, 40, 40, 100)
            surface.DrawRect(0, 0, w, h)
            if settingsScrollPanelTestButton:IsHovered() then -- gradient start: (255, 86, 65) end: (255, 190, 131)
                surface.SetDrawColor(255, 86, 65)
                DrawOutlinedTexturedRect(self, w, h, gradient_mat, 4)
                settingsHelpText:SetText("Love?")
            end
            surface.SetTextColor(primarytext)
            surface.SetTextPos(14, 14)
            surface.SetFont("MichromaRegular")
            surface.DrawText("Button #" .. i)
        end
        function settingsScrollPanelTestButton:DoClick()
            if IsValid(Dropdown) then
                Dropdown:Remove()
            end

            local Dropdown = vgui.Create("DPanel", motherFrame)
            Dropdown:SetSize(settingsScrollPanelTestButton:GetWide(), 3 * 40)
            Dropdown:SetPos(650, settingsScrollPanelTestButton:LocalToScreen())
            print(settingsScrollPanelTestButton:GetPos())
            print(settingsScrollPanelTestButton:LocalToScreen())

            function Dropdown:Paint(w, h)
                surface.SetDrawColor(70, 70, 70, 220)
                surface.DrawRect(0, 0, w, h)
            end

            OpenDropdown = Dropdown
        end
    end

    local videoSettingsButton = vgui.Create("DButton", motherFrame)
    videoSettingsButton:SetPos(103, 230)
    videoSettingsButton:SetSize(394, 56)
    videoSettingsButton:SetFont("MichromaRegular")
    videoSettingsButton:SetText("")
    videoSettingsButton:SetTextColor(primarytext)

    function videoSettingsButton:Paint(w, h)
        if self:IsHovered() then
            surface.SetDrawColor(34, 34, 34, 100)
            surface.DrawRect(0, 0, w, h)
        end
        surface.SetTextColor(primarytext)
        surface.SetTextPos(w - 383, h - 42)
        surface.SetFont("MichromaRegular")
        surface.DrawText("VIDEO")
    end

    function videoSettingsButton:DoClick()
        -- PrintTable(videoSettingsOptions)
        for k, v in ipairs(videoSettingsOptions) do
            print(v.convar)
            print(v.printname)
            local button = settingsScrollPanel:Add("DButton")
            button:SetText(v.printname)
            button.DoClick = function()
                local current = v
                current:Hide()
                v:Show()
            end
        end
    end
end)










