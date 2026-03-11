-- Menu de report

local reportMenu = RageUI.CreateMenu("Report", "Système de signalement")
reportMenu:DisplayGlare(true)
reportMenu:SetRectangleBanner(0, 0, 0, 255) -- bannière noire comme les autres menus

local hasPendingReport = false
local pendingReportData = nil

-- Fonction pour vérifier si le joueur a déjà un report ouvert
local function CheckPendingReport()
    local done = false
    ESX.TriggerServerCallback('Lixzy:HasPendingReport', function(reportData)
        if reportData then
            hasPendingReport = true
            pendingReportData = reportData
        else
            hasPendingReport = false
            pendingReportData = nil
        end
        done = true
    end)
    -- attendre que le callback serve retourne les informations
    while not done do
        Citizen.Wait(0)
    end
end

-- Vérifier au démarrage
Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(100)
    end
    Citizen.Wait(2000)
    CheckPendingReport()
end)

-- Rafraîchir quand un report est envoyé/annulé
RegisterNetEvent('Lixzy:RefreshPlayerReport')
AddEventHandler('Lixzy:RefreshPlayerReport', function()
    CheckPendingReport()
end)

-- Commande /report pour ouvrir le menu
RegisterCommand('report', function(source, args, rawCommand)
    -- Si des arguments sont fournis, on fait l'ancien système (envoi direct)
    if args[1] then
        local msg = table.concat(args, ' ')
        TriggerServerEvent('Lixzy:CreateReport', msg)
        return
    end
    
    -- Sinon on ouvre le menu
    CheckPendingReport()
    Citizen.Wait(100) -- Petit délai pour récupérer les données
    
    RageUI.Visible(reportMenu, not RageUI.Visible(reportMenu))
end, false)

-- Gestion du menu
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        RageUI.IsVisible(reportMenu, function()
            
            if hasPendingReport then
                -- Si le joueur a déjà un report ouvert
                RageUI.Separator("~r~Vous avez déjà un report ouvert")
                RageUI.Separator("Raison: ~y~" .. (pendingReportData.reason or ""))
                RageUI.Separator("")

                RageUI.Button('Voir le message complet', 'Afficher le message envoyé', {}, true, {
                    onSelected = function()
                        ESX.ShowAdvancedNotification('REPORT', '~b~Message complet', pendingReportData.reason or 'Aucun message', 'CHAR_CHAT_CALL', 1)
                    end
                })
                
                RageUI.Button("~r~Annuler mon report", "Supprimer votre report en attente", {RightLabel = "→"}, true, {
                    onSelected = function()
                        ESX.ShowNotification("~y~Annulation du report en cours...")
                        TriggerServerEvent('Lixzy:CancelReport')
                        Citizen.Wait(500)
                        CheckPendingReport()
                        ESX.ShowNotification('~g~Votre report a bien été supprimé')
                        RageUI.CloseAll()
                    end
                })
                
            else
                -- Si le joueur n'a pas de report ouvert
                RageUI.Separator("~g~Aucun report en cours")
                RageUI.Separator("")
                
                RageUI.Button("~g~Faire un report", "Signaler un problème ou un joueur", {RightLabel = "→"}, true, {
                    onSelected = function()
                        -- Ouvrir le clavier pour entrer le message
                        local reportText = KeyboardInput("REPORT_INPUT", "Décrivez votre problème", "", 500)
                        
                        if reportText and reportText ~= "" then
                            TriggerServerEvent('Lixzy:CreateReport', reportText)
                            ESX.ShowNotification('~g~Report envoyé avec succès !')
                            Citizen.Wait(500)
                            CheckPendingReport()
                            RageUI.CloseAll()
                        else
                            ESX.ShowNotification('~r~Vous devez entrer un message')
                        end
                    end
                })
            end
            
            RageUI.Separator("")
            RageUI.Button("~r~Fermer", "Fermer le menu", {RightLabel = "←"}, true, {
                onSelected = function()
                    RageUI.CloseAll()
                end
            })
            
        end)
        
        if not RageUI.Visible(reportMenu) then
            Citizen.Wait(500)
        end
    end
end)

-- Fonction KeyboardInput (si elle n'existe pas déjà dans votre client.lua)
function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
    AddTextEntry(entryTitle, textEntry)
    DisplayOnscreenKeyboard(1, entryTitle, '', inputText, '', '', '', maxLength)

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        return result
    else
        Citizen.Wait(500)
        return nil
    end
end
