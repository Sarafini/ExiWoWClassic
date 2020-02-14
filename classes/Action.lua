local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;
local UI, Database, Tools, Timer, RPText, Character, Event, Index, Condition;	-- These are setup in ini

local Action = {}
Action.__index = Action;

	Action.GCD = false;				-- On global cooldown
	Action.GCD_TIMER = 0;
	Action.GCD_SECONDS = 1.5;
	Action.GCD_STARTED = 0;
	-- Consts
	Action.MELEE_RANGE = {37727};				-- These are itemIDs, used with 
	Action.CASTER_RANGE = {34471,28767};
	Action.tooltipTimer = nil;					-- Interval for refreshing the tooltip

	-- Cast timer
	Action.CASTING_SPELL = nil;				-- Spell being cast
	Action.CASTING_TIMER = nil;				-- Spell being cast
	Action.CASTING_TARGET = "player";				-- Spell being cast
	Action.CASTING_MOVEMENT_BINDING = nil		-- Event binding for moving while casting 
	Action.CASTING_SPELL_BINDING = nil			-- Event binding for using a blizzard spell while casting
	Action.FINISHING_SPELL_BINDING = nil
	Action.CASTING_SOUND_LOOP = nil;					-- Sound loop
	Action.CASTING_SOUND_FINISH_EVENT = nil;			-- Event handler for making the sound loop
	Action.FRAME_CASTBAR = nil;


	Action.ini = function()

		UI = require("UI");
		Database = require("Database");
		Tools = require("Tools");
		Timer = require("Timer");
		RPText = require("RPText");
		Character = require("Character");
		Event = require("Event");
		Index = require("Index");
		Condition = require("Condition");

		Action.FRAME_CASTBAR = CreateFrame("StatusBar", "ExiWoWCastBar", UIParent, "CastingBarFrameTemplate");
		local sb = Action.FRAME_CASTBAR;
		CastingBarFrame_OnLoad(sb, false, false, false);
		sb:SetSize(195,13);
		sb:SetPoint("CENTER", UIParent, "CENTER", 0, -200);

		--Action.Lib[1]:toggleCastBar(true);
	end
	

	-- Define the class
	function Action:new(data)
		local self = {}
		setmetatable(self, Action);

		if type(data) ~= "table" then
			data = {}
		end

		local getVar = function(v, def)
			if v == nil then return def end
			return v
		end

		-- Settings
		self.id = data.id or ""										-- ID of Action
		self.name = data.name or ""									-- Name of action
		self.description = data.description or ""					-- Description of action
		self.texture = data.texture or ""							-- Texture, does not need a path
		self.cooldown = data.cooldown or 0							-- Internal cooldown
		self.global_cooldown = getVar(data.global_cooldown, true)			-- Affected by global cooldown
		self.alias = data.alias or false							-- Lets you override the ID for a send
		self.cast_time = data.cast_time or 0						-- Cast time of spell
		self.cast_sound_loop = data.cast_sound_loop or false		-- Cast loop sound
		self.cast_sound_start = data.cast_sound_start or false		-- Start cast sound, played once
		self.cast_sound_success = data.cast_sound_success or false	-- Cast success sound, played once
		self.rarity = type(data.rarity) == "number" and data.rarity or 2
		if self.rarity < 1 then self.rarity = 1
		elseif self.rarity > 7 then self.rarity = 7
		end
		self.passive = data.passive;								-- Passive effect
		self.passive_on = false;
		self.passive_on_enabled = data.passive_on_enabled;			-- REQUIRED PASSIVE Function when passive enabled (if this is passive). First argument is bool fromUserAction
		self.passive_on_disabled = data.passive_on_disabled;		-- Function when passive disabled (if this is passive). This is always triggered through a user action
		self.passive_event_bindings = {};

		self.suppress_all_errors = data.suppress_all_errors or false

		self.conditions = type(data.conditions) == "table" and data.conditions or {};
		self.filters = type(data.filters) == "table" and data.filters or {};		-- Same as above, but will hide the ability and not generate errors

		

		-- Handle default conditions
		local defaults = {
			-- The batched ones need to be separated into single ones on add
			party_restricted = {
				Condition.get("sender_party_restricted"),
				Condition.get("victim_party_restricted"),
			},
			not_stunned = Condition.get("not_stunned"),
			not_in_instance = Condition.get("not_in_instance"),
			sender_alive = Condition.get("sender_alive"),
			victim_alive = Condition.get("victim_alive"),
			not_in_vehicle = {
				Condition.get("sender_not_in_vehicle"),
				Condition.get("victim_not_in_vehicle"),
			},
			not_shapeshifted = Condition.get("victim_not_shapeshifted")
		};
		if type(data.not_defaults) == "table" then
			for _,v in pairs(data.not_defaults) do
				if not defaults[v] then print("Unknown default action condition", v)
				else
					defaults[v] = nil;
				end
			end
		end

		for k,v in pairs(defaults) do
			if v[1] == nil then v = {v}; end
			for _, cond in pairs(v) do
				table.insert(self.conditions, cond);
			end
		end
		-- Functions
		self.fn_send = data.fn_send									-- Function to execute on the sender when sending
		self.fn_receive = data.fn_receive							-- Function to execute on the receiver when receiving
		self.fn_cast = data.fn_cast									-- Function to execute on the sender when starting a cast
		self.fn_done = data.fn_done									-- Function sent on both success and interrupt

		
		self.charges = data.charges or math.huge;						-- Charges tied to this spell. Charges can be added by loot?
		self.max_charges = type(data.max_charges) == "number" and data.max_charges or math.huge;

		Condition.checkSyntax(self, self.conditions);
		Condition.checkSyntax(self, self.filters);

		-- Custom
		self.hidden = data.hidden or false;								-- Hides action from action window
		self.learned = getVar(data.learned, true);						-- This spell needs to be learned
		self.favorite = data.favorite or false;							-- Gets priority above the rest
		self.important = data.important or false;						-- Gets priority below favorite

		-- Internal
		self.on_cooldown = false
		self.cooldown_timer = 0;
		self.cooldown_started = 0;
		

		return self;
	end





			-- Methods --
	-- Saving & Loading --

	function Action:import(data)

		-- Importable args
		if data.learned ~= nil and not self.learned then self.learned = not not data.learned end
		if data.favorite ~= nil then self.favorite = not not data.favorite end
		if data.cooldown_started and data.cooldown_started+self.cooldown > GetTime() then 
			self:setCooldown(self.cooldown+data.cooldown_started-GetTime(), true);
			self.cooldown_started = data.cooldown_started;
		else
			self.cooldown_started = 0;
		end
		if data.passive_on then 
			if not self.passive_on then
				self:passive_on_enabled(false);
			end
			self.passive_on = true;
		end
		if data.charges then self.charges = data.charges end
		if self.charges == "INF" then self.charges = math.huge end

	end

	function Action:export()

		local charges = self.charges
		if charges == math.huge then charges = "INF" end
		return {
			id = self.id,
			learned = self.learned,
			favorite = self.favorite,
			cooldown_started = self.cooldown_started,
			charges = charges,
			passive_on = self.passive_on
		};

	end


	-- Passives
	function Action:passiveOn(event, callback)
		local handle = Event.on(event, callback);
		table.insert(self.passive_event_bindings, handle);
		return handle;
	end

	function Action:passiveOff()
		for _,v in pairs(self.passive_event_bindings) do
			Event.off(v);
		end
	end

	-- Charges
	function Action:consumeCharges(nr)
		if not nr then nr = 1 end

		-- Not enough charges
		if self.charges-nr < 0 then return false end

		self.charges = self.charges-nr;
		if self.charges > self.max_charges then self.charges = self.max_charges end
		UI.actionPage.update();
		return true;

	end


	function Action:setCooldown(overrideTime, ignoreGlobal)

		-- This action is completely excempt from cooldowns
		if (ignoreGlobal or not self.global_cooldown) and self.cooldown <= 0 then return end

		if self.global_cooldown and not ignoreGlobal then
			Action:setGlobalCooldown();
		end

		local cd = self.cooldown;
		if overrideTime then cd = overrideTime end;

		self:resetCooldown();
		if cd > 0 then
			self.on_cooldown = true;
			self.cooldown_started = GetTime();
			Timer.set(function(se)
				self:resetCooldown();
			end, cd);
		end
		UI.actionPage.update();


	end

	function Action:setGlobalCooldown()

		Action.GCD = true;
		Action.GCD_STARTED = GetTime();
		Timer.clear(Action.GCD_TIMER);
		Timer.set(function()
			Action.GCD = false;
			Action.GCD_STARTED = 0;
		end, Action.GCD_SECONDS);
		UI.actionPage.update();

	end

	function Action:resetCooldown()

		self.on_cooldown = false;
		Timer.clear(self.cooldown_timer);
		self.cooldown_started = 0;
		UI.actionPage.update();

	end

	-- Returns when cooldown started and how long it is
	function Action:getCooldown()

		local gl = Action.GCD_SECONDS+Action.GCD_STARTED;
		local ll = self.cooldown_started+self.cooldown;

		local ctime = GetTime();
		-- We're not on a cooldown --
		if ll < ctime and gl < ctime then return 0, 0 end

		-- Global cooldown is longer
		if gl > ll then
			return Action.GCD_STARTED, Action.GCD_SECONDS;
		end

		-- Local cooldown --
		return self.cooldown_started, self.cooldown;

	end

	-- Validates conditions used in ability display
	function Action:validateFiltering(caster, suppressErrors)

		local _, _, cls = UnitClass(caster);
		local _, rname = UnitRace(caster);

		-- conditions, senderUnit, receiverUnit, senderChar, receiverChar, eventData, event, action, debug
		local success, cond = Condition.all(self.filters, caster, caster, ExiWoW.ME, ExiWoW.ME, nil, nil, self);

		if not success then
			return cond:reportError(suppressErrors);
		end

		-- Send validation
		if caster == "player" then
			
			if self.charges < 1 then
				return Tools.reportError("Not enough charges.", suppressErrors)
			end

			if not self.learned then
				return Tools.reportError("Spell not learned.", suppressErrors)
			end

		end


		return true;

	end


	-- Condition validation
	-- Validates for both receive and send --
	-- Returns boolean true on success
	-- suppressErrors can also be int 1 to return the error
	function Action:validate(unitCaster, unitTarget, suppressErrors, isSend, isCastComplete)

		if self.suppress_all_errors and suppressErrors ~= 1 then 
			suppressErrors = true;
		end -- Allow actions to suppress errors

		-- Make sure it's not on cooldown
		if isSend and not isCastComplete and (self.on_cooldown or (self.global_cooldown and Action.GCD)) then
			return Tools.reportError("Can't do that yet", suppressErrors);
		end

		-- Validate filtering. Filtering is also used in if a spell should show up whatsoever
		if isSend and not self:validateFiltering(unitCaster, suppressErrors) then 
			return false;
		end


		-- Make sure target and caster are actual units
		unitCaster = Ambiguate(unitCaster, "all")
		unitTarget = Ambiguate(unitTarget, "all")
		if isSend and not UnitExists(unitCaster) then
			return Tools.reportError("Caster does not exist", suppressErrors);
		end
		if not UnitExists(unitTarget) then
			return Tools.reportError("No viable target", suppressErrors);
		end

		if not UnitIsPlayer(unitCaster) or not UnitIsPlayer(unitTarget) then
			return Tools.reportError("Target is not a player", suppressErrors);
		end

		local hard, reason = Index.checkHardLimits(unitCaster, unitTarget, suppressErrors);
		if not hard then 
			return false, reason;
		end

		local tChar = ExiWoW.TARGET;
		if unitTarget == "player" then
			tChar = ExiWoW.ME;
		end

		-- Validate the conditions
		if #self.conditions > 0 then
			-- conditions, senderUnit, receiverUnit, senderChar, receiverChar, eventData, event, action, debug
			local senderChar = nil;
			if isSend then senderChar = ExiWoW.ME; end
			local success, failedCondition = Condition.all(self.conditions, unitCaster, unitTarget, senderChar, ExiWoW.ME, nil, nil, self);
			if not success then
				return failedCondition:reportError(suppressErrors);
			end
		end

		return true

	end

	function Action:getAllConditions()
		return Tools.concat(self.conditions, self.filters);
	end

	function Action:requiresStealth()
		local all = self:getAllConditions();
		for _,cond in pairs(all) do
			if cond.type == Condition.Types.RTYPE_STEALTH and not cond.inverse then
				return true;
			end
		end
	end

	function Action:requiresParty()
		local all = self:getAllConditions();
		for _,cond in pairs(all) do
			if cond.type == Condition.Types.RTYPE_PARTY and not cond.inverse then
				return true;
			end
		end
	end

	function Action:partyRestricted()
		local all = self:getAllConditions();
		for _,cond in pairs(all) do
			if cond.type == Condition.Types.RTYPE_PARTY_RESTRICTED and not cond.inverse then
				return true;
			end
		end
	end

	function Action:disabledInCombat()
		local all = self:getAllConditions();
		for _,cond in pairs(all) do
			if cond.type == Condition.Types.RTYPE_COMBAT and cond.inverse then
				return true;
			end
		end
	end

	function Action:selfCastOnly()
		local all = self:getAllConditions();
		for _,cond in pairs(all) do
			if cond.type == Condition.Types.RTYPE_SELF_ONLY and not cond.inverse then
				return true;
			end
		end
	end

	function Action:requiresMeleeRange()
		local all = self:getAllConditions();
		for _,cond in pairs(all) do
			if cond.type == Condition.Types.RTYPE_DISTANCE and not cond.inverse and cond.data == Action.MELEE_RANGE then
				return true;
			end
		end
	end

	function Action:requiresCastRange()
		local all = self:getAllConditions();
		for _,cond in pairs(all) do
			if cond.type == Condition.Types.RTYPE_DISTANCE and not cond.inverse and cond.data == Action.CASTER_RANGE then
				return true;
			end
		end
	end

		-- TOOLTIP HANDLING --
	function Action:onTooltip(frame)

		Timer.clear(Action.tooltipTimer);
		if not not frame then

			-- Set timer for refreshing
			local th = self
			Action.tooltipTimer = Timer.set(function()
				th:drawTooltip()
			end, 0.25, math.huge);

			GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
			self:drawTooltip();

		else

			GameTooltip:Hide();

		end


	end

		-- Returns range in yards based on the range consts --
	function Action.getRangeYards()
		return 40;
	end



	function Action:drawTooltip()

		local v = self
		GameTooltip:ClearLines()
		GameTooltip:AddLine(v.name, 1, 1, 1)

		-- CD --
		local started, duration = v:getCooldown();
		local singles = {}

		if v.passive then
			table.insert(singles, "Passive");
		elseif v.cast_time > 0 then
			table.insert(singles, Tools.timeFormat(v.cast_time).." cast");
		else
			table.insert(singles, "Instant")
		end

		if not v.self_only and not v.passive then
			if v:requiresMeleeRange() then
				table.insert(singles, "Melee Range");
			elseif v:requiresCastRange() then
				table.insert(singles, "40 yd range");
			end
		end

		if v.cooldown > 0 and not v.passive then
			table.insert(singles, Tools.timeFormat(v.cooldown).." cooldown");
		end
		if v.passive then
			if v.passive_on then
				table.insert(singles, "ENABLED");
			else
				table.insert(singles, "Disabled");
			end
		end

		local c = 0.8	-- Brightness of text
		local x = 0		-- Iterator for double texts
		local pre = ""	-- Previous text
		-- a starts at 1 because hurdurlua
		for a,text in pairs(singles) do
			if a%2 == 0 then
				GameTooltip:AddDoubleLine(pre, text, c,c,c,c,c,c);
			else 
				pre = text
			end
			x = x+1;
		end
		if x%2 == 1 then
			GameTooltip:AddLine(pre, c,c,c);
		end

		

		if v:requiresStealth() then
			GameTooltip:AddLine("Requires Stealth", c,c,c);
		end

		if not v:selfCastOnly() then

			if v:requiresParty() then
				GameTooltip:AddLine("Requires Party Member", c,c,c);
			elseif v:partyRestricted() then
				GameTooltip:AddLine("Party Restricted", c,c,c);
			end

		end

		if v:disabledInCombat() then
			GameTooltip:AddLine("Disabled in Combat", c,c,c);
		end

		if started > 0 then
			GameTooltip:AddLine("Cooldown remaining: "..tostring(Tools.timeFormat(duration-(GetTime()-started))), 1, 1,1, 0.75);
		end


		GameTooltip:AddLine(v.description, nil, nil, nil, true)
		GameTooltip:Show()

	end

		-- CASTBAR --
	-- Shows castbar for this action, or can be used statically to turn off
	function Action:toggleCastBar(on)


		local sb = Action.FRAME_CASTBAR;

		if not on then
			-- Hide
			sb.casting = false;
			sb:Hide();
			return;
		end

		local startColor = CastingBarFrame_GetEffectiveStartColor(sb, false, notInterruptible);
		sb:SetStatusBarColor(startColor:GetRGB());
		if sb.flashColorSameAsStart then
			sb.Flash:SetVertexColor(startColor:GetRGB());
		else
			sb.Flash:SetVertexColor(1, 1, 1);
		end

		--sb.Spark:Show();

		sb.value = 0;
		sb.maxValue = self.cast_time;
		sb:SetMinMaxValues(0, sb.maxValue);
		sb:SetValue(sb.value);
		
		sb.Text:SetText(self.name);
		CastingBarFrame_ApplyAlpha(sb, 1.0);

		sb.holdTime = 0;
		sb.casting = true;
		sb.castID = 0;
		sb.channeling = nil;
		sb.fadeOut = nil;

		if self.texture then 
			sb.Icon:SetTexture("Interface/Icons/"..self.texture);
		end
		
		sb:Show();

	end


	-- Template functions for callbacks and such
	
	function Action:sendRPText(sender, target, suppressErrors, callback)

		local ts = ExiWoW.ME;
		local tt = ExiWoW.CAST_TARGET;
		if UnitIsUnit(target, "player") then tt = ts; end -- Self cast

		local id = self.id;
		if self.alias then id = self.alias end
		-- Request your target to generate a text
		return {
			id = id,
			sender=ExiWoW.ME:export(true),
		}, 
		-- Callback
		function(se, success, data) 
			if success and type(data) == "table" then

				if data.t then
					RPText.print(RPText.convert(data.t, ExiWoW.ME, tt))
				end

				-- Play receiving sound if not self cast
				if data.so then 
					local sounds = data.so;
					if type(data.so) ~= "table" then
						sounds = {data.so};
					end
					for _,sound in pairs(sounds) do
						PlaySound(sound, "SFX");
					end
				end

				if type(callback) == "function" then
					callback(se, success, data);
				end
				
			end
		end
	end

	-- Callback is triggered with text if text was successfully received
	function Action:receiveRPText( sender, target, args, callback )

		if 
			type(args) ~= "table" or 
			type(args.id) ~= "string" or 
			type(args.sender) ~= "table" then
			return;
		end
		id = args.id;
		senderPlayer = Character:new(args.sender);
		senderPlayer.name = Ambiguate(sender, "all");

		-- id, senderUnit, receiverUnit, senderChar, receiverChar, eventData, event, action
		local rptext = RPText.get(id, sender, "player", senderPlayer, ExiWoW.ME, nil, nil, Action.get(id));
		if not rptext then return false end

		local out = {
			t=rptext.text_sender,
			so=rptext.sound,
			tc=rptext.custom,
		};

		rptext:convertAndReceive(senderPlayer, ExiWoW.ME);
		if callback then
			callback(rptext);
		end
		return true, out;

	end

	function Action:allowCasterMoving()
		for _,a in pairs(self.conditions) do
			if a.type == Condition.Types.RTYPE_MOVING and a.inverse then
				return false
			end
		end
		return true
	end


