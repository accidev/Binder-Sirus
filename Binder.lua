function Binder_OnLoad(self)
	out_frame("Binder загружен. Пиши /binder для помощи");
	self:RegisterEvent("ADDON_LOADED");

	SLASH_BINDER1 = "/binder";
	SlashCmdList["BINDER"] = function(cmd, editbox)
		local command, rest = cmd:match("^(%S*)%s*(.-)$");
		if command == "load" and rest ~= "" then
			Load_Profile(rest);
		elseif command == "toggle" then
			Binder_Toggle();
		elseif command == "info" then
			out_frame("Оптимизировано и переведено: Accidev");
			out_frame("Обновлено: 6/6/2024")
			out_frame("Поддерживает сохранение биндов для WoW Sirus + ElvUI.")
		else
			out_frame("Команды Binder:");
			out_frame("  - /binder toggle - Открывает основное окно.");
			out_frame("  - /binder load (name) - Загружает профиль с 'name', регистр учитывается.");
		end
	end
	LibKeyBound = LibStub('LibKeyBound-1.0')
end

function Binder_OnEvent(self, event, ...)
	if (event == "ADDON_LOADED") then
		local addonName = ...;
		if addonName == "ElvUI" then
			Binder_ElvUI_OnLoad();
		end
		Binder_MinimapButton_OnLoad();
		Minimap_Checkbox_WhenLoaded();
	end
end

function Binder_ElvUI_OnLoad()
	out_frame("ElvUI загружен. Добавлены дополнительные настройки для ElvUI.");
end

function out_frame(text)
	DEFAULT_CHAT_FRAME:AddMessage(text)
end

function out(text)
	UIErrorsFrame:AddMessage(text, 1.0, 1.0, 0, 1, 10)
end

function Binder_Toggle()
	local frame = getglobal("Binder_Frame")
	Selection = false;
	if (frame) then
		if (frame:IsVisible()) then
			frame:Hide();
			Binder_Title:Hide();
			Description_InputBox:Hide();
			Name_Input_Frame:Hide();
			ApplyOrDelete_Frame:Hide();
			Description_Frame:Hide();
			Selection_Frame:Hide();
			Loading_Frame:Hide();
			Options_Frame:Hide();
			Creation_Frame:Hide();
			Description_Input_Frame:Hide();
			Divider_Frame1:Hide();
			Divider_Frame2:Hide();
			Name_InputBox:SetText("");
			Description_InputBox:SetText("");
		else
			frame:Show();
			Binder_Title:Show();
			Name_Input_Frame:Show();
			Description_InputBox:Show();
			ApplyOrDelete_Frame:Show();
			Description_Frame:Show();
			Selection_Frame:Show();
			Loading_Frame:Show();
			Options_Frame:Show();
			Creation_Frame:Show();
			Description_Input_Frame:Show();
			Divider_Frame1:Show();
			Divider_Frame2:Show();
			Name_InputBox:SetText("");
			Description_InputBox:SetText("");
			BinderEntry1:UnlockHighlight();
			BinderEntry2:UnlockHighlight();
			BinderEntry3:UnlockHighlight();
			BinderEntry4:UnlockHighlight();
			BinderEntry5:UnlockHighlight();
		end
	end
end

ProfileName_OnButton = "";
Currently_Selected_Profile_Num = 0;
Selection = false;

function BinderScrollBar_Update()
	local line;
	local lineplusoffset;
	FauxScrollFrame_Update(BinderScrollBar, Binder_Settings.ProfilesCreated, 5, 19);
	for line = 1, 5 do
		lineplusoffset = line + FauxScrollFrame_GetOffset(BinderScrollBar);
		if (lineplusoffset < (Binder_Settings.ProfilesCreated + 1)) then
			getglobal("BinderEntry" .. line):SetText(Binder_Settings.Profiles[lineplusoffset].Name);
			getglobal("BinderEntry" .. line):Show();
		else
			getglobal("BinderEntry" .. line):Hide();
		end
	end

	if (Currently_Selected_Profile_Num == 0) then
	else
		if (BinderEntry1:GetText() == Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name) then
			BinderEntry1:LockHighlight()
		else
			BinderEntry1:UnlockHighlight();
		end

		if (BinderEntry2:GetText() == Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name) then
			BinderEntry2:LockHighlight()
		else
			BinderEntry2:UnlockHighlight();
		end

		if (BinderEntry3:GetText() == Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name) then
			BinderEntry3:LockHighlight()
		else
			BinderEntry3:UnlockHighlight();
		end

		if (BinderEntry4:GetText() == Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name) then
			BinderEntry4:LockHighlight()
		else
			BinderEntry4:UnlockHighlight();
		end

		if (BinderEntry5:GetText() == Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name) then
			BinderEntry5:LockHighlight()
		else
			BinderEntry5:UnlockHighlight();
		end
	end
