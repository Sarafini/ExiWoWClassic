local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local Action, Underwear, Database, Event, Timer, Quest, Condition;

UI = {}
	UI.FRAME = false 					-- Page browser for ExiWoW
	UI.open = false 					-- Set to false when done debugging. Setting to false by default will have it visible by default
	UI.lootQueue = {}					-- {{name=name, icon=icon}} - Queue of loot to show when the loot toast pops up
	UI.page = 1

	function UI.ini()

		UI.open = globalStorage.UI_OPEN;
		UI.page = globalStorage.UI_PAGE;
		Action = require("Action");
		Underwear = require("Underwear");
		Database = require("Database");
		Event = require("Event");
		Timer = require("Timer");
		Quest = require("Quest");		
		Condition = require("Condition");
	end


	-- Local helper functions
	local function onSettingsChange()
		--if true then return end
		Event.raise(Event.Types.ACTION_SETTING_CHANGE)
	end

	-- Helpful internal build function
	local function createSlider(id, parent, point, x,y, low, high, label, min,max, step, tooltip, callback, width, height)
		--if true then return end
		if not width then width = 200 end
		if not height then height = 20 end
		local sl = CreateFrame("Slider", id, parent, "OptionsSliderTemplate")
		sl:SetWidth(width)
		sl:SetHeight(height)
		sl:SetPoint(point, x, y);
		sl:SetOrientation('HORIZONTAL')
		sl.tooltipText = tooltip;
		getglobal(sl:GetName()..'Low'):SetText(low);
		getglobal(sl:GetName()..'High'):SetText(high);
		getglobal(sl:GetName()..'Text'):SetText(label);
		sl.baseText = label
		sl:SetMinMaxValues(min, max)
		sl:SetValueStep(step)
		sl:SetObeyStepOnDrag(true)
		sl:Show();
		sl:SetScript("OnValueChanged", function(...)
			onSettingsChange()
			callback(...);
		end)

	end

	local function setValueInTitle(self, val)
		getglobal(self:GetName().."Text"):SetText(self.baseText..val);
	end

	function UI.build()
		--if true then return end
		local f = ExiWoWSettingsFrame;
		UI.FRAME = f;
		f:SetMovable(true)
		f:EnableMouse(true)
		f:RegisterForDrag("LeftButton")
		f:SetScript("OnDragStart", f.StartMoving)
		f:SetScript("OnDragStop", f.StopMovingOrSizing)

		PanelTemplates_SetNumTabs(f, 4);
		PanelTemplates_SetTab(f, 1);
		--ExiWoWSettingsFrame_page_settings:Show();
		--ExiWoWSettingsFrame_page_actions:Hide();

		if not UI.open then
			f:Hide();
		end

		UI.portrait.build();

		UI.quests.build();

		-- Build actions page
		UI.actionPage.build();
		-- Build underwear page
		UI.underwearPage.build();


		-- Build settings frame --
		UI.localSettings.build();
		-- Global settings
		UI.globalSettings.build();
		
		UI.talkbox.build();

		UI.setPage(UI.page);

		hooksecurefunc(LootAlertSystem,"setUpFunction",function()
	
			if #UI.lootQueue == 0 then return end
		
			local scans = {}
			scans["Fanged Green Glaive"] = true
			scans["Large Fang"] = true
			scans["Weapon Enhancement Token"] = true
			scans["Gloves of the Fang"] = true
			scans["Fang of the Pit"] = true
			scans["Golad, Twilight of Aspects"] = true
		
			local lootAlertPool = LootAlertSystem.alertFramePool
			for alertFrame in lootAlertPool:EnumerateActive() do
		
				if scans[alertFrame.ItemName:GetText()] then
					local item = UI.lootQueue[1]
					local name = item.name
					local icon = item.icon
					--DisplayTableInspectorWindow(alertFrame)
					alertFrame.ItemName:SetText(name)
					alertFrame.hyperlink = ""
					alertFrame:SetScript("OnEnter", function(frame)	end);
					alertFrame:SetScript("Onleave", function() end);
					alertFrame.lootItem.Icon:SetTexture("Interface/Icons/"..icon);
					table.remove(UI.lootQueue, 1)
					if #UI.lootQueue == 0 then return end
				end
			end
			
		
		end)

		-- Bind events
		ExiWoWSettingsFrame_close:SetScript("OnMouseUp", function (self, button)
			UI:toggle();
		end)


		ExiWoWSettingsFrameTab1:SetScript("OnMouseUp", function (self, button)
			UI.setPage(1, true)
		end)

		ExiWoWSettingsFrameTab2:SetScript("OnMouseUp", function (self, button)
			UI.setPage(2, true)
		end)

		ExiWoWSettingsFrameTab3:SetScript("OnMouseUp", function (self, button)
			UI.setPage(3, true)
		end)
		ExiWoWSettingsFrameTab4:SetScript("OnMouseUp", function (self, button)
			UI.setPage(4, true)
		end)

	end


	-- Main UI functions
	function UI.toggle()
		--if true then return end
		UI.open = not UI.open
		globalStorage.UI_OPEN = UI.open;
		if UI.open then
			UI.FRAME:Show();
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN );
		else
			UI.FRAME:Hide();
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE );
		end
	end


	-- Creates a macro
	function UI.createMacro(id)
		--if true then return end
		local action = Action.get(id)
		if not action then return false end
	
		local sub = id:sub(1, 16)
		local found = GetMacroIndexByName(sub);
		if found == 0 then
			local index = CreateMacro(sub, action.texture, "/ewact "..id)
			if not index then 
				print("Unable to create macro, make sure you have empty generic macro slots");
				return false;
			else 
				PickupMacro(index)
			end
		else
			PickupMacro(found)
		end
	end

	-- Refresh all--
	function UI.refreshAll()
		--if true then return end
		require("Action"):sort();
		UI.actionPage.update();
		UI.underwearPage.update();
		UI.localSettings.update();
		UI.globalSettings.update();
		UI.quests.update();
	end

	-- Deactivates all tabs
	function UI.hideAllTabs()
		--if true then return end
		ExiWoWSettingsFrame_page_settings:Hide();
		ExiWoWSettingsFrame_page_actions:Hide();
		ExiWoWSettingsFrame_page_underwear:Hide();	
		ExiWoWSettingsFrame_page_quests:Hide();
	end

	
	function UI.setPage(tab, playSound)
		--if true then return end
		if tab == nil then return end
		local pages = {"actionPage", "quests", "underwearPage", "localSettings"};
		if not pages[tab] then print("UI Page not found", tab); return end
		PanelTemplates_SetTab(UI.FRAME, tab);
		UI:hideAllTabs();
		UI[pages[tab]].open();
		if playSound then
			PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
		end
		UI.page = tab;
		globalStorage.UI_PAGE = tab;
	end



	-- Portrait
	UI.portrait = {};
	UI.portrait.targetHasExiWoWFrame = nil;			-- Gender display for target
	UI.portrait.excitementBar = false; 				-- Excitement bar frame thing
	UI.portrait.FRAME_WIDTH = 19;
	UI.portrait.FRAME_HEIGHT = 19;
	UI.portrait.PADDING = 7;
	UI.portrait.resting = nil;
	UI.portrait.border = nil;
	

	-- Builds the portrait
	function UI.portrait.build()
		--if true then return end
		local frameWidth = UI.portrait.FRAME_WIDTH;
		local frameHeight = UI.portrait.FRAME_HEIGHT;
		local padding = UI.portrait.PADDING;

		-- Icon
		local bg = CreateFrame("Button",nil,PlayerFrame); --frameType, frameName, frameParent, frameTemplate   
		bg:SetMovable(true)
		bg:RegisterForDrag("LeftButton")
		bg:SetScript("OnDragStart", bg.StartMoving)
		bg:SetScript("OnDragStop", bg.StopMovingOrSizing)
		
		

		-- Bind events
		bg:RegisterForClicks("AnyUp");
		bg:SetScript("OnClick", function (self, button, down)
			UI:toggle();
		end);

		bg:SetFrameStrata("HIGH");
		bg:SetSize(frameWidth,frameHeight);
		bg:SetPoint("TOPLEFT",80,-5);
		

		local mask = bg:CreateMaskTexture()
		mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		mask:SetPoint("CENTER")

		-- Background
		local t = bg:CreateTexture(nil, "BACKGROUND");
		t:SetColorTexture(0,0,0,0.5);
		t:AddMaskTexture(mask)
		t:SetAllPoints(bg);


		-- Status bar
		local bar = CreateFrame("Frame", nil, bg);
		bar:SetPoint("TOPLEFT");
		bar:SetSize(frameWidth,frameHeight);
		--bar:SetRotation(math.pi/2);

		t = bar:CreateTexture(nil, "BORDER");
		t:SetPoint("BOTTOM");
		t:SetSize(frameWidth,frameHeight);
		t:SetTexture("Interface\\TargetingFrame\\UI-StatusBar");
		--t:SetHeight(frameHeight*max(self.excitement, 0.00001)); -- Setting to 0 doesn't work
		SetClampedTextureRotation(t, 90);
		t:SetVertexColor(1,0.75,1)
		t:AddMaskTexture(mask);
		UI.portrait.portraitExcitementBar = t;
		UI.portrait.updateExcitementDisplay();

		-- Border

		local ol = CreateFrame("Frame", nil, bar);
		ol:SetPoint("TOPLEFT", -padding+1, padding-1)
		ol:SetSize(frameWidth+padding*2,frameHeight+padding*2)
		-- Inner
		t = ol:CreateTexture(nil, "BACKGROUND");
		t:SetTexture("Interface/common/portrait-ring-withbg-highlight");
		t:SetPoint("CENTER", 2);
		t:SetVertexColor(0.75,1,0.75);
		t:SetTexCoord(0.3,0.7,0.3,0.7);
		t:SetAlpha(0);
		t:SetSize(frameWidth,frameHeight);
		UI.portrait.resting = t;

		-- Outer
		
		t = ol:CreateTexture(nil, "ARTWORK");
		t:SetTexture("Interface\\MINIMAP\\MiniMap-TrackingBorder");
		t:SetTexCoord(0.01,0.61,0,0.6);
		t:SetPoint("CENTER", 1,4);
		t:SetAllPoints(ol);
		UI.portrait.border = t;
		
		-- Overlay
		t = ol:CreateTexture(nil, "OVERLAY");
		t:SetTexture("Interface/MINIMAP/UI-Minimap-ZoomButton-Highlight");
		t:SetVertexColor(1,1,0.7);
		t:SetPoint("CENTER", 0,0);
		t:SetBlendMode("ADD");
		t:SetSize(frameWidth+15,frameHeight+15);
		t:SetAlpha(0);
		bg.highlight = t;
		bg:SetScript("OnEnter", function(self) self.highlight:SetAlpha(1) end)
		bg:SetScript("OnLeave", function(self) self.highlight:SetAlpha(0) end)
		

		-- BUILD THE TARGET PORTRAIT --
		bg = CreateFrame("Button",nil,TargetFrame); --frameType, frameName, frameParent, frameTemplate   
		bg:SetMovable(true)
		bg:EnableMouse(true);
		bg:RegisterForDrag("LeftButton")
		bg:SetScript("OnDragStart", bg.StartMoving)
		bg:SetScript("OnDragStop", bg.StopMovingOrSizing)

		bg:SetFrameStrata("HIGH");
		bg:SetSize(20,20);
		bg:SetPoint("TOPRIGHT",-88,-10);
		t = bg:CreateTexture(nil, "BACKGROUND");
		t:SetTexture("Interface/AddOns/ExiWoW/media/icons/genders.blp");
		t:SetVertexColor(1,0.5,1);
		t:SetTexCoord(0,0.25,0,1);
		t:SetAlpha(0.75);
		t:SetAllPoints(bg);
		bg.genderTexture = t;
		UI.portrait.targetHasExiWoWFrame = bg;
		bg:Hide();
	end

	function UI.portrait.updateExcitementDisplay()
		--if true then return end
		local n = max(ExiWoW.ME:getExcitementPerc(), 0.00001);
		UI.portrait.portraitExcitementBar:SetHeight(UI.portrait.FRAME_WIDTH*n);	
		UI.portrait.portraitExcitementBar:SetPoint("BOTTOM", 0,0);---UI.portrait.FRAME_HEIGHT+UI.portrait.FRAME_HEIGHT*n
		

	end

	-- Settings for pages with buttons
	UI.buttonPage = {
		ROWS = 4,
		COLS = 8,
		MARG = 1.1,
	}





	UI.quests = {};
	UI.quests.listingFrames = {};
	UI.quests.left = nil
	UI.quests.right = nil
	UI.quests.empty = nil;
	UI.quests.selected = nil;		-- ID of selected quest

	function UI.quests.build()
		--if true then return end
		-- Empty
			local empty = CreateFrame("Frame", nil, ExiWoWSettingsFrame_page_quests);
			empty:SetAllPoints();
			UI.quests.empty = empty;
			local etext = empty:CreateFontString(nil, "BACKGROUND", "QuestTitleFont");
			etext:SetTextColor(1,1,1,1);
			etext:SetAllPoints();
			etext:SetText("You have no quests.");
			etext:SetJustifyH("CENTER");
			etext:SetJustifyV("CENTER");
			

		-- Left side
			local fr = CreateFrame("ScrollFrame", nil, ExiWoWSettingsFrame_page_quests);
			UI.quests.left = fr;
			fr:SetSize(160, 290);
			fr:SetPoint("TOPLEFT", 15, -25);

			fr:EnableMouse(true)
			fr:EnableMouseWheel(true)	
			--local bg = fr:CreateTexture(nil, "BACKGROUND");
			--bg:SetAllPoints(fr);
			--bg:SetColorTexture(255,255,255,1);

			local scrollbar = CreateFrame("Slider", nil, fr, "UIPanelScrollBarTemplate");
			scrollbar:SetPoint("TOPLEFT",fr,"TOPRIGHT",5,-20) 
			scrollbar:SetPoint("BOTTOMLEFT",fr,"BOTTOMRIGHT",5,20) 
			scrollbar:SetMinMaxValues(1,10) 
			scrollbar:SetValueStep(1) 
			scrollbar:SetStepsPerPage(7)
			scrollbar.scrollStep = 20
			scrollbar:SetValue(0) 
			scrollbar:SetWidth(16)
			scrollbar:SetScript("OnValueChanged",function(self,value) 
				self:GetParent():SetVerticalScroll(value) 
			end) 
			fr.scroll = scrollbar;

			local scrollchild = CreateFrame("Frame");
			fr.scrollchild = scrollchild;
			fr:SetScrollChild(scrollchild);
			scrollchild:SetWidth(fr:GetWidth());

			fr:SetScript("OnMouseWheel", function(self, delta)
				local cur_val = scrollbar:GetValue()
				local min_val, max_val = scrollbar:GetMinMaxValues()
			
				if delta < 0 and cur_val < max_val then
					cur_val = math.min(max_val, cur_val + 10)
					scrollbar:SetValue(cur_val)
				elseif delta > 0 and cur_val > min_val then
					cur_val = math.max(min_val, cur_val - 10)
					scrollbar:SetValue(cur_val)
				end
			end)



		-- Right side
			fr = CreateFrame("ScrollFrame", nil, ExiWoWSettingsFrame_page_quests);
			UI.quests.right = fr;
			fr:SetSize(245, 290);
			fr:SetPoint("TOPRIGHT", -15, -25);

			fr:EnableMouse(true)
			fr:EnableMouseWheel(true)	
			--local bg = fr:CreateTexture(nil, "BACKGROUND");
			--bg:SetAllPoints(fr);
			--bg:SetColorTexture(255,255,255,1);
			--local bg = fr:CreateTexture(nil, "BACKGROUND", "QuestLogBackground");
			--bg:SetAllPoints(fr);


			scrollbar = CreateFrame("Slider", nil, fr, "UIPanelScrollBarTemplate");
			scrollbar:SetPoint("TOPRIGHT",fr,"TOPLEFT",-5,-20) 
			scrollbar:SetPoint("BOTTOMRIGHT",fr,"BOTTOMLEFT",-5,20) 
			scrollbar:SetMinMaxValues(1,10) 
			scrollbar:SetValueStep(1) 
			scrollbar:SetStepsPerPage(7)
			scrollbar.scrollStep = 20
			scrollbar:SetValue(0) 
			scrollbar:SetWidth(16)
			scrollbar:SetScript("OnValueChanged",function(self,value) 
				self:GetParent():SetVerticalScroll(value) 
			end) 
			fr.scroll = scrollbar;

			scrollchild = CreateFrame("Frame");
			fr.scrollchild = scrollchild;
			fr:SetScrollChild(scrollchild);
			scrollchild:SetWidth(fr:GetWidth());
			scrollchild:SetHeight(fr:GetHeight());
			

			local header = scrollchild:CreateFontString(nil, "BACKGROUND", "QuestTitleFont");
			header:SetTextColor(1,1,1,1);
			header:SetPoint("TOPLEFT", scrollchild);
			scrollchild.header = header;
			header:SetText("This is the header");

			local progress = scrollchild:CreateFontString(nil, "BACKGROUND", "QuestFont");
			progress:SetTextColor(1,1,1,0.75);
			progress:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -5);
			progress:SetJustifyH("LEFT");
			scrollchild.progress = progress;
			progress:SetText("Progress goes here");
			progress:SetWidth(scrollchild:GetWidth());

			local handin = CreateFrame("Button", nil, scrollchild, "UIPanelButtonTemplate");
			handin:SetSize(120, 25);
			handin:SetPoint("CENTER", progress, "CENTER", 0, -3);
			handin:SetText("Finish Quest");
			handin:SetScript("OnClick", UI.quests.handinClicked);
			handin:Hide();
			scrollchild.handin = handin;

			local description = scrollchild:CreateFontString(nil, "BACKGROUND", "QuestTitleFont");
			description:SetTextColor(1,1,1,1);
			description:SetPoint("TOPLEFT", progress, "BOTTOMLEFT", 0, -10);
			description:SetText("Description");
			description:SetJustifyH("LEFT");
			scrollchild.descTitle = description;

			local desc = scrollchild:CreateFontString(nil, "BACKGROUND", "QuestFont");
			desc:SetTextColor(1,1,1,1);
			desc:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -5);
			scrollchild.desc = desc;
			desc:SetText("Quest description");
			desc:SetJustifyH("LEFT");
			desc:SetWidth(scrollchild:GetWidth());
			
			local rewardsTitle = scrollchild:CreateFontString(nil, "BACKGROUND", "QuestTitleFont");
			rewardsTitle:SetTextColor(1,1,1,1);
			rewardsTitle:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -10);
			rewardsTitle:SetText("Rewards");
			scrollchild.rewardsText = rewardsTitle;

			scrollchild.rewardFrames = {};

			for i=1,6 do
				local rewards = CreateFrame("Button", nil, scrollchild, "QuestItemTemplate");
				local pointA, pointB = "TOPLEFT", "BOTTOMLEFT";
				local ofsmul = 1;
				local multi = math.floor((i-1)/2)*60;
				rewards.index = i;
				rewards:SetPoint(pointA, rewardsTitle, pointB, 0, -5-(i-1)*45);
				--DisplayTableInspectorWindow(rewards)
				rewards.Name:SetText("Reward Name");
				rewards.Icon:SetTexture("Interface/Icons/achievement_character_pandaren_female");
				--rewards:SetSize(200,50);
				
				rewards.NameFrame:SetPoint("left", 25, 0);
				rewards.NameFrame:SetSize(190,60);

				rewards.Icon:SetSize(40,40);
				rewards.Icon:SetParent(rewards);
				rewards.Icon:SetPoint("left", rewards, "left", 0, 0);
				rewards.Name:SetPoint("left", 45,0);
				table.insert(scrollchild.rewardFrames, rewards);
				rewards:EnableMouse(true);
				rewards:SetScript("OnEnter", function(self)
					local reward = Quest.get(UI.quests.selected).rewards[self.index];
					UI.quests.tooltip(reward.type, reward.id, self);
				end);
				rewards:SetScript("OnLeave", function(self)
					local reward = Quest.get(UI.quests.selected).rewards[self.index];
					UI.quests.tooltip(reward.type, reward.id);
				end);
			end


			fr:SetScript("OnMouseWheel", function(self, delta)
				local cur_val = scrollbar:GetValue()
				local min_val, max_val = scrollbar:GetMinMaxValues()
			
				if delta < 0 and cur_val < max_val then
					cur_val = math.min(max_val, cur_val + 10)
					scrollbar:SetValue(cur_val)
				elseif delta > 0 and cur_val > min_val then
					cur_val = math.max(min_val, cur_val - 10)
					scrollbar:SetValue(cur_val)
				end
			end)

		
	end

	function UI.quests.getListingFrame(index)
		--if true then return end
		if not UI.quests.listingFrames[index] then
			local ab = CreateFrame("Button", nil, UI.quests.left.scrollchild, "QuestLogTitleTemplate");
			ab.Text:SetWidth(UI.quests.left.scrollchild:GetWidth()-15);
			local objectives = {};

			for i=1,4 do
				local sub = CreateFrame("FRAME", nil, ab, "QuestLogObjectiveTemplate");
				sub.Text:SetWidth(UI.quests.left.scrollchild:GetWidth()-15);
				table.insert(objectives, sub);
			end
			ab.objectives = objectives;
			
			UI.quests.listingFrames[index] = ab;
			ab:SetScript("OnEnter", UI.quests.mouseOver);
			ab:SetScript("OnLeave", UI.quests.mouseOut);
			ab:SetScript("OnClick", UI.quests.clicked);
						
			
		end
		return UI.quests.listingFrames[index];
	end

	function UI.quests.handinClicked()
		--if true then return end
		local quest = Quest.get(UI.quests.selected);
		if quest and quest:isReadyToHandIn() and quest:isDetachedHandin() then
			quest:handIn();
		end
	end

	function UI.quests.tooltip(itemType, itemID, frame)
		--if true then return end
		local asset = nil;
		if itemType == "Charges" then
			asset = Action.get(itemID);
		elseif itemType == "Underwear" then
			asset = Underwear.get(itemID);
		end
		asset:onTooltip(frame and frame or nil);
	end
	

	function UI.quests.mouseOver(frame)
		
	end

	function UI.quests.mouseOut(frame)
		
	end

	function UI.quests.clicked(frame)
		--if true then return end
		UI.quests.selected = frame.questID;
		UI.quests.update();
	end

	function UI.quests.update()
		--if true then return end
		local quests = Quest.getActive();
		if #quests > 0 then
			if not UI.quests.selected then
				UI.quests.selected = quests[1].id;
			end
			UI.quests.empty:Hide();
			UI.quests.left:Show();
			UI.quests.right:Show();
		else
			UI.quests.empty:Show();
			UI.quests.left:Hide();
			UI.quests.right:Hide();
			return;
		end


		-- LISTING
		local i, y = 0, 0;
		while i<#UI.quests.listingFrames or i<#quests do
			i = i+1;
			local f = UI.quests.getListingFrame(i);
			if i > #quests then 
				f:Hide();
			else
				local quest = quests[i];
				f.questID = quest.id;
				f:SetText(quest.name);
				f:SetPoint("TOPLEFT", -15, -y);
				y = y+f:GetHeight();
				
				
				local obFrames = f.objectives;
				for _,of in pairs(obFrames) do 
					of:Hide(); 
				end

				local objectives = quest:getCurrentObjectives();

				if not objectives then
					objectives = {
						Quest.Objective:new({
							name = quest.end_journal,
							num = 1,
						})
					};
					local sub = obFrames[1];
					sub.Text:SetText("- "..quest.end_journal);
					sub:Show();
				end

				local n = 0
				for _,obj in pairs(objectives) do
					local sub = obFrames[n+1];
					local text = obj.name;
					local comp = obj:completed();
					sub.Text:SetTextColor(0.75,0.75,0.75);
					if not comp and obj.num > 1 then 
						text = obj.current_num.."/"..obj.num .. " " .. text;
					end
					if comp then
						text = text.." (Completed)";
						sub.Text:SetTextColor(0.5,0.5,0.5);
					end
					sub.Text:SetText(text);
					sub:Show();
					local height = sub.Text:GetHeight();
					sub:SetHeight(height);
					local base = 8;
					local h = height+2;
					local point = f.Text;
					local left = -10;
					if n > 0 then
						point = obFrames[n];
						left = 0;
						base = 0;
						h = h-2;
					end
					sub:SetPoint("TOPLEFT", point, "BOTTOMLEFT", left, -base);
					y = y+base+h;
					n = n+1;
				end

				
			end
		end

		local scrollchild = UI.quests.left.scrollchild;
		scrollchild:SetSize(UI.quests.left:GetWidth(), y);
		if y-295 < 1 then
			UI.quests.left.scroll:Hide();
		else
			UI.quests.left.scroll:Show();
			UI.quests.left.scroll:SetMinMaxValues(1,y-300);
		end


		-- ACTIVE QUEST
		local quest = Quest.get(UI.quests.selected);
		local right = UI.quests.right.scrollchild;
		local objectives = quest:getCurrentObjectives();
		local objLevel = quest:getCurrentObjectivesLevel();
		
		right.handin:Hide();
		right.header:SetText(quest.name);
		local out = "";
		if not objectives then
			if quest:isDetachedHandin() then
				right.progress:Hide();
				right.handin:Show();
			else	
				objectives = {
					Quest.Objective:new({
						name = quest.end_journal,
						num = 1
					})
				};
			end
		end

		if objectives then
			right.progress:Show();
			for _,obj in pairs(objectives) do
				local text = obj.name;
				local sub = right.progress;
				if obj.num > 1 then 
					text = obj.current_num.."/"..obj.num .. " " .. text;
				end
				text = " - "..text.."\n";
				out = out..text;
			end
			right.progress:SetText(out);
		end

		local journal = quest.journal_entry;
		local journalOut = "";
		if type(journal) ~= "table" then
			journal = {journal};
		end

		for k,v in pairs(journal) do
			if objLevel == nil or k <= objLevel then
				if k > 1 then journalOut = journalOut.."\n\n"; end
				journalOut = journalOut..v;
			end
		end	

		right.desc:SetText(journalOut);

		if #quest.rewards > 0 then
			right.rewardsText:Show();
		else
			right.rewardsText:Hide();
		end		
		--rewards
		for i=1,6 do
			local f = right.rewardFrames[i];
			if quest.rewards[i] then
				f:Show();
				local data = quest.rewards[i]:getTalkboxData();
				f.Name:SetText(data.name);
				f.Icon:SetTexture(data.icon);
				f.Count:Hide();
				if data.quant > 1 and data.quant < math.huge then
					f.Count:Show();
					f.Count:SetText(data.quant);
				end
			else
				f:Hide();
			end
		end


		local height = 
			right.header:GetHeight()+
			right.progress:GetHeight()+
			right.desc:GetHeight()+
			right.descTitle:GetHeight()*2+
			#quest.rewards*50+
			-250;
		
		right:SetSize(UI.quests.right:GetWidth(), height+300);
		if height < 1 then 
			UI.quests.right.scroll:Hide();
			UI.quests.right.scroll:SetMinMaxValues(1, 1);
		else
			UI.quests.right.scroll:Show();
			UI.quests.right.scroll:SetMinMaxValues(1, height);
		end
	end
	UI.quests.open = function()
		--if true then return end
		PanelTemplates_SetTab(UI.FRAME, 2);
		UI:hideAllTabs();
		ExiWoWSettingsFrame_page_quests:Show();
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end












	-- UI Talkbox for quests and dialog
	UI.talkbox = {};
	UI.talkbox.active = nil;	-- Use Talkbox object
	UI.talkbox.seqtime = 0;
	UI.talkbox.sequence = nil;
	UI.talkbox.radcheck = nil;	-- Timer for checking radius


	function UI.talkbox.build()
		--if true then return end
		-- Talkbox
		local talkbox = CreateFrame("Frame", nil, UIParent);
		UI.talkbox.frame = talkbox;
		talkbox:SetAllPoints();
		talkbox:SetMovable(true)

		local function bindForDrag(fr)
			fr:EnableMouse(true)
			fr:SetScript("OnMouseDown", function(self, button)
				if button == "LeftButton" and not talkbox.isMoving then
					talkbox:StartMoving();
					talkbox.isMoving = true;
				end
			end)
			fr:SetScript("OnMouseUp", function(self, button)
				if button == "LeftButton" and talkbox.isMoving then
					talkbox:StopMovingOrSizing();
					talkbox.isMoving = false;
				end
			end)
			fr:SetScript("OnHide", function(self)
				if ( talkbox.isMoving ) then
					talkbox:StopMovingOrSizing();
					talkbox.isMoving = false;
				end
			end)
		end

		local fr = CreateFrame("Button", nil, talkbox);
		talkbox.main = fr;
		fr:SetSize(550, 200);
		fr:SetPoint("CENTER", 0, -200);
		bindForDrag(fr);
		fr:RegisterForClicks("LeftButtonUp", "RightButtonUp");

		fr:SetScript("OnEnter", function(self, button)
			self.hover:Show();
		end)
		fr:SetScript("OnLeave", function(self, button)
			self.hover:Hide();
		end)
		fr:SetScript("OnClick", function(self, button)
			if button == "LeftButton" then
				UI.talkbox.advance();
			elseif button == "RightButton" then
				UI.talkbox.back();
			end
			PlaySound(806, "DIALOG");
		end);	
		

		fr.rewards = {};
		for i=1,6 do
			local rewards = CreateFrame("Button", nil, talkbox, "QuestItemTemplate");
			local pointA, pointB = "TOPLEFT", "BOTTOMLEFT";
			local ofsmul = 1;
			if i%2 == 0 then
				pointA = "TOPRIGHT";
				pointB = "BOTTOMRIGHT";
				ofsmul = -14;
			end
			local multi = math.floor((i-1)/2)*60;
			rewards:SetPoint(pointA, fr, pointB, 20+10*ofsmul, 10-multi);
			rewards.index = i;
			--DisplayTableInspectorWindow(rewards)
			rewards.Name:SetText("Reward Name");
			rewards.Icon:SetTexture("Interface/Icons/achievement_character_pandaren_female");
			--rewards:SetSize(200,50);
			rewards.NameFrame:SetPoint("left", 43, -10);
			rewards.NameFrame:SetSize(220,90);
			rewards.Icon:SetSize(60,60);
			rewards.Icon:SetPoint("left", rewards, "left", 0, 0);
			rewards.Name:SetPoint("left", 70,-10);

			rewards:SetScript("OnEnter", function(self)
				local reward = Quest.get(UI.talkbox.active.id).rewards[self.index];
				UI.quests.tooltip(reward.type, reward.id, self);
			end);
			rewards:SetScript("OnLeave", function(self)
				local reward = Quest.get(UI.talkbox.active.id).rewards[self.index];
				UI.quests.tooltip(reward.type, reward.id);
			end);
			
			table.insert(fr.rewards, rewards);
		end

		local closeButton = CreateFrame("Button", nil, fr, "UIPanelCloseButton");
		closeButton:SetSize(40,40);
		closeButton.close = closeButton;
		closeButton:SetPoint("TOPRIGHT", 0, 0);
		closeButton:Show();
		closeButton:RegisterForClicks("LeftButtonUp");
		closeButton:SetScript("OnClick", function(self, button)
			UI.talkbox.hide();
			PlaySound(879, "Dialog");
		end);

		local bg = fr:CreateTexture(nil, "BACKGROUND");
		bg:SetAllPoints(fr);
		bg:SetTexture("Interface/QuestFrame/TalkingHeads");
		bg:SetTexCoord(0.000976562, 0.557617, 0.00390625, 0.1543);

		-- Portrait black bg
		local ol = fr:CreateTexture(nil, "BACKGROUND");
		ol:SetSize(140,140);
		ol:SetPoint("LEFT", 15, 0);
		ol:SetTexture("Interface/QuestFrame/TalkingHeads");
		ol:SetTexCoord(0.5586, 0.67, 0.306, 0.42);

		-- /run ExiWoW.require("UI").quests.talkbox.model:SetUnit("target")
		local model = CreateFrame("PlayerModel", nil, fr);
		fr.model = model;
		model:SetSize(130,130);
		model:SetPoint("LEFT", 25, 0);
		model:SetDisplayInfo(17781); -- Find the NPC on wowhead, edit source and search for ModelViewer.show, that has the displayid
		model:SetCamera(0);
		--[[
		model:SetScript("OnUpdate", function(self, e)
			if UI.talkbox.sequence then
				self:SetSequenceTime(UI.talkbox.sequence, GetTime()*1000-UI.talkbox.seqtime);
			end
		end);
		]]
		-- Portrait border
		local border = CreateFrame("Frame", nil, model);
		border:SetAllPoints();
		ol = border:CreateTexture(nil, "BORDER");
		ol:SetSize(145, 145);
		ol:SetPoint("LEFT", -5, 0);
		ol:SetTexture("Interface/QuestFrame/TalkingHeads");
		ol:SetTexCoord(0.5664, 0.693, 0.007, 0.1357);
		
		-- Quest title text
		local text = fr:CreateFontString(nil, "BACKGROUND", "Fancy22Font");
		--text:SetTextColor(1,1,1,1);
		text:SetPoint("TOPRIGHT", -15, -30);
		text:SetWidth(365);
		text:SetJustifyH("LEFT");
		text:SetText("Quest title");
		fr.title = text;

		-- Quest desc
		text = fr:CreateFontString(nil, "BACKGROUND", "GameFontHighlightLarge");
		--text:SetTextColor(1,1,1,1);
		text:SetPoint("TOPLEFT", fr.title, "BOTTOMLEFT", 0, -5);
		text:SetJustifyH("LEFT");
		text:SetWidth(365);
		fr.description = text;
		text:SetText("This is the quest description. I'm gonna type out a few lines just to make sure it fits and wraps correctly.");

		-- Page out of page
		text = fr:CreateFontString(nil, "BACKGROUND", "GameFontHighlightLarge");
		--text:SetTextColor(1,1,1,1);
		text:SetPoint("BOTTOMRIGHT", fr, "BOTTOMRIGHT", -25, 25);
		text:SetJustifyH("RIGHT");
		text:SetTextColor(1,1,1,0.5);
		text:SetWidth(365);
		text:SetText("1/1");
		fr.pagination = text;

		-- Hover Hover frame
		local hover = CreateFrame("Frame", nil, fr);
		hover:SetAllPoints();
		hover:SetFrameStrata("HIGH");
		fr.hover = hover;

		-- 0.248047, 0.503906, 0.617188, 0.75
		ol = hover:CreateTexture(nil, "BACKGROUND");
		ol:SetAllPoints();
		ol:SetTexture("Interface/QuestFrame/TalkingHeads");
		ol:SetTexCoord(0.565, 0.805, 0.15, 0.227);
		ol:SetAlpha(0.5);
		hover:Hide();

		UI.talkbox.hide();
	end

	function UI.talkbox.getActive()
		--if true then return end
		return UI.talkbox.active;
	end

	function UI.talkbox.set(talkbox)
		--if true then return end
		if UI.talkbox.active then 
			return 
		end

		Timer.clear(UI.talkbox.radcheck);
		if talkbox.x and talkbox.y and talkbox.rad then
			UI.talkbox.radcheck = Timer.set(function()
				local cond = Condition:new({type=Condition.Types.RTYPE_LOC, data={x=talkbox.x, y=talkbox.y, rad=talkbox.rad}});
				local valid = cond:validate("player", "player", ExiWoW.ME, ExiWoW.ME);
				if not valid then
					UI.talkbox.hide();
				end
			end, 0.25, math.huge);
		end

		UI.talkbox.active = talkbox;
		UI.talkbox.page = 1;
		-- Set head and title
		local fr = UI.talkbox.frame.main;
		fr.title:SetText(talkbox.title);

		if type(talkbox.displayInfo) == "string" then
			fr.model:SetUnit(talkbox.displayInfo);
		else
			fr.model:SetDisplayInfo(talkbox.displayInfo);
		end
		fr.model:SetCamera(0);
		Timer.set(function()
			fr.model:SetCamera(0);
		end, 0.01);

		local rewards = fr.rewards;
		for i=1,6 do
			local f = rewards[i];
			f:Hide();
			f.Count:Hide();
			if type(talkbox.rewards) == "table" and talkbox.rewards[i] then
				f:Show();
				f.Name:SetText(talkbox.rewards[i].name);
				f.Icon:SetTexture(talkbox.rewards[i].icon);
				if talkbox.rewards[i].quant > 1  and talkbox.rewards[i].quant < math.huge then
					f.Count:SetText(talkbox.rewards[i].quant);
					f.Count:Show();
				end
			end
		end

		UI.talkbox.draw();
		UI.talkbox.frame:Show();
	end

	function UI.talkbox.advance()
		--if true then return end
		if not UI.talkbox.active then 
			return;
		end
		UI.talkbox.page = UI.talkbox.page+1;
		if UI.talkbox.page > #UI.talkbox.active.lines then
			if type(UI.talkbox.active.onComplete) == "function" then
				UI.talkbox.active.onComplete(UI.talkbox.active);
			end
			UI.talkbox.hide();
			UI.talkbox.active = nil;
		else
			UI.talkbox.draw();
		end
	end

	function UI.talkbox.back()
		--if true then return end
		if not UI.talkbox.active or UI.talkbox.page == 1 then 
			return 
		end
		UI.talkbox.page = UI.talkbox.page-1;
		UI.talkbox.draw();
	end


	function UI.talkbox.draw()
		--if true then return end
		local tb = UI.talkbox.active;
		local fr = UI.talkbox.frame.main;
		UI.talkbox.sequence = nil;
		UI.talkbox.seqtime = GetTime()*1000;
		local line = tb.lines[UI.talkbox.page];
		local text = line.text;
		if type(text) == "function" then
			text = text();
		end
		
		fr.description:SetText(text);
		fr.model:SetAnimation(0);

		if line.animation and line.animation > 0 then
			--UI.talkbox.sequence = line.animation;
			fr.model:SetAnimation(line.animation);
			local dur = 1;
			if line.animLength and line.animLength > 0 then
				dur = line.animLength;
			end	
			Timer.clear(fr.model.animTimer);
			fr.model.animTimer = Timer.set(function()
				fr.model:SetAnimation(0);
			end, dur);
		end

		fr.pagination:SetText(UI.talkbox.page.."/"..#tb.lines);
	end

	function UI.talkbox.hide()
		Timer.clear(UI.talkbox.radcheck);
		--if true then return end
		UI.talkbox.active = nil;
		UI.talkbox.frame:Hide();
	end













	-- Build the action page
	UI.actionPage = {}
	function UI.actionPage.build()
		--if true then return end
		local f = ExiWoWSettingsFrame_page_actions;
		for row=0,UI.buttonPage.ROWS-1 do
			for col=0,UI.buttonPage.COLS-1 do

				local idx = col+row*UI.buttonPage.COLS;
				local ab = CreateFrame("Button", "ExiWoWActionButton_"..tostring(idx), f, "ActionButtonTemplate");
				ab:SetPoint("TOPLEFT", 23+col*50*UI.buttonPage.MARG, -50-row*50*UI.buttonPage.MARG);
				ab:SetSize(50,50);
				ab.cooldown:SetSwipeTexture('', 0, 0, 0, 0.75)

				local rarity = ab:CreateTexture(nil, "OVERLAY");
				ab.rarity = rarity
				rarity:SetAllPoints()
				rarity:SetTexture("Interface/Common/WhiteIconFrame")

				ab:Hide();

				ab.Name:SetPoint("TOPRIGHT", 8,-30)
				ab.Name:SetFontObject("GameFontHighlight");

				ab:RegisterForDrag("LeftButton");
				ab:SetScript("OnDragStart", function(self)
					local v = UI.actionPage.getAbilityAt(idx+1)
					if v then
						UI.createMacro(v.id)
					end
				end);

				local s = CreateFrame("Frame", nil, ab);
				ab.star = s;
				s:SetPoint("TOPLEFT", -5,5);
				s:SetSize(16,16);
				local tx = s:CreateTexture(nil, "OVERLAY");
				tx:SetTexture("Interface/COMMON/ReputationStar");
				tx:SetTexCoord(0,0.5,0,0.5)
				tx:SetAllPoints();
				s:Hide();

			end
		end
	end

	function UI.actionPage.getAbilityAt(index)
		--if true then return end
		local out = 0;
		
		local lib = Database.filter("Action");
		for k,v in pairs(lib) do
			-- Make sure it's acceptable
			if v:validateFiltering("player", true) and
				not v.hidden and
				v.learned
			then
				out = out+1;
				if out == index then return v end
			end
		end
		return false
	end

	function UI.actionPage.update()
		--if true then return end
		for n=1,UI.buttonPage.ROWS*UI.buttonPage.COLS do
			local f = _G["ExiWoWActionButton_"..(n-1)]
			local v = UI.actionPage.getAbilityAt(n);
			if not v then
				f:Hide();
			else
	
				local name = _G["ExiWoWActionButton_"..(n-1).."Name"];
				if v.charges and v.charges ~= math.huge then
					name:SetText(v.charges)
				else
					name:SetText("")
				end
	
				local rarity = v.rarity-1
				if rarity < 1 then rarity = 1 end
				if rarity >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[rarity] then
					f.rarity:Show();
					f.rarity:SetVertexColor(BAG_ITEM_QUALITY_COLORS[rarity].r, BAG_ITEM_QUALITY_COLORS[rarity].g, BAG_ITEM_QUALITY_COLORS[rarity].b);
				else
					f.rarity:Hide();
				end
	
				f:SetScript("OnMouseUp", function (self, button)
					if IsShiftKeyDown() then
						v.favorite = not v.favorite;
						Action.sort();
						UI.actionPage.update()
					else
						Action.useOnTarget(v.id, "target")
					end
					PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
				end)
	
				f.icon:SetTexture("Interface/Icons/"..v.texture);
				--ab.cooldown = CreateFrame("Cooldown", nil, ab, "CooldownFrameTemplate");
	
				local started, duration = v:getCooldown();
				f.cooldown:SetCooldown(started, duration);
	
				if v.favorite then 
					f.star:Show();
				else
					f.star:Hide();
				end

				if v.passive and v.passive_on then
					f:LockHighlight();
				else
					f:UnlockHighlight();
				end

				-- Generate tooltip
				f:SetScript("OnEnter", function(self)
					v:onTooltip(self);
				end);
				f:SetScript("Onleave", function() 
					v:onTooltip();
				end);
	
				f:Show();
	
			end

		end
	end

	function UI.actionPage.open()
		--if true then return end
		PanelTemplates_SetTab(UI.FRAME, 1);
		UI:hideAllTabs();
		ExiWoWSettingsFrame_page_actions:Show();
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end






	-- Underwear page
	UI.underwearPage = {}
	function UI.underwearPage.build()
		--if true then return end
		local f = ExiWoWSettingsFrame_page_underwear;
		for row=0,UI.buttonPage.ROWS-1 do
			for col=0,UI.buttonPage.COLS-1 do

				local ab = CreateFrame("Button", "ExiWoWUnderwearButton_"..tostring(col+row*UI.buttonPage.COLS), f, "ActionButtonTemplate");
				ab:SetAttribute("type", "action");
				ab:SetAttribute("action", 1);
				ab:SetPoint("TOPLEFT", 23+col*50*UI.buttonPage.MARG, -50-row*50*UI.buttonPage.MARG);
				ab:SetSize(50,50);
				ab.cooldown:SetSwipeTexture('', 0, 0, 0, 0.75)

				local rarity = ab:CreateTexture(nil, "OVERLAY");
				ab.rarity = rarity
				rarity:SetAllPoints()
				rarity:SetTexture("Interface/Common/WhiteIconFrame")
				
				ab:Hide();



				local s = CreateFrame("Frame", nil, ab);
				ab.star = s;
				s:SetPoint("TOPLEFT", -5,5);
				s:SetSize(16,16);
				local tx = s:CreateTexture(nil, "OVERLAY");
				tx:SetTexture("Interface/COMMON/ReputationStar");
				tx:SetTexCoord(0,0.5,0,0.5)
				tx:SetAllPoints();
				s:Hide();

			end
		end
	end

	function UI.underwearPage.update()
		--if true then return end
		local i = 0;
		local unlocked = ExiWoW.ME.underwear_ids;
		local existing = {}
		for k,v in pairs(unlocked) do
			if Underwear.get(v.id) then
				table.insert(existing, v)
			end
		end

		table.sort(existing, function(a, b)
			if a.fav and not b.fav then return true
			elseif not a.fav and b.fav then return false
			end

			local obja = Underwear.get(a.id)
			local objb = Underwear.get(b.id)
			return obja.name < objb.name;
		end)

		for k,v in pairs(existing) do

			local item = v.id
			local fav = v.fav
			local obj = Underwear.get(item)
			-- Make sure it's acceptable
			if obj then

				local f = _G["ExiWoWUnderwearButton_"..i]

				f:SetScript("OnMouseUp", function (self, button)
					if IsShiftKeyDown() then
						v.fav = not v.fav;
						UI:refreshUnderwearPage()
					else
						ExiWoW.ME:useUnderwear(item)
					end
					PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
				end)


				local rarity = obj.rarity-1
				if rarity < 1 then rarity = 1 end
				if rarity >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[rarity] then
					f.rarity:Show();
					f.rarity:SetVertexColor(BAG_ITEM_QUALITY_COLORS[rarity].r, BAG_ITEM_QUALITY_COLORS[rarity].g, BAG_ITEM_QUALITY_COLORS[rarity].b);
				else
					f.rarity:Hide();
				end

				f.icon:SetTexture("Interface/Icons/"..obj.icon);

				if fav then 
					f.star:Show();
				else
					f.star:Hide();
				end

				if item == ExiWoW.ME.underwear_worn then
					f:LockHighlight()
				else
					f:UnlockHighlight()
				end

				-- Generate tooltip
				f:SetScript("OnEnter", function(frame)
					obj:onTooltip(frame);
				end);
				f:SetScript("Onleave", function() 
					obj:onTooltip();
				end);

				f:Show();
				i = i+1;

			end

		end

		for n=i,UI.buttonPage.ROWS*UI.buttonPage.COLS-1 do
			local f = _G["ExiWoWUnderwearButton_"..n]
			f:Hide();
		end
	end

	UI.underwearPage.open = function()
		--if true then return end
		PanelTemplates_SetTab(UI.FRAME, 3);
		UI:hideAllTabs();
		ExiWoWSettingsFrame_page_underwear:Show();
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end






	-- Local settings
	UI.localSettings = {}
	function UI.localSettings.build()
		--if true then return end
		local f = ExiWoWSettingsFrame_page_settings;
	
		local top = -50;
		local spacing = -40;
		local left = 30
		-- Masochism slider
		local item = 0
		createSlider("ExiWoWSettingsFrame_page_settings_masochism", f, "TOPLEFT", left, -50, "0", "100", "Masochism", 0, 100, 1, "Affects amount of excitement you gain from taking hits or masochistic actions and spells.", 
		function(self,arg1) 
			ExiWoW.ME.masochism = arg1/100;
			localStorage.masochism = ExiWoW.ME.masochism;
		end);

		-- Penis size slider
		item = item+1
		createSlider("ExiWoWSettingsFrame_page_settings_penis_size", f, "TOPLEFT", left, top+spacing*item, "Off", "Huge", "Male Endowment", 0, 5, 1, "How well endowed is your character?", 
		function(self,arg1) 
			arg1 = arg1-1;
			if arg1 == -1 then arg1 = false end
			ExiWoW.ME.penis_size = arg1;
			localStorage.penis_size = ExiWoW.ME.penis_size;
		end);

		-- Breast size slider
		item = item+1
		createSlider("ExiWoWSettingsFrame_page_settings_breast_size", f, "TOPLEFT", left, top+spacing*item, "Off", "Huge", "Female Endowment", 0, 5, 1, "How large are your character's breasts?", 
		function(self,arg1) 
			arg1 = arg1-1;
			if arg1 == -1 then arg1 = false end
			ExiWoW.ME.breast_size = arg1;
			localStorage.breast_size = ExiWoW.ME.breast_size;
		end);


		-- Butt size
		item = item+1
		createSlider("ExiWoWSettingsFrame_page_settings_butt_size", f, "TOPLEFT", left, top+spacing*item, "Tiny", "Huge", "Rear Size", 0, 4, 1, "How much junk in the trunk?", 
		function(self,arg1) 
			ExiWoW.ME.butt_size = arg1;
			localStorage.butt_size = ExiWoW.ME.butt_size;
		end);

		-- Toggle vagina
		item = item+1
		createSlider("ExiWoWSettingsFrame_page_settings_vagina_size", f, "TOPLEFT", left+40, top+spacing*item, "Off", "On", "Female Genitalia", 0, 1, 1, "Does your character have female genitalia?", 
		function(self,arg1) 
			arg1 = arg1-1;
			if arg1 == -1 then arg1 = false end
			ExiWoW.ME.vagina_size = arg1;
			localStorage.vagina_size = ExiWoW.ME.vagina_size;
		end, 60);

		-- Tank mode
		item = item+1
		local checkbutton = CreateFrame("CheckButton",  "ExiWoWSettingsFrame_page_settings_tank_mode", f, "ChatConfigCheckButtonTemplate");
		checkbutton.tooltip = "Adds a small chance of crit texts to trigger from normal hits. Useful on tanks since they can't be critically hit.";
		checkbutton:SetPoint("TOPLEFT", left, top+spacing*item);
		getglobal(checkbutton:GetName() .. 'Text'):SetText("Tank Mode");
		checkbutton:SetScript("OnClick", function(self)
			localStorage.tank_mode = self:GetChecked();
			PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
			onSettingsChange()
		end)
		

		-- Right side
		item = 0
		createSlider("ExiWoWSettingsFrame_page_settings_muscle_tone", f, "TOPRIGHT", -left, top+spacing*item, "Scrawny", "Bodybuilder", "Muscle Tone", 0, 10, 1, "How muscular are you compared to your race/class average?", 
		function(self, arg1)
			ExiWoW.ME.muscle_tone = arg1;
			localStorage.muscle_tone = ExiWoW.ME.muscle_tone;
		end)
		item = item+1
		createSlider("ExiWoWSettingsFrame_page_settings_fat", f, "TOPRIGHT", -left, top+spacing*item, "Emaciated", "Obese", "Body Fat", 0, 10, 1, "How fat are you compared to your race/class average?", 
		function(self, arg1)
			ExiWoW.ME.fat = arg1;
			localStorage.fat = ExiWoW.ME.fat;
		end)
		item = item+1
		createSlider("ExiWoWSettingsFrame_page_settings_intelligence", f, "TOPRIGHT", -left, top+spacing*item, "Dumb", "Scholarly", "Intelligence", 0, 10, 1, "How smart are you compared to your race/class average when it comes to solving problems?", 
		function(self, arg1)
			ExiWoW.ME.intelligence = arg1;
			localStorage.intelligence = ExiWoW.ME.intelligence;
		end)
		item = item+1
		createSlider("ExiWoWSettingsFrame_page_settings_wisdom", f, "TOPRIGHT", -left, top+spacing*item, "Gullible", "Astute", "Wisdom", 0, 10, 1, "What social skills does your character possess?", 
		function(self, arg1)
			ExiWoW.ME.wisdom = arg1;
			localStorage.wisdom = ExiWoW.ME.wisdom;
		end)
		

	end
	
	function UI.localSettings.update()
		--if true then return end
		local psize = ExiWoW.ME:getPenisSize();
		local tsize = ExiWoW.ME:getBreastSize();
		local bsize = ExiWoW.ME:getButtSize();
		local vsize = ExiWoW.ME:getVaginaSize();
		
		if psize == false then psize = -1 end
		if tsize == false then tsize = -1 end
		if vsize == false then vsize = -1 end
		psize = psize+1;
		tsize = tsize+1;
		vsize = vsize+1;

		local me = ExiWoW.ME;
		ExiWoWSettingsFrame_page_settings_masochism:SetValue(math.floor(me.masochism*100));
		ExiWoWSettingsFrame_page_settings_penis_size:SetValue(psize)
		ExiWoWSettingsFrame_page_settings_breast_size:SetValue(tsize)
		ExiWoWSettingsFrame_page_settings_butt_size:SetValue(bsize);
		ExiWoWSettingsFrame_page_settings_vagina_size:SetValue(vsize);
		ExiWoWSettingsFrame_page_settings_fat:SetValue(ExiWoW.ME.fat);
		ExiWoWSettingsFrame_page_settings_muscle_tone:SetValue(ExiWoW.ME.muscle_tone);
		ExiWoWSettingsFrame_page_settings_intelligence:SetValue(ExiWoW.ME.intelligence);
		ExiWoWSettingsFrame_page_settings_wisdom:SetValue(ExiWoW.ME.wisdom);
		
		
		ExiWoWSettingsFrame_page_settings_tank_mode:SetChecked(localStorage.tank_mode);
	end

	function UI.localSettings.open()
		--if true then return end
		PanelTemplates_SetTab(UI.FRAME, 4);
		UI:hideAllTabs();
		ExiWoWSettingsFrame_page_settings:Show();
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end



	-- Loot display
	-- /run UI:drawLoot("TestLoot", "ability_defend", 1)
	-- /run UI:drawLoot("TestLoot2", "ability_hunter_pet_bear", 2)
	-- Rarity starts at 1 which is grey
	-- Rarity starts at 1 which is grey
	function UI.drawLoot(name, icon, rarity)
		--if true then return end
		if not rarity then rarity = 2 end

		table.insert(UI.lootQueue, {name=name, icon=icon})

		local rarities = {
			"|cff1eff00|Hitem:133963::::::::110:::::|h[w]|h|r",		-- Grey
			"|cff1eff00|Hitem:5637::::::::110:::::|h[w]|h|r",		-- White
			"|cff1eff00|Hitem:120302::::::::110:::::|h[w]|h|r",		-- Green
			"|cff1eff00|Hitem:10413::::::::110:::::|h[w]|h|r",		-- Blue
			"|cff1eff00|Hitem:124367::::::::110:::::|h[w]|h|r",		-- Purple
			"|cff1eff00|Hitem:77949::::::::110:::::|h[w]|h|r"		-- Orange
		}
		PlaySound(50893, "Dialog")

		local function checkItem()
			if GetItemInfo(rarities[rarity]) == nil then
				Timer.set(checkItem, 0.1)
			else
				LootAlertSystem:AddAlert(rarities[rarity], 1, 0, 0, 0, false, false, nil, false, false, true, false);
			end
		end

		checkItem();
		
	end
	
	-- Global settings
	UI.globalSettings = {}
	function UI.globalSettings.build()
		--if true then return end
		local panel = CreateFrame("Frame", appName.."_globalConf", UIParent)
		panel.name = "ExiWoW"
		InterfaceOptions_AddCategory(panel)

		local gPadding = 30;
		local gBottom = 40;

		-- Create the buttons
		local function createCheckbutton(suffix, parent, attach, x_loc, y_loc, displayname, tooltip)
			local checkbutton = CreateFrame("CheckButton", appName .. "_globalConf_"..suffix, parent, "ChatConfigCheckButtonTemplate");
			checkbutton.tooltip = tooltip;
			checkbutton:SetPoint(attach, x_loc, y_loc);
			getglobal(checkbutton:GetName() .. 'Text'):SetText(displayname);
			return checkbutton;
		end

		local n = 0;
		createCheckbutton("enable_in_dungeons", panel, "TOPLEFT", gPadding,-gPadding-gBottom*n, "Enable in Dungeons", "Some actions may still be disabled in dungeons due to API restrictions");
		n = n+1;
		createCheckbutton("enable_public", panel, "TOPLEFT", gPadding,-gPadding-gBottom*n, "Enable Public", "Allows ANYONE to use actions on you.\n(Some functionality may still be restricted by the API)");
		n = n+1;
		createCheckbutton("taunt_female", panel, "TOPLEFT", gPadding,-gPadding-gBottom*n, "Enable Female Actions", "Turn off to prevent certain actions by females to be used against you.");
		n = n+1;
		createCheckbutton("taunt_male", panel, "TOPLEFT", gPadding,-gPadding-gBottom*n, "Enable Male Actions", "Turn off to prevent certain actions by males to be used against you.");
		n = n+1;
		createCheckbutton("taunt_other", panel, "TOPLEFT", gPadding,-gPadding-gBottom*n, "Enable Other Actions", "Turn off to prevent certain actions by other genders to be used against you.");
		
		local prefix = appName.."_globalConf_";
		n = 0
		createSlider(prefix.."takehit_rp_rate", panel, "TOPRIGHT", -gPadding,-gPadding-gBottom*n, "1", "60", "Hit Text Limit", 1, 60, 1, "Sets minimum time in seconds between RP texts received from being affected by an attack or spell.", function(self, val)
			setValueInTitle(self, " ("..val.." sec)");
		end);
		n = n+1
		createSlider(prefix.."spell_text_freq", panel, "TOPRIGHT", -gPadding,-gPadding-gBottom*n, "0%", "400%", "Spell RP Text Chance", 0, 4, 0.1, "Sets the chance of a viable spell triggering an RP text.\nThis is multiplied by the spell's internal chance, so even at 100% it's not a guarantee. Default = 100%", function(self, val)
			setValueInTitle(self, " ("..math.floor(val*100).."%)");
		end);
		n = n+1
		createSlider(prefix.."swing_text_freq", panel, "TOPRIGHT", -gPadding,-gPadding-gBottom*n, "0%", "100%", "Melee Text Chance", 0, 1, 0.05, "Chance of a text triggering on a melee hit. Crits are 4x this value. Default = 15%", function(self, val)
			setValueInTitle(self, " ("..math.floor(val*100).."%)");
		end);
		n = n+1
		createSlider(prefix.."taunt_freq", panel, "TOPRIGHT", -gPadding,-gPadding-gBottom*n, "0%", "100%", "NPC whisper chance", 0, 1, 0.05, "Chance of NPCs whispering you. 0 turns it off.", function(self, val)
			setValueInTitle(self, " ("..math.floor(val*100).."%)");
		end);
		n = n+1
		createSlider(prefix.."taunt_rp_rate", panel, "TOPRIGHT", -gPadding,-gPadding-gBottom*n, "0", "300", "NPC Whisper Limit", 0, 300, 1, "Minimum time between receiving NPC whispers in combat. Default is 30.", function(self, val)
			setValueInTitle(self, " ("..val.." sec)");
		end);
		
				
		panel.okay = function (self) 

			local gs = globalStorage;
			local prefix = appName.."_globalConf_";
			gs.takehit_rp_rate = getglobal(prefix.."takehit_rp_rate"):GetValue();
			gs.spell_text_freq = getglobal(prefix.."spell_text_freq"):GetValue();
			gs.swing_text_freq = getglobal(prefix.."swing_text_freq"):GetValue();
			gs.taunt_freq = getglobal(prefix.."taunt_freq"):GetValue();
			gs.taunt_rp_rate = getglobal(prefix.."taunt_rp_rate"):GetValue();
			
			
			gs.enable_in_dungeons = getglobal(prefix.."enable_in_dungeons"):GetChecked();
			gs.enable_public = getglobal(prefix.."enable_public"):GetChecked();
			gs.taunt_female = getglobal(prefix.."taunt_female"):GetChecked();
			gs.taunt_male = getglobal(prefix.."taunt_male"):GetChecked();
			gs.taunt_other = getglobal(prefix.."taunt_other"):GetChecked();

		end;
		panel.cancel = function (self)  UI.drawGlobalSettings(); end;
	end

	function UI.globalSettings.update()
		--if true then return end
		local gs = globalStorage;
		local prefix = appName.."_globalConf_";
		getglobal(prefix.."takehit_rp_rate"):SetValue(gs.takehit_rp_rate);
		getglobal(prefix.."spell_text_freq"):SetValue(gs.spell_text_freq);
		getglobal(prefix.."swing_text_freq"):SetValue(gs.swing_text_freq);
		getglobal(prefix.."taunt_freq"):SetValue(gs.taunt_freq);
		getglobal(prefix.."taunt_rp_rate"):SetValue(gs.taunt_rp_rate);
		getglobal(prefix.."enable_in_dungeons"):SetChecked(gs.enable_in_dungeons);
		getglobal(prefix.."enable_public"):SetChecked(gs.enable_public);
		getglobal(prefix.."taunt_female"):SetChecked(gs.taunt_female);
		getglobal(prefix.."taunt_male"):SetChecked(gs.taunt_male);
		getglobal(prefix.."taunt_other"):SetChecked(gs.taunt_other);
	end



export("UI", UI, {
	talkbox = UI.talkbox,
	refreshAll = UI.refreshAll,
}, UI)
	

	
