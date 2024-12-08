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
    -- TODO: maybe retry applying styles after a wait, for certain blocked reasons
    -- TODO: don't change skills that aren't purchased
    -- TODO: toggleable which skills not to apply to
    -- TODO: disclaimer
    -- TODO: on cast

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
            type = "description",
            title = "|c3bdb5eTriggers|r",
            text = "Do nothing - do not change styles\nRandomize all - randomly choose a style, including the current\nRandomize different - randomly choose a style that is different from the current\nCycle - choose the next style in the list",
            width = "full",
        },
        {
            type = "dropdown",
            name = "On login",
            tooltip = "Change styles on login",
            choices = {SSC.Modes.DO_NOTHING, SSC.Modes.RANDOMIZE_ALL, SSC.Modes.RANDOMIZE_DIFFERENT, SSC.Modes.CYCLE},
            default = SSC.Modes.DO_NOTHING,
            getFunc = function() return SSC.savedOptions.triggers.login end,
            setFunc = function(value)
                SSC.savedOptions.triggers.login = value
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "On exiting combat",
            tooltip = "Cycle styles on exiting combat",
            choices = {SSC.Modes.DO_NOTHING, SSC.Modes.RANDOMIZE_ALL, SSC.Modes.RANDOMIZE_DIFFERENT, SSC.Modes.CYCLE},
            default = SSC.Modes.DO_NOTHING,
            getFunc = function() return SSC.savedOptions.triggers.exitCombat end,
            setFunc = function(value)
                SSC.savedOptions.triggers.exitCombat = value
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "On loadscreen",
            tooltip = "Cycle styles on loadscreen (player activated)",
            choices = {SSC.Modes.DO_NOTHING, SSC.Modes.RANDOMIZE_ALL, SSC.Modes.RANDOMIZE_DIFFERENT, SSC.Modes.CYCLE},
            default = SSC.Modes.DO_NOTHING,
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