end

function ProfileSelection_OnClick(self)
	ProfileName_OnButton = self:GetText()

	for i = 1, Binder_Settings.ProfilesCreated do
		if (ProfileName_OnButton == Binder_Settings.Profiles[i].Name) then
			Currently_Selected_Profile_Num = i
		end
	end

	if Currently_Selected_Profile_Num ~= 0 then
		Description_Update(Currently_Selected_Profile_Num)
	end
	Selection = true

	BinderScrollBar_Update()
end

function Description_Update(profilenum)
	if (profilenum == nil) or (Binder_Settings.Profiles[profilenum] == nil) then
		Description_Frame_Text2:SetText("")
	else
		Description_Frame_Text2:SetText(Binder_Settings.Profiles[profilenum].Description)
	end
end

function Create_Button_OnUpdate()
	if (Name_InputBox:GetText() == "") then
		Create_Button:Disable()
	else
		Create_Button:Enable()
	end
end

function Binder_CreateButton_Details(tt, ldb)
	tt:SetText(
		"Создаст новый профиль привязок клавиш с введенным именем, используя текущие привязки клавиш. (Описание необязательно)")
end

function Binder_CreateButton_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_RIGHT")
	Binder_CreateButton_Details(GameTooltip)
end

Binder_Settings = {
	ProfilesCreated = 0,
	Profiles = {}
}

function Create_OnClick(arg1)
	local exists = false;

	for i = 1, Binder_Settings.ProfilesCreated do
		namecheck = Binder_Settings.Profiles[i].Name
		if (Name_InputBox:GetText() == namecheck) then
			exists = true
			out_frame("Профиль '" .. Binder_Settings.Profiles[i].Name .. "' не создан, потому что он уже существует.")
			out("Профиль '" .. Binder_Settings.Profiles[i].Name .. "' не создан, потому что он уже существует.")
			Name_InputBox:SetText("")
		end
	end

	if (exists == true) then
	else
		local NewProfileNum = Binder_Settings.ProfilesCreated + 1;
		Binder_Settings.Profiles[NewProfileNum] = {
			Name = Name_InputBox:GetText(),
			Description = Description_InputBox
				:GetText(),
			The_Binds = {}
		}

		Create_Binds(NewProfileNum)

		Binder_Settings.ProfilesCreated = NewProfileNum

		out_frame("Binder Профиль создан: " .. Name_InputBox:GetText())
		out("Profile Создан: " .. Binder_Settings.Profiles[Binder_Settings.ProfilesCreated].Name)

		if (Description_InputBox:GetText() ~= "") then
			out_frame("Описание: " .. Description_InputBox:GetText())
		end

		Name_InputBox:SetText("");
		Description_InputBox:SetText("");

		BinderScrollBar_Update()
	end
	Name_InputBox:ClearFocus()
	SaveBindings(2)
end

function Create_Binds(profileNum)
	local TheAction, BindingOne, BindingTwo;
	local bindIndex = 1;
	for i = 1, GetNumBindings() do
		TheAction, BindingOne, BindingTwo = GetBinding(i)
		Binder_Settings.Profiles[profileNum].The_Binds[bindIndex] = {
			["TheAction"] = TheAction,
			["BindingOne"] = BindingOne,
			["BindingTwo"] = BindingTwo
		}
		bindIndex = bindIndex + 1;
	end

	if IsAddOnLoaded("ElvUI") then
		bindIndex = SaveElvUIBinds(profileNum, bindIndex);
	end
end

