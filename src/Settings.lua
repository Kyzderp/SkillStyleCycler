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

    -- TODO: button to randomize, button to set all, button to clear all
    -- TODO: make each trigger a dropdown instead, with the option to do nothing
    -- TODO: maybe retry applying styles after a wait, for certain blocked reasons

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
        {
            type = "dropdown",
            name = "Mode",
            tooltip = "Randomize all - randomly choose a style, including the current\nRandomize different - randomly choose a style that is different from the current\nCycle - choose the next style in the list",
            choices = {"Randomize all", "Randomize different", "Cycle"},
            getFunc = function()
                return SSC.savedOptions.mode
            end,
            setFunc = function(value)
                SSC.savedOptions.mode = value
            end,
            width = "full",
        },
        {
            type = "description",
            title = "|c3bdb5eTriggers|r",
            text = nil,
            width = "full",
        },
        {
            type = "checkbox",
            name = "On login",
            tooltip = "Cycle styles on login",
            default = false,
            getFunc = function() return SSC.savedOptions.triggers.login end,
            setFunc = function(value)
                SSC.savedOptions.triggers.login = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "On exiting combat",
            tooltip = "Cycle styles on exiting combat",
            default = true,
            getFunc = function() return SSC.savedOptions.triggers.exitCombat end,
            setFunc = function(value)
                SSC.savedOptions.triggers.exitCombat = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "On loadscreen",
            tooltip = "Cycle styles on loadscreen (player activated)",
            default = true,
            getFunc = function() return SSC.savedOptions.triggers.loadscreen end,
            setFunc = function(value)
                SSC.savedOptions.triggers.loadscreen = value
            end,
            width = "full",
        },
    }

    SSC.addonPanel = LAM:RegisterAddonPanel("SkillStyleCyclerOptions", panelData)
    LAM:RegisterOptionControls("SkillStyleCyclerOptions", optionsData)
end