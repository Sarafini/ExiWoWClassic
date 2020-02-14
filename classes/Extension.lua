local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;


Extension = {}
Extension.LIB = {}
Extension.__index = Extension;

local RPText, Action, Effect, Underwear, Database, Func, NPC, Zone, Spell, Loot, Visual;


	function Extension:ini()
		Database = require("Database");
		RPText = require("RPText");
		Action = require("Action");
		Effect = require("Effect");
		Underwear = require("Underwear");
		Condition = require("Condition");
		Func = require("Func");
		NPC = require("NPC");
		Zone = require("Zone");
		Spell = require("Spell");
		Loot = require("Loot");
		Quest = require("Quest");
		Visual = require("Visual");

	end

	function Extension:new(data, isRoot)
		local self = {}
		setmetatable(self, Extension); 
		if type(data) ~= "table" or type(data.id) ~= "string" or (data.id == "ROOT" and not isRoot) then
			print("Unable to import extension, data or id missing")
			return false;
		end

		local function importTable(t)
			if type(t) ~= "table" then return {} end
			return t
		end

		self.id = data.id

		-- Import RP
		self.rpTexts = importTable(data.rpTexts)

		-- Import actions
		self.actions = importTable(data.actions)

		-- Effects
		self.effects = importTable(data.effects)

		-- Underwear
		self.underwear = importTable(data.underwear)

		-- Conditions
		self.conditions = importTable(data.conditions);

		-- Loot
		self.loot = importTable(data.loot);

		-- NPCs
		self.npcs = importTable(data.npcs);

		-- Zones
		self.zones = importTable(data.zones);

		-- Spells
		self.spells = importTable(data.spells);

		-- Functions
		self.functions = importTable(data.functions);

		-- Quests
		self.quests = importTable(data.quests);

		-- Visuals
		self.visuals = importTable(data.visuals);

		return self
	end

	-- Exports to a JSON string for the user
	function Extension:export()
		if self.id == nil then return false end
		-- Todo:export
	end

	-- These functions lets you add by generic objects
	function Extension:addRpText(data)
		table.insert(self.rpTexts, RPText:new(data))
	end
	Extension.addRPText = Extension.addRpText;

	function Extension:addAction(data)
		table.insert(self.actions, Action:new(data));
	end

	function Extension:addEffect(data)
		table.insert(self.effects, Effect:new(data))
	end
	function Extension:addUnderwear(data)
		table.insert(self.underwear, Underwear:new(data))
	end
	function Extension:addCondition(data)
		table.insert(self.conditions, Condition:new(data))
	end
	function Extension:addFunction(data)
		table.insert(self.functions, Func:new(data));
	end
	function Extension:addNPC(data)
		table.insert(self.npcs, NPC:new(data));
	end
	function Extension:addSpell(data)
		table.insert(self.spells, Spell:new(data));
	end
	function Extension:addZone(data)
		table.insert(self.zones, Zone:new(data));
	end
	function Extension:addLoot(data)
		table.insert(self.loot, Loot:new(data));
	end
	function Extension:addQuest(data)
		table.insert(self.quests, Quest:new(data));
	end
	function Extension:addVisual(data)
		table.insert(self.visuals, Visual:new(data));
	end


	-- STATIC --

	-- Updates asset indexes --
	function Extension.index()

		-- Reset libraries	
		Database.clearTables("RPText", "Action", "Effect", "Underwear", "Condition", "Func", "NPC", "Spell", "Zone", "Loot", "Quest");

		for k,v in pairs(Extension.LIB) do
			Database.add("RPText", v.rpTexts);
			Database.add("Action", v.actions);
			Database.add("Effect", v.effects);
			Database.add("Underwear", v.underwear);
			Database.add("Condition", v.conditions);
			Database.add("Func", v.functions);
			Database.add("NPC", v.npcs);
			Database.add("Spell", v.spells);
			Database.add("Zone", v.zones);
			Database.add("Loot", v.loot);
			Database.add("Quest", v.quests);
			Database.add("Visual", v.visuals);
		end
		

		local UI = require("UI")
		local Action = require("Action")

		-- Update the HUD
		Action.sort()
		UI.underwearPage.update()
		UI.actionPage.update()
		

	end

	function Extension.exportAll()
		local out = {}
		for k,v in pairs(Extension.LIB) do
			local exp = v:export()
			if exp then 
				table.insert(out, exp)
			end
		end
	end


	function Extension.import(data, isRoot)
		local ex = Extension:new(data, isRoot);
		if ex then
			Extension.LIB[ex.id] = ex
			Extension.index()
			if ex.id ~= "ROOT" then
				print("-- Using: ", ex.id)
			end
			if ExiWoW.loaded then ExiWoW.Menu:refreshAll(); end
			return ex
		end
	end

	-- Import from text --
	function Extension.importFromText(text)
		-- Todo: Figure out a way to import with custom functions
	end

	function Extension.remove(id)
		Extension.LIB[id] = nil
		Extension.index();
	end



export("Extension", Extension,
	{
		import = Extension.import
	},
	{
		index = Extension.index,
		remove = Extension.remove
	}
)
