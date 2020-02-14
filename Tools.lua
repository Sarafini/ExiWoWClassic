local appName, internal = ...
local export = internal.Module.export;

local Tools = {};

	-- Error/notice frame
	function Tools.reportError(message, ignore)
		if ignore then return false, message end
		UIErrorsFrame:AddMessage(message, 1.0, 0.0, 0.0, 53, 6);
		return false, message;
	end

	function Tools.reportNotice(message)
		UIErrorsFrame:AddMessage(message, 0.5, 1.0, 0.5, 53, 6);
		return true;
	end


	-- Tools
	-- Replaces unit with YOU if it's you
	function Tools.unitRpName(unit)
		unit = Ambiguate(unit, "all")
		if UnitIsUnit(unit, "player") then return "YOU" end
		return unit;
	end

	-- Searches name in acceptable {name=true, name2=true...}, if acceptable is nil, then it's a wildcard
	-- If name is not a string, then it's false
	function Tools.multiSearch(name, acceptable)
		if acceptable == nil then 
			return true; 
		end
		if type(name) ~= "string" then 
			return false;
		end
		local itm = {}
		if type(acceptable) ~= "table" then 
			itm[acceptable] = true;
		else 
			itm = acceptable;
		end
		for v,_ in pairs(itm) do
			if type(v) ~= "string" then 
				for vv, vk in pairs(itm) do 
					print(vv, vk) 
				end
			end
			if name == v or (v:sub(1,1) == "%" and name:find(v:sub(2))) then 
				return true;
			end				
		end
		return false
	end

	-- Formats a timestamp
	function Tools.timeFormat(seconds)
		if seconds > 3600 then return tostring(math.ceil(seconds/3600)).." Hr" end
		if seconds > 60 then return tostring(math.ceil(seconds/60)) .. " Min" end
		return tostring(math.ceil(seconds)).." Sec"
	end

	-- Creates a set like {name, name2...} => {name=true, name2=true...}
	function Tools.createSet(list)
		local set = {}
		if type(list) ~= "table" then list = {list} end
		for _, l in pairs(list) do 
			set[l] = true 
		end
		return set
	end

	-- Turns an item slot id to a name
	function Tools.itemSlotToname(slot)
		local all_slots = {}
		all_slots[1] = "head armor"
		all_slots[3] = "shoulder armor"
		all_slots[4] = "shirt"
		all_slots[5] = "chestpiece"
		all_slots[6] = "belt"
		all_slots[7] = "pants"
		all_slots[8] = "boots"
		all_slots[10] = "gloves"
		all_slots[15] = "cloak"
		all_slots[19] = "tabard"
		return all_slots[slot]
	end

	function Tools.concat(...)
		local out = {};
		local input = {...};
		for _,i in pairs(input) do
			if type(i) ~= "table" then
				i = {i};
			end
			for _,v in pairs(i) do
				table.insert(out, v);
			end
		end
		return out;
	end

	-- Compares the root keys of a table, returning two tables: addedKeys, removedKeys
	function Tools.tableCompare(post, pre)
		local addedValues = {};
		local removedValues = {};

		-- Find added values
		for k,_ in pairs(post) do
			if not pre[k] then
				addedValues[k] = true;
			end
		end
		-- Get removed values
		for k,_ in pairs(pre) do
			if not post[k] then
				removedValues[k] = true;
			end
		end
		
		return addedValues, removedValues;

	end


export("Tools", Tools)
