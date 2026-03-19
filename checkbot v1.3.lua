local lastUpdateTime = nil
local lastStatusUpdate = 0
local prevStatus = {}

function getTimeAgo()
    if lastUpdateTime == nil then
        return "baru saja"
    end
    local diff = os.time() - lastUpdateTime
    if diff < 60 then
        return diff .. " detik yang lalu"
    elseif diff < 3600 then
        local minutes = math.floor(diff / 60)
        return minutes .. " menit yang lalu"
    else
        local hours = math.floor(diff / 3600)
        return hours .. " jam yang lalu"
    end
end

function getActivity(bot)
    local activities = {}
    if bot.auto_farm.enabled then table.insert(activities, "🌾 AutoFarm") end
    if bot.auto_geiger.enabled then table.insert(activities, "📡 AutoGeiger") end
    if bot.auto_spam.enabled then table.insert(activities, "💬 AutoSpam") end
    if bot.auto_fish.enabled then table.insert(activities, "🎣 AutoFish") end
    if bot.auto_harvest.enabled then table.insert(activities, "🌿 AutoHarvest") end
    if bot.auto_crime.enabled then table.insert(activities, "🔪 AutoCrime") end
    if bot.auto_cook.enabled then table.insert(activities, "🍳 AutoCook") end
    if bot.auto_collect then table.insert(activities, "💎 AutoCollect") end
    if #activities == 0 then return "💤 Idle" end
    return table.concat(activities, ", ")
end

function checkDisconnected()
    local disconnected = {}
    for _, bot in pairs(getBots()) do
        local current = bot.status == BotStatus.online
        local prev = prevStatus[bot.name]
        if prev == true and current == false then
            table.insert(disconnected, bot.name)
        end
        prevStatus[bot.name] = current
    end
    return disconnected
end

function sendOrEditStatus(updateStatus)
    local disconnected = checkDisconnected()
    local text = ""

    if #disconnected > 0 then
        text = "<@1184002415272398898> <a:Angry:1252211602653053008> Bot disconnect sir!!\n"
        for _, name in pairs(disconnected) do
            text = text .. "<a:aDevilGlare:1031194205441249382> **" .. name .. "** terputus!\n"
        end
        text = text .. "\n"
    end

    text = text .. "<a:b_animewiggle:947198246244192316>**Status Semua Bot**\n\n"

    for _, bot in pairs(getBots()) do
        if bot.status == BotStatus.online then
            local world = bot:getWorld()
            local worldName = world ~= nil and world.name or "Unknown"
            text = text .. "<a:online:1160758807790624859>" .. bot.name .. " - Online | <:WorldList:1156644357135409262> " .. worldName .. "\n"
            text = text .. "   ┗ " .. getActivity(bot) .. "\n"
        else
            text = text .. "<a:offline:1160758900279234670>" .. bot.name .. " - Offline\n"
        end
    end

    text = text .. "\n<a:TB_warning:1101039889170046997>**Last Update:** " .. getTimeAgo()

    local wbh = Webhook.new(link)
    wbh.content = text
    if messageId == nil then
        wbh:send()
    else
        wbh:edit(messageId)
    end

    if updateStatus then
        lastUpdateTime = os.time()
        lastStatusUpdate = os.time()
    end
end

for _, bot in pairs(getBots()) do
    prevStatus[bot.name] = bot.status == BotStatus.online
end

while true do
    local now = os.time()
    if now - lastStatusUpdate >= 120 then
        sendOrEditStatus(true)
    else
        sendOrEditStatus(false)
    end
    sleep(30000)
end
