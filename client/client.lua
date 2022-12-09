local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local tabEnabled, tabLoaded, isDead, lastOpend, site, subSite = false, false, false, 0, nil, 'tab'
local katalogID, tab = nil, nil
local PlayerData = {}
if Config.NativeUIEnabled then
	_menuPool  = NativeUI.CreatePool()
end

RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
	PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent("QBCore:Client:OnJobUpdate")
AddEventHandler("QBCore:Client:OnJobUpdate", function(job)
	PlayerData.job = job
end)

function CreateDialog(OnScreenDisplayTitle_shopmenu)
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
	if (site ~= 'cop' and site ~= 'medic' and site ~= 'car') or (subSite ~= 'tab' and subSite ~= 'pc' and subSite ~= 'katalog' and subSite ~= 'strafen' and subSite ~= 'bewerben') then
		QBCore.Functions.Notify('Fehler beim einrichten des vCAD UIs!', 'error', 7500)
		return
	end

	local PlayerPed = PlayerPedId()

	if bool == true then
		local openSite = GetURL(site)

		--print(site) 		--??
		--print(katalogID) 	--??
		--print(subSite) 	--??

		if subSite == 'katalog' or subSite == 'bewerben' or subSite == 'strafen' then
			if katalogID ~= nil then
				if site == 'car' and subSite == 'katalog' then
					openSite = openSite..'shop?sp='..katalogID
				elseif site == 'cop' and subSite == 'strafen' then
					openSite = openSite..'strafen?c='..katalogID
				elseif subSite == 'bewerben' then
					openSite = openSite..'bewerben?c='..katalogID
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
	end
end

local function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
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

RegisterNetEvent('vCAD:ShowNotification')
AddEventHandler('vCAD:ShowNotification', function(msg)
	QBCore.Functions.Notify(msg, 'info', 7500)
end)

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

	if newSite == 'tab' and Config.NeededItem ~= nil and Config.NeededItem ~= 'nil' then 
		local found = false
		PlayerData = QBCore.Functions.GetPlayerData()

		for k,v in pairs(PlayerData.items) do
			if found == true then
				break
			elseif type(Config.NeededItem) == 'table' then
				for key,value in pairs(Config.NeededItem) do
					if v.name ~= nil and v.name ~= 'nil' and v.name == value and v.count > 0 then
						found = true
						break
					end
				end
			elseif v.name == Config.NeededItem and v.count > 0 then
				found = true
				break
			end
		end

		if found == false then
			return false
		end
	end

	if system == 'cop' and Config.CopNetJob ~= nil and Config.CopNetJob ~= 'nil' and PlayerData.job ~= nil then
		local found = false

		for k,v in pairs(Config.CopNetJob) do
			if PlayerData.job.name == v then
				found = true
				break
			end
		end

		if found == false then
			return false
		end
	elseif system == 'medic' and Config.MedicNetJob ~= nil and Config.MedicNetJob ~= 'nil' and PlayerData.job ~= nil then
		local found = false
		
		for k,v in pairs(Config.MedicNetJob) do
			if PlayerData.job.name == v then
				found = true
				break
			end
		end

		if found == false then
			return false
		end
	elseif system == 'car' and newSite ~= 'katalog' and Config.CarNetJob ~= nil and Config.CarNetJob ~= 'nil' and PlayerData.job ~= nil then
		local found = false
		
		for k,v in pairs(Config.CarNetJob) do
			if PlayerData.job.name == v then
				found = true
				break
			end
		end

		if found == false then
			return false
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
			if (PlayerData.job ~= nil and PlayerData.job.name == v.Job) or not v.Job then
				local distance = #(playerCoords - v.Coords)
			
				if distance < 50.0 then
					DrawMarker(Config.Marker.type, v.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, Config.Marker.rotate, nil, nil, false)
					letSleep = false
			
					if distance <= Config.Marker.x then
						DrawText3D(Config.Marker.x, Config.Marker.y, Config.Marker.z, v.Prompt)
	
						if IsControlJustReleased(0, 38) then
							TriggerEvent('vCAD:openUI', v.System, v.OpenType, true)
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
					DrawText3D(Config.Marker.x, Config.Marker.y, Config.Marker.z, v.Prompt)
	
					if IsControlJustReleased(0, 38) then
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
	while #Config.SonderZonen > 0 and (Config.EnabledStrafen or Config.EnabledBewerben) do
		Citizen.Wait(1)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local letSleep = true

		for k,v in ipairs(Config.SonderZonen) do
			if (v.OpenType == 'strafen' and Config.EnabledStrafen) or (v.OpenType == 'bewerben' and Config.EnabledBewerben) then
				local distance = #(playerCoords - v.Coords)
			
				if distance < 50.0 then
					DrawMarker(Config.Marker.type, v.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, Config.Marker.rotate, nil, nil, false)
					letSleep = false
			
					if distance <= Config.Marker.x then
						DrawText3D(Config.Marker.x, Config.Marker.y, Config.Marker.z, v.Prompt)
	
						if IsControlJustReleased(0, 38) then
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

