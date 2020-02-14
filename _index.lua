local appName, internal = ...
local require = internal.require;
local export = internal.Module.export;
internal.build = {}							-- Collection of libraries to build
internal.ext = nil							-- Root extension
local Tools = require("Tools")
local Action, Extension, Character, UI, Effect, Timer, Event, Callback, Database, Quest, RPText;


UIParentLoadAddOn("Blizzard_DebugTools");

-- Create base tables that can be accessed immediately without needing to use an extension
--[[
	/console scriptErrors 1
	/run ExiWoW.UI.drawLoot("Test", "inv_pants_leather_04")

]]
ExiWoW = {};
ExiWoW.require = internal.Module.require;
ExiWoW.initialized = false
ExiWoW.LibAssets = {}			-- Reusable thingie library

-- Targets
ExiWoW.ME = nil					-- My character
ExiWoW.TARGET = nil				-- Target character, do not use in actions
ExiWoW.CAST_TARGET = nil		-- Cast target character, use this in actions
ExiWoW.loaded = false;


-- Globalstorage and localstorage are persistent variables
--globalStorage = nil
-- GlobalStorage defaults
local GLOBALSTORAGE_DEFAULTS = {
	swing_text_freq = 0.15,		-- Percent chance of a swing triggering a special text. Crits are 4x this value
	spell_text_freq = 1,		-- Percent chance of spell damage triggering a special text
	takehit_rp_rate = 6,			-- RP texts from being hit by spells and abilities can only trigger this often
	enable_in_dungeons = false,
	enable_public = false,
	tank_mode = false,			-- Tank mode grants a chance for normal texts to trigger a critical, since tanks can't be critically hit
	taunt_freq = 0.1,			-- Chance of a horny npc taunt when they damage you.
	taunt_rp_rate = 30,			-- Time between horny npc taunts
	taunt_female = true,		-- I want to be hit on by females 
	taunt_male = true,			-- I want to be hit on by males
	taunt_other = true,			-- I want to be hit on by other
	tank_mode_perc = 0.05,		-- Tank mode text trigger percentage
};

--localStorage = nil
-- LocalStorage defaults
local LOCALSTORAGE_DEFAULTS = {
	penis_size = false,
	vagina_size = false,
	breast_size = false,
	butt_size = 2,
	masochism = 0.25,			-- Value between 0 and 1
	abilities = {},
	excitement = 0,
	underwear_ids = {{id="DEFAULT",fav=false}},
	underwear_worn = "DEFAULT",
	muscle_tone = 5,
	intelligence = 5,
	fat = 5,
	wisdom = 5,
	effects = {},
	quests = {},		-- See Quest.lua
};


-- ExiWoW global functions
	-- Returns a full sound path
	function ExiWoW.getSound(name)
		return "Interface\\Addons\\ExiWoW\\media\\sfx\\"..name..".ogg";
	end





	-- Static class definition for INDEX
