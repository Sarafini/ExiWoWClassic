local appName, internal = ...
local require = internal.require;

function internal.Gateway()

	local Event = require("Event");
	local Character = require("Character");
	local RPText = require("RPText");
	local Spell = require("Spell");
	local Loot = require("Loot");
	local Action = require("Action");
	local Database = require("Database");
	local Timer = require("Timer");
	local Index = require("Index");
	local Condition = require("Condition");

	-- Swing
	local function onSwing(unit, sender, crit)
		--print("Checking hardlimits on swing, sender", sender, Index.checkHardLimits(sender, "player", false));
		if not Index.checkHardLimits(sender, "player", true) then return end

		local chance = globalStorage.swing_text_freq;
		if crit ~= "" then 
			chance = chance*4;
		end -- Crits have 3x chance for swing text

		
		local rand = math.random();
		--print("Swing. Crit: "..crit.." chance "..chance.." rand "..rand);
		if not RPText.getTakehitCD() and rand < chance and unit and not UnitIsPlayer(unit) then

			-- id, senderUnit, receiverUnit, senderChar, receiverChar, eventData, event, action
			local npc = Character.buildNPC(unit, sender);
			local rp = RPText.get(Event.Types.SWING..crit, unit, "player", npc, ExiWoW.ME, nil, Event.Types.SWING..crit);
			if rp then
				RPText.setTakehitTimer();
				rp:convertAndReceive(npc, ExiWoW.ME)
			end
		end

	end
	Event.on(Event.Types.SWING, function(data)
		onSwing(data.unit, data.name, "");
	end);
	Event.on(Event.Types.SWING_CRIT, function(data)
		onSwing(data.unit, data.name, "_CRIT");
	end);


	-- See buildSpellTrigger in Event for aura
	-- name is the name of the unit
	local function onSpell(event, aura, unit, name)
		if not Index.checkHardLimits(unit, "player", true) then return end

		local chance = 1;
		if event == Event.SPELL_TICK then
			chance = 0.05;
		end
		chance = chance*globalStorage.spell_text_freq;
		
		local npc = Character.buildNPC(unit, name);
		local eventData = RPText.buildSpellData(aura.spellId, aura.name, aura.harmful, npc.name, aura.count, aura.crit);

		

		-- See if this spell was bound at all
		local spells = Spell.filter(aura.name, unit, "player", npc, ExiWoW.ME, eventData, event);
		local all = Database.getIDs("Spell", aura.name);
		for _,sp in pairs(all) do
			if type(sp.onTrigger) == "function" then
				sp:onTrigger(event, unit, "player", npc, ExiWoW.ME);
			end
		end
		for _,sp in pairs(spells) do
			if type(sp.onAccepted) == "function" then
				sp:onAccepted(event, unit, "player", npc, ExiWoW.ME);
			end
		end

		-- Trigger random RP texts
		local spell = spells[1];
		if spell and not RPText.getTakehitCD() and math.random() < chance*spell.chanceMod then
			eventData.tags = spell:exportTags();
			local name = aura.name;
			if spell.alias then
				name = spell.alias;
			end

			local rp = RPText.get(name, unit, "player", npc, ExiWoW.ME, eventData, event);
			if rp then
				RPText.setTakehitTimer();
				rp:convertAndReceive(npc, ExiWoW.ME, false, eventData);
			end
		end

	end
	Event.on(Event.Types.SPELL_ADD, function(data) onSpell(Event.Types.SPELL_ADD, data.aura, data.unit, data.name); end);
	Event.on(Event.Types.SPELL_REM, function(data) onSpell(Event.Types.SPELL_REM, data.aura, data.unit, data.name); end);
	Event.on(Event.Types.SPELL_TICK, function(data) onSpell(Event.Types.SPELL_TICK, data.aura, data.unit, data.name); end);
	Event.on(Event.Types.SPELL_RAN, function(data) onSpell(Event.Types.SPELL_RAN, data.aura, data.unit, data.name); end);
	


	local function rollLoot(event, npcName, eventData)
		
		local npc = Character.buildNPC("none", npcName);
		
		---- senderUnit, receiverUnit, senderChar, receiverChar, eventData, event, action
		local available = Loot.filter("none", "player", npc, ExiWoW.ME, eventData, event, Action.get("FORAGE"));

		--print("Rolling loot with", event, npc.name, "found", #available);
		local out = {};

		for _,loot in pairs(available) do
			for _,item in pairs(loot.items) do
				
				local chance = 1
				if item.chance then chance = item.chance end

				if math.random() < chance then

					local quant = item.quant;
					if not quant or quant < 1 then quant = 1 end

					if type(item.quantRand) == "number" and item.quantRand > 0 then
						quant = quant+math.random(item.quantRand+1)-1;
					end

					local added = ExiWoW.ME:addItem(item.type, item.id, quant);
					if added then
						-- RP text
						if item.text then 
							item.text.item = added.name;
							item.text:convertAndReceive(npc, ExiWoW.ME, false, nil, function(text)
								text = string.gsub(text, "%%Qs", quant ~= 1 and "s" or "")
								text = string.gsub(text, "%%Q", quant)
								return text
							end);
						end
						if item.sound then PlaySound(item.sound, "Dialog") end
						table.insert(out, item);

						if event == Event.Types.FORAGE then
							return out;
						end
					end
				end
			end
		end

		if #out > 0 then return out end
		return false

	end
	Event.on(Event.Types.MONSTER_KILL, function(data)
		if not Index.checkHardLimits("player", "player", true) then return end
		
		rollLoot(Event.Types.MONSTER_KILL, data.name); 
		RPText.trigger(nil, data.name, "player", Character.buildNPC("none", data.name), ExiWoW.ME, {}, Event.Types.MONSTER_KILL);
	end);
	Event.on(Event.Types.FORAGE, function(data) 
		if not rollLoot(Event.Types.FORAGE, data.name) then
			PlaySound(1142, "Dialog")
			RPText.print("You found nothing");
		end
	end);

	-- World containers
	local scanned_containers = {};
	Event.on(Event.Types.CONTAINER_OPENED, function(data)
		if not Index.checkHardLimits("player", "player", true) then return end

		--print("Container opened", ExiWoW.json.encode(data));
		for i=1, GetNumLootItems() do
			local items = {GetLootSourceInfo(i)};
			--print("Item", i, GetLootSlotInfo(i))
			--print("Sources", GetLootSourceInfo(i));
			for k,v in ipairs(items) do
				if k%2 == 1 then
					if not scanned_containers[v] then
						scanned_containers[v] = true;
						Timer.set(function()
							scanned_containers[v] = nil;
						end, 300);
						rollLoot(Event.Types.CONTAINER_OPENED, data.container, data);
					end
				end
			end
		end
	end);


end