function SaveElvUIBinds(profileNum, bindIndex)
	local function saveElvUIBarBinds(barNum, bindIndex)
		for buttonNum = 1, 12 do
			local buttonName = "ElvUI_Bar" .. barNum .. "Button" .. buttonNum;
			local bind1, bind2 = GetBindingKey(buttonName);
			Binder_Settings.Profiles[profileNum].The_Binds[bindIndex] = {
				["TheAction"] = buttonName,
				["BindingOne"] = bind1,
				["BindingTwo"] = bind2
			}
			bindIndex = bindIndex + 1;
		end
		return bindIndex;
	end

	for barNum = 6, 10 do
		bindIndex = saveElvUIBarBinds(barNum, bindIndex);
	end
	return bindIndex;
end

BinderMinimapSettings = {
	Checkbox = nil,
	xposition = 300,
	yposition = 0,
}

function Binder_MinimapButton_OnLoad()
	Binder_MinimapButton:SetPoint("CENTER", BinderMinimapSettings.xposition, BinderMinimapSettings.yposition)
end

function Binder_MinimapButton_Reposition()
	local xlim = (GetScreenWidth() / 2)
	local ylim = (GetScreenHeight() / 2)

	if (BinderMinimapSettings.xposition > xlim) then
		BinderMinimapSettings.xposition = xlim
	end
	if (BinderMinimapSettings.xposition < (-1) * xlim) then
		BinderMinimapSettings.xposition = (-1) * xlim
	end
	if (BinderMinimapSettings.yposition > ylim) then
		BinderMinimapSettings.yposition = ylim
	end
	if (BinderMinimapSettings.yposition < (-1) * ylim) then
		BinderMinimapSettings.yposition = (-1) * ylim
	end

	Binder_MinimapButton:SetPoint("CENTER", BinderMinimapSettings.xposition, BinderMinimapSettings.yposition)
end

function Binder_MinimapButton_DraggingFrame_OnUpdate()
	local xcursor, ycursor = GetCursorPosition()

	local xpos = (xcursor / UIParent:GetEffectiveScale()) - (GetScreenWidth() / 2);
	local ypos = (ycursor / UIParent:GetEffectiveScale()) - (GetScreenHeight() / 2);

	BinderMinimapSettings.xposition = xpos
	BinderMinimapSettings.yposition = ypos

	Binder_MinimapButton_Reposition()
end

function Binder_MinimapButton_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_LEFT")
	Binder_MinimapButton_Details(GameTooltip)
end

function Binder_MinimapButton_Details(tt, ldb)
	tt:SetText("Binder|n|nЛевый клик: Открыть окно|nПравый клик: Переместить)")
end

function Minimap_Reset(arg1)
	BinderMinimapSettings.xposition = 0
	BinderMinimapSettings.yposition = 0
	Binder_MinimapButton_Reposition()
end

function Minimap_Reset_Details(tt, ldb)
	tt:SetText("Сбросит позицию кнопки |nна миникарте в центр экрана")
end

function Minimap_Reset_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_RIGHT")
	Minimap_Reset_Details(GameTooltip)
end

function Minimap_Checkbox_WhenLoaded()
	if (BinderMinimapSettings.Checkbox == 1) then
		Minimap_CheckButton1:SetChecked(true)
	else
		Minimap_CheckButton1:SetChecked(false)
	end
	Minimap_Checkbox_OnUpdate()
end

function Minimap_Checkbox_OnUpdate()
	if (Minimap_CheckButton1:GetChecked() == 1) then
		BinderMinimapSettings.Checkbox = 1
		Binder_MinimapButton:Hide()
	else
		BinderMinimapSettings.Checkbox = nil
		Binder_MinimapButton:Show()
	end
end

function Defaults_OnClick(arg1)
	LoadBindings(0)
	SaveBindings(2)
end

function Apply_OnClick()
	Load_Profile(ProfileName_OnButton);
end

function RemoveAllBinds()
	for i = 1, GetNumBindings() do
		command, key1, key2 = GetBinding(i);
		if (key1) then SetBinding(key1); end
		if (key2) then SetBinding(key2); end
	end
end