if Config.Hotkey ~= nil and Config.Hotkey ~= 'nil' then
	RegisterKeyMapping('copnet', 'Copnet Tablet', 'keyboard', string.upper(Config.Hotkey))
end

if Config.MedicHotkey ~= nil and Config.MedicHotkey ~= "nil" then
	RegisterKeyMapping('medicnet', 'Medicnet Tablet', 'keyboard', string.upper(Config.MedicHotkey))
end

if Config.CarHotkey ~= nil and Config.CarHotkey ~= "nil" then
	RegisterKeyMapping('carnet', 'Carnet Tablet', 'keyboard', string.upper(Config.CarHotkey))
end

if Config.Commands.Tablet == true then
	RegisterCommand('copnet',function(source, args)
		TriggerEvent('vCAD:openUI', 'cop', Config.OpenType)
	end, false)

	RegisterCommand('medicnet',function(source, args)
		TriggerEvent('vCAD:openUI', 'medic', Config.OpenType)
	end, false)

	RegisterCommand('carnet',function(source, args)
		TriggerEvent('vCAD:openUI', 'car', Config.OpenType)
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
	end

	QBCore.Functions.Notify('!!!Wenn dies nicht Funktioniert, restarte bitte das Tablet mit', 'info', 7500)
	QBCore.Functions.Notify('/restart '..GetCurrentResourceName(), 'info', 7500)
end)

RegisterCommand("vcad", function(source, args, rawCommand)
	if Config.NativeUIEnabled then
		OpenMenu()

		Wait(100)
		xOpenMenu:Visible(not xOpenMenu:Visible())
	else
		OpenMenu()
	end
end)

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
	
		local auswahl = {"~b~CopNet", "~r~MedicNet", "~y~CarNet"}
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
				QBCore.Functions.Notify('Du musst eine Public ID eingeben.', 'error', 7500)
				return
			end
	
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z - 1.0)
			local Prompt = 'Drücke ~INPUT_CONTEXT~ um dich zu Bewerben.'
	
			TriggerServerEvent('vCAD:SaveSonderZonenConfig', posi, pid, 'bewerben', Prompt, System)
		end
		xOpenMenu:AddItem(BewerbungenAdd)
	
		local xfrei = NativeUI.CreateItem('----------------------------------', '')
		xOpenMenu:AddItem(xfrei)
	
		local StrafenKatalogAdd = NativeUI.CreateItem('🔎 Strafen Katalog Hinzufügen', 'An diesem Punkt können die Spieler dann die Strafen einsehen.')
		StrafenKatalogAdd.Activated = function(sender, item)
			pid = CreateDialog('[Strafen] Gib die Public ID ein')
	
			if pid == nil or pid == '' then
				QBCore.Functions.Notify('Du musst eine Public ID eingeben.', 'error', 7500)
				return
			end
	
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z - 1.0)
			local Prompt = 'Drücke ~INPUT_CONTEXT~ um dir die Strafen anzuschauen.'
	
			TriggerServerEvent('vCAD:SaveSonderZonenConfig', posi, 'strafen', Prompt, System)
		end
		xOpenMenu:AddItem(StrafenKatalogAdd)
	
		local CarNetKatalogAdd = NativeUI.CreateItem('🚘 CarNet Katalog Hinzufügen', 'Hier ist es möglich den ~y~CarNet~s~ Katalog einzusehen.')
		CarNetKatalogAdd.Activated = function(sender, item)
			pid = CreateDialog('[VehicleShop] Gib die Public ID ein')
	
			if pid == nil or pid == '' then
				QBCore.Functions.Notify('Du musst eine Public ID eingeben.', 'error', 7500)
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

