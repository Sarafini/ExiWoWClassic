local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local Tools = require("Tools");

local Database = {
	tables = {}
};


function Database.add(tble, value)
	if type(value) ~= "table" then
		value = {value};
	end
	if type(Database.tables[tble]) ~= "table" then
		Database.tables[tble] = {};
	end
	
	for _,v in pairs(value) do
		table.insert(Database.tables[tble], v);
	end
end



function Database.sort(tble, fn)
	local tb = Database.tables[tble];
	if type(tb) ~= "table" then return false end
	table.sort(tb, fn);
	return true;
end

function Database.clearTables(...)
	for _,v in pairs({...}) do
		Database.tables[v] = nil;
	end
end

function Database.getID(tbl, id)
	local all = Database.filter(tbl);
	for _,v in pairs(all) do
		if Tools.multiSearch(id, v.id) then
			return v;
		end
	end
end

function Database.getIDs(tbl, ids)
	if type(ids) ~= "table" then
		ids = {[ids]=true};
	end
	local all = Database.filter(tbl);
	local out = {};
	for _,v in pairs(all) do
		if ids[v.id] then
			table.insert(out, v);
		elseif type(v.id) == "table" then
			for id,_ in pairs(v.id) do
				if ids[id] then
					table.insert(out, v);
					break;
				end
			end
		end
	end
	return out;
end

-- Lets you supply one or many filter functions
-- Returns false if none are found
function Database.filter(tble, filters)

	local tb = Database.tables[tble];
	if type(tb) ~= "table" then return false end
	if type(filters) ~= "table" then filters = {} end

	local out = {};
	for _,v in pairs(tb) do
		local success = true;
		for _,f in pairs(filters) do
			if f(v) == false then
				success = false;
				break;
			end
		end
		if success then
			table.insert(out, v)
		end
	end
	return out;
end

export("Database", Database, {
	filter = Database.filter,
	sort = Database.sort,
	getIDs = Database.getIDs,
	getID = Database.getID
}, 
{
	add = Database.add,
	clearTables = Database.clearTables,
	tables = Database.tables
})
