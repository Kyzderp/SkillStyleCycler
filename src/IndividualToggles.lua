SkillStyleCycler = SkillStyleCycler or {}
local SSC = SkillStyleCycler

local BASE_STYLE_ID = -1 -- Just so I stop confusing myself

--[[
enabledStyles = {
    [progressionId] = {
        name = "blah",
        texture = "blah",
        styles = {
            [BASE_STYLE_ID] = true, (base style)
            [collectibleId] = true,
            [collectibleId] = false,
        },
    },
}
]]
local function CollectEnabledStylesKeys(enabledStyles)
    for skillType = 1, GetNumSkillTypes() do
        for skillLineIndex = 1, GetNumSkillLines(skillType) do
            for skillIndex = 1, GetNumSkillAbilities(skillType, skillLineIndex) do
                local progressionId = GetProgressionSkillProgressionId(skillType, skillLineIndex, skillIndex)
                local numStyles = GetNumProgressionSkillAbilityFxOverrides(progressionId)

                if (numStyles > 0) then
                    local name, texture = GetSkillAbilityInfo(skillType, skillLineIndex, skillIndex)

                    -- Add skill if doesn't exist; name/texture could be different if you have it morphed on the class, but it's probably ok
                    if (not enabledStyles[progressionId]) then
                        enabledStyles[progressionId] = {name = name, texture = texture, styles = {[BASE_STYLE_ID] = true,}}
                    end

                    -- Find the newest(?) unlocked one, while printing out all and checking for current active
                    for i = 1, numStyles do
                        local collectibleId = GetProgressionSkillAbilityFxOverrideCollectibleIdByIndex(progressionId, i)

                        -- For some reason, there are "styles" that don't exist but return 0 and are included in the number of styles. Unreleased?
                        if (collectibleId ~= 0) then
                            -- Add style if it doesn't exist, defaulting to true
                            if (enabledStyles[progressionId].styles[collectibleId] == nil) then
                                enabledStyles[progressionId].styles[collectibleId] = true
                            end

                            -- Overwrite this anyway so it's updated for the current morphs/class
                            enabledStyles[progressionId].name = name
                            enabledStyles[progressionId].texture = texture
                        end
                    end
                end
            end
        end
    end
end
SSC.CollectEnabledStylesKeys = CollectEnabledStylesKeys
-- /script local a = {} SkillStyleCycler.CollectEnabledStylesKeys(a) d(a)

local function CreateStyleSetting(controls, progressionId, collectibleId)
    local name
    if (collectibleId == BASE_STYLE_ID) then
        name = zo_strformat("|t30:30:<<1>>|t <<2>>", SSC.savedOptions.enabledStyles[progressionId].texture, SSC.savedOptions.enabledStyles[progressionId].name)
    else
        name = zo_strformat("|t30:30:<<1>>|t <<2>>", GetCollectibleIcon(collectibleId), GetCollectibleName(collectibleId))
    end

    table.insert(controls, {
        type = "checkbox",
        name = name,
        tooltip = "yeet",
        default = true,
        getFunc = function() return SSC.savedOptions.enabledStyles[progressionId].styles[collectibleId] end,
        setFunc = function(value)
            SSC.savedOptions.enabledStyles[progressionId].styles[collectibleId] = value
            SSC.BuildSkillStyleTable()
        end,
        width = "full",
    })
end

local function CreateSkillSettings(controls, progressionId)
    -- Skills with only 1 style (base) could have been included because of 0-collectibles
    local hasStyles = false
    for collectibleId, _ in pairs(SSC.savedOptions.enabledStyles[progressionId].styles) do
        if (collectibleId ~= BASE_STYLE_ID) then hasStyles = true end
    end
    if (not hasStyles) then return end

    table.insert(controls, {
        type = "description",
        title = SSC.savedOptions.enabledStyles[progressionId].name,
        text = nil,
        width = "full",
    })

    for collectibleId, _ in pairs(SSC.savedOptions.enabledStyles[progressionId].styles) do
        CreateStyleSetting(controls, progressionId, collectibleId)
    end
end

local function CreateToggleSettings()
    CollectEnabledStylesKeys(SSC.savedOptions.enabledStyles)

    local controls = {}
    for progressionId, _ in pairs(SSC.savedOptions.enabledStyles) do
        CreateSkillSettings(controls, progressionId)
    end

    return {
        type = "submenu",
        name = "Individual Toggles",
        controls = controls,
    }
end
SSC.CreateToggleSettings = CreateToggleSettings
