list.Set("DesktopWindows", "chicagoRP Settings", {
    title = "Client Settings",
    icon = "icon64/chicagorp_settings.png",
    init = function(icon, window)
        LocalPlayer():ConCommand("chicagoRP_settings")
    end
})

local function HorizontalScreenScale(size)
    return math.Round(size * (ScrW() / 1920.0))
end

local function VerticalScreenScale(size)
    return math.Round(size * (ScrH() / 1080.0))
end

-- wish i didn't have to make four fonts but i think that's a minor sin in the face of what other devs do
surface.CreateFont("MichromaSmall", {
    font = "Michroma",
    extended = false,
    size = VerticalScreenScale(20),
    weight = 551,
    antialias = true,
    shadow = false
})

surface.CreateFont("MichromaRegular", {
    font = "Michroma",
    extended = false,
    size = VerticalScreenScale(24),
    weight = 550,
    antialias = true,
    shadow = false
})

surface.CreateFont("MichromaLarge", {
    font = "Michroma",
    extended = false,
    size = VerticalScreenScale(52),
    weight = 550,
    antialias = true,
    shadow = false
})

surface.CreateFont("MichromaHelpText", {
    font = "Michroma",
    extended = false,
    size = VerticalScreenScale(18),
    weight = 550,
    antialias = true,
    shadow = false
})