# Admin Zone - Temporary Admin Zones

A FiveM resource that allows administrators to create temporary safe zones with automatic restrictions.

**Version 2.0** - Remade with ox_lib and dual framework support (QBCore/ESX)

## Features

This resource allows administrators to set temporary admin zones that automatically:
- Disable weapon firing (inside the zone only)
- Disable melee attacks (inside the zone only)
- Apply speed limiter to vehicles (inside the zone only)
- Display on-screen notifications when entering/leaving zones
- Show temporary blips on the map
- Send Discord webhook notifications when zones are created/removed
- Auto-remove zones when the admin disconnects

Upon removing zones, the resource:
- Removes the temporary blips
- Re-enables shooting and violence
- Notifies players of zone clearance
- Removes the speed limit

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib) - Required
- [qb-core](https://github.com/qbcore-framework/qb-core) - Required if using QBCore
- [es_extended](https://github.com/esx-framework/esx_core) - Required if using ESX

## Installation

1. Download and place the `donk_adminzone` folder in your `resources` directory
2. Ensure `ox_lib` is installed and started before this resource
3. Add to your `server.cfg`:
   ```
   ensure ox_lib
   ensure donk_adminzone
   ```
4. Configure the resource in `config.lua` (see Configuration section)
5. Restart your server

## Configuration

Open `config.lua` and configure the following:

### Framework Selection
```lua
Config.Framework = 'qb' -- Change to 'esx' to use ESX framework
```

### Admin Groups
```lua
Config.AdminGroups = {"admin", "god"} -- Groups that can use admin zone commands
```

### Zone Settings
```lua
Config.DisableViolence = true          -- Disable shooting/melee in admin zones
Config.BlipRadius = 100.0              -- Zone radius in meters
Config.BlipColor = 1                   -- Blip color (1 = Red)
Config.BlipSprite = 487                -- Blip sprite ID
Config.BlipName = "Temp Safe Zone"     -- Blip name
Config.MaxSpeed = 20                   -- Maximum speed in MPH inside zone
Config.ZoneCheckDistance = 100.0       -- Distance to check for zone proximity
```

### Discord Webhook
```lua
Config.UseWebhook = true               -- Enable/disable webhook logging
Config.Webhook = "YOUR_WEBHOOK_URL"    -- Discord webhook URL
Config.WebhookColor = 16711680         -- Discord embed color (red)
```

## Commands

- `/setgz` - Create a temporary admin zone at your current location
- `/cleargz` - Clear your temporary admin zone

**Note:** Only players with admin permissions can use these commands.

## Keybinds (Optional)

You can bind these commands to keys using FiveM's keybind system:
1. Press `ESC` > Settings > Key Bindings > FiveM
2. Find the commands and assign your preferred keys

## Framework Compatibility

This resource supports both QBCore and ESX frameworks. Simply change the `Config.Framework` setting in `config.lua`:

**For QBCore:**
```lua
Config.Framework = 'qb'
```

**For ESX:**
```lua
Config.Framework = 'esx'
```

The resource will automatically use the appropriate framework functions.

## How It Works

1. Admin uses `/setgz` command
2. A zone is created at their current location
3. All players within the zone radius:
   - See a blip on their map
   - Get on-screen notifications
   - Cannot use weapons (if enabled)
   - Have their vehicle speed limited
4. Admin uses `/cleargz` to remove the zone
5. If admin disconnects, their zone is automatically removed

## Support

- Original Author: donk
- Remade with ox_lib and dual framework support

## Credits

- Based on the original qb-adminzone
- Remade with ox_lib by the community

## License

This project maintains the original licensing terms.
