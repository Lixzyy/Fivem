ESX = {};
TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

-- wrap native GetPlayerName to prevent null/zero argument errors
-- the engine throws a SCRIPT ERROR when the parameter is nil/0, so
-- we bail out early and return nil instead. any code that needs a
-- fallback string should handle the nil return value.
local _origGetPlayerName = GetPlayerName
GetPlayerName = function(id)
    if not id or id == 0 then
        return nil
    end
    return _origGetPlayerName(id)
end

local staff = {}
local allreport = {}
local reportcount = {}

local function IsStaff(x)
    -- accepts a group string, a player source number, or an xPlayer table
    if type(x) == 'string' then
        local group = x
        return group == "support" or group == "mod" or group == "admin" or group == "manager" or group == "owner" or group == "superadmin"
    end
    local src = nil
    if type(x) == 'number' then
        src = x
    elseif type(x) == 'table' and x.getGroup then        -- when receiving an xPlayer table, prefer using the object; permission checks use group/DB        local group = x.getGroup and x.getGroup() or nil
        if group and (group == "support" or group == "mod" or group == "admin" or group == "manager" or group == "owner" or group == "superadmin") then
            return true
        end
        src = x.source
    end
    if src then
        local xPlayer = ESX.GetPlayerFromId(src)
        -- avoid infinite recursion by checking the group string instead of passing the xPlayer table back into IsStaff
        if xPlayer and xPlayer.getGroup and IsStaff(xPlayer.getGroup()) then return true end
        -- license-based fallback removed; relying on DB/group only

    end
    return false
end

local function IsAdminOrHigher(x)
    if type(x) == 'string' then
        return x == "admin" or x == "manager" or x == "owner" or x == "superadmin"
    end
    local src = nil
    if type(x) == 'number' then
        src = x
    elseif type(x) == 'table' and x.getGroup then
        src = x.source
    end
    if src then
        -- license-based fallback removed; relying on group/DB only
        local xPlayer = ESX.GetPlayerFromId(src)
        -- avoid infinite recursion by checking the group string instead of passing the xPlayer table back into IsAdminOrHigher
        if xPlayer and xPlayer.getGroup and IsAdminOrHigher(xPlayer.getGroup()) then return true end
    end
    return false
end

-- License-based staff checks removed: using DB/group checks only
-- (HasStaffLicense removed)


-- Validate Config.Licenses on startup and warn about malformed entries
-- License config validation removed (no longer used)


-- CheckMyLicense debug removed (not used)


-- Lixzy:isPlayerStaffByLicense removed; no client-side license checks anymore


-- load tenuestaff/outfits.json from the `tenuestaff` resource if present
local TenueOutfits = {}
local status, content = pcall(LoadResourceFile, 'tenuestaff', 'outfits.json')
if status and content then
    local ok, parsed = pcall(json.decode, content)
    if ok and parsed then
        TenueOutfits = parsed
        -- print debug supprimé
    end
end

RegisterServerEvent('Lixzy:RequestOutfits')
AddEventHandler('Lixzy:RequestOutfits', function()
    TriggerClientEvent('Lixzy:LoadGroupOutfits', source, TenueOutfits)
end)

-- command ping
TriggerEvent('es:addGroupCommand', 'ping', 'user', function(source)
    local pname = GetPlayerName(source) or tostring(source)
    TriggerClientEvent('esx:showAdvancedNotification', source, 'PING', '~b~' .. pname .. '', 'Votre ping est de ~n~~r~'..GetPlayerPing(source)..' MS', 'CHAR_CHAT_CALL', 0)
end)

-- command report

-- ============================================================
-- SYSTÈME DE REPORT AVEC MENU
-- ============================================================

-- Callback pour vérifier si le joueur a un report en attente
ESX.RegisterServerCallback('Lixzy:HasPendingReport', function(source, cb)
    local ids = GetPlayerIdentifiers(source) or {}
    local reporter_identifier = ''
    for _, id in ipairs(ids) do
        if type(id) == 'string' then
            if string.sub(id,1,6) == 'steam:' then 
                reporter_identifier = id 
                break 
            end
            if string.sub(id,1,8) == 'license:' and reporter_identifier == '' then 
                reporter_identifier = id 
            end
        end
    end
    
    MySQL.Async.fetchAll('SELECT id, reason FROM reports WHERE reporter_identifier = @ident LIMIT 1', {
        ['@ident'] = reporter_identifier
    }, function(rows)
        if rows and #rows > 0 then
            cb(rows[1])
        else
            cb(nil)
        end
    end)
end)

-- Événement pour annuler un report
RegisterServerEvent('Lixzy:CancelReport')
AddEventHandler('Lixzy:CancelReport', function()
    local source = source
    
    local ids = GetPlayerIdentifiers(source) or {}
    local reporter_identifier = ''
    for _, id in ipairs(ids) do
        if type(id) == 'string' then
            if string.sub(id,1,6) == 'steam:' then 
                reporter_identifier = id 
                break 
            end
            if string.sub(id,1,8) == 'license:' and reporter_identifier == '' then 
                reporter_identifier = id 
            end
        end
    end
    
    MySQL.Async.execute('DELETE FROM reports WHERE reporter_identifier = @ident', {
        ['@ident'] = reporter_identifier
    }, function(affected)
        if affected and affected > 0 then
            TriggerClientEvent('esx:showNotification', source, '~g~Votre report a été annulé')
            TriggerClientEvent('Lixzy:RefreshPlayerReport', source)
            
            local xPlayers = ESX.GetPlayers()
            for i=1, #xPlayers, 1 do
                local xP = ESX.GetPlayerFromId(xPlayers[i])
                if xP then
                    local group = xP.getGroup and xP.getGroup() or 'user'
                    if group == "support" or group == "mod" or group == "admin" or group == "manager" or group == "owner" or group == "superadmin" then
                        TriggerClientEvent("Lixzy:RefreshReport", xP.source)
                    end
                end
            end
        else
            TriggerClientEvent('esx:showNotification', source, '~y~Aucun report à annuler')
        end
    end)
end)

