SkillStyleCycler = SkillStyleCycler or {}
local SSC = SkillStyleCycler
SSC.name = "SkillStyleCycler"
SSC.version = "0.0.0"

local defaultOptions = {
    debug = false,
    mode = "Randomize all", -- Randomize all (including current), Randomize different, Cycle, ???
    triggers = {
        login = false,
        exitCombat = true,
        loadscreen = true, -- really just on player activated
    },
}


---------------------------------------------------------------------------------------------------
local function PrintDebug(message)
    if (SSC.savedOptions.debug) then
        d(message)
    end
end


---------------------------------------------------------------------
---------------------------------------------------------------------
--[[
A map of progressionId to the collectible IDs, but only if the skill is unlocked and the collectibles are unlocked
{
    progressionId = {
        available = {0, 139213, 345435}, -- Treat 0 as no style applied
        active = 1, -- The index, 1, 2...
    }
}
]]
local skillStyleTable = {}

-- 1 ~ num
local function GetRandomNumber(num)
    return math.floor(math.random() * num + 1)
end

-- 1 ~ num except for except
local function GetRandomNumberExcept(num, except)
    local result = GetRandomNumber(num - 1)
    if (result >= except) then
        return result + 1
    end
    return result
end
-- /script local a = {} for i = 1, 1000 do local b = SkillStyleCycler.GetRandomNumberExcept(5, 4) if not a[b] then a[b] = 0 end a[b] = a[b] + 1 end d(a)

local function MaybeChangeStyle(progressionId)
    local data = skillStyleTable[progressionId]
    if (not data) then return end

    local newIndex
    if (SSC.savedOptions.mode == "Cycle") then
        -- Increment, wrapping around if needed
        newIndex = data.active + 1
        if (newIndex > #data.available) then
            newIndex = 1
        end
    elseif (SSC.savedOptions.mode == "Randomize all") then
        -- Pick randomly
        newIndex = GetRandomNumber(#data.available)
        if (newIndex == data.active) then return end -- Same as current, so do nothing
    elseif (SSC.savedOptions.mode == "Randomize different") then
        -- Pick randomly
        newIndex = GetRandomNumberExcept(#data.available, data.active)
        if (newIndex == data.active) then return end -- Same as current, so do nothing
    else
        d("|cFF0000????|r")
        return
    end

    -- Find the ID and icon
    local collectibleId = data.available[newIndex]
    local icon
    -- If the desired is the base style, deactivate the previous one
    if (collectibleId == 0) then
        collectibleId = data.available[data.active]
        local morph = GetProgressionSkillCurrentMorphSlot(progressionId)
        local abilityId = GetProgressionSkillMorphSlotAbilityId(progressionId, morph)
        icon = GetAbilityIcon(abilityId)
    else
        icon = GetCollectibleIcon(collectibleId)
    end
    data.active = newIndex

    UseCollectible(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    PrintDebug(string.format("|t20:20:%s|t", icon))
end

local function CycleAll()
    for progressionId, _ in pairs(skillStyleTable) do
        MaybeChangeStyle(progressionId)
    end
end
SSC.CycleAll = CycleAll -- /script SkillStyleCycler.CycleAll()


---------------------------------------------------------------------------------------------------
-- Initialize
---------------------------------------------------------------------------------------------------
local function BuildSkillStyleTable()
    d("building skill style table")
    for skillType = 1, GetNumSkillTypes() do
        for skillLineIndex = 1, GetNumSkillLines(skillType) do
            -- The current class' 3 lines is always returned first, so skip the rest
            if (skillType == SKILL_TYPE_CLASS and skillLineIndex > 3) then break end

            for skillIndex = 1, GetNumSkillAbilities(skillType, skillLineIndex) do
                local progressionId = GetProgressionSkillProgressionId(skillType, skillLineIndex, skillIndex)
                local numStyles = GetNumProgressionSkillAbilityFxOverrides(progressionId)

                -- Make sure the skill is unlocked
                local _, _, _, _, _, _, progressionIndex = GetSkillAbilityInfo(skillType, skillLineIndex, skillIndex)

                if (progressionIndex ~= nil and numStyles > 0) then
                    -- Collect list of unlocked styles
                    local unlockedStyles = {0}
                    local activeStyle = 1
                    for fxIndex = 1, numStyles do
                        local collectibleId = GetProgressionSkillAbilityFxOverrideCollectibleIdByIndex(progressionId, fxIndex)
                        if (IsCollectibleUnlocked(collectibleId)) then
                            table.insert(unlockedStyles, collectibleId)
                            if (IsCollectibleActive(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)) then
                                activeStyle = fxIndex + 1
                            end
                        end
                    end

                    -- Only add it to the table if there are styles unlocked, obv
                    if (#unlockedStyles > 1) then
                        skillStyleTable[progressionId] = {
                            available = unlockedStyles,
                            active = activeStyle,
                        }
                    end
                end
            end
        end
    end
end


---------------------------------------------------------------------------------------------------
-- Apply all
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

    EVENT_MANAGER:RegisterForEvent(SSC.name .. "FirstActivated", EVENT_PLAYER_ACTIVATED, function()
            BuildSkillStyleTable()
            EVENT_MANAGER:UnregisterForEvent(SSC.name .. "FirstActivated", EVENT_PLAYER_ACTIVATED)
        end)
    EVENT_MANAGER:RegisterForEvent(SSC.name .. "PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
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
