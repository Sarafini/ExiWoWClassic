local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;
local Condition, Database, Tools, Index, Timer, Effect, Func;

local RPText = {};
RPText.__index = RPText;
RPText.DEBUG = false
RPText.takehitCD = nil			-- Cooldown for takehit texts
RPText.whisperCD = nil

	function RPText.ini()
		Condition = require("Condition");
		Database = require("Database");
		Tools = require("Tools");
		Index = require("Index");
		Timer = require("Timer");
		Effect = require("Effect");
		Func = require("Func");
	end

	function RPText.getTakehitCD() return RPText.takehitCD end
	function RPText.getWhisperCD() return RPText.whisperCD end

	-- The syntax of these are %S<type> for sender %T<type> for receiver. If no extra type is specified, it gets name
	local TAG_SENDER_NAME = "%S";
	local TAG_RECEIVER_NAME = "%T";
	local TAG_SUFFIXES = {
		GROIN = "groin",
		GENITALS = "genitals",		-- Automatically picks one based on your gender
		PENIS = "penis",
		VAGINA = "vagina",
		BREASTS = "breasts",
		BREAST = "breast",			-- Singular version
		BUTT = "butt",
		BUTTCHEEK = "buttcheek", 	-- Singular version
		RACETAG = "rtag",			-- Fuzzy for worgen and pandas, automatically included in breast(s), butt(cheek)
		RACE = "race",
		CLASS = "class",
		UNDERWEAR = "undies",		-- Underwear name
		BULGE = "bulge",			-- Bulge, package, junk etc
		-- These are converted into somewhat applicable pronouns, him->her->their etc 
		HIM = "him",
		HIS = "his",
		HE = "he",
	}
	-- Prevents issues, longer ones should be first
	local TAG_SUFFIX_ORDER = {}
	for k,v in pairs(TAG_SUFFIXES) do
		table.insert(TAG_SUFFIX_ORDER, v)
	end
	table.sort(TAG_SUFFIX_ORDER, function(a,b)
		if string.len(a) > string.len(b) then return true end
		return false
	end)

	-- These are generic tags you can use
	local TAG_GENERIC = {
		LEFTRIGHT = "leftright",			-- Returns left or right
		HARDEN = "harden",					-- Synonym for harden
		-- Only available from spells
		SPELL = "spell",					-- Name of spell that was cast
		-- Only available with an item condition
		ITEM = "item",						-- Name of last item validated with the condition
	}

	-- RPText CLASS
	function RPText:new(data)
		local self = {}
		setmetatable(self, RPText);

		self.id = data.id or "";			-- Generally matches an Action ID. Gets converted into a table with {id = true}. If "" then it's a wildcard, and only conditions are checked
		self.text_sender = data.text_sender or false; 		-- RP Text
		self.text_receiver = data.text_receiver or ""; 		-- RP Text
		self.text_bystander = data.text_bystander or false;	-- RP Text for bystanders
		self.requirements = type(data.requirements) == "table" and data.requirements or {};
		self.sound = data.sound;					-- Play this sound when sending or receiving this. Can also be a table of many sounds
		self.fn = data.fn or nil;					-- Only supported for NPC/Spell events. Actions should use the action system instead
		self.is_chat = data.is_chat or false		-- Makes the RP text display with chat colors instead. Set text_bystander to any non-false value to make it a say. Otherwise it's a whisper
		self.visual = data.visual;					-- Triggers a visual from the visuals library
		self.allow_shapeshift = false;				-- Toggle to disallow shapeshifts
		self.custom = data.custom;					-- Lets you put custom data on this text

		-- Automatic
		self.item = ""								-- Populated automatically when you use an item condition, contains the last valid item name

		if type(self.id) ~= "table" and self.id ~= "" then
			local id = {};
			id[self.id] = true;
			self.id = id;
		end
		Condition.checkSyntax(self, self.requirements);

		return self
	end

	-- Conditions are auto prepended here
	function RPText:validate(...)

		if not self.allow_shapeshift and Func.get("isShapeshifted")() then
			return false;
		end
		--conditions, senderUnit, receiverUnit, senderChar, receiverChar, eventData, event, action, debug
		return Condition.all(self.requirements, ...);
	end

	function RPText.convert(text, sender, receiver, spelldata, item)

		-- Do the suffixes
		for k,v in pairs(TAG_SUFFIX_ORDER) do
			text = string.gsub(text, "%%S"..v, RPText.getSynonym(v, sender, spelldata))
			text = string.gsub(text, "%%T"..v, RPText.getSynonym(v, receiver, spelldata))
		end

		if item then 
			text = string.gsub(text, "%%"..TAG_GENERIC.ITEM, item)
		end

		for k,v in pairs(TAG_GENERIC) do
			text = string.gsub(text, "%%"..v, RPText.getSynonym(v, receiver, spelldata))
		end
		
		

		-- Default names must go last because they're subsets
		text = string.gsub(text, "%%S", sender:getName())
		text = string.gsub(text, "%%T", receiver:getName())

		return text;

	end

	-- Converts and outputs text_receiver and audio, as well as triggering fn if applicable
	function RPText:convertAndReceive(sender, receiver, noSound, spell, customFunction)

		local text = self.text_receiver;
		if customFunction then 
			text = customFunction(text) 
		end
		local text = RPText.convert(text, sender, receiver, spell, self.item);

		local bystander = self.text_bystander
		if not self.is_chat then
			RPText.print(text)
		else
			RPText.npcSpeak(text, nil, self.text_bystander == false);
			if self.text_bystander ~= false then
				bystander = self.text_receiver
			end
		end

		
		if bystander then
			Index.sendBystanderText(
				RPText.convert(bystander, sender, receiver, spell, self.item),
				self.is_chat,
				sender:getName()
			);
		end

		if type(self.fn) == "function" then
			self:fn(sender, receiver);
		end

		if type(self.visual) == "string" then
			Effect.triggerVisual(self.visual);
		end

		if self.sound and not noSound then
			local sounds = self.sound;
			if type(sounds) ~= "table" then
				sounds = {sounds};
			end
			for _,sound in pairs(sounds) do
				if type(sound) == "number" then
					PlaySound(sound, "SFX");
				else
					PlaySoundFile(sound, "SFX");
				end
			end
		end

	end



	-- STATIC
	-- Returns an RPText object
	function RPText.get(id, senderUnit, receiverUnit, senderChar, receiverChar, eventData, event, action, debug)

		local viable = {};
		if not senderUnit then
			return false;
		end
		senderUnit = Ambiguate(senderUnit, "all");
		local isSelfCast = UnitIsUnit(senderUnit, receiverUnit);		
		local lib = Database.filter("RPText");

		for k,v in pairs(lib) do

			if v.id == "" or Tools.multiSearch(id, v.id) then
				
				local valid = v:validate(senderUnit, receiverUnit, senderChar, receiverChar, eventData, event, action, debug);
				if 
					valid and 
					(
						-- This is a self cast and there's no sender text, allow it
						(not v.text_sender and isSelfCast) or
						-- Not a self cast and there's a text_sender or the sender is not a player
						((v.text_sender or not UnitIsPlayer(senderUnit)) and not isSelfCast)	-- NPC spell and hits don't have a sender text
						--((v.text_sender or senderUnit.type ~= "player") and not isSelfCast) -- NPC spells don't have text_sender, so they need to be put here
					)
				then
					table.insert(viable, v)
				end

			end
			

		end

		-- Pick a random element
		if next(viable) == nil then
			return false;
		end

		item = viable[math.random( #viable )]
		return item;

	end

	function RPText.buildSpellData(spellID, spellName, harmful, casterName, count, crit, tags)
		return {
			spellID = spellID or 0,
			spellName = spellName or "",
			harmful = harmful or false,
			casterName = casterName or "",
			count = count or 0,
			crit = crit or false,
			tags = tags
		};
	end

	-- Same as above but triggers as well
	--senderUnit, receiverUnit, senderChar, receiverChar, eventData, event, action
	function RPText.trigger(id, senderUnit, receiverUnit, senderChar, receiverChar, eventData, event, action, debug)
		local text = RPText.get(id, senderUnit, receiverUnit, senderChar, receiverChar, eventData, event, action, debug)
		if text then 
			--sender, receiver, noSound, spell, customFunction
			text:convertAndReceive(senderChar, receiverChar, false, eventData) 
			return text
		end
		return false
	end

	function RPText.setTakehitTimer()
		local rate = globalStorage.takehit_rp_rate;
		Timer.clear(RPText.takehitCD);
		RPText.takehitCD = Timer.set(function()
			RPText.takehitCD = nil;
		end, rate)
	end

	function RPText.getSynonym(tag, target, spelldata)

		local getSizeTag = function(size)

			if type(size) ~= "number" then 
				return "" 
			end

			local tags = {"huge", "enormous", "giant"};
			if size < 1 then 
				tags = {"tiny", "miniscule", "puny"}
			elseif size < 2 then 
				tags = {"modestly sized", "smallish", "undersized"} 
			elseif size < 3 then 
				tags = {}
			elseif size < 4 then 
				tags = {"large", "big", "sizeable"}
			end

			if next(tags) == nil or math.random() < 0.5 then 
				return "" 
			end	
			
			return tags[math.random(#tags)].." "
			
		end

		local function getRaceTag()
			if math.random() < 0.5 then return "" end
			local tags = {}
			if string.lower(target.race) == "worgen" or string.lower(target.race) == "pandaren" then
				tags = {"fuzzy", "furry"}
			end
			if next(tags) ~= nil then
				return tags[math.random(#tags)].." "
			end
			return "";
		end

		local getRandom = function(...)
			local input = {...}
			return input[math.random(#input)]
		end

		local name = "";
		if target then name = target:getName(); end
		
		-- Generic tags
		if tag == TAG_GENERIC.LEFTRIGHT then
			if math.random() < 0.5 then return "left" end
			return "right"
		elseif tag == TAG_GENERIC.SPELL then
			if type(spelldata) == "table" and spelldata.spellName then 
				return spelldata.spellName 
			end
			return "spell"
		elseif tag == TAG_GENERIC.HARDEN then
			return getRandom("harden", "stiffen")
		end

		if tag == TAG_SUFFIXES.GENITALS then
			tag = TAG_SUFFIXES.GROIN		-- Default to groin
			local r = {}
			if target:getVaginaSize() ~= false then table.insert(r, TAG_SUFFIXES.VAGINA) end
			if target:getPenisSize() ~= false then table.insert(r, TAG_SUFFIXES.PENIS) end
			if #r > 0 then
				tag = r[math.random(#r)]
			end
		end

		-- Specific tags
		if tag == TAG_SUFFIXES.PENIS then
			return getSizeTag(target:getPenisSize())..getRandom("penis", "dick", "member", "cock", "manhood")
		elseif tag == TAG_SUFFIXES.GROIN then
			return getRandom("groin", "crotch")
		elseif tag == TAG_SUFFIXES.BULGE then
			return getRandom("bulge", "package", "junk")
		elseif tag == TAG_SUFFIXES.VAGINA then
			return getRandom("vagina", "pussy", "cunt", "quim")
		elseif tag == TAG_SUFFIXES.BREASTS then
			local out = getSizeTag(target:getBreastSize())..getRaceTag()..getRandom("boobs", "tits", "breasts", "knockers");
			return out
		elseif tag == TAG_SUFFIXES.RACETAG then
			return getRaceTag()
		elseif tag == TAG_SUFFIXES.BUTT then
			return getSizeTag(target:getButtSize())..getRandom("butt", "rear", "rump", "backside", "bottom", "ass")
		elseif tag == TAG_SUFFIXES.BREAST then
			return getSizeTag(target:getBreastSize())..getRandom("boob", "tit", "breast")
		elseif tag == TAG_SUFFIXES.BUTTCHEEK then
			return getSizeTag(target:getButtSize())..getRandom("buttcheek", "asscheek", "glute")
		elseif tag == TAG_SUFFIXES.RACE then
			return string.lower(target.race)
		elseif tag == TAG_SUFFIXES.CLASS then
			return string.lower(target.class)
		elseif tag == TAG_SUFFIXES.HIM then
			if target:isMale() then return "him"
			elseif target:isFemale() then return "her"
			else return "them"
			end
		elseif tag == TAG_SUFFIXES.HIS then
			if target:isMale() then return "his" 
			elseif target:isFemale() then return "her"
			else return "their"
			end
		elseif tag == TAG_SUFFIXES.UNDERWEAR then
			local und = target:getUnderwear();
			if not und then return "underwear" end
			local out = ""
			if math.random() < 0.5 and und.color then out = out..und.color.." "; end
			out = out..string.lower(und.name);
			return out
		elseif tag == TAG_SUFFIXES.HE then
			if target:isMale() then return "he" 
			elseif target:isFemale() then return "she"
			else return "they"
			end
		end

		return "";

	end

	function RPText.print(text, ignoreChat)
		-- 0.95686274509,0.49019607843,0.25490196078
		if not ignoreChat then
			ChatFrame1:AddMessage(text, 0.737, 0.6, 0.980);
		end
		--f47d41
		UIErrorsFrame:AddMessage(text, 1, 0.8, 1, 53, 6);
	end

	function RPText.bystander(text)
		-- 0.95686274509,0.49019607843,0.25490196078
		ChatFrame1:AddMessage(text, 0.835, 0.772, 0.686);
	end

	-- You can either do (sender,text) or (text)
	function RPText.npcSpeak(sender, text, isWhisper)
		if text then
			sender = sender.." says: "..text;
		end	
		local color = {0.95294117647, 0.94901960784, 0.59607843137}
		if isWhisper then
			color = {1.0,0.49,1.0}
		end
		ChatFrame1:AddMessage(sender, color[1], color[2], color[3]);
		UIErrorsFrame:AddMessage(sender, color[1], color[2], color[3], 53, 6);
	end



export(
	"RPText", 
	RPText
)
