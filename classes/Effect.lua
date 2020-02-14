local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local Database, Character, Timer, Event, Tools;

-- Effect PASSIVES
local EffectPassive = {}
	EffectPassive.__index = EffectPassive;
	function EffectPassive:new(data)
		local self = {};
		setmetatable(self, EffectPassive); 

		self.type = data.type;
		self.data = data.data;
		
		return self;
	end

	EffectPassive.Types = {
		Visual = "Visual",				-- {id=id}
	};


local Effect = {}
	Effect.__index = Effect;
	Effect.applied = {}					-- {index = {effect:Effect:new(), expires:(float)expires, ticks:(int)ticks, stacks:(int)stacks, id:(int)index}...}
	Effect.index = 0
	Effect.passives = {};


	function Effect.ini()
		Database = require("Database");
		Character = require("Character");
		Event = require("Event");
		Timer = require("Timer");
		Tools = require("Tools");
		Visual = require("Visual");
	end

	function Effect:new(data)
		local self = {}
		setmetatable(self, Effect); 

		self.id = data.id
		self.detrimental = data.detrimental or false	-- 
		self.duration = data.duration or 0;				-- Total duration of effect, use 0 for passive
		self.ticking = data.ticking or 0;				-- Sec between ticks
		self.max_stacks = data.max_stacks or 1;
		self.texture = data.texture;
		self.name = data.name;
		self.description = data.description;
		self.sound_loop = data.sound_loop;
		self.passives = type(data.passives) == "table" and data.passives or {};			-- Use EffectPassive

		self.onAdd = data.onAdd;							-- (obj)activeData, (bool)fromLogin
		self.onRemove = data.onRemove;
		self.onTick = data.onTick;
		self.onStackChange = data.onStackChange;			-- (obj)activeData, (bool)fromLogin
		self.onRightClick = data.onRightClick;				-- Right click binding
		self.customData = {};								-- Supplied when applying the effect
		self.timers = {};

		self.tags = type(data.tags) == "table" and data.tags or {};	-- Not a set, just id, id1, id2...

		self.eventBindings = {};

		-- Automatic
		self.loopPlaying = nil

		return self
	end

	local function getNumBuffs(detrimental)
		local out = 0
		for i,v in pairs(Effect.applied) do
			if 
				(v.effect.detrimental and detrimental) or
				(not v.effect.detrimental and not detrimental)
			then out = out+1 end
		end
		return out
	end


	-- Checks if an effect object is already affecting us
	function Effect:isApplied()
		for k,v in pairs(Effect.applied) do
			if v.effect == self then return k end 
		end
		return false
	end

	function Effect:updateTooltip(buff)
		GameTooltip:SetOwner(buff, "ANCHOR_BOTTOMLEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(self.name, 1, 1, 1)
		GameTooltip:AddLine(self.description, nil, nil, nil, true)
		GameTooltip:Show()
	end

	-- FromLogin is added when this is added when you login or reload UI. And it's the "out" object defined below
	function Effect:add(stacks, fromLogin, customData)

		if not stacks or stacks < 1 then stacks = 1 end
		local expires = 0
		if self.duration and self.duration > 0 then
			expires = self.duration+GetTime()
		end

		local exists = self:isApplied()
		local existed = exists
		local out = {}
		local runOnAdd = false
		local fLogin = type(fromLogin) == "table";
		-- Insert the effect
		if fLogin then
			Effect.index = Effect.index+1;
			exists = Effect.index;
			fromLogin.effect = self;
			fromLogin.id = exists;
			customData = fromLogin.customData;
			Effect.applied[exists] = fromLogin;
			out = fromLogin;
			runOnAdd = true;
		end
		self.customData = customData;
		
		
		-- Newly added effect
		if exists == false then

			runOnAdd = true
			Effect.index = Effect.index+1
			exists = Effect.index
			out = {
				effect = self,
				expires = expires,
				ticks = 0,
				stacks = stacks,
				id = Effect.index
			};

			local ticking = 0
			if self.ticking and self.ticking > 0 then
				ticking = self.ticking
			end

			Effect.applied[Effect.index] = out

		-- Existing effect, but not if it was loaded from reload
		elseif not fLogin then
			out = Effect.applied[exists]
			Timer.clear(out.timerExpire);
			out.expires = expires
			out.stacks = out.stacks + stacks
		end

		if out.stacks > self.max_stacks then
			out.stacks = self.max_stacks
		end

		-- Handle ticking
		local se = self;
		if self.ticking > 0 and type(self.onTick) == "function" and (not existed or fLogin) then
			out.timerTick = Timer.set(function() 
				se:onTick();
				out.ticks = out.ticks+1;
			end, self.ticking, math.huge);
		end

		if self.sound_loop and (not existed or fLogin) then

			local _, handle = PlaySound(self.sound_loop, "SFX", false, true);
			self.loopPlaying = handle;
			local se = self;
			self.loopEvent = Event.on("SOUNDKIT_FINISHED", function(data)
				if data[1] == se.loopPlaying then 
					local _, handle = PlaySound(se.sound_loop, "SFX", false, true);
					se.loopPlaying = handle;
				end
			end)

		end

		-- onAdd function
		if type(self.onAdd) == "function" and runOnAdd then
			self:onAdd(out, fromLogin);
		end

		-- Runs on both since technically an add is a stack change
		if type(self.onStackChange) == "function" then
			self:onStackChange(out, fromLogin);
		end

		-- Both newly added and stack added
		if expires > 0 then
			local dur = self.duration
			-- Update timer
			if fLogin then
				dur = out.expires-GetTime()
			end
			out.timerExpire = Timer.set(function() Effect.rem(out.id) end, dur);
		end

		Effect:UpdateAllBuffAnchors()
		return exists
	end

	function Effect:rebindMouseover(buffName, effect)
		buff = _G[buffName]
		if not buff then return end
		buff:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
			GameTooltip:SetFrameLevel(self:GetFrameLevel() + 2);
			if effect then
				effect.effect:updateTooltip(self);
			else
				GameTooltip:SetUnitAura(PlayerFrame.unit, self:GetID(), self.filter);
			end
		end)
	end

	function Effect:hasTag(tag)
		for _,t in pairs(self.tags) do
			if Tools.multiSearch(t, tag) then
				return true;
			end
		end
	end

	-- Binds an event that's auto removed when the effect is removed
	function Effect:on(event, callback)
		table.insert(self.eventBindings, Event.on(event, callback));
	end
	

	function Effect:setTimer(...)
		table.insert(self.timers, Timer.set(...));
	end

	-- Removes timers and event bindings
	function Effect:off()
		for _,v in pairs(self.eventBindings) do
			Event.off(v);
		end
		for _,v in pairs(self.timers) do
			Timer.clear(v);
		end
	end


	-- Static

	function Effect.getBuffAtIndex(index, detrimental)
		local i = 0
		for k,v in pairs(Effect.applied) do
			if 
				(detrimental and v.effect.detrimental) or
				(not detrimental and not v.effect.detrimental)
			then
				i = i+1
				if i == index then return v end
			end 
		end
	end

	function Effect.refreshBuffs()
		local n = 0
		for i=1,BUFF_MAX_DISPLAY do
			if UnitAura("player", i, "HELPFUL") == nil then
				n = n+1
				local effect = Effect.getBuffAtIndex(n, false);
				Effect:AuraButtonUpdate("BuffButton", i, "HELPFUL", effect);
				Effect:rebindMouseover("BuffButton"..i, effect)
			end
		end

		n = 0
		for i=1,DEBUFF_MAX_DISPLAY do
			if UnitAura("player", i, "HARMFUL") == nil then
				n = n+1
				local effect = Effect.getBuffAtIndex(n, true)
				Effect:AuraButtonUpdate("DebuffButton", i, "HARMFUL", effect);
				Effect:rebindMouseover("DebuffButton"..i, effect)
			end
		end

	end

	function Effect.get(id)
		local lib = Database.filter("Effect");
		for _,v in pairs(lib) do
			if v.id == id then return v end
		end
		return false
	end


	-- Runs an effect by ID
	function Effect.run(id, stacks, fromLogin, customData)
		local effect = Effect.get(id)
		if not effect then 
			print("Effect not found", id); 
			return false; 
		end
		effect:add(stacks, fromLogin, customData);
		Effect.updatePassives();
	end

	function Effect.rem(index)
		local effect = Effect.applied[index];
		local fx = effect.effect;
		if type(fx.onRemove) == "function" then
			fx:onRemove();
		end
		fx:off();
		if fx.loopEvent then
			Event.off(fx.loopEvent);
		end
		if fx.loopPlaying then
			StopSound(fx.loopPlaying);
		end
		Timer.clear(effect.timerExpire);
		Timer.clear(effect.timerTick);
		Effect.applied[index] = nil;
		Effect:UpdateAllBuffAnchors();
		Effect.updatePassives();
	end

	function Effect.remByID(id)
		for k,v in pairs(Effect.applied) do
			if v.effect.id == id then Effect.rem(k) end
		end
	end

	function Effect.remByTags(...)
		local args = {...};
		for _,tag in pairs(args) do
			for id,fx in pairs(Effect.applied) do
				if fx.effect:hasTag(tag) then
					Effect.rem(id);
				end
			end
		end
	end

	function Effect.remByTagsNotThis(th, ...)
		local args = {...};
		for _,tag in pairs(args) do
			for id,fx in pairs(Effect.applied) do
				if fx.effect:hasTag(tag) and fx.effect ~= th then
					Effect.rem(id);
				end
			end
		end
	end

	-- Hook for official methods, Don't remove the colon : 
	function Effect:AuraButtonUpdate(buttonName, index, filter, effect)

		local unit = PlayerFrame.unit;
		local name = false
		local texture = ''
		local count = 1
		--local debuffType = DebuffTypeSymbol["Magic"]
		local duration = 0
		local expirationTime = 0
		local timeMod = 0
		local description = ""

		if effect then
			local obj = effect.effect
			name = obj.name
			texture = obj.texture
			count = effect.stacks
			duration = obj.duration
			expirationTime = effect.expires
			description = obj.description
		end

		local buffName = buttonName..index;
		local buff = _G[buffName];

		if ( not name ) then
			-- No buff so hide it if it exists
			if ( buff ) then
				buff:Hide();
				buff.ewID = nil
				buff.duration:Hide();
			end
			return nil;
		else
			local helpful = (filter == "HELPFUL");
			-- If button doesn't exist make it
			if ( not buff ) then
				if ( helpful ) then
					buff = CreateFrame("Button", buffName, BuffFrame, "BuffButtonTemplate");
				else
					buff = CreateFrame("Button", buffName, BuffFrame, "DebuffButtonTemplate");
				end
				buff.parent = BuffFrame;
			end
			-- Setup Buff
			buff:SetID(index);
			buff.unit = unit;
			buff.filter = filter;
			buff:SetAlpha(1.0);
			buff.exitTime = nil;
			buff.ewID = effect.id;
			buff:Show();

			-- Set filter-specific attributes
			if ( not helpful ) then
				-- Anchor Debuffs
				DebuffButton_UpdateAnchors(buttonName, index);

				buff:RegisterForClicks("RightButtonUp");
				buff:SetScript("OnClick", Effect.onRightClick)

				-- Set color of debuff border based on dispel class.
				local debuffSlot = _G[buffName.."Border"];
				if ( debuffSlot ) then
					local color;
					if ( debuffType ) then
						color = DebuffTypeColor[debuffType];
						if ( ENABLE_COLORBLIND_MODE == "1" ) then
							buff.symbol:Show();
							buff.symbol:SetText(DebuffTypeSymbol[debuffType] or "");
						else
							buff.symbol:Hide();
						end
					else
						buff.symbol:Hide();
						color = DebuffTypeColor["none"];
					end
					debuffSlot:SetVertexColor(color.r, color.g, color.b);
				end
			end

			if ( duration > 0 and expirationTime ) then
				if ( SHOW_BUFF_DURATIONS == "1" ) then
					buff.duration:Show();
				else
					buff.duration:Hide();
				end
				
				local timeLeft = (expirationTime - GetTime());
				buff.timeMod = timeMod; 
				if(timeMod > 0) then
					timeLeft = timeLeft / timeMod;
				end

				if ( not buff.timeLeft ) then
					buff.timeLeft = timeLeft;
					buff:SetScript("OnUpdate", AuraButton_OnUpdate);
				else
					buff.timeLeft = timeLeft;
				end

				buff.expirationTime = expirationTime;
			else
				buff.duration:Hide();
				
				if ( buff.timeLeft ) then
					buff:SetScript("OnUpdate", nil);
				end
				buff.timeLeft = nil;
			end

			

			-- Set Texture
			local icon = _G[buffName.."Icon"];
			icon:SetTexture(texture);

			-- Set the number of applications of an aura
			if ( count > 1 ) then
				buff.count:SetText(count);
				buff.count:Show();
			else
				buff.count:Hide();
			end

			-- Refresh tooltip
			if ( GameTooltip:IsOwned(buff) ) then
				effect.effect:updateTooltip(buff);
			end
		end
		return 1;


	end

	function Effect:UpdateAllBuffAnchors()

		Effect.refreshBuffs() -- Makes sure enough frames exist

		local buff, previousBuff, aboveBuff, index;
		local numBuffs = 0;
		local numAuraRows = 0;
		local slack = BuffFrame.numEnchants;
		
		for i = 1, BUFF_ACTUAL_DISPLAY+getNumBuffs(false) do
			buff = _G["BuffButton"..i];
			numBuffs = numBuffs + 1;
			index = numBuffs + slack;
			if ( buff.parent ~= BuffFrame ) then
				buff.count:SetFontObject(NumberFontNormal);
				buff:SetParent(BuffFrame);
				buff.parent = BuffFrame;
			end
			buff:ClearAllPoints();

			if ( (index > 1) and (mod(index, BUFFS_PER_ROW) == 1) ) then
				-- New row
				numAuraRows = numAuraRows + 1;
				buff:SetPoint("TOP", aboveBuff, "BOTTOM", 0, -BUFF_ROW_SPACING);
				aboveBuff = buff;
			elseif ( index == 1 ) then
				numAuraRows = 1;
				buff:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0);
				aboveBuff = buff;
			else
				if ( numBuffs == 1 ) then
					if ( BuffFrame.numEnchants > 0 ) then
						buff:SetPoint("TOPRIGHT", "TemporaryEnchantFrame", "TOPLEFT", BUFF_HORIZ_SPACING, 0);
					else
						buff:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0);
					end
				else
					buff:SetPoint("RIGHT", previousBuff, "LEFT", BUFF_HORIZ_SPACING, 0);
				end
			end
			previousBuff = buff;
		end

		-- check if we need to manage frames
		local bottomEdgeExtent = BUFF_FRAME_BASE_EXTENT;
		if ( DEBUFF_ACTUAL_DISPLAY+getNumBuffs(true) > 0 ) then
			bottomEdgeExtent = bottomEdgeExtent + DebuffButton1.offsetY + BUFF_BUTTON_HEIGHT + ceil((DEBUFF_ACTUAL_DISPLAY+getNumBuffs(true)) / BUFFS_PER_ROW) * (BUFF_BUTTON_HEIGHT + BUFF_ROW_SPACING);
		else
			bottomEdgeExtent = bottomEdgeExtent + numAuraRows * (BUFF_BUTTON_HEIGHT + BUFF_ROW_SPACING);
		end
		if ( BuffFrame.bottomEdgeExtent ~= bottomEdgeExtent ) then
			BuffFrame.bottomEdgeExtent = bottomEdgeExtent;
			UIParent_ManageFramePositions();
		end
	end

	function Effect:onRightClick()
		if self.ewID then

			local obj = Effect.applied[self.ewID]
			if not obj then return end

			local allow = false
			if type(obj.effect.onRightClick) == "function" then
				local call = obj.effect:onRightClick(obj)
				if call == false then 
					-- Prevent right click of beneficial spell
					return
				elseif call == true then
					-- Can be used to right click a detrimental spell
					allow = true
				end
			end
			if obj.effect.detrimental and not allow then return end
			
			Effect.rem(self.ewID)
		end 
	end

	-- Improves the frames
	function Effect.onLoad()
		local fxFrame = CreateFrame("Frame");
		hooksecurefunc("BuffFrame_Update", function()
			Effect:UpdateAllBuffAnchors()
		end)

		-- Right click an EWID
		hooksecurefunc("BuffButton_OnClick", Effect.onRightClick)

		hooksecurefunc("AuraButton_OnUpdate", function(self)
			if self.ewID and Effect.applied[self.ewID] then
				if ( GameTooltip:IsOwned(self) ) then
					Effect.applied[self.ewID].effect:updateTooltip(self);
				end
			end
		end)
	end

	-- Passives
	function Effect.updatePassives()
		-- Start with visuals
		local preVisuals = Effect.passives[EffectPassive.Types.Visual];
		if not preVisuals then preVisuals = {} end
		local postVisuals = {};

		-- Stack the effects
		for _,effect in pairs(Effect.applied) do
			for _,passive in pairs(effect.effect.passives) do
				if passive.type == EffectPassive.Types.Visual then
					postVisuals[passive.data.id] = true;
				end
			end
		end

		local added, removed = Tools.tableCompare(postVisuals, preVisuals);
		for k,_ in pairs(added) do
			Visual.get(k):trigger(true);
		end
		for k,_ in pairs(removed) do
			Visual.get(k):fade();
		end

		Effect.passives[EffectPassive.Types.Visual] = postVisuals;
	end

	-- Triggers a visual unless it's already in a duration effect
	function Effect.triggerVisual(id)
		-- This effect is already active through a long term effect
		if Effect.passives[EffectPassive.Types.Visual] and Effect.passives[EffectPassive.Types.Visual][id] then
			return;
		end
		Visual.get(id):trigger();
	end




export(
	"Effect",
	Effect,
	{
		EffectPassive = EffectPassive,
		run = Effect.run,
		triggerVisual = Effect.triggerVisual,
		rem = Effect.rem,
		get = Effect.get,
		remByID = Effect.remByID,
		remByTags = Effect.remByTags,
		remByTagsNotThis = Effect.remByTagsNotThis,
	},
	Effect
)
