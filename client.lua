local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
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
local tabEnabled, tabLoaded, isDead, lastOpend, site, subSite = false, false, false, 0, 'cop', 'tab'
local PlayerData = {}

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

function REQUEST_NUI_FOCUS(bool)
	local PlayerPed = PlayerPedId()

	if (site ~= 'cop' and site ~= 'medic') or (subSite ~= 'tab' and subSite ~= 'pc') then
		ShowNotification('~r~Fehler beim einrichten des WGC UIs.')
		ShowNotification('~r~Fehler beim einrichten des WGC UIs!')
		return
	end

    SetNuiFocus(bool, bool)
	
	if bool == true then
		local openSite = 'https://pc.'..site..'net.li/tablet.php'
		if subSite == 'pc' then
			openSite = 'https://pc.'..site..'net.li/'
		end

		if IsPedInAnyVehicle(PlayerPed, false) and Config.OnlyInVehicle == true and Config.VehicleOpenType == 'pc' then
			openSite = 'https://pc.'..site..'net.li/'
		elseif Config.Animation == true and not IsPedInAnyVehicle(PlayerPed, false) then
			TaskPlayAnim(PlayerPed, 'anim_heist@arcade_combined@', 'world_human_stand_mobile@_male@_text@_idle_a', 8.0, -8.0, -1, 16, 0, false, false, false)
			SetCurrentPedWeapon(PlayerPed, GetHashKey('WEAPON_UNARMED'), true) 
			
			if not HasAnimDictLoaded('anim_heist@arcade_combined@') then
				RequestAnimDict('anim_heist@arcade_combined@')

				while not HasAnimDictLoaded('anim_heist@arcade_combined@') do
					Citizen.Wait(1)
				end
			end
		end
		
		SendNUIMessage({showtab = true, site = openSite, autoscale = Config.AutoScale and subSite == 'tab'})
    else
        SendNUIMessage({hidetab = true})
        SetNuiFocus(false, false)
		if Config.Animation == true then
			ClearPedTasks(PlayerPed)
		end
    end
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
			
			if Config.Animation == true then
				ClearPedTasks(PlayerPedId())
			end
		end
	end
end)

function canOpenTablet(system, type)
	local PlayerPed = PlayerPedId()
	local canOpen = not Config.OnlyInVehicle
	
	if Config.OnlyInVehicle == true and IsPedInAnyVehicle(PlayerPed, false) then
		if Config.InEmergencyVehicle == true then
			if GetVehicleClass(GetVehiclePedIsIn(PlayerPed, false)) == 18 then
				canOpen = true
			end
		end

		if #Config.Vehicles > 0 then
			local vehHash = GetEntityModel(GetVehiclePedIsIn(PlayerPed, false))
			for k,v in pairs(Config.Vehicles) do
				if (tonumber(v) and v == vehHash) or (tostring(v) and GetHashKey(v) == vehHash) then
					canOpen = true
					break
				end
			end
		end
	end

	if type == 'tab' and Config.NeededItem ~= nil and Config.NeededItem ~= 'nil' then 
		PlayerData = ESX.GetPlayerData()

		for k,v in pairs(PlayerData.inventory) do
			if v.name == Config.NeededItem and v.count > 0 then
				canOpen = true
				break
			end
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
	end
	
	return canOpen
end

RegisterNetEvent('wgc:openUI')
AddEventHandler('wgc:openUI', function(system, newSite) 
	if not isDead then
		if canOpenTablet(system, newSite) == true then
			if (GetGameTimer() - lastOpend) > 250 then
				site = system
				subSite = newSite
				lastOpend = GetGameTimer()
				tabEnabled = true
				REQUEST_NUI_FOCUS(true)
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
			TriggerEvent('wgc:openUI', 'cop', Config.HotkeyOpenType)
		elseif Config.MedicHotkey ~= nil and Config.MedicHotkey ~= "nil" and IsControlJustReleased(0, Keys[Config.MedicHotkey]) and not isDead then
			TriggerEvent('wgc:openUI', 'medic',  Config.HotkeyOpenType)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local letSleep = true

		for k,v in ipairs(Config.Zones) do
			if (PlayerData.job ~= nil and PlayerData.job.name == v.Job) or not v.Job then
				local distance = GetDistanceBetweenCoords(playerCoords, v.Coords, true)
			
				if distance < 50.0 then
					DrawMarker(v.Marker.type, v.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Marker.x, v.Marker.y, v.Marker.z, v.Marker.r, v.Marker.g, v.Marker.b, v.Marker.a, false, false, 2, v.Marker.rotate, nil, nil, false)
					letSleep = false
				end
			
				if distance <= v.Marker.x then
					letSleep = false
					ShowHelpNotification(v.Prompt)

					if IsControlJustReleased(0, Keys['E']) then
						TriggerEvent('wgc:openUI', v.System, v.OpenType)
					end
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
		TriggerEvent('wgc:openUI', 'cop', Config.CommandOpenType)
	end, false)

	RegisterCommand('medicnet',function(source, args)
		TriggerEvent('wgc:openUI', 'medic', Config.CommandOpenType)
	end, false)
end

Citizen.CreateThread(function()
	local timeout, l = false, 0
	
	while not tabLoaded do
		Citizen.Wait(0)
		l = l + 1
		if l > 500 then
			tabLoaded = true
			timeout = true
		end
    end
	
    if timeout == true then        
        return
    end
	
    REQUEST_NUI_FOCUS(false)
end)
