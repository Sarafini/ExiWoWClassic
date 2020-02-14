local appName, internal = ...;
local export = internal.Module.export;
local require = internal.require;

local Database, Effect, Event, Timer;

local Underwear = {}
	Underwear.__index = Underwear;

	function Underwear.ini()
		Database = require("Database");
		Effect = require("Effect");
		Event = require("Event");
		Timer = require("Timer");
	end

	-- RPText CLASS
	function Underwear:new(data)
		local self = {}
		setmetatable(self, Underwear);
		
		self.id = data.id or "";							--
		self.name = data.name or "???"
		self.icon = data.icon or "Inv_misc_questionmark"
		self.rarity = type(data.rarity) == "number" and data.rarity or 2
		if self.rarity < 1 then self.rarity = 1
		elseif self.rarity > 7 then self.rarity = 7
		end

		self.description = data.description or "???";
		self.tags = data.tags or {};
		self.color = data.color or false;
		self.equip_sound = data.equip_sound or 1202;
		self.unequip_sound = data.equip_sound or 1185;
		self.flavor = data.flavor or false;

		self.on_equip = data.on_equip;
		self.on_unequip = data.on_unequip;

		-- Allows you to tie passive effects to underwear
		-- Contains effect IDs
		self.effects = type(data.effects) == "table" and data.effects or {}
		self.binds = {};
		self.timers = {};

		return self
	end

	function Underwear:onEquip()
		self:unbindAll();
		if type(self.on_equip) == "function" then
			self:on_equip();
		end
		for _,v in pairs(self.effects) do
			local effect = Effect.get(v)
			if effect then
				effect:add(1)
			end
		end
	end

	function Underwear:onUnequip()
		self:unbindAll();
		for _,v in pairs(self.effects) do
			Effect.remByID(v)
		end
		for k,_ in pairs(self.timers) do
			self:clearTimer(k);
		end
		if type(self.on_unequip) == "function" then
			self:on_unequip();
		end
	end

	-- Lets you bind events, these will be automatically wiped when the underwear is removed
	function Underwear:bind(event, fn, data, max_triggers)
		local bind = Event.on(event, fn, data, max_triggers);
		table.insert(self.binds, bind);
		return bind;
	end

	function Underwear:setTimer(id, fn, time, repeats)
		self:clearTimer(id);
		self.timers[id] = Timer.set(fn, time, repeats);
	end
	function Underwear:clearTimer(id)
		if self.timers[id] then
			Timer.clear(self.timers[id]);
			self.timers[id] = nil;
		end
	end

	function Underwear:unbindAll()
		for _,bind in pairs(self.binds) do
			Event.off(bind);
		end
		self.binds = {};
	end

		-- TOOLTIP HANDLING --
	function Underwear:onTooltip(frame)

		if frame then

			local v = self
			local rarity = self.rarity-1
			if rarity < 1 then rarity = 1 end
			local color = ITEM_QUALITY_COLORS[rarity]

			GameTooltip:SetOwner(frame, "ANCHOR_CURSOR");
			GameTooltip:ClearLines();
			GameTooltip:AddLine(self.name, color.r, color.g, color.b);
			GameTooltip:AddLine(self.description, 0.9, 0.9, 0.9, true);
			if self.flavor then
				GameTooltip:AddLine("\""..self.flavor.."\"", 1, 0.82, 0.043, true)
			end
			GameTooltip:Show()

		else

			GameTooltip:Hide();

		end


	end

	function Underwear:export()
		return {
			id = self.id,
			na = self.name,
			co = self.color
		}
	end


	-- Static

	function Underwear.import(data)
		return Underwear:new({
			name = data.na,
			color = data.co,
			id = data.id
		});
	end

	function Underwear.get(id)
		local lib = Database.filter("Underwear");
		for _,uw in pairs(lib) do
			if uw.id == id then return uw end
		end
		return false
	end


export(
	"Underwear", 
	Underwear
)
