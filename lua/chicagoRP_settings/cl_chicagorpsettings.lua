list.Set("DesktopWindows", "chicagoRP Settings", {
    title = "chicagoRP Settings",
    icon = "icon64/chicagoRP_settings.png",
    init = function(icon, window)
        LocalPlayer():ConCommand("chicagoRP_settings")
    end
})

print("chicagoRP client LUA loaded!")

-- wish i didn't have to make three fonts but i think that's a minor sin in the face of what other devs do
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
local gradient_mat = Material("vgui/gradient-u") -- gradient-d, gradient-r, gradient-u, gradient_down, gradient_up
local HideHUD = false
local OpenMotherFrame = nil
local OpenPanel = nil
local Dynamic = 0
local primarytext = (Color(255, 255, 255, 255))
local secondarytext = (Color(130, 25, 39, 255))

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
        settingsButton:SetSize(800, 50)
        function settingsButton:Paint(w, h)
            surface.SetDrawColor(40, 40, 40, 100)
            surface.DrawRect(0, 0, w, h)
            if settingsButton:IsHovered() then -- gradient start: (255, 86, 65) end: (255, 190, 131)
                surface.SetDrawColor(255, 86, 65)
                DrawOutlinedTexturedRect(self, gradient_mat, 3)
                helptextparent:SetText(helptext)
            end
            if (GetConVar(convar):GetInt() == 0) and (max == 1) then -- add float check pls
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawOutlinedRect(770, 12, 22, 22, 2)
            elseif (GetConVar(convar):GetInt() == 1) and (max == 1) then -- add float check pls
                surface.SetDrawColor(255, 255, 255, 255)
                draw.RoundedBox(4, 775, 17, 12, 12, primarytext)
                surface.DrawOutlinedRect(770, 12, 22, 22, 2)
            elseif (GetConVar(convar):GetInt() >= 0) and (max > 1) then
                local statusString = GetConVar(convar):GetInt()
                draw.DrawText(statusString, "MichromaRegular", 790, 12, primarytext, TEXT_ALIGN_RIGHT)
            end
            draw.DrawText(printname, "MichromaRegular", 14, 12, primarytext, TEXT_ALIGN_LEFT)
        end
        function settingsButton:DoClick()
            if (GetConVar(convar):GetInt() == 0) then -- add float check pls
                RunConsoleCommand(convar, "1")
            elseif (GetConVar(convar):GetInt() == 1) then -- add float check pls
                RunConsoleCommand(convar, "0")
            end
        end
    elseif (GetConVar(convar):GetInt() >= 0 or GetConVar(convar):GetInt() <= 0) and (max > 1) and ConVarExists(convar) then
        local settingsSliderParent = parent:Add("DButton")
        settingsSliderParent:SetText("")
        settingsSliderParent:Dock(TOP)
        settingsSliderParent:DockMargin(0, 0, 3, 4)
        settingsSliderParent:SetSize(800, 50)
        function settingsSliderParent:Paint(w, h)
            draw.DrawText(printname, "MichromaRegular", 14, 12, primarytext, TEXT_ALIGN_LEFT)
            surface.SetDrawColor(40, 40, 40, 100)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(255, 86, 65)
            if self:IsHovered() or self:IsChildHovered() then
                DrawOutlinedTexturedRect(self, gradient_mat, 3)
            end
            -- return nil
        end

        local settingsSlider = vgui.Create("DNumSlider", settingsSliderParent)
        settingsSlider:SetText("")
        settingsSlider:SetSize(335, 50)
        settingsSlider:SetPos(467, 0)
        settingsSlider:SetMin(min)
        settingsSlider:SetMax(max)
        settingsSlider:SetDecimals(0)
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
    end
end

hook.Add("HUDPaint", "chicagoRP_HideHUD", function() -- we also need to hide hints and prop protection display
    if HideHUD then
        return false
    end
end)

