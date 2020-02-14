local appName, internal = ...
local Module = {};
internal.Module = Module;
Module.modules = {};

-- Class definition
function Module.export(cName, classdef, pub, pvt)
	if Module.modules[cName] then return; end

	-- Automatic methods
	local pubDefaults = {"new"}
	local pvtDefaults = {"ini"}

	local private = type(pvt) == "table" and pvt or {}
	local public = type(pub) == "table" and pub or classdef

	public.new = classdef.new
	private.ini = classdef.ini

	Module.modules[cName] = {
		["required"] = false,
		["public"] = public,
		["private"] = private
	}
end

-- This one is exposed to the public
function Module.require(cName)
	
	if not Module.modules[cName] then
		print("ERROR: No module of name", cName)
		return
	end

	local out = {}
	if 
		Module.modules[cName] and 
		type(Module.modules[cName].public) == "table" 
	then
		for k,v in pairs(Module.modules[cName].public) do
			out[k] = v;
		end
		if not Module.modules[cName].required then
			Module.modules[cName].required = true;

			if 
				Module.modules[cName].private and 
				type(Module.modules[cName].private.ini) == "function" 
			then
				Module.modules[cName].private.ini();
			end
		end
	end
	return out;
end

-- This one is only exposed internally
function internal.require(cName)
	local out = Module.require(cName);
	-- Add private as well
	if 
		Module.modules[cName] and 
		type(Module.modules[cName].private) == "table" 
	then
		for k,v in pairs(Module.modules[cName].private) do
			out[k] = v;
		end
	end
	return out;
end
