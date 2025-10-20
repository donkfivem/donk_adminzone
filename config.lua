Config = {}

-- Framework Selection: 'qb' or 'esx'
Config.Framework = 'esx' -- Change to 'esx' to use ESX framework

-- Admin groups/permissions
Config.AdminGroups = {"admin", "god", "superadmin"}

-- Zone Settings
Config.DisableViolence = true -- Disable shooting/melee in admin zones
Config.BlipRadius = 100.0
Config.BlipColor = 1 -- Default: 1 (Red) - See https://docs.fivem.net/docs/game-references/blips/
Config.BlipSprite = 487
Config.BlipName = "Temp Safe Zone"
Config.MaxSpeed = 20 -- Maximum speed in MPH inside admin zone
Config.ZoneCheckDistance = 100.0 -- Distance to check for zone proximity

-- Webhook Settings
Config.UseWebhook = true
Config.Webhook = "https://discord.com/api/webhooks/1405797544327643259/ZEhkJefvZQYnnU30JkA3Li_mCotYSpyP8_x4qmVX7Q1ehoAQUtl2i2E3c9pi-YrW1-D_"
Config.WebhookColor = 16711680 -- Discord embed color (red)