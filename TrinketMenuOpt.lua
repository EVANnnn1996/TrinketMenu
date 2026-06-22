--[[ TrinketMenuOpt.lua : Options and sort window for TrinketMenu ]]

local L = TrinketMenu.L

TrinketMenu.CheckOptInfo = {
{"ShowIcon","ON",L["Opt_ShowIcon"],L["Opt_ShowIcon_Desc"]},
{"SquareMinimap","OFF",L["Opt_SquareMinimap"],L["Opt_SquareMinimap_Desc"],"ShowIcon"},
{"CooldownCount","OFF",L["Opt_CooldownCount"],L["Opt_CooldownCount_Desc"]},
{"TooltipFollow","OFF",L["Opt_TooltipFollow"],L["Opt_TooltipFollow_Desc"],"ShowTooltips"},
{"KeepOpen","OFF",L["Opt_KeepOpen"],L["Opt_KeepOpen_Desc"]},
{"KeepDocked","ON",L["Opt_KeepDocked"],L["Opt_KeepDocked_Desc"]},
{"Notify","OFF",L["Opt_Notify"],L["Opt_Notify_Desc"]},
{"DisableToggle","OFF",L["Opt_DisableToggle"],L["Opt_DisableToggle_Desc"],"ShowIcon"},
{"NotifyChatAlso","OFF",L["Opt_NotifyChatAlso"],L["Opt_NotifyChatAlso_Desc"]},
{"Locked","OFF",L["Opt_Locked"],L["Opt_Locked_Desc"]},
{"ShowTooltips","ON",L["Opt_ShowTooltips"],L["Opt_ShowTooltips_Desc"]},
{"NotifyThirty","ON",L["Opt_NotifyThirty"],L["Opt_NotifyThirty_Desc"]},
{"MenuOnShift","OFF",L["Opt_MenuOnShift"],L["Opt_MenuOnShift_Desc"]},
{"TinyTooltips","OFF",L["Opt_TinyTooltips"],L["Opt_TinyTooltips_Desc"],"ShowTooltips"},
{"SetColumns","OFF",L["Opt_SetColumns"],L["Opt_SetColumns_Desc"]},
{"LargeCooldown","ON",L["Opt_LargeCooldown"],L["Opt_LargeCooldown_Desc"],"CooldownCount"},
{"ShowHotKeys","ON",L["Opt_ShowHotKeys"],L["Opt_ShowHotKeys_Desc"]},
{"StopOnSwap","OFF",L["Opt_StopOnSwap"],L["Opt_StopOnSwap_Desc"]},
{"HideOnLoad","OFF",L["Opt_HideOnLoad"],L["Opt_HideOnLoad_Desc"]}
}

-- table.insert(TrinketMenu.CheckOptInfo,)

TrinketMenu.TooltipInfo = {
{"TrinketMenu_LockButton",L["TT_LockButton"],L["TT_LockButton_Desc"]},
{"TrinketMenu_Trinket0Check",L["TT_Trinket0Check"],L["TT_Trinket0Check_Desc"]},
{"TrinketMenu_Trinket1Check",L["TT_Trinket1Check"],L["TT_Trinket1Check_Desc"]},
{"TrinketMenu_SortPriority",L["TT_SortPriority"],L["TT_SortPriority_Desc"]},
{"TrinketMenu_SortDelay",L["TT_SortDelay"],L["TT_SortDelay_Desc"]},
{"TrinketMenu_SortKeepEquipped",L["TT_SortKeepEquipped"],L["TT_SortKeepEquipped_Desc"]},
{"TrinketMenu_Profiles",L["TT_Profiles"],L["TT_Profiles_Desc"]},
{"TrinketMenu_Delete",L["TT_Delete"],L["TT_Delete_Desc"]},
{"TrinketMenu_ProfilesDelete",L["TT_ProfilesDelete"],L["TT_ProfilesDelete_Desc"]},
{"TrinketMenu_ProfilesLoad",L["TT_ProfilesLoad"],L["TT_ProfilesLoad_Desc"]},
{"TrinketMenu_ProfilesSave",L["TT_ProfilesSave"],L["TT_ProfilesSave_Desc"]},
{"TrinketMenu_ProfileName",L["TT_ProfileName"],L["TT_ProfileName_Desc"]},
}