-- Handler pour créer un report
RegisterServerEvent('Lixzy:CreateReport')
AddEventHandler('Lixzy:CreateReport', function(reason)
    local source = source
    print("[ex_admin][DEBUG] Lixzy:CreateReport appelé", source, reason)
    
    local xPlayerSource = ESX.GetPlayerFromId(source)
    if not xPlayerSource then
        print("[ex_admin][ERROR] xPlayer introuvable pour source:", source)
        return
    end

    if not reason or reason == '' then
        TriggerClientEvent('esx:showNotification', source, '~r~Utilisation : /report votre message')
        return
    end

    local ids = GetPlayerIdentifiers(source) or {}
    local reporter_identifier = ''
    for _, id in ipairs(ids) do
        if type(id) == 'string' then
            if string.sub(id,1,6) == 'steam:' then 
                reporter_identifier = id 
                break 
            end
            if string.sub(id,1,8) == 'license:' and reporter_identifier == '' then 
                reporter_identifier = id 
            end
        end
    end

    -- Vérifier si le joueur a déjà un report en attente
    MySQL.Async.fetchAll('SELECT id FROM reports WHERE reporter_identifier = @ident LIMIT 1', {
        ['@ident'] = reporter_identifier
    }, function(existingReports)
        if existingReports and #existingReports > 0 then
            TriggerClientEvent('esx:showNotification', source, '~r~Vous avez déjà un report en cours !')
            return
        end

        if not reportcount then reportcount = {} end
        
        local isadded = false
        for k,v in pairs(reportcount) do
            if v.id == source then
                isadded = true
            end
        end
        
        if not isadded then
            table.insert(reportcount, { 
                id = source,
                gametimer = 0
            })
        end
        
        for k,v in pairs(reportcount) do
            if v.id == source then
                if v.gametimer + 120000 > GetGameTimer() and v.gametimer ~= 0 then
                    local myname = GetPlayerName(source) or tostring(source)
        TriggerClientEvent('esx:showAdvancedNotification', source, 'SUPPORT', '~b~'..myname..'', 'Vous devez patienter ~r~2 minute~s~ avant de faire de nouveau un ~r~report !', 'CHAR_BLOCKED', 0)
                    return
                else
                    v.gametimer = GetGameTimer()
                end
            end
        end

        local myname = GetPlayerName(source) or tostring(source)
        TriggerClientEvent('esx:showAdvancedNotification', source, 'REPORT', '~b~' .. myname .. '', 'Votre Report a bien été envoyé \n [ '.. reason .. ' ]', 'CHAR_CHAT_CALL', 0)

        if Config.webhook and Config.webhook.report and Config.webhook.report ~= "TON WEBHOOK ICI" and Config.webhook.report ~= "" then
            PerformHttpRequest(Config.webhook.report, function(err, text, headers) end, 'POST', json.encode({
                username = "REPORT", 
                content = "``REPORT``\n```ID : " .. source .. "\nNom : " .. (GetPlayerName(source) or tostring(source)) .. "\nMessage : " .. reason .. "```"
            }), { ['Content-Type'] = 'application/json' })
        end
        
        local reporter_name = GetPlayerName(source) or tostring(source)
        
        print("[ex_admin][DEBUG] Insertion report:", reporter_identifier, source, reporter_name, reason)
        
        MySQL.Async.execute('INSERT INTO reports (reporter_identifier, reporter_source, reporter_name, reason) VALUES (@ident, @src, @name, @reason)', {
            ['@ident'] = reporter_identifier, 
            ['@src'] = source, 
            ['@name'] = reporter_name, 
            ['@reason'] = reason
        }, function(affected)
            print("[ex_admin][DEBUG] Report inséré, affected rows:", affected)
            
            TriggerClientEvent('Lixzy:RefreshPlayerReport', source)
            
            MySQL.Async.fetchAll('SELECT id FROM reports WHERE reporter_identifier = @ident AND reason = @reason ORDER BY id DESC LIMIT 1', {
                ['@ident'] = reporter_identifier, 
                ['@reason'] = reason
            }, function(rows)
                local report_id = rows[1] and rows[1].id or 0
                print("[ex_admin][DEBUG] Report ID récupéré:", report_id)
                
                local xPlayers = ESX.GetPlayers()
                for i=1, #xPlayers, 1 do
                    local xP = ESX.GetPlayerFromId(xPlayers[i])
                    if xP then
                        local group = xP.getGroup and xP.getGroup() or 'user'
                        if group == "support" or group == "mod" or group == "admin" or group == "manager" or group == "owner" or group == "superadmin" then
                            TriggerClientEvent("Lixzy:RefreshReport", xP.source)
                            TriggerClientEvent('esx:showAdvancedNotification', xP.source, 'REPORT', '~b~Nouveau Report~s~', 'ID: ~r~' .. source .. '~s~\nJoueur: ~b~' .. reporter_name .. '\n~s~Message: ~y~' .. reason, 'CHAR_CHAT_CALL', 0)
                        end
                    end
                end
            end)
        end)
    end)
end)

RegisterServerEvent("Lixzy:SendLogs")
AddEventHandler("Lixzy:SendLogs", function(action)
    local xPlayer = ESX.GetPlayerFromId(source)
    if IsStaff(xPlayer) then
        PerformHttpRequest(Config.webhook.SendLogs, function(err, text, headers) end, 'POST', json.encode({username = "RevoPvP", content = "```\nNom : " .. (GetPlayerName(source) or tostring(source)) .. "\nAction : ".. action .." !```" }), { ['Content-Type'] = 'application/json' })
    else
        TriggerEvent("BanSql:ICheatServer", source, "CHEAT")
    end
end)

RegisterServerEvent("Lixzy:onStaffJoin")
AddEventHandler("Lixzy:onStaffJoin", function()
    local src = source
    local ok, err = pcall(function()
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then
            -- print debug supprimé
            return
        end
        -- print debug supprimé
        if not IsStaff(xPlayer) then
            TriggerEvent("BanSql:ICheatServer", src, "CHEAT")
            return
        end
        -- send webhook (non-blocking)
        if Config.webhook and Config.webhook.Staffmodeon and Config.webhook.Staffmodeon ~= "" then
            PerformHttpRequest(Config.webhook.Staffmodeon , function(err, text, headers) end, 'POST', json.encode({username = "RevoPvP", content = "``STAFF MODE ON``\n```\nNom : " .. (GetPlayerName(src) or tostring(src)) .. "\nAction : Active Staff Mode !```" }), { ['Content-Type'] = 'application/json' })
        else
            -- print debug supprimé
        end
        -- avoid duplicates
        local already = false
        for i=1, #staff do
            if staff[i] == src then already = true break end
        end
        if not already then
            table.insert(staff, src)
            -- print debug supprimé
        else
            -- print debug supprimé
        end
        TriggerClientEvent('esx:showAdvancedNotification', src, 'STAFF', '~g~ACTIF', '~b~'..(GetPlayerName(src) or tostring(src)).. '~s~ à ~g~activer~s~ son StaffMode ', 'CHAR_BUGSTARS', 8)
    end)
    if not ok then
        -- print debug supprimé
    end
end)

RegisterServerEvent("Lixzy:onStaffLeave")
AddEventHandler("Lixzy:onStaffLeave", function()
    local src = source
    local ok, err = pcall(function()
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then
            -- print debug supprimé
            return
        end
        -- print debug supprimé
        if not IsStaff(xPlayer) then
            -- print debug supprimé
            TriggerEvent("BanSql:ICheatServer", src, "CHEAT")
            return
        end
        if Config.webhook and Config.webhook.Staffmodeoff and Config.webhook.Staffmodeoff ~= "" then
            PerformHttpRequest(Config.webhook.Staffmodeoff , function(err, text, headers) end, 'POST', json.encode({username = "RevoPvP", content = "``STAFF MODE OFF``\n```\nNom : " .. (GetPlayerName(src) or tostring(src)) .. "\nAction : Désactive Staff Mode !```" }), { ['Content-Type'] = 'application/json' })
        else
            -- print debug supprimé
        end
        -- remove from staff array by value
        for i=1, #staff do
            if staff[i] == src then
                table.remove(staff, i)
                -- print debug supprimé
                break
            end
        end
        TriggerClientEvent('esx:showAdvancedNotification', src, 'STAFF', '~r~DESACTIVER', '~b~'..(GetPlayerName(src) or tostring(src)).. '~s~ à ~r~désactiver~s~ son StaffMode ', 'CHAR_BUGSTARS', 8)
    end)
    if not ok then
        -- print debug supprimé
    end
end)

RegisterServerEvent("Lixzy:Jail")
AddEventHandler("Lixzy:Jail", function(id, time)
    local xPlayer = ESX.GetPlayerFromId(source)
    if IsStaff(xPlayer) then
        if Config.webhook and Config.webhook.Jail and Config.webhook.Jail ~= "" then
            PerformHttpRequest(Config.webhook.Jail, function(err, text, headers) end, 'POST', json.encode({username = "JAIL", content = "`` JAIL ``\n````\nNom : " .. (GetPlayerName(source) or tostring(source)) .. "\nNom de la personne jail : " .. (GetPlayerName(id) or tostring(id)) .. "\nTemps : " .. time .. " minutes ```" }), { ['Content-Type'] = 'application/json' })
        else
            -- print debug supprimé
        end
        TriggerEvent('esx_jailer:sendToJail', tonumber(id), tonumber(time * 60))
    else
        TriggerEvent("BanSql:ICheatServer", source, "CHEAT")
    end
end)

RegisterServerEvent("Lixzy:UnJail")
AddEventHandler("Lixzy:UnJail", function(id, time)
    local xPlayer = ESX.GetPlayerFromId(source)
    if IsAdminOrHigher(xPlayer) then
        PerformHttpRequest(Config.webhook.UnJail, function(err, text, headers) end, 'POST', json.encode({username = "UNJAIL", content = "`` UNJAIL ``\n```\nNom : " .. (GetPlayerName(source) or tostring(source)) .. "\nNom de la personne unjail : " .. (GetPlayerName(id) or tostring(id)) .. "```" }), { ['Content-Type'] = 'application/json' })
        TriggerEvent("esx_jailer:unjailQuest", id)
    else
        TriggerEvent("BanSql:ICheatServer", source, "CHEAT")
    end
end)


