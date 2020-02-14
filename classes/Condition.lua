local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local RPText, Character, Tools, Database, Action, Event, Zone, Event, Func;

local Condition = {};
Condition.__index = Condition;


-- Req CLASS --
	-- Ranges are usually 0 = tiny, 1 = small, 2 = average, 3 = large, 4 = huge
	Condition.Types = {
		RTYPE_HAS_PENIS = "has_penis",				-- These explain themselves
		RTYPE_HAS_VAGINA = "has_vagina",
		RTYPE_HAS_BREASTS = "has_breasts",
		RTYPE_PENIS_GREATER = "penis_greater",		-- (int)size :: Penis greater than size.
		RTYPE_BREASTS_GREATER = "breasts_greater",	-- (int)size :: Breasts greater than size.
		RTYPE_BUTT_GREATER = "butt_greater",			-- (int)size :: Butt greater than size.
		RTYPE_RACE = "race",							-- {raceEN=true, raceEn=true...} Table of races that are accepted. Example: {Gnome=true, HighmountainTauren=true}, use UnitRace
		RTYPE_CLASS = "class",							-- {englishClass=true, englishClass=true...} Table of classes that are accepted. Example: {DEATHKNIGHT=true, MONK=true}
		-- RTYPE_SPEC = "spec",							-- {s..specNumber=true, s..specNumber=true...} Table of classes that are accepted. Example: {s0=true}, for priest this would be disc
		RTYPE_TYPE = "type",							-- {typeOne=true, typeTwo=true...} For players this is always "player", otherwise refer to the type of NPC, such as "Humanoid"
		RTYPE_NAME = "name",							-- {nameOne=true, nameTwo=true...} Name of targ. If used with NPCs, consider using a tag instead
		RTYPE_TAG = "tag",								-- {a, or b, or c...}
		RTYPE_RANDOM = "rand",							-- {chance=0-1} 1 = 100%
		RTYPE_HAS_AURA = "aura",						-- {{name=name, caster=casterName}...} Player has one or more of these auras
		RTYPE_HAS_INVENTORY = "inv",					-- {{name=name, quant=min_quant}}
		RTYPE_UNDIES = "undies",						-- false = none, true = req, {name=true, name2=true...} = limit by name
		RTYPE_HAS_ACTION_PET = "pet",					-- Has an active action pet. Sender check only.

		-- The following will only validate from spell based eventData
		RTYPE_CRIT = "crit",						-- Spell was a critical hit
		RTYPE_DETRIMENTAL = "detrimental",			-- Spell was detrimental
		RTYPE_EQUIPMENT = "equipment",				-- {slot=(int)equipmentSlot(http://wowwiki.wikia.com/wiki/InventorySlotId), type="Plate/Mail/Leather/Cloth"}
		RTYPE_EVENT = "event",							-- Event that raised this

		-- These require the container open event
		-- Name of the container opened can be checked with RTYPE_NAME
		RTYPE_CONTAINER_ACTION = "c_action",			-- Action used to open the container, like Opening or Herb Gathering
		RTYPE_SENDER_TALLER = "taller",					-- (bool)much_taller - Don't user sender=true on these. They're automatically checked
		RTYPE_SENDER_SHORTER = "shorter",				-- (bool)much_shorter - The heights go from 0 to 2. So much_taller/shorter would mean a difference of 2
		

		-- These are primarily used for whisper texts
		RTYPE_REQUIRE_MALE = "req_male",			-- Allow male must be checked in settings
		RTYPE_REQUIRE_FEMALE = "req_female",		-- Allow female must be checked in settings
		RTYPE_REQUIRE_OTHER = "req_other",			-- Allow other must be checked in settings

		RTYPE_SELF_ONLY = "self_only",					-- Requires player unit to be target unit.
		RTYPE_SHAPESHIFTED = "not_shapeshifted",		-- Self only. No shapeshift. No transformation toys.
		RTYPE_STEALTH = "stealth",						-- Requires player unit to be stealthed
		RTYPE_PARTY = "party",							-- Player has to be in a party (regardless of settings, use for actions relying on methods only accessible on party members)
		RTYPE_PARTY_RESTRICTED = "party_restricted",	-- Same as above, but can be turned off in settings
		RTYPE_COMBAT = "combat",						-- Require player unit in combat
		RTYPE_DISTANCE = "distance",					-- (obj)distance - Use a const from Character to define the distance
		RTYPE_STUNNED = "stunned",						-- Player unit must be stunned
		RTYPE_MOVING = "moving",						-- Target unit must be moving
		RTYPE_INSTANCE = "instance",					-- Player unit must be in an instance
		RTYPE_DEAD = "dead",							-- Target unit must be dead
		RTYPE_VEHICLE = "vehicle",						-- Target unit must be in a vehicle

		RTYPE_ZONE = "zone",							-- zoneName
		RTYPE_SUBZONE = "subzone",						-- subZoneName
		RTYPE_LOC = "loc",								-- {x = 42.84, y=17.36, rad=0.1}

		RTYPE_ON_QUEST = "on_quest",					-- {quest1, quest2...}
		RTYPE_COMPLETED_QUEST = "completed_quest",		-- {quest1, quest2...}

		RTYPE_FAIL_ON_RECEIVE = "FAIL_RECEIVE",			-- Debug task that always fails on the receiver
	}

	-- Index 1 = noninverted, index 2 = inverted
	Condition.Errors = {
		[Condition.Types.RTYPE_FAIL_ON_RECEIVE] = {
			"Fail on receive.",
			"Fail on receive."
		},
		[Condition.Types.RTYPE_ON_QUEST] = {
			"Target is on a nonallowed quest.",
			"Target is not on the required quest."
		},
		[Condition.Types.RTYPE_COMPLETED_QUEST] = {
			"Target has completed a nonallowed quest.",
			"Target has not completed the required quest."
		},
		[Condition.Types.RTYPE_HAS_PENIS] = {
			"Target has no penis.",
			"Target has a penis."
		},
		[Condition.Types.RTYPE_HAS_VAGINA] = {
			"Target has no vagina.",
			"Target has a vagina."
		},
		[Condition.Types.RTYPE_HAS_BREASTS] = {
			"Target has no breasts.",
			"Target has breasts."
		},
		[Condition.Types.RTYPE_PENIS_GREATER] = {
			"Target genitals too small.",
			"Target genitals too large."
		},
		[Condition.Types.RTYPE_BREASTS_GREATER] = {
			"Target breasts too small.",
			"Target breasts too large."
		},
		[Condition.Types.RTYPE_BUTT_GREATER] = {
			"Target butt too small.",
			"Target butt to small."
		},
		[Condition.Types.RTYPE_RACE] = {
			"Target is not the required race.",
			"Target race incompatible."
		},
		[Condition.Types.RTYPE_CLASS] = {
			"Target is not the required class.",
			"Target race invalid."
		},
		-- [Condition.Types.RTYPE_SPEC] = {
		-- 	"Target is not the required spec.",
		-- 	"Target spec invalid."
		-- },
		[Condition.Types.RTYPE_TYPE] = {
			"Target type invalid.",
			"Target type invalid."
		},
		[Condition.Types.RTYPE_RANDOM] = {
			"Random fail!",
			"Random fail!"
		},
		[Condition.Types.RTYPE_NAME] = {
			"Target name invalid.",
			"Target name invalid."
		},
		[Condition.Types.RTYPE_HAS_AURA] = {
			"Target is missing required aura.",
			"Target is protected."
		},
		[Condition.Types.RTYPE_HAS_INVENTORY] = {
			"Required inventory missing.",
			"Required inventory missing."
		},
		[Condition.Types.RTYPE_UNDIES] = {
			"Target not wearing underwear.",
			"Target is wearing underwear."
		},
		[Condition.Types.RTYPE_CRIT] = {
			"This was not a critical hit.",
			"This was a critical hit."
		},
		[Condition.Types.RTYPE_DETRIMENTAL] = {
			"Spell was not detrimental.",
			"Spell was detrimental."
		},
		[Condition.Types.RTYPE_EQUIPMENT] = {
			"Required equipment missing.",
			"Invalid equipment worn."
		},
		[Condition.Types.RTYPE_EVENT] = {
			"Event invalid.",
			"Event invalid."
		},
		[Condition.Types.RTYPE_REQUIRE_MALE] = {
			"Blocked by male preferences.",
			"Blocked by male preferences."
		},
		[Condition.Types.RTYPE_REQUIRE_FEMALE] = {
			"Blocked by female preferences.",
			"Blocked by female preferences."
		},
		[Condition.Types.RTYPE_REQUIRE_OTHER] = {
			"Blocked by other preferences.",
			"Blocked by other preferences."
		},
		[Condition.Types.RTYPE_SELF_ONLY] = {
			"Invalid target.",
			"Cannot do that to yourself."
		},
		[Condition.Types.RTYPE_STEALTH] = {
			"You are not stealthed.",
			"You are stealthed."
		},
		[Condition.Types.RTYPE_PARTY] = {
			"You are not in a party.",
			"You are in a party."
		},
		[Condition.Types.RTYPE_PARTY_RESTRICTED] = {
			"Blocked due to party restrictions.",
			"Blocked due to party restrictions."
		},
		[Condition.Types.RTYPE_COMBAT] = {
			"You are not in combat.",
			"You are in combat."
		},
		[Condition.Types.RTYPE_DISTANCE] = {
			"Too far away.",
			"Too close."
		},
		[Condition.Types.RTYPE_STUNNED] = {
			"You are not stunned.",
			"You are stunned."
		},
		[Condition.Types.RTYPE_MOVING] = {
			"You are not moving.",
			"You are moving."
		},
		[Condition.Types.RTYPE_INSTANCE] = {
			"You are not in an instance.",
			"You are in an instance."
		},
		[Condition.Types.RTYPE_DEAD] = {
			"You are alive.",
			"You are dead."
		},
		[Condition.Types.RTYPE_VEHICLE] = {
			"You are not in a vehicle.",
			"You are in a vehicle."
		},
		[Condition.Types.RTYPE_LOC] = {
			"You are not in the right spot.",
			"You are not in the right spot."
		},
		[Condition.Types.RTYPE_SUBZONE] = {
			"You are not in the right subzone.",
			"This subzone is not allowed."
		},
		[Condition.Types.RTYPE_ZONE] = {
			"You are not in the right zone.",
			"This zone is not allowed."
		},
		[Condition.Types.RTYPE_TAG] = {
			"Required tag missing.",
			"Blocking tag set."
		},		
		[Condition.Types.RTYPE_SHAPESHIFTED] = {
			"Target not shapeshifted",
			"Target shapeshifted"
		},
		[Condition.Types.RTYPE_HAS_ACTION_PET] = {
			"Pet not found.",
			"Pet not allowed."
		},
		[Condition.Types.RTYPE_SENDER_TALLER] = {
			"Too short",
			"Too tall"
		},
		[Condition.Types.RTYPE_SENDER_SHORTER] = {
			"Too tall",
			"Too short"
		}
	}


	function Condition.ini()
		RPText = require("RPText");
		Character = require("Character");
		Tools = require("Tools");
		Database = require("Database");
		Action = require("Action");
		Event = require("Event");
		Zone = require("Zone");
		Event = require("Event");
		Func = require("Func");
	end

	function Condition:new(data)
		local self = {}
		setmetatable(self, Condition);

		self.id = data.id;
		self.type = data.type or false;									-- RTYPE_*
		self.sender = data.sender or false;								-- Validate against sender							-- 
		self.data = data.data;													-- See RTYPE_*
		self.inverse = data.inverse;											-- Returns false if it DOES validate

		if self.type == false then print("No type definition of condition", self.id) end

		return self
	end

	
	-- If senderChar is empty, it should only validate receiver
	function Condition:validate(senderUnit, receiverUnit, senderChar, receiverChar, eventData, event, action, debug)

		local ty = Condition.Types;
		local t = self.type;
		local targ = receiverChar;
		local targUnit = receiverUnit;
		if self.sender then 
			-- We can disregard sender conditions if
			if 
				not senderChar and 						-- There's no sender char (receiving end of action)
				t ~= ty.RTYPE_PARTY and 				-- This doens't require the player to be in our party (prevents sending party restricted actions)
				t ~= ty.RTYPE_PARTY_RESTRICTED 		-- Same as above
			then
				return true;
			end

			if not senderChar then
				senderChar = Character:new({}, senderUnit);
			end
			targ = senderChar;
			targUnit = senderUnit;
		end

		
		

		local data = self.data;
		local inverse = self.inverse;
		local name = targ:getName();
		
		local ch = ExiWoW.ME;

		local isSelf =
			(senderUnit == nil or receiverUnit == nil) or
			(senderUnit == "player" and UnitIsUnit(receiverUnit, "player")) or
			(receiverUnit == "player" and UnitIsUnit(senderUnit, "player"));
		local targIsMe = UnitIsUnit(targUnit, "player");
		local inParty = isSelf or UnitInRaid(senderUnit) or UnitInParty(senderUnit) or UnitInRaid(receiverUnit) or UnitInRaid(receiverUnit);
		local senderIsMe = UnitIsUnit(senderUnit, "player");

		-- Try to find errors
		local out = false

		if t == ty.RTYPE_FAIL_ON_RECEIVE then
			out = not targIsMe;
		elseif t == ty.RTYPE_HAS_PENIS then
			out = targ:getPenisSize() ~= false;
		elseif t == ty.RTYPE_HAS_VAGINA then 
			out = targ:getVaginaSize() ~= false;
		elseif t == ty.RTYPE_HAS_BREASTS then 
			out = targ:getBreastSize() ~= false;
		elseif t == ty.RTYPE_NAME then
			out = Tools.multiSearch(name, data)
		elseif t == ty.RTYPE_PENIS_GREATER then 
			out = targ:getPenisSize() ~= false and targ:getPenisSize() > data[1];
		elseif t == ty.RTYPE_BREASTS_GREATER then 
			out = targ:getBreastSize() ~= false and targ:getBreastSize() > data[1];
		elseif t == ty.RTYPE_BUTT_GREATER then 
			out = targ:getButtSize() > data[1];
		elseif t == ty.RTYPE_RACE then 
			out = Tools.multiSearch(targ.race, data);
		elseif t == ty.RTYPE_CLASS then 
			out = Tools.multiSearch(targ.class, data);
		-- elseif t == ty.RTYPE_SPEC and targ.spec then
		-- 	out = Tools.multiSearch("s"..targ.spec, data);
		elseif t == ty.RTYPE_TYPE then 
			out = Tools.multiSearch(targ.type, data);
		elseif t == ty.RTYPE_ZONE then
			out = Tools.multiSearch(GetRealZoneText(), data);
		elseif t == ty.RTYPE_SUBZONE then
			out = Tools.multiSearch(GetSubZoneText(), data);
		elseif t == ty.RTYPE_HAS_ACTION_PET then
			out = not senderIsMe or PetHasActionBar();
		elseif t == ty.RTYPE_SENDER_TALLER then
			out = senderChar.height > receiverChar.height  and (not data or senderChar.height-receiverChar.height > 1);
		elseif t == ty.RTYPE_SENDER_SHORTER then
			out = senderChar.height < receiverChar.height and (not data or receiverChar.height-senderChar.height > 1);
		elseif t == ty.RTYPE_LOC then
			local mapID = C_Map.GetBestMapForUnit("player");
			local pos = C_Map.GetPlayerMapPosition(mapID,"player");
			local px,py = pos:GetXY();
			px = px*100; py = py*100;
			local x = data.x;
			local y = data.y;
			local radius = data.rad or 1;
			local dist = math.sqrt((px-x)*(px-x)+(py-y)*(py-y));
			out = dist <= radius;
		elseif t == ty.RTYPE_ON_QUEST then
			out = not targIsme or Quest.isActive(data);
		elseif t == ty.RTYPE_COMPLETED_QUEST then
			out = not targIsme or Quest.isCompleted(data);
		elseif t == ty.RTYPE_CRIT then
			out = type(eventData) == "table" and eventData.crit;
		elseif t == ty.RTYPE_DETRIMENTAL then
			out = type(eventData) == "table" and eventData.harmful;
		elseif t == ty.RTYPE_MELEE then
			out = spelltype == ty.RTYPE_MELEE
		elseif t == ty.RTYPE_SPELL_ADD then
			out = spelltype == ty.RTYPE_SPELL_ADD;
		elseif t == ty.RTYPE_SPELL_REM then
			out = spelltype == ty.RTYPE_SPELL_REM;
		elseif t == ty.RTYPE_SPELL_TICK then
			out = spelltype == ty.RTYPE_SPELL_TICK;
		elseif t == ty.RTYPE_RANDOM then
			out = math.random() < data.chance;
		elseif t == ty.RTYPE_HAS_AURA then
			out = Event.hasAura(data);
		elseif t == ty.RTYPE_HAS_INVENTORY then
			out = not senderIsMe or Character:hasInventory(data);
		elseif t == ty.RTYPE_REQUIRE_MALE then
			out = globalStorage.taunt_male == true
		elseif t == ty.RTYPE_REQUIRE_FEMALE then
			out = globalStorage.taunt_female == true
		elseif t == ty.RTYPE_REQUIRE_OTHER then
			out = globalStorage.taunt_other == true
		elseif t == ty.RTYPE_EVENT then
			out = Tools.multiSearch(event, data)
		elseif t == ty.RTYPE_EQUIPMENT then
			local unit = false
			if targ == ExiWoW.ME then unit = "player" 
			elseif targ == ExiWoW.TARGET then unit = "target"
			end
			-- /dump GetItemInfo(GetInventoryItemID("player", 7))
			-- /dump GetInventoryItemID("target", 7)
			
			if unit then 
				local id = GetInventoryItemID(unit, data.slot)
				if not id then 
					out = false
				else
					local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice =
						GetItemInfo(id);
					out = itemType == "Armor" and (data.type == nil or Tools.multiSearch(itemSubType, data.type))
				end
			end
		elseif t == ty.RTYPE_UNDIES then
			local und = targ:getUnderwear();
			out = 
				(data[1] == false and und == false) or
				(data[1] == true and und ~= false) or
				(type(und) == "table" and data[und.id])
		elseif t == ty.RTYPE_TAG then
			local tags = Tools.concat(
				targ:getTags(),
				Zone.getCurrentTags()
			)
			if type(eventData) == "table" then
				tags = Tools.concat(tags, eventData.tags);
			end 

			tags = Tools.createSet(tags);
			if type(data) == "string" then data = {data} end
			for _,v in pairs(data) do
				out = Tools.multiSearch(v, tags)
				if out then
					break
				end
			end
		elseif t == ty.RTYPE_SELF_ONLY then
			out = isSelf;
		elseif t == ty.RTYPE_STEALTH then
			out = IsStealthed() or (not targIsMe and not senderIsMe);
		elseif t == ty.RTYPE_PARTY then
			out = inParty;
		elseif t == ty.RTYPE_PARTY_RESTRICTED then
			out = inParty or globalStorage.enable_public;
		elseif t == ty.RTYPE_COMBAT then
			out = UnitAffectingCombat(targUnit);
		elseif t == ty.RTYPE_DISTANCE then
			out = (Action.checkRange(senderUnit, data) and Action.checkRange(receiverUnit, data));
		elseif t == ty.RTYPE_STUNNED then
			-- Makes it always return true if target is not me, since only I can check if I am stunned
			if not targIsMe then out = not inverse
			else out = not HasFullControl();		-- Target in condition is checked
			end
		elseif t == ty.RTYPE_MOVING then
			out = GetUnitSpeed(targUnit) > 0;
		elseif t == ty.RTYPE_INSTANCE then	
			out = IsInInstance();
		elseif t == ty.RTYPE_DEAD then
			out = UnitIsDeadOrGhost(targUnit);
		elseif t == ty.RTYPE_VEHICLE then
			out = UnitInVehicle(targUnit);
		elseif t == ty.RTYPE_SHAPESHIFTED then
			if not targIsMe then
				out = not inverse;
			else
				out = Func.get("isShapeshifted")();
			end
		end

		if (Condition.DEBUG or debug) and not out then 
			print("Failed on", t, ExiWoW.json.encode(data));
		end

		if inverse then out = not out end
		return out; 
	end

	-- If suppress is 1, it returns instead
	function Condition:reportError(suppress)
		if suppress == true then return false end
		if not Condition.Errors[self.type] then
			return false, "Unknown error";
		end
		local error = Condition.Errors[self.type][1];
		if self.inverse then
			error = Condition.Errors[self.type][2];
		end
		if suppress == 1 then return false, error.." (Expected: "..ExiWoW.json.encode(self.data)..")" end
		return Tools.reportError(error, ignore);
	end

	function Condition.get(id)
		return Database.getID("Condition", id);
	end

	function Condition.checkSyntax(asset, conditions)
		if type(conditions) ~= "table" then
			conditions = {conditions};
		end
		for i,v in ipairs(conditions) do
			if not v then
				print("Invalid condition found in asset", asset.id, "at index", i)
			end
		end
	end

	-- Validate all conditions
	function Condition.all(conditions, senderUnit, receiverUnit, senderChar, receiverChar, eventData, event, action, debug)

		local function validateThese(input, noOr)

			for k,v in pairs(input) do

				local failOutput = v;

				-- Validate a sub
				local success = true
				if v[1] ~= nil then 
					success, failOutput = validateThese(v)	-- We must go deeper
				else
					if not v or type(v.validate) ~= "function" then
						print("Invalid condition in ", self.text_receiver);
					end
					success = v:validate(senderUnit, receiverUnit, senderChar, receiverChar, eventData, event, action, debug) -- This entry was a condition
				end

				if success and not noOr then 
					return true
				elseif not success and noOr then
					return false, failOutput
				end
			end

			if not noOr then return false, input[1] end
			return true

		end

		local success, cond = validateThese(conditions, true);
		return success, cond;
	end

export(
	"Condition", 
	Condition
)
