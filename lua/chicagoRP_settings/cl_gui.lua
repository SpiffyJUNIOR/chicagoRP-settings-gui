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

local blurMat = Material("pp/blurscreen")
local gradientLeftMat = Material("vgui/gradient-l") -- gradient-d, gradient-r, gradient-u, gradient-l, gradient_down, gradient_up
local gradientRightMat = Material("vgui/gradient-r") -- gradient-d, gradient-r, gradient-u, gradient-l, gradient_down, gradient_up
local roundedOutlineMat = Material("chicagoRP_settings/color_panel_clear.png")
local exiticon = Material("chicagoRP_settings/exiticon.png", "smooth")
local HideHUD = false
local OpenMotherFrame = nil
local OpenScrollPanel = nil
local OpenControlText = nil
local Dynamic = 0
local primarytext = (Color(CVarPrimaryRed, CVarPrimaryGreen, CVarPrimaryBlue, 255))
local secondarytext = (Color(CVarSecondaryRed, CVarSecondaryGreen, CVarSecondaryBlue, 255))
local accenttext = Color(CVarAccentRed, CVarAccentGreen, CVarAccentBlue, 220) -- colors for exit icon, outline text, and back/game text
local gradientcolor1 = Color(CVarPrimaryGradientRed, CVarPrimaryGradientGreen, CVarPrimaryGradientBlue, 180) -- Color(247, 31, 251, 200)
local gradientcolor2 = Color(CVarSecondaryGradientRed, CVarSecondaryGradientGreen, CVarSecondaryGradientBlue, 180) -- Color(4, 164, 255, 200)
local hoverslide = CreateSound(game.GetWorld(), "chicagoRP_settings/hover_slide.wav", 0) -- create the new sound, parented to the worldspawn (which always exists)

if IsValid(hoverslide) then
    hoverslide:SetSoundLevel(0) -- play everywhere
end

local function BlurBackground(panel)
    if (!IsValid(panel) or !panel:IsVisible()) then return end
    local layers, density, alpha = 1, 1, 100
    local x, y = panel:LocalToScreen(0, 0)
    local FrameRate, Num, Dark = 1 / RealFrameTime(), 5, 150

    surface.SetDrawColor(255, 255, 255, alpha)
    surface.SetMaterial(blurMat)

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

local function DrawOutlinedTexturedRect(panel, material, thickness) -- colorcube uses r and d texture
    if (!IsValid(panel) or !panel:IsVisible()) then return end
    local w, h = panel:GetSize()

    surface.SetMaterial(material)
    surface.DrawTexturedRectUV(0, 0, w, thickness, 0, 0, 1, 0) -- top
    surface.DrawTexturedRectUV(0, h - thickness, w, thickness, 0, 1, 1, 1) -- bottom
    surface.DrawTexturedRectUV(0, 0, thickness, h, 0, 0, 0, 1) -- left
    surface.DrawTexturedRectUV(w - thickness, 0, thickness, h, 1, 0, 1, 1) -- right
end

local function DrawOutlinedGradientRect(panel, firstcolor, secondcolor, thickness)
    if (!IsValid(panel) or !panel:IsVisible()) then return end
    local w, h = panel:GetSize()

    surface.SetDrawColor(firstcolor)
    surface.SetMaterial(gradientLeftMat)
    surface.DrawTexturedRectUV(0, 0, w, thickness, 0, 0, 1, 0) -- top
    surface.DrawTexturedRectUV(0, h - thickness, w, thickness, 0, 1, 1, 1) -- bottom
    surface.DrawTexturedRectUV(0, 0, thickness, h, 0, 0, 0, 1) -- left
    surface.DrawTexturedRectUV(w - thickness, 0, thickness, h, 1, 0, 1, 1) -- right

    surface.SetDrawColor(secondcolor)
    surface.SetMaterial(gradientRightMat)
    surface.DrawTexturedRectUV(0, 0, w, thickness, 0, 0, 1, 0) -- top
    surface.DrawTexturedRectUV(0, h - thickness, w, thickness, 0, 1, 1, 1) -- bottom
    surface.DrawTexturedRectUV(0, 0, thickness, h, 0, 0, 0, 1) -- left
    surface.DrawTexturedRectUV(w - thickness, 0, thickness, h, 1, 0, 1, 1) -- right
end

local function TexturedQuadPart(mat, x1, y1, w, h, tx, ty, tw, th) -- taken from TF2 gamemode by Kilburn, wango911, Agent Agrimar, and LeadKiller
    local x2, y2 = x1 + w, y1 + h
    local tw0 = mat:GetInt("$realwidth")
    local th0 = mat:GetInt("$realheight")
    local u1, v1, u2, v2 = tx / tw0, ty / th0, (tx + tw) / tw0, (ty + th) / th0

    local v = {}
    v[1] = {
        x = x1,
        y = y1,
        u = u1,
        v = v1
    }

    v[2] = {
        x = x2,
        y = y1,
        u = u2,
        v = v1
    }

    v[3] = {
        x = x2,
        y = y2,
        u = u2,
        v = v2
    }

    v[4] = {
        x = x1,
        y = y2,
        u = u1,
        v = v2
    }

    surface.SetMaterial(mat)
    surface.DrawPoly(v)
end

local function RoundedOutline(mat, x, y, w, h, src_corner_width, src_corner_height, draw_corner_width, draw_corner_height) -- taken from TF2 gamemode by Kilburn, wango911, Agent Agrimar, and LeadKiller
    local tw = mat:GetInt("$realwidth")
    local th = mat:GetInt("$realheight")
    local dx = draw_corner_width
    local dy = draw_corner_height

    local Dx = src_corner_width
    local Dy = src_corner_height

    local x1, y1 = x + dx, y + dy
    local x2, y2 = x + w - dx, y + h - dy
    local w2, h2 = w - 2 * dx, h - 2 * dy

    TexturedQuadPart(mat, x, y, dx, dy, 0, 0, Dx, Dy) -- corners
    TexturedQuadPart(mat, x2, y, dx, dy, tw - Dx, 0, Dx, Dy) -- corners
    TexturedQuadPart(mat, x, y2, dx, dy, 0, th - Dy, Dx, Dy) -- corners
    TexturedQuadPart(mat, x2, y2, dx, dy, tw - Dy, th - Dy, Dx, Dy) -- corners

    TexturedQuadPart(mat, x1, y, w2, dy, Dx, 0, tw - 2 * Dx, Dy) -- borders
    TexturedQuadPart(mat, x1, y2, w2, dy, Dx, th - Dy, tw - 2 * Dx, Dy) -- borders
    TexturedQuadPart(mat, x, y1, dx, h2, 0, Dy, Dx, th - 2 * Dy) -- borders
    TexturedQuadPart(mat, x2, y1, dx, h2, tw - Dx, Dy, Dx, th - 2 * Dy) -- borders

    TexturedQuadPart(mat, x1, y1, w2, h2, Dx, Dy, tw - 2 * Dx, th - 2 * Dy) -- inside
end

