local appName, internal = ...
local require = internal.require;

function internal.build.quests()

	local Func = require("Func");
	local Quest = require("Quest");
	local Objective = Quest.Objective;
	local Reward = Quest.Reward;
	local ext = internal.ext;
	local Event = require("Event");

	-- Test quest
	ext:addQuest({
		id = "SHOCKTACLE",
		name = "Shocktacle",
		start_text = {"You found a still squirming lightning tentacle on the bog strider.", "Maybe you could use the other bogstriders to recharge it?"},
		journal_entry = "You have found a barely squirming lightning tentacle on a bog strider in Zangarmarsh.\n\nPerhaps if you were to charge it by getting hit by additional lightning tethers, it could make for an interesting toy?",
		--end_journal = "",
		end_text = {"Your lightning tentacle is fully charged."},
		questgiver = 17781,
		rewards = {
			Reward:new({
				id = "SHOCKTACLE",
				type = "Charges",
				quant = math.huge
			})
		},
		objectives = {
			Objective:new({
				id = "tether",
				name = "Lightning tentacle charge",
				num = 6,				-- Num of name to do to complete it
				onObjectiveEnable = function(self) 
					self.data.spellTracker = Event.on(Event.Types.SPELL_ADD, function(data)
						if data.aura.name == "Lightning Tether" then
							self:add(1);
						end
					end);
				end,		-- Raised when objective is activated
				onObjectiveDisable = function(self) 
					if self.data.spellTracker then
						Event.off(self.data.spellTracker);
					end
				end	-- Raised when objective is completed or disabled
			}),		
		},		-- You can wrap objectives in {} to create packages
		start_events = {
			{
				event = Event.Types.MONSTER_KILL,
				fn = function(self, data)
					if data.name == "Fen Strider" then
						return true;
					end
				end
			}
		}
	});


end