-- NPC Libraries (Don't forget to make NPC Name conditions out of these)
local appName, internal = ...;
local require = internal.require;

-- Library for Conditions --
function internal.build.npcs()

	local NPC = require("NPC");
	local Database = require("Database");
	local ext = internal.ext;

	ext:addNPC({id="Writhing Terror",tags={"TENTACLE_FIEND", "LASHER"}});
	ext:addNPC({id="Fiendling Flesh Beast",tags={"TENTACLE_FIEND", "LASHER"}});
	ext:addNPC({id="Fleshfiend",tags={"TENTACLE_FIEND", "LASHER"}});
	ext:addNPC({id="Parasitic Fleshbeast",tags={"TENTACLE_FIEND", "LASHER"}});
	ext:addNPC({id="Nightmare Terror",tags={"TENTACLE_FIEND", "LASHER"}});
	ext:addNPC({id="Shadowfiend",tags={"TENTACLE_FIEND", "LASHER"}});
	ext:addNPC({id="Slumbering Nightmare",tags={"TENTACLE_FIEND", "LASHER"}});
	ext:addNPC({id="Blighted Manifestation",tags={"TENTACLE_FIEND", "LASHER", "SMALL"}});
	
	ext:addNPC({id="%Boulderslide",tags={"KOBOLD", "FISTFIGHTER", "SMALL"}});

	ext:addNPC({id="%Scorpid",tags={"PINCHY"}});
	ext:addNPC({id="%Chitterspine",tags={"PINCHY"}});
	ext:addNPC({id="%Glimmershell",tags={"PINCHY"}});
	ext:addNPC({id="Desert Crawler",tags={"PINCHY"}});
	ext:addNPC({id="%Duneclaw",tags={"PINCHY"}});
	ext:addNPC({id="Duneshore Crab",tags={"PINCHY"}});
	ext:addNPC({id="Scorpid Worker",tags={"PINCHY"}});
	ext:addNPC({id="%Surf Crawler",tags={"PINCHY"}});
	ext:addNPC({id="Silt Crawler",tags={"PINCHY"}});
	ext:addNPC({id="Clattering Crawler",tags={"PINCHY"}});
	ext:addNPC({id="Spined Crawler",tags={"PINCHY"}});
	ext:addNPC({id="%Makrura",tags={"PINCHY"}});
	ext:addNPC({id="%Mak'Rana",tags={"PINCHY"}});
	ext:addNPC({id="King Azureback",tags={"PINCHY"}});
	ext:addNPC({id="Moonshell Crawler",tags={"PINCHY"}});
	ext:addNPC({id="Skittering Doomstinger",tags={"PINCHY"}});
	ext:addNPC({id="%Scorpashi",tags={"PINCHY"}});
	ext:addNPC({id="%Bogstrok",tags={"PINCHY"}});
	ext:addNPC({id="%Drysnap",tags={"PINCHY"}});
	ext:addNPC({id="%Tide Crawler",tags={"PINCHY"}});
	ext:addNPC({id="Deepwater Spikeback",tags={"PINCHY"}});

	ext:addNPC({id="Sabreclaw Skitterer",tags={"PINCHY"}});
	ext:addNPC({id="Splitclaw Skitterer",tags={"PINCHY"}});
	ext:addNPC({id="Sandskin Pincer",tags={"PINCHY"}});
	ext:addNPC({id="Pyreshell Scuttler",tags={"PINCHY"}});
	ext:addNPC({id="%Crab",tags={"PINCHY"}});
	ext:addNPC({id="Spikeshell Scuttler",tags={"PINCHY"}});
	ext:addNPC({id="Sand Scuttler",tags={"PINCHY"}});

	ext:addNPC({id="Coastal Spikeback",tags={"PINCHY"}});
	ext:addNPC({id="Leyscar Scuttler",tags={"PINCHY"}});
	ext:addNPC({id="Derelict Hexapod",tags={"PINCHY", "MEDIUM"}});
	ext:addNPC({id="Dazarian Snapper",tags={"PINCHY", "MEDIUM"}});
	ext:addNPC({id="Hardshell Pincher",tags={"PINCHY", "MEDIUM"}});
	ext:addNPC({id="Hardshell Sand Shifter",tags={"PINCHY", "SMALL"}});
	ext:addNPC({id="Spiny Kelp Clicker",tags={"PINCHY", "MEDIUM"}});
	ext:addNPC({id="Spiny Rock Crab",tags={"PINCHY", "MEDIUM"}});
	
	
	ext:addNPC({id="Feltotem Warmonger",tags={"FELTOTEM"}, gender=2});
	ext:addNPC({id="Feltotem Bloodsinger",tags={"FELTOTEM"}, gender=2});
	ext:addNPC({id="Torok Bloodtotem",tags={"FELTOTEM"}, gender=2});
	
	ext:addNPC({id="%Thistlefur",tags={"FURBOLG"}});
	ext:addNPC({id="%Deadwood",tags={"FURBOLG"}});
	ext:addNPC({id="%Smolderhide",tags={"FURBOLG"}});
	ext:addNPC({id="%Winterfall",tags={"FURBOLG"}});

	ext:addNPC({id="%Harpy",tags={"HARPY"}, gender=3});
	ext:addNPC({id="Witchwood Hag",tags={"HARPY"}, gender=3});
	ext:addNPC({id="%Crawliac",tags={"HARPY"}, gender=3});
	ext:addNPC({id="Ragi the Hexxer",tags={"HARPY"}, gender=3});
	ext:addNPC({id="Agara Deathsong",tags={"HARPY"}, gender=3});
	ext:addNPC({id="Ugla the Hag",tags={"HARPY"}, gender=3});
	ext:addNPC({id="Screeching Hag-Sister",tags={"HARPY"}, gender=3});
	ext:addNPC({id="Screeching Harridan",tags={"HARPY"}, gender=3});
	
	ext:addNPC({id="Jadefire Felsworn",tags={"SATYR"}, gender=2});
	ext:addNPC({id="Jadefire Rogue",tags={"SATYR"}, gender=2});
	ext:addNPC({id="%Satyr",tags={"SATYR"}, gender=2});
	
	ext:addNPC({id="%Bloodpetal",tags={"LASHER", "VINES"}});
	ext:addNPC({id="Bloodpetal Flayer",tags={"LASHER", "VINES"}});
	ext:addNPC({id="Gloomshade Blossom",tags={"LASHER", "VINES"}});
	ext:addNPC({id="Uprooted Lasher",tags={"LASHER", "VINES"}});
	ext:addNPC({id="Corrupted Lasher",tags={"LASHER", "VINES"}});
	ext:addNPC({id="Uprooted Lasher",tags={"LASHER", "VINES"}});
	ext:addNPC({id="Lashvine",tags={"LASHER", "VINES"}});
	ext:addNPC({id="%Lasher",tags={"LASHER"}});
	ext:addNPC({id="Mature Deathblossom",tags={"LASHER"}});
	ext:addNPC({id="Carnivorous Seedling",tags={"LASHER", "MEDIUM"}});
	ext:addNPC({id="Carnivorous Thistlevine",tags={"LASHER", "LARGE"}});
	ext:addNPC({id="Withered Lashling",tags={"LASHER", "LARGE"}});
	

	ext:addNPC({id="Nether Maiden",tags={"SUCCUBUS", "LASHER"}, gender=3});
	ext:addNPC({id="Salia",tags={"SUCCUBUS", "LASHER"}, gender=3});
	ext:addNPC({id="Moora",tags={"SUCCUBUS", "LASHER"}, gender=3});
	ext:addNPC({id="Sister of Grief",tags={"SUCCUBUS", "LASHER"}, gender=3});
	ext:addNPC({id="Mannoroc Lasher",tags={"SUCCUBUS", "LASHER"}, gender=3});

	ext:addNPC({id="%Ooze",tags={"OOZE"}});
	ext:addNPC({id="Shifting Mireglob",tags={"OOZE"}});
	ext:addNPC({id="%Slime",tags={"OOZE"}});
	ext:addNPC({id="%Sludge",tags={"OOZE"}});
	ext:addNPC({id="Fel Secretion",tags={"OOZE"}});
	ext:addNPC({id="Boiling Springbubble",tags={"OOZE"}});
	ext:addNPC({id="Undulating Boneslime",tags={"OOZE"}});
	ext:addNPC({id="Unholy Corpuscle",tags={"OOZE"}});
	
	ext:addNPC({id="Withervine Creeper",tags={"BOG_SHAMBLER"}});
	ext:addNPC({id="Withervine Rager",tags={"BOG_SHAMBLER"}});
	
	ext:addNPC({id="Bloodbough Fungalmancer",tags={"MUSHROOM_MAN", "TENTACLE_STAFF", "MEDIUM"}});
	

	ext:addNPC({id="Hazzali Stinger",tags={"SILITHID", "WASP"}});
	ext:addNPC({id="Gorishi Wasp",tags={"SILITHID", "WASP"}});
	ext:addNPC({id="Centipaar Wasp",tags={"SILITHID", "WASP"}});
	
	ext:addNPC({id="Bonegnasher Skullcrusher",tags={"TROGG", "FISTFIGHTER", "MEDIUM"}});
	ext:addNPC({id="Bonegnasher Earthcaller",tags={"TROGG", "FISTFIGHTER", "MEDIUM"}});
	ext:addNPC({id="Pome Wraith",tags={"SKELETON", "FISTFIGHTER", "MEDIUM"}});
	
	ext:addNPC({id="%Saurolisk",tags={"SAUROLISK"}});
	
	ext:addNPC({id="Bilgewater Hauler",tags={"GOBLIN", "SMALL", "FISTFIGHTER", "HUMANOID"}});
	ext:addNPC({id="Venture Co. Mechanic",tags={"SMALL", "HUMANOID"}});
	ext:addNPC({id="Venture Co. Muscle",tags={"LARGE", "HUMANOID"}});

	ext:addNPC({id="Thistleleaf Ruffian",tags={"FISTFIGHTER", "SMALL"}});
	ext:addNPC({id="Thistleleaf Menace",tags={"FISTFIGHTER", "SMALL"}});
	ext:addNPC({id="Thistleleaf Thorndancer",tags={"FISTFIGHTER", "SMALL"}});
	ext:addNPC({id="Southsea Sailor",tags={"FISTFIGHTER", "MEDIUM"}});
	ext:addNPC({id="Southsea Swabbie",tags={"FISTFIGHTER", "MEDIUM"}});
	ext:addNPC({id="%Undergrell",tags={"FISTFIGHTER", "SMALL"}});
	ext:addNPC({id="Mad Henryk",tags={"FISTFIGHTER", "MEDIUM"}});
	ext:addNPC({id="Pale Gloomstalker",tags={"PALE_ORC", "FISTFIGHTER","MEDIUM"},gender=2});
	ext:addNPC({id="Pale Skinslicer",tags={"PALE_ORC", "FISTFIGHTER","MEDIUM"},gender=2});
	ext:addNPC({id="Pale Tormentor",tags={"PALE_ORC", "FISTFIGHTER","MEDIUM"},gender=2});
	ext:addNPC({id="Pale Tormentor",tags={"PALE_ORC", "FISTFIGHTER","MEDIUM"},gender=2});
	
	ext:addNPC({id="Feathered Viper",tags={"CLOUD_SERPENT","LARGE"}});
	ext:addNPC({id="Feathered Viper Hatchling",tags={"CLOUD_SERPENT","MEDIUM"}});
	

	-- Mogu
	-- Can't have dashes in pattern search, use % to escape
	ext:addNPC({id="%Kao%-Tien",tags={"MOGU"}, gender=2});
	

	-- World containers can also use tags
	

end