local function TheCoolerScreenScale(size)
    return math.Round(size * (ScrW() / 1920.0))
end

local function AdvancedScreenScale(size, width)
    return math.Round(size * (width / 1920.0))
end

local function CreateSettingsButton(printname, convar, min, max, helptext, parent, helptextparent, frame)
    local CVarColorPulse = GetConVar("chicagoRP_clickpulse"):GetBool()

    if (GetConVar(convar):GetInt() == 0 or GetConVar(convar):GetInt() == 1) and (max == 1) and ConVarExists(convar) then
        local settingsButton = parent:Add("DButton")
        settingsButton:SetText("")
        settingsButton:Dock(TOP)
        settingsButton:DockMargin(0, 0, 3, 4)
        settingsButton:SetSize(TheCoolerScreenScale(1340), TheCoolerScreenScale(50))

        function settingsButton:OnCursorEntered()
            surface.PlaySound("chicagoRP_settings/hover.wav")
        end

        function settingsButton:Paint(w, h)
            local hovered = self:IsHovered()
            local bufIn, stepIn = self.__hoverBufIn or 0, RealFrameTime() * 4

            if hovered and bufIn < 1 then
                bufIn = math.min(1, stepIn + bufIn)
            elseif !hovered and bufIn > 0 then
                bufIn = math.max(0, bufIn - stepIn)
            end

            self.__hoverBufIn = bufIn
            bufIn = math.EaseInOut(bufIn, 0.2, 0.2)
            local alpha, clr = Lerp(bufIn, 80, 80), Lerp(bufIn, 40, 80)

            surface.SetDrawColor(clr, clr, clr, alpha)
            surface.DrawRect(0, 0, w, h)
            -----
            local bufOutlineIn, stepOutlineIn = self.__hoverbufOutlineIn or 0, RealFrameTime() * 4

            if hovered and bufOutlineIn < 1 then
                bufOutlineIn = math.min(1, stepOutlineIn + bufOutlineIn)
            elseif !hovered and bufOutlineIn > 0 then
                bufOutlineIn = math.max(0, bufOutlineIn - stepOutlineIn)
            end

            self.__hoverbufOutlineIn = bufOutlineIn
            bufOutlineIn = math.EaseInOut(bufOutlineIn, 0.5, 0.5)
            local alphaOutline = Lerp(bufOutlineIn, 0, 180)

            gradientcolor1.a = alphaOutline
            gradientcolor2.a = alphaOutline

            -- DrawOutlinedGradientRect(self, gradientcolor1, gradientcolor2, 3)
            if (self.value != true) then
                DrawOutlinedGradientRect(self, gradientcolor1, gradientcolor2, 3)
            end
            -----
            local pulseBuf, pulseStep = self.__pulseBuf or 0, RealFrameTime() * 5

            if (self.value == true) and pulseBuf < 1 then
                pulseBuf = math.min(1, pulseStep + pulseBuf)
                print(pulseBuf)
            elseif (self.value != true) and pulseBuf > 0 then
                pulseBuf = math.max(0, pulseBuf - pulseStep)
                print(pulseBuf)
            end

            self.__pulseBuf = pulseBuf
            pulseBuf = math.EaseInOut(pulseBuf, 0.2, 0.2)
            local alphaPulse, clrRed, clrGreen, clrBlue, outlinePulse = Lerp(pulseBuf, 40, 40), Lerp(pulseBuf, 0, 150), Lerp(pulseBuf, 0, 20), Lerp(pulseBuf, 0, 30), Lerp(pulseBuf, 0, 4)

            surface.SetDrawColor(clrRed, clrGreen, clrBlue, alphaPulse)
            surface.DrawRect(0, 0, w, h)

            DrawOutlinedGradientRect(self, gradientcolor1, gradientcolor2, outlinePulse)

            if hovered then
                helptextparent:SetText(helptext)
            end

            if (GetConVar(convar):GetInt() == 0) and (max == 1) then
                surface.SetDrawColor(primarytext:Unpack())
                RoundedOutline(roundedOutlineMat, TheCoolerScreenScale(1300), TheCoolerScreenScale(14), 22, 22, 1, 1, 1, 1)
            elseif (GetConVar(convar):GetInt() == 1) and (max == 1) then
                surface.SetDrawColor(primarytext:Unpack())
                draw.RoundedBox(4, TheCoolerScreenScale(1305), TheCoolerScreenScale(19), 12, 12, primarytext)
                RoundedOutline(roundedOutlineMat, TheCoolerScreenScale(1300), TheCoolerScreenScale(14), 22, 22, 1, 1, 1, 1)
            elseif (GetConVar(convar):GetInt() >= 0) and (max > 1) then
                local statusString = GetConVar(convar):GetInt()
                draw.DrawText(statusString, "MichromaRegular", TheCoolerScreenScale(790), TheCoolerScreenScale(12), primarytext, TEXT_ALIGN_RIGHT)
            end

            draw.DrawText(printname, "MichromaRegular", TheCoolerScreenScale(14), TheCoolerScreenScale(12), primarytext, TEXT_ALIGN_LEFT)
        end

        function settingsButton:DoClick()
            self.value = true
            if (GetConVar(convar):GetInt() == 0) then -- add float check pls
                RunConsoleCommand(convar, "1")
                surface.PlaySound("chicagoRP_settings/select.wav")
            elseif (GetConVar(convar):GetInt() == 1) then -- add float check pls
                RunConsoleCommand(convar, "0")
                surface.PlaySound("chicagoRP_settings/select.wav")
            end
            timer.Simple(0.20, function() -- tweak to look better and tweak times
                if IsValid(self) then
                    self.value = false
                end
            end)
        end
    elseif (GetConVar(convar):GetInt() >= 0 or GetConVar(convar):GetInt() <= 0) and (max > 1) and ConVarExists(convar) then
        local settingsSliderParent = parent:Add("DButton")
        settingsSliderParent:SetText("")
        settingsSliderParent:Dock(TOP)
        settingsSliderParent:DockMargin(0, 0, 3, 4)
        settingsSliderParent:SetSize(TheCoolerScreenScale(1340), TheCoolerScreenScale(50))

        function settingsSliderParent:Paint(w, h)
            local hovered = self:IsHovered()
            local childhovered = self:IsChildHovered()
            local buf, step = self.__hoverBuf or 0, RealFrameTime() * 4

            if (hovered or childhovered) and buf < 1 then
                buf = math.min(1, step + buf)
            elseif (!hovered and !childhovered) and buf > 0 then
                buf = math.max(0, buf - step)
            end

            self.__hoverBuf = buf
            buf = math.EaseInOut(buf, 0.2, 0.2)
            local alpha, clr = Lerp(buf, 80, 80), Lerp(buf, 40, 80)

            surface.SetDrawColor(clr, clr, clr, alpha)
            surface.DrawRect(0, 0, w, h)
            -----
            local Outlinebuf, Outlinestep = self.__hoverOutlineBuf or 0, RealFrameTime() * 4

            if (hovered or childhovered) and Outlinebuf < 1 then
                Outlinebuf = math.min(1, Outlinestep + Outlinebuf)
            elseif (!hovered and !childhovered) and Outlinebuf > 0 then
                Outlinebuf = math.max(0, Outlinebuf - Outlinestep)
            end

            self.__hoverOutlineBuf = Outlinebuf
            Outlinebuf = math.EaseInOut(buf, 0.5, 0.5)
            local alphaOutline = Lerp(buf, 0, 150)

            gradientcolor1.a = alphaOutline
            gradientcolor2.a = alphaOutline

            DrawOutlinedGradientRect(self, gradientcolor1, gradientcolor2, 3)

            if (hovered or childhovered) then
                helptextparent:SetText(helptext)
            end

            draw.DrawText(printname, "MichromaRegular", w - (w - TheCoolerScreenScale(14)), h - (h - TheCoolerScreenScale(12)), primarytext, TEXT_ALIGN_LEFT)
            -- return nil
        end

        local settingsSlider = vgui.Create("DNumSlider", settingsSliderParent)
        local parentW, parentH = settingsSlider:GetParent():GetSize()
        settingsSlider:SetText("")
        settingsSlider:SetSize(AdvancedScreenScale(335, parentW), parentH)
        settingsSlider:SetPos(parentW - self:GetSize(), 0) -- fucking fix this
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
            draw.DrawText(GetConVar(convar):GetInt(), "MichromaRegular", w - (w - TheCoolerScreenScale(325)), h - (h - TheCoolerScreenScale(13)), primarytext, TEXT_ALIGN_RIGHT)
        end

        function settingsSlider.Slider.Knob:Paint(w, h)
            return nil
        end

        function settingsSlider.Slider:OnCursorEntered()
            surface.PlaySound("chicagoRP_settings/hover.wav")
        end

        function settingsSliderParent:OnCursorEntered()
            surface.PlaySound("chicagoRP_settings/hover.wav")
        end

        function settingsSlider:OnValueChanged(value)
            self:SetValue(math.Round(value, 0))
            hoverslide:Stop()
            hoverslide:Play()
        end
    end
