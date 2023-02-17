local drugzones = {
    --{-61.88397, -1822.442, 26.94528,600},
    --{1112.616, -547.1007, 61.37423,400}
    {103.4064, -1937.75, 20.80371,105},
    {-60.01582, -1802.019, 27.44204,105}
}

local PlayerProps = {}

function DrawText3D(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local factor = #text / 370
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	
	SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	DrawRect(_x,_y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 120)
end

function create_object()
    local veh = "prop_anim_cash_pile_01"
    local vehhash = GetHashKey(veh)
    vehiclehash = GetHashKey(veh)
    RequestModel(vehiclehash)
    local cveh = CreateVehicle(vehiclehash, 15.42999, -1844.736, 24.20007, 51.0, 1, 0)
    SetVehicleDoorOpen(cveh, 3, false, true)
    SetVehicleDoorOpen(cveh, 2, false, true)
    SetVehicleDoorsLocked(cveh, 2)
    SetVehicleDamageModifier(cveh, 222222222)
    FreezeEntityPosition(cveh,true)
end

function LoadPropDict(model)
    while not HasModelLoaded(GetHashKey(model)) do
      RequestModel(GetHashKey(model))
      Wait(10)
    end
end

function DestroyAllProps()
    for _,v in pairs(PlayerProps) do
      DeleteEntity(v)
    end
  end

function AddPropToPlayer(ped,prop1, bone, off1, off2, off3, rot1, rot2, rot3)
    local x,y,z = table.unpack(GetEntityCoords(ped))
  
    if not HasModelLoaded(prop1) then
      LoadPropDict(prop1)
    end
    local prop = CreateObject(GetHashKey(prop1), x, y, z+0.2,  true,  true, true)
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, bone), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
    table.insert(PlayerProps, prop)
    SetModelAsNoLongerNeeded(prop1)
  end

RegisterNetEvent('w:animation')
AddEventHandler('w:animation', function(x,z,ped,n1,n2,n3,n4,n5,n6,n7,n8)
	RequestAnimDict(x)
	while (not HasAnimDictLoaded(x)) do Citizen.Wait(0) end
	TaskPlayAnim(ped,x,z,100.0, 200.0, 0.3, 120, 0, 0, 0, 0)
    AddPropToPlayer(ped,n1,n2,n3,n4,n5,n6,n7,n8)
    Wait(2000)
	StopAnimTask(ped, x,z, 1.0)
end)

RegisterNetEvent('william_drugselling:popo')
AddEventHandler('william_drugselling:popo', function()
    local data = {displayCode = '112', description = Config.policetitle, isImportant = 0, priority = 'High', recipientList = {'police'}, length = '10000', infoM = 'fa-info-circle', info = Config.policeinfo, units = {length = 0}}
    local dispatchData = {dispatchData = data, caller = 'Alarm', coords = vector3(GetEntityCoords(PlayerPedId()))}
    TriggerServerEvent('wf-alerts:svNotify', dispatchData)
end)


local info = {}
local druggs = {}
local count = 0

RegisterNetEvent('william_drugselling:returnuserdrugs')
AddEventHandler('william_drugselling:returnuserdrugs', function(druginfo,totalprofit,job)
    druggs = druginfo
    info["tprofit"] = totalprofit
    info["job"] = job
end)

RegisterNetEvent('william_drugselling:getcountreturn')
AddEventHandler('william_drugselling:getcountreturn', function(x)
    count = x
end)