local Index = {}
	Index["INPUT_BUFFER"] = {};				-- cbid = {parts:[part1,part2...], timeout:(int)timer}
	Index["FRAME"] = CreateFrame("Frame");
		
	-- Event bindings go here, since the script starts on a loaded event
	function Index.ini()
		-- Register main frame
		Index.FRAME:RegisterEvent("ADDON_LOADED");
		Index.FRAME:RegisterEvent("PLAYER_LOGOUT");
		Index.FRAME:RegisterEvent("CHAT_MSG_ADDON")
		Index.FRAME:SetScript("OnEvent", Index.onEvent)
	end
		
	-- Event gateway
	-- Handles addon commands and loading --
	function Index.onEvent(frame, event, prefix, message, channel, sender)
		-- This addon has loaded, begin
		if event == "ADDON_LOADED" and prefix == appName then 
			Index.onLoad();
		elseif event == "PLAYER_LOGOUT" and ExiWoW.initialized then Index.onPlayerLogout();
		elseif event == "CHAT_MSG_ADDON" then Index.onChatMessage(prefix, sender, message);
		end
	end

		-- Initialize when the addon has loaded
	function Index.onLoad()
		
		-- Character must be created before action
		if type(globalStorage) ~= "table" then globalStorage = {} end
		if type(localStorage) ~= "table" then localStorage = {} end

		-- Load the required classes here
		Action = require("Action");
		Extension = require("Extension");
		Character = require("Character");
		Effect = require("Effect");
		UI = require("UI");
		Timer = require("Timer");
		Event = require("Event");
		Callback = require("Callback");
		Database = require("Database");
		Quest = require("Quest");
		RPText = require("RPText");
		Visual = require("Visual");

		ExiWoW.ME = Character:new();
		UI.build();

		
		

		-- Load defaults into local and globalstorage 
		for k,v in pairs(GLOBALSTORAGE_DEFAULTS) do
			if globalStorage[k] == nil then globalStorage[k] = v end
		end
		for k,v in pairs(LOCALSTORAGE_DEFAULTS) do
			if localStorage[k] == nil then localStorage[k] = v end
		end

		internal.ext = Extension.import({id="ROOT"}, true);	-- Build the main extension for assets

		-- Bind slash commands
		SLASH_EWACT1 = '/ewact'
		SlashCmdList["EWACT"] = function(msg) Action.useOnTarget(msg, "target") end
		SLASH_EWRESET1 = '/ewreset'
		SlashCmdList["EWRESET"] = function(msg) Index.resetSettings() end
		SLASH_EWTOGGLE1 = '/ewtoggle'
		SlashCmdList["EWTOGGLE"] = function(msg) UI.toggle(); end
		
		-- Initialize actions
		Action.ini();

		-- Build libraries
		-- Load order
		internal.build.functions();
		internal.build.functions = nil;
		internal.build.conditions();
		internal.build.conditions = nil;
		Extension.index();
		internal.build.npcs();
		internal.build.npcs = nil;
		internal.build.zones();
		internal.build.zones = nil;
		Extension.index();
		internal.build.spells();
		internal.build.spells = nil;
		Extension.index();
		-- The rest can be in any order
		for k,fn in pairs(internal.build) do
			fn();
		end
		internal.build = nil

		-- Setup gateway
		internal.Gateway();
		internal.Gateway = nil;
		
		-- Bind listeners
		C_ChatInfo.RegisterAddonMessagePrefix(appName.."a")		-- Sends an action	 {cb:cbToken, id:action_id, data:(var)data}
		C_ChatInfo.RegisterAddonMessagePrefix(appName.."c")		-- Receive a callback {cb:cbToken, success:(bool)success, data:(var)data}
		C_ChatInfo.RegisterAddonMessagePrefix(appName.."b")		-- Bystander text. {tx:(str)text,ch:(bool)is_chat}
		
		Timer.set(function()
			Index.loadFromStorage()
			ExiWoW.initialized = true;
			UI.refreshAll();
			Extension.index();
			Event.raise(Event.Types.LOADED)
			Effect.onLoad();
			print("ExiWoW initialized")
		end, 1)

		-- Wait 5 sec for inventory to load
		Timer.set(function()
			UI.refreshAll();
		end, 5)

		-- If you need a big box for debug
		--[[
			local f=CreateFrame("ScrollFrame", "DebugBox", UIParent, "InputScrollFrameTemplate")
			f:SetSize(300,300)
			f:SetPoint("CENTER")
			f.EditBox:SetFontObject("ChatFontNormal")
			f.EditBox:SetMaxLetters(1024)
			f.CharCount:Hide()
			local editBox = f.EditBox -- already created in above template
			editBox:SetFontObject("ChatFontNormal")
			editBox:SetAllPoints(true)
			editBox:SetWidth(f:GetWidth()) -- multiline editboxes need a width declared!!
			-- when ESC is hit while editbox has focus, clear focus (a second ESC closes window)
			editBox:SetScript("OnEscapePressed",editBox.ClearFocus)
		]]
	end

	function Index.onChatMessage(prefix, sender, message)
		local function getChunkedMessage(input, debug)

			local timer = Timer;
			local data = {}
			for msg in input:gmatch("([^§]+)") do
				table.insert(data, msg)
			end
			local token = data[1]
			local section = tonumber(data[2])
			local total = tonumber(data[3])
			local out = ""
			for i=4,#data do
				out = out..data[i]
				if i ~= #data then out = out.."," end
			end
			if debug then print(out) end
			if not token or not section or not total then return false end

			if not Index.INPUT_BUFFER[token] then 
				Index.INPUT_BUFFER[token] = {parts={}, timeout=Timer.set(function() Index.INPUT_BUFFER[token] = nil end, 5)} 
			end
			Index.INPUT_BUFFER[token].parts[section] = out
			
			local joined = ""
			for i=1,total do
				if Index.INPUT_BUFFER[token].parts[i] == nil then return false end
				joined = joined..Index.INPUT_BUFFER[token].parts[i]
			end

			-- Remove from Index.INPUT_BUFFER
			Timer.clear(Index.INPUT_BUFFER[token].timeout)
			Index.INPUT_BUFFER[token] = nil

			return joined, token

		end

		if prefix == appName.."a" then

			--Index.INPUT_BUFFER
			local data, cb = getChunkedMessage(message)
			if data == false then return end

			local sname = Ambiguate(sender, "all") 			-- Sender name for use in units
			
			
			local da = ExiWoW.json.decode(data); 		-- JSON decode message
			local aID = da.id								-- Action ID
			local success, response = Action.receive(aID, sender, da.da, 1);
			if cb then
				Index.sendCallback(cb, sname, success, response);
			end
			

		end

		if prefix == appName.."c" then

			local data, cb = getChunkedMessage(message)
			if data == false then return end
			--DebugBox.EditBox:SetText(data)
			local sname = Ambiguate(sender, "all")
			local response = ExiWoW.json.decode(data);
			Callback.trigger(cb, response.su, response.da, sender);
			
		end

		if prefix == appName.."b" and not UnitIsUnit(Ambiguate(sender, "all"), "player") then

			local data, cb = getChunkedMessage(message);
			if data == false then return end
			--DebugBox.EditBox:SetText(data)
			local sname = Ambiguate(sender, "all");
			local response = ExiWoW.json.decode(data);

			if not CheckInteractDistance(sname, 1) or not response or not response.tx or not response.v or Ambiguate(response.v, "all") == Ambiguate(UnitName("player"), "all") then
				return;
			end

			-- Add to chat log
			if response.ch then
				RPText.npcSpeak(response.tx);
			else
				RPText.bystander(response.tx);
			end
			
			
		end
	end

	function Index.onPlayerLogout()

		if Index.blockSave then return false; end
		if not ExiWoW.loaded then return false; end
		-- Saving
		local l = localStorage;

		l.excitement = ExiWoW.ME.excitement;
		l.underwear_ids = ExiWoW.ME.underwear_ids;
		l.underwear_worn = ExiWoW.ME.underwear_worn;

		l.abilities = {};
		local lib = Database.filter("Action");
		for k,v in pairs(lib) do
			if not v.hidden then
				table.insert( l.abilities, v:export() )
			end
		end

		l.effects = {}
		for k,v in pairs(Effect.applied) do
			table.insert(l.effects, {
				id = v.effect.id,
				expires = v.expires,
				ticks = v.ticks,
				stacks = v.stacks,
				customData = v.effect.customData,
			})
		end

	end



	-- Check public and dungeon limits, this is used everywhere so
	function Index.checkHardlimits(sender, receiver, suppressErrors)

		-- Public toggle
		if not globalStorage.enable_public then
			if sender and not UnitInRaid(sender) and not UnitInParty(sender) and sender and not UnitIsUnit(sender, "player") and UnitPlayerControlled(sender) then
				return Tools.reportError("Sender is not in your party", suppressErrors);
			end
			if receiver and not UnitInRaid(receiver) and not UnitInParty(receiver) and receiver and not UnitIsUnit(receiver, "player") and UnitPlayerControlled(receiver) then
				return Tools.reportError("Target is not in your party", suppressErrors);
			end
		end

		if not globalStorage.enable_in_dungeons then

			if IsInInstance() then
				return Tools.reportError("Can't use in an instance.", suppressErrors)
			end

		end
		return true;

	end

	-- Reset settings
	function Index.resetSettings()
		globalStorage = {};
		localStorage = {};
		Index.blockSave = true;
		ReloadUI();
	end

	-- Load settings
	function Index.loadFromStorage()

		ExiWoW.ME.penis_size = localStorage.penis_size;
		ExiWoW.ME.vagina_size = localStorage.vagina_size;
		ExiWoW.ME.breast_size = localStorage.breast_size;
		ExiWoW.ME.butt_size = localStorage.butt_size;
		ExiWoW.ME.masochism = localStorage.masochism;
		ExiWoW.ME.underwear_ids = localStorage.underwear_ids
		ExiWoW.ME.underwear_worn = localStorage.underwear_worn
		ExiWoW.ME.muscle_tone = localStorage.muscle_tone
		ExiWoW.ME.fat = localStorage.fat
		ExiWoW.ME.intelligence = localStorage.intelligence;
		ExiWoW.ME.wisdom = localStorage.wisdom;
		ExiWoW.ME:addExcitement(localStorage.excitement, true);
		local underwear = ExiWoW.ME:getUnderwear();
		if underwear then
			underwear:onEquip();
		end

		-- Load in abilities
		for k,v in pairs(localStorage.abilities) do
			local abil = Action.get(v.id);
			if abil then abil:import(v) end
		end

		for k,v in pairs(localStorage.effects) do
			if v.expires == 0 or v.expires > GetTime() then
				Effect.run(v.id, v.stacks, v);
			end
		end

		Quest.loadFromStorage();

		ExiWoW.loaded = true;
		Index.onPlayerLogout()
		
	end


	-- Communication methods
	function Index.sendAction(unit, actionID, data, callback)
		if UnitFactionGroup(unit) ~= UnitFactionGroup("player") then return false end
		local out = {
			id = actionID,
			da = data
		};
		local text = ExiWoW.json.encode(out);
		local cb = Callback.add(callback);
		Index.sendChunks("a", cb, ExiWoW.json.encode(out), unit)

	end

	function Index.sendCallback(token, unit, success, data)

		local out = {
			su = success,
			da = data
		};

		--DebugBox.EditBox:SetText(ExiWoW.json.encode(out))
		Index.sendChunks("c", token, ExiWoW.json.encode(out), unit)

	end


	function Index.sendBystanderText(text, isChat, victimName)
		local out = {
			tx = text,
			ch = isChat,
			v = victimName
		};
		local text = ExiWoW.json.encode(out);
		local token = Callback.generateToken();
		--print("Sending bystander", text)
		Index.sendChunks("b", token, ExiWoW.json.encode(out), nil)
	end

	function Index.sendChunks(suffix, token, text, unit)

		-- Allowed chunk size
		local tl = 255-(appName..suffix):len()-20		-- Prefix length

		local chunks = {}
		for i=0,math.floor(text:len()/tl) do
			local chunk = text:sub(i*tl+1, i*tl+tl)
			table.insert(chunks, chunk)
		end
		
		local ctype = "WHISPER"
		if unit == nil then 
			ctype = "PARTY"
		end
		
		--DebugBox.EditBox:SetText(ExiWoW.json.encode(out))
		local total = #chunks
		for i,ch in ipairs(chunks) do
			C_ChatInfo.SendAddonMessage(appName..suffix, token.."§"..i.."§"..total.."§"..ch, ctype, unit)
		end	

	end

	

	

-- Index END


-- Export module
export(
	"Index", 
	Index, 
	{
		sendAction = Index.sendAction,
		sendCallback = Index.sendCallback,
		sendBystanderText = Index.sendBystanderText,
		sendChunks = Index.sendChunks,
		onPlayerLogout = Index.onPlayerLogout,
		checkHardLimits = Index.checkHardlimits,
	}, 
	{
		
	}
)

-- Initializes index
require("Index")



