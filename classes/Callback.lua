local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;
local Timer;

-- Callback system
local Callback = {};	
	Callback.ini = function()
		Timer = require("Timer");
	end
	Callback.WAITING = {}; -- {id:str token, timer:int timer, callback:fn callback}

	-- Adds a callback listener and returns the callback token
	function Callback.add(fn)
		local token = Callback.generateToken();
		
		-- Give it 1 sec
		local timer = Timer.set(function()
			Callback.trigger(token, false);
		end, 1);
		
		table.insert(Callback.WAITING, {
			callback = fn,
			id = token,
			timer = timer
		});
		return token;
	end

	function Callback.remove(token)
		for k,v in pairs(Callback.WAITING) do
			if v.id == token then
				Timer.clear(v.timer);
				Callback.WAITING[k] = nil;
				return;
			end
		end
	end

	function Callback.generateToken()
		local token = string.gsub("xxxxxx", '[x]', function (c)
			local out = string.format('%x', math.random(0, 0xf))
			return out
		end)
		return token;
	end

	function Callback.trigger(token, success, args, sender)
		for k,v in pairs(Callback.WAITING) do
			if v.id == token then
				if type(v.callback) == "function" then
					v:callback(success, args, sender);
				end
				Callback.remove(token);
				return;
			end
		end
	end

export(
	"Callback", 
	Callback,
	{
		add = Callback.add,
		remove = Callback.remove,
		trigger = Callback.trigger
	},
	{
		generateToken = Callback.generateToken
	}
)