RegisterServerEvent("Lixzy:teleport")
AddEventHandler("Lixzy:teleport", function(id)
    local xPlayer = ESX.GetPlayerFromId(source)
    if IsStaff(xPlayer) then
        -- CORRECTION: Vérifier que le joueur cible existe
        local targetName = GetPlayerName(id)
        if not targetName then
            TriggerClientEvent('esx:showNotification', source, '~r~Le joueur est déconnecté')
            return
        end
        
        PerformHttpRequest(Config.webhook.teleport, function(err, text, headers) end, 'POST', json.encode({username = "RevoPvP", content = "``TELEPORT``\n```\nNom : " .. (GetPlayerName(source) or tostring(source)) .. "\nAction : Téléporter aux joueurs ! " .. "\n\n" .. "Nom de la personne : " .. targetName .. "```" }), { ['Content-Type'] = 'application/json' })
        TriggerClientEvent("Lixzy:teleport", source, GetEntityCoords(GetPlayerPed(id)))
    else
        TriggerEvent("BanSql:ICheatServer", source, "CHEAT")
    end
end)

RegisterServerEvent("Lixzy:teleportTo")
AddEventHandler("Lixzy:teleportTo", function(id)
    local xPlayer = ESX.GetPlayerFromId(source)
    if IsStaff(xPlayer) then
        -- CORRECTION: Vérifier que le joueur cible existe
        local targetName = GetPlayerName(id)
        if not targetName then
            TriggerClientEvent('esx:showNotification', source, '~r~Le joueur est déconnecté')
            return
        end
        
        PerformHttpRequest(Config.webhook.teleportTo, function(err, text, headers) end, 'POST', json.encode({username = "RevoPvP", content = "``TELEPORT SUR SOI MEME``\n```\nNom : " .. (GetPlayerName(source) or tostring(source)) .. "\nAction : Téléportez les joueurs à RevoPvP ! " .. "\n\n" .. "Nom de la personne : " .. targetName .. "```" }), { ['Content-Type'] = 'application/json' })
        TriggerClientEvent("Lixzy:teleport", id, GetEntityCoords(GetPlayerPed(source)))
    else
        TriggerEvent("BanSql:ICheatServer", source, "CHEAT")
    end
end)

RegisterServerEvent("Lixzy:Revive")
AddEventHandler("Lixzy:Revive", function(id)
    local xPlayer = ESX.GetPlayerFromId(source)
    if IsStaff(xPlayer) then
        -- CORRECTION: Vérifier que le joueur cible existe
        local targetName = GetPlayerName(id)
        if not targetName then
            TriggerClientEvent('esx:showNotification', source, '~r~Le joueur est déconnecté')
            return
        end
        
        PerformHttpRequest(Config.webhook.revive, function(err, text, headers) end, 'POST', json.encode({username = "RevoPvP", content = "``REVIVE``\n```\nNom : " .. (GetPlayerName(source) or tostring(source)) .. "\nAction : Revive ! " .. "\n\n" .. "Nom de la personne revive : " .. targetName .. "```" }), { ['Content-Type'] = 'application/json' })
        TriggerClientEvent("esx_ambulancejob:revive", id)
    else
        TriggerEvent("BanSql:ICheatServer", source, "CHEAT")
    end
end)


RegisterServerEvent("Lixzy:teleportcoords")
AddEventHandler("Lixzy:teleportcoords", function(id, coords)
    local xPlayer = ESX.GetPlayerFromId(source)
    if IsStaff(xPlayer) then
        -- CORRECTION: Vérifier que le joueur cible existe
        local targetName = GetPlayerName(id)
        if not targetName then
            TriggerClientEvent('esx:showNotification', source, '~r~Le joueur est déconnecté')
            return
        end
        
        PerformHttpRequest(Config.webhook.teleportcoords, function(err, text, headers) end, 'POST', json.encode({username = "RevoPvP", content = "``TP GARAGE``\n```\nNom : " .. GetPlayerName(source) .. "\nAction : Tp sur garage ! " .. "\n\n" .. "Nom de la personne : " .. targetName .. "```" }), { ['Content-Type'] = 'application/json' })
        TriggerClientEvent("Lixzy:teleport", id, vector3(215.76, -810.12, 30.73))
    else
        TriggerEvent("BanSql:ICheatServer", source, "CHEAT")
    end
end)

RegisterServerEvent("Lixzy:teleporttoit")
AddEventHandler("Lixzy:teleporttoit", function(id, coords)
    local xPlayer = ESX.GetPlayerFromId(source)
    if IsStaff(xPlayer) then
        -- CORRECTION: Vérifier que le joueur cible existe
        local targetName = GetPlayerName(id)
        if not targetName then
            TriggerClientEvent('esx:showNotification', source, '~r~Le joueur est déconnecté')
            return
        end
        
        PerformHttpRequest(Config.webhook.teleporttoit, function(err, text, headers) end, 'POST', json.encode({username = "RevoPvP", content = "``TP TOIT``\n```\nNom : " .. GetPlayerName(source) .. "\nAction : Tp sur un toit ! " .. "\n\n" .. "Nom de la personne : " .. targetName .. "```" }), { ['Content-Type'] = 'application/json' })
        TriggerClientEvent("Lixzy:teleport", id, vector3(-75.59, -818.07, 326.17))
    else
        TriggerEvent("BanSql:ICheatServer", source, "CHEAT")
    end
end)


RegisterServerEvent("Lixzy:message")
AddEventHandler("Lixzy:message", function(target, message)
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = GetPlayerName(source)
    if IsStaff(xPlayer) then
        PerformHttpRequest(Config.webhook.message, function(err, text, headers) end, 'POST', json.encode({username = "RevoPvP", content = "``MESSAGE``\n```\nNom : " .. GetPlayerName(source) .. "\nAction : Message ! " .. "\n\n" .. "Nom de la personne : " .. GetPlayerName(target) .. "\n" .. "Message est : " .. message .. "```" }), { ['Content-Type'] = 'application/json' })
        TriggerClientEvent("esx:showNotification", source, ("~g~Message envoyé à %s"):format(GetPlayerName(target)))
        TriggerClientEvent('esx:showAdvancedNotification', target, 'Message du staff', '~r~'..name..' ~s~:', ''..message..'' , 'CHAR_SOCIAL_CLUB', 0)
    else
        TriggerEvent("BanSql:ICheatServer", source, "CHEAT")
    end
end)

RegisterServerEvent("Lixzy:annonce")
AddEventHandler("Lixzy:annonce", function( message)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayers	= ESX.GetPlayers()
    local name = GetPlayerName(source)
    if IsAdminOrHigher(xPlayer) then
        for i=1, #xPlayers, 1 do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'ANNONCE', '~b~'..name..' :', ''..message..'', 'CHAR_ARTHUR', 0)
        end
        PerformHttpRequest(Config.webhook.annonce, function(err, text, headers) end, 'POST', json.encode({username = "RevoPvP", content = "``ANNONCE``\n```\nNom : " .. GetPlayerName(source) .. "\nAction : Annonce ! " .. "\n\n" .. "Message : " ..message.. "```" }), { ['Content-Type'] = 'application/json' })

    else
        TriggerEvent("BanSql:ICheatServer", source, "CHEAT")
    end
end)

RegisterServerEvent("Lixzy:reviveall")
AddEventHandler("Lixzy:reviveall", function(message)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayers	= ESX.GetPlayers()
    if IsAdminOrHigher(xPlayer) then
        for i=1, #xPlayers, 1 do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            TriggerClientEvent('esx_ambulancejob:revive', xPlayers[i])
			TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'ANNONCE', '~b~'..xPlayers[i]..' ', '~r~Revive de tout le monde', 'CHAR_GANGAPP', 0)
        end
    else
        TriggerEvent("BanSql:ICheatServer", source, "CHEAT")
    end
end)

RegisterServerEvent("Lixzy:SavellPlayerAuto")
AddEventHandler("Lixzy:SavellPlayerAuto", function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = GetPlayerName(source)
    if IsAdminOrHigher(xPlayer) then
        PerformHttpRequest(Config.webhook.SavellPlayerAuto, function(err, text, headers) end, 'POST', json.encode({username = "RevoPvP", content = "``SAVE JOUEURS ``\n```\nNom : " .. GetPlayerName(source) .. "\nAction : save joueurs  ! " .. "```" }), { ['Content-Type'] = 'application/json' })
        if ESX.SavePlayers and type(ESX.SavePlayers) == 'function' then
            ESX.SavePlayers(cb)
            -- print debug supprimé
        else
            -- fallback: try to call xPlayer.save() for each player if available
            local players = ESX.GetPlayers()
            local count = 0
            for i=1, #players, 1 do
                local xp = ESX.GetPlayerFromId(players[i])
                if xp and type(xp.save) == 'function' then
                    pcall(function() xp.save() end)
                    count = count + 1
                end
            end
            -- print debug supprimé
            if cb then pcall(cb) end
        end
    else
        TriggerEvent("BanSql:ICheatServer", source, "CHEAT")
    end
end)

