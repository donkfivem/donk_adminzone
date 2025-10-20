local zones = {}
local activeZones = {}
local inZone = false
local currentBlip = nil
local currentRadiusBlip = nil
local speedLimitActive = false

-- Helper function to round numbers
local function round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

-- Create blips for a zone
local function createZoneBlips(coords)
    if currentBlip then
        RemoveBlip(currentBlip)
    end
    if currentRadiusBlip then
        RemoveBlip(currentRadiusBlip)
    end

    currentBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    currentRadiusBlip = AddBlipForRadius(coords.x, coords.y, coords.z, Config.BlipRadius)

    SetBlipSprite(currentBlip, Config.BlipSprite)
    SetBlipAsShortRange(currentBlip, true)
    SetBlipColour(currentBlip, Config.BlipColor)
    SetBlipScale(currentBlip, 1.0)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.BlipName)
    EndTextCommandSetBlipName(currentBlip)

    SetBlipAlpha(currentRadiusBlip, 80)
    SetBlipColour(currentRadiusBlip, Config.BlipColor)
end

-- Remove zone blips
local function removeZoneBlips()
    if currentBlip then
        RemoveBlip(currentBlip)
        currentBlip = nil
    end
    if currentRadiusBlip then
        RemoveBlip(currentRadiusBlip)
        currentRadiusBlip = nil
    end
end

-- Enter admin zone
local function enterZone(coords)
    if inZone then return end

    inZone = true
    createZoneBlips(coords)

    lib.showTextUI('~r~WARNING: ~y~You are in an ADMIN ZONE~n~~w~No RP, No Speeding, No Violence', {
        position = "top-center",
        icon = 'shield-halved',
        style = {
            borderRadius = 5,
            backgroundColor = '#48BB78',
            color = 'white'
        }
    })
end

-- Exit admin zone
local function exitZone()
    if not inZone then return end

    inZone = false
    removeZoneBlips()
    lib.hideTextUI()

    lib.notify({
        title = 'Admin Zone',
        description = 'You have exited the admin zone',
        type = 'success'
    })
end

-- Check if player is in any zone
local function checkZoneProximity()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local foundZone = false

    for _, zone in pairs(zones) do
        local distance = #(playerCoords - zone.coord)
        if distance <= Config.ZoneCheckDistance then
            if not inZone then
                enterZone(zone.coord)
            end
            foundZone = true
            break
        end
    end

    if not foundZone and inZone then
        exitZone()
    end
end

-- Handle violence restrictions
CreateThread(function()
    while true do
        Wait(0)
        if inZone and Config.DisableViolence then
            local playerPed = PlayerPedId()
            SetPlayerCanDoDriveBy(playerPed, false)
            DisablePlayerFiring(playerPed, true)
            DisableControlAction(0, 140, true) -- Melee attack (R)
            DisableControlAction(0, 141, true) -- Melee attack 2
            DisableControlAction(0, 142, true) -- Melee attack 3
            DisableControlAction(0, 257, true) -- Attack
            DisableControlAction(0, 263, true) -- Melee attack
            DisableControlAction(0, 264, true) -- Melee attack 2
        else
            Wait(500)
        end
    end
end)

-- Handle speed limits in zones
CreateThread(function()
    while true do
        Wait(500)
        local playerPed = PlayerPedId()

        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local playerCoords = GetEntityCoords(playerPed)
            local needSpeedLimit = false

            -- Check if we're in any zone
            for _, zone in pairs(zones) do
                if #(playerCoords - zone.coord) < Config.ZoneCheckDistance then
                    needSpeedLimit = true
                    break
                end
            end

            if needSpeedLimit then
                local maxSpeedMPS = Config.MaxSpeed / 2.237 -- Convert MPH to meters per second
                SetEntityMaxSpeed(vehicle, maxSpeedMPS)

                if not speedLimitActive then
                    speedLimitActive = true
                    lib.notify({
                        title = 'Speed Limit',
                        description = ('Speed limited to %s MPH in this zone'):format(Config.MaxSpeed),
                        type = 'warning'
                    })
                end
            else
                if speedLimitActive then
                    SetEntityMaxSpeed(vehicle, 999.0) -- Reset to default
                    speedLimitActive = false
                end
            end
        else
            if speedLimitActive then
                speedLimitActive = false
            end
        end
    end
end)

-- Main zone checking thread
CreateThread(function()
    while true do
        Wait(1000)
        if #zones > 0 then
            checkZoneProximity()
        end
    end
end)

-- Update zones from server
RegisterNetEvent('adminzone:UpdateZones', function(zoneTable)
    zones = zoneTable

    -- If we were in a zone that no longer exists, exit it
    if inZone then
        local stillInZone = false
        local playerCoords = GetEntityCoords(PlayerPedId())

        for _, zone in pairs(zones) do
            if #(playerCoords - zone.coord) <= Config.ZoneCheckDistance then
                stillInZone = true
                break
            end
        end

        if not stillInZone then
            exitZone()
        end
    end

    -- If all zones cleared, show notification
    if #zones == 0 and inZone then
        lib.notify({
            title = 'Admin Zone',
            description = 'All admin zones have been cleared',
            type = 'success'
        })
        exitZone()
    end
end)

-- Get player coords for setting zone
RegisterNetEvent('adminzone:getCoords', function(command)
    TriggerServerEvent('adminzone:sendCoords', command, GetEntityCoords(PlayerPedId()))
end)

-- Request zones on player loaded
if Config.Framework == 'qb' then
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        TriggerServerEvent('adminzone:ServerUpdateZone')
    end)
elseif Config.Framework == 'esx' then
    RegisterNetEvent('esx:playerLoaded', function()
        TriggerServerEvent('adminzone:ServerUpdateZone')
    end)
end

-- Request zones on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(1000)
        TriggerServerEvent('adminzone:ServerUpdateZone')
    end
end)
