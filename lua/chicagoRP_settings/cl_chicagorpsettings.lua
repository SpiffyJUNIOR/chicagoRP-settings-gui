list.Set("DesktopWindows", "chicagoRP Settings", {
    title = "chicagoRP Settings",
    icon = "icon64/chicagoRP_settings.png",
    init = function(icon, window)
        LocalPlayer():ConCommand("chicagoRP_settings")
    end
})

CreateClientConVar("chicagoRP_primary_r", 255, true, false, "Changes the (R) color value for the settings GUI's primary text.", 1, 255)
CreateClientConVar("chicagoRP_primary_g", 255, true, false, "Changes the (G) color value for the settings GUI's primary text.", 1, 255)
CreateClientConVar("chicagoRP_primary_b", 255, true, false, "Changes the (B) color value for the settings GUI's primary text.", 1, 255)
CreateClientConVar("chicagoRP_secondary_r", 130, true, false, "Changes the (R) color value for the settings GUI's secondary text.", 1, 255)
CreateClientConVar("chicagoRP_secondary_g", 25, true, false, "Changes the (G) color value for the settings GUI's secondary text.", 1, 255)
CreateClientConVar("chicagoRP_secondary_b", 40, true, false, "Changes the (B) color value for the settings GUI's secondary text.", 1, 255)

local CVarPrimaryRed = GetConVar("chicagoRP_primary_r"):GetInt()
local CVarPrimaryGreen = GetConVar("chicagoRP_primary_g"):GetInt()
local CVarPrimaryBlue = GetConVar("chicagoRP_primary_b"):GetInt()
local CVarSecondaryRed = GetConVar("chicagoRP_secondary_r"):GetInt()
local CVarSecondaryGreen = GetConVar("chicagoRP_secondary_g"):GetInt()
local CVarSecondaryBlue = GetConVar("chicagoRP_secondary_b"):GetInt()

print("chicagoRP client LUA loaded!")

-- wish i didn't have to make three fonts but i think that's a minor sin in the face of what other devs do
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
local gradient_mat = Material("vgui/gradient-u") -- gradient-d, gradient-r, gradient-u, gradient_down, gradient_up
local HideHUD = false
local OpenMotherFrame = nil
local OpenPanel = nil
local Dynamic = 0
local primarytext = (Color(CVarPrimaryRed, CVarPrimaryGreen, CVarPrimaryBlue, 255))
local secondarytext = (Color(CVarSecondaryRed, CVarSecondaryGreen, CVarSecondaryBlue, 255))
local LoadedSounds = {}

local function NonDSPPlaySound(FileName)
    local sound
    local filter
    if !LoadedSounds[FileName] then
        -- The sound is always re-created serverside because of the RecipientFilter.
        sound = CreateSound(game.GetWorld(), FileName, filter) -- create the new sound, parented to the worldspawn (which always exists)
        if sound then
            sound:SetDSP(0, true)
            sound:SetSoundLevel(0) -- play everywhere
            LoadedSounds[FileName] = {sound, filter} -- cache the CSoundPatch
        end
    else
        sound = LoadedSounds[FileName][1]
        filter = LoadedSounds[FileName][2]
    end
    if sound then
        sound:Stop() -- it won't play again otherwise
        sound:Play()
    end
    return sound -- useful if you want to stop the sound yourself
end

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

local function DrawOutlinedTexturedRect(panel, material, thickness) -- figure out how to make gradient mat
    if (!IsValid(panel) and !panel:IsVisible()) then return end
    local w, h = panel:GetSize()
    surface.SetMaterial(material)
    surface.DrawTexturedRectUV(0, 0, w, thickness, 0, 0, 1, 0) -- top
    surface.DrawTexturedRectUV(0, h - thickness, w, thickness, 0, 1, 1, 1) -- bottom
    surface.DrawTexturedRectUV(0, 0, thickness, h, 0, 0, 0, 1) -- left
    surface.DrawTexturedRectUV(w - thickness, 0, thickness, h, 0, 0, 0, 1) -- right
end

