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

ESX = nil
local tabEnabled, tabLoaded, isDead, lastOpend, site, subSite = false, false, false, 0, nil, 'tab'
local katalogID, tab = nil, nil
local PlayerData = {}
local hasAlreadyEnteredMarker = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

function ShowNotification(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName(msg)
	DrawNotification(false, true)
end

function ShowHelpNotification(msg)
	BeginTextCommandDisplayHelp('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandDisplayHelp(0, false, true, -1)
end

function REQUEST_NUI_FOCUS(bool, reload)
	local PlayerPed = PlayerPedId()

	if (site ~= 'cop' and site ~= 'medic' and site ~= 'car') or (subSite ~= 'tab' and subSite ~= 'pc' and subSite ~= 'katalog' and subSite ~= 'strafen' and subSite ~= 'bewerben') then
		ShowNotification('~r~Fehler beim einrichten des vCAD UIs.')
		ShowNotification('~r~Fehler beim einrichten des vCAD UIs!')
		return
	end

	if bool == true then
		local openSite = getsite(site)
		Wait(100)

		if katalogID ~= nil and site == 'cop' and subSite == 'strafen' then
			openSite = 'https://copnet.ch/strafen?c='..katalogID
		end

		if katalogID ~= nil and site == 'cop' and subSite == 'bewerben' then
			openSite = 'https://copnet.ch/bewerben?c='..katalogID
		end

		if katalogID ~= nil and site == 'car' and subSite == 'katalog' then
			openSite = 'https://mechnet.ch/shop.php?sp='..katalogID
		end
		print(openSite)

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

			TaskPlayAnim(PlayerPed, "amb@world_human_seat_wall_tablet@female@base", "base" ,8.0, -8.0, -1, 50, 0, false, false, false)
			attachObject()
		end
    else
        SendNUIMessage({hidetab = true})
	SetNuiFocus(false, false)
		
	if Config.Animation == true or tab ~= nil then
		ClearPedTasks(PlayerPed)
		DeleteObject(tab)
		tab = nil
	end
    end
end

function getsite(system)
	if system == "cop" then
		return "https://copnet.ch/"
	elseif system == "medic" then
		return "https://medicnet.ch/"
	elseif system == "car" then
		return "https://mechnet.ch/"
	end
end

function attachObject()
	if tab ~= nil then
		DeleteObject(tab)
	end
		
	tab = CreateObject(GetHashKey("prop_cs_tablet"), 0, 0, 0, true, true, true)
	AttachEntityToEntity(tab, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0.17, 0.10, -0.13, 20.0, 180.0, 180.0, true, true, false, true, 1, true)
end

RegisterNUICallback("tablet-bus", function(data)
	if data.load then
		tabLoaded = true
	elseif data.hide then
		tabEnabled = false
		REQUEST_NUI_FOCUS(false)
	elseif data.click then
		lastOpend = GetGameTimer()
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if tabEnabled then
			SendNUIMessage({hidetab = true})
			SetNuiFocus(false, false)
			
			if Config.Animation == true or tab ~= nil then
				ClearPedTasks(PlayerPedId())
				DeleteObject(tab)
				tab = nil
			end
		end
	end
end)

function canOpenTablet(system, Ttype, pos)
	local PlayerPed = PlayerPedId()
	local canOpen = not Config.OnlyInVehicle
	
	if Config.OnlyInVehicle == true and IsPedInAnyVehicle(PlayerPed, false) then
		if Config.InEmergencyVehicle == true then
			if GetVehicleClass(GetVehiclePedIsIn(PlayerPed, false)) == 18 then
				canOpen = true
			end
		end

		if #Config.Vehicles[system] > 0 then
			local vehHash = GetEntityModel(GetVehiclePedIsIn(PlayerPed, false))

			for k,v in pairs(Config.Vehicles[system]) do
				if (tonumber(v) and v == vehHash) or (tostring(v) and GetHashKey(v) == vehHash) then
					canOpen = true
					break
				end
			end
		end
	end

	if pos or Ttype == 'katalog' or Ttype == 'strafen' or Ttype == 'bewerben' then
		return true
	end

	if Ttype == 'tab' and Config.NeededItem ~= nil and Config.NeededItem ~= 'nil' then 
		local found = false
		PlayerData = ESX.GetPlayerData()

		for k,v in pairs(PlayerData.inventory) do
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
	elseif system == 'car' and Ttype ~= 'katalog' and Config.CarNetJob ~= nil and Config.CarNetJob ~= 'nil' and PlayerData.job ~= nil then
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
	
	return canOpen
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
		if canOpenTablet(system, newSite, pos) == true then
			if (GetGameTimer() - lastOpend) > 250 then
				if site ~= system then
					site = system
					reloadTab = true
				end

				if subSite ~= newSite then
					subSite = newSite
					reloadTab = true
				end

				if pos ~= true and pos ~= false and katalogID ~= pos then
					katalogID = pos
					reloadTab = true
				end

				lastOpend = GetGameTimer()
				tabEnabled = true
				REQUEST_NUI_FOCUS(true, reloadTab)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if NetworkIsPlayerActive(PlayerId()) then
			local PlayerPed = PlayerPedId()

			if IsPedFatallyInjured(PlayerPed) and not isDead then
				isDead = true
					
				if tabEnabled then
					tabEnabled = false
					REQUEST_NUI_FOCUS(false)
				end
			elseif not IsPedFatallyInjured(PlayerPed) then
				isDead = false
			end
		end
		
		if Config.Hotkey ~= nil and Config.Hotkey ~= "nil" and IsControlJustReleased(0, Keys[Config.Hotkey]) and not isDead then
			if Keys[Config.Hotkey] then
				TriggerEvent('vCAD:openUI', 'cop', Config.HotkeyOpenType)
			else
				ShowNotification('~r~Fehler beim einrichten des vCAD UIs!')
				ShowNotification('~r~Der angegebene Config.Hotkey ist ungültig!')
			end
		end

		if Config.MedicHotkey ~= nil and Config.MedicHotkey ~= "nil" and IsControlJustReleased(0, Keys[Config.MedicHotkey]) and not isDead then
			if Keys[Config.MedicHotkey] then
				TriggerEvent('vCAD:openUI', 'medic',  Config.HotkeyOpenType)
			else
				ShowNotification('~r~Fehler beim einrichten des vCAD UIs!')
				ShowNotification('~r~Der angegebene Config.MedicHotkey ist ungültig!')
			end
		end

		if Config.CarHotkey ~= nil and Config.CarHotkey ~= "nil" and IsControlJustReleased(0, Keys[Config.CarHotkey]) and not isDead then
			if Keys[Config.CarHotkey] then
				TriggerEvent('vCAD:openUI', 'car',  Config.HotkeyOpenType)
			else
				ShowNotification('~r~Fehler beim einrichten des vCAD UIs!')
				ShowNotification('~r~Der angegebene Config.CarHotkey ist ungültig!')
			end
		end
	end
end)

Citizen.CreateThread(function()
	while Config.EnabledZones do
		Citizen.Wait(1)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local letSleep = true

		for k,v in ipairs(Config.Zones) do
			if (PlayerData.job ~= nil and PlayerData.job.name == v.Job) or not v.Job then
				local distance = #(playerCoords - v.Coords)
			
				if distance < 50.0 then
					DrawMarker(Config.Marker.type, v.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, Config.Marker.rotate, nil, nil, false)
					letSleep = false
				end
			
				if distance <= Config.Marker.x then
					letSleep = false
					ShowHelpNotification(v.Prompt)

					if IsControlJustReleased(0, Keys['E']) then
						TriggerEvent('vCAD:openUI', v.System, v.OpenType, true)
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
	while true do
		Citizen.Wait(1)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local letSleep = true

		local isinMarker = false

		for k, v in pairs(Config.SonderZonen) do
			if v ~= nil then
				local distance = #(playerCoords - v.Coords)
				if distance <= 20 then
					DrawMarker(Config.Marker.type, v.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, Config.Marker.rotate, nil, nil, false)
					letSleep = false
				end

				if distance <= Config.Marker.x then
					letSleep = false
					ShowHelpNotification(v.Prompt)

					if IsControlJustReleased(0, Keys['E']) then
						TriggerEvent('vCAD:openUI', v.System, v.OpenType, v.PublicID or true)
					end
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while Config.EnabledKatalog do
		Citizen.Wait(1)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local letSleep = true

		for k,v in ipairs(Config.Katalog) do
			local distance = #(playerCoords - v.Coords)
			
			if distance < 50.0 then
				DrawMarker(Config.Marker.type, v.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, Config.Marker.rotate, nil, nil, false)
				letSleep = false
			end
		
			if distance <= Config.Marker.x then
				letSleep = false
				ShowHelpNotification(v.Prompt)

				if IsControlJustReleased(0, Keys['E']) then
					TriggerEvent('vCAD:openUI', v.System, v.OpenType, v.PublicID or true)
				end
			end
		end

		if letSleep then
			Citizen.Wait(2500)
		end
	end
end)

if Config.Commands == true then
	RegisterCommand('copnet',function(source, args)
		TriggerEvent('vCAD:openUI', 'cop', Config.CommandOpenType)
	end, false)

	RegisterCommand('medicnet',function(source, args)
		TriggerEvent('vCAD:openUI', 'medic', Config.CommandOpenType)
	end, false)

	RegisterCommand('carnet',function(source, args)
		TriggerEvent('vCAD:openUI', 'car', Config.CommandOpenType)
	end, false)
end

RegisterCommand("vcadadd", function(source, args, rawCommand)
    if args[1] == 'pc' then
		if args[5] ~= nil then
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
	
			local location = vector3(coords.x, coords.y, coords.z - 1.0)
			local result = false
	
			for k, v in pairs(Config.CopNetJob) do
				if args[5] == v then
					result = true
				end
			end
	
			for k, v in pairs(Config.MedicNetJob) do
				if args[5] == v then
					result = true
				end
			end
	
			for k, v in pairs(Config.CarNetJob) do
				if args[5] == v then
					result = true
				end
			end
	
			if result then
	
				table.insert(Config.Zones, {
					Coords = location,
					Prompt = 'Drücke ~INPUT_CONTEXT~ um den PC zu nutzen.',
					System = args[3],
					OpenType = args[4],
					Job = args[5]
				})
	
				TriggerServerEvent('vCAD:SaveZoneConfig', args[2], location, args[3], args[4], args[5])
			else
				ESX.ShowNotification('~r~Es gibt keinen Job der je auf eines dieser PC´s zugreifen darf.')
			end
		else
			ESX.ShowNotification('~r~Nicht alle Daten angegeben.')
		end
	elseif args[1] == 'katalog' then
		local pid = Config.PublicID.Katalog
		if args[2] == nil then
			ESX.ShowNotification("Gib eine Beschreibung an um die Position in der Config wieder zu finden.")
			return
		end
		if args[3] == nil then
			ESX.ShowNotification("Du hast keine PublicID eingegeben, es wird die aus der Config genommen.")
			if Config.PublicID.Katalog == nil or Config.PublicID.Katalog == '' then
				ESX.ShowNotification("Keine PublicID gefunden. Vorgang abgebrochen...")
				return
			end
		else
			pid = args[3]
		end
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)

		local location = vector3(coords.x, coords.y, coords.z - 1.0)

		table.insert(Config.Katalog, {
			Coords = location,
			Prompt = 'Drücke ~INPUT_CONTEXT~ um den Katalog anzuschauen.',
			System = 'car',
			OpenType = 'katalog',
			PublicID = "'"..pid.."'"
		})

		TriggerServerEvent('vCAD:SaveKatalogConfig', args[2], location, pid)
	elseif args[1] == 'strafen' then
		local pid = nil
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)
		local Prompt = 'Drücke ~INPUT_CONTEXT~ um dir die Strafen anzuschauen.'

		if args[2] ~= nil then
			pid = args[2]

			local location = vector3(coords.x, coords.y, coords.z - 1.0)

			table.insert(Config.SonderZonen, {
				Coords = location,
				Prompt = Prompt,
				System = 'cop',
				OpenType = args[1],
				PublicID = "'"..pid.."'"
			})

			TriggerServerEvent('vCAD:SaveSonderZonenConfig', location, pid, args[1], Prompt)
		else
			if Config.PublicID.Strafen ~= nil or Config.PublicID.Strafen ~= '' then
				pid = Config.PublicID.Strafen
			end

			if pid ~= nil then
				local location = vector3(coords.x, coords.y, coords.z - 1.0)

				table.insert(Config.SonderZonen, {
					Coords = location,
					Prompt = Prompt,
					System = 'cop',
					OpenType = args[1],
					PublicID = "'"..pid.."'"
				})

				TriggerServerEvent('vCAD:SaveSonderZonenConfig', location, pid, args[1], Prompt)
			else
				ESX.ShowNotification("Keine ID angegeben")
			end
		end
	elseif args[1] == 'bewerben' then
		local pid = nil
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)
		local Prompt = 'Drücke ~INPUT_CONTEXT~ um dich zu Bewerben.'

		if args[2] ~= nil then
			pid = args[2]

			local location = vector3(coords.x, coords.y, coords.z - 1.0)

			table.insert(Config.SonderZonen, {
				Coords = location,
				Prompt = Prompt,
				System = 'cop',
				OpenType = args[1],
				PublicID = "'"..pid.."'"
			})

			TriggerServerEvent('vCAD:SaveSonderZonenConfig', location, pid, args[1], Prompt)
		else
			if Config.PublicID.Bewerbung ~= nil or Config.PublicID.Bewerbung ~= '' then
				pid = Config.PublicID.Bewerbung
			end

			if pid ~= nil then
				local location = vector3(coords.x, coords.y, coords.z - 1.0)

				table.insert(Config.SonderZonen, {
					Coords = location,
					Prompt = Prompt,
					System = 'cop',
					OpenType = args[1],
					PublicID = "'"..pid.."'"
				})

				TriggerServerEvent('vCAD:SaveSonderZonenConfig', location, pid, args[1], Prompt)
			else
				ESX.ShowNotification("Keine ID angegeben")
			end
		end
	end
end)


Citizen.CreateThread(function()
	TriggerEvent("chat:addSuggestion", "/vcadadd", "Generiert ein punkt mit dem zugang für ein PC, Strafen, Bewerber oder den Katalog",{ 
        {name = "möglichkeiten:", help = "pc, strafen, bewerben, katalog"},
	})
end)