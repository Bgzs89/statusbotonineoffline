local lastUpdateTime = nil  -- simpan waktu terakhir update

function getTimeAgo()
    if lastUpdateTime == nil then
        return "baru saja"
    end
    
    local diff = os.time() - lastUpdateTime  -- selisih detik
    
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
    
    if bot.auto_farm.enabled then
        table.insert(activities, "🌾 AutoFarm")
    end
    if bot.auto_geiger.enabled then
        table.insert(activities, "📡 AutoGeiger")
    end
    if bot.auto_spam.enabled then
        table.insert(activities, "💬 AutoSpam")
    end
    if bot.auto_fish.enabled then
        table.insert(activities, "🎣 AutoFish")
    end
    if bot.auto_harvest.enabled then
        table.insert(activities, "🌿 AutoHarvest")
    end
    if bot.auto_crime.enabled then
        table.insert(activities, "🔪 AutoCrime")
    end
    if bot.auto_cook.enabled then
        table.insert(activities, "🍳 AutoCook")
    end
    if bot.auto_collect then
        table.insert(activities, "💎 AutoCollect")
    end

    if #activities == 0 then
        return "💤 Idle"
    end
    
    return table.concat(activities, ", ")
end

function sendOrEditStatus()
    local text = "<a:b_animewiggle:947198246244192316>**Status Semua Bot**\n\n"
    
    for _, bot in pairs(getBots()) do
        if bot.status == BotStatus.online then
			local world = bot:getWorld()
            local worldName = "Unknown"
            if world ~= nil then
                worldName = world.name
            end
            text = text .. "<a:online:1160758807790624859>" .. bot.name .. " - Online | <:WorldList:1156644357135409262> " .. worldName .. "\n"
			text = text .. "   ┗ " .. getActivity(bot) .. "\n"
        else
            text = text .. "<a:offline:1160758900279234670>" .. bot.name .. " - Offline\n"
        end
    end
    
    -- Tampilkan last update
    text = text .. "\n<a:TB_warning:1101039889170046997>**Last Update:** " .. getTimeAgo()
    
    local wbh = Webhook.new(link)
    wbh.content = text

    if messageId == nil then
        wbh:send()
    else
        wbh:edit(messageId)
    end
    
    -- Update waktu setelah kirim
    lastUpdateTime = os.time()
end

while true do
    sendOrEditStatus()
    sleep(1000)
end