end

local function CreateControlsButton(bind, printname, helptext, parent, helptextparent, frame)
    local controlsButton = parent:Add("DButton")
    controlsButton:SetText("")
    controlsButton:Dock(TOP)
    controlsButton:DockMargin(0, 0, 3, 4)
    controlsButton:SetSize(TheCoolerScreenScale(800), TheCoolerScreenScale(44))

    function controlsButton:OnCursorEntered()
        surface.PlaySound("chicagoRP_settings/hover.wav")
    end

    function controlsButton:Paint(w, h)
        local hovered = self:IsHovered()
        local haschildren = self:HasChildren()
        local buf, step = self.__hoverBuf or 0, RealFrameTime() * 4
        local statusString = "Unbound"

        if (hovered or haschildren) and buf < 1 then
            buf = math.min(1, step + buf)
        elseif (!hovered and !haschildren) and buf > 0 then
            buf = math.max(0, buf - step)
        end

        self.__hoverBuf = buf
        buf = math.EaseInOut(buf, 0.2, 0.2)
        local alpha, clr = Lerp(buf, 80, 80), Lerp(buf, 40, 60)

        surface.SetDrawColor(clr, clr, clr, alpha)
        surface.DrawRect(0, 0, w, h)
        -----
        local Outlinebuf, Outlinestep = self.__hoverOutlineBuf or 0, RealFrameTime() * 4

        if (hovered or haschildren) and Outlinebuf < 1 then
            Outlinebuf = math.min(1, Outlinestep + Outlinebuf)
        elseif (!hovered and !haschildren) and Outlinebuf > 0 then
            Outlinebuf = math.max(0, Outlinebuf - Outlinestep)
        end

        self.__hoverOutlineBuf = Outlinebuf
        Outlinebuf = math.EaseInOut(buf, 0.5, 0.5)
        local alphaOutline = Lerp(buf, 0, 150)

        gradientcolor1.a = alphaOutline
        gradientcolor2.a = alphaOutline

        if (self.value != true) then
            DrawOutlinedGradientRect(self, gradientcolor1, gradientcolor2, 3)
        end
        -----
        local pulseBuf, pulseStep = self.__pulseBuf or 0, RealFrameTime() * 5

        if (self.value == true) and pulseBuf < 1 then
            pulseBuf = math.min(1, pulseStep + pulseBuf)
            print(pulseBuf)
        elseif (self.value != true) and pulseBuf > 0 then
            pulseBuf = math.max(0, pulseBuf - pulseStep)
            print(pulseBuf)
        end

        self.__pulseBuf = pulseBuf
        pulseBuf = math.EaseInOut(pulseBuf, 0.2, 0.2)
        local alphaPulse, clrRed, clrGreen, clrBlue, outlinePulse = Lerp(pulseBuf, 40, 40), Lerp(pulseBuf, 0, 150), Lerp(pulseBuf, 0, 20), Lerp(pulseBuf, 0, 30), Lerp(pulseBuf, 0, 4)

        surface.SetDrawColor(clrRed, clrGreen, clrBlue, alphaPulse)
        surface.DrawRect(0, 0, w, h)

        DrawOutlinedGradientRect(self, gradientcolor1, gradientcolor2, outlinePulse)

        if hovered or haschildren then
            helptextparent:SetText(helptext)
        end

        if input.LookupBinding(bind, false) and !haschildren then -- how do we hide this for a certain button?
            statusString = string.upper(input.LookupBinding(bind, false))
            draw.DrawText(statusString, "MichromaRegular", TheCoolerScreenScale(1325), TheCoolerScreenScale(10), primarytext, TEXT_ALIGN_RIGHT)
        end

        draw.DrawText(printname, "MichromaRegular", TheCoolerScreenScale(14), TheCoolerScreenScale(10), primarytext, TEXT_ALIGN_LEFT)
    end

    function controlsButton:DoClick()
        surface.PlaySound("chicagoRP_settings/select.wav")
        self.value = true

        timer.Simple(0.20, function() -- tweak to look better and tweak times
            if IsValid(self) and self.value == true then
                self.value = false
            end
        end)

        if IsValid(OpenControlText) then
            OpenControlText:Remove()
        end

        local controlHelpText = vgui.Create("DLabel", frame)
        controlHelpText:SetPos(TheCoolerScreenScale(1395), TheCoolerScreenScale(880))
        controlHelpText:SetSize(400, 30)
        controlHelpText:SetFont("MichromaHelpText")
        controlHelpText:SetText("Press a key to bind.")

        function controlHelpText:Paint(w, h)
            -- surface.SetDrawColor(200, 0, 0, 10)
            -- surface.DrawRect(0, 0, w, h)
            draw.DrawText(self:GetText(), "MichromaSmall", w - (w - 385), h - (h - 5), primarytext, TEXT_ALIGN_RIGHT)

            return true
        end

        function controlHelpText:OnRemove() -- debug function
            print("helptext removed")
        end

        controlHelpText:SetAlpha(0)
        controlHelpText:AlphaTo(255, 0.2, 0)

        local parentW, parentH = self:GetSize()

        local controlsTextEntry = self:Add("DTextEntry")
        controlsTextEntry:Dock(RIGHT)
        controlsTextEntry:SetSize(AdvancedScreenScale(60, parentW), AdvancedScreenScale(44, parentH))
        controlsTextEntry:RequestFocus() -- please

        function controlsTextEntry:Paint(w, h)
            if math.sin((SysTime() * 1) * 6) > 0 then
                draw.DrawText("__", "MichromaRegular", TheCoolerScreenScale(34), TheCoolerScreenScale(12), primarytext, TEXT_ALIGN_CENTER)
            end
        end

        function controlsTextEntry:OnKeyCode(keyCode)
            local bindblocked = false
            local keyname = tostring(input.GetKeyName(keyCode) .. " ")
            local bindtext = tostring("bind " .. input.GetKeyName(keyCode) .. " " .. bind)
            for k, v in ipairs(blockedbindkeys) do
                if keyCode == v then
                    surface.PlaySound("chicagoRP_settings/back.wav")
                    controlHelpText:SetText("Binding default key blocked.")
                    self:Remove()
                    timer.Simple(5, function()
                        if IsValid(controlHelpText) then
                            controlHelpText:SetAlpha(255)
                            controlHelpText:AlphaTo(0, 0.5, 0)
                        end
                    end)
                    bindblocked = true
                end
            end
            if bindblocked then return end
            print("Please enter bind " .. keyname .. bind .. " in your console.") -- add spaces pls
            SetClipboardText(bindtext)
            surface.PlaySound("chicagoRP_settings/select.wav")
            controlHelpText:SetText("Key bound, paste in console then enter.")

            controlsButton.value = true
            timer.Simple(0.20, function() -- tweak to look better and tweak times
                if IsValid(controlsButton) and controlsButton.value == true then
                    controlsButton.value = false
                end
            end)

            self:Remove()
            timer.Simple(5, function()
                if IsValid(controlHelpText) then
                    controlHelpText:SetAlpha(255)
                    controlHelpText:AlphaTo(0, 0.5, 0)
                end
            end)
        end

        function controlsTextEntry:OnLoseFocus()
            surface.PlaySound("chicagoRP_settings/back.wav")
            controlHelpText:SetText("Bind cancelled.")
            print("bind cancelled")
            self:Remove()
            timer.Simple(5, function()
                if IsValid(controlHelpText) then
                    controlHelpText:SetAlpha(255)
                    controlHelpText:AlphaTo(0, 0.5, 0)
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

    if IsValid(ArcCW.InvHUD) then
        ArcCW.InvHUD:Hide()
    end

    function motherFrame:Paint(w, h)
        if CVarBlur then
            BlurBackground(self)
            draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 0))
        elseif !CVarBlur then
            draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 170))
        end
    end

    motherFrame:SetAlpha(0)
    motherFrame:AlphaTo(255, 0.15, 0)

    motherFrame:MakePopup()
    motherFrame:Center()

    timer.Simple(0.15, function()
        if CVarDSP then
            ply:SetDSP(30, false)
        end
    end)

    surface.PlaySound("chicagoRP_settings/back.wav")

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
    exitButton:SetPos(TheCoolerScreenScale(86), TheCoolerScreenScale(96))
    exitButton:SetSize(80, 20)
    exitButton:SetFont("MichromaSmall")
    exitButton:SetText("  GAME")
    exitButton:SetTextColor(secondarytext)

    function exitButton:DoClick()
        motherFrame:AlphaTo(50, 0.15, 0)
        surface.PlaySound("chicagoRP_settings/back.wav")
        timer.Simple(0.15, function()
            if IsValid(motherFrame) then
                motherFrame:Close()
            end
        end)
    end

    function exitButton:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end
    ---

    local exitIconButton = vgui.Create("DButton", motherFrame)
    exitIconButton:SetPos(TheCoolerScreenScale(77), TheCoolerScreenScale(98))
    exitIconButton:SetSize(TheCoolerScreenScale(14), TheCoolerScreenScale(15))

    function exitIconButton:DoClick()
        motherFrame:AlphaTo(50, 0.15, 0)
        surface.PlaySound("chicagoRP_settings/back.wav")
        timer.Simple(0.15, function()
            if IsValid(motherFrame) then
                motherFrame:Close()
            end
        end)
    end

    function exitIconButton:Paint(w, h)
        surface.SetDrawColor(accenttext)
        surface.SetMaterial(exiticon)
        surface.DrawTexturedRect(0, 0, w, h)
        -- return nil
        return true
    end
    ---

    local settingsLabel = vgui.Create("DLabel", motherFrame)
    settingsLabel:SetPos(TheCoolerScreenScale(101), TheCoolerScreenScale(119))
    settingsLabel:SetSize(130, 20)
    settingsLabel:SetFont("MichromaRegular")
    settingsLabel:SetText("SETTINGS")
    settingsLabel:SetTextColor(primarytext)

    function settingsLabel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end
    ---

    local settingsTitleLabel = vgui.Create("DLabel", motherFrame)
    settingsTitleLabel:SetPos(TheCoolerScreenScale(520), TheCoolerScreenScale(130))
    settingsTitleLabel:SetSize(TheCoolerScreenScale(500), TheCoolerScreenScale(200))
    settingsTitleLabel:SetText("")
    settingsTitleLabel:SetTextColor(primarytext)

    function settingsTitleLabel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        draw.DrawText(self:GetText(), "MichromaLarge", TheCoolerScreenScale(12), TheCoolerScreenScale(12), accenttext, TEXT_ALIGN_LEFT)
        draw.DrawText(self:GetText(), "MichromaLarge", TheCoolerScreenScale(14), TheCoolerScreenScale(10), primarytext, TEXT_ALIGN_LEFT)
        return true
    end
    ---

    local settingsHelpText = vgui.Create("DLabel", motherFrame)
    settingsHelpText:SetPos(TheCoolerScreenScale(100), TheCoolerScreenScale(935))
    settingsHelpText:SetSize(1000, 30) -- scale this and the text somehow
    settingsHelpText:SetFont("MichromaSmall")
    settingsHelpText:SetText("")
    settingsHelpText:SetTextColor(primarytext)

    function settingsHelpText:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end
    ---

    local exitHelpText = vgui.Create("DLabel", motherFrame)
    exitHelpText:SetPos(TheCoolerScreenScale(100), TheCoolerScreenScale(984))
    exitHelpText:SetSize(TheCoolerScreenScale(160), TheCoolerScreenScale(30))
    exitHelpText:SetFont("MichromaHelpText")
    exitHelpText:SetText("[Q]   BACK")
    exitHelpText:SetTextColor(secondarytext)

    function exitHelpText:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end
    ---

    local videoSettingsScrollPanel = vgui.Create("DScrollPanel", motherFrame)
    videoSettingsScrollPanel:SetPos(TheCoolerScreenScale(525), TheCoolerScreenScale(235))
    videoSettingsScrollPanel:SetSize(TheCoolerScreenScale(1360), TheCoolerScreenScale(635))
    videoSettingsScrollPanel:Hide()

    function videoSettingsScrollPanel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        -- print(self:IsVisible())
        return nil
    end

    local videoSettingsScrollBar = videoSettingsScrollPanel:GetVBar() -- mr biden please legalize nuclear bombs
    videoSettingsScrollBar:SetHideButtons(true)
    videoSettingsScrollBar:SetPos(TheCoolerScreenScale(525), TheCoolerScreenScale(235))
    function videoSettingsScrollBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(42, 40, 35, 66))
    end
    function videoSettingsScrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(76, 76, 74, 150))
    end

    for _, v in ipairs(chicagoRPvideoSettingsOptions) do
        CreateSettingsButton(v.printname, v.convar, v.min, v.max, v.text, videoSettingsScrollPanel, settingsHelpText, motherFrame)
    end
    ---

    local gameSettingsScrollPanel = vgui.Create("DScrollPanel", motherFrame)
    gameSettingsScrollPanel:SetPos(TheCoolerScreenScale(525), TheCoolerScreenScale(235))
    gameSettingsScrollPanel:SetSize(TheCoolerScreenScale(1360), TheCoolerScreenScale(635))
    gameSettingsScrollPanel:Hide()

    function gameSettingsScrollPanel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        -- print(self:IsVisible())
        return nil
    end

    local gameSettingsScrollBar = gameSettingsScrollPanel:GetVBar() -- mr biden please legalize nuclear bombs
    gameSettingsScrollBar:SetHideButtons(true)
    gameSettingsScrollBar:SetPos(TheCoolerScreenScale(525), TheCoolerScreenScale(235))
    function gameSettingsScrollBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(42, 40, 35, 66))
    end
    function gameSettingsScrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(76, 76, 74, 150))
    end

    for _, v in ipairs(chicagoRPgameSettingsOptions) do
        CreateSettingsButton(v.printname, v.convar, v.min, v.max, v.text, gameSettingsScrollPanel, settingsHelpText, motherFrame)
    end
    ---

    local controlsSettingsScrollPanel = vgui.Create("DScrollPanel", motherFrame)
    controlsSettingsScrollPanel:SetPos(TheCoolerScreenScale(525), TheCoolerScreenScale(235))
    controlsSettingsScrollPanel:SetSize(TheCoolerScreenScale(1360), TheCoolerScreenScale(635))
    controlsSettingsScrollPanel:Hide()

    function controlsSettingsScrollPanel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        -- print(self:IsVisible())
        return nil
    end

    local controlsSettingsScrollBar = controlsSettingsScrollPanel:GetVBar() -- mr biden please legalize nuclear bombs
    controlsSettingsScrollBar:SetHideButtons(true)
    controlsSettingsScrollBar:SetPos(TheCoolerScreenScale(525), TheCoolerScreenScale(235))
    function controlsSettingsScrollBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(42, 40, 35, 66))
    end
    function controlsSettingsScrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(76, 76, 74, 150))
    end

    for _, v in ipairs(chicagoRPcontrolsSettingsOptions) do
        CreateControlsButton(v.bind, v.printname, v.text, controlsSettingsScrollPanel, settingsHelpText, motherFrame)
    end
    ---

    local controlParentW, controlParentH = controlsSettingsScrollPanel:GetSize()

    local actionLabel = vgui.Create("DLabel", controlsSettingsScrollPanel)
    actionLabel:SetPos(AdvancedScreenScale(10, controlParentW), AdvancedScreenScale(-25, controlParentW))
    actionLabel:SetSize(TheCoolerScreenScale(100), TheCoolerScreenScale(30))
    actionLabel:SetText("ACTION")
    actionLabel:SetTextColor(secondarytext)
    actionLabel:NoClipping(true) -- fuck you derma

    function actionLabel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        draw.DrawText(self:GetText(), "MichromaSmall", 0, 0, secondarytext, TEXT_ALIGN_LEFT)
        return true
    end
    ---

    local bindLabel = vgui.Create("DLabel", controlsSettingsScrollPanel)
    bindLabel:SetPos(AdvancedScreenScale(1380, controlParentW), AdvancedScreenScale(-25, controlParentW)) -- fucking fix this
    bindLabel:SetSize(TheCoolerScreenScale(100), TheCoolerScreenScale(30))
    bindLabel:SetText("BINDING")
    bindLabel:SetTextColor(secondarytext)
    bindLabel:NoClipping(true) -- fuck you derma

    function bindLabel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        draw.DrawText(self:GetText(), "MichromaSmall", TheCoolerScreenScale(96), 0, secondarytext, TEXT_ALIGN_RIGHT)
        return true
    end
    ---

    function motherFrame:OnKeyCodePressed(key)
        if IsValid(OpenScrollPanel) and (key == KEY_ESCAPE or key == KEY_Q) then
            OpenScrollPanel:SetAlpha(255)
            OpenScrollPanel:AlphaTo(0, 0.15, 0)
            settingsTitleLabel:SetAlpha(255)
            settingsTitleLabel:AlphaTo(0, 0.15, 0)
            settingsHelpText:SetAlpha(255)
            settingsHelpText:AlphaTo(0, 0.15, 0)
            surface.PlaySound("chicagoRP_settings/back.wav")
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
            surface.PlaySound("chicagoRP_settings/back.wav")
            timer.Simple(0.15, function()
                if IsValid(self) then
                    self:Close()
                end
            end)
        end
    end
    ---
    local videoSettingsButton = vgui.Create("DButton", motherFrame)
    videoSettingsButton:SetPos(TheCoolerScreenScale(103), TheCoolerScreenScale(230))
    videoSettingsButton:SetSize(TheCoolerScreenScale(394), TheCoolerScreenScale(56))
    videoSettingsButton:SetFont("MichromaRegular")
    videoSettingsButton:SetText("")
    videoSettingsButton:SetTextColor(primarytext)

    function videoSettingsButton:OnCursorEntered()
        surface.PlaySound("chicagoRP_settings/hover.wav")
    end

    function videoSettingsButton:Paint(w, h)
        local panelActive = videoSettingsScrollPanel:IsVisible()
        local hovered = self:IsHovered()
        local buf, step = self.__hoverBuf or 0, RealFrameTime() * 3
        local alpha, clr = Lerp(buf, 0, 34), Lerp(buf, 0, 66) -- end of anim

        if hovered and buf < 1 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != videoSettingsScrollPanel) then
            buf = math.min(1, step + buf)
            alpha, clr = Lerp(buf, 0, 60), Lerp(buf, 0, 66)
        elseif !hovered and buf >= 0 and panelActive and OpenScrollPanel != nil and (OpenScrollPanel == videoSettingsScrollPanel) then -- kill yourself
            buf = math.max(0, buf - step)
            alpha, clr = Lerp(buf, 40, 40), Lerp(buf, 14, 14) -- Lerp(buf, 34, 60), Lerp(buf, 66, 66)
        elseif hovered and buf < 1 and panelActive and (OpenScrollPanel != nil or OpenScrollPanel == videoSettingsScrollPanel) then
            buf = math.min(1, step + buf)
            alpha, clr = Lerp(buf, 40, 60), Lerp(buf, 66, 66) -- Lerp(buf, 60, 34), Lerp(buf, 66, 66)
        elseif !hovered and buf >= 0 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != videoSettingsScrollPanel) then
            buf = math.max(0, buf - step)
            alpha, clr = Lerp(buf, 0, 34), Lerp(buf, 0, 66)
        end

        if hovered and buf >= 1 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != videoSettingsScrollPanel) then
            alpha, clr = Lerp(buf, 0, 60), Lerp(buf, 0, 66)
        elseif !hovered and buf <= 0.02 and panelActive and OpenScrollPanel != nil and (OpenScrollPanel == videoSettingsScrollPanel) then -- kill yourself
            alpha, clr = Lerp(buf, 40, 40), Lerp(buf, 14, 14) -- Lerp(buf, 34, 60), Lerp(buf, 66, 66)
        elseif hovered and buf >= 1 and panelActive and (OpenScrollPanel != nil or OpenScrollPanel == videoSettingsScrollPanel) then
            alpha, clr = Lerp(buf, 30, 60), Lerp(buf, 66, 66) -- Lerp(buf, 60, 34), Lerp(buf, 66, 66)
        elseif !hovered and buf <= 0.02 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != videoSettingsScrollPanel) then
            alpha, clr = Lerp(buf, 0, 34), Lerp(buf, 0, 66)
        end

        self.__hoverBuf = buf
        buf = math.EaseInOut(buf, 0.2, 0.2)
        alpha, clr = alpha, clr

        surface.SetDrawColor(clr, clr, clr, alpha)
        surface.DrawRect(0, 0, w, h)
        -----
        local pulseBuf, pulseStep = self.__pulseBuf or 0, RealFrameTime() * 5

        if (self.value == true) and pulseBuf < 1 then
            pulseBuf = math.min(1, pulseStep + pulseBuf)
            print(pulseBuf)
        elseif (self.value != true) and pulseBuf > 0 then
            pulseBuf = math.max(0, pulseBuf - pulseStep)
            print(pulseBuf)
        end

        self.__pulseBuf = pulseBuf
        pulseBuf = math.EaseInOut(pulseBuf, 0.2, 0.2)
        local alphaPulse, clrRed, clrGreen, clrBlue = Lerp(pulseBuf, 0, 40), Lerp(pulseBuf, 0, 180), Lerp(pulseBuf, 0, 20), Lerp(pulseBuf, 0, 30)
        -- local outlinePulse = Lerp(pulseBuf, 0, 3)

        surface.SetDrawColor(clrRed, clrGreen, clrBlue, alphaPulse)
        surface.DrawRect(0, 0, w, h)

        -- DrawOutlinedGradientRect(self, gradientcolor1, gradientcolor2, outlinePulse)

        draw.DrawText("VIDEO", "MichromaRegular", TheCoolerScreenScale(11), TheCoolerScreenScale(14), primarytext, TEXT_ALIGN_LEFT)
    end

    function videoSettingsButton:DoClick() -- nauseating code but it works and i don't want to touch it
        self.value = true

        timer.Simple(0.20, function() -- tweak to look better and tweak times
            if IsValid(self) and self.value == true then
                self.value = false
            end
        end)

        if IsValid(OpenScrollPanel) and IsValid(settingsTitleLabel) then -- OpenScrollPanel == gamepanel and IsValid(OpenScrollPanel)
            OpenScrollPanel:SetAlpha(255)
            OpenScrollPanel:AlphaTo(0, 0.15, 0)
            settingsTitleLabel:SetAlpha(255)
            settingsTitleLabel:AlphaTo(0, 0.15, 0)
            settingsHelpText:SetAlpha(255)
            settingsHelpText:AlphaTo(0, 0.15, 0)
            timer.Simple(0.15, function()
                if IsValid(OpenScrollPanel) then
                    OpenScrollPanel:Hide()
                    settingsHelpText:SetText("")
                end
            end)
            timer.Simple(0.15, function()
                if IsValid(OpenScrollPanel) and OpenScrollPanel == videoSettingsScrollPanel and !OpenScrollPanel:IsVisible() then
                    OpenScrollPanel = nil
                end
            end)
            if OpenScrollPanel == nil then return end
            timer.Simple(0.2, function()
                if IsValid(videoSettingsScrollPanel) and IsValid(settingsTitleLabel) and IsValid(OpenScrollPanel) then
                    settingsTitleLabel:SetAlpha(0)
                    settingsTitleLabel:AlphaTo(255, 0.15, 0)
                    settingsHelpText:SetAlpha(0)
                    settingsHelpText:AlphaTo(255, 0.15, 0)
                    videoSettingsScrollPanel:Show()
                    videoSettingsScrollPanel:SetAlpha(0)
                    videoSettingsScrollPanel:AlphaTo(255, 0.15, 0)
                    settingsTitleLabel:SetText("VIDEO")
                    OpenScrollPanel = videoSettingsScrollPanel
                end
            end)
        elseif IsValid(videoSettingsScrollPanel) and !IsValid(OpenScrollPanel) and IsValid(settingsTitleLabel) then
            settingsTitleLabel:SetAlpha(0)
            settingsTitleLabel:AlphaTo(255, 0.15, 0)
            settingsHelpText:SetAlpha(0)
            settingsHelpText:AlphaTo(255, 0.15, 0)
            videoSettingsScrollPanel:Show()
            videoSettingsScrollPanel:SetAlpha(0)
            videoSettingsScrollPanel:AlphaTo(255, 0.15, 0)
            settingsTitleLabel:SetText("VIDEO")
            OpenScrollPanel = videoSettingsScrollPanel
        end
        surface.PlaySound("chicagoRP_settings/select.wav")
    end
    ---

    local gameSettingsButton = vgui.Create("DButton", motherFrame)
    gameSettingsButton:SetPos(TheCoolerScreenScale(103), TheCoolerScreenScale(290))
    gameSettingsButton:SetSize(TheCoolerScreenScale(394), TheCoolerScreenScale(56))
    gameSettingsButton:SetFont("MichromaRegular")
    gameSettingsButton:SetText("")
    gameSettingsButton:SetTextColor(primarytext)
    print(TheCoolerScreenScale(103))

    function gameSettingsButton:OnCursorEntered()
        surface.PlaySound("chicagoRP_settings/hover.wav")
    end

    function gameSettingsButton:Paint(w, h)
        local panelActive = gameSettingsScrollPanel:IsVisible()
        local hovered = self:IsHovered()
        local buf, step = self.__hoverBuf or 0, RealFrameTime() * 3
        local alpha, clr = Lerp(buf, 0, 34), Lerp(buf, 0, 66) -- end of anim

        if hovered and buf < 1 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != gameSettingsScrollPanel) then
            buf = math.min(1, step + buf)
            alpha, clr = Lerp(buf, 0, 60), Lerp(buf, 0, 66)
        elseif !hovered and buf >= 0 and panelActive and OpenScrollPanel != nil and (OpenScrollPanel == gameSettingsScrollPanel) then -- kill yourself
            buf = math.max(0, buf - step)
            alpha, clr = Lerp(buf, 40, 40), Lerp(buf, 14, 14) -- Lerp(buf, 34, 60), Lerp(buf, 66, 66)
        elseif hovered and buf < 1 and panelActive and (OpenScrollPanel != nil or OpenScrollPanel == gameSettingsScrollPanel) then
            buf = math.min(1, step + buf)
            alpha, clr = Lerp(buf, 40, 60), Lerp(buf, 66, 66) -- Lerp(buf, 60, 34), Lerp(buf, 66, 66)
        elseif !hovered and buf >= 0 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != gameSettingsScrollPanel) then
            buf = math.max(0, buf - step)
            alpha, clr = Lerp(buf, 0, 34), Lerp(buf, 0, 66)
        end

        if hovered and buf >= 1 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != gameSettingsScrollPanel) then
            alpha, clr = Lerp(buf, 0, 60), Lerp(buf, 0, 66)
        elseif !hovered and buf <= 0.02 and panelActive and OpenScrollPanel != nil and (OpenScrollPanel == gameSettingsScrollPanel) then -- kill yourself
            alpha, clr = Lerp(buf, 40, 40), Lerp(buf, 14, 14) -- Lerp(buf, 34, 60), Lerp(buf, 66, 66)
        elseif hovered and buf >= 1 and panelActive and (OpenScrollPanel != nil or OpenScrollPanel == gameSettingsScrollPanel) then
            alpha, clr = Lerp(buf, 30, 60), Lerp(buf, 66, 66) -- Lerp(buf, 60, 34), Lerp(buf, 66, 66)
        elseif !hovered and buf <= 0.02 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != gameSettingsScrollPanel) then
            alpha, clr = Lerp(buf, 0, 34), Lerp(buf, 0, 66)
        end

        self.__hoverBuf = buf
        buf = math.EaseInOut(buf, 0.2, 0.2)
        alpha, clr = alpha, clr

        surface.SetDrawColor(clr, clr, clr, alpha)
        surface.DrawRect(0, 0, w, h)
        -----
        local pulseBuf, pulseStep = self.__pulseBuf or 0, RealFrameTime() * 5

        if (self.value == true) and pulseBuf < 1 then
            pulseBuf = math.min(1, pulseStep + pulseBuf)
            print(pulseBuf)
        elseif (self.value != true) and pulseBuf > 0 then
            pulseBuf = math.max(0, pulseBuf - pulseStep)
            print(pulseBuf)
        end

        self.__pulseBuf = pulseBuf
        pulseBuf = math.EaseInOut(pulseBuf, 0.2, 0.2)
        local alphaPulse, clrRed, clrGreen, clrBlue = Lerp(pulseBuf, 0, 40), Lerp(pulseBuf, 0, 180), Lerp(pulseBuf, 0, 20), Lerp(pulseBuf, 0, 30)
        -- local outlinePulse = Lerp(pulseBuf, 0, 3)

        surface.SetDrawColor(clrRed, clrGreen, clrBlue, alphaPulse)
        surface.DrawRect(0, 0, w, h)

        -- DrawOutlinedGradientRect(self, gradientcolor1, gradientcolor2, outlinePulse)

        draw.DrawText("GAME", "MichromaRegular", TheCoolerScreenScale(11), TheCoolerScreenScale(14), primarytext, TEXT_ALIGN_LEFT)
    end

    function gameSettingsButton:DoClick() -- nauseating code but it works and i don't want to touch it
        self.value = true

        timer.Simple(0.20, function() -- tweak to look better and tweak times
            if IsValid(self) and self.value == true then
                self.value = false
            end
        end)

        if IsValid(OpenScrollPanel) and IsValid(settingsTitleLabel) then -- OpenScrollPanel == gamepanel and IsValid(OpenScrollPanel)
            OpenScrollPanel:SetAlpha(255)
            OpenScrollPanel:AlphaTo(0, 0.15, 0)
            settingsTitleLabel:SetAlpha(255)
            settingsTitleLabel:AlphaTo(0, 0.15, 0)
            settingsHelpText:SetAlpha(255)
            settingsHelpText:AlphaTo(0, 0.15, 0)
            timer.Simple(0.15, function()
                if IsValid(OpenScrollPanel) then
                    OpenScrollPanel:Hide()
                    settingsHelpText:SetText("")
                end
            end)
            timer.Simple(0.15, function()
                if IsValid(OpenScrollPanel) and OpenScrollPanel == gameSettingsScrollPanel and !OpenScrollPanel:IsVisible() then
                    OpenScrollPanel = nil
                end
            end)
            if OpenScrollPanel == nil then return end
            timer.Simple(0.2, function()
                if IsValid(gameSettingsScrollPanel) and IsValid(settingsTitleLabel) and IsValid(OpenScrollPanel) then
                    settingsTitleLabel:SetAlpha(0)
                    settingsTitleLabel:AlphaTo(255, 0.15, 0)
                    settingsHelpText:SetAlpha(0)
                    settingsHelpText:AlphaTo(255, 0.15, 0)
                    gameSettingsScrollPanel:Show()
                    gameSettingsScrollPanel:SetAlpha(0)
                    gameSettingsScrollPanel:AlphaTo(255, 0.15, 0)
                    settingsTitleLabel:SetText("GAME")
                    OpenScrollPanel = gameSettingsScrollPanel
                end
            end)
        elseif IsValid(gameSettingsScrollPanel) and !IsValid(OpenScrollPanel) and IsValid(settingsTitleLabel) then
            settingsTitleLabel:SetAlpha(0)
            settingsTitleLabel:AlphaTo(255, 0.15, 0)
            settingsHelpText:SetAlpha(0)
            settingsHelpText:AlphaTo(255, 0.15, 0)
            gameSettingsScrollPanel:Show()
            gameSettingsScrollPanel:SetAlpha(0)
            gameSettingsScrollPanel:AlphaTo(255, 0.15, 0)
            settingsTitleLabel:SetText("GAME")
            OpenScrollPanel = gameSettingsScrollPanel
        end
        surface.PlaySound("chicagoRP_settings/select.wav")
    end
    ---

    local controlsSettingsButton = vgui.Create("DButton", motherFrame)
    controlsSettingsButton:SetPos(TheCoolerScreenScale(103), TheCoolerScreenScale(350))
    controlsSettingsButton:SetSize(TheCoolerScreenScale(394), TheCoolerScreenScale(56))
    controlsSettingsButton:SetFont("MichromaRegular")
    controlsSettingsButton:SetText("")
    controlsSettingsButton:SetTextColor(primarytext)

    function controlsSettingsButton:OnCursorEntered()
        surface.PlaySound("chicagoRP_settings/hover.wav")
    end

    function controlsSettingsButton:Paint(w, h)
        local panelActive = controlsSettingsScrollPanel:IsVisible()
        local hovered = self:IsHovered()
        local buf, step = self.__hoverBuf or 0, RealFrameTime() * 3
        local alpha, clr = Lerp(buf, 0, 34), Lerp(buf, 0, 66) -- end of anim

        if hovered and buf < 1 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != controlsSettingsScrollPanel) then
            buf = math.min(1, step + buf)
            alpha, clr = Lerp(buf, 0, 60), Lerp(buf, 0, 66)
        elseif !hovered and buf >= 0 and panelActive and OpenScrollPanel != nil and (OpenScrollPanel == controlsSettingsScrollPanel) then -- kill yourself
            buf = math.max(0, buf - step)
            alpha, clr = Lerp(buf, 40, 40), Lerp(buf, 14, 14) -- Lerp(buf, 34, 60), Lerp(buf, 66, 66)
        elseif hovered and buf < 1 and panelActive and (OpenScrollPanel != nil or OpenScrollPanel == controlsSettingsScrollPanel) then
            buf = math.min(1, step + buf)
            alpha, clr = Lerp(buf, 40, 60), Lerp(buf, 66, 66) -- Lerp(buf, 60, 34), Lerp(buf, 66, 66)
        elseif !hovered and buf >= 0 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != controlsSettingsScrollPanel) then
            buf = math.max(0, buf - step)
            alpha, clr = Lerp(buf, 0, 34), Lerp(buf, 0, 66)
        end

        if hovered and buf >= 1 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != controlsSettingsScrollPanel) then
            alpha, clr = Lerp(buf, 0, 60), Lerp(buf, 0, 66)
        elseif !hovered and buf <= 0.02 and panelActive and OpenScrollPanel != nil and (OpenScrollPanel == controlsSettingsScrollPanel) then -- kill yourself
            alpha, clr = Lerp(buf, 40, 40), Lerp(buf, 14, 14) -- Lerp(buf, 34, 60), Lerp(buf, 66, 66)
        elseif hovered and buf >= 1 and panelActive and (OpenScrollPanel != nil or OpenScrollPanel == controlsSettingsScrollPanel) then
            alpha, clr = Lerp(buf, 30, 60), Lerp(buf, 66, 66) -- Lerp(buf, 60, 34), Lerp(buf, 66, 66)
        elseif !hovered and buf <= 0.02 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != controlsSettingsScrollPanel) then
            alpha, clr = Lerp(buf, 0, 34), Lerp(buf, 0, 66)
        end

        self.__hoverBuf = buf
        buf = math.EaseInOut(buf, 0.2, 0.2)
        alpha, clr = alpha, clr

        surface.SetDrawColor(clr, clr, clr, alpha)
        surface.DrawRect(0, 0, w, h)
        -----
        local pulseBuf, pulseStep = self.__pulseBuf or 0, RealFrameTime() * 5

        if (self.value == true) and pulseBuf < 1 then
            pulseBuf = math.min(1, pulseStep + pulseBuf)
            print(pulseBuf)
        elseif (self.value != true) and pulseBuf > 0 then
            pulseBuf = math.max(0, pulseBuf - pulseStep)
            print(pulseBuf)
        end

        self.__pulseBuf = pulseBuf
        pulseBuf = math.EaseInOut(pulseBuf, 0.2, 0.2)
        local alphaPulse, clrRed, clrGreen, clrBlue = Lerp(pulseBuf, 0, 40), Lerp(pulseBuf, 0, 150), Lerp(pulseBuf, 0, 20), Lerp(pulseBuf, 0, 30)
        -- local outlinePulse = Lerp(pulseBuf, 0, 3)

        surface.SetDrawColor(clrRed, clrGreen, clrBlue, alphaPulse)
        surface.DrawRect(0, 0, w, h)

        -- DrawOutlinedGradientRect(self, gradientcolor1, gradientcolor2, outlinePulse)

        draw.DrawText("CONTROLS", "MichromaRegular", TheCoolerScreenScale(11), TheCoolerScreenScale(14), primarytext, TEXT_ALIGN_LEFT)
    end

    function controlsSettingsButton:DoClick() -- nauseating code but it works and i don't want to touch it
        self.value = true

        timer.Simple(0.20, function() -- tweak to look better and tweak times
            if IsValid(self) and self.value == true then
                self.value = false
            end
        end)

        if IsValid(OpenScrollPanel) and IsValid(settingsTitleLabel) then
            OpenScrollPanel:SetAlpha(255)
            OpenScrollPanel:AlphaTo(0, 0.15, 0)
            settingsTitleLabel:SetAlpha(255)
            settingsTitleLabel:AlphaTo(0, 0.15, 0)
            settingsHelpText:SetAlpha(255)
            settingsHelpText:AlphaTo(0, 0.15, 0)
            timer.Simple(0.15, function()
                if IsValid(OpenScrollPanel) then
                    OpenScrollPanel:Hide()
                    settingsHelpText:SetText("")
                end
            end)
            timer.Simple(0.15, function()
                if IsValid(OpenScrollPanel) and OpenScrollPanel == controlsSettingsScrollPanel and !OpenScrollPanel:IsVisible() then
                    OpenScrollPanel = nil
                end
            end)
            if OpenScrollPanel == nil then return end
            timer.Simple(0.2, function()
                if IsValid(controlsSettingsScrollPanel) and IsValid(settingsTitleLabel) and IsValid(OpenScrollPanel) then
                    settingsTitleLabel:SetAlpha(0)
                    settingsTitleLabel:AlphaTo(255, 0.15, 0)
                    settingsHelpText:SetAlpha(0)
                    settingsHelpText:AlphaTo(255, 0.15, 0)
                    controlsSettingsScrollPanel:Show()
                    controlsSettingsScrollPanel:SetAlpha(0)
                    controlsSettingsScrollPanel:AlphaTo(255, 0.15, 0)
                    settingsTitleLabel:SetText("KEY BINDINGS")
                    OpenScrollPanel = controlsSettingsScrollPanel
                end
            end)
        elseif IsValid(controlsSettingsScrollPanel) and !IsValid(OpenScrollPanel) and IsValid(settingsTitleLabel) then
            settingsTitleLabel:SetAlpha(0)
            settingsTitleLabel:AlphaTo(255, 0.15, 0)
            settingsHelpText:SetAlpha(0)
            settingsHelpText:AlphaTo(255, 0.15, 0)
            controlsSettingsScrollPanel:Show()
            controlsSettingsScrollPanel:SetAlpha(0)
            controlsSettingsScrollPanel:AlphaTo(255, 0.15, 0)
            settingsTitleLabel:SetText("KEY BINDINGS")
            OpenScrollPanel = controlsSettingsScrollPanel
        end
        surface.PlaySound("chicagoRP_settings/select.wav")
    end

    OpenMotherFrame = motherFrame
end)

print("chicagoRP GUI loaded!")

-- still need:
-- fix binding label, fix slider position, fix slider text, make scalable height(?)
-- tighten up UI layout
-- optimization
-- make creating categories not awful