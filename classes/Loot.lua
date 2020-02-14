local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local RPText, Character, Tools, Database, Action, Event, Condition;

local Loot = {};
Loot.__index = Loot;

	function Loot.ini()
		RPText = require("RPText");
		Character = require("Character");
		Tools = require("Tools");
		Database = require("Database");
		Action = require("Action");
		Event = require("Event");
		Condition = require("Condition");
	end

	function Loot:new(data)
		local self = {}
		setmetatable(self, Loot);

		self.id = data.id;			-- Optinal, used for debugging
		self.conditions = data.conditions or {};
		self.items = data.items;

		for _,v in pairs(self.conditions) do
			if type(v) ~= "table" then
				print("Invalid condition detected in loot");
				print(debugstack())
			end
		end

		return self
	end


	Loot.Item = {};
	Loot.Item.__index = Loot.Item;
	function Loot.Item:new(data)
		local self = {}
		setmetatable(self, Loot);

		self.id = data.id;							-- ID of action or underwear
		self.type = data.type or "Charges";			-- Charges or Underwear
		self.text = data.text;						-- RPText object output when you find this
		self.chance = data.chance or 1;				-- Chance between 0 and 1
		self.quant = data.quant or 1;				-- Nr charges
		self.quantRand = data.quantRand or 0;		-- Nr of random items to add onto quant
		self.sound = data.sound;					-- Sound to play when looted

		return self

	end

	-- Filters loot by conditions
	function Loot.filter(...)
		local all = Database.filter("Loot");
		out = {};
		for _,v in pairs(all) do
			local validate, cond = Condition.all(v.conditions, ...);
			if validate then
				table.insert(out, v);
			else
				--print("Failed at ", cond:reportError(false,true))
			end
		end
		return out;
	end

	-- A little bit different to the others in that it returns only the function, not the Func object
	function Loot.get(id)
		return Database.getID("Loot", id);
	end

export(
	"Loot", 
	Loot,
	{
		get = Loot.get,
		new = Loot.new,
		Item = Loot.Item,
		filter = Loot.filter
	},
	{
		
	}
)