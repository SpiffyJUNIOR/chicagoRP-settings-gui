local CVarPrimaryRed = GetConVar("chicagoRP_primary_r"):GetInt()
local CVarPrimaryGreen = GetConVar("chicagoRP_primary_g"):GetInt()
local CVarPrimaryBlue = GetConVar("chicagoRP_primary_b"):GetInt()
local CVarSecondaryRed = GetConVar("chicagoRP_secondary_r"):GetInt()
local CVarSecondaryGreen = GetConVar("chicagoRP_secondary_g"):GetInt()
local CVarSecondaryBlue = GetConVar("chicagoRP_secondary_b"):GetInt()
local CVarAccentRed = GetConVar("chicagoRP_accent_r"):GetInt()
local CVarAccentGreen = GetConVar("chicagoRP_accent_g"):GetInt()
local CVarAccentBlue = GetConVar("chicagoRP_accent_b"):GetInt()
local CVarPrimaryGradientRed = GetConVar("chicagoRP_primarygradient_r"):GetInt()
local CVarPrimaryGradientGreen = GetConVar("chicagoRP_primarygradient_g"):GetInt()
local CVarPrimaryGradientBlue = GetConVar("chicagoRP_primarygradient_b"):GetInt()
local CVarSecondaryGradientRed = GetConVar("chicagoRP_secondarygradient_r"):GetInt()
local CVarSecondaryGradientGreen = GetConVar("chicagoRP_secondarygradient_g"):GetInt()
local CVarSecondaryGradientBlue = GetConVar("chicagoRP_secondarygradient_b"):GetInt()

local blockedbindkeys = {
    [1] = KEY_ESCAPE,
    [2] = KEY_TAB,
    [3] = KEY_Q,
    [4] = KEY_W,
    [5] = KEY_S,
    [6] = KEY_A,
    [7] = KEY_D,
    [8] = KEY_E,
    [9] = KEY_ENTER,
    [10] = KEY_CAPSLOCK,
    [11] = KEY_R,
    [12] = KEY_V,
    [13] = KEY_F,
    [13] = KEY_C
}

local exiticon = Material("chicagorp_settings/exiticon.png", "smooth")
local HideHUD = false
local OpenMotherFrame = nil
local OpenScrollPanel = nil
local OpenControlText = nil
local primarytext = (Color(CVarPrimaryRed, CVarPrimaryGreen, CVarPrimaryBlue, 255))
local secondarytext = (Color(CVarSecondaryRed, CVarSecondaryGreen, CVarSecondaryBlue, 255))
local accenttext = Color(CVarAccentRed, CVarAccentGreen, CVarAccentBlue, 220) -- colors for exit icon, outline text, and back/game text
local gradientcolor1 = Color(CVarPrimaryGradientRed, CVarPrimaryGradientGreen, CVarPrimaryGradientBlue, 180) -- Color(247, 31, 251, 200)
local gradientcolor2 = Color(CVarSecondaryGradientRed, CVarSecondaryGradientGreen, CVarSecondaryGradientBlue, 180) -- Color(4, 164, 255, 200)
local pulseredfrom, pulseredto = 0, 150
local pulsegreenfrom, pulsegreento = 0, 20
local pulsebluefrom, pulseblueto = 0, 30
local pulsealphafrom, pulsealphato = 0, 80
local altpulseredfrom, altpulseredto = 0, 180
local altpulsegreenfrom, altpulsegreento = 0, 20
local altpulsebluefrom, altpulseblueto = 0, 30
local altpulsealphafrom, altpulsealphato = 0, 40

local function SlideSound()
    local hoverslide = CreateSound(game.GetWorld(), "chicagorp_settings/hover_slide.wav", 0)
    if hoverslide then
        hoverslide:SetSoundLevel(0)
        hoverslide:Stop()
        hoverslide:Play()
    end
    return hoverslide
end

