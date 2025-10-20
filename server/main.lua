local zones = {}

local function sendToDiscord(title, message)
    if not Config.UseWebhook or not Config.Webhook or Config.Webhook == "" then
        return
    end

    if not message or message == '' then return end

    local embed = {
        {
            ["color"] = Config.WebhookColor,
            ["title"] = "TEMPORARY ADMIN ZONE",
            ["description"] = ("Time: **%s**"):format(os.date('%Y-%m-%d %H:%M:%S')),
            ["fields"] = {
                {
                    ["name"] = "Message",
                    ["value"] = message
                }
            },
            ["footer"] = {
                ["text"] = "Admin Zone System",
                ["icon_url"] = "https://icons.iconarchive.com/icons/iconarchive/red-orb-alphabet/128/Letter-A-icon.png",
            }
        }
    }

    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({
        username = "Admin Zone",
        embeds = embed
    }), {
        ['Content-Type'] = 'application/json'
    })
end

local function hasActiveZone(identifier)
    for i, zone in pairs(zones) do
        if zone.identifier == identifier then
            return true
        end
    end
    return false
end

local function removeZoneByIdentifier(identifier)
    for i, zone in pairs(zones) do
        if zone.identifier == identifier then
            table.remove(zones, i)
            return true
        end
    end
    return false
end

lib.addCommand('setgz', {
    help = 'Create a temporary admin zone at your location',
    restricted = 'group.admin'
}, function(source, args, raw)
    local src = source
    local Player = Framework.GetPlayer(src)

    if not Player then return end

    local identifier = Framework.GetPlayerIdentifier(Player)
    local playerName = Framework.GetPlayerName(Player)

    if hasActiveZone(identifier) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Admin Zone',
            description = 'You already have an active zone! Clear it before creating another.',
            type = 'error'
        })
        return
    end

    sendToDiscord("ADD ADMIN ZONE", playerName .. " has set a temporary admin zone")
    TriggerClientEvent("adminzone:getCoords", src, "setzone")
end)

lib.addCommand('cleargz', {
    help = 'Clear your temporary admin zone',
    restricted = 'group.admin'
}, function(source, args, raw)
    local src = source
    local Player = Framework.GetPlayer(src)

    if not Player then return end

    local identifier = Framework.GetPlayerIdentifier(Player)
    local playerName = Framework.GetPlayerName(Player)

    if removeZoneByIdentifier(identifier) then
        sendToDiscord("CLEAR ADMIN ZONE", playerName .. " removed their admin zone")
        TriggerClientEvent("adminzone:UpdateZones", -1, zones)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Admin Zone',
            description = 'Your admin zone has been cleared',
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Admin Zone',
            description = 'You don\'t have an active zone',
            type = 'error'
        })
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local Player = Framework.GetPlayer(src)

    if Player then
        local identifier = Framework.GetPlayerIdentifier(Player)
        if removeZoneByIdentifier(identifier) then
            TriggerClientEvent("adminzone:UpdateZones", -1, zones)
        end
    end
end)

RegisterNetEvent('adminzone:sendCoords', function(command, coords)
    local src = source
    local Player = Framework.GetPlayer(src)

    if not Player then return end

    if not Framework.HasPermission(src, 'admin') then
        return
    end

    local identifier = Framework.GetPlayerIdentifier(Player)

    if command == 'setzone' then
        zones[#zones + 1] = {
            identifier = identifier,
            coord = coords
        }
        TriggerClientEvent("adminzone:UpdateZones", -1, zones)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Admin Zone',
            description = 'Admin zone created successfully',
            type = 'success'
        })
    end
end)

RegisterNetEvent('adminzone:ServerUpdateZone', function()
    TriggerClientEvent('adminzone:UpdateZones', source, zones)
end)