function Load_Profile(profile_name)
	Profile_Num = nil;
	for i = 1, Binder_Settings.ProfilesCreated do
		if (profile_name == Binder_Settings.Profiles[i].Name) then
			Profile_Num = i;
			break;
		end
	end

	if (Profile_Num == nil) then
		out_frame("Binder Профиль '" .. profile_name .. "' не найден.")
	else
		RemoveAllBinds();

		for i = 1, #Binder_Settings.Profiles[Profile_Num].The_Binds do
			local TheAction = Binder_Settings.Profiles[Profile_Num].The_Binds[i].TheAction
			local BindingOne = Binder_Settings.Profiles[Profile_Num].The_Binds[i].BindingOne
			local BindingTwo = Binder_Settings.Profiles[Profile_Num].The_Binds[i].BindingTwo
			if (BindingOne ~= nil) then
				SetBinding(BindingOne, TheAction)
			end
			if (BindingTwo ~= nil) then
				SetBinding(BindingTwo, TheAction)
			end
		end

		SaveBindings(2)
		LoadBindings(2)
		out_frame("Binder Профиль " .. profile_name .. " загружен.")
	end
end

function LoadElvUIBinds(profileNum)
	local function loadElvUIBarBinds(barNum)
		for buttonNum = 1, 12 do
			local binds = Binder_Settings.Profiles[profileNum].The_Binds[(barNum - 6) * 12 + buttonNum];
			if binds then
				SetBinding(binds.BindingOne, binds.TheAction)
				SetBinding(binds.BindingTwo, binds.TheAction)
			end
		end
	end

	for barNum = 6, 10 do
		loadElvUIBarBinds(barNum);
	end
end

function Apply_Button_OnUpdate()
	if (Selection == false) then
		Apply_Button:Disable()
	end
	if (Selection == true) then
		Apply_Button:Enable()
	end
end

function Binder_ApplyButton_Details(tt, ldb)
	tt:SetText("Эта кнопка применит|nтекущий выбранный|nпрофиль Binder")
end

function Binder_ApplyButton_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_RIGHT")
	Binder_ApplyButton_Details(GameTooltip)
end

function Update_Profile()
	local TheAction, BindingOne, BindingTwo;

	for i = 1, GetNumBindings() do
		TheAction, BindingOne, BindingTwo = GetBinding(i)
		Binder_Settings.Profiles[Currently_Selected_Profile_Num].The_Binds[i] = {
			["TheAction"] = TheAction,
			["BindingOne"] = BindingOne,
			["BindingTwo"] = BindingTwo
		}
	end

	out_frame("Binder Профиль: " ..
		Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name .. ", обновлен до текущих биндов.")
	out("Binder Профиль: " ..
		Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name .. ", обновлен до текущих биндов.")
end

function Update_Button_OnUpdate()
	if (Selection == false) then
		Update_Button:Disable()
	end
	if (Selection == true) then
		Update_Button:Enable()
	end
end

function Binder_UpdateButton_Details(tt, ldb)
	tt:SetText("Эта кнопка обновит привязки текущего выбранного профиля Binder")
end

function Binder_UpdateButton_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_RIGHT")
	Binder_UpdateButton_Details(GameTooltip)
end

function Binder_DeleteButton_Details(tt, ldb)
	tt:SetText("ВНИМАНИЕ!!! Если вы удалите профиль, вы НЕ сможете его восстановить. Будьте осторожны...")
end

function Binder_DeleteButton_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_RIGHT")
	Binder_DeleteButton_Details(GameTooltip)
end

function Delete_OnClick(arg1)
	if ProfileName_OnButton == nil or ProfileName_OnButton == "" then
		local profileFound = false
		for i = 1, Binder_Settings.ProfilesCreated do
			if Binder_Settings.Profiles[i].Name == nil or Binder_Settings.Profiles[i].Name == "" then
				Currently_Selected_Profile_Num = i
				profileFound = true
				break
			end
		end

		if not profileFound then
			out_frame("Ошибка: Профиль не выбран или профиль без имени не найден для удаления.")
			return
		else
			ProfileName_OnButton = "Профиль без имени"
		end
	end

	out_frame("Профиль " .. ProfileName_OnButton .. " удален")
	if (Currently_Selected_Profile_Num < Binder_Settings.ProfilesCreated) then
		for i = Currently_Selected_Profile_Num, Binder_Settings.ProfilesCreated - 1 do
			Binder_Settings.Profiles[i] = Binder_Settings.Profiles[i + 1]
		end
		Binder_Settings.Profiles[Binder_Settings.ProfilesCreated] = nil
	else
		Binder_Settings.Profiles[Binder_Settings.ProfilesCreated] = nil
	end

	Binder_Settings.ProfilesCreated = Binder_Settings.ProfilesCreated - 1
	Currently_Selected_Profile_Num = 0
	Selection = false
	BinderScrollBar_Update()
