SkillStyleCycler = SkillStyleCycler or {}
local SSC = SkillStyleCycler


function SSC.CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "Skill Style Cycler",
        author = "Kyzeragon",
        version = SSC.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "description",
            title = "|c3bdb5eGeneral Settings|r",
            text = nil,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Debug",
            tooltip = "Show debug chat",
            default = false,
            getFunc = function() return SSC.savedOptions.debug end,
            setFunc = function(value)
                SSC.savedOptions.debug = value
            end,
            width = "full",
        },
    }

    SSC.addonPanel = LAM:RegisterAddonPanel("SkillStyleCyclerOptions", panelData)
    LAM:RegisterOptionControls("SkillStyleCyclerOptions", optionsData)
end