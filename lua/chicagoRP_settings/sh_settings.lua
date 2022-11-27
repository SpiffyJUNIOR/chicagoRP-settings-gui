chicagoRP = {}

chicagoRP.video = { -- simfphys camera, arccw, first person shadow, shmovement, vfire, simfphys, stormfox, atmos
    [1] = {
        convar = "cl_new_impact_effects",
        max = 1,
        min = 0,
        printname = "Fancy Impact Effects",
        text = "Fancy impact particles. May have heavy performance impact on low-spec computers."
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
        max = 1.00, -- float
        min = 0.00, -- float
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

chicagoRP.game = { -- simfphys camera, arccw, first person shadow, shmovement, vfire, simfphys, stormfox, atmos, 
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

chicagoRP.controls = {
    [1] = {
        bind = "+drop",
        printname = "Drop Weapon",
        text = "Drops the currently held weapon."
    },
    [2] = {
        bind = "holsterweapon",
        printname = "Holster Weapon",
        text = "Holsters the currently equipped weapon."
    },
    [3] = {
        bind = "jmod_ez_inv",
        printname = "Open Armor Inventory",
        text = "Open's JMod's armor inventory."
    },
    [4] = {
        bind = "jmod_ez_togglegoggles",
        printname = "Toggle/Untoggle Goggles",
        text = "Toggles or untoggles your currently equipped goggles."
    },
    [5] = {
        bind = "+drop",
        printname = "Drop Weapon",
        text = "Drops the currently held weapon."
    },
    [6] = {
        bind = "+drop",
        printname = "Drop Weapon",
        text = "Drops the currently held weapon."
    },
    [7] = {
        bind = "+drop",
        printname = "Drop Weapon",
        text = "Drops the currently held weapon."
    },
    [8] = {
        bind = "+drop",
        printname = "Drop Weapon",
        text = "Drops the currently held weapon."
    },
    [9] = {
        bind = "+drop",
        printname = "Drop Weapon",
        text = "Drops the currently held weapon."
    },
    [10] = {
        bind = "+drop",
        printname = "Drop Weapon",
        text = "Drops the currently held weapon."
    },
    [11] = {
        bind = "+drop",
        printname = "Drop Weapon",
        text = "Drops the currently held weapon."
    },
    [12] = {
        bind = "+drop",
        printname = "Drop Weapon",
        text = "Drops the currently held weapon."
    },
    [13] = {
        bind = "+drop",
        printname = "Drop Weapon",
        text = "Drops the currently held weapon."
    },
    [14] = {
        bind = "+drop",
        printname = "Drop Weapon",
        text = "Drops the currently held weapon."
    },
    [15] = {
        bind = "+drop",
        printname = "Drop Weapon",
        text = "Drops the currently held weapon."
    },
    [16] = {
        bind = "+drop",
        printname = "Drop Weapon",
        text = "Drops the currently held weapon."
    },
    [17] = {
        bind = "+drop",
        printname = "Drop Weapon",
        text = "Drops the currently held weapon."
    },
    [18] = {
        bind = "+drop",
        printname = "Drop Weapon",
        text = "Drops the currently held weapon."
    }
}

chicagoRP.categories = {
    [1] = {
        binding = "false",
        name = "video",
        printname = "VIDEO"
    },
    [2] = {
        binding = "false",
        name = "game",
        printname = "GAME"
    },
    [3] = {
        binding = "true",
        name = "controls",
        overridename = "KEY BINDINGS",
        printname = "CONTROLS"
    }
}

print("chicagoRP shared settings loaded!")