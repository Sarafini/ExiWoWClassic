local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local Timer = {}

	function Timer.ini()
	end

	-- Use math.huge for infinite times
	function Timer.set(callback, seconds, times)

		if type(callback) ~= "function" then
			print("Can't set timer, callback invalid", callback);
			return false
		end

		return C_Timer.NewTicker(seconds or 1, callback, times or 1);

	end

	function Timer.clear(timer)
		if type(timer) ~= "table" then 
			return;
		end
		timer:Cancel();
	end


export(
	"Timer", 
	Timer,
	{
		set = Timer.set,
		clear = Timer.clear
	}
)
