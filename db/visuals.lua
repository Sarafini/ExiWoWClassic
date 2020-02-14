-- NPC Libraries (Don't forget to make NPC Name conditions out of these)
local appName, internal = ...;
local require = internal.require;
local Event, Database, RPText, Visual;


local function ATC(texture, textureWidth, textureHeight, frameWidth, frameHeight, numFrames, elapsed, throttle)
	if ( not texture.frame ) then
		-- initialize everything
		texture.frame = 1;
		texture.throttle = throttle;
		texture.numColumns = floor(textureWidth/frameWidth);
		texture.numRows = floor(textureHeight/frameHeight);
		texture.columnWidth = frameWidth/textureWidth;
		texture.rowHeight = frameHeight/textureHeight;
	end

	local frame = texture.frame;
	local framesToAdvance = 0;
	if elapsed then
		framesToAdvance = floor(texture.throttle / throttle);
	end
	while ( frame + framesToAdvance > numFrames ) do
		frame = frame - numFrames;
	end
	frame = frame + framesToAdvance;
	texture.throttle = 0;
	local left = mod(frame-1, texture.numColumns)*texture.columnWidth;
	local right = left + texture.columnWidth;
	local bottom = ceil(frame/texture.numColumns)*texture.rowHeight;
	local top = bottom - texture.rowHeight;
	texture:SetTexCoord(left, right, top, bottom);
	texture.frame = frame;

end



-- Library for Conditions --
function internal.build.visuals()

	Visual = require('Visual');
	Event = require('Event');
	Database = require('Database');
	RPText = require('RPText');

	--local NPC = require("NPC");
	--local Database = require("Database");
	local ext = internal.ext;
	-- /dump ExiWoW.require("Visual").get("heavyPain"):trigger()
	ext:addVisual({
		id="heavyPain",
		image="red_border.tga",
		update = function(self)
			local delta = GetTime()-self.timeTriggered;
			local duration = 0.75;
			if delta > duration then
				return true;
			end
			local alpha = (sin(GetTime()*1000)+1)/8+0.75;
			if self.hold then
				return alpha;
			end
			return alpha*ExiWoW.Easing.outQuad(delta, 1, -1, duration)*0.75;
		end
	});

	-- Pain
	ext:addVisual({
		id="pain",
		image="red_border.tga",
		update = function(self)
			local delta = GetTime()-self.timeTriggered;
			local duration = 0.5;
			if delta > duration then
				return true;
			end
			local alpha = ((sin(GetTime()*1000)+1)/8+0.75)*min(1,delta*5);
			if self.hold then
				return alpha;
			end
			return alpha*ExiWoW.Easing.outQuad(delta, 1, -1, duration)*0.5;
		end
	});

	-- /dump ExiWoW.require("Visual").get("whiteSplat"):trigger();
	ext:addVisual({
		id="whiteSplat",
		image="cloudy_fade_border.tga",
		create = function(self)

			self.frame.bg:SetAlpha(0.25);

			self.frame.splats = {};
			local positions = {};

			for i=0,1 do
				table.insert(positions, {
					pos = "center",
					offset ={0,0},
					scale = 1
				});
			end

			local i =0;
			for _,v in pairs(positions) do
				local h = CreateFrame("Frame", nil, self.frame);
				h:SetPoint(v.pos, v.offset[1], v.offset[2]);
				h.texture = h:CreateTexture(nil, "BACKGROUND");
				h.texture:SetTexture("Interface/AddOns/ExiWoW/media/borders/splat_anim.tga");
				h.texture:SetAllPoints(h);
				h.texture:SetBlendMode("ADD");
				h.start = i*0.05;
				i = i+1;
				table.insert(self.frame.splats, h);
			end

		end,
		start = function(self)
			for i,v in pairs(self.frame.splats) do

				-- Resets texture
				v.texture.frame = nil;
				ATC(v.texture, 1024, 1024, 128, 256, 32, nil, 0.02125+random()*0.02);

				v:SetPoint("center",
					random()*1600-800,
					random()*800-400
				);
				local rand = (random()*0.5+0.5);
				v:SetWidth(300*rand);
				v:SetHeight(600*rand);
				v:SetAlpha(random()*0.75+0.25);

			end
		end,
		update = function(self, elapsed)

			local delta = GetTime()-self.timeTriggered;
			local duration = 1.5;
			for _,v in pairs(self.frame.splats) do
				local el = elapsed;
				local d = delta-v.start;
				if d > 0 then
					if v.texture.frame > 30 then
						v.texture.frame = 31;
						el = 0;
					end
					AnimateTexCoords(v.texture, 1024, 256, 64, 128, 32, el, 0.02125+random()*0.02);
				end
			end

			if self.hold or delta < duration/2 then
				return 1;
			end

			if delta > duration then
				return true;
			end

			local d = delta-duration/2;
			return min(1,max(0,ExiWoW.Easing.inQuart(d/(duration/2), 1, -1, 1)));

		end
	});

	-- /dump ExiWoW.require("Visual").get("greenSplat"):trigger();
	ext:addVisual({
		id="greenSplat",
		image="cloudy_fade_border.tga",
		create = function(self)

			self.frame.bg:SetAlpha(0.25);
			self.frame.bg:SetVertexColor(0.5,1,0.5);

			self.frame.splats = {};
			local positions = {};

			for i=0,3 do
				table.insert(positions, {
					pos = "center",
					offset ={0,0},
					scale = 1
				});
			end

			local i =0;
			for _,v in pairs(positions) do
				local h = CreateFrame("Frame", nil, self.frame);
				h:SetPoint(v.pos, v.offset[1], v.offset[2]);

				h.texture = h:CreateTexture(nil, "BACKGROUND");
				h.texture:SetVertexColor(0.5,1,0.5);

				h.texture:SetTexture("Interface/AddOns/ExiWoW/media/borders/splat_anim.tga");
				h.texture:SetAllPoints(h);
				h.texture:SetBlendMode("ADD");
				h.start = i*0.05;
				i = i+1;
				table.insert(self.frame.splats, h);
			end


		end,
		start = function(self)
			for i,v in pairs(self.frame.splats) do

				self.frame.bg:SetAlpha(0.25);
				
				-- Resets texture
				v.texture.frame = nil;
				ATC(v.texture, 1024, 1024, 128, 256, 32, nil, 0.02125+random()*0.02);

				v:SetPoint("center",
					random()*1600-800,
					random()*800-400
				);
				local rand = (random()*0.5+0.5);
				v:SetWidth(300*rand);
				v:SetHeight(600*rand);
				v:SetAlpha(random()*0.75+0.25);

			end
		end,
		update = function(self, elapsed)

			local delta = GetTime()-self.timeTriggered;
			local duration = 2.5;
			for _,v in pairs(self.frame.splats) do
				local el = elapsed;
				local d = delta-v.start;
				if d > 0 then
					if v.texture.frame > 30 then
						v.texture.frame = 31;
						el = 0;
					end
					AnimateTexCoords(v.texture, 1024, 256, 64, 128, 32, el, 0.02125+random()*0.02);
				end
			end

			if self.hold or delta < duration/2 then
				return 1;
			end

			if delta > duration then
				return true;
			end

			local d = delta-duration/2;
			return min(1,max(0,ExiWoW.Easing.inQuart(d/(duration/2), 1, -1, 1)));

		end
	});

	-- /dump ExiWoW.require("Visual").get("orangeSplat"):trigger();
	ext:addVisual({
		id="orangeSplat",
		create = function(self)

			self.frame.splats = {};
			local positions = {};

			for i=0,1 do
				table.insert(positions, {
					pos = "center",
					offset ={0,0},
					scale = 1
				});
			end

			local i =0;
			for _,v in pairs(positions) do
				local h = CreateFrame("Frame", nil, self.frame);
				h:SetPoint(v.pos, v.offset[1], v.offset[2]);

				h.texture = h:CreateTexture(nil, "BACKGROUND");
				h.texture:SetVertexColor(1,0.6,0.1);

				h.texture:SetTexture("Interface/AddOns/ExiWoW/media/borders/splat_anim.tga");
				h.texture:SetAllPoints(h);
				h.texture:SetBlendMode("ADD");
				h.start = i*0.05;
				i = i+1;
				table.insert(self.frame.splats, h);
			end


		end,
		start = function(self)
			for i,v in pairs(self.frame.splats) do

				self.frame.bg:SetAlpha(0.25);
				
				-- Resets texture
				v.texture.frame = nil;
				ATC(v.texture, 1024, 1024, 128, 256, 32, nil, 0.02125+random()*0.02);

				v:SetPoint("center",
					random()*1600-800,
					random()*800-400
				);
				local rand = (random()*0.5+0.5);
				v:SetWidth(300*rand);
				v:SetHeight(600*rand);
				v:SetAlpha(random()*0.75+0.25);

			end
		end,
		update = function(self, elapsed)

			local delta = GetTime()-self.timeTriggered;
			local duration = 2.5;
			for _,v in pairs(self.frame.splats) do
				local el = elapsed;
				local d = delta-v.start;
				if d > 0 then
					if v.texture.frame > 30 then
						v.texture.frame = 31;
						el = 0;
					end
					AnimateTexCoords(v.texture, 1024, 256, 64, 128, 32, el, 0.02125+random()*0.02);
				end
			end

			if self.hold or delta < duration/2 then
				return 1;
			end

			if delta > duration then
				return true;
			end

			local d = delta-duration/2;
			return min(1,max(0,ExiWoW.Easing.inQuart(d/(duration/2), 1, -1, 1)));

		end
	});


	-- /dump ExiWoW.require("Visual").get("quickWet"):trigger();
	ext:addVisual({
		id="quickWet",
		image="cloudy_fade_border.tga",
		create = function(self)

			self.frame.bg:SetAlpha(0.4);
			self.frame.bg:SetVertexColor(0.5,0.8,1);

			self.frame.splats = {};
			local positions = {};

			for i=0,15 do
				table.insert(positions, {
					pos = "center",
					offset ={0,0},
					scale = 1
				});
			end

			local i =0;
			for _,v in pairs(positions) do
				local h = CreateFrame("Frame", nil, self.frame);
				h:SetPoint(v.pos, v.offset[1], v.offset[2]);

				h.texture = h:CreateTexture(nil, "BACKGROUND");
				h.texture:SetVertexColor(0.5,0.7,1);

				h.texture:SetTexture("Interface/AddOns/ExiWoW/media/borders/waterdrop.tga");
				h.texture:SetAllPoints(h);
				h.texture:SetBlendMode("ADD");
				table.insert(self.frame.splats, h);
			end


		end,
		start = function(self)
			for i,v in pairs(self.frame.splats) do

				self.frame.bg:SetAlpha(0.25);
				v.y = random()*1000-500;
				v.x = random()*2000-1000;
				
				v:SetPoint("center",
					v.x,
					v.y
				);
				
				local rand = (random()*0.75+0.1);
				v.yspeed = rand*2;
				v:SetWidth(80*rand);
				v:SetHeight(80*rand);
				v:SetAlpha(random()*0.75+0.1);

			end
		end,
		update = function(self, elapsed)

			local delta = GetTime()-self.timeTriggered;
			local duration = 0.75;
			for _,v in pairs(self.frame.splats) do
				local el = elapsed;
				v:SetPoint("center", v.x, v.y-delta*100*v.yspeed);
			end

			if delta > duration then
				return true;
			end

			local d = delta/(duration*0.25);
			if delta < duration/4 then
				return 0.75*math.sin(d*math.pi/2);
			end
			d = (delta-duration*0.25)/(duration*0.75);


			return 0.75*math.sin(d*math.pi/2+math.pi/2);

		end
	});


	-- /dump ExiWoW.require("Visual").get("greenSplatPersistent"):trigger();
	ext:addVisual({
		id="greenSplatPersistent",
		create = function(self)
			
			self._timeout = 1800;
			self.frame.splats = {};
			
		end,
		start = function(self)

			local v;
			for _,splat in pairs(self.frame.splats) do
				if splat._started+self._timeout < GetTime() then
					v = splat;
					break;
				end
			end

			-- No viable splats. We'll have to replace one
			if #self.frame.splats >= 8 and not v then
				local lowest = -1;
				for _,splat in pairs(self.frame.splats) do
					if splat._started < lowest or lowest == -1 then
						v = splat;
						lowest = splat._started;
					end
				end
			end

			-- Create a new splat
			if not v then
				local h = CreateFrame("Frame", nil, self.frame);
				h:SetPoint("center", 0, 0);
				h.texture = h:CreateTexture(nil, "BACKGROUND");
				local bright = random()*0.5+0.5;
				h.texture:SetVertexColor(0.5*bright,1*bright,0.5*bright);
				h.texture:SetTexture("Interface/AddOns/ExiWoW/media/borders/splat_anim.tga");
				h.texture:SetAllPoints(h);
				h.texture:SetBlendMode("BLEND");
				v = h;
				table.insert(self.frame.splats, v);
			end

			v._started = GetTime();

			-- Resets texture
			v.texture.frame = nil;
			ATC(v.texture, 1024, 1024, 128, 256, 32, nil, 0.02125+random()*0.02);
			v:SetPoint("center", random()*1600-800, random()*800-400);
			local rand = (random()*0.5+0.5);
			v:SetWidth(200*rand);
			v:SetHeight(400*rand);
			v:Show();


			-- Bind removal events, as these get unbound before start
			local function rem()
				self:stop();
				Visual.get("quickWet"):trigger();
				for _,v in pairs(self.frame.splats) do
					v._started = 0;
					v:Hide();
				end
			end
			self:on(Event.Types.SUBMERGE, rem);
			self:on(Event.Types.SPELL_RAN, function(data)
				local aura = data.aura;
				local all = Database.getIDs("Spell", aura.name);
				local eventData = RPText.buildSpellData(aura.spellId, aura.name, aura.harmful, data.name);
				for _,sp in pairs(all) do
					eventData.tags = sp:exportTags();
					if Condition.get("ts_slosh"):validate("player", "player", ExiWoW.ME, ExiWoW.ME, eventData) then
						rem();
					end
				end
			end);
			

		end,
		update = function(self, elapsed)

			local active = 0;
			for _,v in pairs(self.frame.splats) do

				-- Ignore something that has finished
				if v._started ~= 0 then
					-- Animate
					local el = elapsed;
					if v.texture.frame > 29 then
						v.texture.frame = 31;
						el = 0;
					end
					if v.texture.frame ~= 31 then
						AnimateTexCoords(v.texture, 1024, 256, 64, 128, 32, el, 0.02125+random()*0.02);
					end

					local started = v._started;
					local delta = GetTime()-started;
					-- Timed out
					if delta > started+self._timeout then
						v._started = 0;
						v:Hide();
					else
						-- Update alpha
						v:SetAlpha( 0.25*min(1,max(0,ExiWoW.Easing.inQuart(delta, 1, -1, self._timeout))) );
						active = active+1;
					end

				end
				
			end

			
			if active == 0 then
				return true;
			end

			return 1;
		end
	});

	-- /dump ExiWoW.require("Visual").get("whiteSplatPersistent"):trigger();
	ext:addVisual({
		id="whiteSplatPersistent",
		create = function(self)
			
			self._timeout = 1800;
			self.frame.splats = {};
			
		end,
		start = function(self)

			local v;
			for _,splat in pairs(self.frame.splats) do
				if splat._started+self._timeout < GetTime() then
					v = splat;
					break;
				end
			end

			-- No viable splats. We'll have to replace one
			if #self.frame.splats >= 8 and not v then
				local lowest = -1;
				for _,splat in pairs(self.frame.splats) do
					if splat._started < lowest or lowest == -1 then
						v = splat;
						lowest = splat._started;
					end
				end
			end

			-- Create a new splat
			if not v then
				local h = CreateFrame("Frame", nil, self.frame);
				h:SetPoint("center", 0, 0);
				h.texture = h:CreateTexture(nil, "BACKGROUND");
				local bright = random()*0.25+0.75;
				h.texture:SetVertexColor(1*bright,1*bright,1*bright);
				h.texture:SetTexture("Interface/AddOns/ExiWoW/media/borders/splat_anim.tga");
				h.texture:SetAllPoints(h);
				h.texture:SetBlendMode("BLEND");
				v = h;
				table.insert(self.frame.splats, v);
			end

			v._started = GetTime();

			-- Resets texture
			v.texture.frame = nil;
			ATC(v.texture, 1024, 1024, 128, 256, 32, nil, 0.02125+random()*0.02);
			v:SetPoint("center", random()*1600-800, random()*800-400);
			local rand = (random()*0.5+0.5);
			v:SetWidth(200*rand);
			v:SetHeight(400*rand);
			v:Show();

			-- Bind removal events, as these get unbound before start
			local function rem()
				self:stop();
				for _,v in pairs(self.frame.splats) do
					v._started = 0;
					v:Hide();
				end
				Visual.get("quickWet"):trigger();
			end
			self:on(Event.Types.SUBMERGE, rem);
			self:on(Event.Types.SPELL_RAN, function(data)
				local aura = data.aura;
				local all = Database.getIDs("Spell", aura.name);
				local eventData = RPText.buildSpellData(aura.spellId, aura.name, aura.harmful, data.name);
				for _,sp in pairs(all) do
					eventData.tags = sp:exportTags();
					if Condition.get("ts_slosh"):validate("player", "player", ExiWoW.ME, ExiWoW.ME, eventData) then
						rem();
					end
				end
			end);
			

		end,
		update = function(self, elapsed)

			local active = 0;
			for _,v in pairs(self.frame.splats) do

				-- Ignore something that has finished
				if v._started ~= 0 then
					-- Animate
					local el = elapsed;
					if v.texture.frame > 29 then
						v.texture.frame = 31;
						el = 0;
					end
					if v.texture.frame ~= 31 then
						AnimateTexCoords(v.texture, 1024, 256, 64, 128, 32, el, 0.02125+random()*0.02);
					end

					local started = v._started;
					local delta = GetTime()-started;
					-- Timed out
					if delta > started+self._timeout then
						v._started = 0;
						v:Hide();
					else
						-- Update alpha
						v:SetAlpha( 0.25*min(1,max(0,ExiWoW.Easing.inQuart(delta, 1, -1, self._timeout))) );
						active = active+1;
					end

				end
				
			end

			
			if active == 0 then
				return true;
			end

			return 1;
		end
	});

	-- /dump ExiWoW.require("Visual").get("orangeSplatPersistent"):trigger();
	ext:addVisual({
		id="orangeSplatPersistent",
		create = function(self)
			
			self._timeout = 1800;
			self.frame.splats = {};
			
		end,
		start = function(self)

			local v;
			for _,splat in pairs(self.frame.splats) do
				if splat._started+self._timeout < GetTime() then
					v = splat;
					break;
				end
			end

			-- No viable splats. We'll have to replace one
			if #self.frame.splats >= 8 and not v then
				local lowest = -1;
				for _,splat in pairs(self.frame.splats) do
					if splat._started < lowest or lowest == -1 then
						v = splat;
						lowest = splat._started;
					end
				end
			end

			-- Create a new splat
			if not v then
				local h = CreateFrame("Frame", nil, self.frame);
				h:SetPoint("center", 0, 0);
				h.texture = h:CreateTexture(nil, "BACKGROUND");
				local bright = random()*0.25+0.75;
				h.texture:SetVertexColor(1*bright,0.75*bright,0.5*bright);
				h.texture:SetTexture("Interface/AddOns/ExiWoW/media/borders/splat_anim.tga");
				h.texture:SetAllPoints(h);
				h.texture:SetBlendMode("BLEND");
				v = h;
				table.insert(self.frame.splats, v);
			end

			v._started = GetTime();

			-- Resets texture
			v.texture.frame = nil;
			ATC(v.texture, 1024, 1024, 128, 256, 32, nil, 0.02125+random()*0.02);
			v:SetPoint("center", random()*1600-800, random()*800-400);
			local rand = (random()*0.5+0.5);
			v:SetWidth(200*rand);
			v:SetHeight(400*rand);
			v:Show();

			-- Bind removal events, as these get unbound before start
			local function rem()
				self:stop();
				for _,v in pairs(self.frame.splats) do
					v._started = 0;
					v:Hide();
				end
				Visual.get("quickWet"):trigger();
			end
			self:on(Event.Types.SUBMERGE, rem);
			self:on(Event.Types.SPELL_RAN, function(data)
				local aura = data.aura;
				local all = Database.getIDs("Spell", aura.name);
				local eventData = RPText.buildSpellData(aura.spellId, aura.name, aura.harmful, data.name);
				for _,sp in pairs(all) do
					eventData.tags = sp:exportTags();
					if Condition.get("ts_slosh"):validate("player", "player", ExiWoW.ME, ExiWoW.ME, eventData) then
						rem();
					end
				end
			end);
			

		end,
		update = function(self, elapsed)

			local active = 0;
			for _,v in pairs(self.frame.splats) do

				-- Ignore something that has finished
				if v._started ~= 0 then
					-- Animate
					local el = elapsed;
					if v.texture.frame > 29 then
						v.texture.frame = 31;
						el = 0;
					end
					if v.texture.frame ~= 31 then
						AnimateTexCoords(v.texture, 1024, 256, 64, 128, 32, el, 0.02125+random()*0.02);
					end

					local started = v._started;
					local delta = GetTime()-started;
					-- Timed out
					if delta > started+self._timeout then
						v._started = 0;
						v:Hide();
					else
						-- Update alpha
						v:SetAlpha( 0.25*min(1,max(0,ExiWoW.Easing.inQuart(delta, 1, -1, self._timeout))) );
						active = active+1;
					end

				end
				
			end

			
			if active == 0 then
				return true;
			end

			return 1;
		end
	});
	

	-- /dump ExiWoW.require("Visual").get("frost"):trigger()
	ext:addVisual({
		id="frost",
		image="frost_border.tga",
		update = function(self)
			local delta = GetTime()-self.timeTriggered;
			local duration = 0.75;
			if delta > duration then
				return true;
			end
			if self.hold then return 1 end
			return min(1,max(0,ExiWoW.Easing.outInQuart(delta, 1, -1, duration)));
		end
	});
	-- /run ExiWoW.require("Visual").get("lightning"):trigger()
	ext:addVisual({
		id="lightning",
		image="lightning_border.tga",
		update = function(self)
			local delta = GetTime()-self.timeTriggered;
			local duration = 0.5;
			if delta > duration then
				return true;
			end

			local alpha = (sin(GetTime()*3000)+1)/8+0.75;
			if self.hold then
				return alpha;
			end
			return alpha*min(1,max(0,ExiWoW.Easing.outInBounce(delta, 1, -1, duration)))*(0.5+(duration-delta)/2);
		end
	});
	-- /run ExiWoW.require("Visual").get("heavyExcitement"):trigger()
	-- /run ExiWoW.require("Visual").get("heavyExcitement"):stop()
	ext:addVisual({
		id="heavyExcitement",
		image="cloudy_fade_border.tga",
		create = function(self)

			self.frame.bg:SetVertexColor(1,0.5,1);

			self.frame.hearts = {};
			local positions = {
				{pos="topleft", offset={100+random()*50,-100+random()*100}, scale=random()*0.5+0.5},
				{pos="bottomleft", offset={400+random()*50,300+random()*100}, scale=random()*0.5+0.5},
				{pos="bottomright", offset={-200-random()*50,300+random()*100}, scale=random()*0.5+0.5},
				{pos="topright", offset={-300+random()*150,-200+random()*200}, scale=random()*0.5+0.5},
			};

			for i=0,8 do
				table.insert(positions, {
					pos = "center",
					offset ={0,0},
					scale = 1
				});
			end

			for _,v in pairs(positions) do
				local h = CreateFrame("Frame", nil, self.frame);
				h:SetWidth(150*v.scale);
				h:SetHeight(300*v.scale);
				h:SetPoint(v.pos, v.offset[1], v.offset[2]);
				h.texture = h:CreateTexture(nil, "BACKGROUND");

				h.texture:SetTexture("Interface/AddOns/ExiWoW/media/borders/heart_anim.tga");
				h.texture:SetAllPoints(h);
				h.texture:SetBlendMode("ADD");
				table.insert(self.frame.hearts, h);
				AnimateTexCoords(h.texture, 1024, 256, 64, 128, 32, random(), 0.015);
			end

		end,
		start = function(self)
			for i,v in pairs(self.frame.hearts) do
				if i > 4 then
					v:SetPoint("center",
						random()*1600-800,
						random()*1000-500
					);
					local rand = (random()*0.25+0.25);
					v:SetWidth(150*rand);
					v:SetHeight(300*rand);
					v:SetAlpha(random()*0.75+0.25);
				end
			end
		end,
		update = function(self, elapsed)
			local delta = GetTime()-self.timeTriggered;
			local duration = 1;
			for _,v in pairs(self.frame.hearts) do
				AnimateTexCoords(v.texture, 1024, 256, 64, 128, 32, elapsed, 0.015);
			end

			local alpha = (sin(GetTime()*1000)+1)/4+0.25;
			if self.hold then
				return alpha;
			end

			if delta > duration then
				return true;
			end

			return alpha*ExiWoW.Easing.outQuad(delta, 1, -1, duration);

		end
	});


	ext:addVisual({
		id="excitement",
		image="cloudy_fade_border.tga",
		create = function(self)
			self.frame.bg:SetVertexColor(1,0.5,1);
		end,
		update = function(self, elapsed)
			local delta = GetTime()-self.timeTriggered;
			local duration = 1;
			
			local alpha = 0.25*min(1,delta*2);
			if self.hold then
				return alpha;
			end

			if delta > duration then
				return true;
			end

			return alpha*ExiWoW.Easing.outQuad(delta, 1, -1, duration);

		end
	});

end