local function CreateSettingsButton(printname, convar, min, max, helptext, parent, helptextparent)
    if (GetConVar(convar):GetInt() == 0 or GetConVar(convar):GetInt() == 1) and (max == 1) and ConVarExists(convar) then
        local settingsButton = parent:Add("DButton")
        settingsButton:SetText("")
        settingsButton:Dock(TOP)
        settingsButton:DockMargin(0, 0, 3, 4)
        settingsButton:SetSize(1340, 50)

        function settingsButton:OnCursorEntered()
            if self:IsHovered() then
                surface.PlaySound("chicagoRP_settings/hover.wav")
            end
        end

        function settingsButton:Paint(w, h)
            surface.SetDrawColor(40, 40, 40, 80)
            surface.DrawRect(0, 0, w, h)
            if settingsButton:IsHovered() then -- gradient start: (255, 86, 65) end: (255, 190, 131)
                surface.SetDrawColor(80, 80, 80, 20)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(255, 86, 65)
                DrawOutlinedTexturedRect(self, gradient_mat, 3)
                helptextparent:SetText(helptext)
            end
            if (GetConVar(convar):GetInt() == 0) and (max == 1) then
                surface.SetDrawColor(primarytext:Unpack())
                surface.DrawOutlinedRect(1300, 14, 22, 22, 2)
            elseif (GetConVar(convar):GetInt() == 1) and (max == 1) then
                surface.SetDrawColor(primarytext:Unpack())
                draw.RoundedBox(4, 1305, 19, 12, 12, primarytext)
                surface.DrawOutlinedRect(1300, 14, 22, 22, 2)
            elseif (GetConVar(convar):GetInt() >= 0) and (max > 1) then
                local statusString = GetConVar(convar):GetInt()
                draw.DrawText(statusString, "MichromaRegular", 790, 12, primarytext, TEXT_ALIGN_RIGHT)
            end
            draw.DrawText(printname, "MichromaRegular", 14, 12, primarytext, TEXT_ALIGN_LEFT)
        end

        function settingsButton:DoClick()
            if (GetConVar(convar):GetInt() == 0) then -- add float check pls
                RunConsoleCommand(convar, "1")
                surface.PlaySound("chicagoRP_settings/select.wav")
            elseif (GetConVar(convar):GetInt() == 1) then -- add float check pls
                RunConsoleCommand(convar, "0")
                surface.PlaySound("chicagoRP_settings/select.wav")
            end
        end
    elseif (GetConVar(convar):GetInt() >= 0 or GetConVar(convar):GetInt() <= 0) and (max > 1) and ConVarExists(convar) then
        local settingsSliderParent = parent:Add("DButton")
        settingsSliderParent:SetText("")
        settingsSliderParent:Dock(TOP)
        settingsSliderParent:DockMargin(0, 0, 3, 4)
        settingsSliderParent:SetSize(1340, 50)

        function settingsSliderParent:Paint(w, h)
            surface.SetDrawColor(40, 40, 40, 80)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(255, 86, 65)
            draw.DrawText(printname, "MichromaRegular", 14, 12, primarytext, TEXT_ALIGN_LEFT)
            if self:IsHovered() or self:IsChildHovered() then
                DrawOutlinedTexturedRect(self, gradient_mat, 3)
                surface.SetDrawColor(80, 80, 80, 20)
                surface.DrawRect(0, 0, w, h)
            end
            -- return nil
        end

        local settingsSlider = vgui.Create("DNumSlider", settingsSliderParent)
        settingsSlider:SetText("")
        settingsSlider:SetSize(335, 50)
        settingsSlider:SetPos(1007, 0)
        settingsSlider:SetMin(min)
        settingsSlider:SetMax(max)
        settingsSlider:SetDecimals(0)
        settingsSlider:SetValue(GetConVar(convar):GetInt())
        settingsSlider:SetConVar(convar)
        settingsSlider.Scratch:Hide() -- based? retarded? you decide!
        settingsSlider.Label:Hide()
        settingsSlider.TextArea:Hide()
        settingsSlider.Slider:SetCursor("hand")

        function settingsSlider:Paint(w, h)
            return nil
        end

        function settingsSlider.Slider:Paint(w, h) -- 335, 44
            surface.SetDrawColor(80, 80, 80, 55)
            surface.DrawRect(0, 0, settingsSlider.Slider:GetSlideX() * w, h)
            surface.SetDrawColor(80, 80, 80, 20)
            surface.DrawRect(0, 0, w, h)
            print(settingsSlider.Slider:GetSlideX())
            draw.DrawText(GetConVar(convar):GetInt(), "MichromaRegular", 325, 13, primarytext, TEXT_ALIGN_RIGHT)
        end

        function settingsSlider.Slider.Knob:Paint(w, h)
            return nil
        end

        function settingsSlider.Slider:OnCursorEntered()
            if self:IsHovered() then
                surface.PlaySound("chicagoRP_settings/hover.wav")
            end
        end

        function settingsSliderParent:OnCursorEntered()
            if self:IsHovered() then
                surface.PlaySound("chicagoRP_settings/hover.wav")
            end
        end

        function settingsSlider:OnValueChanged(value)
            self:SetValue(math.Round(value, 0))
            local hoverslide = CreateSound(game.GetWorld(), "chicagoRP_settings/hover_slide.wav", 0) -- create the new sound, parented to the worldspawn (which always exists)
            hoverslide:SetSoundLevel(0) -- play everywhere
            hoverslide:Stop()
            hoverslide:Play()
        end
    end