function TrinketMenu.InitOptions()
	TrinketMenu.CreateTimer("DragMinimapButton",TrinketMenu.DragMinimapButton,0,1)
	TrinketMenu.MoveMinimapButton()
	local item
	for i=1,table.getn(TrinketMenu.CheckOptInfo) do
		item = getglobal("TrinketMenu_Opt"..TrinketMenu.CheckOptInfo[i][1].."Text")
		if item then
			item:SetText(TrinketMenu.CheckOptInfo[i][3])
			item:SetTextColor(.95,.95,.95)
		end
	end
	TrinketMenu.Tab_OnClick(1)
	table.insert(UISpecialFrames,"TrinketMenu_OptFrame")
	TrinketMenu_Title:SetText("TrinketMenu "..TrinketMenu_Version)
	TrinketMenu_Tab1:SetText(L["TabOptions"])

	TrinketMenu_OptFrame:SetBackdropBorderColor(.3,.3,.3,1)
	TrinketMenu_SubOptFrame:SetBackdropBorderColor(.3,.3,.3,1)
	if TrinketMenu.QueueInit then
		TrinketMenu.QueueInit()
		TrinketMenu_Tab1:Show()
		TrinketMenu_OptFrame:SetHeight(326)
		TrinketMenu_SubOptFrame:SetPoint("TOPLEFT",TrinketMenu_OptFrame,"TOPLEFT",8,-50)
	else
		TrinketMenu_OptStopOnSwap:Hide() -- remove StopOnSwap option if queue not loaded
		TrinketMenu_Tab1:Hide() -- hide options tab if it's only tab
		TrinketMenu_OptFrame:SetHeight(300)
		TrinketMenu_SubOptFrame:SetPoint("TOPLEFT",TrinketMenu_OptFrame,"TOPLEFT",8,-24)
	end
	TrinketMenu_OptColumnsSlider:SetValue(TrinketMenuOptions.Columns)
	TrinketMenu_OptColumnsSliderText:SetText(string.format(L["TrinketsCount"],TrinketMenuOptions.Columns))
	TrinketMenu.ReflectLock()
	TrinketMenu.ReflectCooldownFont()
	TrinketMenu.ReflectKeyBindings()
end

function TrinketMenu.ToggleFrame(frame)
	if frame:IsVisible() then
		frame:Hide()
	else
		frame:Show()
	end
end

function TrinketMenu.OptFrame_OnShow()
	TrinketMenu.ValidateChecks()
	if TrinketMenu.CurrentlySorting then
		TrinketMenu.PopulateSort(TrinketMenu.CurrentlySorting)
	end
end

--[[ Minimap button ]]

function TrinketMenu.MoveMinimapButton()
	local xpos,ypos
	if TrinketMenuOptions.SquareMinimap=="ON" then
		xpos = 110 * cos(TrinketMenuOptions.IconPos or 0)
		ypos = 110 * sin(TrinketMenuOptions.IconPos or 0)
		xpos = math.max(-82,math.min(xpos,84))
		ypos = math.max(-86,math.min(ypos,82))
	else
		xpos = 80*cos(TrinketMenuOptions.IconPos or 0)
		ypos = 80*sin(TrinketMenuOptions.IconPos or 0)
	end
	TrinketMenu_IconFrame:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-xpos,ypos-52)
	if TrinketMenuOptions.ShowIcon=="ON" then
		TrinketMenu_IconFrame:Show()
	else
		TrinketMenu_IconFrame:Hide()
	end
end

