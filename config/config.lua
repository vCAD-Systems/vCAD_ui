Config = {}

--[[
Welches Design (das Tablet selbst, nicht COPNET ODER MEDICNET ODER CARNET) soll genutzt werden?
Standard / HTML = false
Neues, moderneres (von Flixxx) = true
]]
Config.Design = false

--[[
Animation beim öffnen des Tablets?
Ja = true
Nein = false
]]
Config.Animation = false

--[[
Befehl "/copnet"?
Ja = true
Nein = false
]]
Config.Commands = true

--[[
    Trage hier die Identifier ein die PC´s erstellen dürfen.
    Funktionierende Identifier sind steam: und license:
]]
Config.EnabledIdentifier = {
    'steam:110000101e019f7'
    --'steam:110000101e019f8'
}

--[[
Wenn die funktion auf "false" steht, werden keine Computer gesetzt!
]]
Config.EnabledZones = false
--[[
Wollt Ihr euren CarnNet Katalog ingame an einem Punkt anzeigen?
true = ja
false = Nein
]]
Config.EnabledKatalog = false
--[[
    Wollt ihr das sich euche Spieler Ingame beim CopNet Bewerben kann?
    wenn ja dann = true
    wenn nein dann = false
]]
Config.EnabledBewerben = false
--[[
    Wollt Ihr Ingame Punkte wo man die Strafen öffentlich einsehen kann?
    wenn ja dann = true
    wenn nein dann = false
]]
Config.EnabledStrafen = false

--[[
    Wenn Ihr nur eine Public id habt, dann braucht ihr diese nicht bei dem Command ingame mit senden sondern könnt sie einfach hier hinterlegen.
    z.B. Katalog = 'xyz',
]]
Config.PublicID = {
    Katalog = nil,
    Bewerbung = nil,
    Strafen = nil,
}

--[[
Entscheidet was beim nutzen des Befehls geöffnet wird:
'tab' für das Tablet
'pc' für den PC
]]
Config.CommandOpenType = 'tab'

--[[
Hotkey fürs Tablet?
Ja = Taste Beispiel: 'F10'
Nein = nil
]]
-- Für CopNet:
Config.Hotkey = 'F10' 
-- Für MedicNet:
Config.MedicHotkey = 'F9'
-- Für CarNet:
Config.CarHotkey = 'F7'

--[[
Entscheidet was beim nutzen des Hotkeys geöffnet wird:
'tab' für das Tablet
'pc' für den PC
]]
Config.HotkeyOpenType = 'tab'

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
Entscheidet was beim nutzen des Tablets im Auto geöffnet wird:
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
