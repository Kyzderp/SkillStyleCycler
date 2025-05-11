SkillStyleCycler = SkillStyleCycler or {}
local SSC = SkillStyleCycler

local CLASS_STYLE_PACK = "This is 1 of 21 styles in the Class Style Pack: Tamriel United bundle, previously available for free (with 2 >L50 characters) in the Crown Store."
local NEW_LIFE_STYLES = "This is 1 of 3 styles in the New Life Styles: Winter bundle, previously available for 2500 |t16:16:/esoui/art/currency/crowns_mipmap.dds|t in the Crown Store."
local CARNAVAL_CRATE_LEGENDARY = "This is a Legendary reward from Carnaval Crates, or directly purchased with 100 |t16:16:/esoui/art/currency/crowngem_mipmap.dds|t or 3600 |t16:16:/esoui/art/currency/currency_seals_of_endeavor_64.dds|t."
local CARNAVAL_CRATE_EPIC = "This is an Epic reward from Carnaval Crates, or directly purchased with 40 |t16:16:/esoui/art/currency/crowngem_mipmap.dds|t or 2000 |t16:16:/esoui/art/currency/currency_seals_of_endeavor_64.dds|t."

-- This is a manual map of where "purchasable" collectibles came from, if known.
-- The intention is to continually update this as more styles are
-- released, because scattered information is annoying, and uncollected
-- crown store styles don't show up in the collectibles menu.
SSC.sourceData = {
-----------------------------
-- CLASS
    [12945] = CLASS_STYLE_PACK, -- Lava Whip, Ice Blue
    [12944] = CLASS_STYLE_PACK, -- Fiery Breath, Ice Blue
    [12943] = CLASS_STYLE_PACK, -- Spiked Armor, Azure Blue

    [12952] = CLASS_STYLE_PACK, -- Puncturing Strikes, Ice Blue
    [12954] = CLASS_STYLE_PACK, -- Backlash, Ice Blue
    [12953] = CLASS_STYLE_PACK, -- Rushed Ceremony, Azure Blue

    [12947] = CLASS_STYLE_PACK, -- Death Stroke, Lilac Purple
    [12948] = CLASS_STYLE_PACK, -- Veiled Strike, Lilac Purple
    [12946] = CLASS_STYLE_PACK, -- Assassin's Blade, Lilac Purple

    [13059] = "This was available for 2000 |t16:16:/esoui/art/currency/crowns_mipmap.dds|t in the Crown Store.", -- Summon Winged Twilight, Warrior
    [12949] = CLASS_STYLE_PACK, -- Crystal Shard, Ruby Red
    [12951] = CLASS_STYLE_PACK, -- Daedric Curse, Ruby Red
    [12950] = CLASS_STYLE_PACK, -- Lightning Form, Ruby Red

    [1260] = "This is part of the Morrowind Collector's Pack.", -- Slate-Gray Summoned Bear
    [13051] = CLASS_STYLE_PACK, -- Scorch, Blazing Orange
    [13052] = CLASS_STYLE_PACK, -- Fungal Growth, Blazing Orange
    [13053] = CLASS_STYLE_PACK, -- Arctic Wind, Blazing Orange

    [13048] = CLASS_STYLE_PACK, -- Frozen Colossus, Carmine Red
    [13115] = CLASS_STYLE_PACK, -- Flame Skull, Onyx and Red
    [13050] = CLASS_STYLE_PACK, -- Death Scythe, Carmine Red

    [13046] = CLASS_STYLE_PACK, -- Runeblades, Azure Blue
    [13045] = CLASS_STYLE_PACK, -- Fatecarver, Soothing Blue
    [13047] = CLASS_STYLE_PACK, -- Runemend, Azure Blue

-----------------------------
-- WEAPON
    [13058] = NEW_LIFE_STYLES, -- Critical Charge, Winter's Gale
    [13056] = NEW_LIFE_STYLES, -- Volley, Winterfall
    [13446] = CARNAVAL_CRATE_LEGENDARY, -- Wall of Elements, Autumn Leaves
    [13447] = CARNAVAL_CRATE_EPIC, -- Whirlwind, Cinnabar Red

-----------------------------
-- ARMOR

-----------------------------
-- WORLD

-----------------------------
-- GUILD
    [13057] = NEW_LIFE_STYLES, -- Meteor, Winter's Blast
    [13448] = "This was available for 1500 |t16:16:/esoui/art/currency/crowns_mipmap.dds|t in the Crown Store.", -- Magelight, Passion Blossom

-----------------------------
-- ALLIANCE WAR
    [13449] = CARNAVAL_CRATE_LEGENDARY, -- War Horn, Aquatic
    [13460] = CARNAVAL_CRATE_EPIC, -- Vigor, Verdant Green
}