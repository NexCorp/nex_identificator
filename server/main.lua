NEX = nil
local CachedPlayers = {}
local TextingPlayers = {}
local forcedReload = false

Citizen.CreateThread(function()
    while NEX == nil do
        Citizen.Wait(5)
        TriggerEvent("nexus:getNexusObject", function(obj) NEX = obj end)
    end

    NEX.RegisterCommand(Config.IdHeadDisplayAdminInfoCommand, 'admin', function(xPlayer, args, showError)
        TriggerEvent('nexus:Id:ToggleAdminInfo', xPlayer.source)
    end, false, {help = 'Hide administrative ID information.', validate = true, arguments = {}})

    NEX.RegisterCommand(Config.IdHeadDisplayAdminExtraInfoCommand, 'admin', function(xPlayer, args, showError)
        TriggerEvent('nexus:Id:ToggleAdminExtraInfo', xPlayer.source)
    end, false, {help = 'Hide extra administrative ID information.', validate = true, arguments = {}})

	while true do
		Citizen.Wait(Config.ServerSendSignalTimer * 1000)
		SendHeadInfoToServerPlayers()
	end
end)

isAdmin = function(source)
    local xPlayer = NEX.GetPlayerFromId(source)
    if xPlayer.getGroup() == 'admin' then --Change this to 'admin'
        return true
    end
    return false
end

SendHeadInfoToServerPlayers = function()
    Citizen.CreateThread(function()
        local xPlayers = NEX.GetPlayers()
        local xData = {}

        for i=1, #xPlayers, 1 do
            local xPlayer = NEX.GetPlayerFromId(xPlayers[i])
            local source = xPlayer.source
            local identifier = xPlayer.identifier
            local dbId = xPlayer.dbId
            local name = xPlayer.getName()
            local charId = xPlayer.charId
            local job = xPlayer.getJob().name

            local data = { identifier = identifier, name = name, database = dbId }

            local isTexting = false
            for _, v2 in pairs(TextingPlayers) do
                if tostring(v2.id) == tostring(source) then
                    isTexting = v2.toggle
                    break
                end
            end

            local data = { playerPid = source, job = job, charId = charId, id = dbId, steam = name, texting = isTexting }
            table.insert(xData, data)

        end
        TriggerClientEvent('nexus:Id:PlayersData', -1, xData)
    end)
end

RegisterNetEvent('nexus:Id:ToggleChat')
AddEventHandler('nexus:Id:ToggleChat', function(toggle)
    for k, v in pairs(TextingPlayers) do
        if v.id == source then
            v.toggle = toggle
            break
        end
    end
end)


RegisterNetEvent('nexus:Id:CheckIntegrity')
AddEventHandler('nexus:Id:CheckIntegrity', function()
    table.insert(TextingPlayers, {id=source, toggle = false}) 
    if isAdmin(source) then
        TriggerClientEvent('nexus:Id:SetIntegrityAsStaff', source)
    end
end)

RegisterNetEvent('nexus:Id:ToggleAdminGhost')
AddEventHandler('nexus:Id:ToggleAdminGhost', function(target)
    local xSource = source
    if target ~= nil then
        xSource = target
    end

    if isAdmin(xSource) then
        -- (WIP) Toggle id invisible for admins
    end
end)

RegisterNetEvent('nexus:Id:ToggleAdminExtraInfo')
AddEventHandler('nexus:Id:ToggleAdminExtraInfo', function(target)
    local xSource = source
    if target ~= nil then
        xSource = target
    end

    if isAdmin(xSource) then
        TriggerClientEvent('nexus:Id:ToggleAdminExtraInfo', xSource)
    end
end)

RegisterNetEvent('nexus:Id:ToggleAdminInfo')
AddEventHandler('nexus:Id:ToggleAdminInfo', function(target)
    local xSource = source
    if target ~= nil then
        xSource = target
    end
    if isAdmin(xSource) then
        TriggerClientEvent('nexus:Id:ToggleAdminInfo', xSource)
    end
end)


RegisterServerEvent("nexus:Id:SetDatabaseIdentifier")
AddEventHandler('nexus:Id:SetDatabaseIdentifier', function()
    local xPlayer = NEX.GetPlayerFromId(source)
    TriggerClientEvent('nexus:Id:SetDatabaseIdentifier', source, xPlayer.dbId)
end)