function TrinketMenu.DragMinimapButton()
	local xpos,ypos = GetCursorPosition()
	local xmin,ymin = Minimap:GetLeft() or 400, Minimap:GetBottom() or 400
	xpos = xmin-xpos/Minimap:GetEffectiveScale()+70
	ypos = ypos/Minimap:GetEffectiveScale()-ymin-70
	TrinketMenuOptions.IconPos = math.deg(math.atan2(ypos,xpos))
	TrinketMenu.MoveMinimapButton()
end

function TrinketMenu.MinimapButton_OnClick()
	PlaySound("GAMEGENERICBUTTONPRESS")
	if arg1=="LeftButton" and TrinketMenuOptions.DisableToggle=="OFF" then
		TrinketMenu.ToggleFrame(TrinketMenu_MainFrame)
	else
		TrinketMenu.ToggleFrame(TrinketMenu_OptFrame)
	end
end

--[[ CheckButton ]]

function TrinketMenu.ValidateChecks()
	local check,button
	for i=1,table.getn(TrinketMenu.CheckOptInfo) do
		check = TrinketMenu.CheckOptInfo[i]
		button = getglobal("TrinketMenu_Opt"..check[1])
		if button then
			button:SetChecked(TrinketMenuOptions[check[1]]=="ON")
			if check[5] then
				if TrinketMenuOptions[check[5]]=="ON" then
					button:Enable()
					getglobal("TrinketMenu_Opt"..check[1].."Text"):SetTextColor(.95,.95,.95)
				else
					button:Disable()
					getglobal("TrinketMenu_Opt"..check[1].."Text"):SetTextColor(.5,.5,.5)
				end
			end
		end
	end
	TrinketMenu_OptColumnsSlider:SetAlpha((TrinketMenuOptions.SetColumns=="ON") and 1 or .5)
	TrinketMenu_OptColumnsSlider:EnableMouse((TrinketMenuOptions.SetColumns=="ON") and 1 or 0)
	TrinketMenu_OptColumnsSlider:SetValue(TrinketMenuOptions.Columns)
end

function TrinketMenu.OptColumnsSlider_OnValueChanged()
	if TrinketMenuOptions then
		TrinketMenuOptions.Columns = this:GetValue()
		TrinketMenu_OptColumnsSliderText:SetText(string.format(L["TrinketsCount"],TrinketMenuOptions.Columns))
		if TrinketMenu_MenuFrame:IsVisible() then
			TrinketMenu.BuildMenu()
		end
	end
end