end

function Hide_Areyousure()
	Areyousure_Frame:Hide()
	Selection = false
end

function Delete_Button_OnUpdate()
	if (Selection == false) then
		Delete_Button:Disable()
	end
	if (Selection == true) then
		Delete_Button:Enable()
	end
end

function DeleteAll_Button_OnClick()
	for i = 1, Binder_Settings.ProfilesCreated do
		Binder_Settings.Profiles[i] = nil
	end
	Currently_Selected_Profile_Num = 0
	Binder_Settings.ProfilesCreated = 0
	BinderScrollBar_Update()
	out_frame("Все профили удалены.")
end

function DeleteAll_Button_OnUpdate()
	if (Currently_Selected_Profile_Num == 0) then
	else
		if (Binder_Settings.Profiles[Currently_Selected_Profile_Num].Name == "Удалить все") then
			DeleteAll_Button:Enable()
		else
			DeleteAll_Button:Disable()
		end
	end
end

function Close_Button_Details(tt, ldb)
	tt:SetText("Закрыть")
end

function Close_Button_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_RIGHT")
	Close_Button_Details(GameTooltip)
end

local f = CreateFrame("frame")
local LibKeyBound = LibStub:GetLibrary("LibKeyBound-1.0")

f:RegisterEvent("PLAYER_LOGIN")

f:SetScript("OnEvent", function(self, event, ...)
	if self[event] then
		return self[event](self, event, ...)
	end
end)