local function CreateSettingsButton(printname, convar, min, max, helptext, parent, helptextparent, frame)
    local CVarPulse = GetConVar("chicagoRP_clickpulse"):GetBool()

    if (GetConVar(convar):GetInt() == 0 or GetConVar(convar):GetInt() == 1) and (max == 1) and ConVarExists(convar) then
        local settingsButton = parent:Add("DButton")
        settingsButton:SetText("")
        settingsButton:Dock(TOP)
        settingsButton:DockMargin(0, 0, 3, 4)
        settingsButton:SetSize(chicagoRP.HorizontalScreenScale(1340), chicagoRP.VerticalScreenScale(50))

        function settingsButton:OnCursorEntered()
            surface.PlaySound("chicagorp_settings/hover.wav")
        end

        function settingsButton:Paint(w, h)
            local hovered = self:IsHovered()
            -----
            chicagoRP.ButtonFade(self, w, h, 40, 80, 80, 80, 4, false)

            -----
            chicagoRP.OutlineFade(self, w, h, 0, 180, gradientcolor1, gradientcolor2, 4, false)

            -----
            if CVarPulse then
                chicagoRP.Pulse(self, w, h, pulseredfrom, pulseredto, pulsegreenfrom, pulsegreento, pulsebluefrom, pulseblueto, pulsealphafrom, pulsealphato, self.pulse, 5, false, gradientcolor1, gradientcolor2)
            end

            -----
            if hovered then
                helptextparent:SetText(helptext)
            end

            -----
            if (GetConVar(convar):GetInt() == 0) and (max == 1) then
                surface.SetDrawColor(primarytext:Unpack())
                chicagoRP.DrawOutlinedRoundedBox(3, chicagoRP.HorizontalScreenScale(1300), chicagoRP.VerticalScreenScale(14), chicagoRP.VerticalScreenScale(22), chicagoRP.VerticalScreenScale(22), primarytext, 1)
            elseif (GetConVar(convar):GetInt() == 1) and (max == 1) then
                surface.SetDrawColor(primarytext:Unpack())
                draw.RoundedBox(4, chicagoRP.HorizontalScreenScale(1305), chicagoRP.VerticalScreenScale(19), chicagoRP.VerticalScreenScale(12), chicagoRP.VerticalScreenScale(12), primarytext)
                chicagoRP.DrawOutlinedRoundedBox(3, chicagoRP.HorizontalScreenScale(1300), chicagoRP.VerticalScreenScale(14), chicagoRP.VerticalScreenScale(22), chicagoRP.VerticalScreenScale(22), primarytext, 1)
            elseif (GetConVar(convar):GetInt() >= 0) and (max > 1) then
                local statusString = GetConVar(convar):GetInt()
                draw.DrawText(statusString, "MichromaRegular", chicagoRP.HorizontalScreenScale(790), chicagoRP.VerticalScreenScale(12), primarytext, TEXT_ALIGN_RIGHT)
            end

            draw.DrawText(printname, "MichromaRegular", chicagoRP.HorizontalScreenScale(14), chicagoRP.VerticalScreenScale(12), primarytext, TEXT_ALIGN_LEFT)
        end

        function settingsButton:DoClick()
            self.pulse = true

            timer.Simple(0.20, function()
                if IsValid(self) then
                    self.pulse = false
                end
            end)

            if (GetConVar(convar):GetInt() == 0) then
                RunConsoleCommand(convar, "1")
                surface.PlaySound("chicagorp_settings/select.wav")
            elseif (GetConVar(convar):GetInt() == 1) then
                RunConsoleCommand(convar, "0")
                surface.PlaySound("chicagorp_settings/select.wav")
            end
        end
    elseif (GetConVar(convar):GetInt() >= 0 or GetConVar(convar):GetInt() <= 0) and (max > 1) and ConVarExists(convar) then
        local settingsSliderParent = parent:Add("DButton")
        settingsSliderParent:SetText("")
        settingsSliderParent:Dock(TOP)
        settingsSliderParent:DockMargin(0, 0, 3, 4)
        settingsSliderParent:SetSize(chicagoRP.HorizontalScreenScale(1340), chicagoRP.VerticalScreenScale(50))

        function settingsSliderParent:OnCursorEntered()
            surface.PlaySound("chicagorp_settings/hover.wav")
        end

        function settingsSliderParent:Paint(w, h)
            local hovered = self:IsHovered()
            local childhovered = self:IsChildHovered()
            -----
            chicagoRP.ButtonFade(self, w, h, 40, 80, 80, 80, 4, true)

            chicagoRP.OutlineFade(self, w, h, 0, 150, gradientcolor1, gradientcolor2, 4, true)

            chicagoRP.DrawOutlinedGradientRect(self, gradientcolor1, gradientcolor2, 3)

            if (hovered or childhovered) then
                helptextparent:SetText(helptext)
            end

            draw.DrawText(printname, "MichromaRegular", chicagoRP.HorizontalScreenScale(14), chicagoRP.VerticalScreenScale(12), primarytext, TEXT_ALIGN_LEFT)
            -- return nil
        end

        local settingsSlider = vgui.Create("DNumSlider", settingsSliderParent)
        local parentW, parentH = settingsSliderParent:GetSize()
        settingsSlider:SetText("")
        settingsSlider:SetSize(chicagoRP.HorizontalScreenScale(335), parentH)
        settingsSlider:SetPos(parentW - settingsSlider:GetSize(), 0)
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
            draw.DrawText(GetConVar(convar):GetInt(), "MichromaRegular", chicagoRP.HorizontalScreenScale(325), chicagoRP.VerticalScreenScale(13), primarytext, TEXT_ALIGN_RIGHT)
        end

        function settingsSlider.Slider.Knob:Paint(w, h)
            return nil
        end

        function settingsSlider.Slider:OnCursorEntered()
            surface.PlaySound("chicagorp_settings/hover.wav")
        end

        function settingsSlider:OnValueChanged(value)
            self:SetValue(math.Round(value, 0))
            SlideSound()
        end
    end
