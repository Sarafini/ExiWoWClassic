local appName, internal = ...;
local require = internal.require;

-- Library for Conditions --
function internal.build.conditions()

	-- RPText Condition templates
	local Condition = require("Condition");	-- RPText requirement constructor
	local Action = require("Action");
	local ty = Condition.Types;				-- Local filter types
	local ext = internal.ext;
	local NPC = require("NPC");
	local Event = require("Event");

	-- Random chance
	ext:addCondition({id="rand10", type=ty.RTYPE_RANDOM, data={chance=0.1}});
	ext:addCondition({id="rand20", type=ty.RTYPE_RANDOM, data={chance=0.2}});
	ext:addCondition({id="rand30", type=ty.RTYPE_RANDOM, data={chance=0.3}});
	ext:addCondition({id="rand40", type=ty.RTYPE_RANDOM, data={chance=0.4}});
	ext:addCondition({id="rand50", type=ty.RTYPE_RANDOM, data={chance=0.5}});
	ext:addCondition({id="rand60", type=ty.RTYPE_RANDOM, data={chance=0.6}});
	ext:addCondition({id="rand70", type=ty.RTYPE_RANDOM, data={chance=0.7}});
	ext:addCondition({id="rand80", type=ty.RTYPE_RANDOM, data={chance=0.8}});
	ext:addCondition({id="rand90", type=ty.RTYPE_RANDOM, data={chance=0.9}});

	ext:addCondition({id="attackerHumanoid", type = ty.RTYPE_TYPE,sender = true,data = {Humanoid = true}});
	ext:addCondition({id="attackerBeast", type = ty.RTYPE_TYPE,sender = true,data = {Beast = true}});
	ext:addCondition({id="attackerHumanoidish", type = ty.RTYPE_TYPE, sender = true, data = {Humanoid = true, Undead = true, Demon=true}});
	ext:addCondition({id="victimBreasts", type = ty.RTYPE_HAS_BREASTS});
	ext:addCondition({id="victimPenis", type = ty.RTYPE_HAS_PENIS});
	ext:addCondition({id="victimVagina", type = ty.RTYPE_HAS_VAGINA});
	ext:addCondition({id="attackerBreasts", type = ty.RTYPE_HAS_BREASTS, sender=true});
	ext:addCondition({id="attackerPenis", type = ty.RTYPE_HAS_PENIS, sender=true});
	ext:addCondition({id="attackerVagina", type = ty.RTYPE_HAS_VAGINA, sender=true});
	ext:addCondition({id="largeBreasts", type = ty.RTYPE_BREASTS_GREATER, data={2}});
	ext:addCondition({id="largePenis", type = ty.RTYPE_PENIS_GREATER, data={2}});
	ext:addCondition({id="largeButt", type = ty.RTYPE_BUTT_GREATER, data={2}});
	ext:addCondition({id="attackerIsTentacleFiend", type=ty.RTYPE_TAG, data={"NPC_TENTACLE_FIEND"}, sender=true});
	ext:addCondition({id="attackerIsPinchy", type=ty.RTYPE_TAG, data={"NPC_PINCHY"}, sender=true});
	ext:addCondition({id="attackerIsWasp", type=ty.RTYPE_TAG, data={"NPC_WASP"}, sender=true});
	ext:addCondition({id="attackerIsLasher", type=ty.RTYPE_TAG, data={"NPC_LASHER"}, sender=true});
	ext:addCondition({id="attackerIsVines", type=ty.RTYPE_TAG, data={"NPC_VINES"}, sender=true});
	ext:addCondition({id="attackerIsOoze", type=ty.RTYPE_TAG, data={"NPC_OOZE"}, sender=true});
	ext:addCondition({id="attackerIsFeltotem", type=ty.RTYPE_TAG, data={"NPC_FELTOTEM"}, sender=true});
	ext:addCondition({id="attackerIsBogshambler", type=ty.RTYPE_TAG, data={"NPC_BOG_SHAMBLER"}, sender=true});
	ext:addCondition({id="attackerNotLarge", type=ty.RTYPE_TAG, data={"NPC_LARGE", "NPC_GIANT"}, sender=true, inverse=true});
	ext:addCondition({id="attackerSmallOrMedium", type=ty.RTYPE_TAG, data={"NPC_SMALL", "NPC_MEDIUM"}, sender=true, inverse=true});
	ext:addCondition({id="attackerIsSmall", type=ty.RTYPE_TAG, data={"NPC_SMALL"}, sender=true});
	ext:addCondition({id="attackerIsFistfighter", type=ty.RTYPE_TAG, data={"NPC_FISTFIGHTER"}, sender=true});
	ext:addCondition({id="attackerIsMogu", type=ty.RTYPE_TAG, data={"NPC_MOGU"}, sender=true});
	ext:addCondition({id="attackerIsPaleOrc", type=ty.RTYPE_TAG, data={"NPC_PALE_ORC"}, sender=true});
	ext:addCondition({id="attackerIsCloudSerpent", type=ty.RTYPE_TAG, data={"NPC_CLOUD_SERPENT"}, sender=true});
	ext:addCondition({id="attackerIsSaurolisk", type=ty.RTYPE_TAG, data={"NPC_SAUROLISK"}, sender=true});
	ext:addCondition({id="attackerHasTentacleStaff", type=ty.RTYPE_TAG, data={"TENTACLE_STAFF"}, sender=true});
	
	ext:addCondition({id="senderTaller", type=ty.RTYPE_SENDER_TALLER, data=false});
	ext:addCondition({id="senderMuchTaller", type=ty.RTYPE_SENDER_TALLER, data=true});
	ext:addCondition({id="senderShorter", type=ty.RTYPE_SENDER_SHORTER, data=false});
	ext:addCondition({id="senderMuchShorter", type=ty.RTYPE_SENDER_SHORTER, data=true});
	
	

	ext:addCondition({id="victimIsPandaren", type=ty.RTYPE_RACE, data={Pandaren=true}});
	


	ext:addCondition({id="maleWhispers", type=ty.RTYPE_REQUIRE_MALE});
	ext:addCondition({id="femaleWhispers", type=ty.RTYPE_REQUIRE_FEMALE});
	ext:addCondition({id="otherWhispers", type=ty.RTYPE_REQUIRE_OTHER});
	ext:addCondition({id="targetWearsUnderwear", type=ty.RTYPE_UNDIES, data={true}});
	ext:addCondition({id="targetNoUnderwear", type=ty.RTYPE_UNDIES, data={true}, inverse=true});
	
	ext:addCondition({id="victimKnockedDown", type = ty.RTYPE_TAG, data={"TMPSPELL_KNOCKDOWN"}});
	ext:addCondition({id="victimParalyzed", type = ty.RTYPE_HAS_AURA, data={{name="Paralysis"}}});
	ext:addCondition({id="invFeathers", type=ty.RTYPE_HAS_INVENTORY, data={{name="Light Feather"}}});
	ext:addCondition({id="victimHeadJumped", type=ty.RTYPE_TAG, data={"TMPSPELL_HEADJUMP"}});
	ext:addCondition({id="chestPlate", type=ty.RTYPE_EQUIPMENT, data={slot=5, type="Plate"}});
	ext:addCondition({id="chestLightArmor", type=ty.RTYPE_EQUIPMENT, data={slot=5, type={Leather=true, Cloth=true}}});
	ext:addCondition({id="chestHeavyArmor", type=ty.RTYPE_EQUIPMENT, data={slot=5, type={Plate=true, Mail=true}}});
	ext:addCondition({id="legsHeavyArmor", type=ty.RTYPE_EQUIPMENT, data={slot=7, type={Plate=true, Mail=true}}});
	ext:addCondition({id="victimChestNotPlate", type=ty.RTYPE_EQUIPMENT, data={slot=5, type={Plate=true}}, inverse=true});
	ext:addCondition({id="victimChestPlate", type=ty.RTYPE_EQUIPMENT, data={slot=5, type={Plate=true}}});
	ext:addCondition({id="victimCrotchPlate", type=ty.RTYPE_EQUIPMENT, data={slot=7, type={Plate=true}}});
	ext:addCondition({id="victimCrotchNotPlate", type=ty.RTYPE_EQUIPMENT, data={slot=7, type={Plate=true}}, inverse=true});
	ext:addCondition({id="targetTabard", type=ty.RTYPE_EQUIPMENT, data={slot=INVSLOT_TABARD}});

	
	ext:addCondition({id="hasChest", type=ty.RTYPE_EQUIPMENT, data={slot=5}});
	ext:addCondition({id="hasShirt", type=ty.RTYPE_EQUIPMENT, data={slot=4}});
	ext:addCondition({id="hasTabard", type=ty.RTYPE_EQUIPMENT, data={slot=19}});
	ext:addCondition({id="noChest", type=ty.RTYPE_EQUIPMENT, data={slot=5}, inverse = true});
	ext:addCondition({id="noShirt", type=ty.RTYPE_EQUIPMENT, data={slot=4}, inverse = true});
	ext:addCondition({id="noTabard", type=ty.RTYPE_EQUIPMENT, data={slot=19}, inverse = true});
	
	ext:addCondition({id="spellDetrimental", type=ty.RTYPE_DETRIMENTAL});
	ext:addCondition({id="spellBeneficial", type=ty.RTYPE_DETRIMENTAL, inverse = true});
	
	
	
	ext:addCondition({id="crotchPlate", type=ty.RTYPE_EQUIPMENT, data={slot=7, type="Plate"}});
	

	ext:addCondition({id="sender_party_restricted", type=ty.RTYPE_PARTY_RESTRICTED, sender=true});
	ext:addCondition({id="victim_party_restricted", type=ty.RTYPE_PARTY_RESTRICTED});
	ext:addCondition({id="is_self", type=ty.RTYPE_SELF_ONLY, sender=true});
	ext:addCondition({id="require_stealth", type=ty.RTYPE_STEALTH, sender=true});
	ext:addCondition({id="require_party", type=ty.RTYPE_PARTY});
	ext:addCondition({id="sender_combat", type=ty.RTYPE_COMBAT, sender=true});
	ext:addCondition({id="victim_combat", type=ty.RTYPE_COMBAT});
	ext:addCondition({id="sender_no_combat", type=ty.RTYPE_COMBAT, sender=true, inverse=true});
	ext:addCondition({id="victim_no_combat", type=ty.RTYPE_COMBAT, inverse=true});
	
	ext:addCondition({id="melee_range", type=ty.RTYPE_DISTANCE, data=Action.MELEE_RANGE});
	ext:addCondition({id="caster_range", type=ty.RTYPE_DISTANCE, data=Action.CASTER_RANGE});
	ext:addCondition({id="no_selfcast", type=ty.RTYPE_SELF_ONLY, sender=true, inverse=true});
	ext:addCondition({id="only_selfcast", type=ty.RTYPE_SELF_ONLY, sender=true});
	ext:addCondition({id="not_stunned", type=ty.RTYPE_STUNNED, inverse=true});
	ext:addCondition({id="stunned", type=ty.RTYPE_STUNNED});
	ext:addCondition({id="sender_not_moving", type=ty.RTYPE_MOVING, inverse=true, sender=true});
	ext:addCondition({id="victim_not_moving", type=ty.RTYPE_MOVING, inverse=true});
	ext:addCondition({id="not_in_instance", type=ty.RTYPE_INSTANCE, inverse=true});
	ext:addCondition({id="sender_alive", type=ty.RTYPE_DEAD, inverse=true, sender=true});
	ext:addCondition({id="victim_alive", type=ty.RTYPE_DEAD, inverse=true});
	ext:addCondition({id="sender_not_in_vehicle", type=ty.RTYPE_VEHICLE, inverse=true, sender=true});
	ext:addCondition({id="victim_not_in_vehicle", type=ty.RTYPE_VEHICLE, inverse=true});
	
	ext:addCondition({id="is_spell_add", type=ty.RTYPE_EVENT, data=Event.Types.SPELL_ADD});
	ext:addCondition({id="is_spell_tick", type=ty.RTYPE_EVENT, data=Event.Types.SPELL_TICK});
	ext:addCondition({id="is_spell_rem", type=ty.RTYPE_EVENT, data=Event.Types.SPELL_REM});
	ext:addCondition({id="is_spell_ran", type=ty.RTYPE_EVENT, data=Event.Types.SPELL_RAN});
	
	ext:addCondition({id="is_melee_attack", type=ty.RTYPE_EVENT, data=Event.Types.SWING});
	ext:addCondition({id="is_melee_crit", type=ty.RTYPE_EVENT, data=Event.Types.SWING_CRIT});
	ext:addCondition({id="is_monster_kill", type=ty.RTYPE_EVENT, data=Event.Types.MONSTER_KILL});
	ext:addCondition({id="is_forage", type=ty.RTYPE_EVENT, data=Event.Types.FORAGE});
	ext:addCondition({id="is_world_container", type=ty.RTYPE_EVENT, data=Event.Types.CONTAINER_OPENED});
	
	ext:addCondition({id="debug_fail_on_receive", type=ty.RTYPE_FAIL_ON_RECEIVE});
	
	ext:addCondition({id="victim_not_shapeshifted", type=ty.RTYPE_SHAPESHIFTED, inverse=true});
	
	
	ext:addCondition({id="sender_spec_1", type=ty.RTYPE_SPEC, data={["s1"]=true}, sender=true});
	ext:addCondition({id="sender_spec_2", type=ty.RTYPE_SPEC, data={["s2"]=true}, sender=true});
	ext:addCondition({id="sender_spec_3", type=ty.RTYPE_SPEC, data={["s3"]=true}, sender=true});
	ext:addCondition({id="sender_spec_4", type=ty.RTYPE_SPEC, data={["s4"]=true}, sender=true});


	ext:addCondition({id="sender_class_shaman", type=ty.RTYPE_CLASS, data={["Shaman"]=true}, sender=true});
	ext:addCondition({id="sender_class_hunter", type=ty.RTYPE_CLASS, data={["Hunter"]=true}, sender=true});
	ext:addCondition({id="sender_class_priest", type=ty.RTYPE_CLASS, data={["Priest"]=true}, sender=true});
	ext:addCondition({id="sender_class_mage", type=ty.RTYPE_CLASS, data={["Mage"]=true}, sender=true});
	ext:addCondition({id="sender_class_warlock", type=ty.RTYPE_CLASS, data={["Warlock"]=true}, sender=true});
	ext:addCondition({id="sender_class_demonhunter", type=ty.RTYPE_CLASS, data={["Demon Hunter"]=true}, sender=true});
	ext:addCondition({id="sender_class_rogue", type=ty.RTYPE_CLASS, data={["Rogue"]=true}, sender=true});
	ext:addCondition({id="sender_class_monk", type=ty.RTYPE_CLASS, data={["Monk"]=true}, sender=true});
	ext:addCondition({id="sender_class_druid", type=ty.RTYPE_CLASS, data={["Druid"]=true}, sender=true});
	ext:addCondition({id="sender_class_warrior", type=ty.RTYPE_CLASS, data={["Warrior"]=true}, sender=true});
	ext:addCondition({id="sender_class_deathknight", type=ty.RTYPE_CLASS, data={["Deathknight"]=true}, sender=true});
	ext:addCondition({id="sender_class_paladin", type=ty.RTYPE_CLASS, data={["Paladin"]=true}, sender=true});


	ext:addCondition({id="sender_race_pandaren", type=ty.RTYPE_RACE, data={Pandaren=true}, sender=true});
	ext:addCondition({id="sender_race_tauren", type=ty.RTYPE_RACE, data={Tauren=true}, sender=true});
	ext:addCondition({id="sender_race_worgen", type=ty.RTYPE_RACE, data={Worgen=true}, sender=true});
	ext:addCondition({id="sender_race_undead", type=ty.RTYPE_RACE, data={Scourge=true}, sender=true});

	ext:addCondition({id="sender_has_pet", type=ty.RTYPE_HAS_ACTION_PET, sender=true});
	

	-- Spell tick/add/rem tag conditions
	ext:addCondition({id="ts_insects", type=ty.RTYPE_TAG, data={"TMPSPELL_INSECTS"}, sender=true});
	ext:addCondition({id="ts_sand", type=ty.RTYPE_TAG, data={"TMPSPELL_SAND"}, sender=true});
	ext:addCondition({id="ts_dirt", type=ty.RTYPE_TAG, data={"TMPSPELL_DIRT"}, sender=true});
	ext:addCondition({id="ts_cold", type=ty.RTYPE_TAG, data={"TMPSPELL_COLD"}, sender=true});
	ext:addCondition({id="ts_electric", type=ty.RTYPE_TAG, data={"TMPSPELL_ELECTRIC"}, sender=true});
	ext:addCondition({id="ts_petrify", type=ty.RTYPE_TAG, data={"TMPSPELL_PETRIFY"}, sender=true});
	ext:addCondition({id="ts_shield_bash", type=ty.RTYPE_TAG, data={"TMPSPELL_SHIELD_BASH"}, sender=true});
	ext:addCondition({id="ts_steam_below", type=ty.RTYPE_TAG, data={"TMPSPELL_STEAM_BELOW"}, sender=true});
	ext:addCondition({id="ts_ground_spike", type=ty.RTYPE_TAG, data={"TMPSPELL_GROUND_SPIKE"}, sender=true});
	ext:addCondition({id="ts_magic_whip", type=ty.RTYPE_TAG, data={"TMPSPELL_MAGIC_WHIP"}, sender=true});
	ext:addCondition({id="ts_spillable", type=ty.RTYPE_TAG, data={"TMPSPELL_SPILLABLE"}, sender=true});
	ext:addCondition({id="ts_slosh", type=ty.RTYPE_TAG, data={"TMPSPELL_SLOSH"}, sender=true});
	ext:addCondition({id="ts_shards", type=ty.RTYPE_TAG, data={"TMPSPELL_SHARDS"}, sender=true});
	ext:addCondition({id="ts_roots", type=ty.RTYPE_TAG, data={"TMPSPELL_ROOTS"}, sender=true});
	
	
	-- Spells
	ext:addCondition({id="hasShadowManacles", type=ty.RTYPE_HAS_AURA, data={{name="Shadow Manacles"}}});
	
	
end