if not Config.NativeUIEnabled then
	local menuLocation = 'topright' -- e.g. topright (default), topleft, bottomright, bottomleft
	local menu = MenuV:CreateMenu(false, 'vCAD', menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'vCAD')
	local menu2 = MenuV:CreateMenu(false, 'vCAD', menuLocation, 220, 20, 60, 'size-125', 'none', 'menuv', 'vCAD2')

	function OpenMenu()
		menu:ClearItems()
		local pcAdd = menu:AddButton({
			icon = '🖥️',
			label = 'PC setzen',
			value = 'pcadd',
			description = 'Setze einen Desktop PC'
		})

		local bpAdd = menu:AddButton({
			icon = '📙',
			label = 'Bewerbungspunkt hinzufügen',
			value = 'bewerberadd',
			description = 'Setze einen Bewerbungspunkt'
		})

		local skAdd = menu:AddButton({
			icon = '⚖️',
			label = 'Strafenkatalog hinzufügen',
			value = 'strafenadd',
			description = 'Setze einen Strafenkatalog Punkt'
		})

		local cnAdd = menu:AddButton({
			icon = '🚗',
			label = 'CarNet Katalog hinzufüge',
			value = 'katalogadd',
			description = 'Setze einen CarNet Katalog'
		})

		MenuV:OpenMenu(menu)

		pcAdd:On("select",function()
			OpenPcMenu(true)
		end)

		bpAdd:On("select",function()
			OpenPcMenu(false)
		end)

		skAdd:On("select",function()
			OpenStrafenMenu()
		end)

		cnAdd:On("select",function()
			OpenKatalogMenu()
		end)
	end

	function OpenPcMenu(pc)
		menu2:ClearItems()
		local copNet = menu2:AddButton({
			icon = '👮',
			label = 'CopNet',
			value = 'cop',
			description = 'Setze einen PC für CopNet'
		})

		local medNet = menu2:AddButton({
			icon = '👨‍⚕️',
			label = 'MedicNet',
			value = 'medic',
			description = 'Setze einen PC für MedicNet'
		})

		local carNet = menu2:AddButton({
			icon = '🚗',
			label = 'CarNet',
			value = 'car',
			description = 'Setze einen PC für CarNet'
		})

		MenuV:OpenMenu(menu2)

		copNet:On("select",function()
			local System = 'cop'
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z -1.0)
			local pid = nil

			if pc == false then
				pid = CreateDialog('Public ID:') 

				if pid == nil or pid == '' then
					QBCore.Functions.Notify('Du musst eine Public ID eingeben.', 'error', 7500)
					return
				end
				local Prompt = 'Drücke ~INPUT_CONTEXT~ um dich zu Bewerben.'
	
				TriggerServerEvent('vCAD:SaveSonderZonenConfig', posi, pid, 'bewerben', Prompt, System)
			end

			if pc then
				TriggerServerEvent('vCAD:SaveZoneConfig', posi, System, 'pc')
			end
		end)

		medNet:On("select",function()
			local System = 'medic'
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z -1.0)
			local pid = nil

			if pc == false then
				pid = CreateDialog('Public ID:') 

				if pid == nil or pid == '' then
					QBCore.Functions.Notify('Du musst eine Public ID eingeben.', 'error', 7500)
					return
				end
				local Prompt = 'Drücke ~INPUT_CONTEXT~ um dich zu Bewerben.'
	
				TriggerServerEvent('vCAD:SaveSonderZonenConfig', posi, pid, 'bewerben', Prompt, System)
			end

			if pc then
				TriggerServerEvent('vCAD:SaveZoneConfig', posi, System, 'pc')
			end
		end)

		carNet:On("select",function()
			local System = 'car'
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local posi = vector3(coords.x, coords.y, coords.z -1.0)
			local pid = nil

			if pc == false then
				pid = CreateDialog('Public ID:') 

				if pid == nil or pid == '' then
					QBCore.Functions.Notify('Du musst eine Public ID eingeben.', 'error', 7500)
					return
				end
				local Prompt = 'Drücke ~INPUT_CONTEXT~ um dich zu Bewerben.'
	
				TriggerServerEvent('vCAD:SaveSonderZonenConfig', posi, pid, 'bewerben', Prompt, System)
			end

			if pc then
				TriggerServerEvent('vCAD:SaveZoneConfig', posi, System, 'pc')
			end
		end)
	end

	function OpenStrafenMenu()
		local pid = CreateDialog('Gib die Public ID ein.')

		if pid == nil or pid == '' then
			QBCore.Functions.Notify('Du musst eine Public ID eingeben.', 'error', 7500)
			return
		end

		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)
		local posi = vector3(coords.x, coords.y, coords.z -1.0)
		local Prompt = 'Drücke ~INPUT_CONTEXT~ um dir die Strafen anzuschauen.'
	
		TriggerServerEvent('vCAD:SaveSonderZonenConfig', posi, pid, 'strafen', Prompt, 'cop')
	end

	function OpenKatalogMenu()
		pid = CreateDialog('[VehicleShop] Gib die Public ID ein')
	
		if pid == nil or pid == '' then
			QBCore.Functions.Notify('Du musst eine Public ID eingeben.', 'error', 7500)
			return
		end

		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)
		local posi = vector3(coords.x, coords.y, coords.z - 1.0)

		TriggerServerEvent('vCAD:SaveKatalogConfig', posi, pid)
	end
end