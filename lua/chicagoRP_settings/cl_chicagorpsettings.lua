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

local function DrawOutlinedTexturedRect(panel, material, thickness) -- figure out how to make gradient mat
    if (!IsValid(panel) and !panel:IsVisible()) then return end
    local w, h = panel:GetSize()
    surface.SetMaterial(material)
    surface.DrawTexturedRectUV(0, 0, w, thickness, 0, 0, 1, 0) -- top
    surface.DrawTexturedRectUV(0, h - thickness, w, thickness, 0, 1, 1, 1) -- bottom
    surface.DrawTexturedRectUV(0, 0, thickness, h, 0, 0, 0, 1) -- left
    surface.DrawTexturedRectUV(w - thickness, 0, thickness, h, 0, 0, 0, 1) -- right
end

local HideHUD = false

hook.Add("HUDPaint", "chicagoRP_HideHUD", function() -- we also need to hide hints and prop protection display
    if HideHUD then
        return false
    end
end)

local gradient_mat = Material("vgui/gradient-u")
-- gradient-d, gradient-r, gradient-u, gradient_down, gradient_up

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
        printname = "PIP Scope Post-Processing",
        text = "Post-Processing for scopes. Should have no impact on framerate."
    },
    [3] = {
        convar = "arccw_scopepp_refract",
        max = 1,
        min = 0,
        printname = "PIP Scope Refraction",
        text = "Refraction inside of scopes when ADSing. Generally has little impact on framerate."
    },
    [4] = {
        convar = "arccw_drawbarrel",
        max = 1,
        min = 0,
        printname = "Draw Barrel in PIP Scope (Expensive!)",
        text = "Draws weapon barrel in scope when ADSing. Disable unless you have a high-spec computer."
    },
    [5] = {
        convar = "arccw_cheapscopes",
        max = 1,
        min = 0,
        printname = "RT PIP Scopes",
        text = "Picture in Picture scopes. Disable it if you have framerate issues while ADSing."
    },
    [6] = {
        convar = "arccw_cheapscopesv2_ratio",
        max = 1, -- float
        min = 0, -- float
        printname = "Cheap Scope FOV",
        text = "Controls scope FOV when ADSing with PIP disabled. Recommended value is 0.10."
    },
    [7] = {
        convar = "arccw_scope_r",
        max = 255,
        min = 0,
        printname = "Sight Color (R)",
        text = "Red color value for sight color."
    },
    [8] = {
        convar = "arccw_scope_g",
        max = 255,
        min = 0,
        printname = "Sight Color (B)",
        text = "Blue color value for sight color."
    },
    [9] = {
        convar = "arccw_scope_b",
        max = 255,
        min = 0,
        printname = "Sight Color (G)",
        text = "Green color value for sight color."
    },
    [10] = {
        convar = "arccw_vm_fov",
        max = 15.00,
        min = -15.00,
        printname = "Viewmodel FOV",
        text = "Viewmodel FOV, only affects ArcCW weapons. Keep at default for a consistent look."
    },
    [11] = {
        convar = "arccw_blur",
        max = 1,
        min = 0,
        printname = "Weapon Customization Blur",
        text = "Blurs screen when customizing weapons."
    },
    [12] = {
        convar = "arccw_blur_toytown",
        max = 1,
        min = 0,
        printname = "Weapon ADS Blur",
        text = "Blurs edges of screen when ADSing."
    },
    [13] = {
        convar = "cl_playershadow",
        max = 1,
        min = 0,
        printname = "First-Person Player Shadow",
        text = "Casts first-person player shadow."
    },
    [14] = {
        convar = "cl_simfphys_frontlamps",
        max = 1,
        min = 0,
        printname = "Vehicle Front Projected Textures",
        text = "Enables dynamic lights for vehicles front lights. Recommended to disable on low-spec rigs."
    },
    [15] = {
        convar = "cl_simfphys_rearlamps",
        max = 1,
        min = 0,
        printname = "Vehicle Rear Projected Textures",
        text = "Enables dynamic lights for vehicles rear lights. Recommended to disable on low-spec rigs."
    },
    [16] = {
        convar = "cl_simfphys_shadows",
        max = 1,
        min = 0,
        printname = "Vehicle Light Shadows",
        text = "Enables light shadows for vehicle lights. Recommended to disable on low-spec rigs."
    }
}

