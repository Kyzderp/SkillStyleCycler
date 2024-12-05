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

local function CanChangeStyle(collectibleId)
    if (collectibleId == 0) then return true end -- This can happen if there's no style, but want to apply no style
    if (not IsCollectibleBlocked(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) and IsCollectibleUsable(collectibleId)) then
        return true
    end

    local reasons = {
        [COLLECTIBLE_USAGE_BLOCK_REASON_ACTIVE_DIG_SITE_REQUIRED] = "ACTIVE_DIG_SITE_REQUIRED",
        [COLLECTIBLE_USAGE_BLOCK_REASON_BLACKLISTED] = "BLACKLISTED",
        [COLLECTIBLE_USAGE_BLOCK_REASON_BLOCKED_BY_LEADERBOARD_EVENT] = "BLOCKED_BY_LEADERBOARD_EVENT",
        [COLLECTIBLE_USAGE_BLOCK_REASON_BLOCKED_BY_SUBZONE] = "BLOCKED_BY_SUBZONE",
        [COLLECTIBLE_USAGE_BLOCK_REASON_BLOCKED_BY_ZONE] = "BLOCKED_BY_ZONE",
        [COLLECTIBLE_USAGE_BLOCK_REASON_CATEGORY_REQUIREMENT_FAILED] = "CATEGORY_REQUIREMENT_FAILED",
        [COLLECTIBLE_USAGE_BLOCK_REASON_COLLECTIBLE_ALREADY_QUEUED] = "COLLECTIBLE_ALREADY_QUEUED",
        [COLLECTIBLE_USAGE_BLOCK_REASON_COMPANION_INTRO_QUEST] = "COMPANION_INTRO_QUEST",
        [COLLECTIBLE_USAGE_BLOCK_REASON_COMPANION_INTRO_QUEST_BLOCKED_BY_ZONE] = "COMPANION_INTRO_QUEST_BLOCKED_BY_ZONE",
        [COLLECTIBLE_USAGE_BLOCK_REASON_COMPANION_MENU_REQUIRED] = "COMPANION_MENU_REQUIRED",
        [COLLECTIBLE_USAGE_BLOCK_REASON_DEAD] = "DEAD",
        [COLLECTIBLE_USAGE_BLOCK_REASON_DEFAULT_ALREADY_ACTIVE] = "DEFAULT_ALREADY_ACTIVE",
        [COLLECTIBLE_USAGE_BLOCK_REASON_DUELING] = "DUELING",
        [COLLECTIBLE_USAGE_BLOCK_REASON_GROUP_FULL] = "GROUP_FULL",
        [COLLECTIBLE_USAGE_BLOCK_REASON_HAS_PENDING_COMPANION] = "HAS_PENDING_COMPANION",
        [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_ALLIANCE] = "INVALID_ALLIANCE",
        [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_CLASS] = "INVALID_CLASS",
        [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_COLLECTIBLE] = "INVALID_COLLECTIBLE",
        [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_GENDER] = "INVALID_GENDER",
        [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_RACE] = "INVALID_RACE",
        [COLLECTIBLE_USAGE_BLOCK_REASON_IN_AIR] = "IN_AIR",
        [COLLECTIBLE_USAGE_BLOCK_REASON_IN_COMBAT] = "IN_COMBAT",
        [COLLECTIBLE_USAGE_BLOCK_REASON_IN_HIDEY_HOLE] = "IN_HIDEY_HOLE",
        [COLLECTIBLE_USAGE_BLOCK_REASON_IN_WATER] = "IN_WATER",
        [COLLECTIBLE_USAGE_BLOCK_REASON_MAX_NUMBER_EQUIPPED] = "MAX_NUMBER_EQUIPPED",
        [COLLECTIBLE_USAGE_BLOCK_REASON_MOUNT_IN_COMBAT] = "MOUNT_IN_COMBAT",
        [COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED] = "NOT_BLOCKED",
        [COLLECTIBLE_USAGE_BLOCK_REASON_ON_COOLDOWN] = "ON_COOLDOWN",
        [COLLECTIBLE_USAGE_BLOCK_REASON_ON_MOUNT] = "ON_MOUNT",
        [COLLECTIBLE_USAGE_BLOCK_REASON_PLACED_IN_HOUSE] = "PLACED_IN_HOUSE",
        [COLLECTIBLE_USAGE_BLOCK_REASON_QUEST_FOLLOWER] = "QUEST_FOLLOWER",
        [COLLECTIBLE_USAGE_BLOCK_REASON_TARGET_REQUIRED] = "TARGET_REQUIRED",
        [COLLECTIBLE_USAGE_BLOCK_REASON_TEMPORARILY_DISABLED] = "TEMPORARILY_DISABLED",
        [COLLECTIBLE_USAGE_BLOCK_REASON_UNACQUIRED_SKILL] = "UNACQUIRED_SKILL",
        [COLLECTIBLE_USAGE_BLOCK_REASON_UNUSABLE_BY_COMPANION] = "UNUSABLE_BY_COMPANION",
        [COLLECTIBLE_USAGE_BLOCK_REASON_WORLD_BOSS] = "WORLD_BOSS",
        [COLLECTIBLE_USAGE_BLOCK_REASON_WORLD_EVENT] = "WORLD_EVENT",
    }

    local reason = GetCollectibleBlockReason(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    d(string.format("|cFF6600Can't change styles because %s|r", reasons[reason] or "???"))
    return false
end

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
        -- if (newIndex == data.active) then return end -- Same as current, so do nothing
    elseif (SSC.savedOptions.mode == "Randomize different") then
        -- Pick randomly
        newIndex = GetRandomNumberExcept(#data.available, data.active)
        -- if (newIndex == data.active) then return end -- Same as current, so do nothing
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

    -- Check if it's even usable
    if (not CanChangeStyle(collectibleId)) then return true, "" end

    if (data.active ~= newIndex) then
        data.active = newIndex
        UseCollectible(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    end
    return false, string.format("|t20:20:%s|t", icon)
end

local function CycleAll()
    local appliedIcons = ""
    for progressionId, _ in pairs(skillStyleTable) do
        local error, icon = MaybeChangeStyle(progressionId)
        if (error) then return end
        appliedIcons = appliedIcons .. " " .. icon
    end
    CHAT_SYSTEM:AddMessage("Applied:" .. appliedIcons)
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
    if (not inCombat and SSC.savedOptions.triggers.exitCombat) then
        d("changing styles because exited combat")
        CycleAll()
    end
end

---------------------------------------------------------------------
-- "Loadscreen"
local function OnPlayerActivated()
    if (SSC.savedOptions.triggers.loadscreen) then
        d("changing styles because player activated")
        CycleAll()
    end
end

---------------------------------------------------------------------
-- First time activated
local function OnPlayerActivatedFirstTIme()
    EVENT_MANAGER:UnregisterForEvent(SSC.name .. "FirstActivated", EVENT_PLAYER_ACTIVATED)

    BuildSkillStyleTable()

    if (SSC.savedOptions.triggers.login) then
        d("changing styles because login/reload")
        CycleAll()
    end

    EVENT_MANAGER:RegisterForEvent(SSC.name .. "PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

---------------------------------------------------------------------
-- Initialize
local function Initialize()
    SSC.savedOptions = ZO_SavedVars:NewAccountWide("SkillStyleCyclerSavedVariables", 1, "Options", defaultOptions)

    SSC.CreateSettingsMenu()

    EVENT_MANAGER:RegisterForEvent(SSC.name .. "FirstActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivatedFirstTIme)
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
