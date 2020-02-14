local appName, internal = ...
local require = internal.require;

function internal.build.effects()

	local Func = require("Func");
	local Effect = require("Effect");
	local Passive = Effect.EffectPassive;
	local ext = internal.ext;
	
	--
	ext:addEffect({
		id = "MORTAS_ARACHNID_SCEPTER",
		detrimental = true,
		duration = 15,
		ticking = 1,
		max_stacks = 1,
		texture = "Interface/Icons/trade_archaeology_nerubianspiderscepter",
		name = "Spider Hex",
		description = "You feel as if hundreds of little spiders are skittering across your body!",

		onAdd = function()
			Func.get("toggleVibHubProgram")("SMALL_TICKLE_RANDOM", 15);
			PlaySound(5694, "SFX");
			DoEmote("GIGGLE", "player");
		end,
		onRemove = function()
			Func.get("toggleVibHubProgram")("SMALL_TICKLE_RANDOM");
		end,
		onTick = function()
			ExiWoW.ME:addExcitement(0.025);
		end
	});

	-- /run ExiWoW.require("Effect").run("TEST_VISUAL");
	ext:addEffect({
		id = "TEST_VISUAL",
		detrimental = false,
		duration = 3,
		max_stacks = 1,
		texture = "Interface/Icons/trade_archaeology_nerubianspiderscepter",
		name = "Test",
		description = "This is a visual effect test!",
		passives = {
			Passive:new({
				type = Passive.Types.Visual,
				data = {id="heavyExcitement"}
			})
		},
		onAdd = function()
			print("OnAdd");
		end,
		onRemove = function()
			print("OnRemove");
		end,
	});


	-- Accepts data {target=followTarget}
	-- /run ExiWoW.require("Effect").run("FOLLOW_6_SEC", 1, false, {target="Lazziere"});
	ext:addEffect({
		id = "FOLLOW_6_SEC",
		detrimental = true,
		duration = 6,
		max_stacks = 1,
		texture = "Interface/Icons/spell_shadow_shadowworddominate",
		name = "Allure",
		description = "You obey!",
		onAdd = function(self)
			local function tick()
				FollowUnit(self.customData.target);
			end
			self:setTimer(tick, 0.05, math.huge);
			tick();
		end,
		onRemove = function()
			FollowUnit("player");
		end
	});


end