Config = {}

--[[
Aktiviere die Funktion wenn ihr fivem-mysql-async verwendet.
und Ihr möchtet das die items in Config.NeedetItem auf vorhandenheit überprüft werden.
]]
Config.MySQL_Async = false

--[[
    Activiere diese Funktion wenn ihr NativeUI nutzt.
    Hier Siehst du wie es mit NativeUI aussehen wird
    https://prnt.sc/7nCnguq0Z_wl

    !!! Ohne NativeUI wird ESX Menu genutzt !!!
]]
Config.NativeUIEnabled = false

--[[
Wollt Ihr die genannten Zonen Aktivieren?
true = ja
false = Nein
]]
Config.EnabledZones = true -- Computer Positionen
Config.EnabledKatalog = true
Config.EnabledStrafen = true
Config.EnabledBewerben = true

--[[
 hier müssen Indentifier eingetragen sein, die ein PC via Command hinzufügen dürfen.
]]
Config.EnabledIdentifier = {
    'steam:110000xxxxxxxxx', --Hex
}

--[[
Welches Design (das Tablet selbst, nicht COPNET ODER MEDICNET ODER CARNET) soll genutzt werden?
Standard / HTML = false
Neues, moderneres (von Flixxx) = true
]]
Config.Design = false

--[[
Welchen job braucht man für..?
Falls Feature nicht erwünscht:
Nein = nil
]]
-- Für CopNet:
Config.CopNetJob = {'police'}
-- Für MedicNet:
Config.MedicNetJob = {'ambulance'}
-- Für CarNet:
Config.CarNetJob = {'cardealer'}
-- Für FDNet:
Config.FireNetJob = {'fire'}

--[[
Animation beim öffnen des Tablets?
Ja = true
Nein = false
]]
Config.Animation = true

--[[
Welche Items braucht man um das Tablet öffnen zu können..?
Falls Feature nicht erwünscht:
Nein = nil
]]
--Config.NeededItem = {'tablet'} oder Config.NeededItem = {'tablet', 'tablet2'}
Config.NeededItem = nil

--[[
Soll man das Tablet auch beim *Benutzen* des Items öffnen können? 
Diese Funktion funktioniert nur, wenn Config.NeededItem NICHT "nil" ist.
Alle Items aus Config.NeededItem nutzbar = 'all'
bestimmtes Item nutzbar = 'itemname'
Nein = nil
]]
Config.CanUseItem = nil

--[[
Entscheidet welche Form beim *Benutzen* des Items geöffnet wird:
Diese Funktion funktioniert nur, wenn Config.CanUseItem "true" ist.
'tab' für das Tablet
'pc' für den PC
]]
Config.ItemOpenType = 'tab'

--[[
Befehle?
Ja = true
Nein = false
]]
Config.Commands = {
    Tablet = true, -- "/copnet", "/medicnet" & "/carnet"
    Gesetze = nil -- "/gesetze" statt nil die PublicID eintragen
}

--[[
Standard Hotkeys fürs Tablet?
Ja = Taste Beispiel: 'F10'
Nein = nil
]]
-- Für CopNet:
Config.Hotkey = 'F9' 
-- Für MedicNet:
Config.MedicHotkey = 'F9'
-- Für CarNet:
Config.CarHotkey = 'F9'
-- Für FireNet:
Config.FDHotkey = 'F11'

--[[
Entscheidet was beim Nutzen des Hotkeys oder Commands geöffnet wird:
'tab' für das Tablet
'pc' für den PC
]]
Config.OpenType = 'tab'

--[[
Man soll das Tablet nur in eine Fahrzeug öffnen können?
Ja = true
Nein = false
]]
Config.OnlyInVehicle = false

--[[
Man soll das Tablet nur in eine Dienstfahrzeug öffnen können? (Fahrzeug muss in der Emergency Class sein)
Diese Funktion funktioniert nur, wenn Config.OnlyInVehicle "true" ist.
Ja = true
Nein = false
]]
Config.InEmergencyVehicle = false

--[[
Entscheidet welche Form beim Nutzen des Tablets im Auto geöffnet wird:
Diese Funktion funktioniert nur, wenn Config.OnlyInVehicle "true" ist.
'tab' für das Tablet
'pc' für den PC
]]
Config.VehicleOpenType = 'tab'

--[[
Aktiviert das "Autoscaling" des Uis:
Einfach gesagt: Tablet klein, PC groß.
Ja = true
Nein = false

! WICHTIG ! 
Beim Tablet können manche Knöpfe und/oder Textfelder nicht erreichbar sein!
Das passiert, da das Tablet nicht für die kleine Ansicht ausgelegt ist!
! WICHTIG !
]]
Config.AutoScale = false

--[[
Liste an Fahrzeugen in denen das Tablet geöffnet werden kann.
Wenn die Tabelle leer ist, ist die Funktion deaktiviert. Fahrzeug Spawnname oder Hashwert angeben.
Diese Funktion funktioniert nur, wenn Config.OnlyInVehicle "true" ist.
]]
Config.Vehicles = {
    ['cop'] = {
        'police',
        -1627000575
    },

    ['medic'] = {
    },

    ['car'] = {
    }
}

--[[
Aussehen der Makierung wo du die Computer benutzen kannst.

type = Aussehen der Makierung --> https://docs.fivem.net/docs/game-references/markers/
x, y, z = Coordinaten
r,g,b = Farb Einstellungen
a = Transparenz
rotate = Soll der Marker Rotieren? true = ja, false = nein
]]
Config.Marker = { type = 1, x = 2.0, y = 2.0, z = 0.5, r = 102, g = 0, b = 102, a = 100, rotate = false }
