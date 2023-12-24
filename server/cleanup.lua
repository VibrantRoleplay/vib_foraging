-----------------
--CleanUp Timer--
-----------------

RegisterNetEvent('foraging:server:CleanUpTimer', function(data)
    if Config.CleanUpTimer > data.Cooldown.Minutes then
	    timer = data.Cooldown.Minutes * 60000
    else
        timer = Config.CleanUpTimer * 60000
    end

    Wait(250)
    Wait(timer)

    for k, mushroom in pairs(WildMushrooms[data.AreaName]) do
        Wait(500)
        DeleteEntity(mushroom)
        TriggerClientEvent('foraging:client:CleanUpZones', -1, WildMushrooms[mushroom].ZoneId) 
    end

    for k, nudist in pairs(Nudists[data.AreaName]) do
        Wait(500)
        local nudistEntity = NetworkGetNetworkIdFromEntity(nudist)
        TriggerClientEvent('foraging:client:CleanUpNudists', -1, data, nudistEntity)
    end
end)