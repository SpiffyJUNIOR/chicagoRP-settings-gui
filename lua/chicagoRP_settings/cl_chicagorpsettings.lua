list.Set("DesktopWindows", "chicagoRP Settings", {
    local listplayer = LocalPlayer()
    title = "Context Menu Icon",
    icon = "icon64/icon.png",
    init = function(icon, window)
        listplayer:EZ_Open_Inventory(listplayer)
    end
})

surface.CreateFont("MichromaRegular", {
    font = "Michroma",
    extended = false,
    size = 15,
    weight = 500,
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
    motherFrame:SetSize(screenwidth, screenheight)
    motherFrame:SetVisible(true)
    motherFrame:SetDraggable(false)
    motherFrame:ShowCloseButton(false)

    function motherFrame:Paint(w, h)
        BlurBackground(self)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 255))
    end

    motherFrame:MakePopup()
    motherFrame:Center()

    function motherFrame:OnKeyCodePressed(key)
        if key == KEY_ESCAPE then
            self:Close()
        end
    end

    function motherFrame:OnClose()
        self:AlphaTo(100, 1, 0)
    end

    local exitButton = vgui.Create("DButton", motherFrame)
    exitButton:SetPos(5, 245)
    exitButton:SetSize(190, 50)

    function exitButton:DoClick()
        motherFrame:Close()
    end

    local exitButtonLabel = vgui.Create("DLabel", exitButton)
    exitButtonLabel:SetPos(5, 250)
    exitButtonLabel:SetText("GAME")
    exitButtonLabel:SetFont("MichromaRegular")
    ---
end)