local videoSettingsOptions = { -- simfphys camera, arccw, first person shadow, shmovement, vfire, simfphys, stormfox, atmos, 
    [1] = {
        convar = "cl_new_impact_effects",
        max = 1,
        min = 0,
        printname = "Fancy Impact Effects",
        text = "Fancy impact particles. Might have heavy performance impact on low-spec computers."
    },
    [2] = {
        convar = "arccw_scopepp",
        max = 1,
        min = 0,
        printname = "Scope Chromatic Aberration",
        text = "Chromatic Aberration for scopes. Should have no impact on framerate."
    },
    [3] = {
        convar = "arccw_thermalpp",
        max = 1,
        min = 0,
        printname = "Thermal Scope Post-Processing",
        text = "Post-Processing for thermal scopes. Disable if you dislike thermal scope's choppiness."
    },
    [4] = {
        convar = "arccw_scopepp_refract",
        max = 1,
        min = 0,
        printname = "PIP Scope Refraction",
        text = "Refraction inside of scopes when ADSing. Generally has little impact on framerate."
    },
    [5] = {
        convar = "arccw_drawbarrel",
        max = 1,
        min = 0,
        printname = "Draw Barrel in PIP Scope (Expensive!)",
        text = "Draws weapon barrel in scope when ADSing. Disable unless you have a high-spec computer."
    },
    [6] = {
        convar = "arccw_cheapscopes",
        max = 1,
        min = 0,
        printname = "Cheap Scopes",
        text = "Cheap Scopes. Only enable if you have framerate issues while ADSing."
    },
    [7] = {
        convar = "arccw_cheapscopesv2_ratio",
        max = 1, -- float
        min = 0, -- float
        printname = "Cheap Scope FOV",
        text = "Controls scope FOV when ADSing with RT PIP disabled. Recommended value is 0.10."
    },
    [8] = {
        convar = "arccw_scope_r",
        max = 255,
        min = 0,
        printname = "Sight Color (R)",
        text = "Red color value for sight color."
    },
    [9] = {
        convar = "arccw_scope_g",
        max = 255,
        min = 0,
        printname = "Sight Color (G)",
        text = "Green color value for sight color."
    },
    [10] = {
        convar = "arccw_scope_b",
        max = 255,
        min = 0,
        printname = "Sight Color (B)",
        text = "Blue color value for sight color."
    },
    [11] = {
        convar = "arccw_vm_fov",
        max = 15.00,
        min = -15.00,
        printname = "Viewmodel FOV",
        text = "Viewmodel FOV, only affects ArcCW weapons. Keep at default for a consistent look."
    },
    [12] = {
        convar = "arccw_blur",
        max = 1,
        min = 0,
        printname = "Weapon Customization Blur",
        text = "Blurs screen when customizing weapons."
    },
    [13] = {
        convar = "arccw_blur_toytown",
        max = 1,
        min = 0,
        printname = "Weapon ADS Blur",
        text = "Blurs edges of screen when ADSing."
    },
    [14] = {
        convar = "cl_playershadow",
        max = 1,
        min = 0,
        printname = "First-Person Player Shadow",
        text = "Casts first-person player shadow."
    },
    [15] = {
        convar = "cl_simfphys_frontlamps",
        max = 1,
        min = 0,
        printname = "Vehicle Front Projected Textures",
        text = "Enables dynamic lights for vehicles front lights. Recommended to disable on low-spec rigs."
    },
    [16] = {
        convar = "cl_simfphys_rearlamps",
        max = 1,
        min = 0,
        printname = "Vehicle Rear Projected Textures",
        text = "Enables dynamic lights for vehicles rear lights. Recommended to disable on low-spec rigs."
    },
    [17] = {
        convar = "cl_simfphys_shadows",
        max = 1,
        min = 0,
        printname = "Vehicle Light Shadows",
        text = "Enables light shadows for vehicle lights. Recommended to disable on low-spec rigs."
    }
}