function TrinketMenu.CheckButton_OnClick()
	local _,_,var = string.find(this:GetName(),"TrinketMenu_Opt(.+)")
	if TrinketMenuOptions[var] then
		TrinketMenuOptions[var] = this:GetChecked() and "ON" or "OFF"
		PlaySound(this:GetChecked() and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
		TrinketMenu.ValidateChecks()
	end

	if this==TrinketMenu_OptCooldownCount then
		TrinketMenu.WriteWornCooldowns()
		TrinketMenu.WriteMenuCooldowns()
	elseif this==TrinketMenu_OptLocked then
		TrinketMenu.DockWindows()
		TrinketMenu.ReflectLock()
	elseif this==TrinketMenu_OptKeepOpen or this==TrinketMenu_OptSetColumns then
		if TrinketMenuOptions.KeepOpen=="ON" then
			TrinketMenu.BuildMenu()
		end
	elseif this==TrinketMenu_OptKeepDocked then
		TrinketMenu.DockWindows()
	elseif this==TrinketMenu_OptLargeCooldown then
		TrinketMenu.ReflectCooldownFont()
	elseif this==TrinketMenu_OptSquareMinimap then
		TrinketMenu.MoveMinimapButton()
	elseif this==TrinketMenu_OptShowHotKeys then
		TrinketMenu.ReflectKeyBindings()
	elseif this==TrinketMenu_OptShowIcon then
		TrinketMenu.MoveMinimapButton()
	end
end

function TrinketMenu.ReflectLock()
	local c = TrinketMenuOptions.Locked=="ON" and 0 or .5
	TrinketMenu_OptFrame:SetBackdropBorderColor(c,c,c,1)
	TrinketMenu_MainFrame:SetBackdropColor(c,c,c,c)
	TrinketMenu_MainFrame:SetBackdropBorderColor(c,c,c,c*2)
	TrinketMenu_MenuFrame:SetBackdropColor(c,c,c,c)
	TrinketMenu_MenuFrame:SetBackdropBorderColor(c,c,c,c*2)
	TrinketMenu_MenuFrame:EnableMouse(c*2)
	TrinketMenu_OptLocked:SetChecked(1-c*2)
	local normalTexture = TrinketMenu_LockButton:GetNormalTexture()
	local pushedTexture = TrinketMenu_LockButton:GetPushedTexture()
	if c==0 then
		TrinketMenu_MainResizeButton:Hide()
		TrinketMenu_MenuResizeButton:Hide()
		normalTexture:SetTexCoord(.875,1,.125,.25)
		pushedTexture:SetTexCoord(.75,.875,.125,.25)
	else
		TrinketMenu_MainResizeButton:Show()
		TrinketMenu_MenuResizeButton:Show()
		normalTexture:SetTexCoord(.75,.875,.125,.25)
		pushedTexture:SetTexCoord(.875,1,.125,.25)
	end
end

function TrinketMenu.ReflectCooldownFont()
	TrinketMenu.SetCooldownFont("TrinketMenu_Trinket0")
	TrinketMenu.SetCooldownFont("TrinketMenu_Trinket1")
	for i=1,30 do
		TrinketMenu.SetCooldownFont("TrinketMenu_Menu"..i)
	end
end

function TrinketMenu.SetCooldownFont(button)
	local item = getglobal(button.."Time")
	if TrinketMenuOptions.LargeCooldown=="ON" then
		item:SetFont("Fonts\\FRIZQT__.TTF",16,"OUTLINE")
		item:SetTextColor(1,.82,0,1)
		item:ClearAllPoints()
		item:SetPoint("CENTER",button,"CENTER")
	else
		item:SetFont("Fonts\\ARIALN.TTF",14,"OUTLINE")
		item:SetTextColor(1,1,1,1)
		item:ClearAllPoints()
		item:SetPoint("BOTTOM",button,"BOTTOM")
	end
end


--[[ Titlebar buttons ]]

function TrinketMenu.SmallButton_OnClick()
	PlaySound("igMainMenuOptionCheckBoxOn")
	if this==TrinketMenu_CloseButton then
		TrinketMenu_OptFrame:Hide()
	elseif this==TrinketMenu_LockButton then
		TrinketMenuOptions.Locked = (TrinketMenuOptions.Locked=="ON") and "OFF" or "ON"
		TrinketMenu.DockWindows()
		TrinketMenu.ReflectLock()
	end
end

--[[ Tabs ]]

function TrinketMenu.Tab_OnClick(override)
	PlaySound("GAMEGENERICBUTTONPRESS")
	local id = override or this:GetID()
	local tab
	if TrinketMenu_ProfilesFrame then
		TrinketMenu_ProfilesFrame:Hide()
	end
	for i=1,3 do
		tab = getglobal("TrinketMenu_Tab"..i)
		if tab then
			tab:UnlockHighlight()
		end
	end
	getglobal("TrinketMenu_Tab"..id):LockHighlight()
	if id==1 then
		TrinketMenu_SubOptFrame:Show()
		if TrinketMenu_SubQueueFrame then
			TrinketMenu_SubQueueFrame:Hide()
		end
	else
		TrinketMenu_SubOptFrame:Hide()
		TrinketMenu_SubQueueFrame:Show()
		TrinketMenu.OpenSort(3-this:GetID())
	end
end