local OpenMotherFrame = nil
local OpenDropdown = nil
local primarytext = (Color(255, 255, 255, 255))
local secondarytext = (Color(130, 25, 39, 255))

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
        local settingsScrollPanelTestButton = videoSettingsScrollPanel:Add("DButton")
        settingsScrollPanelTestButton:SetText("")
        settingsScrollPanelTestButton:Dock(TOP)
        settingsScrollPanelTestButton:DockMargin(0, 0, 3, 4)
        settingsScrollPanelTestButton:SetSize(800, 44)
        function settingsScrollPanelTestButton:Paint(w, h)
            local statusString = "Disabled"
            surface.SetDrawColor(40, 40, 40, 100)
            surface.DrawRect(0, 0, w, h)
            if settingsScrollPanelTestButton:IsHovered() then -- gradient start: (255, 86, 65) end: (255, 190, 131)
                surface.SetDrawColor(255, 86, 65)
                DrawOutlinedTexturedRect(self, gradient_mat, 3)
                settingsHelpText:SetText(v.text)
            end
            if (GetConVar(v.convar):GetInt() == 1) and (v.max == 1) then -- add float check pls
                statusString = "Enabled"
            elseif (GetConVar(v.convar):GetInt() > 1) and (v.max > 1) then
                statusString = GetConVar(v.convar):GetInt()
            end
            draw.DrawText(v.printname, "MichromaRegular", 14, 12, primarytext, TEXT_ALIGN_LEFT)
            draw.DrawText(statusString, "MichromaRegular", 790, 12, primarytext, TEXT_ALIGN_RIGHT)
        end
        function settingsScrollPanelTestButton:DoClick()
            if IsValid(OpenDropdown) then
                OpenDropdown:Remove()
            end

            local Dropdown = vgui.Create("DScrollPanel", motherFrame)
            local _,ScreenY = settingsScrollPanelTestButton:LocalToScreen()
            local DropdownBar = Dropdown:GetVBar()
            Dropdown:SetSize(500, 210) -- button size (465, 50)
            Dropdown:SetPos(1348, ScreenY)
            DropdownBar:SetHideButtons(true)
            print(ScreenY)

            function Dropdown:Paint(w, h)
                -- surface.SetDrawColor(200, 0, 0, 10)
                -- surface.DrawRect(0, 0, w, h)
                return nil
            end

            function DropdownBar:Paint(w, h) -- we still need to figure out how to separate the scroll bar from the frame
                draw.RoundedBox(0, 0, 0, w, h, Color(43, 39, 35, 66))
            end
            function DropdownBar.btnGrip:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(76, 76, 74, 150))
            end

            OpenDropdown = Dropdown

            for i = 0, 6 do
                local DropdownTestButton = Dropdown:Add("DButton")
                DropdownTestButton:SetText("")
                DropdownTestButton:Dock(TOP)
                DropdownTestButton:DockMargin(0, 0, 4, 3)
                DropdownTestButton:SetSize(400, 44)
                function DropdownTestButton:Paint(w, h)
                    surface.SetDrawColor(40, 40, 40, 100)
                    surface.DrawRect(0, 0, w, h)
                    if DropdownTestButton:IsHovered() then -- gradient start: (255, 86, 65) end: (255, 190, 131)
                        surface.SetDrawColor(255, 86, 65)
                        DrawOutlinedTexturedRect(self, gradient_mat, 3)
                        settingsHelpText:SetText("Love.")
                    end
                    surface.SetTextColor(primarytext)
                    surface.SetTextPos(14, 12)
                    surface.SetFont("MichromaRegular")
                    surface.DrawText("Button #" .. i)
                end
            end
        end
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
    function gameSettingsScrollBar:Paint(w, h) -- we still need to figure out how to separate the scroll bar from the frame
        draw.RoundedBox(0, 0, 0, w, h, Color(43, 39, 35, 66))
    end
    function gameSettingsScrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(76, 76, 74, 150))
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
            surface.SetDrawColor(57, 57, 57, 255)
            surface.DrawRect(0, 0, w, h)
        elseif self:IsHovered() and videoSettingsScrollPanel:IsVisible() then
            surface.SetDrawColor(66, 66, 66, 255)
            surface.DrawRect(0, 0, w, h)
        end
        surface.SetTextColor(primarytext)
        surface.SetTextPos(w - 383, h - 42)
        surface.SetFont("MichromaRegular")
        surface.DrawText("VIDEO")
    end

    function videoSettingsButton:DoClick()
        if IsValid(gameSettingsScrollPanel) then
            gameSettingsScrollPanel:Hide()
        end
        videoSettingsScrollPanel:Show()
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
            surface.SetDrawColor(57, 57, 57, 255)
            surface.DrawRect(0, 0, w, h)
        elseif self:IsHovered() and gameSettingsScrollPanel:IsVisible() then
            surface.SetDrawColor(66, 66, 66, 255)
            surface.DrawRect(0, 0, w, h)
        end
        surface.SetTextColor(primarytext)
        surface.SetTextPos(w - 383, h - 42)
        surface.SetFont("MichromaRegular")
        surface.DrawText("GAME")
    end

    function gameSettingsButton:DoClick()
        if IsValid(videoSettingsScrollPanel) then
            videoSettingsScrollPanel:Hide()
        end
        gameSettingsScrollPanel:Show()
    end

    OpenMotherFrame = motherFrame
end)