end

local function CreateControlsButton(bind, printname, helptext, parent, helptextparent)
    local controlsButton = parent:Add("DButton")
    controlsButton:SetText("")
    controlsButton:Dock(TOP)
    controlsButton:DockMargin(0, 0, 3, 4)
    controlsButton:SetSize(800, 44)

    function controlsButton:OnCursorEntered()
        if self:IsHovered() then
            surface.PlaySound("chicagoRP_controls/hover.wav")
        end
    end

    function controlsButton:Paint(w, h)
        local statusString = "Unbound"
        surface.SetDrawColor(40, 40, 40, 80)
        surface.DrawRect(0, 0, w, h)
        if controlsButton:IsHovered() then -- gradient start: (255, 86, 65) end: (255, 190, 131)
            surface.SetDrawColor(80, 80, 80, 20)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(255, 86, 65)
            DrawOutlinedTexturedRect(self, gradient_mat, 3)
            helptextparent:SetText(helptext)
        end
        if input.LookupBinding(bind, false) then
            statusString = string.upper(input.LookupBinding(bind, false))
            draw.DrawText(statusString, "MichromaRegular", 1320, 10, primarytext, TEXT_ALIGN_RIGHT)
        end
        draw.DrawText(printname, "MichromaRegular", 14, 10, primarytext, TEXT_ALIGN_LEFT)
    end

    function controlsButton:DoClick()
        surface.PlaySound("chicagoRP_controls/select.wav")
        print(self:GetSize())
    end
end

hook.Add("HUDPaint", "chicagoRP_HideHUD", function()
    if HideHUD then
        return false
    end
end)

