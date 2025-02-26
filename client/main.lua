ESX = nil
ESX = exports['es_extended']:getSharedObject()

RegisterCommand('checkvip', function()
    -- ดึงข้อมูลวันหมดอายุจากเซิร์ฟเวอร์
    exports.udg_vip:getvip(function(level)
        if level then
            vipLevel = string.upper(level)
        end
    end)

    ESX.TriggerServerCallback('vip:getExpiry', function(result)
        if result.status then
            -- ถ้ามีสถานะ VIP ที่ยังไม่หมดอายุ แสดงเวลาที่เหลือ
            TriggerEvent('chat:addMessage', { 
                color = {255, 0, 0},
                multiline = true,
                args = {
                    'Your VIP Level : [ '..vipLevel..' ]  expires in ' .. result.days .. ' days, ' .. result.hours .. ' hours, ' .. result.minutes .. ' minutes.'
                }
            })
            
        else
            -- ถ้า VIP หมดอายุ หรือไม่มี VIP
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {
                    'Your VIP has expired or you do not have VIP status.'
                }
            })
        end
    end)
end, false)





RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    -- ดึงข้อมูลวันหมดอายุจากเซิร์ฟเวอร์
    Citizen.Wait(15000)
    ESX.TriggerServerCallback('vip:getExpiry', function(result)
        if result.status then
            -- ถ้ามีสถานะ VIP ที่ยังไม่หมดอายุ แสดงเวลาที่เ
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {
                    'Your VIP expires in ' .. result.days .. ' days, ' .. result.hours .. ' hours, ' .. result.minutes .. ' minutes.'
                }
            })
        else
            -- ถ้า VIP หมดอายุ หรือไม่มี VIP
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {
                    'Your VIP has expired or you do not have VIP status.'
                }
            })
        end
    end)
end)



function getvip(cb)
    ESX.TriggerServerCallback('vip:level', function(result)
        if result.status then
            cb(result.level)  -- ส่งระดับ VIP กลับไป
        else
            cb(false) -- หากไม่มี VIP หรือไม่ได้เป็นระดับที่ถูกต้อง
        end
    end)
end

exports('getvip', getvip)



--[[
วิธีการใช้งาน

RegisterCommand('vip', function()
    exports.udg_vip:getvip(function(level)
        if level then
            print("Your VIP level is: " .. level)  -- แสดงระดับ VIP
        else
            print("You do not have a VIP level or the level is invalid.")  -- ไม่มี VIP หรือระดับไม่ถูกต้อง
        end
    end)
end)

]]



RegisterNetEvent('updateitemsql')
AddEventHandler('updateitemsql', function(item)
    print(json.encode(item))
end)

RegisterCommand('h5', function()
    TriggerEvent('esx_status:remove', 'stress', 50000000)
end)