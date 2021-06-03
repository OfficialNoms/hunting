ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)ESX = obj end)

RegisterServerEvent('hunting:rewardShit')
AddEventHandler('hunting:rewardShit', function(weight,hash,animalid)
    -- weight is in kg
    math.randomseed(os.time())
    local xPlayer = ESX.GetPlayerFromId(source)
    local luck = math.random(1, 100)
    local grade = 0
    local meatAmount = math.ceil(weight / Config.MeatWeight * randomFloat(0.8,1.5))
    local usableSkin = math.random(1,5)
    local skinAmount = math.ceil(meatAmount / 5)
    
    if luck >= 95 then grade = 5
    elseif luck >= 85 then grade = 4 
    elseif luck >= 55 then grade = 3
    elseif luck >= 35 then grade = 2
    else grade = 1 end 

    --- This entire thing is experimental pending an update to linden_inventory to support drop creation exports, to use it you MUST apply your own changes to support the 'create' type to linden_inv (example in readme)
    local data = {
        toinv = 'drop',
        invid = 'carcass-'..animalid,
        frominv = 'carcass',
        toSlot = 1,
        type = 'create',
        item = {
            name = 'meat',
            slot = 1,
            weight = Config.MeatWeight,
            count = meatAmount,
            metadata = {grade = grade, animal = Config.Animals[hash].ModNam,type = Config.Animals[hash].label.." meat", description="A pile of Grade "..grade.." meat cut from a "..Config.Animals[hash].label.."."},
            stackable = true,
            label = 'Raw Meat',
        }
    }
    exports['linden_inventory']:CreateNewDrop(xPlayer, data,'carcass-'..animalid)
    TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, {type = 'inform', text = 'You have slaughtered an animal yielding a total of ' ..meatAmount.. 'pieces of meat.'})
    --[[
    if xPlayer.canCarryItem('meat', meatAmount) then
        xPlayer.addInventoryItem('meat', meatAmount, )
    else 
        TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, {type = 'error', text = 'You can\'t hold this much meat.'})
    end 

    if usableSkin > 2 then 
        if xPlayer.canCarryItem('leather', skinAmount) then
            xPlayer.addInventoryItem('leather', skinAmount, {grade = grade, animal = Config.Animals[hash].ModNam,type = Config.Animals[hash].label.." hide", description="A pile of Grade "..grade.." hide cut from a "..Config.Animals[hash].label.."."})
        else 
            TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, {type = 'error', text = 'You can\'t hold this much leather.'})
        end 
    end
    ]]--
end)

RegisterServerEvent('hunting:registerStateBag')
AddEventHandler('hunting:registerStateBag', function(carcass)
    print("Registering state bag (maybe?)")
    carcass = NetworkGetEntityFromNetworkId(carcass)
    Entity(carcass).state.skinning = true
end)


RegisterServerEvent('hunting:sellMeat')
AddEventHandler('hunting:sellMeat', function()
    math.randomseed(os.time())
    local xPlayer = ESX.GetPlayerFromId(source)
    local MeatPrice = math.random(27, 54)
    local payOut = 0 
    local quantity = 0

    for k,v in pairs(xPlayer.getInventory()) do 
        if v.name == 'meat' then 
            if v.metadata and v.metadata.grade then 
                local price =  math.ceil(MeatPrice * v.metadata.grade)
                payOut = payOut + price * v.count
                quantity = quantity + 1
                xPlayer.removeInventoryItem('meat', v.count)
            else 
                payOut = math.ceil(payOut + MeatPrice)
                quantity = quantity + 1 * v.count
                xPlayer.removeInventoryItem('meat', v.count)
            end 
        end
    end 

    xPlayer.addMoney(payOut)
    
    TriggerClientEvent('mythic_notify:client:DoLongHudText', xPlayer.source, {type = 'success', text = 'You have sold ' .. quantity .. ' meat and earned $' .. payOut .. '.', length = 10000})

end)

RegisterServerEvent('hunting:sellLeather')
AddEventHandler('hunting:sellLeather', function()
    math.randomseed(os.time())
    local xPlayer = ESX.GetPlayerFromId(source)
    local LeatherPrice = math.random(54, 87)
    local LeatherQuantity = xPlayer.getInventoryItem('leather').count

    
    if LeatherQuantity >= 1 then
        local quality = 1
        xPlayer.addMoney(quality * LeatherPrice * LeatherQuantity)
        xPlayer.removeInventoryItem('leather', LeatherQuantity)
        TriggerClientEvent('mythic_notify:client:DoLongHudText', xPlayer.source, {type = 'inform', text = 'You have sold ' .. LeatherQuantity .. '  leather and earned $' .. LeatherPrice * LeatherQuantity .. '.', length = 12500})
   else
        TriggerClientEvent('mythic_notify:client:DoLongHudText', xPlayer.source, {type = 'inform', text = 'You don\'t have any leather to sell?'})
    end
end)




function randomFloat(lower, greater)
    return lower + math.random()  * (greater - lower);
end