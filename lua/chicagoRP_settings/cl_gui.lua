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
local TrueFrameTime = RealFrameTime()
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
local pulseredfrom, pulseredto = 0, 150
local pulsegreenfrom, pulsegreento = 0, 20
local pulsebluefrom, pulseblueto = 0, 30
local pulsealphafrom, pulsealphato = 0, 80
local altpulseredfrom, altpulseredto = 0, 180
local altpulsegreenfrom, altpulsegreento = 0, 20
local altpulsebluefrom, altpulseblueto = 0, 30
local alptulsealphafrom, altpulsealphato = 0, 40

local function BlurBackground(panel)
    if (!IsValid(panel) or !panel:IsVisible()) then return end
    local layers, density, alpha = 1, 1, 100
    local x, y = panel:LocalToScreen(0, 0)
    local FrameRate, Num, Dark = 1 / TrueFrameTime, 5, 150

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

local function ButtonFade(panel, w, h, clrfrom, clrto, alphafrom, alphato, speed, children)
    if (children == nil) then children = false end

    local hovered = panel:IsHovered()
    local haschild = panel:HasChildren()
    local childhovered = nil
    local buf, step = panel.__hoverBuf or 0, TrueFrameTime * speed

    if haschild and children == true then
        childhovered = self:GetChild(0):IsHovered()
    end

    if children == false then -- we can combine this check
        if hovered and buf < 1 then
            buf = math.min(1, step + buf)
        elseif !hovered and buf > 0 then
            buf = math.max(0, buf - step)
        end
    elseif children == true then
        if (hovered or childhovered) and buf < 1 then
            buf = math.min(1, step + buf)
        elseif (!hovered and !childhovered) and buf > 0 then
            buf = math.max(0, buf - step)
        end
    end

    panel.__hoverBuf = buf
    buf = math.EaseInOut(buf, 0.2, 0.2)
    local alpha, clr = Lerp(buf, alphafrom, alphato), Lerp(buf, clrfrom, clrto)

    surface.SetDrawColor(clr, clr, clr, alpha)
    surface.DrawRect(0, 0, w, h)
end

local function OutlineFade(panel, w, h, alphafrom, alphato, speed, children)
    if (children == nil) then children = false end

    local hovered = panel:IsHovered()
    local haschild = panel:HasChildren()
    local childhovered = nil
    local Outlinebuf, Outlinestep = panel.__hoverOutlineBuf or 0, TrueFrameTime * speed

    if haschild and children == true then
        childhovered = self:GetChild(0):IsHovered()
    end

    if children == false then -- we can combine this check
        if hovered and Outlinebuf < 1 then
            Outlinebuf = math.min(1, Outlinestep + Outlinebuf)
        elseif !hovered and Outlinebuf > 0 then
            Outlinebuf = math.max(0, Outlinebuf - Outlinestep)
        end
    elseif children == true then
        if (hovered or childhovered) and Outlinebuf < 1 then
            Outlinebuf = math.min(1, Outlinestep + Outlinebuf)
        elseif (!hovered and !childhovered) and Outlinebuf > 0 then
            Outlinebuf = math.max(0, Outlinebuf - Outlinestep)
        end
    end

    panel.__hoverOutlineBuf = Outlinebuf
    Outlinebuf = math.EaseInOut(Outlinebuf, 0.5, 0.5)
    local alphaOutline = Lerp(Outlinebuf, alphafrom, alphato)

    gradientcolor1.a = alphaOutline
    gradientcolor2.a = alphaOutline
end

