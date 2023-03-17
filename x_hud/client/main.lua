local hudStatus, inVehicle, isPaused, settings, hudActive, carhudActive, useKmh, scroll, playerPed = true, false, false,
    false, true, true, true, true
local Radar = true
local function openHudSettings()
    settings = not settings
    SendNUIMessage({
        action = "settings",
        show = settings
    })
    SetNuiFocus(settings, settings)
end

RegisterCommand("hud", function()
    openHudSettings()
end, false)

RegisterNUICallback("close", function(data, cb)
    settings = not settings
    SendNUIMessage({
        action = "settings",
        show = false
    })
    cb(true)
end)

RegisterNUICallback("change_unit", function(data, cb)
    useKmh = data.toggle
    cb(true)
end)

RegisterCommand("*toggleHud", function()
    if isPaused == false and scroll then
        Radar = not Radar
        SendNUIMessage({
            action = "toggleHud"
        })
        if inVehicle then
            DisplayRadar(Radar)
        end
    end
end)
RegisterKeyMapping("*toggleHud", "", "MOUSE_BUTTONANY", "MOUSE_MIDDLE")

RegisterNUICallback('close', function()
    SetNuiFocus(false, false)
end)

local TablesMatch = function(t1, t2)
    if forceUpdate then
        forceUpdate = false
        return false
    end
    for k, v in pairs(t1) do
        if not t2[k] or t2[k] ~= v then
            return false
        end
    end
    return true
end

TableClone = function(t)
    local r = {}
    for k, v in pairs(t or {}) do
        if type(v) == "table" then
            r[k] = TableClone(v)
        else
            r[k] = v
        end
    end
    return r
end

local voice = 2

