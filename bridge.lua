-- Framework Bridge for QBCore and ESX compatibility
Framework = {}

if Config.Framework == 'qb' then
    -- QBCore Framework
    local QBCore = exports['qb-core']:GetCoreObject()

    function Framework.GetPlayer(source)
        return QBCore.Functions.GetPlayer(source)
    end

    function Framework.GetPlayerIdentifier(player)
        return player.PlayerData.license
    end

    function Framework.GetPlayerName(player)
        return player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
    end

    function Framework.HasPermission(source, permission)
        return QBCore.Functions.HasPermission(source, permission) or IsPlayerAceAllowed(source, permission)
    end

    function Framework.RegisterCommand(name, help, args, argsrequired, callback, permission)
        QBCore.Commands.Add(name, help, args, argsrequired, callback, permission)
    end

    function Framework.GetPlayers()
        return QBCore.Functions.GetQBPlayers()
    end

elseif Config.Framework == 'esx' then
    -- ESX Framework
    local ESX = exports['es_extended']:getSharedObject()

    function Framework.GetPlayer(source)
        return ESX.GetPlayerFromId(source)
    end

    function Framework.GetPlayerIdentifier(player)
        return player.identifier
    end

    function Framework.GetPlayerName(player)
        return player.getName()
    end

    function Framework.HasPermission(source, permission)
        local player = ESX.GetPlayerFromId(source)
        if not player then return false end

        -- Check if player has admin group
        for _, group in ipairs(Config.AdminGroups) do
            if player.getGroup() == group then
                return true
            end
        end

        -- Also check ACE permissions
        return IsPlayerAceAllowed(source, permission)
    end

    function Framework.RegisterCommand(name, help, args, argsrequired, callback, permission)
        ESX.RegisterCommand(name, permission, function(xPlayer, args, showError)
            callback(xPlayer.source)
        end, argsrequired, {
            help = help,
            arguments = args
        })
    end

    function Framework.GetPlayers()
        return ESX.GetExtendedPlayers()
    end
else
    print('^1[AdminZone] Invalid framework selected in config.lua. Please set Config.Framework to "qb" or "esx"^0')
end
