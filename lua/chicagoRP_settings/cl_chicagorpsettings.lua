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
CreateClientConVar("chicagoRP_accent_r", 180, true, false, "Changes the (R) color value for the settings GUI's accent text.", 1, 255)
CreateClientConVar("chicagoRP_accent_g", 20, true, false, "Changes the (G) color value for the settings GUI's accent text.", 1, 255)
CreateClientConVar("chicagoRP_accent_b", 5, true, false, "Changes the (B) color value for the settings GUI's accent text.", 1, 255)
CreateClientConVar("chicagoRP_primarygradient_r", 230, true, false, "Changes the (R) color value for the settings GUI's primary gradient.", 1, 255)
CreateClientConVar("chicagoRP_primarygradient_g", 45, true, false, "Changes the (G) color value for the settings GUI's primary gradient.", 1, 255)
CreateClientConVar("chicagoRP_primarygradient_b", 40, true, false, "Changes the (B) color value for the settings GUI's primary gradient.", 1, 255)
CreateClientConVar("chicagoRP_secondarygradient_r", 245, true, false, "Changes the (R) color value for the settings GUI's secondary gradient.", 1, 255)
CreateClientConVar("chicagoRP_secondarygradient_g", 135, true, false, "Changes the (G) color value for the settings GUI's secondary gradient.", 1, 255)
CreateClientConVar("chicagoRP_secondarygradient_b", 70, true, false, "Changes the (B) color value for the settings GUI's secondary gradient.", 1, 255)

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

print("chicagoRP client LUA loaded!")

-- wish i didn't have to make four fonts but i think that's a minor sin in the face of what other devs do
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

