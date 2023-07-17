local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, ["F11"] = 344,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local SystemTitel = 'Copnet, Medicnet, Firenet oder Carnet?'

local tabEnabled, tabLoaded, isDead, lastOpend, site, subSite = false, false, false, 0, 'nil', 'tab'
local katalogID, tab = nil, nil
local hasAlreadyEnteredMarker = false

if Config.NativeUIEnabled then
	_menuPool  = NativeUI.CreatePool()
end

function ShowNotification(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName(msg)
	DrawNotification(false, true)
end

RegisterNetEvent('vCAD:ShowNotification')
AddEventHandler('vCAD:ShowNotification', function(msg)
	ShowNotification(msg)
end)

function ShowHelpNotification(msg)
	BeginTextCommandDisplayHelp('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandDisplayHelp(0, false, true, -1)
end

function CreateDialog(OnScreenDisplayTitle_shopmenu) --general OnScreenDisplay for KeyboardInput
	AddTextEntry(OnScreenDisplayTitle_shopmenu, OnScreenDisplayTitle_shopmenu)
	DisplayOnscreenKeyboard(1, OnScreenDisplayTitle_shopmenu, "", "", "", "", "", 32)
	while (UpdateOnscreenKeyboard() == 0) do
		DisableAllControlActions(0);
		Wait(0);
	end
	if (GetOnscreenKeyboardResult()) then
		local displayResult = GetOnscreenKeyboardResult()
		return displayResult
	end
end

function TOGGLE_NUI_FOCUS(bool, reload)
	if (site ~= 'cop' and site ~= 'medic' and site ~= 'car' and site ~= 'fd') or (subSite ~= 'tab' and subSite ~= 'pc' and subSite ~= 'katalog' and subSite ~= 'strafen' and subSite ~= 'bewerben' and subSite ~= 'beschwerden' and subSite ~= 'wanted' and subSite ~= 'calendar') then
		ShowNotification('~r~Fehler beim einrichten des vCAD UIs.')
		ShowNotification('~r~Fehler beim einrichten des vCAD UIs!')
		return
	end

	local PlayerPed = PlayerPedId()

	if bool == true then
		local openSite = GetURL(site)

		--print(site) 		--??
		--print(katalogID) 	--??
		--print(subSite) 	--??

		if subSite == 'katalog' or subSite == 'bewerben' or subSite == 'strafen' or subSite == "calendar" or subSite == "wanted" or subSite == "beschwerden" then
			if katalogID ~= nil then
				if site == 'car' and subSite == 'katalog' then
					openSite = openSite..'shop?sp='..katalogID
				elseif site == 'cop' and subSite == 'strafen' then
					openSite = openSite..'strafen?c='..katalogID
				elseif subSite == 'bewerben' then
					openSite = openSite..'bewerben?c='..katalogID
				elseif subSite == "beschwerden" then
					openSite = openSite..'beschweren?c='..katalogID
				elseif subSite == "wanted" then
					openSite = openSite..'wanted?c='..katalogID
				elseif subSite == "calendar" then
					openSite = openSite..'calendar?c='..katalogID
				else
					print('[vCAD_UI] Error: `site` oder `subSite` ist ungültig oder nicht angegeben.')
				end
			else
				print('[vCAD_UI] Error: `katalogID` ist ungültig oder nicht angegeben.')
				return
			end
		end

		if reload then
			SendNUIMessage({showtab = true, design = Config.Design, autoscale = Config.AutoScale and subSite == 'tab', site = openSite})
		else
			SendNUIMessage({showtab = true, design = Config.Design, autoscale = Config.AutoScale and subSite == 'tab'})
		end

		SetNuiFocus(bool, bool)

		if Config.Animation == true and subSite == 'tab' and not IsPedInAnyVehicle(PlayerPed, false) then
			SetCurrentPedWeapon(PlayerPed, GetHashKey('WEAPON_UNARMED'), true)
			RequestAnimDict("amb@world_human_seat_wall_tablet@female@base")

			while not HasAnimDictLoaded("amb@world_human_seat_wall_tablet@female@base") do
				Citizen.Wait(1)
			end

			TaskPlayAnim(PlayerPed, "amb@world_human_seat_wall_tablet@female@base", "base", 8.0, -8.0, -1, 50, 0, false, false, false)
			attachObject()
		end
    else
        CloseTab()
    end
end

function GetURL(system)
	if system == "cop" then
		return "https://copnet.ch/"
	elseif system == "medic" then
		return "https://medicnet.ch/"
	elseif system == "car" then
		return "https://mechnet.ch/"
	elseif system == "fd" then
		return "https://fdnet.ch/"
	end
end

function attachObject()
	if tab ~= nil then 
		DeleteObject(tab)
	end

	local PlayerPed = PlayerPedId()
	
	tab = CreateObject(GetHashKey("prop_cs_tablet"), 0, 0, 0, true, true, true)
	AttachEntityToEntity(tab, PlayerPed, GetPedBoneIndex(PlayerPed, 57005), 0.17, 0.10, -0.13, 20.0, 180.0, 180.0, true, true, false, true, 1, true)
end

RegisterNUICallback("tablet-bus", function(data)
	if data.load then
		tabLoaded = true
	elseif data.hide then
		TOGGLE_NUI_FOCUS(false)
		tabEnabled = false
	elseif data.click then
		lastOpend = GetGameTimer()
	end
end)

function CloseTab()
	SendNUIMessage({hidetab = true})
	SetNuiFocus(false, false)
	
	if Config.Animation == true or tab ~= nil then
		ClearPedTasks(PlayerPedId())
		DeleteObject(tab)
		tab = nil
	end
	
	katalogID = nil
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if tabEnabled then
			CloseTab()
		end
	end
end)

function canOpenTablet(system, newSite, pos)
	local PlayerPed = PlayerPedId()
	local canOpen = not Config.OnlyInVehicle
	local canOpenType = newSite

	if pos or newSite == 'katalog' or newSite == 'bewerben' or newSite == 'strafen' then
		return true, canOpenType
	end
	
	if Config.OnlyInVehicle == true and IsPedInAnyVehicle(PlayerPed, false) then
		if Config.InEmergencyVehicle == true then
			if GetVehicleClass(GetVehiclePedIsIn(PlayerPed, false)) == 18 then
				canOpen = true
				canOpenType = Config.VehicleOpenType
			end
		end

		if #Config.Vehicles[system] > 0 then
			local vehHash = GetEntityModel(GetVehiclePedIsIn(PlayerPed, false))
			for k,v in pairs(Config.Vehicles[system]) do
				if (tonumber(v) and v == vehHash) or (tostring(v) and GetHashKey(v) == vehHash) then
					canOpen = true
					canOpenType = Config.VehicleOpenType
					break
				end
			end
		end
	end
	
	return canOpen, canOpenType
end

RegisterNetEvent('vCAD:openUI')
AddEventHandler('vCAD:openUI', function(system, newSite, pos)
	local reloadTab = false

	if not system then
		print('[vCAD_UI] Error: `SYSTEM` Argument ist ungültig oder nicht angegeben.')
		return
	end

	if not newSite then
		print('[vCAD_UI] Error: `TYPE` Argument ist ungültig oder nicht angegeben.')
		return
	end

	if not isDead then
		local canOpen, canOpenType = canOpenTablet(system, newSite, pos)

		if canOpen == true then
			if (GetGameTimer() - lastOpend) > 250 then
				if site ~= system then
					site = system
					reloadTab = true
				end

				if subSite ~= canOpenType then
					subSite = canOpenType
					reloadTab = true
				end

				if pos ~= true and pos ~= false and katalogID ~= pos then
					katalogID = pos
					reloadTab = true
				end
				
				lastOpend = GetGameTimer()
				tabEnabled = true
				TOGGLE_NUI_FOCUS(true, reloadTab)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if Config.NativeUIEnabled then
			_menuPool:ProcessMenus()
		end

		if NetworkIsPlayerActive(PlayerId()) then
			local PlayerPed = PlayerPedId()

			if IsPedFatallyInjured(PlayerPed) and not isDead then
				isDead = true
					
				if tabEnabled then
					tabEnabled = false
					TOGGLE_NUI_FOCUS(false)
				end
			elseif not IsPedFatallyInjured(PlayerPed) then
				isDead = false
			end
		end
	end
end)

Citizen.CreateThread(function()
	while #Config.Zones > 0 and Config.EnabledZones do
		Citizen.Wait(1)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local letSleep = true

		for k,v in ipairs(Config.Zones) do
			local distance = #(playerCoords - v.Coords)
		
			if distance < 50.0 then
				DrawMarker(Config.Marker.type, v.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, Config.Marker.rotate, nil, nil, false)
				letSleep = false
				
				if distance <= Config.Marker.x then
					ShowHelpNotification(v.Prompt)

					if IsControlJustReleased(0, Keys['E']) then
						TriggerEvent('vCAD:openUI', v.System, v.OpenType, v.PublicID or true)
					end
				end
			end
		end

		if letSleep then
			Citizen.Wait(2500)
		end
	end
end)

Citizen.CreateThread(function()
	while #Config.Katalog > 0 and Config.EnabledKatalog do
		Citizen.Wait(1)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local letSleep = true

		for k,v in ipairs(Config.Katalog) do
			local distance = #(playerCoords - v.Coords)
		
			if distance < 50.0 then
				DrawMarker(Config.Marker.type, v.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, Config.Marker.rotate, nil, nil, false)
				letSleep = false

				if distance <= Config.Marker.x then
					ShowHelpNotification(v.Prompt)
	
					if IsControlJustReleased(0, Keys['E']) then
						TriggerEvent('vCAD:openUI', v.System, v.OpenType, v.PublicID or true)
					end
				end
			end
		end

		if letSleep then
			Citizen.Wait(2500)
		end
	end
end)

Citizen.CreateThread(function()
	while #Config.SonderZonen > 0 do
		Citizen.Wait(1)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local letSleep = true

		for k,v in ipairs(Config.SonderZonen) do
			if (v.OpenType == 'strafen' and Config.EnabledStrafen) or (v.OpenType == 'bewerben' and Config.EnabledBewerben) or (v.OpenType == 'beschwerden' and Config.EnabledBeschwerden) or (v.OpenType == 'wanted' and Config.EnabledFahndungen) or (v.OpenType == 'calendar' and Config.EnabledKalender) then
				local distance = #(playerCoords - v.Coords)
			
				if distance < 50.0 then
					DrawMarker(Config.Marker.type, v.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, Config.Marker.rotate, nil, nil, false)
					letSleep = false
			
					if distance <= Config.Marker.x then
						ShowHelpNotification(v.Prompt)
	
						if IsControlJustReleased(0, Keys['E']) then
							TriggerEvent('vCAD:openUI', v.System, v.OpenType, v.PublicID or true)
						end
					end
				end
			end
		end

		if letSleep then
			Citizen.Wait(2500)
		end
	end
end)

if Config.Hotkey ~= nil and Config.Hotkey ~= "nil" then
	RegisterKeyMapping('copnet', 'Copnet Tablet', 'keyboard', string.upper(Config.Hotkey))
end

if Config.MedicHotkey ~= nil and Config.MedicHotkey ~= "nil" then
	RegisterKeyMapping('medicnet', 'Medicnet Tablet', 'keyboard', string.upper(Config.MedicHotkey))
end

if Config.CarHotkey ~= nil and Config.CarHotkey ~= "nil" then
	RegisterKeyMapping('carnet', 'Carnet Tablet', 'keyboard', string.upper(Config.CarHotkey))
end

if Config.FDHotkey ~= nil and Config.FDHotkey ~= "nil" then
	RegisterKeyMapping('firenet', 'FireNet Tablet', 'keyboard', string.upper(Config.FDHotkey))
end

if Config.Commands.Tablet == true or (Config.Hotkey ~= nil and Config.Hotkey ~= "nil") then
	RegisterCommand('copnet',function(source, args)
		TriggerEvent('vCAD:openUI', 'cop', Config.OpenType)
	end, false)
end

if Config.Commands.Tablet == true or (Config.MedicHotkey ~= nil and Config.MedicHotkey ~= "nil") then
	RegisterCommand('medicnet',function(source, args)
		TriggerEvent('vCAD:openUI', 'medic', Config.OpenType)
	end, false)
end

if Config.Commands.Tablet == true or (Config.CarHotkey ~= nil and Config.CarHotkey ~= "nil") then
	RegisterCommand('carnet',function(source, args)
		TriggerEvent('vCAD:openUI', 'car', Config.OpenType)
	end, false)
end

if Config.Commands.Tablet == true or (Config.FDHotkey ~= nil and Config.FDHotkey ~= "nil") then
	RegisterCommand('firenet',function(source, args)
		TriggerEvent('vCAD:openUI', 'fd', Config.OpenType)
	end, false)
end

if Config.Commands.Gesetze ~= nil and Config.Commands.Gesetze ~= 'nil' then
	RegisterCommand("gesetze", function(source, args, rawCommand)
		TriggerEvent('vCAD:openUI', 'cop', 'strafen', Config.Commands.Gesetze)
	end)
end

RegisterNetEvent('vCAD:AddPunkt')
AddEventHandler('vCAD:AddPunkt', function(data, value)
	if data == 'Zones' then
		table.insert(Config.Zones, value)
	elseif data == 'Katalog' then
		table.insert(Config.Katalog, value)
	else
		table.insert(Config.SonderZonen, value)
		ShowNotification("!!!Damit dies Funktioniert, restarte bitte das Tablet!!!")
	end
end)

RegisterCommand("vcad", function(source, args, rawCommand)
	if Config.NativeUIEnabled then
		OpenMenu()

		Wait(100)
		xOpenMenu:Visible(not xOpenMenu:Visible())
	else
		if args[1] == 'pc' or args[1] == 'Pc' or args[1] == 'PC' or args[1] == 'pC' then
			local System = CreateDialog(SystemTitel)

			if System == 'Copnet' then
				System = 'cop'
			elseif System == 'Medicnet' then
				System = 'medic'
			elseif System == 'Carnet' then
				System = 'car'
			elseif System == 'Firenet' then
				System = 'fd'
			else
				ShowNotification('Falsche Angabe, Achte auf die Schreibweise ;)')
				return
			end

			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)

			local posi = vector3(coords.x, coords.y, coords.z -1.0)

			TriggerServerEvent('vCAD:SaveZoneConfig', posi, System, 'pc')
		end
	
		if args[1] == 'Strafen' or args[1] == 'strafen' or args[1] == 'STRAFEN' or args[1] == 'sTRAFEN' then
			local pid = CreateDialog('Bitte die Public ID eingeben!')

			if pid ~= nil or pid ~= '' then
				local ped = PlayerPedId()
				local coords = GetEntityCoords(ped)
				local posi = vector3(coords.x, coords.y, coords.z -1.0)
				local Prompt = 'Drücke ~INPUT_CONTEXT~ um dir die Strafen anzuschauen.'
			
				TriggerServerEvent('vCAD:SaveSonderZonenConfig', posi, pid, 'strafen', Prompt, 'cop')
			else
				ShowNotification('Keine Public ID eingegeben.')
				return
			end
		end
	
		if args[1] == 'bewerben' or args[1] == 'Bewerben' or args[1] == 'BEWERBEN' or args[1] == 'bEWERBEN' then
			local System = CreateDialog(SystemTitel)

			if System == 'Copnet' then
				System = 'cop'
			elseif System == 'Medicnet' then
				System = 'medic'
			elseif System == 'Carnet' then
				System = 'car'
			elseif System == 'Firenet' then
				System = 'fd'
			else
				ShowNotification('Falsche angabe')
				return
			end

			local pid = CreateDialog('Jetzt benötige ich die Public ID.')

			if pid ~= nil or pid ~= '' then
				local ped = PlayerPedId()
				local coords = GetEntityCoords(ped)
				local posi = vector3(coords.x, coords.y, coords.z -1.0)

				local Prompt = 'Drücke ~INPUT_CONTEXT~ um dich zu Bewerben.'
	
				TriggerServerEvent('vCAD:SaveSonderZonenConfig', posi, pid, 'bewerben', Prompt, System)
			else
				ShowNotification('Keine Public ID angegeben!')
				return
			end
		end
	
		if args[1] == 'katalog' or args[1] == 'Katalog' or args[1] == 'KATALOG' or args[1] == 'kATALOG' then
			local pid = CreateDialog('[VehicleShop] Gib die Public ID ein')
			
			if pid == nil or pid == '' then
				ShowNotification('Es wurde keine Public ID eingegeben.')
				return
			end

			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z - 1.0)

			TriggerServerEvent('vCAD:SaveKatalogConfig', posi, pid)
		end

		if args[1] == "beschwerden" or args[1] == "Beschwerden" or args[1] == "BESCHWERDEN" or args[1] == "bESCHWERDEN" then
			local System = CreateDialog(SystemTitel)

			System = CheckSystem(System)

			if System == false then
				ShowNotification('Falsche angabe')
			end

			local pid = CreateDialog('Jetzt benötige ich die Public ID.')

			if pid ~= nil or pid ~= '' then
				local ped = PlayerPedId()
				local coords = GetEntityCoords(ped)
				local posi = vector3(coords.x, coords.y, coords.z -1.0)

				local Prompt = 'Drücke ~INPUT_CONTEXT~ um dich zu Beschwerden.'
	
				TriggerServerEvent('vCAD:SaveSonderZonenConfig', posi, pid, 'beschwerden', Prompt, System)
			else
				ShowNotification('Keine Public ID angegeben!')
				return
			end
		end

		if args[1] == "kalender" or args[1] == "Kalender" or args[1] == "KALENDER" or args[1] == "kALENDER" then
			local System = CreateDialog(SystemTitel)

			System = CheckSystem(System)

			if System == false then
				ShowNotification('Falsche angabe')
			end

			local pid = CreateDialog('Jetzt benötige ich die Public ID.')

			if pid ~= nil or pid ~= '' then
				local ped = PlayerPedId()
				local coords = GetEntityCoords(ped)
				local posi = vector3(coords.x, coords.y, coords.z -1.0)

				local Prompt = 'Drücke ~INPUT_CONTEXT~ um dich zu Beschwerden.'
	
				TriggerServerEvent('vCAD:SaveSonderZonenConfig', posi, pid, 'calendar', Prompt, System)
			else
				ShowNotification('Keine Public ID angegeben!')
				return
			end
		end

		if args[1] == "fahndung" or args[1] == "Fahndung" or args[1] == "FAHNDUNG" or args[1] == "fAHNDUNG" then
			local pid = CreateDialog('Ich benötige die Public ID.')

			if pid ~= nil or pid ~= '' then
				local ped = PlayerPedId()
				local coords = GetEntityCoords(ped)
				local posi = vector3(coords.x, coords.y, coords.z -1.0)

				local Prompt = 'Drücke ~INPUT_CONTEXT~ um die Öffentliche Fahndungsliste einzusehen'
	
				TriggerServerEvent('vCAD:SaveSonderZonenConfig', posi, pid, 'wanted', Prompt, System)
			else
				ShowNotification('Keine Public ID angegeben!')
				return
			end
		end
	end
