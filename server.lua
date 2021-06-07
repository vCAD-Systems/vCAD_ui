ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

if Config.CanUseItem and Config.NeededItem and Config.NeededItem ~= '' then
    ESX.RegisterUsableItem(Config.NeededItem, function(source)
        if Config.ItemOpenType == 'tab' or Config.ItemOpenType == 'pc' then
            local src = source
            local xPlayer = ESX.GetPlayerFromId(src)

            for k,v in pairs(Config.CopNetJob) do
                if xPlayer.job.name == v then
                    TriggerClientEvent('wgc:openUI', src, 'cop',  Config.ItemOpenType)
                    return
                end
            end

            for k,v in pairs(Config.MedicNetJob) do
                if xPlayer.job.name == v then
                    TriggerClientEvent('wgc:openUI', src, 'medic',  Config.ItemOpenType)
                    return
                end
            end
            
            for k,v in pairs(Config.CarNetJob) do
                if xPlayer.job.name == v then
                    TriggerClientEvent('wgc:openUI', src, 'car',  Config.ItemOpenType)
                    return
                end
            end
        else
            print('[WGC_UI] Config.ItemOpenType ungültig!')
        end
    end)
end