SkillStyleCycler = SkillStyleCycler or {}
local SSC = SkillStyleCycler
SSC.name = "SkillStyleCycler"
SSC.version = "0.0.0"

local defaultOptions = {
    debug = false,
    mode = "Randomize", -- Randomize, Cycle, ???
}

-- TODO: check using while dead?

---------------------------------------------------------------------------------------------------
local function PrintDebug(message)
    if (SSC.savedOptions.debug) then
        PrintDebug(message)
    end
end



---------------------------------------------------------------------------------------------------
-- Skill Styles
---------------------------------------------------------------------------------------------------
local function EquipAllSkillStyles()
    for skillType = 1, GetNumSkillTypes() do
        for skillLineIndex = 1, GetNumSkillLines(skillType) do
            -- The current class' 3 lines is always returned first, so skip the rest
            if (skillType == SKILL_TYPE_CLASS and skillLineIndex > 3) then break end

            for skillIndex = 1, GetNumSkillAbilities(skillType, skillLineIndex) do
                local progressionId = GetProgressionSkillProgressionId(skillType, skillLineIndex, skillIndex)
                local numStyles = GetNumProgressionSkillAbilityFxOverrides(progressionId)

                local _, _, _, _, _, _, progressionIndex = GetSkillAbilityInfo(skillType, skillLineIndex, skillIndex)
                local skillUnlocked = progressionIndex ~= nil

                if (numStyles > 0) then
                    local name = GetSkillAbilityInfo(skillType, skillLineIndex, skillIndex)
                    PrintDebug(zo_strformat("<<1>>-<<2>> <<3>> has <<4>> styles", skillLineIndex, skillIndex, name, numStyles))

                    if (not skillUnlocked) then
                        PrintDebug("...|cFF0000BUT THE SKILL IS NOT UNLOCKED AAAAAAAAAAAA|r")
                    end

                    -- Find the newest(?) unlocked one, while printing out all and checking for current active
                    local newestUnlocked
                    for i = 1, numStyles do
                        local fxIndex = numStyles + 1 - i -- Go backwards
                        local collectibleId = GetProgressionSkillAbilityFxOverrideCollectibleIdByIndex(progressionId, fxIndex)
                        if (IsCollectibleUnlocked(collectibleId)) then
                            if (not newestUnlocked) then
                                newestUnlocked = collectibleId
                            end

                            -- Don't override a style if one is already set
                            if (IsCollectibleActive(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)) then
                                PrintDebug(zo_strformat("...|c00FF00<<1>> (<<2>>)|r", GetCollectibleName(collectibleId), collectibleId))
                            else
                                local applying = newestUnlocked == collectibleId and skillUnlocked
                                PrintDebug(zo_strformat("...|cFF9900<<1>> (<<2>>)<<3>>|r",
                                    GetCollectibleName(collectibleId),
                                    collectibleId,
                                    applying and " |c00FF00- applying!" or ""))
                            end
                        else
                            PrintDebug(zo_strformat("...|cFF0000<<1>> (<<2>>)|r", GetCollectibleName(collectibleId), collectibleId))
                        end
                    end

                    -- Apply the newest unlocked if there isn't already one
                    if (skillUnlocked and newestUnlocked ~= nil) then
                        UseCollectible(newestUnlocked, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
                    end
                end
            end
        end
    end
end

---------------------------------------------------------------------
-- Combat state
local function OnCombatStateChanged(_, inCombat)
end

---------------------------------------------------------------------
-- Post Load (player loaded)
local function OnPlayerActivated(_, initial)
    OnCombatStateChanged(_, IsUnitInCombat("player"))
end

---------------------------------------------------------------------
-- Initialize
local function Initialize()
    SSC.savedOptions = ZO_SavedVars:NewAccountWide("SkillStyleCyclerSavedVariables", 1, "Options", defaultOptions)

    SSC.CreateSettingsMenu()

    EVENT_MANAGER:RegisterForEvent(SSC.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(SSC.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
end

---------------------------------------------------------------------
-- On load
local function OnAddOnLoaded(_, addonName)
    if (addonName == SSC.name) then
        EVENT_MANAGER:UnregisterForEvent(SSC.name, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(SSC.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
