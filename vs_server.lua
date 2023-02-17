ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local drugtypes       = {'bag_cocaine','amfetamin','indica_weed','sativa_weed','purple_weed'}

RegisterServerEvent('william_drugselling:getcount')
AddEventHandler('william_drugselling:getcount', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local _source = source
    local count = 0

    for i,j in pairs(drugtypes) do
        local has = xPlayer.getInventoryItem(j).count
        count = count + has
    end

    TriggerClientEvent("william_drugselling:getcountreturn", _source,count)
end)

RegisterServerEvent('william_drugselling:getuserdrugs')
AddEventHandler('william_drugselling:getuserdrugs', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local _source = source

    local drugprices = {
        ["bag_cocaine"]={400,500},
        ["amfetamin"]={300,400},
        ["indica_weed"]={200,250},
        ["sativa_weed"]={250,300},
        ["purple_weed"]={225,275},
    }


    local druginfo        = {}

    local totalprofit     = 0
    local job = xPlayer.job.name

    function removedrug(x,y)
        xPlayer.removeInventoryItem(x,y)
    end

    for i,j in pairs(drugprices) do
        local c = xPlayer.getInventoryItem(i)
        if c.count > 0 then
            local amount     = math.random(1,c.count)
            local price      = math.random(j[1],j[2])
            local totalprice = price*amount
            removedrug(i,amount)
            xPlayer.addAccountMoney('black_money', totalprice)
            druginfo[i] = {
                ['amount']     = amount,
                ['price']      = price,
                ['totalprice'] = totalprice
            }
        end
    end

    --for i,j in pairs(druginfo) do
    --    print("Name   : "..i)
    --    print("Amount : "..j['amount'])
    --    print("Price  : "..j['price'])
    --    print("Tprice : "..j['totalprice'])
    --end

    for i,j in pairs(druginfo) do
        totalprofit = totalprofit + druginfo[i]['totalprice']
    end
    
    TriggerClientEvent("william_drugselling:returnuserdrugs",_source,druginfo,job)
end)

