local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local RPText, Character, Tools, Database, Action, Event;

local Zone = {};
Zone.__index = Zone;

	function Zone.ini()
		RPText = require("RPText");
		Character = require("Character");
		Tools = require("Tools");
		Database = require("Database");
		Action = require("Action");
		Event = require("Event");
	end

	function Zone:new(data)
		local self = {}
		setmetatable(self, Zone);

		self.id = data.id;			-- Id should be a name
		self.sub_of = data.sub_of;														-- Set a string here of a parent zone ID
		self.tags = type(data.tags) == "table" and data.tags or {};					-- Text tags of your choosing

		if not self.id then print("Invalid ID found for a zone"); end
		return self
	end

	-- Returns subs of zone this is called through
	function Zone:getSubs()
		local all = Database.filter("Zone");
		local out = {};
		for k,v in pairs(all) do
			if v.sub_of == self.id then
				table.insert(out, v);
			end
		end
		return out;
	end

	-- Gets a single subzone by name
	function Zone:getSub(name)
		local all = self:getSubs();
		for k,v in pairs(all) do
			if v.id == name then
				return v;
			end
		end
	end

	function Zone:getTags()
		local out = {};
		for _,v in pairs(self.tags) do
			table.insert(out, "ZONE_"..v);
		end
		return out;
	end

	-- A little bit different to the others in that it returns only the function, not the Func object
	function Zone.get(id)
		return Database.getID("Zone", id);
	end

	-- Returns tags of active zone
	function Zone.getCurrentTags()
		local zone = Zone.get(GetRealZoneText());
		local out = {};
		if not zone then return out end
		out = Tools.concat(out, zone:getTags());
		local sub = zone:getSub(GetSubZoneText());
		if not sub then return out end
		out = Tools.concat(out, sub:getTags());
		return out;
	end


export(
	"Zone", 
	Zone,
	{
		get = Zone.get,
		new = Zone.new,
		getCurrentTags = Zone.getCurrentTags,
		getTags = Zone.getTags
	},
	{}
)