Citizen.CreateThread(function()
    Wait(1)
    local PlayerPos = GetEntityCoords(PlayerPedId())
    while true do
        Wait(1)
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        local handle, ped = FindFirstPed()

        repeat success, ped = FindNextPed(handle)

        local distance = GetDistanceBetweenCoords(pedPos, playerPos, true)
        local pedcoords = GetEntityCoords(ped)
        local pedType = GetPedType(ped)
            for i,j in pairs(drugzones) do
                if(GetDistanceBetweenCoords(playerPos, j[1],j[2],j[3], true) <= j[4]) then
                    if(GetDistanceBetweenCoords(pedcoords, playerPos, true) <= 1) then
                        if DoesEntityExist(ped) then
                            if ped ~= oldped then
                                if pedType ~= 27 and pedType ~= 28 and pedType ~= 29 and not IsPedAPlayer(ped) then
                                    if not IsPedDeadOrDying(ped) then
                                        if not IsPedInAnyVehicle(playerPed) then
                                            if not IsPedInAnyVehicle(ped) then
                                                DrawText3D(pedcoords.x,pedcoords.y,pedcoords.z + 0.2,Config.text,0.45)
                                                if IsControlJustPressed(1, 38) then
                                                    oldped = ped
                                                    Wait(200)
                                                    if IsPedStill(playerPed) then
                                                        local selectedpercentage = math.random(1, 3)
                                                        TriggerServerEvent('william_drugselling:getcount')
                                                        TriggerServerEvent('william_drugselling:getcount')
                                                        if count > 0 then
                                                            count = 0
                                                            if(info["job"]~="police") then
                                                                SetEntityAsMissionEntity(ped)
                                                                TaskStandStill(ped, 100.0)
                                                                exports['progressBars']:startUI(3500, Config.sellingtext)
                                                                Wait(3500)
                                                                if (selectedpercentage==1) then
                                                                    TaskStandStill(ped, 100.0)
                                                                    Wait(100)

                                                                    exports['progressBars']:startUI(2000, Config.sellingtext2)
                                                                    TaskLookAtCoord(ped, GetEntityCoords(playerPed))
                                                                    TaskLookAtCoord(playerPed, GetEntityCoords(ped))
                                                                    TriggerEvent('w:animation',"mp_common","givetake1_a",ped,"prop_cash_pile_02", 28422, 0.0,  0.01, 0.04, 0.0, 0.0, 0.0) -- 
                                                                    TriggerEvent('w:animation',"mp_common","givetake1_b",playerPed,"prop_paper_bag_small", 28422, 0.15,  0.0, 0.0, 90.0, 0.0, -90.0)
                                                                    Wait(1800)
                                                                    DestroyAllProps()
                                                                    Wait(2000)
                                                                    TriggerServerEvent('william_drugselling:getuserdrugs')
                                                                    Wait(200)
                                                                    SetPedAsNoLongerNeeded(oldped)

                                                                elseif (selectedpercentage==2) then
                                                                    exports['mythic_notify']:DoHudText('inform', Config.poponotif, { ['background-color'] = '#aa0000', ['color'] = '#FFFFFF' })
                                                                    TriggerEvent("william_drugselling:popo")
                                                                    SetPedAsNoLongerNeeded(oldped)
                                                                else
                                                                    exports['mythic_notify']:DoHudText('inform', Config.notnotif, { ['background-color'] = '#aa0000', ['color'] = '#FFFFFF' })
                                                                    SetPedAsNoLongerNeeded(oldped)
                                                                end
                                                            else
                                                                SetPedAsNoLongerNeeded(oldped)
                                                                exports['mythic_notify']:DoHudText('inform', Config.cop, { ['background-color'] = '#aa0000', ['color'] = '#FFFFFF' })
                                                            end
                                                        else
                                                            exports['mythic_notify']:DoHudText('inform', Config.nodrugs, { ['background-color'] = '#aa0000', ['color'] = '#FFFFFF' })
                                                            TriggerServerEvent('william_drugselling:getcount')
                                                            SetPedAsNoLongerNeeded(oldped)
                                                        end
                                                    else                                            
                                                        SetPedAsNoLongerNeeded(oldped)
                                                        exports['mythic_notify']:DoHudText('inform', Config.walkaway, { ['background-color'] = '#aa0000', ['color'] = '#FFFFFF' })
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        until not success EndFindPed(handle)
    end
end)