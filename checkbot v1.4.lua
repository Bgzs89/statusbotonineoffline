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
    local lines = {}

    if #disconnected > 0 then
        table.insert(lines, "<@1184002415272398898> <a:Angry:1252211602653053008> Bot disconnect sir!!")
        for _, name in ipairs(disconnected) do
            table.insert(lines, "<a:aDevilGlare:1031194205441249382> **" .. name .. "** terputus!")
        end
        table.insert(lines, "")
    end

    table.insert(lines, "<a:b_animewiggle:947198246244192316>**Status Semua Bot**\n")

    for _, bot in pairs(getBots()) do
        if bot.status == BotStatus.online then
            local world = bot:getWorld()
            local worldName = world and world.name or "Unknown"
            table.insert(lines, "<a:online:1160758807790624859>" .. bot.name .. " - Online | <:WorldList:1156644357135409262> " .. worldName)
            table.insert(lines, "   ┗ " .. getActivity(bot))
        else
            table.insert(lines, "<a:offline:1160758900279234670>" .. bot.name .. " - Offline")
        end
    end

    table.insert(lines, "\n<a:TB_warning:1101039889170046997>**Last Update:** " .. getLastUpdateTime())

    local wbh = Webhook.new(link)
    wbh.content = table.concat(lines, "\n")

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