local TransformTime = function(h, m)
    h, m = tostring(h), tostring(m)
    return (#h == 1 and "0" .. h or h) .. ":" .. (#m == 1 and "0" .. m or m)
end

AddEventHandler('pma-voice:setTalkingMode', function(newTalkingRange)
    voice = newTalkingRange

end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        local isPlayerSpeaking = NetworkIsPlayerTalking(PlayerId())
        local hudData = {
            voice = math.floor(voice / 3 * 100)
        }
        SendNUIMessage({
            action = "update_hud",
            hudIcons = hudData,
            voice = isPlayerSpeaking,
            time = TransformTime(GetClockHours(), GetClockMinutes())
        })
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(100)
    local lastHudData, hudData = {}, {}
    local zones = {
        ["AIRP"] = "Airport LS",
        ["ALAMO"] = "Alamo Sea",
        ["ALTA"] = "Alta",
        ["ARMYB"] = "Fort Zancudo",
        ["BANHAMC"] = "Banham Canyon",
        ["BANNING"] = "Banning",
        ["BEACH"] = "Vespucci Beach",
        ["BHAMCA"] = "Banham Canyon",
        ["BRADP"] = "Braddock Pass",
        ["BRADT"] = "Braddock Tunnel",
        ["BURTON"] = "Burton",
        ["CALAFB"] = "Calafia Bridge",
        ["CANNY"] = "Raton Canyon",
        ["CCREAK"] = "Cassidy Creek",
        ["CHAMH"] = "Chamberlain Hills",
        ["CHIL"] = "Vinewood Hills",
        ["CHU"] = "Chumash",
        ["CMSW"] = "Chiliad Mountain",
        ["CYPRE"] = "Cypress Flats",
        ["DAVIS"] = "Davis",
        ["DELBE"] = "Del Perro Beach",
        ["DELPE"] = "Del Perro",
        ["DELSOL"] = "La Puerta",
        ["DESRT"] = "Grand Senora",
        ["DOWNT"] = "Downtown",
        ["DTVINE"] = "Downtown Vinewood",
        ["EAST_V"] = "East Vinewood",
        ["EBURO"] = "El Burro Heights",
        ["ELGORL"] = "El Gordo",
        ["ELYSIAN"] = "Elysian Island",
        ["GALFISH"] = "Galilee",
        ["GOLF"] = "Klub Golfowy",
        ["GRAPES"] = "Grapeseed",
        ["GREATC"] = "Great Chaparral",
        ["HARMO"] = "Harmony",
        ["HAWICK"] = "Hawick",
        ["HORS"] = "Vinewood Racetrack",
        ["HUMLAB"] = "Humane Labs and Research",
        ["JAIL"] = "Bolingbroke Penitentiary",
        ["KOREAT"] = "Little Seoul",
        ["LACT"] = "Land Act Reservoir",
        ["LAGO"] = "Lago Zancudo",
        ["LDAM"] = "Land Act Dam",
        ["LEGSQU"] = "Legion Square",
        ["LMESA"] = "La Mesa",
        ["LOSPUER"] = "La Puerta",
        ["MIRR"] = "Mirror Park",
        ["MORN"] = "Morningwood",
        ["MOVIE"] = "Richards Majestic",
        ["MTCHIL"] = "Mount Chiliad",
        ["MTGORDO"] = "Mount Gordo",
        ["MTJOSE"] = "Mount Josiah",
        ["MURRI"] = "Murrieta Heights",
        ["NCHU"] = "North Chumash",
        ["NOOSE"] = "N.O.O.S.E",
        ["OCEANA"] = "Pacific Ocean",
        ["PALCOV"] = "Paleto Cove",
        ["PALETO"] = "Paleto Bay",
        ["PALFOR"] = "Paleto Forest",
        ["PALHIGH"] = "Palomino Highlands",
        ["PALMPOW"] = "Palmer-Taylor Power Station",
        ["PBLUFF"] = "Pacific Bluffs",
        ["PBOX"] = "Pillbox Hill",
        ["PROCOB"] = "Procopio Beach",
        ["RANCHO"] = "Rancho",
        ["RGLEN"] = "Richman Glen",
        ["RICHM"] = "Richman",
        ["ROCKF"] = "Rockford Hills",
        ["RTRAK"] = "Redwood Track",
        ["SANAND"] = "San Andreas",
        ["SANCHIA"] = "San Chianski",
        ["SANDY"] = "Sandy Shores",
        ["SKID"] = "Mission Row",
        ["SLAB"] = "Stab City",
        ["STAD"] = "Maze Bank Arena",
        ["STRAW"] = "Strawberry",
        ["TATAMO"] = "Tataviam Mountains",
        ["TERMINA"] = "Terminal",
        ["TEXTI"] = "Textile City",
        ["TONGVAH"] = "Tongva Hills",
        ["TONGVAV"] = "Tongva Valley",
        ["VCANA"] = "Vespucci Canals",
        ["VESP"] = "Vespucci",
        ["VINE"] = "Vinewood",
        ["WINDF"] = "Wind Farm",
        ["WVINE"] = "West Vinewood",
        ["ZANCUDO"] = "Zancudo River",
        ["ZP_ORT"] = "Port LS",
        ["ZQ_UAR"] = "Davis Quartz"
    }
    local directions = {
        [0] = "N",
        [45] = "NW",
        [90] = "W",
        [135] = "SW",
        [180] = "S",
        [225] = "SE",
        [270] = "E",
        [315] = "NE",
        [360] = "N"
    }
    Citizen.Wait(100)
    local force = 0
    SendNUIMessage({
        action = "hudChangeId",
        playerid = GetPlayerServerId(PlayerId())
    })
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(100)
            if IsPauseMenuActive() then
                isPaused = true
                SendNUIMessage({
                    action = "pauseMenu",
                    data = true
                })
            else
                isPaused = false
                SendNUIMessage({
                    action = "pauseMenu",
                    data = false
                })
            end
            if hudStatus then
                local playerPed = PlayerPedId()
                local wt = 500
                if hudActive then
                    wt = 400

                    hudData.health = GetEntityHealth(playerPed) - 100
                    hudData.armour = GetPedArmour(playerPed)
                    TriggerEvent("esx_status:getStatus", "hunger", function(hunger)
                        TriggerEvent("esx_status:getStatus", "thirst", function(thirst)
                            hudData.hunger = math.floor(hunger.getPercent())
                            hudData.thirst = math.floor(thirst.getPercent())
                            if not TablesMatch(hudData, lastHudData) or force > 5 then
                                lastHudData = TableClone(hudData)
                                force = 0
                                SendNUIMessage({
                                    action = "update_hud",
                                    hudIcons = hudData,
                                    time = TransformTime(GetClockHours(), GetClockMinutes())
                                })
                            else
                                force = force + 1
                            end
                        end)
                    end)
                end
                Citizen.Wait(wt)
            end
        end
    end)
    Citizen.CreateThread(function()
        DisplayRadar(false)
        local lastCarHudData, carHudData = {}, {}
        while true do
            Citizen.Wait(10)
            if hudStatus then
                local playerPed = PlayerPedId()
                local wt = 100
                if carhudActive then
                    local veh = GetVehiclePedIsIn(playerPed, false)
                    local inVeh = veh and veh ~= 0 or false

                    if inVeh and not inVehicle then
                        inVehicle = true
                        SendNUIMessage({
                            action = "carhud",
                            show = true
                        })
                        if Radar then
                            DisplayRadar(true)
                        end

                    elseif not inVeh and inVehicle then
                        inVehicle = false
                        SendNUIMessage({
                            action = "carhud",
                            show = false
                        })
                        DisplayRadar(false)
                    end
                    if inVehicle then
                        wt = 30
                        local speed, coords = GetEntitySpeed(veh), GetEntityCoords(playerPed)
                        carHudData.speed = math.floor(useKmh and speed * 3.6 or speed * 2.236936)
                        -- carHudData.location = zones[GetNameOfZone(coords.x, coords.y, coords.z)]
                        local street, crossing = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
                        carHudData.location = GetStreetNameFromHashKey(street)
                        local heading = GetEntityHeading(veh)
                        for k, v in pairs(directions) do
                            if math.abs(heading - k) < 22.5 then
                                carHudData.direction = v
                                break
                            end
                        end
                    end
                    if not TablesMatch(carHudData, lastCarHudData) then
                        lastCarHudData = TableClone(carHudData)
                        SendNUIMessage({
                            action = "update_carhud",
                            speed = carHudData.speed,
                            location = carHudData.location,
                            direction = carHudData.direction
                        })
                    end
                end
                Citizen.Wait(wt)
            end
        end
    end)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    Citizen.Wait(1000)
    SendNUIMessage({
        action = "playerLoad"
    })
    Citizen.Wait(100)
    SendNUIMessage({
        action = "hudChangeId",
        playerid = GetPlayerServerId(PlayerId())
    })
end)

AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerLoaded = true
    SendNUIMessage({
        action = "playerLoad"
    })

    Citizen.Wait(100)
    SendNUIMessage({
        action = "hudChangeId",
        playerid = GetPlayerServerId(PlayerId())
    })
    SwitchHud(true)
end)

function SwitchHud(data)
    hudStatus = data
    SendNUIMessage({
        action = 'switchhud',
        switchHud = data
    })
end

exports("SwitchHud", SwitchHud)

Citizen.CreateThread(function()
    local minimap = RequestScaleformMovie("minimap")
    -- SetRadarBigmapEnabled(true, false)
    -- Wait(0)
    -- SetRadarBigmapEnabled(false, false)
    while true do
        Wait(0)
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)

RegisterNUICallback('updateColor', function(data)
    TriggerEvent("xad_hud:client:updateColor", data)
end)
