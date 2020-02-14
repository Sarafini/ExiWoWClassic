-- NPC Libraries (Don't forget to make NPC Name conditions out of these)
local appName, internal = ...;
local require = internal.require;

-- Library for Conditions --
function internal.build.loot()

	local RPText = require("RPText")
	local Condition = require("Condition");	-- RPText requirement constructor
	local Database = require("Database");
	local ty = Condition.Types;			-- Local filter types
	local function getCondition(id)
		return Database.getID("Condition", id);
	end
	local RPText = require("RPText");
	local Func = require("Func");
	local Loot = require("Loot");
	local Item = Loot.Item;

	-- Root extension
	local ext = internal.ext;
	local evtIsKill = Condition.get("is_monster_kill");
	local evtIsForage = Condition.get("is_forage");
	local evtIsWorldContainer = Condition.get("is_world_container");
	

	ext:addLoot({
		id = "KulTirasBoxers",
		conditions = {
			evtIsKill,
			Condition:new({id="kultirasBoxersKill", type=ty.RTYPE_NAME, data={["Sergeant Curtis"]=true, ["Lieutenant Palliter"]=true}, sender=true})
		},
		items = {
			Item:new({
				type = "Underwear", 
				id = "KULTIRAS_BOXERS", 
				chance = 1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "You found a folded pair of %item that %S was carrying!"
				})
			})
		}
	});
	ext:addLoot({
		id = "RazaaniEthereals",
		conditions = {
			evtIsKill,
			Condition:new({type=ty.RTYPE_ZONE, data="Blade's Edge Mountains"}),
			Condition:new({type=ty.RTYPE_NAME, data={["%Razaani"]=true}, sender=true}),
		},
		items = {
			Item:new({
				type = "Underwear", 
				id = "RAZAANI_SOULTHONG", 
				chance = 0.1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "%S was holding a small gem studded garment, you decide to hold on to it!"
				})
			});
		}
	})

	-- Morta's Arachnid Scepter
	ext:addLoot({
		id = "Morta's Arachnid Scepter",
		conditions = {
			evtIsKill,
			Condition:new({type=ty.RTYPE_ZONE, data="The Hinterlands"}),
			Condition:new({type=ty.RTYPE_NAME, data={["Morta'gya the Keeper"]=true}, sender=true}),
		},
		items = {
			Item:new({
				type = "Charges", 
				id = "MORTAS_ARACHNID_SCEPTER", 
				chance = 1,
				quant = math.huge,
				sound = 1191,
				text = RPText:new({
					text_receiver = "%S was holding a dark scepter with spider engravings."
				})
			});
		}
	})

	--[[
	ext:addLoot({
		conditions = {
			evtIsKill,
			Condition:new({type=ty.RTYPE_ZONE, data="Zangarmarsh"}),
			Condition:new({type=ty.RTYPE_NAME, data={["Bloodthirsty Marshfang"]=true}, sender=true}),
		},
		items = {
			Item:new({
				type = "Charges", 
				id = "TEST_ACTION", 
				chance = 1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "%S dropped a test item!"
				})
			})
		}
	})]]

	ext:addLoot({
		conditions = {
			evtIsKill,
			Condition:new({type=ty.RTYPE_ZONE, data="Netherstorm"}),
			Condition:new({type=ty.RTYPE_NAME, data={["Spellreaver Marathelle"]=true}, sender=true}),
		},
		items = {
			Item:new({
				type = "Underwear", 
				id = "BLACK_LACE_PANTIES", 
				chance = 1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "You find some small black lace panties hidden in one of %S's pockets!"
				})
			})
		}
	})

	ext:addLoot({
		conditions = {
			evtIsKill,
			Condition:new({type=ty.RTYPE_ZONE, data="Netherstorm"}),
			Condition:new({type=ty.RTYPE_NAME, data={["Summoner Kanthin"]=true}, sender=true}),
		},
		items = {
			Item:new({
				type = "Underwear", 
				id = "BLACK_LACE_SHORTS", 
				chance = 1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "You find some small black lace shorts hidden in one of %S's pockets!"
				})
			})
		}
	})

	-- Furbolg drops
	ext:addLoot({
		conditions = {
			evtIsKill,
			Condition:new({type=ty.RTYPE_TAG, data="NPC_FURBOLG", sender=true}),
		},
		items = {
			Item:new({
				type = "Underwear", 
				id = "FURBOLG_LOINCLOTH", 
				chance = 0.1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "You found a spare loincloth on the defeated furbolg!"
				})
			})
		}
	})

	-- Crab drops
	ext:addLoot({
		conditions = {
			evtIsKill,
			Condition:new({type=ty.RTYPE_TAG, data="NPC_PINCHY", sender=true}),
		},
		items={
			Item:new({
				type = "Charges", 
				id = "CLAW_PINCH", 
				chance = 0.05,
				quant = math.huge,
				text = RPText:new({
					text_receiver = "This big claw is pristine! I'll polish it and take it with me!"
				})
			})
		}
	})

	-- Satyr drops
	ext:addLoot({
		conditions = {
			evtIsKill,
			Condition:new({type=ty.RTYPE_TAG, data="NPC_SATYR", sender=true}),
		},
		items = {
			Item:new({
				type = "Underwear",
				id = "FELCLOTH_PANTIES",
				chance = 0.1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "The satyr was holding onto a small pair of felcloth panties!"
				})
			})
		}
	})

	ext:addLoot({
		conditions = {
			evtIsKill,
			Condition:new({type=ty.RTYPE_TAG, data="NPC_HARPY", sender=true}),
		},
		items = {
			Item:new({
				type = "Underwear",
				id = "JEWELED_HARPY_THONG",
				chance = 0.1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "You found an extra piece of underwear on the harpy!"
				})
			})
		}
	})




	-- World containers




	-- Foraged loot
	ext:addLoot({
		conditions = {
			evtIsForage,
			Condition:new({type=ty.RTYPE_ZONE, data="Durotar", sender=true}),
			Condition:new({type=ty.RTYPE_SUBZONE, data="Razor Hill", sender=true}),
		},
		items={
			Item:new({
				type = "Underwear", 
				id = "ORCISH_BRIEFS", 
				chance = 1,
				sound = 44577,
				text = RPText:new({
					text_receiver = "You find some orcish briefs in a crate. They seem unused!"
				})
			})
		}
	})


	--STRIPED_SHORTS
	ext:addLoot({
		conditions = {
			evtIsForage,
			Condition:new({type=ty.RTYPE_ZONE, data="Thousand Needles", sender=true}),
			Condition:new({type=ty.RTYPE_HAS_AURA, data={{name="River Boat"}}, sender=true}),
		},
		items = {
			Item:new({
				type = "Underwear", 
				id = "STRIPED_SHORTS", 
				chance = 1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "You find a spare pair of white striped shorts beneath the deck of your boat."
				})
			})
		}
	});

	ext:addLoot({
		conditions = {
			evtIsForage,
			Condition:new({type=ty.RTYPE_ZONE, data="Dustwallow Marsh", sender=true}),
			Condition:new({type=ty.RTYPE_LOC, data={x = 42.65, y=38.05, rad=0.16}, sender=true}),
		},
		items = {
			Item:new({
				type = "Underwear", 
				id = "KULTIRAS_BOXERS", 
				chance = 1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "You found a folded pair of %item!"
				})
			})
		}
	});

	ext:addLoot({
		conditions = {
			evtIsForage,
			Condition:new({type=ty.RTYPE_ZONE, data="Mount Hyjal", sender=true}),
			Condition:new({type=ty.RTYPE_SUBZONE, data="The Forge of Supplication", sender=true}),
		},
		items={
			Item:new({
				type = "Underwear", 
				id = "TWILIGHT_BRIEFS", 
				chance = 0.5,
				sound = 44577,
				text = RPText:new({
					text_receiver = "You found a box of surplus twilight briefs."
				})
			})
		}
	})

	ext:addLoot({
		conditions = {
			evtIsForage,
			Condition:new({type=ty.RTYPE_ZONE, data="Azsuna", sender=true}),
			Condition:new({type=ty.RTYPE_SUBZONE, data="Runas's Hovel", sender=true}),
			Condition:new({type=ty.RTYPE_LOC, data={x = 42.84, y=17.36, rad=0.1}, sender=true}),
		},
		items={
			Item:new({
				type = "Underwear", 
				id = "MANA_GEM_THONG", 
				chance = 1,
				sound = 44577,
				text = RPText:new({
					text_receiver = "You found a sparkling thong emanating mana. Embroidered into the waist is the word \"Elisande\". Maybe that has something to do with Runas' exile."
				})
			})
		}
	})

	ext:addLoot({
		conditions = {
			evtIsForage,
			Condition:new({type=ty.RTYPE_ZONE, data="Azsuna", sender=true}),
			Condition:new({type=ty.RTYPE_SUBZONE, data="Lair of the Deposed", sender=true}),
			Condition:new({type=ty.RTYPE_LOC, data={x = 49.49, y=8.1, rad=0.11}, sender=true}),
		},
		items={
			Item:new({
				type = "Underwear", 
				id = "ARCHMAGE_BRIEFS", 
				chance = 1,
				sound = 44577,
				text = RPText:new({
					text_receiver = "You found a pair of underwear that look like they may have belonged to a Kirin Tor archmage. 'Deposed' indeed."
				})
			})
		}
	})

	ext:addLoot({
		conditions = {
			evtIsForage,
			Condition:new({type=ty.RTYPE_ZONE, data="Suramar", sender=true}),
			Condition:new({type=ty.RTYPE_SUBZONE, data="Estate of the First Arcanist", sender=true}),
			Condition:new({type=ty.RTYPE_LOC, data={x = 65.75, y=62.89, rad=0.26}, sender=true}),
		},
		items={
			Item:new({
				type = "Underwear", 
				id = "BRIGHT_WHITE_BIKINI_BOTTOMS", 
				chance = 1,
				sound = 44577,
				text = RPText:new({
					text_receiver = "You find some bright-white bikini bottoms in a drawer. If Thalyssra asks, you could say Elisande's forces stole them."
				})
			})
		}
	})

	-- FEL_LEATHER_BRIEFS
	ext:addLoot({
		conditions = {
			evtIsForage,
			Condition:new({type=ty.RTYPE_ZONE, data="Felsoul Hold", sender=true}),
			Condition:new({type=ty.RTYPE_SUBZONE, data="Den of the Demented", sender=true}),
		},
		items={
			Item:new({
				type = "Underwear", 
				id = "FEL_LEATHER_BRIEFS", 
				chance = 0.25,
				sound = 44577,
				text = RPText:new({
					text_receiver = "You find a pair of black leather briefs inscribed with runes glowing with fel energy."
				})
			})
		}
	})
	
	

	ext:addLoot({
		conditions = {
			evtIsForage,
			Condition:new({type=ty.RTYPE_ZONE, data="Feralas", sender=true}),
			Condition:new({type=ty.RTYPE_SUBZONE, data="Woodpaw Den", sender=true}),
		},
		items={
			Item:new({
				type = "Underwear", 
				id = "SPIKED_LEATHER_JOCKSTRAP", 
				chance = 0.5,
				sound = 44577,
				text = RPText:new({
					text_receiver = "You find a discarded spiked leather jockstrap. These gnolls must be up to some weird stuff."
				})
			})
		}
	})


	ext:addLoot({
		conditions = {
			evtIsForage,
			Condition:new({type=ty.RTYPE_ZONE, data="Burning Steppes", sender=true}),
			Condition:new({type=ty.RTYPE_SUBZONE, data="The Skull Warren", sender=true}),
		},
		items={
			Item:new({
				type = "Underwear", 
				id = "SKULL_STRAP", 
				chance = 0.5,
				sound = 1199,
				text = RPText:new({
					text_receiver = "You find a skull with waist straps tucked away under some mushrooms"
				})
			})
		}
	})

	ext:addLoot({
		conditions = {
			evtIsForage,
			Condition:new({type=ty.RTYPE_ZONE, data="Felwood", sender=true}),
			Condition:new({type=ty.RTYPE_SUBZONE, data="Whisperwind Grove", sender=true}),
			Condition:new({type=ty.RTYPE_LOC, data={x = 45.06, y=29.37, rad=0.06}, sender=true}),
		},
		items={
			Item:new({
				type = "Underwear", 
				id = "LEAF_PANTIES", 
				chance = 1,
				sound = 911,
				text = RPText:new({
					text_receiver = "You sneakily look through the drawer, finding a pair of leafy panties. These must belong to Innkeeper Wylaria. You hastily pocket them."
				})
			})
		}
	})

	ext:addLoot({
		conditions = {
			evtIsForage,
			Condition:new({type=ty.RTYPE_ZONE, data="Winterspring", sender=true}),
			Condition:new({type=ty.RTYPE_SUBZONE, data="Everlook", sender=true}),
			{
				Condition:new({type=ty.RTYPE_LOC, data={x = 59.21, y=50.16, rad=0.1}, sender=true}),
				Condition:new({type=ty.RTYPE_LOC, data={x = 59.01, y=50.19, rad=0.14}, sender=true}),
				Condition:new({type=ty.RTYPE_LOC, data={x = 60.18, y=50.54, rad=0.09}, sender=true}),
				Condition:new({type=ty.RTYPE_LOC, data={x = 60.59, y=50.16, rad=0.29}, sender=true}),
			}
		},
		items={
			Item:new({
				type = "Underwear", 
				id = "WOOLY_SHORTS", 
				chance = 1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "You found a crate of wooly shorts. Hopefully nobody will mind if a pair goes missing."
				})
			})
		}
	})

	
	-- Sandy zones
	ext:addLoot({
		conditions = {
			evtIsForage,
			{
				Condition:new({type=ty.RTYPE_TAG, data="ZONE_SANDY", sender=true}),
				Condition:new({type=ty.RTYPE_SUBZONE, data={["%Strand"]=true, ["%Beach"]=true, ["%Shore"]=true}, sender=true}),
			}
		},
		items={
			Item:new({
				type = "Charges", 
				id = "THROW_SAND", 
				chance = 0.8,
				sound = 73172,
				text = RPText:new({
					text_receiver = "You found a handful of sand!"
				})
			})
		}
	});

	-- Swamps
	ext:addLoot({
		conditions = {
			evtIsForage,
			{
				Condition:new({type=ty.RTYPE_TAG, data="ZONE_SWAMP", sender=true}),
				Condition:new({type=ty.RTYPE_SUBZONE, data={["%Swamp"]=true, ["%Marsh"]=true, ["%Bog"]=true}, sender=true}),
			}
		},
		items={
			Item:new({
				type = "Charges", 
				id = "SWAMP_MUCK", 
				chance = 0.8,
				sound = 73172,
				text = RPText:new({
					text_receiver = "You found a handful of swamp muck!"
				})
			})
		}
	});

	-- Calming potion loot
	ext:addLoot({
		conditions = {
			evtIsForage,
			Condition:new({type=ty.RTYPE_SUBZONE, data="Tabetha's Farm"}),
		},
		items={
			Item:new({
				type = "Charges", 
				id = "CALMING_POTION", 
				chance = 0.5,
				sound = 1197,
				text = RPText:new({
					text_receiver = "You found a calming potion!"
				})
			})
		}
	})


	ext:addLoot({
		conditions = {
			evtIsForage,
			Condition:new({type=ty.RTYPE_ZONE, data="Swamp of Sorrows", sender=true}),
			Condition:new({type=ty.RTYPE_SUBZONE, data="Bogpaddle", sender=true}),
			{
				Condition:new({type=ty.RTYPE_LOC, data={x = 72.41, y=16.89, rad=0.22}, sender=true}),
				Condition:new({type=ty.RTYPE_LOC, data={x = 72.39, y=12.77, rad=0.32}, sender=true}),
			}
		},
		items={
			Item:new({
				type = "Underwear", 
				id = "HIGH_RISING_BIKINI_THONG_PINK", 
				chance = 1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "You find a crate of pink bikini thongs, hopefully nobody will notice if one goes missing!"
				})
			})
		}
	})

	ext:addLoot({
		conditions = {
			evtIsForage,
			Condition:new({type=ty.RTYPE_ZONE, data="Hellfire Peninsula", sender=true}),
			Condition:new({type=ty.RTYPE_LOC, data={x = 22.13, y=68.27, rad=0.1}, sender=true}),
		},
		items={
			Item:new({
				type = "Underwear", 
				id = "NETHERWEAVE_PANTIES", 
				chance = 1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "You find a skimpy pair of netherweave panties that seem to have been left behind!"
				})
			})
		}
	})

	-- Crescent thong
	ext:addLoot({
		conditions = {
			evtIsForage,
			Condition:new({type=ty.RTYPE_ZONE, data="Zangarmarsh", sender=true}),
			Condition:new({type=ty.RTYPE_LOC, data={x = 23.41, y=66.33, rad=0.08}, sender=true}),
		},
		items={
			Item:new({
				type = "Underwear", 
				id = "CRESCENT_THONG", 
				chance = 1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "While Leesah'oh isn't watching, you snatch one of her panties from a crate in her tent!"
				})
			})
		}
	})

	


	
end
