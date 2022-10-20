list.Set("DesktopWindows", "chicagoRP Settings", {
    title = "Context Menu Icon",
    icon = "icon64/icon.png",
    init = function(icon, window)
        LocalPlayer():ConCommand("chicagoRP_settings")
    end
})

// wish i didn't have to make three fonts but i think that's a minor sin compared to what other devs do
surface.CreateFont("MichromaSmall", {
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

local HideHUD = false

hook.Add("HUDPaint", "chicagoRP_HideHUD", function()
    if HideHUD then
        return false
    end
end)

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

net.Receive("chicagoRP_settings", function()
    local ply = LocalPlayer()
    local screenwidth = ScrW()
    local screenheight = ScrH()
    local whitetext = (Color(255, 255, 255, 255))
    local redtext = (Color(130, 25, 39, 255))
    local motherFrame = vgui.Create("DFrame")
    motherFrame:SetSize(screenwidth, screenheight)
    motherFrame:SetVisible(true)
    motherFrame:SetDraggable(false)
    motherFrame:ShowCloseButton(false)
    motherFrame:SetTitle("")
    motherFrame:ParentToHUD()
    HideHUD = true

    if IsValid(ArcCW.InvHUD) then
        ArcCW.InvHUD:Remove()
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
    end
    ---

    local exitButton = vgui.Create("DButton", motherFrame)
    exitButton:SetPos(86, 96)
    exitButton:SetSize(80, 20)
    -- exitButton:SetSize(200, 200)
    exitButton:SetFont("MichromaSmall")
    exitButton:SetText("< GAME")
    exitButton:SetTextColor(redtext)

    function exitButton:DoClick()
        motherFrame:Close()
    end

    function exitButton:Paint(w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        -- return nil
    end
    ---

    local settingsTitleLabel = vgui.Create("DLabel", motherFrame)
    settingsTitleLabel:SetPos(101, 119)
    settingsTitleLabel:SetSize(130, 20)
    settingsTitleLabel:SetFont("MichromaRegular")
    settingsTitleLabel:SetText("SETTINGS")
    settingsTitleLabel:SetTextColor(whitetext)

    function settingsTitleLabel:Paint(w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        -- return nil
    end
    ---

    local settingsHelpText = vgui.Create("DLabel", motherFrame)
    settingsHelpText:SetPos(100, 935)
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
    controlHelpText:SetPos(100, 1004)
    controlHelpText:SetSize(160, 30)
    controlHelpText:SetFont("MichromaHelpText")
    controlHelpText:SetText("[ENTER]   SELECT")
    controlHelpText:SetTextColor(redtext)

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
    controlHelpText2:SetTextColor(redtext)

    function controlHelpText2:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end
    ---

    local settingsScrollPanel = vgui.Create("DScrollPanel", motherFrame)
    settingsScrollPanel:SetPos(525, 235)
    settingsScrollPanel:SetSize(820, 635)
    settingsScrollPanel:SetPadding(15)

    function settingsScrollPanel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end

    local settingsScrollBar = settingsScrollPanel:GetVBar() -- mr joe biden please legalize nuclear bombs
    settingsScrollBar:SetHideButtons(true)
    function settingsScrollBar:Paint(w, h)
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
                surface.DrawOutlinedRect(0, 0, w, h, 1) -- 4 x drawtexturedrectuv for gradient
                settingsHelpText:SetText("Love?")
            end
            surface.SetTextColor(whitetext)
            surface.SetTextPos(14, 14)
            surface.SetFont("MichromaRegular")
            surface.DrawText("Button #" .. i)
        end
    end
    -- function surface.DrawOutlinedRect(x, y, w, h) -- drawoutlinedrect example
    --     local old = render2d.bound_texture
    --     render2d.SetTexture()
    --     render2d.DrawRect(x, y, 1, h)
    --     render2d.DrawRect(x, y, w, 1)
    --     render2d.DrawRect(w + x - 1, y, 1, h)
    --     render2d.DrawRect(x, h + y - 1, w, 1)
    --     render2d.bound_texture = old
    -- end
    ---

    local videoSettingsButton = vgui.Create("DButton", motherFrame)
    videoSettingsButton:SetPos(103, 230)
    videoSettingsButton:SetSize(394, 56)
    videoSettingsButton:SetFont("MichromaRegular")
    videoSettingsButton:SetText("")
    videoSettingsButton:SetTextColor(whitetext)

    function videoSettingsButton:Paint(w, h)
        if self:IsHovered() then
            surface.SetDrawColor(34, 34, 34, 100)
            surface.DrawRect(0, 0, w, h)
        end
        surface.SetTextColor(whitetext)
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
            -- button:SetPos(300, 300)
            button.DoClick = function()
                current:Hide()
                v:Show()
                local current = v
            end
        end
    end
end)










