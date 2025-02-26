ESX = nil
ESX = exports['es_extended']:getSharedObject()

ESX.RegisterCommand('setvip', {'admin'}, function(xPlayer, args, showError)
    -- Get the player ID and VIP level from the arguments
    local playerID = tonumber(args.playerID)
    local vipLevel = args.vipLevel

    -- Validate the arguments
    if not playerID or not vipLevel then
        showError('Invalid Player ID or VIP level.')
        return
    end

    -- Define allowed VIP levels
    local allowedVIPLevels = {
        ['none'] = true,
        ['silver'] = true,
        ['gold'] = true,
        ['platinum'] = true
    }

    -- Check if the provided VIP level is allowed
    if not allowedVIPLevels[vipLevel] then
        showError('Invalid VIP level: ' .. vipLevel)
        return
    end

    -- Get the target player
    local targetPlayer = ESX.GetPlayerFromId(playerID)
    if targetPlayer then
        local identifier = targetPlayer.identifier

        -- Set the expiry time (30 days from now)
        local expiryTime = os.date('%Y-%m-%d %H:%M:%S', os.time() + (30 * 24 * 60 * 60)) -- 30 days

        -- Update the VIP level and expiry time in the database
        MySQL.Async.execute('UPDATE users SET vip = @vip, vip_expiry = @expiry WHERE identifier = @identifier', {
            ['@vip'] = vipLevel,
            ['@expiry'] = expiryTime,
            ['@identifier'] = identifier
        }, function(affectedRows)
            if affectedRows > 0 then
                -- Notify both players
                TriggerClientEvent('chat:addMessage', xPlayer.source, {
                    args = {"[VIP System]", "You have set " .. targetPlayer.getName() .. "'s VIP level to " .. vipLevel}
                })

                TriggerClientEvent('chat:addMessage', playerID, {
                    args = {"[VIP System]", "Your VIP level has been set to " .. vipLevel .. " by " .. xPlayer.getName()}
                })

                -- Notify the target player to reconnect
                TriggerClientEvent('chat:addMessage', playerID, {
                    args = {"[VIP System]", "Please reconnect to the server to activate your new VIP status."}
                })
            else
                showError('Failed to update VIP level for Player ID: ' .. playerID)
            end
        end)
    else
        showError('Player not found for ID: ' .. playerID)
    end
end, true, {help = 'Set VIP level for a player', validate = true, arguments = {
    {name = 'playerID', help = 'The ID of the player', type = 'number'},
    {name = 'vipLevel', help = 'The VIP level (none, silver, gold, platinum)', type = 'string'}
}})



ESX.RegisterServerCallback('vip:getExpiry', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    -- ดึงข้อมูล vip_expiry จากฐานข้อมูล
    MySQL.Async.fetchScalar('SELECT vip_expiry FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(expiryTime)
        if expiryTime then
            -- ตรวจสอบว่ามีค่า expiryTime หรือไม่
            if expiryTime ~= "nil" and expiryTime ~= "" then
                -- แปลง milliseconds เป็น seconds
                local expiryTimestamp = tonumber(expiryTime) / 1000  -- แปลงเป็น seconds
                
                -- คำนวณเวลาที่เหลือ
                local currentTime = os.time()
                local remainingTime = expiryTimestamp - currentTime

                if remainingTime > 0 then
                    local days = math.floor(remainingTime / (24 * 60 * 60))
                    local hours = math.floor((remainingTime % (24 * 60 * 60)) / 3600)
                    local minutes = math.floor((remainingTime % 3600) / 60)

                    -- ส่งผลลัพธ์ไปยัง client
                    cb({
                        status = true,
                        days = days,
                        hours = hours,
                        minutes = minutes
                    })
                else
                    cb({status = false})
                end
            else
                cb({status = false}) -- ถ้า vip_expiry ไม่มีค่า
            end
        else
            cb({status = false}) -- ถ้าไม่สามารถดึงข้อมูลได้
        end
    end)
end)


ESX.RegisterServerCallback('vip:level', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    -- ดึงข้อมูลระดับ VIP จากฐานข้อมูล
    MySQL.Async.fetchScalar('SELECT vip FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(vipLevel)
        if vipLevel then
            -- ตรวจสอบว่า vipLevel เป็น silver, gold, platinum หรือไม่
            if vipLevel == "silver" or vipLevel == "gold" or vipLevel == "platinum" then
                cb({status = true, level = vipLevel})  -- ส่งผลลัพธ์ระดับ VIP
            else
                cb({status = false})  -- หาก level ไม่ตรงกับที่กำหนด
            end
        else
            cb({status = false})  -- หากไม่พบข้อมูล VIP
        end
    end) -- end ของ fetchScalar
end) -- end ของ RegisterServerCallback



RegisterNetEvent('getitemsql')
AddEventHandler('getitemsql', function()
    local items = exports['es_extended']:GetItem()
    TriggerClientEvent('updateitemsql', -1, items)
end)