RegisterServerEvent("Lixzy:clearInv")
AddEventHandler("Lixzy:clearInv", function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayere = ESX.GetPlayerFromId(target)
    if IsAdminOrHigher(xPlayer) then
        for i = 1, #xPlayere.inventory, 1 do
            if xPlayere.inventory[i].count > 0 then
                xPlayere.setInventoryItem(xPlayere.inventory[i].name, 0)
            end
        end
        PerformHttpRequest(Config.webhook.clearInv, function(err, text, headers) end, 'POST', json.encode({username = "RevoPvP", content = "``CLEAR INVENTAIRE``\n```\nNom : " .. GetPlayerName(source) .. "\nAction : Clear inventaire ! " .. "\n\n" .. "Nom de la personne  : " .. GetPlayerName(target) .. "```" }), { ['Content-Type'] = 'application/json' })
        TriggerClientEvent("esx:showNotification", source, ("~g~Clear inventaire de %s effectuée"):format(GetPlayerName(target)))
    else
        TriggerEvent("BanSql:ICheatServer", source, "CHEAT")
    end
end)

RegisterServerEvent("Lixzy:clearLoadout")
AddEventHandler("Lixzy:clearLoadout", function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayere = ESX.GetPlayerFromId(target)
    if IsAdminOrHigher(xPlayer) then
        for i = #xPlayere.loadout, 1, -1 do
            xPlayere.removeWeapon(xPlayere.loadout[i].name)
        end
        PerformHttpRequest(Config.webhook.clearLoadout, function(err, text, headers) end, 'POST', json.encode({username = "RevoPvP", content = "``CLEAR ARME``\n```\nNom : " .. GetPlayerName(source) .. "\nAction : Clear arme ! " .. "\n\n" .. "Nom de la personne  : " .. GetPlayerName(target) .. "```" }), { ['Content-Type'] = 'application/json' })
        TriggerClientEvent("esx:showNotification", source, ("~g~Clear des armes de %s effectuée"):format(GetPlayerName(target)))
    else
        TriggerEvent("BanSql:ICheatServer", source, "CHEAT")
    end
end)


RegisterServerEvent("Lixzy:WipePlayer")
AddEventHandler("Lixzy:WipePlayer", function(target, id)
    local xPlayer = ESX.GetPlayerFromId(target)
    local steam = xPlayer.getIdentifier()
    if IsAdminOrHigher(xPlayer) then
        PerformHttpRequest(Config.webhook.WipePlayer, function(err, text, headers) end, 'POST', json.encode({username = "RevoPvP", content = "``WIPE``\n```\nNom : " .. GetPlayerName(source) .. "\nAction : Wipe  ! " .. "\n\n" .. "Nom de la personne  : " .. GetPlayerName(target) .. "```" }), { ['Content-Type'] = 'application/json' })
        DropPlayer(target, "Wipe en cours..")
        MySQL.Async.execute([[ 
            DELETE FROM billing WHERE identifier = @wipeID;
            DELETE FROM billing WHERE sender = @wipeID;
            DELETE FROM open_car WHERE identifier = @wipeID;
            DELETE FROM owned_vehicles WHERE owner = @wipeID;
            DELETE FROM user_accounts WHERE identifier = @wipeID;
            DELETE FROM user_accessories WHERE identifier = @wipeID;
            DELETE FROM phone_users_contacts WHERE identifier = @wipeID;
            DELETE FROM user_inventory WHERE identifier = @wipeID;
            DELETE FROM user_licenses WHERE owner = @wipeID;
            DELETE FROM user_tenue WHERE identifier = @wipeID;
             DELETE FROM users WHERE identifier = @wipeID;	]], {
            ['@wipeID'] = steam,
        }, function(rowsChanged)
            -- print debug supprimé
            TriggerClientEvent('esx:showNotification', id, "Joueur wipe")
        end)
        --DELETE FROM owned_properties WHERE owner = @wipeID;
        --DELETE FROM playerstattoos WHERE identifier = @wipeID;
        --DELETE FROM owned_boats WHERE owner = @wipeID;
    else
        TriggerEvent("BanSql:ICheatServer", source, "CHEAT")
    end
end)


RegisterServerEvent("Lixzy:kick")
AddEventHandler("Lixzy:kick", function(id, reason)
    local xPlayer = ESX.GetPlayerFromId(source)
    if IsStaff(xPlayer) then
        PerformHttpRequest(Config.webhook.kick, function(err, text, headers) end, 'POST', json.encode({username = "RevoPvP", content = "``KICK``\n```\nNom : " .. GetPlayerName(source) .. "\nAction : Kick Players ! " .. "\n\n" .. "Nom de la personne  : " .. GetPlayerName(id) .. "\n" .. "Reason : " .. reason .. "```" }), { ['Content-Type'] = 'application/json' })
        DropPlayer(id, reason)
    else
        TriggerEvent("BanSql:ICheatServer", source, "CHEAT")
    end
end)


RegisterServerEvent("Lixzy:ouvrirmenu1")
AddEventHandler("Lixzy:ouvrirmenu1", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    -- print debug supprimé
    if IsStaff(xPlayer) then
        TriggerClientEvent("Lixzy:menu1", source)
    else
        TriggerClientEvent('esx:showNotification', source, '~r~Vous n\'avez pas la permission pour ouvrir le menu')
    end
end)

RegisterServerEvent("Lixzy:ouvrirmenu2")
AddEventHandler("Lixzy:ouvrirmenu2", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    -- print debug supprimé
    if IsStaff(xPlayer) then
        TriggerClientEvent("Lixzy:menu2", source)
    else
        TriggerClientEvent('esx:showNotification', source, '~r~Vous n\'avez pas la permission pour ouvrir le menu')
    end
end)