local function Pulse(panel, w, h, clrredto, clrredfrom, clrgreenfrom, clrgreento, clrbluefrom, clrblueto, alphafrom, alphato, pulsevalue, speed, disableoutline) -- the cracker
    if (disableoutline == nil) then disableoutline = false end

    if (pulsevalue != true) and disableoutline == false then
        DrawOutlinedGradientRect(panel, gradientcolor1, gradientcolor2, 3)
    end

    local pulseBuf, pulseStep = panel.__pulseBuf or 0, TrueFrameTime * speed

    if (pulsevalue == true) and pulseBuf < 1 then
        pulseBuf = math.min(1, pulseStep + pulseBuf)
        print(pulseBuf)
    elseif (pulsevalue != true) and pulseBuf > 0 then
        pulseBuf = math.max(0, pulseBuf - pulseStep)
        print(pulseBuf)
    end

    panel.__pulseBuf = pulseBuf
    pulseBuf = math.EaseInOut(pulseBuf, 0.2, 0.2)
    local alphaPulse = Lerp(pulseBuf, alphafrom, alphato)
    local clrRed, clrGreen, clrBlue = Lerp(pulseBuf, clrredto, clrredfrom), Lerp(pulseBuf, clrgreenfrom, clrgreento), Lerp(pulseBuf, clrbluefrom, clrblueto)
    local outlinePulse = Lerp(pulseBuf, 0, 4)

    surface.SetDrawColor(clrRed, clrGreen, clrBlue, alphaPulse)
    surface.DrawRect(0, 0, w, h)

    if disableoutline == false then
        DrawOutlinedGradientRect(panel, gradientcolor1, gradientcolor2, outlinePulse)
    end
end


local function HoverSound()
    local hoverslide = CreateSound(game.GetWorld(), "chicagoRP_settings/hover_slide.wav", 0)
    if hoverslide then
        hoverslide:SetSoundLevel(0)
        hoverslide:Stop() -- it won't play again otherwise
        hoverslide:Play()
    end
    return hoverslide -- useful if you want to stop the sound yourself
end

local function PanelFadeIn(panel, length)
    if !IsValid(panel) then return end

    panel:SetAlpha(0)
    panel:AlphaTo(255, length, 0)
end

local function PanelFadeOut(panel, length)
    if !IsValid(panel) then return end

    panel:SetAlpha(255)
    panel:AlphaTo(0, length, 0)
end

local function HorizontalScreenScale(size)
    return math.Round(size * (ScrW() / 1920.0))
end

local function VerticalScreenScale(size)
    return math.Round(size * (ScrH() / 1080.0))
end

local function AdvancedHorizontalScreenScale(size, divisor)
    return math.Round(size * (divisor / 1920.0))
end

local function AdvancedVerticalScreenScale(size, divisor)
    return math.Round(size * (divisor / 1080.0))
end