surface.CreateFont("MichromaLarge", {
    font = "Michroma",
    extended = false,
    size = 52,
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

local blockedkeys = {
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
local accenttext = Color(CVarAccentRed, CVarAccentGreen, CVarAccentBlue, 220)
local gradientcolor1 = Color(CVarPrimaryGradientRed, CVarPrimaryGradientGreen, CVarPrimaryGradientBlue, 50) -- Color(247, 31, 251, 200)
local gradientcolor2 = Color(CVarSecondaryGradientRed, CVarSecondaryGradientGreen, CVarSecondaryGradientBlue, 150) -- Color(4, 164, 255, 200)
local hoverslide = CreateSound(game.GetWorld(), "chicagoRP_settings/hover_slide.wav", 0) -- create the new sound, parented to the worldspawn (which always exists)
hoverslide:SetSoundLevel(0) -- play everywhere

local function BlurBackground(panel)
    if (!IsValid(panel) and !panel:IsVisible()) then return end
    local layers, density, alpha = 1, 1, 80
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
    if (!IsValid(panel) and !panel:IsVisible()) then return end
    local w, h = panel:GetSize()

    surface.SetMaterial(material)
    surface.DrawTexturedRectUV(0, 0, w, thickness, 0, 0, 1, 0) -- top
    surface.DrawTexturedRectUV(0, h - thickness, w, thickness, 0, 1, 1, 1) -- bottom
    surface.DrawTexturedRectUV(0, 0, thickness, h, 0, 0, 0, 1) -- left
    surface.DrawTexturedRectUV(w - thickness, 0, thickness, h, 1, 0, 1, 1) -- right
end

local function DrawOutlinedGradientRect(panel, firstcolor, secondcolor, thickness)
    surface.SetDrawColor(firstcolor)
    DrawOutlinedTexturedRect(panel, gradientLeftMat, thickness)
    surface.SetDrawColor(secondcolor)
    DrawOutlinedTexturedRect(panel, gradientRightMat, thickness)
end

local function TexturedQuadPart(mat, x1, y1, w, h, tx, ty, tw, th) -- ripped from TF2 gamemode by Kilburn, wango911, Agent Agrimar, and LeadKiller
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

local function RoundedOutline(mat, x, y, w, h, src_corner_width, src_corner_height, draw_corner_width, draw_corner_height) -- ripped from TF2 gamemode by Kilburn, wango911, Agent Agrimar, and LeadKiller
    local tw = mat:GetInt("$realwidth")
    local th = mat:GetInt("$realheight")
    local dx = draw_corner_width
    local dy = draw_corner_height

    local Dx = src_corner_width
    local Dy = src_corner_height

    local x1, y1 = x + dx, y + dy
    local x2, y2 = x + w - dx, y + h - dy
    local w2, h2 = w - 2 * dx, h - 2 * dy

    print(mat)

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

local function CreateSettingsButton(printname, convar, min, max, helptext, parent, helptextparent, frame)
    if (GetConVar(convar):GetInt() == 0 or GetConVar(convar):GetInt() == 1) and (max == 1) and ConVarExists(convar) then
        local settingsButton = parent:Add("DButton")
        settingsButton:SetText("")
        settingsButton:Dock(TOP)
        settingsButton:DockMargin(0, 0, 3, 4)
        settingsButton:SetSize(1340, 50)

        function settingsButton:OnCursorEntered()
            surface.PlaySound("chicagoRP_settings/hover.wav")
        end

        function settingsButton:Paint(w, h)
            local hovered = self:IsHovered()
            local buf, step = self.__hoverBuf or 0, RealFrameTime() * 4

            if hovered and buf < 1 then
                buf = math.min(1, step + buf)
            elseif !hovered and buf > 0 then
                buf = math.max(0, step - buf)
            end

            self.__hoverBuf = buf
            buf = math.EaseInOut(buf, 0.2, 0.2)
            local alpha, clr = Lerp(buf, 80, 80), Lerp(buf, 40, 60)

            surface.SetDrawColor(clr, clr, clr, alpha)
            surface.DrawRect(0, 0, w, h)
            -----
            local Outlinebuf, Outlinestep = self.__hoverOutlineBuf or 0, RealFrameTime() * 4

            if hovered and Outlinebuf < 1 then
                Outlinebuf = math.min(1, Outlinestep + Outlinebuf)
            elseif !hovered and Outlinebuf > 0 then
                Outlinebuf = math.max(0, Outlinestep - Outlinebuf)
            end

            self.__hoverOutlineBuf = Outlinebuf
            Outlinebuf = math.EaseInOut(buf, 0.5, 0.5)
            local alphaOutline = Lerp(buf, 0, 150)

            gradientcolor1.a = alphaOutline
            gradientcolor2.a = alphaOutline

            DrawOutlinedGradientRect(self, (gradientcolor1), (gradientcolor2), 3)

            if hovered then
                helptextparent:SetText(helptext)
            end

            if (GetConVar(convar):GetInt() == 0) and (max == 1) then
                surface.SetDrawColor(primarytext:Unpack())
                RoundedOutline(roundedOutlineMat, 1300, 14, 22, 22, 1, 1, 1, 1)
            elseif (GetConVar(convar):GetInt() == 1) and (max == 1) then
                surface.SetDrawColor(primarytext:Unpack())
                draw.RoundedBox(4, 1305, 19, 12, 12, primarytext)
                RoundedOutline(roundedOutlineMat, 1300, 14, 22, 22, 1, 1, 1, 1)
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
            local hovered = self:IsHovered()
            local childhovered = self:IsChildHovered()
            local buf, step = self.__hoverBuf or 0, RealFrameTime() * 4

            if (hovered or childhovered) and buf < 1 then
                buf = math.min(1, step + buf)
            elseif (!hovered and !childhovered) and buf > 0 then
                buf = math.max(0, step - buf)
            end

            self.__hoverBuf = buf
            buf = math.EaseInOut(buf, 0.2, 0.2)
            local alpha, clr = Lerp(buf, 80, 80), Lerp(buf, 40, 60)

            surface.SetDrawColor(clr, clr, clr, alpha)
            surface.DrawRect(0, 0, w, h)
            -----
            local Outlinebuf, Outlinestep = self.__hoverOutlineBuf or 0, RealFrameTime() * 4

            if (hovered or childhovered) and Outlinebuf < 1 then
                Outlinebuf = math.min(1, Outlinestep + Outlinebuf)
            elseif (!hovered and !childhovered) and Outlinebuf > 0 then
                Outlinebuf = math.max(0, Outlinestep - Outlinebuf)
            end

            self.__hoverOutlineBuf = Outlinebuf
            Outlinebuf = math.EaseInOut(buf, 0.5, 0.5)
            local alphaOutline = Lerp(buf, 0, 150)

            gradientcolor1.a = alphaOutline
            gradientcolor2.a = alphaOutline

            DrawOutlinedGradientRect(self, (gradientcolor1), (gradientcolor2), 3)

            if (hovered or childhovered) then
                helptextparent:SetText(helptext)
            end

            draw.DrawText(printname, "MichromaRegular", 14, 12, primarytext, TEXT_ALIGN_LEFT)
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
            draw.DrawText(GetConVar(convar):GetInt(), "MichromaRegular", 325, 13, primarytext, TEXT_ALIGN_RIGHT)
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
    controlsButton:SetSize(800, 44)

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
            buf = math.max(0, step - buf)
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
            Outlinebuf = math.max(0, Outlinestep - Outlinebuf)
        end

        self.__hoverOutlineBuf = Outlinebuf
        Outlinebuf = math.EaseInOut(buf, 0.5, 0.5)
        local alphaOutline = Lerp(buf, 0, 150)

        gradientcolor1.a = alphaOutline
        gradientcolor2.a = alphaOutline

        DrawOutlinedGradientRect(self, (gradientcolor1), (gradientcolor2), 3)

        if hovered or haschildren then
            helptextparent:SetText(helptext)
        end

        if input.LookupBinding(bind, false) and !haschildren then -- how do we hide this for a certain button?
            statusString = string.upper(input.LookupBinding(bind, false))
            draw.DrawText(statusString, "MichromaRegular", 1325, 10, primarytext, TEXT_ALIGN_RIGHT)
        end

        draw.DrawText(printname, "MichromaRegular", 14, 10, primarytext, TEXT_ALIGN_LEFT)
    end

    function controlsButton:DoClick()
        surface.PlaySound("chicagoRP_settings/select.wav")

        if IsValid(OpenControlText) then
            OpenControlText:Remove()
        end

        local controlHelpText = vgui.Create("DLabel", frame)
        controlHelpText:SetPos(1495, 880)
        controlHelpText:SetSize(390, 30)
        controlHelpText:SetFont("MichromaHelpText")
        controlHelpText:SetText("Press a key to bind.")

        function controlHelpText:Paint(w, h)
            -- surface.SetDrawColor(200, 0, 0, 10)
            -- surface.DrawRect(0, 0, w, h)
            draw.DrawText(self:GetText(), "MichromaSmall", 385, 5, primarytext, TEXT_ALIGN_RIGHT)

            return true
        end

        function controlHelpText:OnRemove() -- debug function
            print("helptext removed")
        end

        controlHelpText:SetAlpha(0)
        controlHelpText:AlphaTo(255, 0.2, 0)

        local controlsTextEntry = self:Add("DTextEntry")
        controlsTextEntry:Dock(RIGHT)
        controlsTextEntry:SetSize(60, 44)
        controlsTextEntry:RequestFocus() -- please

        function controlsTextEntry:Paint(w, h)
            if math.sin((SysTime() * 1) * 6) > 0 then
                draw.DrawText("__", "MichromaRegular", 34, 12, primarytext, TEXT_ALIGN_CENTER)
            end
        end

        function controlsTextEntry:OnKeyCode(keyCode)
            local bindblocked = false
            local keyname = tostring(input.GetKeyName(keyCode) .. " ")
            local bindtext = tostring("bind " .. input.GetKeyName(keyCode) .. " " .. bind)
            for k, v in ipairs(blockedkeys) do
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

    print(primarytext)
    print(secondarytext)

    if IsValid(ArcCW.InvHUD) then
        ArcCW.InvHUD:Hide()
    end

    function motherFrame:Paint(w, h)
        BlurBackground(self)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 0))
    end

    motherFrame:SetAlpha(0)
    motherFrame:AlphaTo(255, 0.15, 0)

    motherFrame:MakePopup()
    motherFrame:Center()

    timer.Simple(0.15, function()
        ply:SetDSP(30, false)
    end)

    surface.PlaySound("chicagoRP_settings/back.wav")

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
    exitIconButton:SetPos(77, 98)
    exitIconButton:SetSize(14, 15)

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
    settingsLabel:SetPos(101, 119)
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
    settingsTitleLabel:SetPos(520, 130)
    settingsTitleLabel:SetSize(500, 200)
    settingsTitleLabel:SetText("")
    settingsTitleLabel:SetTextColor(primarytext)

    function settingsTitleLabel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        draw.DrawText(self:GetText(), "MichromaLarge", 12, 12, accenttext, TEXT_ALIGN_LEFT)
        draw.DrawText(self:GetText(), "MichromaLarge", 14, 10, primarytext, TEXT_ALIGN_LEFT)
        return true
    end
    ---

    local settingsHelpText = vgui.Create("DLabel", motherFrame)
    settingsHelpText:SetPos(100, 935)
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
    exitHelpText:SetPos(100, 984)
    exitHelpText:SetSize(160, 30)
    exitHelpText:SetFont("MichromaHelpText")
    exitHelpText:SetText("[Q]   BACK")
    exitHelpText:SetTextColor(secondarytext)

    function exitHelpText:Paint(w, h)
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
        -- print(self:IsVisible())
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

    for _, v in ipairs(chicagoRPvideoSettingsOptions) do
        CreateSettingsButton(v.printname, v.convar, v.min, v.max, v.text, videoSettingsScrollPanel, settingsHelpText, motherFrame)
    end
    ---

    local gameSettingsScrollPanel = vgui.Create("DScrollPanel", motherFrame)
    gameSettingsScrollPanel:SetPos(525, 235)
    gameSettingsScrollPanel:SetSize(1360, 635)
    gameSettingsScrollPanel:Hide()

    function gameSettingsScrollPanel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        -- print(self:IsVisible())
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

    for _, v in ipairs(chicagoRPgameSettingsOptions) do
        CreateSettingsButton(v.printname, v.convar, v.min, v.max, v.text, gameSettingsScrollPanel, settingsHelpText, motherFrame)
    end
    ---

    local controlsSettingsScrollPanel = vgui.Create("DScrollPanel", motherFrame)
    controlsSettingsScrollPanel:SetPos(525, 235)
    controlsSettingsScrollPanel:SetSize(1360, 635)
    controlsSettingsScrollPanel:Hide()

    function controlsSettingsScrollPanel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        -- print(self:IsVisible())
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

    for _, v in ipairs(chicagoRPcontrolsSettingsOptions) do
        CreateControlsButton(v.bind, v.printname, v.text, controlsSettingsScrollPanel, settingsHelpText, motherFrame)
    end
    ---

    local actionLabel = vgui.Create("DLabel", controlsSettingsScrollPanel)
    actionLabel:SetPos(10, -25)
    actionLabel:SetSize(100, 30)
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
    bindLabel:SetPos(1240, -25)
    bindLabel:SetSize(100, 30)
    bindLabel:SetText("BINDING")
    bindLabel:SetTextColor(secondarytext)
    bindLabel:NoClipping(true) -- fuck you derma

    function bindLabel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        draw.DrawText(self:GetText(), "MichromaSmall", 96, 0, secondarytext, TEXT_ALIGN_RIGHT)
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
                if IsValid(OpenScrollPanel) then
                    if !OpenScrollPanel:IsVisible() then
                        OpenScrollPanel = nil
                    end
                end
            end)
        elseif !IsValid(OpenScrollPanel) and (key == KEY_ESCAPE or key == KEY_Q) then
            self:AlphaTo(50, 0.15, 0)
            surface.PlaySound("chicagoRP_settings/back.wav")
            timer.Simple(0.15, function()
                self:Close()
            end)
        end
    end
    ---
    local videoSettingsButton = vgui.Create("DButton", motherFrame)
    videoSettingsButton:SetPos(103, 230)
    videoSettingsButton:SetSize(394, 56)
    videoSettingsButton:SetFont("MichromaRegular")
    videoSettingsButton:SetText("")
    videoSettingsButton:SetTextColor(primarytext)

    function videoSettingsButton:OnCursorEntered()
        surface.PlaySound("chicagoRP_settings/hover.wav")
    end

    function videoSettingsButton:Paint(w, h)
        local panelActive = videoSettingsScrollPanel:IsVisible()
        local hovered = self:IsHovered()
        local buf, step = self.__hoverBuf or 0, RealFrameTime() * 5
        local alpha, clr = Lerp(buf, 0, 34), Lerp(buf, 0, 66) -- end of anim

        if hovered and buf < 1 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != videoSettingsScrollPanel) then
            buf = math.min(1, step + buf)
            alpha, clr = Lerp(buf, 0, 60), Lerp(buf, 0, 66)
        elseif !hovered and buf >= 0 and panelActive and OpenScrollPanel != nil and (OpenScrollPanel == videoSettingsScrollPanel) then -- kill yourself
            buf = math.max(0, step - buf)
            alpha, clr = Lerp(buf, 40, 40), Lerp(buf, 14, 14) -- Lerp(buf, 34, 60), Lerp(buf, 66, 66)
        elseif hovered and buf < 1 and panelActive and (OpenScrollPanel != nil or OpenScrollPanel == videoSettingsScrollPanel) then
            buf = math.min(1, step + buf)
            alpha, clr = Lerp(buf, 40, 60), Lerp(buf, 66, 66) -- Lerp(buf, 60, 34), Lerp(buf, 66, 66)
        elseif !hovered and buf >= 0 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != videoSettingsScrollPanel) then
            buf = math.max(0, step - buf)
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

        draw.DrawText("VIDEO", "MichromaRegular", w - 383, h - 42, primarytext, TEXT_ALIGN_LEFT)
    end

    function videoSettingsButton:DoClick() -- nauseating code but it works and i don't want to touch it
        self.value = !self.value
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
                if IsValid(OpenScrollPanel) and OpenScrollPanel == videoSettingsScrollPanel then
                    if !OpenScrollPanel:IsVisible() then
                        OpenScrollPanel = nil
                    end
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
    gameSettingsButton:SetPos(103, 290)
    gameSettingsButton:SetSize(394, 56)
    gameSettingsButton:SetFont("MichromaRegular")
    gameSettingsButton:SetText("")
    gameSettingsButton:SetTextColor(primarytext)

    function gameSettingsButton:OnCursorEntered()
        surface.PlaySound("chicagoRP_settings/hover.wav")
    end

    function gameSettingsButton:Paint(w, h)
        local panelActive = gameSettingsScrollPanel:IsVisible()
        local hovered = self:IsHovered()
        local buf, step = self.__hoverBuf or 0, RealFrameTime() * 5
        local alpha, clr = Lerp(buf, 0, 34), Lerp(buf, 0, 66) -- end of anim

        if hovered and buf < 1 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != gameSettingsScrollPanel) then
            buf = math.min(1, step + buf)
            alpha, clr = Lerp(buf, 0, 60), Lerp(buf, 0, 66)
        elseif !hovered and buf >= 0 and panelActive and OpenScrollPanel != nil and (OpenScrollPanel == gameSettingsScrollPanel) then -- kill yourself
            buf = math.max(0, step - buf)
            alpha, clr = Lerp(buf, 40, 40), Lerp(buf, 14, 14) -- Lerp(buf, 34, 60), Lerp(buf, 66, 66)
        elseif hovered and buf < 1 and panelActive and (OpenScrollPanel != nil or OpenScrollPanel == gameSettingsScrollPanel) then
            buf = math.min(1, step + buf)
            alpha, clr = Lerp(buf, 40, 60), Lerp(buf, 66, 66) -- Lerp(buf, 60, 34), Lerp(buf, 66, 66)
        elseif !hovered and buf >= 0 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != gameSettingsScrollPanel) then
            buf = math.max(0, step - buf)
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
        draw.DrawText("GAME", "MichromaRegular", w - 383, h - 42, primarytext, TEXT_ALIGN_LEFT)
    end

    function gameSettingsButton:DoClick() -- nauseating code but it works and i don't want to touch it
        self.value = !self.value
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
                if IsValid(OpenScrollPanel) and OpenScrollPanel == gameSettingsScrollPanel then
                    if !OpenScrollPanel:IsVisible() then
                        OpenScrollPanel = nil
                    end
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
    controlsSettingsButton:SetPos(103, 350)
    controlsSettingsButton:SetSize(394, 56)
    controlsSettingsButton:SetFont("MichromaRegular")
    controlsSettingsButton:SetText("")
    controlsSettingsButton:SetTextColor(primarytext)

    function controlsSettingsButton:OnCursorEntered()
        surface.PlaySound("chicagoRP_settings/hover.wav")
    end

    function controlsSettingsButton:Paint(w, h)
        local panelActive = controlsSettingsScrollPanel:IsVisible()
        local hovered = self:IsHovered()
        local buf, step = self.__hoverBuf or 0, RealFrameTime() * 5
        local alpha, clr = Lerp(buf, 0, 34), Lerp(buf, 0, 66) -- end of anim

        if hovered and buf < 1 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != controlsSettingsScrollPanel) then
            buf = math.min(1, step + buf)
            alpha, clr = Lerp(buf, 0, 60), Lerp(buf, 0, 66)
        elseif !hovered and buf >= 0 and panelActive and OpenScrollPanel != nil and (OpenScrollPanel == controlsSettingsScrollPanel) then -- kill yourself
            buf = math.max(0, step - buf)
            alpha, clr = Lerp(buf, 40, 40), Lerp(buf, 14, 14) -- Lerp(buf, 34, 60), Lerp(buf, 66, 66)
        elseif hovered and buf < 1 and panelActive and (OpenScrollPanel != nil or OpenScrollPanel == controlsSettingsScrollPanel) then
            buf = math.min(1, step + buf)
            alpha, clr = Lerp(buf, 40, 60), Lerp(buf, 66, 66) -- Lerp(buf, 60, 34), Lerp(buf, 66, 66)
        elseif !hovered and buf >= 0 and (!panelActive or panelActive) and (OpenScrollPanel == nil or OpenScrollPanel != controlsSettingsScrollPanel) then
            buf = math.max(0, step - buf)
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
        draw.DrawText("CONTROLS", "MichromaRegular", w - 383, h - 42, primarytext, TEXT_ALIGN_LEFT)
    end

    function controlsSettingsButton:DoClick() -- nauseating code but it works and i don't want to touch it
        self.value = !self.value
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
                if IsValid(OpenScrollPanel) and OpenScrollPanel == controlsSettingsScrollPanel then
                    if !OpenScrollPanel:IsVisible() then
                        OpenScrollPanel = nil
                    end
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

-- still need:
-- keep hover on setting button when cursor is no longer in scroll panel (ask diamond doves about this)
-- button fade out anims (abuse fade in code for this)
-- tighten up UI layout
-- make UI scale correctly with screen resolution (math and maybe performlayout)
-- if possible, COLOR PULSE WHEN BUTTON IS CLICKED