RegisterServerEvent("Lixzy:ReportRegle")
AddEventHandler("Lixzy:ReportRegle", function(reportId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if IsStaff(xPlayer) then
        if not reportId or reportId == nil then
            print('[ex_admin][ERROR] ReportRegle: reportId est nil')
            TriggerClientEvent('esx:showNotification', source, '~r~Erreur: ID du report invalide')
            return
        end
        
        print('[ex_admin][DEBUG] ReportRegle: reportId=' .. tostring(reportId))
        
        MySQL.Async.fetchAll('SELECT reporter_source FROM reports WHERE id = @id', {['@id'] = reportId}, function(rows)
            if rows[1] and rows[1].reporter_source then
                local reporterSrc = rows[1].reporter_source
                if reporterSrc and reporterSrc > 0 then
                    local reporterName = GetPlayerName(reporterSrc)
                    if reporterName then
                        local staffName = GetPlayerName(source) or "Staff"
                        TriggerClientEvent('esx:showAdvancedNotification', reporterSrc, 'SUPPORT', '~b~' ..staffName.. '', '~g~Votre report a été réglée !', 'CHAR_CHAT_CALL', 0)
                    end
                end
            end

            MySQL.Async.execute('DELETE FROM reports WHERE id = @id', {['@id'] = reportId}, function(affected)
                print('[ex_admin][DEBUG] Report supprimé, affected rows: ' .. tostring(affected))
                local xPlayers = ESX.GetPlayers()
                for i = 1, #xPlayers, 1 do
                    local xP = ESX.GetPlayerFromId(xPlayers[i])
                    if xP and IsStaff(xP) then
                        TriggerClientEvent("Lixzy:RefreshReport", xP.source)
                    end
                end
            end)
        end)
    else
        TriggerEvent("BanSql:ICheatServer", source, "CHEAT")
    end
end)

ESX.RegisterServerCallback('Lixzy:retrievePlayers', function(playerId, cb)
    local players = {}
    local xPlayers = ESX.GetPlayers()

    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        table.insert(players, {
            id = "0",
            group = xPlayer.getGroup(),
            source = xPlayer.source,
            jobs = xPlayer.getJob().name,
            name = xPlayer.getName()
        })
    end

    cb(players)
end)

ESX.RegisterServerCallback('Lixzy:retrieveStaffPlayers', function(playerId, cb)
    local playersadmin = {}
    local xPlayers = ESX.GetPlayers()

    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if IsStaff(xPlayer) then
            -- if the player only has a staff license (group still 'user'), override group with the grade from Config.Licenses for display purposes
            local displayGroup = xPlayer.getGroup()
            local usedLicence = nil
            if not IsStaff(displayGroup) then
                local ids = GetPlayerIdentifiers(xPlayer.source) or {}
                for _, id in ipairs(ids) do
                    if type(id) == 'string' and string.sub(id,1,8) == 'license:' then
                        for grade, list in pairs(Config.Licenses or {}) do
                            for i=1, #list do
                                if list[i] == id then
                                    displayGroup = grade
                                    usedLicence = id
                                    break
                                end
                            end
                            if displayGroup ~= xPlayer.getGroup() then break end
                        end
                    end
                    if displayGroup ~= xPlayer.getGroup() then break end
                end
            end
            table.insert(playersadmin, {
                id = "0",
                group = displayGroup,
                source = xPlayer.source,
                jobs = xPlayer.getJob().name,
                name = xPlayer.getName()
            })
        end
    end

    cb(playersadmin)
end)

ESX.RegisterServerCallback('Lixzy:retrieveReport', function(playerId, cb)
    MySQL.Async.fetchAll('SELECT id, reporter_source as id_source, reporter_name as name, reason, created_at FROM reports ORDER BY id DESC', {}, function(rows)
        cb(rows)
    end)
end)

ESX.RegisterServerCallback('Lixzy:retrieveBans', function(playerId, cb)
    MySQL.Async.fetchAll('SELECT id, identifier, license, discord, ip, reason, staff, expires, created_at FROM bans ORDER BY id DESC LIMIT 200', {}, function(rows)
        for i, ban in ipairs(rows) do
            if ban.expires and tonumber(ban.expires) and tonumber(ban.expires) ~= 0 then
                ban.expires_formatted = os.date('%d/%m/%Y à %H:%M', tonumber(ban.expires))
            else
                ban.expires_formatted = 'PERMANENT'
            end

            if ban.created_at then

                ban.created_formatted = tostring(ban.created_at)
            end
        end
        
        cb(rows)
    end)
end)

-- Ensure bans table exists
CreateThread(function()
    MySQL.Async.execute([[ 
        CREATE TABLE IF NOT EXISTS bans (
            id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
            identifier VARCHAR(100),
            license VARCHAR(100),
            discord VARCHAR(100),
            ip VARCHAR(100),
            reason TEXT,
            staff VARCHAR(64),
            expires BIGINT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], {}, function(affected)
        -- print debug supprimé
    end)
end)

-- welcome message merged into main playerConnecting handler (removed duplicate)

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- jail command
TriggerEvent('es:addGroupCommand', 'jail', 'user', function(source, args, user)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not IsStaff(xPlayer) then
		TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
		return
	end
	if args[1] and GetPlayerName(args[1]) ~= nil and tonumber(args[2]) then
		TriggerEvent('esx_jailer:sendToJail', tonumber(args[1]), tonumber(args[2] * 60))
        if Config.webhook and Config.webhook.Jail and Config.webhook.Jail ~= '' then
            PerformHttpRequest(Config.webhook.Jail, function(err, text, headers) end, 'POST', json.encode({username = "JAIL", content = "`` JAIL ``\n````\nNom : " .. GetPlayerName(source) .. "\nNom de la personne jail : " .. GetPlayerName(args[1]) .. "\nTemps : " .. tonumber(args[2]) .. " minutes ```" }), { ['Content-Type'] = 'application/json' })
        else
            print('[ex_admin] Webhook Jail non configuré, saut de l envoi')
        end

	else
		TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'ID de joueur invalide ou temps de prison !' } } )
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, {help = "Mettre un joueur en prison", params = {{name = "id", help = "id de la personne"}, {name = "time", help = "temps de prison en minutes"}}})


-- unjail command
TriggerEvent('es:addGroupCommand', 'unjail', 'user', function(source, args, user)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not IsAdminOrHigher(xPlayer) then
		TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
		return
	end
	if args[1] then
		if GetPlayerName(args[1]) ~= nil then
			TriggerEvent('esx_jailer:unjailQuest', tonumber(args[1]))
            PerformHttpRequest(Config.webhook.UnJail, function(err, text, headers) end, 'POST', json.encode({username = "UNJAIL", content = "`` UNJAIL ``\n```\nNom : " .. GetPlayerName(source) .. "\nNom de la personne unjail : " .. GetPlayerName(args[1]) .. "```" }), { ['Content-Type'] = 'application/json' })
		else
			TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'ID de joueur non valide !' } } )
		end
	else
		TriggerEvent('esx_jailer:unjailQuest', source)
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, {help = "Sortir les gens de prison", params = {{name = "id", help = "id de la personne"}}})

RegisterServerEvent('esx_jailer:sendToJail')
AddEventHandler('esx_jailer:sendToJail', function(target, jailTime)
	local identifier = GetPlayerIdentifiers(target)[1]

	MySQL.Async.fetchAll('SELECT * FROM jail WHERE identifier=@id', {['@id'] = identifier}, function(result)
		if result[1] ~= nil then
			MySQL.Async.execute("UPDATE jail SET jail_time=@jt WHERE identifier=@id", {['@id'] = identifier, ['@jt'] = jailTime})
		else
			MySQL.Async.execute("INSERT INTO jail (identifier,jail_time) VALUES (@identifier,@jail_time)", {['@identifier'] = identifier, ['@jail_time'] = jailTime})
		end
	end)
	
	TriggerClientEvent('esx:showAdvancedNotification', target, 'PRISON', '~r~'..GetPlayerName(target)..'', 'est maintenant en ~b~prison ~s~pour ~n~[ ~u~'..ESX.Round(jailTime / 60)..' ~s~] minutes', 'CHAR_GANGAPP', 0)

	TriggerClientEvent('esx_policejob:unrestrain', target)
	TriggerClientEvent('esx_jailer:jail', target, jailTime)
end)

RegisterServerEvent('esx_jailer:checkJail')
AddEventHandler('esx_jailer:checkJail', function()
	local player = source 
	local identifier = GetPlayerIdentifiers(player)[1] 
	MySQL.Async.fetchAll('SELECT * FROM jail WHERE identifier=@id', {['@id'] = identifier}, function(result)
		if result[1] ~= nil then

			TriggerClientEvent('esx_jailer:jail', player, tonumber(result[1].jail_time))
		end
	end)
end)

RegisterServerEvent('esx_jailer:unjailQuest')
AddEventHandler('esx_jailer:unjailQuest', function(source)
	if source ~= nil then
		unjail(source)
	end
end)

RegisterServerEvent('esx_jailer:unjailTime')
AddEventHandler('esx_jailer:unjailTime', function()
	unjail(source)
end)

RegisterServerEvent('esx_jailer:updateRemaining')
AddEventHandler('esx_jailer:updateRemaining', function(jailTime)
	local identifier = GetPlayerIdentifiers(source)[1]
	MySQL.Async.fetchAll('SELECT * FROM jail WHERE identifier=@id', {['@id'] = identifier}, function(result)
		if result[1] ~= nil then
			MySQL.Async.execute("UPDATE jail SET jail_time=@jt WHERE identifier=@id", {['@id'] = identifier, ['@jt'] = jailTime})
		end
	end)
end)

function unjail(target)
	local identifier = GetPlayerIdentifiers(target)[1]
	MySQL.Async.fetchAll('SELECT * FROM jail WHERE identifier=@id', {['@id'] = identifier}, function(result)
		if result[1] ~= nil then
			MySQL.Async.execute('DELETE from jail WHERE identifier = @id', {['@id'] = identifier})
		end
	end)

    TriggerClientEvent('esx:showAdvancedNotification', target, 'PRISON', '~u~'..GetPlayerName(target)..'', ' est libéré de prison!', 'CHAR_GANGAPP', 0)

	TriggerClientEvent('esx_jailer:unjail', target)
end