net.Receive("chicagoRP_settings", function()
    if IsValid(OpenMotherFrame) then return end
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
    motherFrame:SetKeyboardInputEnabled(true)
    HideHUD = true

    print(primarytext)
    print(secondarytext)

    if IsValid(ArcCW.InvHUD) then
        ArcCW.InvHUD:Hide()
    end

    function motherFrame:Paint(w, h)
        BlurBackground(self)
        -- local color = Color(0, 0, 0, Lerp(RealFrameTime(), 0, 10))
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 0))
    end

    motherFrame:SetAlpha(0)
    motherFrame:AlphaTo(255, 0.2, 0)

    motherFrame:MakePopup()
    motherFrame:Center()

    timer.Simple(0.2, function()
        ply:SetDSP(30, false)
    end)

    surface.PlaySound("chicagoRP_settings/back.wav")

    function motherFrame:OnKeyCodePressed(key)
        if key == KEY_ESCAPE or key == KEY_Q then
            self:AlphaTo(50, 0.1, 0)
            surface.PlaySound("chicagoRP_settings/back.wav")
            timer.Simple(0.1, function()
                self:Close()
            end)
        end
    end

    function motherFrame:OnClose()
        HideHUD = false
        if IsValid(ArcCW.InvHUD) then
            ArcCW.InvHUD:Show()
        end
        ply:SetDSP(0, false)
    end
    ---

    local exitButton = vgui.Create("DButton", motherFrame)
    exitButton:SetPos(86, 96)
    exitButton:SetSize(80, 20)
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
    controlHelpText:SetPos(100, 984)
    controlHelpText:SetSize(160, 30)
    controlHelpText:SetFont("MichromaHelpText")
    controlHelpText:SetText("[Q]   BACK")
    controlHelpText:SetTextColor(secondarytext)

    function controlHelpText:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end
    ---

    local videoSettingsScrollPanel = vgui.Create("DScrollPanel", motherFrame)
    videoSettingsScrollPanel:SetPos(525, 235)
    videoSettingsScrollPanel:SetSize(1360, 635)
    videoSettingsScrollPanel:Hide()

    function videoSettingsScrollPanel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end

    local videoSettingsScrollBar = videoSettingsScrollPanel:GetVBar() -- mr biden please legalize nuclear bombs
    videoSettingsScrollBar:SetHideButtons(true)
    videoSettingsScrollBar:SetPos(525, 235)
    function videoSettingsScrollBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(43, 39, 35, 66))
    end
    function videoSettingsScrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(76, 76, 74, 150))
    end

    for k, v in ipairs(chicagoRPvideoSettingsOptions) do
        CreateSettingsButton(v.printname, v.convar, v.min, v.max, v.text, videoSettingsScrollPanel, settingsHelpText)
    end
    ---

    local gameSettingsScrollPanel = vgui.Create("DScrollPanel", motherFrame)
    gameSettingsScrollPanel:SetPos(525, 235)
    gameSettingsScrollPanel:SetSize(1360, 635)
    gameSettingsScrollPanel:Hide()

    function gameSettingsScrollPanel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end

    local gameSettingsScrollBar = gameSettingsScrollPanel:GetVBar() -- mr biden please legalize nuclear bombs
    gameSettingsScrollBar:SetHideButtons(true)
    gameSettingsScrollBar:SetPos(525, 235)
    function gameSettingsScrollBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(43, 39, 35, 66))
    end
    function gameSettingsScrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(76, 76, 74, 150))
    end

    for k, v in ipairs(chicagoRPgameSettingsOptions) do
        CreateSettingsButton(v.printname, v.convar, v.min, v.max, v.text, gameSettingsScrollPanel, settingsHelpText)
    end
    ---

    local controlsSettingsScrollPanel = vgui.Create("DScrollPanel", motherFrame)
    controlsSettingsScrollPanel:SetPos(525, 235)
    controlsSettingsScrollPanel:SetSize(1360, 635)
    controlsSettingsScrollPanel:Hide()

    function controlsSettingsScrollPanel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end

    local controlsSettingsScrollBar = controlsSettingsScrollPanel:GetVBar() -- mr biden please legalize nuclear bombs
    controlsSettingsScrollBar:SetHideButtons(true)
    controlsSettingsScrollBar:SetPos(525, 235)
    function controlsSettingsScrollBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(43, 39, 35, 66))
    end
    function controlsSettingsScrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(76, 76, 74, 150))
    end

    for k, v in ipairs(chicagoRPcontrolsSettingsOptions) do
        CreateControlsButton(v.bind, v.printname, v.text, controlsSettingsScrollPanel, settingsHelpText)
    end
    ---

    local videoSettingsButton = vgui.Create("DButton", motherFrame)
    videoSettingsButton:SetPos(103, 230)
    videoSettingsButton:SetSize(394, 56)
    videoSettingsButton:SetFont("MichromaRegular")
    videoSettingsButton:SetText("")
    videoSettingsButton:SetTextColor(primarytext)

    function videoSettingsButton:OnCursorEntered()
        if self:IsHovered() and !videoSettingsScrollPanel:IsVisible() then
            surface.PlaySound("chicagoRP_settings/hover.wav")
        elseif self:IsHovered() and videoSettingsScrollPanel:IsVisible() then
            surface.PlaySound("chicagoRP_settings/hover.wav")
        end
    end

    function videoSettingsButton:Paint(w, h)
        if self:IsHovered() and !videoSettingsScrollPanel:IsVisible() then
            surface.SetDrawColor(34, 34, 34, 100)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(255, 86, 65)
            DrawOutlinedTexturedRect(self, gradient_mat, 2)
        elseif !self:IsHovered() and videoSettingsScrollPanel:IsVisible() then
            surface.SetDrawColor(66, 66, 66, 30)
            surface.DrawRect(0, 0, w, h)
        elseif self:IsHovered() and videoSettingsScrollPanel:IsVisible() then
            surface.SetDrawColor(66, 66, 66, 60)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(255, 86, 65)
            DrawOutlinedTexturedRect(self, gradient_mat, 2)
        end
        surface.SetTextColor(primarytext)
        surface.SetTextPos(w - 383, h - 42)
        surface.SetFont("MichromaRegular")
        surface.DrawText("VIDEO")
    end

    function videoSettingsButton:DoClick()
        if IsValid(OpenPanel) then
            OpenPanel:Hide()
        end
        videoSettingsScrollPanel:Show()
        videoSettingsScrollPanel:SetAlpha(0)
        videoSettingsScrollPanel:AlphaTo(255, 0.2, 0)
        OpenPanel = videoSettingsScrollPanel
        surface.PlaySound("chicagoRP_settings/select.wav")
    end
    ---

    local gameSettingsButton = vgui.Create("DButton", motherFrame)
    gameSettingsButton:SetPos(103, 290)
    gameSettingsButton:SetSize(394, 56)
    gameSettingsButton:SetFont("MichromaRegular")
    gameSettingsButton:SetText("")
    gameSettingsButton:SetTextColor(primarytext)

    function gameSettingsButton:OnCursorEntered()
        if self:IsHovered() and !gameSettingsScrollPanel:IsVisible() then
            surface.PlaySound("chicagoRP_settings/hover.wav")
        elseif self:IsHovered() and gameSettingsScrollPanel:IsVisible() then
            surface.PlaySound("chicagoRP_settings/hover.wav")
        end
    end

    function gameSettingsButton:Paint(w, h)
        if self:IsHovered() and !gameSettingsScrollPanel:IsVisible() then
            surface.SetDrawColor(34, 34, 34, 100)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(255, 86, 65)
            DrawOutlinedTexturedRect(self, gradient_mat, 2)
        elseif !self:IsHovered() and gameSettingsScrollPanel:IsVisible() then
            surface.SetDrawColor(66, 66, 66, 30)
            surface.DrawRect(0, 0, w, h)
        elseif self:IsHovered() and gameSettingsScrollPanel:IsVisible() then
            surface.SetDrawColor(66, 66, 66, 60)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(255, 86, 65)
            DrawOutlinedTexturedRect(self, gradient_mat, 2)
        end
        surface.SetTextColor(primarytext)
        surface.SetTextPos(w - 383, h - 42)
        surface.SetFont("MichromaRegular")
        surface.DrawText("GAME")
    end

    function gameSettingsButton:DoClick()
        if IsValid(OpenPanel) then
            OpenPanel:Hide()
        end
        gameSettingsScrollPanel:Show()
        gameSettingsScrollPanel:SetAlpha(0)
        gameSettingsScrollPanel:AlphaTo(255, 0.2, 0)
        OpenPanel = gameSettingsScrollPanel
        surface.PlaySound("chicagoRP_settings/select.wav")
    end
    ---

    local controlsSettingsButton = vgui.Create("DButton", motherFrame)
    controlsSettingsButton:SetPos(103, 350)
    controlsSettingsButton:SetSize(394, 56)
    controlsSettingsButton:SetFont("MichromaRegular")
    controlsSettingsButton:SetText("")
    controlsSettingsButton:SetTextColor(primarytext)

    function controlsSettingsButton:OnCursorEntered()
        if self:IsHovered() and !controlsSettingsScrollPanel:IsVisible() then
            surface.PlaySound("chicagoRP_settings/hover.wav")
        elseif self:IsHovered() and controlsSettingsScrollPanel:IsVisible() then
            surface.PlaySound("chicagoRP_settings/hover.wav")
        end
    end

    function controlsSettingsButton:Paint(w, h)
        if self:IsHovered() and !controlsSettingsScrollPanel:IsVisible() then
            surface.SetDrawColor(34, 34, 34, 100)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(255, 86, 65)
            DrawOutlinedTexturedRect(self, gradient_mat, 2)
        elseif !self:IsHovered() and controlsSettingsScrollPanel:IsVisible() then
            surface.SetDrawColor(66, 66, 66, 30)
            surface.DrawRect(0, 0, w, h)
        elseif self:IsHovered() and controlsSettingsScrollPanel:IsVisible() then
            surface.SetDrawColor(66, 66, 66, 60)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(255, 86, 65)
            DrawOutlinedTexturedRect(self, gradient_mat, 2)
        end
        surface.SetTextColor(primarytext)
        surface.SetTextPos(w - 383, h - 42)
        surface.SetFont("MichromaRegular")
        surface.DrawText("CONTROLS")
    end

    function controlsSettingsButton:DoClick()
        if IsValid(OpenPanel) then
            OpenPanel:Hide()
        end
        controlsSettingsScrollPanel:Show()
        controlsSettingsScrollPanel:SetAlpha(0)
        controlsSettingsScrollPanel:AlphaTo(255, 0.2, 0)
        OpenPanel = controlsSettingsScrollPanel
        surface.PlaySound("chicagoRP_settings/select.wav")
    end

    OpenMotherFrame = motherFrame
end)

-- still need:
-- ui layout pass
-- color pulse when click button 86, 65, 66
-- rounded outline
-- two-tone gradient material that can be changed ingame
-- MAYBE a slight move anim when opened/closed