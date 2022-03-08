--[[
Liste an Orten in denen das Tablet geöffnet werden kann.
Wenn die Tabelle leer ist, ist die Funktion deaktiviert.
System = 'cop' für CopNet
System = 'medic' für MedicNet
System = 'car' für CarNet
]]
Config.Zones = {
    -- Misson Row PD
    {
        Coords = vector3(441.94, -978.87, 29.69),
        Prompt = 'Drücke ~INPUT_CONTEXT~ um den PC zu nutzen.',
        System = 'cop',
        OpenType = 'pc',
        Job = 'police'
    },

    -- Pillbox Hill KH
    {
        Coords = vector3(312.29, -597.218, 43.2821),
        Prompt = 'Drücke ~INPUT_CONTEXT~ um den PC zu nutzen.',
        System = 'medic',
        OpenType = 'pc',
        Job = 'police'
    },
}