# Framework Setup Guide

## Switching Between QBCore and ESX

This resource supports both QBCore and ESX frameworks. Here's how to configure it:

### For QBCore Users

1. Open `config.lua`
2. Set the framework:
   ```lua
   Config.Framework = 'qb'
   ```
3. Ensure you have `qb-core` installed and running
4. Restart the resource

### For ESX Users

1. Open `config.lua`
2. Set the framework:
   ```lua
   Config.Framework = 'esx'
   ```
3. Ensure you have `es_extended` (ESX core) installed and running
4. Make sure your admin group is properly configured in ESX
5. Restart the resource

## How Notifications Work

### Server-Side Notifications
Server-side code uses `TriggerClientEvent('ox_lib:notify', source, {...})` to send notifications to clients:

```lua
TriggerClientEvent('ox_lib:notify', src, {
    title = 'Admin Zone',
    description = 'Your message here',
    type = 'success' -- 'success', 'error', 'warning', 'info'
})
```

### Client-Side Notifications
Client-side code uses `lib.notify({...})` directly:

```lua
lib.notify({
    title = 'Admin Zone',
    description = 'Your message here',
    type = 'success'
})
```

## Admin Permissions

### QBCore
- Uses QBCore's built-in permission system
- Default admin groups: `admin`, `god`
- Can be configured in `Config.AdminGroups`

### ESX
- Uses ESX's group system
- Checks player's group against `Config.AdminGroups`
- Also supports ACE permissions as fallback
- Make sure your admin has the correct group set in the database

## Troubleshooting

### "Command not found"
- Check that ox_lib is installed and started before this resource
- Verify the framework setting matches your server setup

### "Notifications not showing"
- Ensure ox_lib is up to date
- Check browser console (F8) for errors
- Verify the resource is started after ox_lib

### "Permission denied"
- For QBCore: Check player's group in `qb-core/shared/jobs.lua`
- For ESX: Verify player's group in database (`users` table, `group` column)
- Ensure `Config.AdminGroups` includes your admin group

## ESX Specific Notes

The resource uses `es_extended` which is the official ESX core. The initialization is:

```lua
ESX = exports['es_extended']:getSharedObject()
```

This works with modern ESX (1.2+). If you're using an older version, you may need to modify the bridge.lua file.

## Discord Webhook

Both frameworks support Discord webhooks. Configure in `config.lua`:

```lua
Config.UseWebhook = true
Config.Webhook = "YOUR_WEBHOOK_URL_HERE"
Config.WebhookColor = 16711680 -- Red color
```

## Need Help?

If you encounter issues:
1. Check the server console for errors
2. Verify your framework is properly installed
3. Ensure all dependencies are up to date
4. Check that admin permissions are correctly set
