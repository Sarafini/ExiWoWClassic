local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local RPText, Character, Tools, Database, Action, Event;

local Func = {};
Func.__index = Func;

	function Func.ini()
		RPText = require("RPText");
		Character = require("Character");
		Tools = require("Tools");
		Database = require("Database");
		Action = require("Action");
		Event = require("Event");
	end

	function Func:new(data)
		local self = {}
		setmetatable(self, Func);

		self.id = data.id;
		self.fn = data.fn;									
		
		if not self.id then 
			print("Error, a function is missing ID"); 
			print(debugstack());
		end
		if not self.fn then print("Error, a function is missing function data:", self.id); end
		
		return self
	end

	-- A little bit different to the others in that it returns only the function, not the Func object
	function Func.get(id)
		local fn = Database.getID("Func", id);
		if not fn then print("Attempt to call nonexistent function", id); return end
		return fn.fn;
	end

export(
	"Func", 
	Func,
	{
		get = Func.get,
		new = Func.new
	},
	{}
)