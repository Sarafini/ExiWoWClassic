-- NPC Libraries (Don't forget to make NPC Name conditions out of these)
local appName, internal = ...;
local require = internal.require;

function internal.build.zones()

	local Spell = require("Spell");
	local Database = require("Database");
	local Condition = require("Condition");
	local ext = internal.ext;
	
	ext:addZone({id="Durotar", tags={"SANDY"}});
	ext:addZone({id="Burning Steppes", tags={"SANDY"}});
	ext:addZone({id="Tanaris", tags={"SANDY"}});
	ext:addZone({id="Westfall", tags={"SANDY"}});
	ext:addZone({id="Barrens", tags={"SANDY"}});
	ext:addZone({id="Stonetalon Mountains", tags={"SANDY"}});
	ext:addZone({id="Thousand Needles", tags={"SANDY"}});
	ext:addZone({id="Desolace", tags={"SANDY"}});
	ext:addZone({id="Searing Gorge", tags={"SANDY"}});
	ext:addZone({id="Badlands", tags={"SANDY"}});
	ext:addZone({id="Blasted Lands", tags={"SANDY"}});
	ext:addZone({id="Deadwind Pass", tags={"SANDY"}});
	ext:addZone({id="Hellfire Peninsula", tags={"SANDY"}});
	ext:addZone({id="Blade's Edge Mountains", tags={"SANDY"}});
	ext:addZone({id="Netherstorm", tags={"SANDY"}});
	ext:addZone({id="Shadowmoon Valley", tags={"SANDY"}});
	ext:addZone({id="Vol'Dun", tags={"SANDY"}});

	ext:addZone({id="Felwood", tags={"MUSHROOMS"}});
	ext:addZone({id="Eastern Plaguelands", tags={"MUSHROOMS"}});
	ext:addZone({id="Western Plaguelands", tags={"MUSHROOMS"}});


	ext:addZone({id="Nazmir", tags={"MUSHROOMS","SWAMP"}});
	ext:addZone({id="Zangarmarsh", tags={"MUSHROOMS","SWAMP"}});
	ext:addZone({id="Swamp of Sorrows", tags={"SWAMP"}});
	ext:addZone({id="Dustwallow Marsh", tags={"SWAMP"}});
	ext:addZone({id="Wetlands", tags={"SWAMP"}});


end