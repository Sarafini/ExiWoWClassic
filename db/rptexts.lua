local appName, internal = ...
local require = internal.require;

function internal.build.rptexts()
	
	local Condition = require("Condition");	-- RPText requirement constructor
	local Database = require("Database");
	local ty = Condition.Types;			-- Local filter types
	local function getCondition(id)
		return Database.getID("Condition", id);
	end
	local RPText = require("RPText");
	local Func = require("Func");

	-- Root extension
	local ext = internal.ext;
		
	-- Only wholesome family friendly PG stuff in here

	-- Tickle target
		ext:addRpText({
			id = "TICKLE",
			text_sender = "You tickle %T!",
			text_receiver = "%T tickles you!",
			requirements = {},
		})

	-- Tickle self
		ext:addRpText({
			id = "TICKLE",
			text_bystander = "%T tickles %Thimself!",
			text_receiver = "You tickle yourself!",
			requirements = {},
			
		})
	-- Wedgie
		ext:addRpText({
			id = "WEDGIE",
			text_bystander = "%S grabs a hold of %T's %Tundies, giving %Thim a wedgie!",
			text_sender = "You grab a hold of %T's %Tundies, giving %Thim a wedgie!",
			text_receiver = "%S grabs a hold of your %Tundies, giving you a wedgie!",
			sound = 25626,
			requirements = {getCondition("targetWearsUnderwear")},
			visual = "heavyPain",
		})

		ext:addRpText({
			id = "WEDGIE",
			text_bystander = "%T grabs a hold of %This %Tundies and gives %Thimself a wedgie!",
			text_receiver = "You grab a hold of your %Tundies and give yourself a wedgie!",
			sound = 25626,
			requirements = {getCondition("targetWearsUnderwear")},
			visual = "heavyPain"
		});
	

	--SHOCKTACLE
		ext:addRpText({
			id = "SHOCKTACLE",
			text_bystander = "%S lashes %T with a lightning tentacle!",
			text_sender = "You lash %T with your lightning tentacle!",
			text_receiver = "%S lashes you with %Shis lightning tentacle!",
			sound = 3338,
			requirements = {},
			visual = "lightning",
		})
		ext:addRpText({
			id = "SHOCKTACLE",
			text_bystander = "%S lashes %Shimself with a lightning tentacle!",
			text_receiver = "You lash yourself with your lightning tentacle!",
			sound = 3338,
			visual = "lightning",
			requirements = {},
		})

	-- Insect swarm
		ext:addRpText({
			text_receiver = "The insects get into your equipment, skittering across your body!",
			requirements = {
				getCondition("is_spell_add"), 
				getCondition("ts_insects"), 
			},
			fn = Func.get("addExcitementDefault")
		})

	-- Sand ADD
		ext:addRpText({
			text_receiver = "Sand gets into your clothes!",
			requirements = {
				getCondition("is_spell_add"),
				getCondition("ts_sand"), 
			},
			fn = Func.get("addExcitementMasochistic")
		})

		ext:addRpText({
			text_receiver = "Some dirt gets into your clothes!",
			requirements = {
				getCondition("is_spell_tick"),
				getCondition("ts_dirt"),
			},
			fn = Func.get("addExcitementMasochistic")
		})

		ext:addRpText({
			id = "THROW_SAND",
			text_bystander = "%T throws sand into the air, some of which falls back down on %Thim and into %This clothes!",
			text_receiver = "You throw sand into the air, some of which falls back down on you and into your clothes!",
			sound = 73172,
			requirements = {},
		});

		ext:addRpText({
			id = "SWAMP_MUCK",
			text_bystander = "%S throws a glob of swamp muck at %T!",
			text_sender = "You throw a glob of swamp muck at %T!",
			text_receiver = "%S throws a glob of swamp muck at you!",
			sound = 20674,
			visual = "greenSplatPersistent",
			requirements = {}
		});

		ext:addRpText({
			id = "SWAMP_MUCK",
			text_bystander = "%T throws a glob of swamp muck into the air, some of which falls back down on %Thim and into %This clothes!",
			text_receiver = "You throw a glob of swamp muck into the air, some of which falls back down on you and into your clothes!",
			sound = 20674,
			visual = "greenSplatPersistent",
			requirements = {}
		});

		ext:addRpText({
			id = "THROW_SAND",
			text_bystander = "%S throws a handful of sand at %T!",
			text_sender = "You throw a handful of sand at %T!",
			text_receiver = "%S throws a handful of sand at you!",
			sound = 907,
			requirements = {}
		});

		ext:addRpText({
			id = "MORTAS_ARACHNID_SCEPTER",
			text_bystander = "%S casts a hex on %T!",
			text_sender = "You cast a hex on %T!",
			text_receiver = "%S casts a hex on you!",
		});
		ext:addRpText({
			id = "MORTAS_ARACHNID_SCEPTER",
			text_receiver = "You cast a hex on yourself!",
		});
		

		ext:addRpText({
			id = "CLAW_PINCH",
			text_bystander = "%S pinches %T's side with a big claw!",
			text_sender = "You pinch %T's side with your big claw!",
			text_receiver = "%S pinches your side with %Shis big claw!",
			sound = 36721,
			requirements = {}
		})
		ext:addRpText({
			id = "CLAW_PINCH",
			text_bystander = "%T pinches %T's nose with a big claw!",
			text_sender = "You pinch %T's nose with your big claw!",
			text_receiver = "%S pinches your nose with %Shis big claw!",
			sound = 36721,
			requirements = {}
		})
		ext:addRpText({
			id = "CLAW_PINCH",
			text_bystander = "%T pinches %This own nose with a big claw!",
			text_receiver = "You pinch your nose with your big claw!",
			sound = 36721,
			requirements = {}
		})

	-- Priest Allure
		ext:addRpText({
			id = "ALLURE",
			text_sender = "You mind control %T, forcing %Thim to follow you!",
			text_receiver = "%S casts a mind control spell on you, forcing you to follow!",
			sound = 14381,
			requirements = {}
		})


	-- Slosh
		ext:addRpText({
			text_receiver = "%spell splashes across your face!",
			requirements = {
				getCondition("ts_slosh"),
				getCondition("rand10"),
				getCondition("spellDetrimental")
			},
		});
	
	-- RP VOICE LINES

		-- Mogu
			ext:addRpText({
				id = "_WHISPER_",
				is_chat = true,
				sound = 26944,
				text_receiver = "%S whispers: Pandaren were meant to serve!",
				requirements = {
					getCondition("attackerIsMogu"),
					getCondition("victimIsPandaren")
				},
			});
			ext:addRpText({
				id = "_WHISPER_",
				is_chat = true,
				sound = 26944,
				text_receiver = "%S whispers: A pandaren? I will enjoy putting you back in chains!",
				requirements = {
					getCondition("attackerIsMogu"),
					getCondition("victimIsPandaren")
				},
			});
			ext:addRpText({
				id = "_WHISPER_",
				is_chat = true,
				sound = 26944,
				text_receiver = "%S whispers: A pandaren escaping %This chains!?",
				requirements = {
					getCondition("attackerIsMogu"),
					getCondition("victimIsPandaren")
				},
			});
			ext:addRpText({
				id = "_WHISPER_",
				is_chat = true,
				sound = 26944,
				text_receiver = "%S whispers: Get back in your cage, panda!",
				requirements = {
					getCondition("attackerIsMogu"),
					getCondition("victimIsPandaren")
				},
			});
			
			

end