-- Ban player via server event (inserts into `bans` table)
RegisterServerEvent('Lixzy:BanPlayer')
AddEventHandler('Lixzy:BanPlayer', function(targetId, hours, reason)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not IsStaff(xPlayer) then
        TriggerEvent("BanSql:ICheatServer", src, "CHEAT")
        return
    end
    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        TriggerClientEvent('esx:showNotification', src, '~r~Joueur introuvable')
        return
    end
    local ids = GetPlayerIdentifiers(targetId)
    local identifier, license, discord, ip = '', '', '', ''
    for _, id in ipairs(ids) do
        if string.sub(id,1,8) == 'license:' then license = id end
        if string.sub(id,1,6) == 'steam:' then identifier = id end
        if string.sub(id,1,4) == 'ip:' then ip = id end
        if string.sub(id,1,8) == 'discord:' then discord = id end
    end
    local expires = 0
    if tonumber(hours) and tonumber(hours) > 0 then expires = os.time() + tonumber(hours) * 3600 end
    MySQL.Async.execute('INSERT INTO bans (identifier, license, discord, ip, reason, staff, expires) VALUES (@identifier, @license, @discord, @ip, @reason, @staff, @expires)', {
        ['@identifier'] = identifier,
        ['@license'] = license,
        ['@discord'] = discord,
        ['@ip'] = ip,
        ['@reason'] = reason or 'Banni',
        ['@staff'] = GetPlayerName(src),
        ['@expires'] = expires
    }, function(rowsChanged)
        -- Attempt to find the inserted ban id (best-effort)
        MySQL.Async.fetchAll('SELECT id FROM bans WHERE identifier = @identifier AND reason = @reason ORDER BY id DESC LIMIT 1', {['@identifier'] = identifier, ['@reason'] = reason}, function(rows)
            local banId = rows[1] and rows[1].id or 0
            print(('^3[ex_admin] BanPlayer: target=%s ident=%s license=%s expires=%s banId=%s'):format(tostring(targetId), tostring(identifier), tostring(license), tostring(expires), tostring(banId)))
            -- notify staff who executed the ban
            TriggerClientEvent('esx:showNotification', src, ('~g~Ban appliqué (ID: %s)'):format(tostring(banId)))
            -- drop the target with a detailed message
            local expText = (expires == 0) and 'Permanent' or os.date('%c', expires)
            local kickMsg = ('Banni (ID:%s) | Raison: %s | Expire: %s'):format(tostring(banId), tostring(reason or 'Banni'), tostring(expText))
            DropPlayer(targetId, kickMsg)
            -- notify all staff clients to refresh ban list
            for i=1, #ESX.GetPlayers(), 1 do
                local xP = ESX.GetPlayerFromId(ESX.GetPlayers()[i])
                if xP and IsStaff(xP) then
                    TriggerClientEvent("Lixzy:RefreshBans", xP.source)
                end
            end
            -- send webhook with ban id
            if Config.webhook and Config.webhook.ban and Config.webhook.ban ~= "" then
                PerformHttpRequest(Config.webhook.ban, function() end, 'POST', json.encode({username = "RevoPvP", content = "``BAN``\n````\nNom staff: "..GetPlayerName(src).."\nCible: "..GetPlayerName(targetId).." ("..targetId..")\nBanID: "..tostring(banId).."\nRaison: "..reason.."\nExpires: "..tostring(expText).."```"}), { ['Content-Type'] = 'application/json' })
            end
        end)
    end)
end)

-- check bans on connecting players
AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    deferrals.defer()
    deferrals.update("Vérification...")
    
    local playerId = source
    
    -- Vérifier que le playerId est valide AVANT d'appeler GetPlayerIdentifiers
    if not playerId or playerId == 0 or playerId == nil then
        print(('^1[ex_admin] playerConnecting: source invalide pour %s - connexion autorisée par défaut'):format(tostring(playerName)))
        deferrals.done()
        return
    end
    
    -- Utiliser pcall pour éviter les crash si GetPlayerIdentifiers échoue
    local success, identifiers = pcall(GetPlayerIdentifiers, playerId)
    
    if not success or not identifiers or #identifiers == 0 then
        print(('^1[ex_admin] playerConnecting: erreur GetPlayerIdentifiers pour %s (source=%s) - connexion autorisée'):format(tostring(playerName), tostring(playerId)))
        deferrals.done()
        return
    end

    -- Récupérer la license
    local license = ''
    for _, id in pairs(identifiers) do
        if type(id) == 'string' and string.sub(id, 1, 8) == 'license:' then
            license = id
            break
        end
    end

    if license == '' then
        print(('^3[ex_admin] playerConnecting: aucune license pour %s (source=%s) - connexion autorisée'):format(tostring(playerName), tostring(playerId)))
        deferrals.done()
        return
    end

    print(('^2[ex_admin] playerConnecting: vérification ban pour %s (license=%s)'):format(tostring(playerName), license:sub(1, 20)..'...'))

    -- Vérifier les bans dans la base de données
    MySQL.Async.fetchAll('SELECT id, reason, staff, expires FROM bans WHERE license = @license AND (expires = 0 OR expires > @now) LIMIT 1', {
        ['@license'] = license,
        ['@now'] = os.time()
    }, function(rows)
        if rows and #rows > 0 then
            local ban = rows[1]
            local expText = (ban.expires == 0) and 'PERMANENT' or os.date('%d/%m/%Y à %H:%M', ban.expires)
            
            local message = string.format([[


🚫 ════════════════════════════════════════════════════════════ 🚫

                            VOUS ÊTES BANNI

🚫 ════════════════════════════════════════════════════════════ 🚫


    👤 Joueur      : %s
    📝 Raison      : %s
    👮 Staff       : %s
    ⏰ Expire      : %s
    🆔 Ban ID      : #%s


────────────────────────────────────────────────────────────────

    💬 Pour contester : discord.gg/votreserveur

────────────────────────────────────────────────────────────────


]], 
    playerName,
    ban.reason or 'Aucune raison',
    ban.staff or 'Système',
    expText,
    tostring(ban.id)
)
            
            print(('^1[ex_admin] CONNEXION REFUSÉE - %s banni (ID:%s, Raison:%s)'):format(
                tostring(playerName),
                tostring(ban.id),
                tostring(ban.reason)
            ))
            
            deferrals.done(message)
        else
            print(('^2[ex_admin] %s autorisé'):format(tostring(playerName)))
            deferrals.done()
        end
    end)
end)

-- Unban player via server event / command
RegisterServerEvent('Lixzy:UnbanPlayer')
AddEventHandler('Lixzy:UnbanPlayer', function(target)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    -- allow console (src == 0) or admins
    if src ~= 0 and not IsAdminOrHigher(xPlayer) then
        TriggerEvent("BanSql:ICheatServer", src, "CHEAT")
        return
    end

    local targetStr = tostring(target or "")

    -- if numeric, try to treat as player server id or ban id
    if tonumber(targetStr) then
        local tnum = tonumber(targetStr)
        local xTarget = ESX.GetPlayerFromId(tnum)
        if xTarget then
            -- online player: remove by identifier/license
            local ids = GetPlayerIdentifiers(tnum)
            local ident, lic = '', ''
            for _, id in ipairs(ids) do
                if string.sub(id,1,6) == 'steam:' then ident = id end
                if string.sub(id,1,8) == 'license:' then lic = id end
            end
            MySQL.Async.execute('DELETE FROM bans WHERE identifier = @ident OR license = @lic', {['@ident'] = ident, ['@lic'] = lic}, function(rows)
                if rows and rows > 0 then
                    TriggerClientEvent('esx:showNotification', src, '~g~Unban effectué.')
                    if Config.webhook and Config.webhook.ban and Config.webhook.ban ~= '' then
                        PerformHttpRequest(Config.webhook.ban, function() end, 'POST', json.encode({username = "RevoPvP", content = "``UNBAN``\n```\nStaff: "..GetPlayerName(src).."\nCible: "..GetPlayerName(tnum).." ("..tnum..")\n```"}), { ['Content-Type'] = 'application/json' })
                    end
                else
                    TriggerClientEvent('esx:showNotification', src, '~y~Aucun ban trouvé pour ce joueur.')
                end
            end)
            return
        else
            -- not online: try delete by ban id if exists
            MySQL.Async.execute('DELETE FROM bans WHERE id = @id', {['@id'] = tnum}, function(rows)
                if rows and rows > 0 then
                    TriggerClientEvent('esx:showNotification', src, '~g~Unban effectué (par id).')
                    for i=1, #ESX.GetPlayers(), 1 do
                        local xP = ESX.GetPlayerFromId(ESX.GetPlayers()[i])
                        if xP and IsStaff(xP) then
                            TriggerClientEvent("Lixzy:RefreshBans", xP.source)
                        end
                    end
                else
                    TriggerClientEvent('esx:showNotification', src, '~y~Aucun ban trouvé avec cet id.')
                end
            end)
            return
        end
    end

    -- otherwise try by identifier or license (exact match)
    MySQL.Async.execute('DELETE FROM bans WHERE identifier = @ident OR license = @ident', {['@ident'] = targetStr}, function(rows)
        if rows and rows > 0 then
            TriggerClientEvent('esx:showNotification', src, '~g~Unban effectué.')
            -- notify staff clients to refresh ban list
            for i=1, #ESX.GetPlayers(), 1 do
                local xP = ESX.GetPlayerFromId(ESX.GetPlayers()[i])
                if xP and IsStaff(xP) then
                    TriggerClientEvent("Lixzy:RefreshBans", xP.source)
                end
            end
            if Config.webhook and Config.webhook.ban and Config.webhook.ban ~= '' then
                PerformHttpRequest(Config.webhook.ban, function() end, 'POST', json.encode({username = "RevoPvP", content = "``UNBAN``\n```\nStaff: "..(src == 0 and 'Console' or GetPlayerName(src)).."\nCible: "..targetStr.."\n```"}), { ['Content-Type'] = 'application/json' })
            end
        else
            TriggerClientEvent('esx:showNotification', src, '~y~Aucun ban trouvé pour: ' .. targetStr)
        end
    end)
end)

