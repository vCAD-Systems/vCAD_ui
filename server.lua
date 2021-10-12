ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function makeItemUseable(name)
    if name == nil or name == 'nil' then return end
    
    ESX.RegisterUsableItem(name, function(source)
        if Config.ItemOpenType == 'tab' or Config.ItemOpenType == 'pc' then
            local xPlayer = ESX.GetPlayerFromId(source)

            for k,v in pairs(Config.CopNetJob) do
                if xPlayer.job.name == v then
                    TriggerClientEvent('wgc:openUI', source, 'cop',  Config.ItemOpenType)
                    return
                end
            end

            for k,v in pairs(Config.MedicNetJob) do
                if xPlayer.job.name == v then
                    TriggerClientEvent('wgc:openUI', source, 'medic',  Config.ItemOpenType)
                    return
                end
            end
            
            for k,v in pairs(Config.CarNetJob) do
                if xPlayer.job.name == v then
                    TriggerClientEvent('wgc:openUI', source, 'car',  Config.ItemOpenType)
                    return
                end
            end
        else
            print('[WGC_UI] Config.ItemOpenType ungültig!')
        end
    end)
end

if Config.CanUseItem and Config.CanUseItem ~= 'nil' and Config.CanUseItem ~= '' and Config.NeededItem ~= nil and Config.NeededItem ~= 'nil' then 
    if Config.CanUseItem == 'all' then
        if type(Config.NeededItem) == 'table' then
            for k,v in pairs(Config.NeededItem) do
                makeItemUseable(v)
            end
        else
            makeItemUseable(Config.NeededItem)
        end
    else
        makeItemUseable(Config.CanUseItem)
    end
end