local function CreateSettingsButton(printname, convar, min, max, helptext, parent, helptextparent, frame)
    local CVarColorPulse = GetConVar("chicagoRP_clickpulse"):GetBool()

    if (GetConVar(convar):GetInt() == 0 or GetConVar(convar):GetInt() == 1) and (max == 1) and ConVarExists(convar) then
        local settingsButton = parent:Add("DButton")
        settingsButton:SetText("")
        settingsButton:Dock(TOP)
        settingsButton:DockMargin(0, 0, 3, 4)
        settingsButton:SetSize(HorizontalScreenScale(1340), VerticalScreenScale(50))
        print(VerticalScreenScale(50))

        function settingsButton:OnCursorEntered()
            surface.PlaySound("chicagoRP_settings/hover.wav")
        end

        function settingsButton:Paint(w, h)
            local hovered = self:IsHovered()
            -- local bufIn, stepIn = self.__hoverBufIn or 0, TrueFrameTime * 4

            -- if hovered and bufIn < 1 then
            --     bufIn = math.min(1, stepIn + bufIn)
            -- elseif !hovered and bufIn > 0 then
            --     bufIn = math.max(0, bufIn - stepIn)
            -- end

            -- self.__hoverBufIn = bufIn
            -- bufIn = math.EaseInOut(bufIn, 0.2, 0.2)
            -- local alpha, clr = Lerp(bufIn, 80, 80), Lerp(bufIn, 40, 80)

            -- surface.SetDrawColor(clr, clr, clr, alpha)
            -- surface.DrawRect(0, 0, w, h)
            -- -----
            -- local bufOutlineIn, stepOutlineIn = self.__hoverbufOutlineIn or 0, TrueFrameTime * 4

            -- if hovered and bufOutlineIn < 1 then
            --     bufOutlineIn = math.min(1, stepOutlineIn + bufOutlineIn)
            -- elseif !hovered and bufOutlineIn > 0 then
            --     bufOutlineIn = math.max(0, bufOutlineIn - stepOutlineIn)
            -- end

            -- self.__hoverbufOutlineIn = bufOutlineIn
            -- bufOutlineIn = math.EaseInOut(bufOutlineIn, 0.5, 0.5)
            -- local alphaOutline = Lerp(bufOutlineIn, 0, 180)

            -- gradientcolor1.a = alphaOutline
            -- gradientcolor2.a = alphaOutline

            -- -- DrawOutlinedGradientRect(self, gradientcolor1, gradientcolor2, 3)
            -- if (self.pulse != true) then
            --     DrawOutlinedGradientRect(self, gradientcolor1, gradientcolor2, 3)
            -- end
            -- -----
            -- local pulseBuf, pulseStep = self.__pulseBuf or 0, TrueFrameTime * 5

            -- if (self.pulse == true) and pulseBuf < 1 then
            --     pulseBuf = math.min(1, pulseStep + pulseBuf)
            --     print(pulseBuf)
            -- elseif (self.pulse != true) and pulseBuf > 0 then
            --     pulseBuf = math.max(0, pulseBuf - pulseStep)
            --     print(pulseBuf)
            -- end

            -- self.__pulseBuf = pulseBuf
            -- pulseBuf = math.EaseInOut(pulseBuf, 0.2, 0.2)
            -- local alphaPulse, clrRed, clrGreen, clrBlue, outlinePulse = Lerp(pulseBuf, 0, 80), Lerp(pulseBuf, 0, 150), Lerp(pulseBuf, 0, 20), Lerp(pulseBuf, 0, 30), Lerp(pulseBuf, 0, 4)

            -- surface.SetDrawColor(clrRed, clrGreen, clrBlue, alphaPulse)
            -- surface.DrawRect(0, 0, w, h)

            -- DrawOutlinedGradientRect(self, gradientcolor1, gradientcolor2, outlinePulse)

            ButtonFade(self, w, h, 40, 80, 80, 80, 4, false)
            -----

            OutlineFade(self, w, h, 0, 180, 4, false)
            -----

            Pulse(self, w, h, pulseredfrom, pulseredto, pulsegreenfrom, pulsegreento, pulsebluefrom, pulseblueto, pulsealphafrom, pulsealphato, self.pulse, 5)

            if hovered then
                helptextparent:SetText(helptext)
            end

            if (GetConVar(convar):GetInt() == 0) and (max == 1) then
                surface.SetDrawColor(primarytext:Unpack())
                RoundedOutline(roundedOutlineMat, HorizontalScreenScale(1300), VerticalScreenScale(14), 22, 22, 1, 1, 1, 1)
            elseif (GetConVar(convar):GetInt() == 1) and (max == 1) then
                surface.SetDrawColor(primarytext:Unpack())
                draw.RoundedBox(4, HorizontalScreenScale(1305), VerticalScreenScale(19), 12, 12, primarytext)
                RoundedOutline(roundedOutlineMat, HorizontalScreenScale(1300), VerticalScreenScale(14), 22, 22, 1, 1, 1, 1)
            elseif (GetConVar(convar):GetInt() >= 0) and (max > 1) then
                local statusString = GetConVar(convar):GetInt()
                draw.DrawText(statusString, "MichromaRegular", HorizontalScreenScale(790), VerticalScreenScale(12), primarytext, TEXT_ALIGN_RIGHT)
            end

            draw.DrawText(printname, "MichromaRegular", HorizontalScreenScale(14), VerticalScreenScale(12), primarytext, TEXT_ALIGN_LEFT)
        end

        function settingsButton:DoClick()
            self.pulse = true

            timer.Simple(0.20, function() -- tweak to look better and tweak times
                if IsValid(self) then
                    self.pulse = false
                end
            end)

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
        settingsSliderParent:SetSize(HorizontalScreenScale(1340), VerticalScreenScale(50))

        function settingsSliderParent:OnCursorEntered()
            surface.PlaySound("chicagoRP_settings/hover.wav")
        end

        function settingsSliderParent:Paint(w, h)
            local hovered = self:IsHovered()
            local childhovered = self:IsChildHovered()
            -----
            -- local Outlinebuf, Outlinestep = self.__hoverOutlineBuf or 0, TrueFrameTime * 4

            -- if (hovered or childhovered) and Outlinebuf < 1 then
            --     Outlinebuf = math.min(1, Outlinestep + Outlinebuf)
            -- elseif (!hovered and !childhovered) and Outlinebuf > 0 then
            --     Outlinebuf = math.max(0, Outlinebuf - Outlinestep)
            -- end

            -- self.__hoverOutlineBuf = Outlinebuf
            -- Outlinebuf = math.EaseInOut(buf, 0.5, 0.5)
            -- local alphaOutline = Lerp(buf, 0, 150)

            -- gradientcolor1.a = alphaOutline
            -- gradientcolor2.a = alphaOutline

            -- DrawOutlinedGradientRect(self, gradientcolor1, gradientcolor2, 3)

            ButtonFade(self, w, h, 40, 80, 80, 80, 4, true)

            OutlineFade(self, w, h, 0, 150, 4, true) -- work you actual piece of shit

            DrawOutlinedGradientRect(self, gradientcolor1, gradientcolor2, 3)

            if (hovered or childhovered) then
                helptextparent:SetText(helptext)
            end

            draw.DrawText(printname, "MichromaRegular", HorizontalScreenScale(14), VerticalScreenScale(12), primarytext, TEXT_ALIGN_LEFT)
            -- return nil
        end

        local settingsSlider = vgui.Create("DNumSlider", settingsSliderParent)
        local parentW, parentH = settingsSliderParent:GetSize()
        settingsSlider:SetText("")
        settingsSlider:SetSize(HorizontalScreenScale(335), parentH) -- 234
        settingsSlider:SetPos(parentW - settingsSlider:GetSize(), 0) -- fix this
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
            draw.DrawText(GetConVar(convar):GetInt(), "MichromaRegular", HorizontalScreenScale(325), VerticalScreenScale(13), primarytext, TEXT_ALIGN_RIGHT)
        end

        function settingsSlider.Slider.Knob:Paint(w, h)
            return nil
        end

        function settingsSlider.Slider:OnCursorEntered()
            surface.PlaySound("chicagoRP_settings/hover.wav")
        end

        function settingsSlider:OnValueChanged(value)
            self:SetValue(math.Round(value, 0))
            HoverSound()
            -- print(value)
        end
    end