-- admin command to unban: /unban <playerId|banId|license|identifier>
TriggerEvent('es:addGroupCommand', 'unban', 'user', function(source, args, user)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not IsAdminOrHigher(xPlayer) then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
        return
    end
    if not args[1] then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Usage: /unban <playerId|banId|license|identifier>' } })
        return
    end
    TriggerEvent('Lixzy:UnbanPlayer', args[1])
end, function(source, args, user)
    TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, {help = "Débannir un joueur", params = {{name = "id", help = "playerId|banId|license|identifier"}}})

-- duplicated ban-check handler removed (logic consolidated in main handler below)

-- Fallback: allow client to ask server to re-check bans after fully loaded (works when playerConnecting had nil source)
RegisterServerEvent('Lixzy:CheckBanOnLoaded')
AddEventHandler('Lixzy:CheckBanOnLoaded', function()
    local src = source
    if not src or src == 0 then
        print(('^1[ex_admin] CheckBanOnLoaded called with invalid source=%s'):format(tostring(src)))
        return
    end
    local ids = GetPlayerIdentifiers(src) or {}
    local identifier, license, discord, ip = '', '', '', ''
    for _, id in pairs(ids) do
        if type(id) == 'string' then
            if string.sub(id,1,8) == 'license:' then license = id end
            if string.sub(id,1,6) == 'steam:' then identifier = id end
            if string.sub(id,1,8) == 'discord:' then discord = id end
            if string.sub(id,1,3) == 'ip:' then ip = id end
        end
    end
    MySQL.Async.fetchAll('SELECT id, reason, staff, expires FROM bans WHERE (identifier = @identifier OR license = @license OR discord = @discord OR ip = @ip) AND (expires = 0 OR expires > @now) LIMIT 1', {['@identifier']=identifier, ['@license']=license, ['@discord']=discord, ['@ip']=ip, ['@now']=os.time()}, function(rows)
        if rows and #rows > 0 then
            local ban = rows[1]
            local expText = (ban.expires == 0) and 'Permanent' or os.date('%c', ban.expires)
            print(('^1[ex_admin] CheckBanOnLoaded: dropping source=%s banId=%s reason=%s'):format(tostring(src), tostring(ban.id), tostring(ban.reason)))
            DropPlayer(src, ('Vous êtes banni (ID:%s). Raison: %s | Expire: %s'):format(tostring(ban.id), tostring(ban.reason or 'Interdit'), tostring(expText)))
        end
    end)
end)