-- STATIC --

	function Action.sort()
		Database.sort("Action", function(a,b)
			local aimportance = (a.favorite and 1 or 0)*2+(a.important and 1 or 0);
			local bimportance = (b.favorite and 1 or 0)*2+(b.important and 1 or 0);
			if aimportance > bimportance then return true end
			if aimportance < bimportance then return false end
			return a.name < b.name;
		end)	
	end

	-- Useful stuff for actions --
	function Action.handleInspectCallback(target, success, data)
		-- Fail --
		if not success then return false end

		local char = Character:new(data, target)
		local out = "Inspecting "..Ambiguate(UnitName(target), "all").." you can tell that"
		local muscle = char.muscle_tone
		local fat = char.fat
		local butt = char:getButtSize()
		local breasts = char:getBreastSize()
		local junk = char:getPenisSize()

		local texts = {}
		if muscle < 3 then table.insert(texts, "frail")
		elseif muscle < 5 then table.insert(texts, "weak")
		elseif muscle > 7 then table.insert(texts, "brawny")
		elseif muscle > 5 then table.insert(texts, "toned")
		end
		if fat < 2 then table.insert(texts, "emaciated")
		elseif fat < 4 then table.insert(texts, "slender")
		elseif fat > 7 then table.insert(texts, "corpulent")
		elseif fat > 5 then table.insert(texts, "burly")
		end

		if #texts > 0 then out = out.." they look "..table.concat(texts, ", and ")..". They have"
		else out = out.." they have"
		end

		texts = {}
		if butt == 0 then table.insert(texts, "a flat butt")
		elseif butt == 1 then table.insert(texts, "a small butt")
		elseif butt == 2 then table.insert(texts, "an average butt")
		elseif butt == 3 then table.insert(texts, "a large butt")
		elseif butt == 4 then table.insert(texts, "a huge butt")
		end
		if breasts == false then table.insert(texts, "no breasts")
		elseif breasts == 0 then table.insert(texts, "a mostly flat chest")
		elseif breasts == 1 then table.insert(texts, "a small chest")
		elseif breasts == 2 then table.insert(texts, "average sized breasts")
		elseif breasts == 3 then table.insert(texts, "a large chest")
		elseif breasts == 4 then table.insert(texts, "a huge chest")
		end
		if junk == 0 then table.insert(texts, "a barely visible pants bulge")
		elseif junk == 1 then table.insert(texts, "a small pants bulge")
		elseif junk == 2 then table.insert(texts, "an average pants bulge")
		elseif junk == 3 then table.insert(texts, "a generous pants bulge")
		elseif junk == 4 then table.insert(texts, "a massive pants bulge")
		end
		
		if #texts > 0 then
			out = out.." "..table.concat(texts, " and ")
		end
		out = out.."."

		if char.excitement > 0 then
			out = out.."\nThey "
			if char.excitement < 0.25 then out = out.."seem a little flustered"
			elseif char.excitement < 0.5 then out = out.."seem somewhat flustered"
			elseif char.excitement < 0.75 then out = out.."seem pretty flustered"
			elseif char.excitement < 1 then out = out.."seem very flustered"
			else out = out.."are fidgeting, looking highly uncomfortable"
			end
			out = out.."."
		end

		RPText.print(out);
	end


	-- Get from library by id
	function Action.get(id)

		local lib = Database.filter("Action");
		for i, act in pairs(lib) do
			if act.id == id then return act end
		end
		return false

	end

	-- Check range
	function Action.checkRange(target, item)
		if not item then item = self.max_distance end
		for i,v in ipairs(item) do
			if IsItemInRange(v, target) then
				return true;
			end
		end
		return false;
	end

	-- Send an action, id can also be an action
	function Action.useOnTarget(id, target, castFinish, isProc)

		if Action.CASTING_SPELL then
			return Tools.reportError("You are already using an action!");
		end

		-- Find the action
		local action = id;
		if type(action) ~= "table" then
			action = Action.get(id);
			if not action then
				return Tools.reportError("Action not found: "..id);
			end
		end

		local isPassive = action.passive and not isProc;


		-- Self cast actions don't need to send a message
		if action:selfCastOnly() or not UnitExists("target") or isPassive then
			target = "player"
		end

		if action.charges-1 < 0 and not isPassive then
			return Tools.reportError("Not enough charges");
		end

		

		-- Validate conditions
		if not isPassive then
			local su, re = action:validate("player", target, false, true, castFinish)
			if not su then 
				return false;
			end
		-- Passive toggles only need to validate filtering to toggle
		else
			if not action:validateFiltering("player") then
				return false;
			end
		end

		-- Set cooldowns etc

		-- Use special function, if it returns false, then prevent default behavior
		local args = {}
		local callback = nil
		
		-- Default send logic

		ExiWoW.CAST_TARGET = ExiWoW.TARGET

		if not castFinish and not isPassive then 
			Action:setGlobalCooldown();
		end

		-- Toggle passive
		if isPassive then
			action.passive_on = not action.passive_on;
			if action.passive_on then
				action:passive_on_enabled(true);
			else
				if type(action.passive_on_disabled) == "function" then
					action:passive_on_disabled();
				end
				action:passiveOff();
			end
			UI.actionPage.update();
		elseif action.cast_time <= 0 or castFinish then 

			Event.raise(Event.Types.ACTION_SENT, {id=action.id, target=target})
			if type(action.fn_done) == "function" then action:fn_done(true) end
			if type(action.fn_send) == "function" then
				args, callback = action:fn_send("player", target, suppressErrors);
				if args == false then return false end -- Return false from your custom function to prevent a send
			end

			-- Finish cast
			action:setCooldown(false, true);
			-- Send to target
			local first,last = UnitName(target)
			if last then first = first.."-"..last end
			Index.sendAction(Ambiguate(first, "all"), action.id, args, function(...)
				if type(callback) == "function" then callback(...) end
				-- Reason on fail is data
				local self, success, reason = ...
				Event.raise(Event.Types.ACTION_USED, {id=id, target=target, args=args, success=success})
				if success then
					action:consumeCharges(1);
				elseif reason then
					Tools.reportError(reason);
					-- Wipe cooldown
					action:resetCooldown();
				end
			end)
			
		else 
			-- Start cast
			Action.beginSpellCast(action, target);
		end

	end


	-- Receive an action
	function Action.receive(id, sender, args, suppressErrors)

		-- Default value is true
		if suppressErrors == nil then suppressErrors = true end
		local action = Action.get(id);
		if not action then 
			return false; 
		end			-- Received Action not found

		-- Received action is invalid
		local attempt, err = action:validate(sender, "player", suppressErrors, false, false);
		if not attempt then 
			return false, err;
		end

		-- Returns (bool)success, (var)data
		if type(action.fn_receive) == "function" then
			return action:fn_receive(sender, "player", args);
		else 
			return true
		end

	end

	-- Tools for conditions
	function Action.computeDistance(x1,y1,z1,x2,y2,z2, instance1, instance2)
		if instance1 ~= instance2 then return end
		return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2-z1) ^ 2) ^ 0.5
	end


	function Action.beginSpellCast(action, target)

		Action:endSpellCast(false);
		Action.CASTING_SPELL = action;
		Action.CASTING_TARGET = Ambiguate( UnitName(target), "all" );
		-- Timer
		Action.CASTING_TIMER = Timer.set(function()
			Action:endSpellCast(true);
		end, action.cast_time);

		-- Cast bar
		action:toggleCastBar(true);

		if type(action.fn_cast) == "function" then
			action:fn_cast("player", target, suppressErrors)
		end

		local interrupt = function()
			PlaySound(10846, "SFX");
			Tools.reportError("Interrupted");
			Action.endSpellCast(false);
			if type(action.fn_done) == "function" then action:fn_done(false) end
		end

		if action.cast_sound_start then
			PlaySound(action.cast_sound_start, "SFX")
		end

		-- Audio loop
		if action.cast_sound_loop then
			local _, handle = PlaySound(action.cast_sound_loop, "SFX", false, true);
			Action.CASTING_SOUND_LOOP = handle;
			Action.CASTING_SOUND_FINISH_EVENT = Event.on("SOUNDKIT_FINISHED", function(data)
				if data[1] == Action.CASTING_SOUND_LOOP then 
					StopSound(Action.CASTING_SOUND_LOOP);
					local _, handle = PlaySound(action.cast_sound_loop, "SFX", false, true);
					Action.CASTING_SOUND_LOOP = handle;
				end
			end)
		end

		-- Move interrupt
		if not action:allowCasterMoving() then
			Action.CASTING_MOVEMENT_BINDING = Event.on("PLAYER_STARTED_MOVING", interrupt)
		end

		-- Official effect
		Action.CASTING_SPELL_BINDING = Event.on("UNIT_SPELLCAST_START", function(data)
			if UnitIsUnit(data[1], "PLAYER") then interrupt() end
		end)
		Action.FINISHING_SPELL_BINDING = Event.on("UNIT_SPELLCAST_SUCCEEDED", function(data)
			if data[3] ~= 240022 then
				if UnitIsUnit(data[1], "PLAYER") then interrupt() end
			end
		end)

		
	end

	function Action.endSpellCast(success)

		-- Make sure we are actually casting --
		if not Action.CASTING_SPELL then return end

		local self = Action.CASTING_SPELL;
		
		Event.off(Action.CASTING_MOVEMENT_BINDING);
		Event.off(Action.CASTING_SPELL_BINDING);
		Event.off(Action.FINISHING_SPELL_BINDING);
		Event.off(Action.CASTING_SOUND_FINISH_EVENT);

		-- Let it play the fade out animation
		if not success then
			Event.raise(Event.Types.ACTION_INTERRUPTED, {id=Action.CASTING_SPELL.id, target=Action.CASTING_TARGET})
			Action:toggleCastBar(false);
		end


		if Action.CASTING_SOUND_LOOP then
			StopSound(Action.CASTING_SOUND_LOOP);
			Action.CASTING_SOUND_LOOP = nil
		end

		if success and self.cast_sound_success then
			PlaySound(self.cast_sound_success, "SFX")
		end

		Timer.clear(Action.CASTING_TIMER);
		Timer.clear(Action.CASTING_INTERVAL);
		
		local c = Action.CASTING_SPELL
		Action.CASTING_SPELL = nil;
		if success then
			Action.useOnTarget(c, Action.CASTING_TARGET, true);
		end

	end

export(
	"Action", 
	Action,
	{
		sort = Action.sort,
		get = Action.get,
		useOnTarget = Action.useOnTarget,
		endSpellCast = Action.endSpellCast,
		sendRPText = Action.sendRPText,
		computeDistance = Action.computeDistance,
		
	},
	Action
)
