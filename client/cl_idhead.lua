--[[

 _   _          _____    _            _   _  __ _           _             
| \ | |        |_   _|  | |          | | (_)/ _(_)         | |            
|  \| | _____  __| |  __| | ___ _ __ | |_ _| |_ _  ___ __ _| |_ ___  _ __ 
| . ` |/ _ \ \/ /| | / _` |/ _ \ '_ \| __| |  _| |/ __/ _` | __/ _ \| '__|
| |\  |  __/>  <_| || (_| |  __/ | | | |_| | | | | (_| (_| | || (_) | |   
\_| \_/\___/_/\_\___/\__,_|\___|_| |_|\__|_|_| |_|\___\__,_|\__\___/|_|   
                                                                          
Distributed by Ukader Network, whose developer has publicly released this copy to the general public. Use it under the GNU AGPL v3 license.
Support is limited, but you can contact the following links: 

Discord: AlexBanPer#4245
Mail: a.martinez@ukader.net
General Support: support@ukader.net
Official Discord: https://discord.gg/rmCv7UJVPD

We appreciate publishing any modification to this under the concepts of collaborative work.                                                                   

]]

local disPlayerNames = Config.IdHeadMinimumDistance
local adminDistance = Config.IdHeadMaxAdminDistane

local playerDistances = {}
local showIDsAboveHead = false

local isAdmin = false
local displayAdmin = Config.IdHeadDisplayAdminInfo
local displayAdminExtra = Config.IdHeadDisplayAdminExtraInfo
local chatOpen = false
local playersDB = {}

NEX = nil

TriggerEvent('nexus:getNexusObject', GetCurrentResourceName(), function(obj) 
    NEX = obj 
end)
    
RegisterNetEvent('nexus:Id:PlayersData')
AddEventHandler('nexus:Id:PlayersData', function(data, isForced)
    playersDB = data
end)

RegisterNetEvent("nexus:Id:ToggleAdminInfo")
AddEventHandler("nexus:Id:ToggleAdminInfo", function()
	displayAdmin = not displayAdmin
end)

RegisterNetEvent("nexus:Id:ToggleAdminExtraInfo")
AddEventHandler("nexus:Id:ToggleAdminExtraInfo", function()
	displayAdminExtra = not displayAdminExtra
end)


RegisterNetEvent("chat:IsShowOpen")
AddEventHandler("chat:IsShowOpen", function(value)
	chatOpen = value
	if not value then
		TriggerServerEvent("ID:OpenChat", false)
	end
end)

RegisterNetEvent('nexus:Id:SetIntegrityAsStaff')
AddEventHandler('nexus:Id:SetIntegrityAsStaff', function()
	print("[INTEGRIDAD] Acceso administrativo consedido.")
	isAdmin = true
end)

Citizen.CreateThread(function()
    while Config.EnableIdHead do 
        if IsControlPressed(0, Config.IdHeadKeyCode) then
            showIDsAboveHead = not showIDsAboveHead
            Citizen.Wait(500)
        end

        if IsControlPressed(0, 245) then
			TriggerServerEvent("ID:OpenChat", true)
			Citizen.Wait(500)
		end
        Citizen.Wait(5)
    end
end)


Citizen.CreateThread(function()
	while Config.EnableIdHead do
		if showIDsAboveHead then
            for _, id in ipairs(GetActivePlayers()) do
                local playerPed = GetPlayerPed(id)
				if playerPed ~= GetPlayerPed(-1) then 
					if NetworkIsPlayerActive(id) then
						distance = math.floor(#(GetEntityCoords(GetPlayerPed(-1), true) - GetEntityCoords(playerPed, true)))
                        playerDistances[id] = distance
						Citizen.Wait(400)
					end
				end
            end
            Citizen.Wait(2500)
		end
        Citizen.Wait(1500)
    end
end)

function getPlayerDB(id)
	for _, v in pairs(playersDB) do
		if tostring(v.playerPid) == tostring(GetPlayerServerId(id)) then
			return v
		end
	end
	return nil
end

Citizen.CreateThread(function()
	while Config.EnableIdHead do
        Citizen.Wait(5)
        for _, id in ipairs(GetActivePlayers()) do 
            if NetworkIsPlayerActive(id) then
                if GetPlayerPed(id) ~= GetPlayerPed(-1) then 
                    if (playerDistances[id] ~= nil) and (playerDistances[id] <= 8) then
                        local x2, y2, z2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
                        local v2 = getPlayerDB(id)
                        if v2 ~= nil then
                            if tostring(v2.playerPid) == tostring(GetPlayerServerId(id)) then
                                if v2.texting then
                                    DrawText3D(x2, y2, z2+1.5, 2, " 💬 ", 255,255,24)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)


Citizen.CreateThread(function()
    while Config.EnableIdHead do
		Citizen.Wait(5)
        if showIDsAboveHead then
            for _, player in pairs(playersDB) do
                local targetSource = player.playerPid
                
                local playerServerID = GetPlayerFromServerId(targetSource)
                local targetPed = GetPlayerPed(playerServerID)

                if targetPed ~= GetPlayerPed(-1) and NetworkIsPlayerActive(playerServerID) then
                    local x2, y2, z2 = table.unpack(GetEntityCoords(targetPed, true))
                    if playerDistances[playerServerID] ~= nil then
                        local concatenation = targetSource .. " [".. player.id .."]"
                        if isAdmin and playerDistances[playerServerID] <= adminDistance and playerDistances[playerServerID] > disPlayerNames then
                            if displayAdmin and isAdmin then
                                if displayAdminExtra then
                                    local health = GetEntityHealth(targetPed)
                                    DrawText3D(x2, y2, z2+2.1, 8,  "Salud: " .. health .. "/200 | (" .. player.job ..")" , 200,255,0)
                                end
                                DrawText3D(x2, y2, z2+1.6, 8,  player.steam .. " [CharId: ".. player.charId .."]", 0,190,255)                            end
                            if NetworkIsPlayerTalking(playerServerID) then
                                DrawText3D(x2, y2, z2+1, 7, concatenation, 247,124,24)
                            else
                                DrawText3D(x2, y2, z2+1, 7, concatenation, 255,255,255)
                            end
                        else
                            if playerDistances[playerServerID] <= disPlayerNames then
                                if displayAdmin and isAdmin then
                                    if displayAdminExtra then
                                        local health = GetEntityHealth(targetPed)
                                        DrawText3D(x2, y2, z2+1.6, 2,  "Salud: " .. health .. "/200 | (" .. player.job ..")" , 200,255,0)
                                    end
                                    DrawText3D(x2, y2, z2+1.5, 2,  player.steam .. " [CharId: ".. player.charId .."]", 0,190,255)
                                end

                                if NetworkIsPlayerTalking(playerServerID) then
                                    DrawText3D(x2, y2, z2+1.2, 1.8, concatenation, 247,124,24)
                                else
                                    DrawText3D(x2, y2, z2+1.2, 1.8, concatenation, 255,255,255)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)


function DrawText3D(x,y,z, scaleX, text, r,g,b) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = (1/dist)*scaleX
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
   
    if onScreen then
        SetTextScale(0.0*scale, 0.55*scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(r, g, b, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end