local gameSettingsOptions = { -- simfphys camera, arccw, first person shadow, shmovement, vfire, simfphys, stormfox, atmos, 
    [1] = {
        convar = "arccw_crosshair_clr_a",
        max = 255,
        min = 0,
       printname = "Crosshair Color (A)",
        text = "Alpha transparency value for crosshair color. Only affects ArcCW Weapons."
    },
    [2] = {
        convar = "arccw_crosshair_clr_r",
        max = 255,
        min = 0,
        printname = "Crosshair Color (R)",
        text = "Red color value for crosshair color. Only affects ArcCW Weapons."
    },
    [3] = {
        convar = "arccw_crosshair_clr_g",
        max = 255,
        min = 0,
        printname = "Crosshair Color (G)",
        text = "Green color value for crosshair color. Only affects ArcCW Weapons."
    },
    [4] = {
        convar = "arccw_crosshair_clr_b",
        max = 255,
        min = 0,
        printname = "Crosshair Color (B)",
        text = "Blue color value for crosshair color. Only affects ArcCW Weapons."
    }
}

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

    local videoSettingsScrollPanel = vgui.Create("DScrollPanel", motherFrame)
    videoSettingsScrollPanel:SetPos(525, 235)
    videoSettingsScrollPanel:SetSize(820, 635)
    videoSettingsScrollPanel:Hide()

    function videoSettingsScrollPanel:Paint(w, h)
        -- draw.RoundedBox(8, 0, 0, w, h, Color(200, 0, 0, 10))
        return nil
    end

    local videoSettingsScrollBar = videoSettingsScrollPanel:GetVBar() -- mr biden please legalize nuclear bombs
    videoSettingsScrollBar:SetHideButtons(true)
    videoSettingsScrollBar:SetPos(525, 235)
    function videoSettingsScrollBar:Paint(w, h) -- we still need to figure out how to separate the scroll bar from the frame
        draw.RoundedBox(0, 0, 0, w, h, Color(43, 39, 35, 66))
    end
    function videoSettingsScrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(76, 76, 74, 150))
    end

    for k, v in ipairs(videoSettingsOptions) do
        CreateSettingsButton(v.printname, v.convar, v.min, v.max, v.text, videoSettingsScrollPanel, settingsHelpText)
    end
    ---

    local gameSettingsScrollPanel = vgui.Create("DScrollPanel", motherFrame)
    gameSettingsScrollPanel:SetPos(525, 235)
    gameSettingsScrollPanel:SetSize(820, 635)
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

    for k, v in ipairs(gameSettingsOptions) do
        CreateSettingsButton(v.printname, v.convar, v.min, v.max, v.text, gameSettingsScrollPanel, settingsHelpText)
    end
    ---

    local videoSettingsButton = vgui.Create("DButton", motherFrame)
    videoSettingsButton:SetPos(103, 230)
    videoSettingsButton:SetSize(394, 56)
    videoSettingsButton:SetFont("MichromaRegular")
    videoSettingsButton:SetText("")
    videoSettingsButton:SetTextColor(primarytext)

    function videoSettingsButton:Paint(w, h)
        if self:IsHovered() and !videoSettingsScrollPanel:IsVisible() then
            surface.SetDrawColor(34, 34, 34, 100)
            surface.DrawRect(0, 0, w, h)
        elseif !self:IsHovered() and videoSettingsScrollPanel:IsVisible() then
            surface.SetDrawColor(66, 66, 66, 30)
            surface.DrawRect(0, 0, w, h)
        elseif self:IsHovered() and videoSettingsScrollPanel:IsVisible() then
            surface.SetDrawColor(66, 66, 66, 60)
            surface.DrawRect(0, 0, w, h)
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
        OpenPanel = videoSettingsScrollPanel
    end
    ---

    local gameSettingsButton = vgui.Create("DButton", motherFrame)
    gameSettingsButton:SetPos(103, 290)
    gameSettingsButton:SetSize(394, 56)
    gameSettingsButton:SetFont("MichromaRegular")
    gameSettingsButton:SetText("")
    gameSettingsButton:SetTextColor(primarytext)

    function gameSettingsButton:Paint(w, h)
        if self:IsHovered() and !gameSettingsScrollPanel:IsVisible() then
            surface.SetDrawColor(34, 34, 34, 100)
            surface.DrawRect(0, 0, w, h)
        elseif !self:IsHovered() and gameSettingsScrollPanel:IsVisible() then
            surface.SetDrawColor(66, 66, 66, 30)
            surface.DrawRect(0, 0, w, h)
        elseif self:IsHovered() and gameSettingsScrollPanel:IsVisible() then
            surface.SetDrawColor(66, 66, 66, 60)
            surface.DrawRect(0, 0, w, h)
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
        OpenPanel = gameSettingsScrollPanel
    end

    OpenMotherFrame = motherFrame
end)

-- still need:
-- slider text looks less bold
-- keyboard nagivation
-- changeable colors
-- two-tone gradient material that can be changed ingame
-- ui sounds
-- fade in/out
-- color pulse when click button