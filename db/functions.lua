local appName, internal = ...;
local require = internal.require;

-- Library for Conditions --
function internal.build.functions()

	local Func = require("Func");
	local Event = require("Event");
	local Database = require("Database");
	local ext = internal.ext;

-- Sound kits
	-- /run ExiWoW.LibAssets.effects:painSound()
	ext:addFunction({
		id="painSound",
		fn = function(self, race, sex)
			local sounds = {
				HumanM = 2942,
				HumanF = 2938,
				NightElfM = 2957,
				NightElfF = 2934,
				DwarfM = 2930,
				DwarfF = 2926,
				GnomeM = 3276,
				GnomeF = 3270,
				DraeneiM = 8985,
				DraeneiF = 8989,
				WorgenM = 21451,
				WorgenF = 22452,
				OrcM = 0,
				OrcF = 40744,
				TrollM = 3308,
				TrollF = 3302,
				ScourgeM = 1316,
				ScourgeF = 1362,
				TaurenM = 1354,
				TaurenF = 227,
				BloodElfM = 8997,
				BloodElfF = 8993,
				GoblinM = 18494,
				GoblinF = 18499,
				PandarenM = 28825,
				PandarenF = 31718,
				VoidElfM = 95601,
				VoidElfF = 95603,
				LightforgedDraeneiM = 95750,
				LightforgedDraeneiF = 95732,
				HighmountainTaurenM = 95714,
				HighmountainTaurenF = 95492,
				NightborneM = 95786,
				NightborneF = 76815,
				MagharOrcF = 110564,
				MagharOrcM = 110539,
				DarkIronDwarfF = 101493,
				DarkIronDwarfM = 101511,
				ZandalariTrollF = 126971,
				ZandalariTrollM = 127343,
				KulTiranF = 127063,
				KulTiranM = 127160,
			}
			Func.get("playCharSound")(self, sounds, race, sex);
		end
	});

	-- /run ExiWoW.LibAssets.effects:critSound()
	ext:addFunction({
		id="critSound",
		fn = function(self, race, sex)
			local sounds = {
				HumanM = 2943,
				HumanF = 2939,
				NightElfM = 2958,
				NightElfF = 2935,
				DwarfM = 2931,
				DwarfF = 2927,
				GnomeM = 3277,
				GnomeF = 3271,
				DraeneiM = 8986,
				DraeneiF = 8990,
				WorgenM = 21452,
				WorgenF = 22453,
				OrcM = 0,
				OrcF = 40745,
				TrollM = 3309,
				TrollF = 3303,
				ScourgeM = 1317,
				ScourgeF = 1363,
				TaurenM = 1355,
				TaurenF = 228,
				BloodElfM = 8998,
				BloodElfF = 8994,
				GoblinM = 18495,
				GoblinF = 18500,
				PandarenM = 28824,
				PandarenF = 31719,
				VoidElfM = 95602,
				VoidElfF = 95604,
				LightforgedDraeneiM = 95749,
				LightforgedDraeneiF = 95731,
				HighmountainTaurenM = 95713,
				HighmountainTaurenF = 95491,
				NightborneM = 95785,
				NightborneF = 76816,
				MagharOrcF = 110565, -- VO_801_PC_Maghar_Orc_Female_Wound_Crit
				MagharOrcM = 110540,
				DarkIronDwarfF = 101494,
				DarkIronDwarfM = 101512,
				ZandalariTrollF = 126970,
				ZandalariTrollM = 127342,
				KulTiranF = 127062,
				KulTiranM = 127159,
			}
			Func.get("playCharSound")(self, sounds, race, sex);
		end
	});

	-- /run ExiWoW.LibAssets.effects:deathSound()
	ext:addFunction({
		id="deathSound",
		fn = function(self, race, sex)
			local sounds = {
				HumanM = 2944,
				HumanF = 2940,
				NightElfM = 2959,
				NightElfF = 2936,
				DwarfM = 2932,
				DwarfF = 2928,
				GnomeM = 3278,
				GnomeF = 3272,
				DraeneiM = 8987,
				DraeneiF = 8991,
				WorgenM = 22455,
				WorgenF = 22448,
				OrcM = 1322,
				OrcF = 213,
				TrollM = 3310,
				TrollF = 3304,
				ScourgeM = 1318,
				ScourgeF = 1364,
				TaurenM = 1356,
				TaurenF = 229,
				BloodElfM = 8999,
				BloodElfF = 8995,
				GoblinM = 18493,
				GoblinF = 18498,
				PandarenM = 28822,
				PandarenF = 31720,
				VoidElfM = 95605,
				VoidElfF = 95606,
				LightforgedDraeneiM = 95739,
				LightforgedDraeneiF = 95721,
				HighmountainTaurenM = 95703,
				HighmountainTaurenF = 95488,
				NightborneM = 76806,
				NightborneF = 76813,
				MagharOrcF = 110558,	-- VO_801_PC_Maghar_Orc_Female_Defeat
				MagharOrcM = 110533,
				DarkIronDwarfF = 101486,
				DarkIronDwarfM = 101501,
				ZandalariTrollF = 126968,
				ZandalariTrollM = 127340,
				KulTiranF = 127060,
				KulTiranM = 127157,
			}
			Func.get("playCharSound")(self, sounds, race, sex);
		end
	});

	ext:addFunction({
		id = "playCharSound",
		fn = function(self, library, race, sex)
			if not race then
				_,race = UnitRace("player");
			end
			if not gender then
				gender = UnitSex("player");
			end
			if gender == 2 then race = race.."M"
			elseif gender == 3 then race = race.."F"
			end
			race = race:gsub("%s+", "")
			if not library[race] then return end
			PlaySound(library[race], "SFX")
		end
	});

	ext:addFunction({
		id = "isShapeshifted",
		fn = function(self, library, race, sex)

			-- Transformation effects
			local effect_names = {
				["Skymirror Image"] = true,
				["Trapped in Amber"] = true,
				["Make Like A Tree"] = true,
				["Barnacle-Encrusted Gem"] = true,
				["Bloodmane Charm"] = true,
				["Bones of Transformation"] = true,
				["Botani Camouflage"] = true,
				["Burgy Blackheart's Handsome Hat"] = true,
				["Blessing of the Old God"] = true,
				["Burning Defender"] = true,
				["Celestial Defender"] = true,
				["Coin of Many Faces"] = true,
				["Twice-Cursed Arakkoa Feather"] = true,
				["Projection of a Future Fal'dorei"] = true,
				["Frenzyheart Brew"] = true,
				["Gamon's Heroic Spirit"] = true,
				["Ironbeard's Hat"] = true,
				["Goren Disguise"] = true,
				["Gurboggle's Gleaming Bauble"] = true,
				["Murloc Costume"] = true,
				["Frostborn Illusion"] = true,
				["Memory of Mr. Smite"] = true,
				["Observing the Cosmos"] = true,
				["Aspect of Moonfang"] = true,
				["Mark of the Ashtongue"] = true,
				["Duplicate Millhouse"] = true,
				["Mystic Image"] = true,
				["Wyrmtongue Disguise"] = true,
				["Leyara's Locket"] = true,
				["Surgical Alterations"] = true,
				["Kalytha's Haunted Locket"] = true,
				["Jewel of Hellfire"] = true,
				["Iron Boot "] = true,
				["Home-Made Party Mask"] = true,
				["Orb of Deception"] = true,
				["Blood Elf Illusion"] = true,
				["Warsong Orc Costume"] = true,
				["Podling Disguise"] = true,
				["Rime of the Time-Lost Mariner"] = true,
				["Ring of Broken Promises"] = true,
				["Gnomebulation"] = true,
				["Rukhmar's Sacred Memory"] = true,
				["Flesh to Stone"] = true,
				["Sha'tari Defender's Medallion"] = true,
				["Warden Guise"] = true,
				["Furbolg Form"] = true,
				["Stormforged Vrykul Horn"] = true,
				["Going Ape!"] = true,
				["Thistleleaf Disguise"] = true,
				["Blood Ritual"] = true,
				["Time-Lost Figurine"] = true,
				["Secret of the Ooze"] = true,
				["Vrykul Drinking Horn"] = true,
				["Whole-Body Shrinka'"] = true,
				["Will of Northrend"] = true,
				["Snowman"] = true,
				["Wisp Form"] = true,
			};


			-- Handle class based shapeshifts
			local _, uclass = UnitClass("player")
			-- Druid forms and ghost wolf
			if uclass == "DRUID" or uclass == "SHAMAN" then
				if GetShapeshiftForm() > 0 then
					return true;
				end
			end

			-- Iterate through effects
			local effects = {};
			local i = 1;
			local buff = UnitBuff("player", i);
			while buff do
				table.insert(effects, buff);
				i = i + 1;
				buff = UnitBuff("player", i);
			end
			i = 1;
			buff = UnitDebuff("player", i);
			while buff do
				table.insert(effects, buff);
				i = i + 1;
				buff = UnitDebuff("player", i);
			end

			for k,v in pairs(effects) do
				if v:find("Costume") then
					return true;
				end
				if effect_names[v] then
					return true;
				end
			end
			return false;
		end
	});

	
