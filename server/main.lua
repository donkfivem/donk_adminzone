local zones = {}

-- Send log to Discord webhook
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

-- Check if player has an active zone
local function hasActiveZone(identifier)
    for i, zone in pairs(zones) do
        if zone.identifier == identifier then
            return true
        end
    end
    return false
end

-- Remove zone by identifier
local function removeZoneByIdentifier(identifier)
    for i, zone in pairs(zones) do
        if zone.identifier == identifier then
            table.remove(zones, i)
            return true
        end
    end
    return false
end

-- Set Admin Zone Command
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
        lib.notify(src, {
            title = 'Admin Zone',
            description = 'You already have an active zone! Clear it before creating another.',
            type = 'error'
        })
        return
    end

    sendToDiscord("ADD ADMIN ZONE", playerName .. " has set a temporary admin zone")
    TriggerClientEvent("adminzone:getCoords", src, "setzone")
end)

-- Clear Admin Zone Command
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
        lib.notify(src, {
            title = 'Admin Zone',
            description = 'Your admin zone has been cleared',
            type = 'success'
        })
    else
        lib.notify(src, {
            title = 'Admin Zone',
            description = 'You don\'t have an active zone',
            type = 'error'
        })
    end
end)

-- Handle player disconnect - remove their zones
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

-- Receive coordinates from client and create zone
RegisterNetEvent('adminzone:sendCoords', function(command, coords)
    local src = source
    local Player = Framework.GetPlayer(src)

    if not Player then return end

    -- Double-check permissions
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
        lib.notify(src, {
            title = 'Admin Zone',
            description = 'Admin zone created successfully',
            type = 'success'
        })
    end
end)

-- Send zones to player on request
RegisterNetEvent('adminzone:ServerUpdateZone', function()
    TriggerClientEvent('adminzone:UpdateZones', source, zones)
end)