end

local function CreateControlsButton(bind, printname, helptext, parent, helptextparent, frame)
    local controlsButton = parent:Add("DButton")
    controlsButton:SetText("")
    controlsButton:Dock(TOP)
    controlsButton:DockMargin(0, 0, 3, 4)
    controlsButton:SetSize(chicagoRP.HorizontalScreenScale(800), chicagoRP.VerticalScreenScale(44))

    function controlsButton:OnCursorEntered()
        surface.PlaySound("chicagorp_settings/hover.wav")
    end

    function controlsButton:Paint(w, h)
        local hovered = self:IsHovered()
        local haschildren = self:HasChildren()
        local statusString = "Unbound"
        -----
        chicagoRP.ButtonFade(self, w, h, 40, 80, 80, 80, 4, true)
        -----
        chicagoRP.OutlineFade(self, w, h, 0, 150, gradientcolor1, gradientcolor2, 4, true)
        -----
        chicagoRP.DrawOutlinedGradientRect(self, gradientcolor1, gradientcolor2, 3)
        -----
        if CVarPulse then
            chicagoRP.Pulse(self, w, h, pulseredfrom, pulseredto, pulsegreenfrom, pulsegreento, pulsebluefrom, pulseblueto, pulsealphafrom, pulsealphato, self.pulse, 5, false, gradientcolor1, gradientcolor2)
        end
        -----

        if hovered or haschildren then
            helptextparent:SetText(helptext)
        end

        if input.LookupBinding(bind, false) and !haschildren then
            statusString = string.upper(input.LookupBinding(bind, false))
            draw.DrawText(statusString, "MichromaRegular", chicagoRP.HorizontalScreenScale(1325), chicagoRP.VerticalScreenScale(10), primarytext, TEXT_ALIGN_RIGHT)
        end

        draw.DrawText(printname, "MichromaRegular", chicagoRP.HorizontalScreenScale(14), chicagoRP.VerticalScreenScale(10), primarytext, TEXT_ALIGN_LEFT)
    end

    function controlsButton:DoClick()
        surface.PlaySound("chicagorp_settings/select.wav")
        self.pulse = true

        timer.Simple(0.20, function()
            if IsValid(self) and self.pulse == true then
                self.pulse = false
            end
        end)

        if IsValid(OpenControlText) then
            OpenControlText:Remove()
        end

        local controlHelpText = vgui.Create("DLabel", frame)
        controlHelpText:SetPos(chicagoRP.HorizontalScreenScale(1470), chicagoRP.VerticalScreenScale(930))
        controlHelpText:SetSize(chicagoRP.HorizontalScreenScale(400), 30)
        controlHelpText:SetFont("MichromaHelpText")
        controlHelpText:SetText("Press a key to bind.")

        function controlHelpText:Paint(w, h)
            draw.DrawText(self:GetText(), "MichromaSmall", chicagoRP.HorizontalScreenScale(390), chicagoRP.VerticalScreenScale(5), primarytext, TEXT_ALIGN_RIGHT)

            return true
        end

        chicagoRP.PanelFadeIn(controlHelpText, 0.2)

        local parentW, parentH = self:GetSize()

        local controlsTextEntry = self:Add("DTextEntry")
        controlsTextEntry:Dock(RIGHT)
        controlsTextEntry:SetSize(chicagoRP.AdvancedHorizontalScreenScale(60, parentW), chicagoRP.AdvancedHorizontalScreenScale(44, parentH))
        controlsTextEntry:RequestFocus() -- please

        function controlsTextEntry:Paint(w, h)
            if math.sin((SysTime() * 1) * 6) > 0 then
                draw.DrawText("__", "MichromaRegular", chicagoRP.HorizontalScreenScale(16), chicagoRP.VerticalScreenScale(12), primarytext, TEXT_ALIGN_CENTER)
            end
        end

        function controlsTextEntry:OnKeyCode(keyCode)
            local bindblocked = false
            local keyname = tostring(input.GetKeyName(keyCode) .. " ")
            local bindtext = tostring("bind " .. input.GetKeyName(keyCode) .. " " .. bind)
            for _, v in ipairs(blockedbindkeys) do
                if keyCode == v then
                    surface.PlaySound("chicagorp_settings/back.wav")
                    controlHelpText:SetText("Binding default key blocked.")
                    self:Remove()
                    timer.Simple(5, function()
                        if IsValid(controlHelpText) then
                            chicagoRP.PanelFadeOut(controlHelpText, 0.5)
                        end
                    end)
                    bindblocked = true
                end
            end
            if bindblocked then return end
            print("Please enter bind " .. keyname .. bind .. " in your console.") -- add spaces pls
            SetClipboardText(bindtext)
            surface.PlaySound("chicagorp_settings/select.wav")
            controlHelpText:SetText("Key bound, paste in console then enter.")

            controlsButton.value = true
            timer.Simple(0.20, function()
                if IsValid(controlsButton) and controlsButton.value == true then
                    controlsButton.value = false
                end
            end)

            self:Remove()
            timer.Simple(5, function()
                if IsValid(controlHelpText) then
                    chicagoRP.PanelFadeOut(controlHelpText, 0.5)
                end
            end)
        end

        function controlsTextEntry:OnLoseFocus()
            surface.PlaySound("chicagorp_settings/back.wav")
            controlHelpText:SetText("Bind cancelled.")
            self:Remove()
            timer.Simple(5, function()
                if IsValid(controlHelpText) then
                    chicagoRP.PanelFadeOut(controlHelpText, 0.5)
                end
            end)
        end

        OpenControlText = controlHelpText
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
    local CVarBlur = GetConVar("chicagoRP_blur"):GetBool()
    local CVarPulse = GetConVar("chicagoRP_clickpulse"):GetBool()
    local CVarDSP = GetConVar("chicagoRP_dsp"):GetBool()
    local motherFrame = vgui.Create("DFrame")
    motherFrame:SetSize(screenwidth, screenheight)
    motherFrame:SetVisible(true)
    motherFrame:SetDraggable(false)
    motherFrame:ShowCloseButton(false)
    motherFrame:SetTitle("")
    motherFrame:ParentToHUD()
    motherFrame:SetKeyboardInputEnabled(true)
    HideHUD = true
    OpenScrollPanel = nil

    if ArcCW and IsValid(ArcCW.InvHUD) then
        ArcCW.InvHUD:Hide()
    end

    function motherFrame:Paint(w, h)
        if CVarBlur then
            chicagoRP.BlurBackground(self)
            draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 0))
        elseif !CVarBlur then
            draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 170))
        end
    end

    chicagoRP.PanelFadeIn(motherFrame, 0.15)

    motherFrame:MakePopup()
    motherFrame:Center()

    timer.Simple(0.15, function()
        if CVarDSP then
            ply:SetDSP(30, false)
        end
    end)

    surface.PlaySound("chicagorp_settings/back.wav")

    function motherFrame:OnClose()
        HideHUD = false
        if IsValid(ArcCW.InvHUD) then
            ArcCW.InvHUD:Show()
        end
        if CVarDSP then
            ply:SetDSP(0, false)
        end
    end
    ---

    local exitButton = vgui.Create("DButton", motherFrame)
    exitButton:SetPos(chicagoRP.HorizontalScreenScale(46), chicagoRP.VerticalScreenScale(46))
    exitButton:SetSize(80, 20)
    exitButton:SetFont("MichromaSmall")
    exitButton:SetText("  GAME")
    exitButton:SetTextColor(secondarytext)

    function exitButton:DoClick()
        motherFrame:AlphaTo(50, 0.15, 0)
        surface.PlaySound("chicagorp_settings/back.wav")
        timer.Simple(0.15, function()
            if IsValid(motherFrame) then
                motherFrame:Close()
            end
        end)
    end

    function exitButton:Paint(w, h)
        return nil
    end
    ---

    local exitIconButton = vgui.Create("DButton", motherFrame)
    exitIconButton:SetPos(chicagoRP.HorizontalScreenScale(37), chicagoRP.VerticalScreenScale(48))
    exitIconButton:SetSize(chicagoRP.HorizontalScreenScale(14), chicagoRP.VerticalScreenScale(15))

    function exitIconButton:DoClick()
        motherFrame:AlphaTo(50, 0.15, 0)
        surface.PlaySound("chicagorp_settings/back.wav")
        timer.Simple(0.15, function()
            if IsValid(motherFrame) then
                motherFrame:Close()
            end
        end)
    end

    function exitIconButton:Paint(w, h)
        surface.SetDrawColor(accenttext:Unpack())
        surface.SetMaterial(exiticon)
        surface.DrawTexturedRect(0, 0, w, h)

        return true
    end
    ---

    local settingsLabel = vgui.Create("DLabel", motherFrame)
    settingsLabel:SetPos(chicagoRP.HorizontalScreenScale(61), chicagoRP.VerticalScreenScale(69))
    settingsLabel:SetSize(130, 20)
    settingsLabel:SetFont("MichromaRegular")
    settingsLabel:SetText("SETTINGS")
    settingsLabel:SetTextColor(primarytext)

    function settingsLabel:Paint(w, h)
        return nil
    end
    ---

    local settingsTitleLabel = vgui.Create("DLabel", motherFrame)
    settingsTitleLabel:SetPos(chicagoRP.HorizontalScreenScale(525), chicagoRP.VerticalScreenScale(95))
    settingsTitleLabel:SetSize(chicagoRP.HorizontalScreenScale(500), chicagoRP.VerticalScreenScale(200))
    settingsTitleLabel:SetText("")
    settingsTitleLabel:SetTextColor(primarytext)

    function settingsTitleLabel:Paint(w, h)
        draw.DrawText(self:GetText(), "MichromaLarge", chicagoRP.HorizontalScreenScale(12), chicagoRP.VerticalScreenScale(12), accenttext, TEXT_ALIGN_LEFT)
        draw.DrawText(self:GetText(), "MichromaLarge", chicagoRP.HorizontalScreenScale(14), chicagoRP.VerticalScreenScale(10), primarytext, TEXT_ALIGN_LEFT)

        return true
    end
    ---

    local settingsHelpText = vgui.Create("DLabel", motherFrame)
    settingsHelpText:SetPos(chicagoRP.HorizontalScreenScale(60), chicagoRP.VerticalScreenScale(945))
    settingsHelpText:SetSize(1000, 30)
    settingsHelpText:SetFont("MichromaSmall")
    settingsHelpText:SetText("")
    settingsHelpText:SetTextColor(primarytext)

    function settingsHelpText:Paint(w, h)
        return nil
    end
    ---

    local exitHelpText = vgui.Create("DLabel", motherFrame)
    exitHelpText:SetPos(chicagoRP.HorizontalScreenScale(60), chicagoRP.VerticalScreenScale(984))
    exitHelpText:SetSize(chicagoRP.HorizontalScreenScale(160), chicagoRP.VerticalScreenScale(30))
    exitHelpText:SetFont("MichromaHelpText")
    exitHelpText:SetText("[Q]   BACK")
    exitHelpText:SetTextColor(secondarytext)

    function exitHelpText:Paint(w, h)
        return nil
    end
    ---

    function motherFrame:OnKeyCodePressed(key)
        if IsValid(OpenScrollPanel) and (key == KEY_ESCAPE or key == KEY_Q) then
            chicagoRP.PanelFadeOut(OpenScrollPanel, 0.15)
            chicagoRP.PanelFadeOut(settingsTitleLabel, 0.15)
            chicagoRP.PanelFadeOut(settingsHelpText, 0.15)
            surface.PlaySound("chicagorp_settings/back.wav")
            timer.Simple(0.15, function()
                if IsValid(OpenScrollPanel) then
                    OpenScrollPanel:Hide()
                    settingsHelpText:SetText("")
                end
            end)
            timer.Simple(0.15, function()
                if IsValid(OpenScrollPanel) and !OpenScrollPanel:IsVisible() then
                    OpenScrollPanel = nil
                end
            end)
        elseif !IsValid(OpenScrollPanel) and (key == KEY_ESCAPE or key == KEY_Q) then
            self:AlphaTo(50, 0.15, 0)
            surface.PlaySound("chicagorp_settings/back.wav")
            timer.Simple(0.15, function()
                if IsValid(self) then
                    self:Close()
                end
            end)
        end
    end

    local categoryScrollPanel = vgui.Create("DScrollPanel", motherFrame)
    categoryScrollPanel:SetPos(chicagoRP.HorizontalScreenScale(63), chicagoRP.VerticalScreenScale(180))
    categoryScrollPanel:SetSize(chicagoRP.HorizontalScreenScale(396), chicagoRP.VerticalScreenScale(728))

    function categoryScrollPanel:Paint(w, h)
        return nil
    end

    local categoryScrollBar = categoryScrollPanel:GetVBar() -- mr biden please legalize nuclear bombs
    categoryScrollBar:SetHideButtons(true)
    categoryScrollBar:SetPos(chicagoRP.HorizontalScreenScale(525), chicagoRP.VerticalScreenScale(185))
    function categoryScrollBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(42, 40, 35, 66))
    end
    function categoryScrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(76, 76, 74, 150))
    end

    for _, v in ipairs(chicagoRP.categories) do
        local categoryButton = categoryScrollPanel:Add("DButton")
        categoryButton:SetText("")
        categoryButton:Dock(TOP)
        categoryButton:DockMargin(0, 10, 0, 0)
        categoryButton:SetSize(chicagoRP.HorizontalScreenScale(394), chicagoRP.VerticalScreenScale(56))

        function categoryButton:OnCursorEntered()
            surface.PlaySound("chicagorp_settings/hover.wav")
        end
        ---

        local settingsScrollPanel = vgui.Create("DScrollPanel", motherFrame)
        settingsScrollPanel:SetPos(chicagoRP.HorizontalScreenScale(525), chicagoRP.VerticalScreenScale(185))
        settingsScrollPanel:SetSize(chicagoRP.HorizontalScreenScale(1360), chicagoRP.VerticalScreenScale(735))
        settingsScrollPanel:Hide()

        function settingsScrollPanel:Paint(w, h)
            return nil
        end

        local settingsScrollBar = settingsScrollPanel:GetVBar() -- mr biden please legalize nuclear bombs
        settingsScrollBar:SetHideButtons(true)
        settingsScrollBar:SetPos(chicagoRP.HorizontalScreenScale(525), chicagoRP.VerticalScreenScale(185))

        function settingsScrollBar:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(42, 40, 35, 66))
        end

        function settingsScrollBar.btnGrip:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(76, 76, 74, 150))
        end
        ---
        function categoryButton:Paint(w, h)
            local panelActive = settingsScrollPanel:IsVisible()
            local hovered = self:IsHovered()
            local buf, step = self.__hoverBuf or 0, RealFrameTime() * 5
            local alpha, clr = Lerp(buf, 0, 34), Lerp(buf, 0, 66) -- end of anim

            if hovered and buf < 1 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != settingsScrollPanel) then
                buf = math.min(1, step + buf)
                alpha, clr = Lerp(buf, 0, 60), Lerp(buf, 0, 66)
            elseif !hovered and buf >= 0 and panelActive and OpenScrollPanel != nil and (OpenScrollPanel == settingsScrollPanel) then -- kill yourself
                buf = math.max(0, buf - step)
                alpha, clr = Lerp(buf, 40, 40), Lerp(buf, 14, 14) -- Lerp(buf, 34, 60), Lerp(buf, 66, 66)
            elseif hovered and buf < 1 and panelActive and (OpenScrollPanel != nil or OpenScrollPanel == settingsScrollPanel) then
                buf = math.min(1, step + buf)
                alpha, clr = Lerp(buf, 40, 60), Lerp(buf, 66, 66) -- Lerp(buf, 60, 34), Lerp(buf, 66, 66)
            elseif !hovered and buf >= 0 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != settingsScrollPanel) then
                buf = math.max(0, buf - step)
                alpha, clr = Lerp(buf, 0, 34), Lerp(buf, 0, 66)
            end

            if hovered and buf >= 1 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != settingsScrollPanel) then
                alpha, clr = Lerp(buf, 0, 60), Lerp(buf, 0, 66)
            elseif !hovered and buf <= 0.02 and panelActive and OpenScrollPanel != nil and (OpenScrollPanel == settingsScrollPanel) then -- kill yourself
                alpha, clr = Lerp(buf, 40, 40), Lerp(buf, 14, 14)
            elseif hovered and buf >= 1 and panelActive and (OpenScrollPanel != nil or OpenScrollPanel == settingsScrollPanel) then
                alpha, clr = Lerp(buf, 30, 60), Lerp(buf, 66, 66)
            elseif !hovered and buf <= 0.02 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != settingsScrollPanel) then
                alpha, clr = Lerp(buf, 0, 34), Lerp(buf, 0, 66)
            end

            self.__hoverBuf = buf
            buf = math.EaseInOut(buf, 0.2, 0.2)
            alpha, clr = alpha, clr

            surface.SetDrawColor(clr, clr, clr, alpha)
            surface.DrawRect(0, 0, w, h)
            -----
            if CVarPulse then -- gradient pulse does not work
                chicagoRP.Pulse(self, w, h, altpulseredfrom, altpulseredto, altpulsegreenfrom, altpulsegreento, altpulsebluefrom, altpulseblueto, altpulsealphafrom, altpulsealphato, self.pulse, 3, true)
            end

            draw.DrawText(v.printname, "MichromaRegular", chicagoRP.HorizontalScreenScale(11), chicagoRP.VerticalScreenScale(14), primarytext, TEXT_ALIGN_LEFT)
        end
        ---
        local labelParentW,_ = settingsScrollPanel:GetSize()

        local actionLabel = vgui.Create("DLabel", settingsScrollPanel)
        actionLabel:SetPos(chicagoRP.AdvancedHorizontalScreenScale(10, labelParentW), chicagoRP.AdvancedHorizontalScreenScale(-34, labelParentW))
        actionLabel:SetSize(chicagoRP.HorizontalScreenScale(100), chicagoRP.VerticalScreenScale(30))
        actionLabel:SetText("ACTION")
        actionLabel:SetTextColor(secondarytext)
        actionLabel:NoClipping(true)
        actionLabel:Hide()

        function actionLabel:Paint(w, h)
            draw.DrawText(self:GetText(), "MichromaSmall", 0, 0, secondarytext, TEXT_ALIGN_LEFT)

            return true
        end
        ---

        local bindLabel = vgui.Create("DLabel", settingsScrollPanel)
        bindLabel:SetPos(chicagoRP.AdvancedHorizontalScreenScale(1745, labelParentW), chicagoRP.AdvancedHorizontalScreenScale(-34, labelParentW)) -- fucking fix this
        bindLabel:SetSize(chicagoRP.HorizontalScreenScale(100), chicagoRP.VerticalScreenScale(30))
        bindLabel:SetText("BINDING")
        bindLabel:SetTextColor(secondarytext)
        bindLabel:NoClipping(true)
        bindLabel:Hide()

        function bindLabel:Paint(w, h)
            draw.DrawText(self:GetText(), "MichromaSmall", chicagoRP.HorizontalScreenScale(96), 0, secondarytext, TEXT_ALIGN_RIGHT)

            return true
        end

        local buttonscreated = false
        ---

        function categoryButton:DoClick()
            self.pulse = true

            timer.Simple(0.20, function()
                if IsValid(self) and self.pulse == true then
                    self.pulse = false
                end
            end)

            for _, v2 in ipairs(chicagoRP[v.name]) do
                if buttonscreated == false and isstring(v2.bind) then
                    CreateControlsButton(v2.bind, v2.printname, v2.text, settingsScrollPanel, settingsHelpText, motherFrame)
                    actionLabel:Show()
                    bindLabel:Show()
                elseif buttonscreated == false and isstring(v2.convar) and ConVarExists(v2.convar) then
                    CreateSettingsButton(v2.printname, v2.convar, v2.min, v2.max, v2.text, settingsScrollPanel, settingsHelpText, motherFrame)
                end
            end

            buttonscreated = true

            if IsValid(OpenScrollPanel) and IsValid(settingsTitleLabel) then
                chicagoRP.PanelFadeOut(OpenScrollPanel, 0.15)
                chicagoRP.PanelFadeOut(settingsTitleLabel, 0.15)
                chicagoRP.PanelFadeOut(settingsHelpText, 0.15)
                timer.Simple(0.15, function()
                    if IsValid(OpenScrollPanel) then
                        OpenScrollPanel:Hide()
                        settingsHelpText:SetText("")
                    end
                end)
                timer.Simple(0.15, function()
                    if IsValid(OpenScrollPanel) and OpenScrollPanel == settingsScrollPanel and !OpenScrollPanel:IsVisible() then
                        OpenScrollPanel = nil
                    end
                end)
                if OpenScrollPanel == nil then return end
                timer.Simple(0.2, function()
                    if IsValid(settingsScrollPanel) and IsValid(settingsTitleLabel) and IsValid(OpenScrollPanel) then
                        chicagoRP.PanelFadeIn(settingsTitleLabel, 0.15)
                        chicagoRP.PanelFadeIn(settingsHelpText, 0.15)
                        settingsScrollPanel:Show()
                        chicagoRP.PanelFadeIn(settingsScrollPanel, 0.15)
                        settingsTitleLabel:SetText(v.printname)
                        if v.overridename then
                            settingsTitleLabel:SetText(v.overridename)
                        end
                        OpenScrollPanel = settingsScrollPanel
                    end
                end)
            elseif IsValid(settingsScrollPanel) and !IsValid(OpenScrollPanel) and IsValid(settingsTitleLabel) then
                chicagoRP.PanelFadeIn(settingsTitleLabel, 0.15)
                chicagoRP.PanelFadeIn(settingsHelpText, 0.15)
                settingsScrollPanel:Show()
                chicagoRP.PanelFadeIn(settingsScrollPanel, 0.15)
                settingsTitleLabel:SetText(v.printname)
                if v.overridename then
                    settingsTitleLabel:SetText(v.overridename)
                end
                OpenScrollPanel = settingsScrollPanel
            end
            surface.PlaySound("chicagorp_settings/select.wav")
        end
    end
    ---

    OpenMotherFrame = motherFrame
end)

-- still need:
-- optimization