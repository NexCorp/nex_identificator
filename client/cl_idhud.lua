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

local myId = 0;
local myServerId = GetPlayerServerId(NetworkGetEntityOwner(PlayerPedId()))

local LoadServerId = function()
    TriggerServerEvent("nexus:Id:SetDatabaseIdentifier",  GetPlayerServerId(-1))
    TriggerServerEvent('nexus:Id:CheckIntegrity')
end

local miid = function(text)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(0.35, 0.35)
    SetTextColour( 0,0,0, 255 )
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(Config.IdHudX, Config.IdHudY)
end

RegisterNetEvent("nexus:Id:SetDatabaseIdentifier")
AddEventHandler("nexus:Id:SetDatabaseIdentifier", function(data)
    print("[INTEGRITY] Database ID: " .. data)
    myId = data
end)

Citizen.CreateThread(function()
    Citizen.Wait(2000)
    LoadServerId()

    while Config.EnableIdHud do	
        miid("~w~ID:  ".. myServerId .. " [DB: ".. myId .."]")	
        Citizen.Wait(5)	
    end
end)