end)

if not Config.NativeUIEnabled then
	Citizen.CreateThread(function()
		TriggerEvent("chat:addSuggestion", "/vcad", "Generiert ein punkt mit dem zugang für ein PC, Strafen, Bewerber, Beschwerde, Kalender, Fahndung oder den Katalog",{ 
			{name = "möglichkeiten:", help = "pc, strafen, bewerben, katalog, beschwerden, kalender, fahndung"},
		})
	end)
end




if Config.NativeUIEnabled then
	function OpenMenu()
		_menuPool:Remove()
	
		local System = 'cop'
		local pid = nil
	
		if xOpenMenu ~= nil and xOpenMenu:Visible() then
			xOpenMenu:Visible(false)
			return
		end
	
		xOpenMenu = NativeUI.CreateMenu('vCAD', 'Hier kannst du Positionen Hinzufügen für das Tablet.', 5, 100)
		_menuPool:Add(xOpenMenu)
	
		-- Menu Punkte
	
		--[[
			local PcAdd = NativeUI.CreateItem('PC Hinzufügen', 'Fügt ein PC an deinem Aktuellen Standpunkt hinzu.')
		PcAdd.Activated = function(sender, item)
			OpenPcMenu()
	
			Wait(100)
			xOpenMenu:Visible(false)
			xOpenPcMenu:Visible(not xOpenPcMenu:Visible())
		end
		xOpenMenu:AddItem(PcAdd)
		]]
	
		local auswahl = {"~b~CopNet", "~r~MedicNet", "~y~CarNet", "~o~FireNet"}
		local xSystem = NativeUI.CreateListItem("System:", auswahl, 1)
		xOpenMenu:AddItem(xSystem)
	
		local xfrei = NativeUI.CreateItem('----------------------------------', '')
		xOpenMenu:AddItem(xfrei)
	
		local xPcSetzen = NativeUI.CreateItem('🖥️ Pc setzen', 'Setzt den PC für das System (~r~siehe oben~s~)')
		xPcSetzen.Activated = function(sender, item)
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z - 1.0)
			TriggerServerEvent('vCAD:SaveZoneConfig', posi, System, 'pc')
		end
		xOpenMenu:AddItem(xPcSetzen)
	
		local BewerbungenAdd = NativeUI.CreateItem('📓 Bewerbungspunkt Hinzufügen', 'Fügt ein PC Hinzu wo sich die Personen Bewerben können für das System (~r~siehe oben~s~).')
		BewerbungenAdd.Activated = function(sender, item)
			pid = CreateDialog('[Bewerber] Gib die Public ID ein')
	
			if pid == nil or pid == '' then
				ShowNotification('Du musst eine Public ID eingeben.')
				return
			end
	
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z - 1.0)
			local Prompt = 'Drücke ~INPUT_CONTEXT~ um dich zu Bewerben.'
	
			TriggerServerEvent('vCAD:SaveSonderZonenConfig', posi, pid, 'bewerben', Prompt, System)
		end
		xOpenMenu:AddItem(BewerbungenAdd)
	
		-------------------------------------------------------------------------------------------------------------------------
		local BeschwerdenAdd = NativeUI.CreateItem('🤬 Beschwerdepunkt Hinzufügen', 'Fügt ein PC Hinzu wo sich die Personen Beschwerden können für das System (~r~siehe oben~s~).')
		BeschwerdenAdd.Activated = function(sender, item)
			pid = CreateDialog('Gib die Public ID ein')
	
			if pid == nil or pid == '' then
				ShowNotification('Du musst eine Public ID eingeben.')
				return
			end
	
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z - 1.0)
			local Prompt = 'Drücke ~INPUT_CONTEXT~ um dich zu Beschweren.'
	
			TriggerServerEvent('vCAD:SaveSonderZonenConfig', posi, pid, 'beschwerden', Prompt, System)
		end
		xOpenMenu:AddItem(BeschwerdenAdd)
	
		local CalendarAdd = NativeUI.CreateItem('🗓️ Kalenderpunkt Hinzufügen', 'Fügt ein Punkt Hinzu, wo Spieler den Öffentlichen Kalender einsehen können. Für das System (~r~siehe oben~s).')
		CalendarAdd.Activated = function(sender, item)
			pid = CreateDialog('Gib die Public ID ein')
	
			if pid == nil or pid == '' then
				ShowNotification('Du musst eine Public ID eingeben.')
				return
			end
	
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z - 1.0)
			local Prompt = 'Drücke ~INPUT_CONTEXT~ um den Kalender einzusehen.'
	
			TriggerServerEvent('vCAD:SaveSonderZonenConfig', posi, pid, 'calendar', Prompt, System)
		end
		xOpenMenu:AddItem(CalendarAdd)
		-------------------------------------------------------------------------------------------------------------------------
	
	
	
		local xfrei = NativeUI.CreateItem('----------------------------------', '')
		xOpenMenu:AddItem(xfrei)
	
		local StrafenKatalogAdd = NativeUI.CreateItem('🔎 Strafen Katalog Hinzufügen', 'An diesem Punkt können die Spieler dann die Strafen einsehen.')
		StrafenKatalogAdd.Activated = function(sender, item)
			pid = CreateDialog('[Strafen] Gib die Public ID ein')
	
			if pid == nil or pid == '' then
				ShowNotification('Du musst eine Public ID eingeben.')
				return
			end
	
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z - 1.0)
			local Prompt = 'Drücke ~INPUT_CONTEXT~ um dir die Strafen anzuschauen.'
	
			TriggerServerEvent('vCAD:SaveSonderZonenConfig', posi, 'strafen', Prompt, System)
		end
		xOpenMenu:AddItem(StrafenKatalogAdd)
	
		local FahndungAdd = NativeUI.CreateItem('🚨 Fahndungspunkt Hinzufügen', 'An diesem Punkt können die Spieler die Öffentlichen Fahndungen einsehen.')
		FahndungAdd.Activated = function(sender, item)
			pid = CreateDialog('Gib die Public ID ein')
	
			if pid == nil or pid == '' then
				ShowNotification('Du musst eine Public ID eingeben.')
				return
			end
	
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z - 1.0)
			local Prompt = 'Drücke ~INPUT_CONTEXT~ um die Öffentliche Fahndungsliste einzusehen.'
	
			TriggerServerEvent('vCAD:SaveSonderZonenConfig', posi, pid, 'wanted', Prompt, System)
		end
		xOpenMenu:AddItem(FahndungAdd)
	
		local CarNetKatalogAdd = NativeUI.CreateItem('🚘 CarNet Katalog Hinzufügen', 'Hier ist es möglich den ~y~CarNet~s~ Katalog einzusehen.')
		CarNetKatalogAdd.Activated = function(sender, item)
			pid = CreateDialog('[VehicleShop] Gib die Public ID ein')
	
			if pid == nil or pid == '' then
				ShowNotification('Du musst eine Public ID eingeben.')
				return
			end
	
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z - 1.0)
	
			TriggerServerEvent('vCAD:SaveKatalogConfig', posi, pid)
		end
		xOpenMenu:AddItem(CarNetKatalogAdd)
	
	
	
		xOpenMenu.OnListChange = function(sender, item, index)
			if item == xSystem then
				System = item:IndexToItem(index)
	
				if System == '~b~CopNet' then
					System = 'cop'
				elseif System == '~r~MedicNet' then
					System = 'medic'
				elseif System == '~y~CarNet' then
					System = 'car'
				elseif System == '~o~FireNet' then
					System = 'fd'
				end
	
				print(System)
			end
		end
	
	
		_menuPool:RefreshIndex()
		_menuPool:MouseControlsEnabled (false);
		_menuPool:MouseEdgeEnabled (false);
		_menuPool:ControlDisablingEnabled(false);
	end
end