f.BindMapping = {
	ActionButton1 = "ACTIONBUTTON1",
	ActionButton2 = "ACTIONBUTTON2",
	ActionButton3 = "ACTIONBUTTON3",
	ActionButton4 = "ACTIONBUTTON4",
	ActionButton5 = "ACTIONBUTTON5",
	ActionButton6 = "ACTIONBUTTON6",
	ActionButton7 = "ACTIONBUTTON7",
	ActionButton8 = "ACTIONBUTTON8",
	ActionButton9 = "ACTIONBUTTON9",
	ActionButton10 = "ACTIONBUTTON10",
	ActionButton11 = "ACTIONBUTTON11",
	ActionButton12 = "ACTIONBUTTON12",
	MultiBarBottomLeftButton1 = "MULTIACTIONBAR1BUTTON1",
	MultiBarBottomLeftButton2 = "MULTIACTIONBAR1BUTTON2",
	MultiBarBottomLeftButton3 = "MULTIACTIONBAR1BUTTON3",
	MultiBarBottomLeftButton4 = "MULTIACTIONBAR1BUTTON4",
	MultiBarBottomLeftButton5 = "MULTIACTIONBAR1BUTTON5",
	MultiBarBottomLeftButton6 = "MULTIACTIONBAR1BUTTON6",
	MultiBarBottomLeftButton7 = "MULTIACTIONBAR1BUTTON7",
	MultiBarBottomLeftButton8 = "MULTIACTIONBAR1BUTTON8",
	MultiBarBottomLeftButton9 = "MULTIACTIONBAR1BUTTON9",
	MultiBarBottomLeftButton10 = "MULTIACTIONBAR1BUTTON10",
	MultiBarBottomLeftButton11 = "MULTIACTIONBAR1BUTTON11",
	MultiBarBottomLeftButton12 = "MULTIACTIONBAR1BUTTON12",
	MultiBarBottomRightButton1 = "MULTIACTIONBAR2BUTTON1",
	MultiBarBottomRightButton2 = "MULTIACTIONBAR2BUTTON2",
	MultiBarBottomRightButton3 = "MULTIACTIONBAR2BUTTON3",
	MultiBarBottomRightButton4 = "MULTIACTIONBAR2BUTTON4",
	MultiBarBottomRightButton5 = "MULTIACTIONBAR2BUTTON5",
	MultiBarBottomRightButton6 = "MULTIACTIONBAR2BUTTON6",
	MultiBarBottomRightButton7 = "MULTIACTIONBAR2BUTTON7",
	MultiBarBottomRightButton8 = "MULTIACTIONBAR2BUTTON8",
	MultiBarBottomRightButton9 = "MULTIACTIONBAR2BUTTON9",
	MultiBarBottomRightButton10 = "MULTIACTIONBAR2BUTTON10",
	MultiBarBottomRightButton11 = "MULTIACTIONBAR2BUTTON11",
	MultiBarBottomRightButton12 = "MULTIACTIONBAR2BUTTON12",
	MultiBarLeftButton1 = "MULTIACTIONBAR4BUTTON1",
	MultiBarLeftButton2 = "MULTIACTIONBAR4BUTTON2",
	MultiBarLeftButton3 = "MULTIACTIONBAR4BUTTON3",
	MultiBarLeftButton4 = "MULTIACTIONBAR4BUTTON4",
	MultiBarLeftButton5 = "MULTIACTIONBAR4BUTTON5",
	MultiBarLeftButton6 = "MULTIACTIONBAR4BUTTON6",
	MultiBarLeftButton7 = "MULTIACTIONBAR4BUTTON7",
	MultiBarLeftButton8 = "MULTIACTIONBAR4BUTTON8",
	MultiBarLeftButton9 = "MULTIACTIONBAR4BUTTON9",
	MultiBarLeftButton10 = "MULTIACTIONBAR4BUTTON10",
	MultiBarLeftButton11 = "MULTIACTIONBAR4BUTTON11",
	MultiBarLeftButton12 = "MULTIACTIONBAR4BUTTON12",
	MultiBarRightButton1 = "MULTIACTIONBAR3BUTTON1",
	MultiBarRightButton2 = "MULTIACTIONBAR3BUTTON2",
	MultiBarRightButton3 = "MULTIACTIONBAR3BUTTON3",
	MultiBarRightButton4 = "MULTIACTIONBAR3BUTTON4",
	MultiBarRightButton5 = "MULTIACTIONBAR3BUTTON5",
	MultiBarRightButton6 = "MULTIACTIONBAR3BUTTON6",
	MultiBarRightButton7 = "MULTIACTIONBAR3BUTTON7",
	MultiBarRightButton8 = "MULTIACTIONBAR3BUTTON8",
	MultiBarRightButton9 = "MULTIACTIONBAR3BUTTON9",
	MultiBarRightButton10 = "MULTIACTIONBAR3BUTTON10",
	MultiBarRightButton11 = "MULTIACTIONBAR3BUTTON11",
	MultiBarRightButton12 = "MULTIACTIONBAR3BUTTON12",
}

function f:GetHotkey()
	return LibKeyBound:ToShortKey(GetBindingKey(self:GetBindAction()));
end

function f:GetBindAction()
	return f.BindMapping[self:GetName()];
end

function f:SetKey(key)
	SetBinding(key, f.BindMapping[self:GetName()]);
end

function f:GetBindings()
	local keys;
	local binding = self:GetBindAction();
	for i = 1, select("#", GetBindingKey(binding)) do
		local hotKey = select(i, GetBindingKey(binding));
		if keys then
			keys = keys .. ", " .. GetBindingText(hotKey, "KEY_");
		else
			keys = GetBindingText(hotKey, "KEY_");
		end
	end
	return keys;
end

function f:ClearBindings()
	local binding = self:GetBindAction();
	while GetBindingKey(binding) do
		SetBinding(GetBindingKey(binding), nil);
	end
end

function f:PLAYER_LOGIN()
	for name, _ in pairs(f.BindMapping) do
		local button = getglobal(name);
		if button then
			local OnEnter = button:GetScript("OnEnter");
			button:SetScript("OnEnter", function(self)
				LibKeyBound:Set(self);
				return OnEnter and OnEnter(self);
			end);
			button.GetHotkey = self.GetHotkey;
			button.SetKey = self.SetKey;
			button.GetBindings = self.GetBindings;
			button.GetBindAction = self.GetBindAction;
			button.ClearBindings = self.ClearBindings;
		end
	end
	self:UnregisterEvent("PLAYER_LOGIN");
	self.PLAYER_LOGIN = nil;
end