end

local function CreateControlsButton(bind, printname, helptext, parent, helptextparent, frame)
    local controlsButton = parent:Add("DButton")
    controlsButton:SetText("")
    controlsButton:Dock(TOP)
    controlsButton:DockMargin(0, 0, 3, 4)
    controlsButton:SetSize(HorizontalScreenScale(800), VerticalScreenScale(44))

    function controlsButton:OnCursorEntered()
        surface.PlaySound("chicagoRP_settings/hover.wav")
    end

    function controlsButton:Paint(w, h)
        local hovered = self:IsHovered()
        local haschildren = self:HasChildren()
        local statusString = "Unbound"
        -----

        ButtonFade(self, w, h, 40, 80, 80, 80, 4, true)
        -----

        OutlineFade(self, w, h, 0, 150, 4, true)
        -----

        Pulse(self, w, h, pulseredfrom, pulseredto, pulsegreenfrom, pulsegreento, pulsebluefrom, pulseblueto, pulsealphafrom, pulsealphato, self.pulse, 5)
        -----

        if hovered or haschildren then
            helptextparent:SetText(helptext)
        end

        if input.LookupBinding(bind, false) and !haschildren then -- how do we hide this for a certain button?
            statusString = string.upper(input.LookupBinding(bind, false))
            draw.DrawText(statusString, "MichromaRegular", HorizontalScreenScale(1325), VerticalScreenScale(10), primarytext, TEXT_ALIGN_RIGHT)
        end

        draw.DrawText(printname, "MichromaRegular", HorizontalScreenScale(14), VerticalScreenScale(10), primarytext, TEXT_ALIGN_LEFT)
    end

    function controlsButton:DoClick()
        surface.PlaySound("chicagoRP_settings/select.wav")
        self.pulse = true

        timer.Simple(0.20, function() -- tweak to look better and tweak times
            if IsValid(self) and self.pulse == true then
                self.pulse = false
            end
        end)

        if IsValid(OpenControlText) then
            OpenControlText:Remove()
        end

        local controlHelpText = vgui.Create("DLabel", frame)
        controlHelpText:SetPos(HorizontalScreenScale(1470), VerticalScreenScale(930))
        controlHelpText:SetSize(HorizontalScreenScale(400), 30)
        controlHelpText:SetFont("MichromaHelpText")
        controlHelpText:SetText("Press a key to bind.")

        function controlHelpText:Paint(w, h)
            -- surface.SetDrawColor(200, 0, 0, 10)
            -- surface.DrawRect(0, 0, w, h)
            draw.DrawText(self:GetText(), "MichromaSmall", HorizontalScreenScale(390), VerticalScreenScale(5), primarytext, TEXT_ALIGN_RIGHT)

            return true
        end

        function controlHelpText:OnRemove() -- debug function
            print("helptext removed")
        end

        PanelFadeIn(controlHelpText, 0.2)

        local parentW, parentH = self:GetSize()

        local controlsTextEntry = self:Add("DTextEntry")
        controlsTextEntry:Dock(RIGHT)
        controlsTextEntry:SetSize(AdvancedHorizontalScreenScale(60, parentW), AdvancedHorizontalScreenScale(44, parentH))
        controlsTextEntry:RequestFocus() -- please

        function controlsTextEntry:Paint(w, h)
            -- surface.SetDrawColor(200, 0, 0, 10)
            -- surface.DrawRect(0, 0, w, h)
            if math.sin((SysTime() * 1) * 6) > 0 then
                draw.DrawText("__", "MichromaRegular", HorizontalScreenScale(16), VerticalScreenScale(12), primarytext, TEXT_ALIGN_CENTER)
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
                            PanelFadeOut(controlHelpText, 0.5)
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
                    PanelFadeOut(controlHelpText, 0.5)
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
                    PanelFadeOut(controlHelpText, 0.5)
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

    PanelFadeIn(motherFrame, 0.15)

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
    exitButton:SetPos(HorizontalScreenScale(46), VerticalScreenScale(46))
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
    exitIconButton:SetPos(HorizontalScreenScale(37), VerticalScreenScale(48))
    exitIconButton:SetSize(HorizontalScreenScale(14), VerticalScreenScale(15))

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
    settingsLabel:SetPos(HorizontalScreenScale(61), VerticalScreenScale(69))
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
    settingsTitleLabel:SetPos(HorizontalScreenScale(525), VerticalScreenScale(95))
    settingsTitleLabel:SetSize(HorizontalScreenScale(500), VerticalScreenScale(200))
    settingsTitleLabel:SetText("")
    settingsTitleLabel:SetTextColor(primarytext)

    function settingsTitleLabel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        draw.DrawText(self:GetText(), "MichromaLarge", HorizontalScreenScale(12), VerticalScreenScale(12), accenttext, TEXT_ALIGN_LEFT)
        draw.DrawText(self:GetText(), "MichromaLarge", HorizontalScreenScale(14), VerticalScreenScale(10), primarytext, TEXT_ALIGN_LEFT)
        return true
    end
    ---

    local settingsHelpText = vgui.Create("DLabel", motherFrame)
    settingsHelpText:SetPos(HorizontalScreenScale(60), VerticalScreenScale(935))
    settingsHelpText:SetSize(1000, 30)
    settingsHelpText:SetFont("MichromaSmall")
    settingsHelpText:SetText("")
    settingsHelpText:SetTextColor(primarytext)

    function settingsHelpText:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end
    ---

    local exitHelpText = vgui.Create("DLabel", motherFrame)
    exitHelpText:SetPos(HorizontalScreenScale(60), VerticalScreenScale(984))
    exitHelpText:SetSize(HorizontalScreenScale(160), VerticalScreenScale(30))
    exitHelpText:SetFont("MichromaHelpText")
    exitHelpText:SetText("[Q]   BACK")
    exitHelpText:SetTextColor(secondarytext)

    function exitHelpText:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end
    ---

    function motherFrame:OnKeyCodePressed(key)
        if IsValid(OpenScrollPanel) and (key == KEY_ESCAPE or key == KEY_Q) then
            PanelFadeOut(OpenScrollPanel, 0.15)
            PanelFadeOut(settingsTitleLabel, 0.15)
            PanelFadeOut(settingsHelpText, 0.15)
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

    local categoryScrollPanel = vgui.Create("DScrollPanel", motherFrame)
    categoryScrollPanel:SetPos(HorizontalScreenScale(63), VerticalScreenScale(180))
    categoryScrollPanel:SetSize(HorizontalScreenScale(396), VerticalScreenScale(728))

    function categoryScrollPanel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end

    local categoryScrollBar = categoryScrollPanel:GetVBar() -- mr biden please legalize nuclear bombs
    categoryScrollBar:SetHideButtons(true)
    print(categoryScrollBar:GetSize())
    categoryScrollBar:SetPos(HorizontalScreenScale(525), VerticalScreenScale(185))
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
        categoryButton:SetSize(HorizontalScreenScale(394), VerticalScreenScale(56))

        function categoryButton:OnCursorEntered()
            surface.PlaySound("chicagoRP_settings/hover.wav")
        end
        ---

        local settingsScrollPanel = vgui.Create("DScrollPanel", motherFrame)
        settingsScrollPanel:SetPos(HorizontalScreenScale(525), VerticalScreenScale(185))
        settingsScrollPanel:SetSize(HorizontalScreenScale(1360), VerticalScreenScale(735))
        settingsScrollPanel:Hide()

        function settingsScrollPanel:Paint(w, h)
            -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
            return nil
        end

        local settingsScrollBar = settingsScrollPanel:GetVBar() -- mr biden please legalize nuclear bombs
        settingsScrollBar:SetHideButtons(true)
        settingsScrollBar:SetPos(HorizontalScreenScale(525), VerticalScreenScale(185))

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
            local buf, step = self.__hoverBuf or 0, TrueFrameTime * 3
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
            -- local pulseBuf, pulseStep = self.__pulseBuf or 0, TrueFrameTime * 5

            -- if (self.pulse == true) and pulseBuf < 1 then
            --     pulseBuf = math.min(1, pulseStep + pulseBuf)
            --     -- print(pulseBuf)
            -- elseif (self.pulse != true) and pulseBuf > 0 then
            --     pulseBuf = math.max(0, pulseBuf - pulseStep)
            --     -- print(pulseBuf)
            -- end

            -- self.__pulseBuf = pulseBuf
            -- pulseBuf = math.EaseInOut(pulseBuf, 0.2, 0.2)
            -- local alphaPulse, clrRed, clrGreen, clrBlue = Lerp(pulseBuf, 0, 40), Lerp(pulseBuf, 0, 180), Lerp(pulseBuf, 0, 20), Lerp(pulseBuf, 0, 30)
            -- -- local outlinePulse = Lerp(pulseBuf, 0, 3)

            -- surface.SetDrawColor(clrRed, clrGreen, clrBlue, alphaPulse)
            -- surface.DrawRect(0, 0, w, h)

            Pulse(self, w, h, altpulseredfrom, altpulseredto, altpulsegreenfrom, altpulsegreento, altpulsebluefrom, altpulseblueto, altpulsealphafrom, altpulsealphato, self.pulse, 5)

            -- DrawOutlinedGradientRect(self, gradientcolor1, gradientcolor2, outlinePulse)

            draw.DrawText(v.printname, "MichromaRegular", HorizontalScreenScale(11), VerticalScreenScale(14), primarytext, TEXT_ALIGN_LEFT)
        end
        ---
        local controlParentW, controlParentH = settingsScrollPanel:GetSize()

        local actionLabel = vgui.Create("DLabel", settingsScrollPanel)
        actionLabel:SetPos(AdvancedHorizontalScreenScale(10, controlParentW), AdvancedHorizontalScreenScale(-34, controlParentW))
        actionLabel:SetSize(HorizontalScreenScale(100), VerticalScreenScale(30))
        actionLabel:SetText("ACTION")
        actionLabel:SetTextColor(secondarytext)
        actionLabel:NoClipping(true) -- fuck you derma
        actionLabel:Hide()

        function actionLabel:Paint(w, h)
            -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
            draw.DrawText(self:GetText(), "MichromaSmall", 0, 0, secondarytext, TEXT_ALIGN_LEFT)
            return true
        end
        ---

        local bindLabel = vgui.Create("DLabel", settingsScrollPanel)
        bindLabel:SetPos(AdvancedHorizontalScreenScale(1745, controlParentW), AdvancedHorizontalScreenScale(-34, controlParentW)) -- fucking fix this
        bindLabel:SetSize(HorizontalScreenScale(100), VerticalScreenScale(30))
        bindLabel:SetText("BINDING")
        bindLabel:SetTextColor(secondarytext)
        bindLabel:NoClipping(true) -- fuck you derma
        bindLabel:Hide()

        function bindLabel:Paint(w, h)
            -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
            draw.DrawText(self:GetText(), "MichromaSmall", HorizontalScreenScale(96), 0, secondarytext, TEXT_ALIGN_RIGHT)
            return true
        end

        local buttonscreated = false
        ---

        function categoryButton:DoClick()
            self.pulse = true

            timer.Simple(0.20, function() -- tweak to look better and tweak times
                if IsValid(self) and self.pulse == true then
                    self.pulse = false
                end
            end)

            for _, v in ipairs(chicagoRP[v.name]) do -- if local !isvalid then do
                if buttonscreated == false and isstring(v.bind) then
                    CreateControlsButton(v.bind, v.printname, v.text, settingsScrollPanel, settingsHelpText, motherFrame)
                    actionLabel:Show()
                    bindLabel:Show()
                elseif buttonscreated == false and isstring(v.convar) and ConVarExists(v.convar) then
                    CreateSettingsButton(v.printname, v.convar, v.min, v.max, v.text, settingsScrollPanel, settingsHelpText, motherFrame)
                end
            end

            buttonscreated = true

            if IsValid(OpenScrollPanel) and IsValid(settingsTitleLabel) then
                PanelFadeOut(OpenScrollPanel, 0.15)
                PanelFadeOut(settingsTitleLabel, 0.15)
                PanelFadeOut(settingsHelpText, 0.15)
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
                        PanelFadeIn(settingsTitleLabel, 0.15)
                        PanelFadeIn(settingsHelpText, 0.15)
                        settingsScrollPanel:Show()
                        PanelFadeIn(settingsScrollPanel, 0.15)
                        settingsTitleLabel:SetText(v.printname)
                        if v.overridename then
                            settingsTitleLabel:SetText(v.overridename)
                        end
                        OpenScrollPanel = settingsScrollPanel
                    end
                end)
            elseif IsValid(settingsScrollPanel) and !IsValid(OpenScrollPanel) and IsValid(settingsTitleLabel) then
                PanelFadeIn(settingsTitleLabel, 0.15)
                PanelFadeIn(settingsHelpText, 0.15)
                settingsScrollPanel:Show()
                PanelFadeIn(settingsScrollPanel, 0.15)
                settingsTitleLabel:SetText(v.printname)
                if v.overridename then
                    settingsTitleLabel:SetText(v.overridename)
                end
                OpenScrollPanel = settingsScrollPanel
            end
            surface.PlaySound("chicagoRP_settings/select.wav")
        end
    end
    ---

    OpenMotherFrame = motherFrame
end)

print("chicagoRP GUI loaded!")

-- still need:
-- optimization