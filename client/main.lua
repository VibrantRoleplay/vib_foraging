QBCore = exports["qb-core"]:GetCoreObject()

-------------
--Variables--
-------------

pickingAllowed = true
mushroomsSpawned = false
mushroomsInfo = {}

-------------------
--Object Spawning--
-------------------

function SpawnMushrooms(zone)
    local playerPed = cache.ped
    local spawnedMushrooms = 0

    if mushroomsSpawned then return end
    if spawnedMushrooms >= zone.AmountOfMushrooms then
        mushroomsSpawned = true
        return
    end
    
    while spawnedMushrooms < zone.AmountOfMushrooms do
        Wait(750)
        local randomCoords = getRandomPointInSphere(zone.ZoneCoords, zone.ZoneRadius)
        local occupied = IsObjectNearPoint(Config.MushroomModel, randomCoords, 1.0)

        if not occupied then
            mushroom = CreateObject(Config.MushroomModel, randomCoords.x, randomCoords.y, randomCoords.z, true)
            PlaceObjectOnGroundProperly(mushroom)
            FreezeEntityPosition(mushroom, true)
            spawnedMushrooms = spawnedMushrooms + 1

            local mushroomZone = exports.ox_target:addSphereZone({
                coords = vector3(randomCoords.x, randomCoords.y, randomCoords.z-1.0),
                radius = 0.5,
                debug = Config.Debug,
                options = {
                    {
                        event = "foraging:client:PickUpMushroom",
                        icon = 'fa-solid fa-hand',
                        label = 'Gather shrooooms',
                        args = {
                            mushroom = mushroom,
                        },
                    },
                }
            })
            mushroomsInfo[mushroom] = {
                zoneId = mushroomZone
            }
        else
            if Config.Debug then 
                print("An object is already spawned here")
            end
            Wait(10)
        end
    end
end

RegisterNetEvent('foraging:client:PickUpMushroom', function(data)
    local player = cache.ped
    print(json.encode(data, {indent = true}))

    if lib.progressCircle({
        lable = "Foraging for shrooommmssss",
        duration = 3000,
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
            mouse = false
        },
        anim = {
            dict = 'amb@world_human_gardener_plant@male@base',
            clip = 'base',
            flag = 1,
        },
        -- prop = {
        --     {
        --         model = `w_me_hammer`,
        --         bone = 57005,
        --         pos = vec3(0.05, -0.01, 0.0),
        --         rot = vec3(75.0, 180.0, 150.0)
        --     },
        -- }
    }) then
        exports.ox_target:removeZone(mushroomsInfo[data.args.mushroom].zoneId)
        DeleteObject(data.args.mushroom)
        mushroomsInfo[data.args.mushroom] = nil
        lib.notify({
            title = "Attention",
            description = "You've collected some mushrooms",
            type = 'success',
        })
    else
        lib.notify({
            title = "Canceled",
            description = "Canceled",
            type = "error"
        })
    end
end)

----------------------
--Choose Random Zone--
----------------------

RegisterNetEvent('foraging:client:GetRandomForageLocation', function()
    local player = cache.ped

    local randomLocation = math.random(1, #Config.ForageLocations)
    local randomField = Config.ForageLocations[randomLocation]

    lib.alertDialog({
        header = "Mr Drug Man says:",
        content = "So ... you wanna know where I get my supply?"
        .. "\n\n You give me a couple racks and you'll get the best high you've ever had!",
        centered = true,
        cancel = false
    })

    SellingBlips(randomField)
end)

function SellingBlips(randomField)
    forageBlip = AddBlipForRadius(randomField.ZoneCoords, 30.0)
    SetBlipAlpha(forageBlip, 175)
    SetBlipColour(forageBlip, 2)

    CreateThread(function()
        while true do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - randomField.ZoneCoords)
    
            if distance < 10 then
                RemoveBlip(forageBlip)
                break
            end
            Wait(10)
        end
    end)
end