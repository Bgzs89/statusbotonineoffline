local lastUpdateTime = os.time()
local lastStatusUpdate = 0
local prevStatus = {}

function getLastUpdateTime()
    if lastUpdateTime == nil then
        return "belum ada update"
    end
    return os.date("%H:%M:%S", lastUpdateTime)
end

function getActivity(bot)
    local activities = {}
    local checks = {
        { bot.auto_farm,    "🌾 AutoFarm"    },
        { bot.auto_geiger,  "📡 AutoGeiger"  },
        { bot.auto_spam,    "💬 AutoSpam"    },
        { bot.auto_fish,    "🎣 AutoFish"    },
        { bot.auto_harvest, "🌿 AutoHarvest" },
        { bot.auto_crime,   "🔪 AutoCrime"   },
        { bot.auto_cook,    "🍳 AutoCook"    },
    }
    for _, v in ipairs(checks) do
        if v[1] and v[1].enabled then table.insert(activities, v[2]) end
    end
    if bot.auto_collect then table.insert(activities, "💎 AutoCollect") end
    return #activities > 0 and table.concat(activities, ", ") or "💤 Idle"
end

function checkDisconnected()
    local disconnected = {}
    for _, bot in pairs(getBots()) do
        local isOnline = bot.status == BotStatus.online
        if prevStatus[bot.name] == true and not isOnline then
            table.insert(disconnected, bot.name)
        end
        prevStatus[bot.name] = isOnline
    end
    return disconnected
end

function sendOrEditStatus(updateStatus)
    local disconnected = checkDisconnected()

    local embed = Embed.new()
    embed.color = 0xFFB6C1
    embed.title = "🤖 Status Semua Bot"

    -- Field disconnect alert
    if #disconnected > 0 then
        local dcList = {}
        for _, name in ipairs(disconnected) do
            table.insert(dcList, "<a:aDevilGlare:1031194205441249382> **" .. name .. "** terputus!")
        end
        embed:addField("⚠️ Bot Disconnect!", table.concat(dcList, "\n"), false)
    end

    -- Field per bot
    for _, bot in pairs(getBots()) do
        if bot.status == BotStatus.online then
            local world = bot:getWorld()
            local worldName = world and world.name or "Unknown"
            local value = "<:WorldList:1156644357135409262> **World:** " .. worldName .. "\n" ..
                          "🎮 **Activity:** " .. getActivity(bot)
            embed:addField("<a:online:1160758807790624859> " .. bot.name .. " - Online", value, true)
        else
            embed:addField("<a:offline:1160758900279234670> " .. bot.name .. " - Offline", "💤 Tidak aktif", true)
        end
    end

    embed:addField("🕐 Last Update", getLastUpdateTime(), false)

    local wbh = Webhook.new(link)

    -- Ping disconnect di content (luar embed)
    if #disconnected > 0 then
        wbh.content = "<@1184002415272398898> <a:Angry:1252211602653053008> Bot disconnect sir!!"
    else
        wbh.content = ""
    end

    wbh:addEmbed(embed)

    if messageId == nil then
        local result = wbh:send()
        if result and result.id then
            messageId = result.id
        end
    else
        wbh:edit(messageId)
    end

    if updateStatus then
        lastUpdateTime = os.time()
        lastStatusUpdate = os.time()
    end
end

-- Inisialisasi status awal
for _, bot in pairs(getBots()) do
    prevStatus[bot.name] = bot.status == BotStatus.online
end

-- Main loop
while true do
    local now = os.time()
    sendOrEditStatus(now - lastStatusUpdate >= 120)
    sleep(30000)
end