-- Reusable functions
	-- When sent from RP texts, the args are self, sender, target
	ext:addFunction({
		id="addExcitementMasochisticDefault",
		fn = function(self, ignoreVhProgram)
			-- Swing pain sounds are handled by WoW
			if type(self) ~= "table" or not self.id or (not self.id.SWING and not self.id.SWING_CRIT) then
				Func.get("painSound")();
			end
			Event.raise(Event.Types.EXADD_M_DEFAULT, {vh = not ignoreVhProgram})
			ExiWoW.ME:addExcitement(0.15, false, true);
		end
	});

	ext:addFunction({
		id= "addExcitementMasochisticCrit",
		fn = function(self, ignoreVhProgram)
			-- Swing pain sounds are handled by WoW
			-- Trigger pain sound if
			if 
				type(self) ~= "table" or -- Self is not a table, not 100% sure about this
				not self.id or
				(	-- It is a table, but
					not (self.id.SWING or self.id.SWING_CRIT) or -- It's not a melee swing
					localStorage.tank_mode -- Or tank mode is on
				) 
			then 
				Func.get("critSound")(); 
			end
			
			if type(ignoreVhProgram) ~= "boolean" then
				ignoreVhProgram = false
			end
			Event.raise(Event.Types.EXADD_M_CRIT, {vh = not ignoreVhProgram});
			ExiWoW.ME:addExcitement(0.3, false, true);
		end
	});

	ext:addFunction({
		id="addExcitementDefault",
		fn = function(self, ignoreVhProgram)
			if type(self) ~= "table" or not (self.id.SWING and not self.id.SWING_CRIT) then
				Func.get("painSound")();
			end
			Event.raise(Event.Types.EXADD_DEFAULT, {vh = not ignoreVhProgram})
			ExiWoW.ME:addExcitement(0.1);
		end
	});

	ext:addFunction({
		id="addExcitementCrit",
		fn = function(self, ignoreVhProgram)
			if type(self) ~= "table" or not (self.id.SWING and not self.id.SWING_CRIT) then
				Func.get("critSound")();
			end
			Event.raise(Event.Types.EXADD_CRIT, {vh = not ignoreVhProgram})
			ExiWoW.ME:addExcitement(0.2);
		end
	});

	ext:addFunction({
		id="addExcitement",
		fn = function(...)
			Func.get("addExcitementDefault")(...);
		end
	});


	ext:addFunction({
		id="addExcitementMasochistic",
		fn = function(...)
			Func.get("addExcitementMasochisticDefault")(...);
		end
	});
	

	ext:addFunction({
		id="toggleVibHubProgram",
		fn = function(program, duration)
			if not ExiWoW.VH then return end
			if not ExiWoW.VH.programs[program] then print("Unknown VH program", program); return end
			ExiWoW.VH.addTempProgram(ExiWoW.VH.programs[program], duration);
		end
	});
	
end

