local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local RPText, Character, Tools, Database, Action, Event;

local TalkboxLine = {};
TalkboxLine.__index = TalkboxLine;
	function TalkboxLine:new(data)
		local self = {}
		setmetatable(self, Talkbox);

		self.is_line = true;

		if type(data) ~= "table" then data = {} end
		self.text = data.text;
		self.animation = data.animation;
		self.animLength = data.animLength;							-- How long to animate for
		-- Animation list for PC
		--[[
			0 = idle
			1 = death
			4 = walk
			5 = run
			8,36 = takehit
			9 = takehit crit
			11 = bounce up down?
			12 = bounce up down fwd?
			13 = walk
			14 = stun
			15 = idle
			20 = parry unarmed
			21,22,23 = parry
			24 = dodge
			25,26,27,28,29 = stance
			30 = dodge?
			37 = prejump
			38,40 = falling
			39 = land
			41 = swim idle
			42 = swim fwd
			43 = swim left
			44 = swim right
			45 = swim back
			46 = fire bow
			48 = gun stance I think
			49 = gun fire
			50 = loot down
			51 = cast loop
			53 = cast fwd
			54 = cast up
			55 = roar
			56 = cast stance
			57 = special attack
			58 = 2h special
			59 = shield slam
			60 = talk
			61 = eat
			62 = mine
			63 = use
			64 = exclamation
			65 = question
			66 = bow
			67 = wave
			68 = cheer
			69 = dance
			70 = laugh
			71 = sleep loop
			73 = rude
			74 = roar
			75 = kneel briefly
			76 = kiss
			77 = cry loop
			78 = chicken
			79 = beg
			80 = clap
			81 = yell
			82 = flex
			83 = blush
			84 = point
			85 = stab
			87,88 = offhand attack
			89 = sheathe back dw
			90 = sheathe hips dw
			91 = sit chair
			95 = kick
			96 = sit ground
			97 = sit ground loop
			98 = unsit ground
			99 = lay down
			100 = lay loop
			101 = lay up
			102 = sit chair
			103 = sit chair higher
			104 = sit chair highest
			105 = draw bow
			...
		]]

		return self
	end

local Talkbox = {};
Talkbox.__index = Talkbox;

	function Talkbox.ini()
		RPText = require("RPText");
		Character = require("Character");
		Tools = require("Tools");
		Database = require("Database");
		Action = require("Action");
		Event = require("Event");
	end

	function Talkbox:new(data)
		local self = {}
		setmetatable(self, Talkbox);

		-- Lines of text
		self.id = data.id;
		self.lines = data.lines;				-- Paragraphs
		self.displayInfo = data.displayInfo; 	-- Find the NPC on wowhead, edit source and search for ModelViewer.show, that has the displayid
		self.title = data.title;				-- Title of talkbox
		self.onComplete = data.onComplete;		-- Function to run when completed
		self.rewards = data.rewards;			-- {{name = name, icon=icon, quant=quant}...}
		self.x = data.x;											-- X/Y where the talkbox orginated from in the zone where it's popped
		self.y = data.y;
		self.rad = data.rad;										-- Radius from where to close the talkbox
		
		if type(self.lines) ~= "table" then
			self.lines = {};
		end

		for k,v in pairs(self.lines) do
			if type(v) ~= "table" or not v.is_line then
				self.lines[k] = TalkboxLine:new({text = v});
			end
		end

		return self
	end




export(
	"Talkbox", 
	Talkbox,
	{
		new = Talkbox.new,
		Line = TalkboxLine
	},
	{
		
	}
)