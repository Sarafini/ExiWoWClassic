local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local RPText, Character, Tools, Database, Action, Event;


local NPC = {};
NPC.__index = NPC;

	function NPC.ini()
		RPText = require("RPText");
		Character = require("Character");
		Tools = require("Tools");
		Database = require("Database");
		Action = require("Action");
		Event = require("Event");
	end

	function NPC:new(data)
		local self = {}
		setmetatable(self, NPC);
		
		self.id = data.id;			-- Id is the name of the NPC, can contain % or a table
		self.gender = data.gender;			-- Can be used to force a gender on npcs that don't have genders
		self.tags = type(data.tags) == "table" and data.tags or {};						-- Text tags of your choosing

		if not self.id then print("NPC inserted without an ID"); end
		
		return self
	end

	function NPC:getTags()
		local out = {};
		for _,v in pairs(self.tags) do
			table.insert(out, "NPC_"..v);
		end
		return out;
	end

	-- A little bit different to the others in that it returns only the function, not the Func object
	function NPC.get(id)
		return Database.getID("NPC", id);
	end

export(
	"NPC", 
	NPC,
	{
		get = NPC.get,
		new = NPC.new,
		createCharacter = NPC.createCharacter
	},
	{}
)