CreateThread(function()
    Citizen.Wait(1250)
    local art = [[
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:'##::::::::'####::'##::::'##::'########::'##::'##:::::::::::::::::::
: ##::::::::. ##::: ##:::: ##::..... ##::: ##:: ##:::::::::::::::::::
: ##::::::::: ##:::  ##:: ##:::::::: ##:::: ##::##:::::::::::::::::::
: ##::::::::: ##::::. ###:::::::::: ##:::::  ####:::::::::::::::::::::
: ##::::::::: ##:::: ##:: ##:::::: ##:::::::: ##:::::::::::::::::::::
: ##::::::::: ##::: ##:::: ##:::: ##::::::::: ##:::::::::::::::::::::
: ########::'####:: ##:::: ##::: ########:::: ##:::::::::::::::::::::
:........:::....:::..:::::..::::........:::::..::::::::::::::::::::::

   
                                                              ..---..._
                                                        ..--\"\"         \"-.
                                                   ..-\"\"\"                 \".
                                               ..-\"\"                        \"
                                            .-\"
                                         .-\"      ... -_
                                     .=\"   _..-\" F   .-\"-.....___-..
                                     \"L_ _-'    .\"  j\"  .-\":   /\"-._ \"-
                                        \"      :  .\"  j\"  :   :    |\"\" \".
                                  ......---------\"\"\"\"\"\"\"\"\"\"\"-:_     |   |
                        ...---\"\"\"\"                             -.   f   | \"
                ...---\"\"       . ..----\"\"\"\"\"\"\"\"..                \".-... f  \".
         ..---\"\"\"       ..---\"\"\"\"\"\"\"\"-..--\"\"\"\"\"\"\"\"\"^^::            |. \"-.    .
     .--\"           .mm::::::::::::::::::::::::::...  \"\"L           |x   \".
   -\"             mm;;;;;;;;;;XXXXXXXXXXXXX:::::::::::.. |           |x.   -
 xF        -._ .mF;;;;;;XXXXXXXXXXXXXXXXXXXXXXXXXX:::::::|            |X:.  \"
j         |   j;;;;;XXX#############################::::::|            XX::::
|          |.#;::XXX##################################::::|            |XX:::
|          j#::XXX#######################################::             XXX::
|         .#:XXX###########################################             |XX::
|         #XXX##############################XX############Fl             XXX:
|        .XXX###################XX#######X##XXX###########Fl             lXX:
 |       #XX##################XXX######XXXXXXX###########F j             lXXX
 |       #X#########X#X#####XXX#######XXXXXX#######XXX##F  jl            XXXX
 |       #X#######XX#\"  V###XX#' ####XXXXXX##F\"T##XXXXXX.  V   /  .    .#XXXX
  |       #########\"     V#XX#'  \"####XXXX##.---.##XXXXXX.    /  /  / .##XXXX
  |       \"######X' .--\"\" \"V##L   #####XXX#\"      \"###XXXX. .\"  /  / .###XXXX
  |         #####X \"   .m###m##L   ####XX#      m###m\"###XX#   /  / .#####XXX
   |         \"###X   .mF\"\"   \"y     #####     mX\"   \"Y#\"^####X   / .######XXX
   |           \"T#   #\"        #     ####    X\"       \"F\"\"###XX\"###########XX
   |             L  d\"     ^4dXX^0  xm   \"^##L mx     ^4dXX^0  YL-\"##XX\"S\"\"##########
    |            xL J     ^4Xd%^0    T      \"\"  T    ^4XdX ^0   L. \"##XS.f |#########
    |             BL      ^4X## X^0                  ^4X## X^0      T#SS\"  |#########
    |              #L     ^4X%##X^0                  ^4X%##X|^0     j#SSS /##########
     |              #L  ._ ^4TXXX-\"^0           \"-._  ^4XXXF.-^0    ###SS###########
     |              ##   \"\"\"\"\"                  \"\"\"\"\"\"      ##DS.###########
     |              TF                                      ##BBS.T#########F
      |             #L           ---                        ###BBS.T########'
      |            '##            \"\"                     jL|###BSSS.T#######
       |          '####             ______              .:#|##WWBBBSS.T####F
      J L        '######.            ___/            _c::#|###WWWBSSS|####
     J ;;       '########m            _/            c:::'#|###WWWBBSS.T##\"
    J ;;;L      :########.:m.          _          _cf:::'.L|####WWWWSSS|#\"
  .J ;;;;B      ########B....:m..             _,c%%%:::'...L####WWWBBSSj
 x  ;;;;dB      #######BB.......##m...___..cc%%%%%::::'....|#####WWBBDS.|
\" ;;;;;ABB#     #######BB........##j%%%%%%%%%%%%%%:::'..... #####WWWWDDS|
.;;;;;dBBB#     #######BB.........%%%%%%%%%%%%%%%:::'...   j####WWWWWBDF
;;;;;BBB####    ######BBB.........%%%%%%%%%%%%%%:::'..     #####WWWWWWS
;;;;dBBB####    ######BBB..........^%%%%%%%%%%:::\"         #####WWWWWWB
;;;:BBB######   X#####BBB\"...........\"^YYYYY::\"            #####WWWWWWW
;;.BB#########  X######BBB........:''                      #####WWWWWWW
;;BB##########L X######BBB.......mmmm..                 ..x#####WWWWWWB.
;dBB########### X#######BB.....        \"-._           x\"\"  #####WWWWWWBL
;BBB###########L X######BB...              \"-              ######WWWWBBBL
BBB#############. ######BBB.                                #####WWWWBBBB
BBB############## X#####BBB                                 #####WWWWWBBB
BBB############### T#####BB                                  #####WWWBBB     :
BB################# T###BBP                                   #####WWBB\"    .#
BB##################..W##P                                      ###BBB\"    .##
BB###################..l                                         \"WW\"      ###
BB####################j ___                                        \" l    j###
BBB##################J_-   \"\"\"-..             ':::'   .-\"\"\"\"\"\"\"\"\"\"-.  l  .####
BBB######B##########^1J########^0    \"-.           ::'  -\" ..^1mmm####mm..^0\"-.< #####
NiT34ByTe  BBB#####^1J############^0    \"-_        :|  \" .^1###############mm^0LlR####
BBBBBBBBBBBBBBB###^1/         #######^0    -.     .:| \".^1#####F^^^P^^\"\"\"^^^Y#^0lT^0####
BBBBBBBBBBBBBBBBB^1j|####mm^0        ^1######xx^0-...:::|\"^1 ###f      .....      \"^0#T###
BBBBBBBBBBBBBBBBj^1j##########mm..^0           \":::.\"^1j##F  .mm#########mmm.. Yj^0###
BBBBBBBBBBBBBBBB|^1^WWWSRR############mmmmm xx \"\"\"mjF.mm####################j^0###
BBBBBBBBBBBBBBBB|                      ^1######mmmmmm#######################j^0###
BBBBBBBBBBBBBBBBY^1#m...   ..mmm##########PPPPP#####m..                    lj^0###
BBBBBBBBBBBBBBBBB^12##############^^\"\"^0     ^1..umF^^^Tx ^##mmmm........mmmmmmlj^0###
BBBBBBBBBBBBBBBBBJ^1T######^^^\"\"^0     ^1.mm##PPPF\"....\"m.  \"^^###############lj^0####
BBBBBBBBBBBBBBBBB##^L         ^1.mmm###PPP^0............\"^1m..    \"\"\"\"^^^^^\"\" lj^0####
BBBBBBBBBBBBBBBB#####Y^1#mmx#########P^0..................\"^1^:muuuummmmmm###^^0.#####
BBBBBBBBBBBBBBBB#####::^1Y##mPPPPF^\"^0.......|.............. \"\"^1^^######^^^0\"...#####
BBBBBBBBBBBBBB########..................F............           ........#####
BBBBBBBBBBBBB#########.................|..........          :       ....l#####
BBBBBBBBBBBB###########...............F.........                     ..######
BBBBBBBBBBB#############.............|........                :         dA####
BBBBBBBBBB##############.....................                           kM####
BBBBBBBBB################..................                             k#####
BBBBBBB##################................                               k#####
BBBBB#####################.............                                 t#####
BB########################............                                  \"E####
B########################F............                           .       \"####
#########################............'      |                    ..       \"L##
########################F............                           ...        \"L#
#######################F............'                           .....       \"#
######################F.............                           .......       \"
#####################$..............                         .........
#####################^1lmmm^0.............                      ...........   ..^1m#^0
####################^1j########mmmm^0.............            ......^1mmmmmm########^0
###################^1j###::::;:::::########mmmmmmm##############################^0
##################^1j:::::::;:::::::;;::##############################^^^\"\"\"\"^0
##################^1.mm:::mmm######mmmm:::' ^^^^^^\"\"#######^^\"\"\"\"^0
#################F...^1^m::;::################mmm  .mm\"\"\"^0
#################.......^1m;::::::::::::#########^\"^0
################F.........^1###mmm::::;' .##^\"\"\"^0
 ##############F...........:^1#######m.m#\"^0
   ############..............':^1####^0
     #########F............mm^\"\"
       #######..........m^\"\"
          ####.......%^\"
             #.....x\"
             |.x\"\"
            .-\"
          .-
        .-
      .-
     -
   -\"
 -\"
\"
                                                                             x
                                                                           xx
                                                                         xx
                                                                     xxx\"
                                                                 xxx\"
                                                           .xxxx\"
                                                   ___xxx\"\"
                                             .xxxx\"\"....F
                \"\"\"\"mmxxxxx          ___xxx^^^..........'
                   .xx^^^^YYYY###xxx^^.................|
                .xx^\"        ^3#######x^0..................|
             .xx\"          ^3###########mx^0..............f
           .x^            ^3##############xx^0............|
          j\"             ^3##############    x^0..........;
.........#              ^3############       ^3#x^0.........|
x.......j\"              ^3##########      ^3 ####x^0.......f
 xxx....#..           ^3 ########       ^3 #######x^0......|
   xxxx.#....         ^3#######        ^3##########x^0.....|
      xxx......       ^3#####         #########   x^0....|
         xxx......    ^3###          #######      #m^0...|
           xxx......  ^3##           ######     ####^0..|
             xxx......^3#.          #####       ######m^0|
               xxxx.......        ^3###        #######Fx^0
                   xxx......     ^3 #         j#####    m^0
                      xx......             ^3 ####      Jxm^0
                       xxx......          ^3 ####      j###Km^0
                          xxx.....        ^3 ###      j####F  m^0
                             xx......     ^3  #       ###F    .m^0
                               xxx ....           ^3 j##F    .###m^0
                               m..xx.....         ^3 ##F    j#####K^mm.^0
                                m...xx......      ^3 ##     #####F    ####mm^0
                                m .....x......    ^3 F     j####F    ########^0
                                 m  ......x.....        ^3 ###F    J##########^0
                                 \"m  ........x....     ^3 .#F     #########^0^^|
                                  \"......mmF^^^x....   ^3 ##     ###### ^0     |
                                   lL..jF        x.... ^3.F      #### ^0       |
                                   lTLJF           x....     ^3 #### ^0        |
                                   l::|.            \"....    ^3j###       ##^0
                                    l....            L....   ^3###F     x##^0
                                     l....       ^3..m##L^0...  ^3##F     j###^0
                                     l:...        ^3#####L.^0.. ^3 #F     j####^0
                                      l....    ^3####     .^0..        ^3#####^0
                                      \"....              ...      ^3 ####F^0 |
                                       l....              ...     ^3j###F^0  |
                                        #...               ....   ^3###F^0    |
                                        \"#..              ^3.jL^0 .... ^3##F^0     |
                                         ##.            ^3.m###L^0 ....^3#F^0      |
                                         \"##        ^3..mm######^0  ....       |
                                          |                   |...        |
                                          k                    |...       |
                                          l                    |...       k
                                           k                 ^3.m#L^0 ...     Jk
                                           ##            ^3..mm####L^0 ...     k
                                           ###        ^3 d########^0 ' L....   |
                                           l                   |   \"-.__-\"
                                           l                   |
                                           l                  ^3j#^0 
                                           :                 ^3j##^0 
                                            k               ^3j##'^0 
                                            l            ^3.m###k^0 
                                            l           ^3###^^\"^0 |
                                            |                 ^0 |
                                            j               ^3.##^0 
                                            |              ^3######^0 
                                            |==          ^3##### ####^0 
                                           .k          ^3#####\"   ####^0 
                                           l         ^3#####^     ####^0 
                                           l       ^3###         ####'^0 
                                           !                 ^3m###F^0 
                                           |              ^3 ######^0 
                                           |           ^3mm##m###'^0 
                                           |.       ^3m########F^0 
                                           |.    ^3m#######F\" #^0 
                                           d.   ^3###        #^0 
                                          |..             .'
                                          |..             |
                                           k..           :
                                           ...          ^3F^0 
                                            |...        ^3#d^0 
                                            |...      ^3 ###^0 
                                             L...     ^3####.^0 
                                             |...    ^3j### ^0 |
                                              L...   ^3###  ^0 |
                                              T...  ^3j##    ^0 k
                                               ... ^3##     ^0 |
                                                 ...      .
                                                   \"^-____-

    ]]
    print(art)
end)