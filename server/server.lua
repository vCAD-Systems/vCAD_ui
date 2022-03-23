
function Checkusr(Identifier)
    local steamid  = false
    local license  = false
    print(json.encode(Identifier))

  for k,v in pairs(GetPlayerIdentifiers(source))do
    print(v)
        
      if string.sub(v, 1, string.len("steam:")) == "steam:" then
        steamid = v
      elseif string.sub(v, 1, string.len("license:")) == "license:" then
        license = v
      end
    
  end
end

-- Config Bearbeiten
-- Zones
RegisterServerEvent('vCAD:SaveZoneConfig')
AddEventHandler('vCAD:SaveZoneConfig', function(name, coords, system, type, job)
    local result = Checkusr(GetPlayerIdentifiers(source))

    result = false
	if result then
		local path = GetResourcePath(GetCurrentResourceName())
		local lines_config = lines_from(path.."/config/config_zones.lua")

		
		for k,v in pairs(lines_config) do
			if k == #lines_config then
				DeleteString(path.."/config/config_zones.lua", "}")
			end
		end

		local file = io.open(path.."/config/config_zones.lua", "a") 

		file:write("\n	{   --"..name)
		file:write("\n		Coords = "..coords..",")
		file:write("\n		Prompt = 'Drücke ~INPUT_CONTEXT~ um den PC zu nutzen.',")
		file:write("\n		System = '"..system.."',")
		file:write("\n		OpenType = '"..type.."',")
        file:write("\n      Job = '"..job.."'")
		file:write("\n  },")
		file:write("\n}")
		file:close()
	else
		TriggerClientEvent('esx:showNotification', xPlayer.source, 'Du hast nicht die Berechtigung um das zu machen.')
	end
end)

-- Katalog
RegisterServerEvent('vCAD:SaveKatalogConfig')
AddEventHandler('vCAD:SaveKatalogConfig', function(name, coords, PublicID)
	local result = Checkusr(GetPlayerIdentifiers(source))

	if result then

		local path = GetResourcePath(GetCurrentResourceName())
		local lines_config = lines_from(path.."/config/config_katalog.lua")

		
		for k,v in pairs(lines_config) do
			if k == #lines_config then
				DeleteString(path.."/config/config_katalog.lua", "}")
			end
		end

		local file = io.open(path.."/config/config_katalog.lua", "a") 

		file:write("\n	{   --"..name)
		file:write("\n		Coords = "..coords..",")
		file:write("\n		Prompt = 'Drücke ~INPUT_CONTEXT~ um den Katalog anzuschauen.',")
		file:write("\n		System = 'car',")
		file:write("\n		OpenType = 'katalog',")
        file:write("\n      PublicID = '"..PublicID.."',")
		file:write("\n  },")
		file:write("\n}")
		file:close()
	else
		TriggerClientEvent('esx:showNotification', xPlayer.source, 'Du hast nicht die Berechtigung um das zu machen.')
	end
end)

-- SonderZonen
RegisterServerEvent('vCAD:SaveSonderZonenConfig')
AddEventHandler('vCAD:SaveSonderZonenConfig', function(coords, PublicID, Type, Prompt)
	local result = Checkusr(GetPlayerIdentifiers(source))

	if result then

		local path = GetResourcePath(GetCurrentResourceName())
		local lines_config = lines_from(path.."/config/config_sonstiges.lua")

		
        if coords == nil or PublicID == nil or Type == nil or Prompt == nil then
            print("gibt ein nil wert")
            print("coords:"..coords)
            print("pid."..PublicID)
            print("Type:"..Type)
            print("Prompt:"..Prompt)
            return
        end


		for k,v in pairs(lines_config) do
			if k == #lines_config then
				DeleteString(path.."/config/config_sonstiges.lua", "}")
			end
		end

		local file = io.open(path.."/config/config_sonstiges.lua", "a") 

		file:write("\n	{")
		file:write("\n		Coords = "..coords..",")
		file:write("\n		Prompt = '"..Prompt.."',")
		file:write("\n		System = 'cop',")
		file:write("\n		OpenType = '"..Type.."',")
        file:write("\n      PublicID = '"..PublicID.."',")
		file:write("\n  },")
		file:write("\n}")
		file:close()
	else
		TriggerClientEvent('esx:showNotification', xPlayer.source, 'Du hast nicht die Berechtigung um das zu machen.')
	end
end)

function DeleteString(path, before)
    local inf = assert(io.open(path, "r+"), "Fehler beim Öffnen der Datei.")
    local lines = ""
    while true do
        local line = inf:read("*line")
		if not line then break end
		
		if line ~= before then lines = lines .. line .. "\n" end
    end
    inf:close()
    file = io.open(path, "w")
    file:write(lines)
    file:close()
end

function lines_from(file)
  lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

if Config.MySQL_Async and not Config.NeededItem == nil then
    MySQL.ready(function ()
        if type(Config.NeededItem) ~= 'table' then
            Check_Item(Config.NeededItem)
        elseif type(Config.NeededItem) == 'table' then
            for k, v in pairs(Config.NeededItem) do
                Check_Item(v)
            end
        end
    end)
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function Check_Item(name)
    MySQL.Async.fetchAll('SELECT * FROM items WHERE name = @name', {
        ['@name'] = name
    }, function(result)
        if result[1] then
            return
        else
            Item_Insert(name)
        end
    end)
end

local item_add = false
function Item_Insert(name)
    MySQL.Async.execute("INSERT INTO items(`name`, `label`, `can_remove`) VALUES (@name, @label, @remove)", {
        ['@name'] = name,
        ['@label'] = firstToUpper(name),
        ['@remove'] = 1
    }, function(rowsChange)
        if rowsChange ~= nil and item_add == false then
            item_add = true
            Item_Add_Function()
        end
    end)
end

function Item_Add_Function()
    while item_add do
        Wait(1000)
        print("Server neustarten, damit das Item in ESX Aufgenommen wird!!!")
        TriggerClientEvent('esx:showNotification', -1, 'Server neustarten, damit das Item in ESX Aufgenommen wird!!!')
    end
end