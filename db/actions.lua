local appName, internal = ...
local require = internal.require;

-- Library for Actions --
function internal.build.actions()

	local Action = require("Action");
	local Character = require("Character");
	local Tools = require("Tools");
	local UI = require("UI");
	local RPText = require("RPText");
	local Event = require("Event");
	local Condition = require("Condition");
	local Func = require("Func");
	local Effect = require("Effect");
	local extension = internal.ext;
	

			-- LIBRARY --

	-- Meta action that checks if target has ExiWoW --
	extension:addAction({
		id = "A",
		global_cooldown = false,
		suppress_all_errors = true,
		hidden = true,
		conditions = {},
		not_defaults = {
			"party_restricted",
			"not_stunned",
			"not_in_instance",
			"sender_alive",
			"victim_alive",
			"not_in_vehicle"
		},
		-- Custom sending logic
		fn_send = function(self, sender, target, suppressErrors)
			ExiWoW.TARGET = nil

			-- Return no data, but one callback
			return nil, function(se, success, data, sender)
				if not success then return end
				sender = Ambiguate(sender, "all")
				if success and UnitIsUnit(sender, "target") then
					ExiWoW.TARGET = Character:new(data, sender);
					local offset = 0;
					if ExiWoW.TARGET:isFemale() then offset = 0.25;
					elseif not ExiWoW.TARGET:isMale() then offset = 0.5; end
					UI.portrait.targetHasExiWoWFrame.genderTexture:SetTexCoord(offset,offset+0.25,0,1);
					UI.portrait.targetHasExiWoWFrame:Show();
				end
			end
		end,
		-- Handle the receiving end here
		fn_receive = function(self, sender, target, data)
			return true, ExiWoW.ME:export(true)
		end

	})

	-- Test action
	extension:addAction({
		id = "TEST_ACTION",
		name = "Test Item",
		texture = "achievement_worldevent_littlehelper",
		conditions = {
			Condition.get("debug_fail_on_receive")
		},
		max_charges = 100,
		charges = 0,
		-- Custom sending logic
		fn_send = function(self, sender, target, suppressErrors)
			print("TestAction Send")
			return nil, function(se, success, data)
				print("Test task was", success);
			end
		end,
		-- Handle the receiving end here
		fn_receive = function(self, sender, target, data)
			print("TestAction Receive")
			return false, "An error occurred"
		end

	})

	-- Disrobe --
	extension:addAction({
		id = "DISROBE",
		name = "Disrobe",
		description = "Removes a piece of armor from your target.",
		texture = "ability_rogue_plunderarmor",
		cooldown = 120,
		cast_time = 2,
		cast_sound_loop = 6425,				-- Tailoring, see http://www.wowhead.com/sound=6425/tailoring
		conditions = {
			Condition.get("require_stealth"),
			Condition.get("victim_no_combat"),
			Condition.get("sender_no_combat"),
			Condition.get("require_party"),
			Condition.get("sender_not_moving"),
			Condition.get("melee_range"),
		},
		not_defaults = {},

		-- allow_self = false,
		fn_cast = function(self, sender, target, suppressErrors)
			DoEmote("KNEEL", target);
		end,
		-- Custom sending logic
		fn_send = function(self, sender, target, suppressErrors)

			-- Return no data, but one callback
			return nil, function(se, success, data)
				if not success then
					if data and data[1] then Tools.reportError(data[1], suppressErrors); end
					self:resetCooldown();
				else
					PlaySound(1202, "SFX");
					RPText.print(
						Tools.unitRpName(sender) .. " successfully removed "..
						Ambiguate(UnitName(target), "all").."'s "..
						Tools.itemSlotToname(data.slot).."!"
					);
				end
			end
		end,
		-- Handle the receiving end here
		fn_receive = function(self, sender, target, suppressErrors)
			local all_slots = {
				1, -- Head
				3, -- Shoulder
				4, -- Shirt
				5, -- Chest
				6, -- Belt
				7, -- Pants
				8, -- Boots
				10, -- Gloves
				15, -- Cloak
				19 -- Tabard
			}
			local equipped_slots = {};
			for k,v in pairs(all_slots) do
				local item = GetInventoryItemID(target, v)
				local transmog, _, _, _, _, _, hidden = C_Transmog.GetSlotInfo(v, 0);
				if item ~= nil and not hidden then
					table.insert( equipped_slots, v )
				end
			end

			if next(equipped_slots) == nil then
				return false, {Ambiguate(UnitName("player"), "all") .. " has no strippable slots!"}
			end

			local slot = equipped_slots[ math.random( #equipped_slots ) ];
			Character:removeEquipped(slot);
			RPText.print(Tools.unitRpName(sender) .. " tugged off your "..Tools.itemSlotToname(slot).."!");
			if not UnitIsUnit(Ambiguate(sender, "ALL"), "player") then 
				PlaySound(1202, "SFX");
			end
			return true, {slot=slot}
		end

	})

	-- meditate --
	extension:addAction({
		id = "MEDITATE",
		name = "Meditate",
		description = "Meditate for a while, allowing your excitement to fade at a greatly increased rate.",
		texture = "monk_ability_transcendence",
		cooldown = 0,
		important = true,
		conditions = {
			Condition.get("sender_no_combat"),
			Condition.get("sender_not_moving"),
			Condition.get("only_selfcast"),
		},
		not_defaults = {},
		-- Handle the receiving end here
		fn_receive = function(self, sender, target, suppressErrors)

			if ExiWoW.ME.meditating then
				return Tools.reportError("You are already meditating!");
			end

			-- Start meditation --
			DoEmote("SIT");
			ExiWoW.ME.meditating = true;
			ExiWoW.ME:toggleResting(true)
			Event.on("PLAYER_STARTED_MOVING", function()
				ExiWoW.ME:toggleResting(false)
				ExiWoW.ME.meditating = false;
			end, 1);
			return true

		end
	})

	-- Spot excitement (Public, melee range) --
	extension:addAction({
		id = "ASSESS",
		name = "Assess",
		important = true,
		description = "Take a good look at your target, revealing some information about them.",
		texture = "inv_darkmoon_eye",
		cooldown = 0,
		conditions = {
			Condition.get("caster_range"),
		},
		not_defaults = {
			"party_restricted"
		},
		fn_send = function(self, sender, target, suppressErrors)
			-- We only need a callback for this
			DoEmote("eye", "target");
			return nil, function(se, success, data) Action.handleInspectCallback(target, success, data) end
		end,
		fn_receive = function()
			return true, ExiWoW.ME:export(true)
		end
	});

	-- Sniff (Worgen) --
	extension:addAction({
		id = "SNIFF",
		name = "Sniff",
		description = "Sniff out some information about your target from a distance.",
		texture = "inv_wolfdraenormountshadow",
		cooldown = 0,
		filters = {
			Condition:new({type=Condition.Types.RTYPE_RACE, data={Worgen=true}, sender=true})
		},
		not_defaults = {
			"party_restricted",
		},
		fn_send = function(self, sender, target, suppressErrors)
			DoEmote("SNIFF", target);
			-- Callback
			return nil, function(se, success, data) Action.handleInspectCallback(target, success, data) end
		end,
		fn_receive = function()
			return true, ExiWoW.ME:export(true)
		end
	});

	-- Tickle --
	extension:addAction({
		id = "TICKLE",
		name = "Tickle",
		description = "Tickle a player.",
		texture = "Spell_shadow_fingerofdeath",
		cooldown = 30,
		conditions = {
			Condition.get("melee_range"),
		},
		not_defaults = {},
		fn_send = function(self, sender, target, suppressErrors)
			if not UnitIsUnit(target, "player") then 
				DoEmote("TICKLE", target);
			end
			return self:sendRPText(sender, target, suppressErrors);
		end,
		fn_receive = function(self, sender, target, args)
			DoEmote("GIGGLE", target);
			return self:receiveRPText(sender, target, args);
		end
	});

	-- Wedgie --
	extension:addAction({
		id = "WEDGIE",
		name = "Wedgie",
		description = "Give a player a wedgie, provided they're wearing underwear.",
		texture = "Spell_holy_fistofjustice",
		cooldown = 20,
		conditions = {
			Condition.get("targetWearsUnderwear"),
			Condition.get("melee_range"),
		},
		no_defaults = {
			"party_restricted"
		},
		fn_send = function(self, sender, target, suppressErrors)
			local race = UnitRace(target)
			local gender = UnitSex(target)
			return self:sendRPText(sender, target, suppressErrors, function(se, success)
					if success and not UnitIsUnit(target, "player") then
					Func.get("painSound")(self, race, gender)
				end
			end);
		end,
		fn_receive = function(self, sender, target, args)
			DoEmote("GASP");
			Func.get("addExcitementMasochistic")();
			return self:receiveRPText(sender, target, args);
		end
	});

	-- Forage --
	extension:addAction({
		id = "FORAGE",
		name = "Forage",
		description = "Search your active area for items.",
		texture = "icon_treasuremap",
		cooldown = 0,
		cast_sound_loop = 1104,
		cast_time = 3,
		conditions = {
			Condition.get("only_selfcast"),
			Condition.get("sender_not_moving"),
		},
		not_defaults = {
			"not_in_vehicle",
			"not_stunned"
		},
		fn_cast = function(self, sender, target, suppressErrors)
			DoEmote("KNEEL", target);
		end,
		fn_send = function(self, sender, target, suppressErrors)
			return nil;
		end,
		fn_receive = function(self, sender, target, args)
			Event.raise(Event.Types.FORAGE, {});
			return true
		end
	});

	-- Pace --
	extension:addAction({
		id = "PACE",
		name = "Pace",
		description = "First use: Stake a starting point. Second use: Get the distance from the starting point, measured in map coordinates.",
		texture = "ability_tracking",
		cooldown = 0,
		conditions = {
			Condition.get("only_selfcast"),
		},
		not_defaults = {},
		fn_send = function(self, sender, target, suppressErrors)
			return nil;
		end,
		fn_receive = function(self, sender, target, args)

			local mapID = C_Map.GetBestMapForUnit("player");
			local pos = C_Map.GetPlayerMapPosition(mapID,"player");
			local px,py = pos:GetXY();
			px = px*100
			py = py*100

			if self.starting_point then
				local x = self.starting_point.x
				local y = self.starting_point.y
				local dist = math.floor(math.sqrt((px-x)*(px-x)+(py-y)*(py-y))*100)/100
				self.starting_point = nil
				RPText.print("You are comfortable that you paced a distance of "..dist.." units")
				PlaySound(73276, "SFX")
			else
				self.starting_point = {x=px, y=py}
				PlaySound(42485, "SFX")
				RPText.print("You stake a starting point at X:"..(math.floor(px*100)/100)..", Y:"..(math.floor(py*100)/100))
			end
			return true
			
		end
	});


	-- Arachnid scepter
	extension:addAction({
		id = "MORTAS_ARACHNID_SCEPTER",
		name = "Morta's Arachnid Scepter",
		description = "Hex your target, making them feel as if hundreds of little spiders are skittering across their body.",
		charges = 0,
		texture = "trade_archaeology_nerubianspiderscepter",
		cast_sound_success = 5419,
		rarity = 3,
		cooldown = 300, --300
		conditions = {
			Condition.get("caster_range"),
		},
		fn_send = function(self, sender, target, suppressErrors)
			return self:sendRPText(sender, target, suppressErrors);
		end,
		fn_receive = function(self, sender, target, args)
			local ef = Effect.get(self.id);
			ef:add(1);
			return self:receiveRPText(sender, target, args);
		end
	});

	-- Shocktacle
	extension:addAction({
		id = "SHOCKTACLE",
		name = "Shocktacle",
		description = "A lightning tentacle taken off a Fen Strider. Use it to lash your target.",
		charges = 0,
		texture = "ability_thunderking_lightningwhip",
		rarity = 3,
		cooldown = 30,
		conditions = {
			Condition.get("melee_range"),
		},
		no_defaults = {
			"party_restricted"
		},
		fn_send = function(self, sender, target, suppressErrors)
			local race = UnitRace(target);
			local gender = UnitSex(target);
			return self:sendRPText(sender, target, suppressErrors, function(se, success)
				if success and not UnitIsUnit(target, "player") then
					Func.get("painSound")(self, race, gender)
					PlaySound(21455, "SFX");
				end
			end);
		end,
		fn_receive = function(self, sender, target, args)
			DoEmote("whine", Ambiguate(sender, "all"));
			Func.get("addExcitementMasochisticCrit")();
			PlaySound(21455, "SFX");
			return self:receiveRPText(sender, target, args);
		end
	});






	-- Consumable --

	-- Throw sand
	extension:addAction({
		id = "THROW_SAND",
		name = "Sand",
		description = "Throw sand at your target.",
		max_charges = 10,
		charges = 0,
		texture = "spell_sandexplosion",
		cooldown = 0,
		cast_time = 0.5,
		fn_send = function(self, sender, target, suppressErrors)
			local race = UnitRace(target)
			local gender = UnitSex(target)
			return self:sendRPText(sender, target, suppressErrors, function(se, success)
				if success and not UnitIsUnit(target, "player") then
					Func.get("painSound")(self, race, gender)
				end
			end);
		end,
		fn_receive = function(self, sender, target, args)
			Func.get("addExcitementMasochistic")();
			return self:receiveRPText(sender, target, args)
		end
	});

	-- /run ExiWoW.ME:addItem("Charges", "SWAMP_MUCK", 10);
	extension:addAction({
		id = "SWAMP_MUCK",
		name = "Swamp Muck",
		description = "Throw some gooey muck at your target.",
		max_charges = 10,
		charges = 0,
		texture = "Inv_misc_food_legion_gooslime_multi",
		cooldown = 0,
		cast_time = 0.5,
		fn_send = function(self, sender, target, suppressErrors)
			local race = UnitRace(target);
			local gender = UnitSex(target);
			return self:sendRPText(sender, target, suppressErrors, function(se, success)
				if success and not UnitIsUnit(target, "player") then
					Func.get("painSound")(self, race, gender);
				end
			end);
		end,
		fn_receive = function(self, sender, target, args)
			Func.get("addExcitementMasochistic")();
			return self:receiveRPText(sender, target, args);
		end
	});

	-- Calming potion
	extension:addAction({
		id = "CALMING_POTION",
		name = "Calming Potion",
		description = "Instantly clears your excitement.",
		max_charges = 100,
		charges = 0,
		texture = "inv_potion_68",
		cooldown = 0,
		cast_time = 0,
		conditions = {
			Condition.get("is_self"),
		},
		not_defaults = {},
		fn_receive = function(self, sender, target, args)
			DoEmote("drink", "player");
			PlaySound(3373, "SFX");
			ExiWoW.ME:addExcitement(0, true);
			return true
		end
	});

	-- Claw pinch
	extension:addAction({
		id = "CLAW_PINCH",
		name = "Claw Pinch",
		description = "Use your large claw to pinch your target.",
		charges = 0,
		texture = "inv_misc_claw_lobstrok_red",
		cooldown = 0,
		fn_send = function(self, sender, target, suppressErrors)
			local race = UnitRace(target)
			local gender = UnitSex(target)
			return self:sendRPText(sender, target, suppressErrors, function(se, success)
				if success and not UnitIsUnit(target, "player") then
					Func.get("painSound")(self, race, gender)
				end
			end);
		end,
		fn_receive = function(self, sender, target, args)
			Func.get("addExcitementMasochistic")();
			return self:receiveRPText(sender, target, args);
		end
	});
	


	-- Classes --

	-- Priest - Allure
	extension:addAction({
		id = "ALLURE",
		name = "Allure",
		description = "Forces your target to follow you for 5 seconds.",
		texture = "spell_shadow_shadowworddominate",
		cooldown = 90,
		conditions = {
			Condition.get("caster_range"),
			Condition.get("sender_no_combat"),
			Condition.get("victim_no_combat"),
			Condition.get("require_party"),
			Condition.get("no_selfcast")
		},
		filters = {
			Condition:new({
				type = Condition.Types.RTYPE_CLASS,
				data = {Priest=true},
				sender = true
			}),
		},
		not_defaults = {},
		fn_send = Action.sendRPText,
		fn_receive = function(self, sender, target, args)
			sender = Ambiguate(sender, "all");
			if UnitExists(Ambiguate(sender, "all")) then
				Effect.run("FOLLOW_6_SEC", 1, false, {target=sender});
				return self:receiveRPText(sender, target, args);
			end
			return false;
		end
	});

end