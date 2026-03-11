--@type table Shared object
ESX = {};


TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

local player = {};

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


-- Props 
local limit1 = 0
local limit2 = 0
local limit3 = 0
local limit4 = 0
local limit5 = 0
local limit6 = 0
local limit7 = 0
local limit8 = 0
local limit9 = 0
local limit10 = 0
local limit11 = 0


-- Particule 
local dict2 = "scr_rcpaparazzo1" --Gatégorie
local particleName2 = "scr_mich4_firework_trailburst_spawn" -- Nom de la particule
SetParticle = function()
	Citizen.CreateThread(function()
		RequestNamedPtfxAsset(dict2)
		while not HasNamedPtfxAssetLoaded(dict2) do
			Citizen.Wait(0)
		end
		local ped = PlayerPedId()
		local x,y,z = table.unpack(GetEntityCoords(ped, true))
		local a = 0
		while a < 25 do
			UseParticleFxAssetNextCall(dict2)
			StartParticleFxNonLoopedAtCoord(particleName2, x, y, z, 1.50, 1.50, 1.50, 1.50, false, false, false)
			a = a + 1
			break
			Citizen.Wait(50)
		end
	end)
end

local dict2 = "proj_indep_firework" --Gatégorie
local particleName2 = "scr_indep_firework_grd_burst" -- Nom de la particule
SetParticlePed = function()
	Citizen.CreateThread(function()
		RequestNamedPtfxAsset(dict2)
		while not HasNamedPtfxAssetLoaded(dict2) do
			Citizen.Wait(0)
		end
		local ped = PlayerPedId()
		local x,y,z = table.unpack(GetEntityCoords(ped, true))
		local a = 0
		while a < 25 do
			UseParticleFxAssetNextCall(dict2)
			StartParticleFxNonLoopedAtCoord(particleName2, x, y, z, 1.50, 1.50, 1.50, 1.50, false, false, false)
			a = a + 1
			break
			Citizen.Wait(50)
		end
	end)
end

-- color menu 
local selectedColor = 1
local cVarLongC = { "~r~", "~b~", "~g~", "~y~", "~r~", "~o~", "~r~", "~b~", "~g~", "~y~", "~r~", "~o~" }
local cVarLong = function()
    return cVarLongC[selectedColor]
end

Citizen.CreateThread(function()
    while true do
        Wait(325)
        selectedColor = selectedColor + 1
        if selectedColor > #cVarLongC then
            selectedColor = 1
        end
    end
end)


local selectedColorE = 1
local cVarLongCE = { "~r~", "~w~", "~r~", "~w~", "~r~", "~w~" }
local cVarLongE = function()
    return cVarLongCE[selectedColorE]
end

Citizen.CreateThread(function()
    while true do
        Wait(100)
        selectedColorE = selectedColorE + 1
        if selectedColorE > #cVarLongCE then
            selectedColorE = 1
        end
    end
end)


Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        player = ESX.GetPlayerData()
        Citizen.Wait(10)
    end
end)


local TempsValue = "Aucun Temps !"
local raisontosend = "Aucune Raison !"
local GroupItem = {}
GroupItem.Value = 1

local mainMenu = RageUI.CreateMenu("~r~LIXZY", "~r~Gestions du serveur", 1);
mainMenu:DisplayGlare(true)
mainMenu:SetRectangleBanner(0, 0, 0, 255)
mainMenu:AddInstructionButton({
    [1] = GetControlInstructionalButton(1, 334, 0),
    [2] = "Modifier la vitesse du NoClip",
});

local selectedMenu = RageUI.CreateSubMenu(mainMenu, "~r~LIXZY", "~r~0TEX0", 1300) -- 1300 = position
selectedMenu:DisplayGlare(false)
selectedMenu:SetRectangleBanner(0, 0, 0, 255)

local playerActionMenu = RageUI.CreateSubMenu(mainMenu, "~r~LIXZY", "~r~0TEX0", 1300)
playerActionMenu:DisplayGlare(false)
playerActionMenu:SetRectangleBanner(0, 0, 0, 255)

local menurapid = RageUI.CreateSubMenu(mainMenu, "~r~LIXZY", "~r~Menu RevoPvP", 1300)
menurapid:DisplayGlare(true)
menurapid:SetRectangleBanner(0, 0, 0, 255)

local adminmenu = RageUI.CreateSubMenu(mainMenu, "~r~LIXZY", "~r~Menu RevoPvP", 1300)
adminmenu:DisplayGlare(true)
adminmenu:SetRectangleBanner(0, 0, 0, 255)

local utilsmenu = RageUI.CreateSubMenu(mainMenu, "~r~LIXZY", "~r~Menu Utils", 1300)
utilsmenu:DisplayGlare(true)
utilsmenu:SetRectangleBanner(0, 0, 0, 255)

local pedmenu = RageUI.CreateSubMenu(mainMenu, "~r~LIXZY", "~r~Menu Ped", 1300)
pedmenu:DisplayGlare(true)
pedmenu:SetRectangleBanner(0, 0, 0, 255)

local vehiculemenu = RageUI.CreateSubMenu(mainMenu, "~r~LIXZY", "~r~Menu Vehicule", 1300)
vehiculemenu:DisplayGlare(true)
vehiculemenu:SetRectangleBanner(0, 0, 0, 255)

-- Menu report séparé pour /report (utilisateur)


-- Menu staff pour voir les reports (staff)
local reportmenu = RageUI.CreateSubMenu(mainMenu, "~r~LIXZY", "~r~Reports en attente", 1300)
reportmenu:DisplayGlare(true)
reportmenu:SetRectangleBanner(0, 0, 0, 255)

local banmenu = RageUI.CreateSubMenu(mainMenu, "~r~LIXZY", "~r~Ban List", 1300)
banmenu:DisplayGlare(true)
banmenu:SetRectangleBanner(0, 0, 0, 255) -- black banner


---@class Lixzy
Lixzy = {} or {};

---@class SelfPlayer Administrator current settings
Lixzy.SelfPlayer = {
    ped = 0,
    isStaffEnabled = false,
    isClipping = false,
    isGamerTagEnabled = false,
    isReportEnabled = true,
    isInvisible = false,
    isCarParticleEnabled = false,
    isSteve = false,
    isDelgunEnabled = false,
    isRevogunEnabled = false,
};

-- Les tenues par défaut sont définies dans `ex_admin/config.lua` (Config.GroupOutfits).
-- Si tu as placé un `tenuestaff/outfits.json`, il sera chargé automatiquement et remplacera les valeurs côté client.
-- Tu peux éditer `tenuestaff/outfits.json` ou `ex_admin/config.lua` pour personnaliser les tenues.
-- (Valeurs par défaut présentes dans `ex_admin/config.lua`).


Lixzy.SelectedPlayer = {};

Lixzy.Menus = {} or {};

Lixzy.Helper = {} or {}

---@class Players
Lixzy.Players = {} or {} --- Players lists
---
Lixzy.PlayersStaff = {} or {} --- Players Staff

Lixzy.AllReport = {} or {} --- Players Staff
Lixzy.GetReport = {} -- initialisation pour éviter nil lors des affichages
Lixzy.Bans = {} -- ban list initialisation


---@class GamerTags
Lixzy.GamerTags = {} or {};

playerActionMenu.onClosed = function()
    Lixzy.SelectedPlayer = {}
end

local NoClip = {
    Camera = nil,
    Speed = 1.0
}

local blips = false

-- blips
Citizen.CreateThread(function()
	while true do
		Wait(1)
		if blips then
			for _, player in pairs(GetActivePlayers()) do
				local ped = GetPlayerPed( player )
				local blip = GetBlipFromEntity( ped )
				if not DoesBlipExist( blip ) then
					blip = AddBlipForEntity( ped )
					SetBlipSprite( blip, 1 )
					ShowHeadingIndicatorOnBlip( blip, true )
				else
					local veh = GetVehiclePedIsIn( ped, false )
					local blipSprite = GetBlipSprite( blip )
					if not NetworkIsPlayerTalking( player ) then
						if veh and veh > 0 then
							local vehClass = GetVehicleClass( veh )
							local vehModel = GetEntityModel( veh )
							if vehClass == 15 then
								if blipSprite ~= 422 then
									SetBlipSprite( blip, 422 )
									SetBlipColour(blip, 0)
									ShowHeadingIndicatorOnBlip( blip, false )
								end
							elseif vehClass == 16 then
								if vehModel == GetHashKey( 'besra' ) or vehModel == GetHashKey( 'hydra' ) or vehModel == GetHashKey( 'lazer' ) then
									if blipSprite ~= 424 then
										SetBlipSprite( blip, 424 )
										SetBlipColour(blip, 0)
										ShowHeadingIndicatorOnBlip( blip, false )
									end
								elseif blipSprite ~= 423 then
									SetBlipSprite( blip, 423 )
									SetBlipColour(blip, 0)
									ShowHeadingIndicatorOnBlip( blip, false )
								end
							end
						elseif IsPedInAnyVehicle( ped ) then
							if blipSprite ~= 225 then
								SetBlipSprite( blip, 225 )
								SetBlipColour(blip, 0)
								ShowHeadingIndicatorOnBlip( blip, false )
							end
						else
							if blipSprite ~= 1 then
								SetBlipSprite(blip, 1)
								SetBlipColour(blip, 0)
								ShowHeadingIndicatorOnBlip( blip, true )
							end
						end
					else
						if blipSprite ~= 1 then
							SetBlipSprite( blip, 1 )
							SetBlipColour(blip, 0)
							ShowHeadingIndicatorOnBlip( blip, true )
						end
					end
					if veh then
						SetBlipRotation( blip, math.ceil( GetEntityHeading( veh ) ) )
					else
						SetBlipRotation( blip, math.ceil( GetEntityHeading( ped ) ) )
					end
				end
			end
		else
			for _, player in pairs(GetActivePlayers()) do
				local blip = GetBlipFromEntity( GetPlayerPed(player) )
				if blip ~= nil then
					RemoveBlip(blip)
				end
			end
		end
	end
end)

local selectedIndex = 0;

-- pour le fasttravel
local FastTravel = {
    { Name = "Fourriere", Value = vector3(409.16, -1625.47, 29.29) },
    { Name = "Parking central", Value = vector3(215.76, -810.8, 30.72) },
    { Name = "Concessionaire", Value = vector3(-41.84, -1099.72, 26.42) },
    { Name = "Mecano", Value = vector3(-211.44, -1323.68, 30.89) },
}

-- pour les particuls
local ParticleList = {
    { Name = "Trace", Value = { "scr_rcbarry2", "sp_clown_appear_trails" } },
    { Name = "Mario kart", Value = { "scr_rcbarry2", "scr_clown_bul" } },
    { Name = "Mario kart (2)", Value = { "scr_rcbarry2", "muz_clown" } },
    { Name = "Ghost rider", Value = { "core", "ent_amb_foundry_steam_spawn" } },
};

local GroupIndex = 1;
local GroupIndexx = 1;
local GroupIndexxx = 1;
local GroupIndexxxx = 1;
local GroupIndexxxxx = 1;
local PermissionIndex = 1;
local VehicleIndex = 1;
local FastTravelIndex = 1;
local CarParticleIndex = 1;
local idtosanctionbaby = 1;
local idtoreport = 1;
local kvdureport = 1;
local reportDbId = 1; -- CORRECTION: Variable pour stocker l'ID du report dans la DB

function Lixzy.Helper:RetrievePlayersDataByID(source)
    local player = {}
    for i, v in pairs(Lixzy.Players) do
        if (v.source == source) then
            player = v
        end
    end
    return player
end

-- Returns true if the local player is staff by DB group
function Lixzy.Helper:IsLocalStaff()
    local group = ESX.GetPlayerData().group or 'user'
    return (group ~= 'user')
end

-- noclip
function Lixzy.Helper:onToggleNoClip(toggle)
    if (toggle) then
        Visual.Subtitle("~g~Vous venez d'activer le noclip", 1000)
        if Lixzy.Helper:IsLocalStaff() then
            if (NoClip.Camera == nil) then
                NoClip.Camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
            end
            SetCamActive(NoClip.Camera, true)
            RenderScriptCams(true, false, 0, true, true)
            SetCamCoord(NoClip.Camera, GetEntityCoords(Lixzy.SelfPlayer.ped))
            SetCamRot(NoClip.Camera, GetEntityRotation(Lixzy.SelfPlayer.ped))
            SetEntityCollision(NoClip.Camera, false, false)
            SetEntityVisible(NoClip.Camera, false)
            SetEntityVisible(Lixzy.SelfPlayer.ped, false, false)
        end
    else
        if Lixzy.Helper:IsLocalStaff() then
            Visual.Subtitle("~r~Vous venez de déactivez le noclip", 1000)
            SetCamActive(NoClip.Camera, false)
            RenderScriptCams(false, false, 0, true, true)
            SetEntityCollision(Lixzy.SelfPlayer.ped, true, true)
            -- place player safely on ground at camera location to avoid falling under the map
            local cx, cy, cz = table.unpack(GetCamCoord(NoClip.Camera))
            local foundZ, groundZ = GetGroundZFor_3dCoord(cx, cy, cz + 2.0, 0)
            if foundZ then
                cz = groundZ + 0.5
            end
            SetEntityCoords(Lixzy.SelfPlayer.ped, cx, cy, cz)
            SetEntityHeading(Lixzy.SelfPlayer.ped, GetGameplayCamRelativeHeading(NoClip.Camera))
            if not (Lixzy.SelfPlayer.isInvisible) then
                SetEntityVisible(Lixzy.SelfPlayer.ped, true, false)
            end
        end
    end
end


function Lixzy.Helper:OnRequestGamerTags()
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if (Lixzy.GamerTags[ped] == nil) or (Lixzy.GamerTags[ped].ped == nil) or not (IsMpGamerTagActive(Lixzy.GamerTags[ped].tags)) then
            local colors = {
                ["_dev"] = '~u~DEV',
                ["superadmin"] = '~y~FONDATEUR',
                ["owner"] = '~y~OWNER',
                ["manager"] = '~p~MANAGER',
                ["admin"] = '~r~ADMIN',
                ["mod"] = '~b~MODO',
                ["support"] = '~g~SUPPORT',
                ["user"] = 'USER',
            }
            local nameColors = {
                ["_dev"] = '~u~',
                ["superadmin"] = '~y~',
                ["owner"] = '~y~',
                ["manager"] = '~p~',
                ["admin"] = '~r~',
                ["mod"] = '~b~',
                ["support"] = '~g~',
                ["user"] = '~w~',  -- CORRECTION: Blanc pour les users
            }
            local formatted;
            local group = 'user';  -- Par défaut user
            local permission = 0;
            local fetching = Lixzy.Helper:RetrievePlayersDataByID(GetPlayerServerId(player));
            
            if (fetching) then
                group = fetching.group or 'user'
                local groupLabel = colors[group] or colors["user"]
                local nameColor = nameColors[group] or "~w~"
                formatted = string.format('[%s] [%d] %s%s~s~ (%s)', groupLabel, GetPlayerServerId(player), nameColor, GetPlayerName(player), fetching.jobs)
                permission = fetching.permission or 0
            else
                -- Si on ne trouve pas les infos, afficher en blanc par défaut
                formatted = string.format('[USER] [%d] ~w~%s~s~ (%s)', GetPlayerServerId(player), GetPlayerName(player), "~r~Emplois inconnus")
            end

            Lixzy.GamerTags[ped] = {
                player = player,
                ped = ped,
                group = group,
                permission = permission,
                tags = CreateFakeMpGamerTag(ped, formatted)
            };
        end
    end
end
function Lixzy.Helper:RequestModel(model)
    if (IsModelValid(model)) then
        if not (HasModelLoaded(model)) then
            RequestModel(model)
            while not HasModelLoaded(model) do
                Visual.Prompt(string.format("Lixzy : Chargement du modèle %s..", model), 4)
                Citizen.Wait(1.0)
            end
            BusyspinnerOff()
            return model;
        else
            Visual.PromptDuration(1000, string.format('Lixzy : Impossible de charger le modèle %s est déjà chargé', model), 1)
            return model;
        end
        Visual.FloatingHelpText(string.format("~r~ Lixzy : Le modèle %s que vous venez de demander n'existe pas dans les fichiers du jeu ou sur le serveur.", model))
        return model;
    end
end


function Lixzy.Helper:RequestPtfx(assetName)
    RequestNamedPtfxAsset(assetName)
    if not (HasNamedPtfxAssetLoaded(assetName)) then
        while not HasNamedPtfxAssetLoaded(assetName) do
            Citizen.Wait(1.0)
        end
        return assetName;
    else
        return assetName;
    end
end

function Lixzy.Helper:CreateVehicle(model, vector3)
    self:RequestModel(model)
    local vehicle = CreateVehicle(model, vector3, 100.0, true, false)
    local id = NetworkGetNetworkIdFromEntity(vehicle)

    SetNetworkIdCanMigrate(id, true)
    SetEntityAsMissionEntity(vehicle, false, false)
    SetModelAsNoLongerNeeded(model)

    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehRadioStation(vehicle, 'OFF')
    while not HasCollisionLoadedAroundEntity(vehicle) do
        Citizen.Wait(0)
    end
    return vehicle, GetEntityCoords(vehicle);
end

function Lixzy.Helper:KeyboardInput(TextEntry, ExampleText, MaxStringLength, OnlyNumber)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", 500)
    local blocking = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        blocking = false
        if (OnlyNumber) then
            local number = tonumber(result)
            if (number ~= nil) then
                return number
            end
            return nil
        else
            return result
        end
    else
        Citizen.Wait(500)
        blocking = false
        return nil
    end
end

function Lixzy.Helper:OnGetPlayers()
    local clientPlayers = false;
    ESX.TriggerServerCallback('Lixzy:retrievePlayers', function(players)
        clientPlayers = players
    end)

    while not clientPlayers do
        Citizen.Wait(0)
    end
    return clientPlayers
end

function Lixzy.Helper:OnGetStaffPlayers()
    local clientPlayers = false;
    ESX.TriggerServerCallback('Lixzy:retrieveStaffPlayers', function(players)
        clientPlayers = players
    end)
    while not clientPlayers do
        Citizen.Wait(0)
    end
    return clientPlayers
end

function Lixzy.Helper:GetReport()
    local ReportBB = false
    ESX.TriggerServerCallback('Lixzy:retrieveReport', function(allreport)
        ReportBB = allreport
    end)
    while not ReportBB do
        Citizen.Wait(0)
    end
    return ReportBB
end

-- Fetch bans from server
function Lixzy.Helper:GetBans()
    local BanBB = false
    ESX.TriggerServerCallback('Lixzy:retrieveBans', function(bans)
        BanBB = bans
    end)
    while not BanBB do
        Citizen.Wait(0)
    end
    return BanBB
end

RegisterNetEvent("Lixzy:RefreshReport")
AddEventHandler("Lixzy:RefreshReport", function()
    Lixzy.GetReport = Lixzy.Helper:GetReport()
end)


-- Handler pour /report (menu utilisateur)


RegisterNetEvent("Lixzy:menu1")
AddEventHandler("Lixzy:menu1", function()
    Lixzy.Players = Lixzy.Helper:OnGetPlayers();
    Lixzy.PlayersStaff = Lixzy.Helper:OnGetStaffPlayers()
    Lixzy.GetReport = Lixzy.Helper:GetReport()
    RageUI.Visible(mainMenu, not RageUI.Visible(mainMenu))
end)

RegisterNetEvent("Lixzy:menu2")
AddEventHandler("Lixzy:menu2", function()
    Lixzy.GetReport = Lixzy.Helper:GetReport()
    RageUI.Visible(reportmenu, not RageUI.Visible(reportmenu))
end)

-- MENU ADMIN
Citizen.CreateThread(function()
    while true do

        Citizen.Wait(1)





        RageUI.IsVisible(mainMenu, function()

            RageUI.Checkbox("Staff mode", "Le mode staff ne peut être utilisé que pour ~r~modérer~s~ le serveur, ~r~tout abus sera sévèrement puni~s~, l'intégrité de vos actions sera ~r~enregistrée!!", Lixzy.SelfPlayer.isStaffEnabled, { }, {
                onChecked = function()
                    -- Lixzy.Helper:onStaffMode(true) supprimé (fonction inexistante)
                    TriggerServerEvent('Lixzy:onStaffJoin')
                    serverInteraction = true
                    TriggerEvent('skinchanger:getSkin', function(skin)
                        local group = ESX.GetPlayerData().group or 'user'
                        local outfit = Config.GroupOutfits and Config.GroupOutfits[group] or Config.GroupOutfits and Config.GroupOutfits['default']
                        if outfit then
                            TriggerEvent('skinchanger:loadClothes', skin, outfit)
                        end
                    end)
                end,
                onUnChecked = function()
                    -- Lixzy.Helper:onStaffMode(false) supprimé (fonction inexistante)
                    TriggerServerEvent('Lixzy:onStaffLeave')
                    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                        TriggerEvent('skinchanger:loadSkin', skin)
                    end)
                end,
                onSelected = function(Index)
                    Lixzy.SelfPlayer.isStaffEnabled = Index
                end
            })

            RageUI.Separator(cVarLong() .."→→ 🛡️ ←←")

            RageUI.Separator(string.format(cVarLongE() .. '•~s~ Staff en lignes  [~r~%s~s~]', #Lixzy.PlayersStaff))
 
            RageUI.Separator(string.format(cVarLongE() .. '•~s~ Joueurs en lignes  [~r~%s~s~]', #Lixzy.Players))

            if (Lixzy.SelfPlayer.isStaffEnabled) then

                RageUI.Separator(cVarLong() .."↓ ~r~INTERACTION~s~".. cVarLong() .."↓")

                RageUI.Button(cVarLong() ..'→→ ~s~Liste des staffs', nil, { }, true, {
                    onSelected = function()
                        ESX.ShowNotification(string.format('Staff en lignes [~b~%s~s~]', #Lixzy.PlayersStaff))
                        selectedMenu:SetSubtitle(string.format('~r~Staff en lignes [%s]', #Lixzy.PlayersStaff))
                        selectedIndex = 2;
                    end
                }, selectedMenu)

                RageUI.Button(cVarLong() ..'→→ ~s~Liste des joueurs', nil, { }, true, { 
                    onSelected = function()
                        ESX.ShowNotification(string.format('Joueurs en lignes [~b~%s~s~]', #Lixzy.Players)) 
                        selectedMenu:SetSubtitle(string.format('~r~Joueurs en lignes [%s]', #Lixzy.Players))  
                        selectedIndex = 1;
                    end
                }, selectedMenu)

                RageUI.Button(cVarLong() .. '→→ ~s~Liste des reports', nil, {  }, true, {
                    onSelected = function()
                    end
                }, reportmenu)

                RageUI.Separator(cVarLong() .."↓ ~r~MENU ~s~".. cVarLong() .."↓")

                RageUI.Button(cVarLong() ..'→ ~s~ Menu Admin', nil, { }, true, {
                    onSelected = function()
                    end
                }, adminmenu)

                RageUI.Button(cVarLong() ..'→ ~s~ Menu Rapid', nil, { }, true, {
                    onSelected = function()
                    end
                }, menurapid)
                
                RageUI.Button(cVarLong() ..'→ ~s~ Menu Ped', nil, { }, true, {
                    onSelected = function()
                    end
                }, pedmenu)

                RageUI.Button(cVarLong() ..'→ ~s~Menu Vehicule', nil, { }, true, {
                    onSelected = function()
                    end
                }, vehiculemenu)

                RageUI.Button(cVarLong() ..'→ ~s~ Menu Utils', nil, { }, true, {
                    onSelected = function()
                    end
                }, utilsmenu)

            end
        end)

        if (Lixzy.SelfPlayer.isStaffEnabled) then
            RageUI.IsVisible(utilsmenu, function()

                RageUI.Checkbox("Delgun", nil, Lixzy.SelfPlayer.isDelgunEnabled, { }, {
                    onChecked = function()
                        TriggerServerEvent("Lixzy:SendLogs", "Active Delgun")
                    end,
                    onUnChecked = function()
                        TriggerServerEvent("Lixzy:SendLogs", "Désactive Delgun")
                    end,
                    onSelected = function(Index)
                        Lixzy.SelfPlayer.isDelgunEnabled = Index
                        if Index then
                            if Lixzy.SelfPlayer.isRevogunEnabled then
                                Lixzy.SelfPlayer.isRevogunEnabled = false
                                TriggerServerEvent("Lixzy:SendLogs", "Désactive Revogun (Auto)")
                            end
                        end
                    end
                })

                RageUI.Checkbox("Revogun", "Quand activé, un laser s'affiche et en tirant sur un joueur vous ouvrez sa page", Lixzy.SelfPlayer.isRevogunEnabled, { }, {
                    onChecked = function()
                        TriggerServerEvent("Lixzy:SendLogs", "Active Revogun")
                    end,
                    onUnChecked = function()
                        TriggerServerEvent("Lixzy:SendLogs", "Désactive Revogun")
                    end,
                    onSelected = function(Index)
                        Lixzy.SelfPlayer.isRevogunEnabled = Index
                        if Index then
                            if Lixzy.SelfPlayer.isDelgunEnabled then
                                Lixzy.SelfPlayer.isDelgunEnabled = false
                                TriggerServerEvent("Lixzy:SendLogs", "Désactive Delgun (Auto)")
                            end
                        end
                    end
                })

                RageUI.List('Fast Travel', FastTravel, FastTravelIndex, nil, {}, true, {
                    onListChange = function(Index, Item)
                        FastTravelIndex = Index;
                    end,
                    onSelected = function(Index, Item)
                        SetEntityCoords(PlayerPedId(), Item.Value)
                    end,
                })

                RageUI.Checkbox("Particule sur les roue", nil, Lixzy.SelfPlayer.isCarParticleEnabled, { }, {
                    onChecked = function()
                        TriggerServerEvent("Lixzy:SendLogs", "Active Particle on wheel")
                    end,
                    onUnChecked = function()
                        TriggerServerEvent("Lixzy:SendLogs", "Désactive Particle on wheel")
                    end,
                    onSelected = function(Index)
                        Lixzy.SelfPlayer.isCarParticleEnabled = Index
                    end
                })

                if (Lixzy.SelfPlayer.isCarParticleEnabled) then
                    RageUI.List('Particule sur les roue (Type)', ParticleList, CarParticleIndex, nil, {}, true, {
                        onListChange = function(Index, Item)
                            CarParticleIndex = Index;
                        end,
                        onSelected = function(Index, Item)

                        end,
                    })
                end
            end)
        end


        if (Lixzy.SelfPlayer.isStaffEnabled) then
            RageUI.IsVisible(pedmenu, function()

                RageUI.Button('Reprendre son personnage', nil, {}, true, {
                    onSelected = function()
                        SetParticlePed()
                        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
                            local isMale = skin.sex == 0
        
        
                            TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
                                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                                    TriggerEvent('skinchanger:loadSkin', skin)
                                    TriggerEvent('esx:restoreLoadout')
                            end)
                            end)
                            end) 
                        end
                }, pedmenu)

                RageUI.Separator("↓ ~r~Ped ~s~↓")

                RageUI.Button('Robot', nil, {}, true, {
                    onSelected = function()
                        SetParticlePed()
                        local j1 = PlayerId()
                    local p1 = GetHashKey('u_m_y_rsranger_01')
                    RequestModel(p1)
                    while not HasModelLoaded(p1) do
                        Wait(100)
                        end
                        SetPlayerModel(j1, p1)
                        SetModelAsNoLongerNeeded(p1)
                    end  
                }, pedmenu)

                RageUI.Button('Apu', nil, {}, true, {
                    onSelected = function()
                        SetParticlePed()
                        local j1 = PlayerId()
                        local p1 = GetHashKey('g_f_y_lost_01')
                        RequestModel(p1)
                        while not HasModelLoaded(p1) do
                            Wait(100)
                            end
                            SetPlayerModel(j1, p1)
                            SetModelAsNoLongerNeeded(p1)
                        end  
                }, pedmenu)

                RageUI.Button('Apu 2', nil, {}, true, {
                    onSelected = function()
                        SetParticlePed()
                        local j1 = PlayerId()
                    local p1 = GetHashKey('s_f_y_bartender_01')
                    RequestModel(p1)
                    while not HasModelLoaded(p1) do
                        Wait(100)
                        end
                        SetPlayerModel(j1, p1)
                        SetModelAsNoLongerNeeded(p1)
                    end   
                }, pedmenu)

                RageUI.Button('Pogo Wish', nil, {}, true, {
                    onSelected = function()
                        SetParticlePed()
                        local j1 = PlayerId()
                        local p1 = GetHashKey('u_m_m_streetart_01')
                        RequestModel(p1)
                        while not HasModelLoaded(p1) do
                            Wait(100)
                            end
                            SetPlayerModel(j1, p1)
                            SetModelAsNoLongerNeeded(p1)
                        end 
                }, pedmenu)

                RageUI.Button('Pogo', nil, {}, true, {
                    onSelected = function()
                        SetParticlePed()
                        local j1 = PlayerId()
                    local p1 = GetHashKey('u_m_y_pogo_01')
                    RequestModel(p1)
                    while not HasModelLoaded(p1) do
                      Wait(100)
                     end
                     SetPlayerModel(j1, p1)
                     SetModelAsNoLongerNeeded(p1)
                    end
                }, pedmenu)

                RageUI.Button('Mime', nil, {}, true, {
                    onSelected = function()  
                        SetParticlePed()
                        local j1 = PlayerId()
                        local p1 = GetHashKey('s_m_y_mime')
                        RequestModel(p1)
                        while not HasModelLoaded(p1) do
                          Wait(100)
                         end
                         SetPlayerModel(j1, p1)
                         SetModelAsNoLongerNeeded(p1)
                        end 
                }, pedmenu)

                RageUI.Button('Jésus', nil, {}, true, {
                    onSelected = function()     
                        SetParticlePed()
                            local j1 = PlayerId()
                            local p1 = GetHashKey('u_m_m_jesus_01')
                            RequestModel(p1)
                            while not HasModelLoaded(p1) do
                              Wait(100)
                             end
                             SetPlayerModel(j1, p1)
                             SetModelAsNoLongerNeeded(p1)
                            end
                }, pedmenu)

                RageUI.Button('The Rock', nil, {}, true, {
                    onSelected = function()  
                        SetParticlePed()  
                            local j1 = PlayerId()
                    local p1 = GetHashKey('u_m_y_babyd')
                    RequestModel(p1)
                    while not HasModelLoaded(p1) do
                      Wait(100)
                     end
                     SetPlayerModel(j1, p1)
                     SetModelAsNoLongerNeeded(p1)
                    end 
                }, pedmenu)

                RageUI.Button('Zombie', nil, {}, true, {
                    onSelected = function()     
                        SetParticlePed()
                            local j1 = PlayerId()
                            local p1 = GetHashKey('u_m_y_zombie_01')
                            RequestModel(p1)
                            while not HasModelLoaded(p1) do
                              Wait(100)
                             end
                             SetPlayerModel(j1, p1)
                             SetModelAsNoLongerNeeded(p1)
                            end  
                }, pedmenu)

                RageUI.Button('Sonic', nil, {}, true, {
                    onSelected = function()     
                        SetParticlePed()
                            local j1 = PlayerId()
                            local p1 = GetHashKey('Sonic')
                            RequestModel(p1)
                            while not HasModelLoaded(p1) do
                              Wait(100)
                             end
                             SetPlayerModel(j1, p1)
                             SetModelAsNoLongerNeeded(p1)
                            end  
                }, pedmenu)

                RageUI.Button('patrick', nil, {}, true, {
                    onSelected = function()    
                        SetParticlePed() 
                            local j1 = PlayerId()
                            local p1 = GetHashKey('patrick')
                            RequestModel(p1)
                            while not HasModelLoaded(p1) do
                              Wait(100)
                             end
                             SetPlayerModel(j1, p1)
                             SetModelAsNoLongerNeeded(p1)
                            end  
                }, pedmenu)

                RageUI.Button('Ada_Wong', nil, {}, true, {
                    onSelected = function()  
                        SetParticlePed()   
                            local j1 = PlayerId()
                            local p1 = GetHashKey('Ada_Wong')
                            RequestModel(p1)
                            while not HasModelLoaded(p1) do
                              Wait(100)
                             end
                             SetPlayerModel(j1, p1)
                             SetModelAsNoLongerNeeded(p1)
                            end  
                }, pedmenu)

                RageUI.Button('Asian', nil, {}, true, {
                    onSelected = function()     
                        SetParticlePed()
                            local j1 = PlayerId()
                            local p1 = GetHashKey('AsianGirl')
                            RequestModel(p1)
                            while not HasModelLoaded(p1) do
                              Wait(100)
                             end
                             SetPlayerModel(j1, p1)
                             SetModelAsNoLongerNeeded(p1)
                            end  
                }, pedmenu)

            end)
        end

        if (Lixzy.SelfPlayer.isStaffEnabled) then
            RageUI.IsVisible(vehiculemenu, function()
                RageUI.List('Vehicles', {
                    { Name = "BMX", Value = 'bmx' },
                    { Name = "Club", Value = 'club' },
                    { Name = "Panto", Value = 'panto' },
                    { Name = "Blista", Value = "Blista" },
                    { Name = "Sanchez", Value = 'sanchez' },
                }, VehicleIndex, nil, {}, true, {
                    onListChange = function(Index, Item)
                        VehicleIndex = Index;
                    end,
                    onSelected = function(Index, Item)
                        if Item.Value == nil then
                            local modelName = KeyboardInput('Lixzy_BOX_VEHICLE_NAME', "Nom du vehicule", '', 50)
                            TriggerEvent('Lixzy:spawnVehicle', modelName)
                            TriggerServerEvent("Lixzy:SendLogs", "Spawn custom vehicle")
                        else
                            TriggerEvent('Lixzy:spawnVehicle', Item.Value)
                            TriggerServerEvent("Lixzy:SendLogs", "Spawn vehicle")
                        end
                    end,
                })
                RageUI.Button('Réparation du véhicule', nil, { }, true, {
                    onSelected = function()
                        local plyVeh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
                        SetVehicleFixed(plyVeh)
                        SetVehicleDirtLevel(plyVeh, 0.0)
                        TriggerServerEvent("Lixzy:SendLogs", "Repair Vehicle")
                    end
                })

                RageUI.List('Suppression des véhicules (Zone)', {
                    { Name = "1", Value = 1 },
                    { Name = "5", Value = 5 },
                    { Name = "10", Value = 10 },
                    { Name = "15", Value = 15 },
                    { Name = "20", Value = 20 },
                    { Name = "25", Value = 25 },
                    { Name = "30", Value = 30 },
                    { Name = "50", Value = 50 },
                    { Name = "100", Value = 100 },
                }, GroupIndex, nil, {}, true, {
                    onListChange = function(Index, Item)
                        GroupIndex = Index;
                    end,
                    onSelected = function(Index, Item)
                        TriggerServerEvent("Lixzy:SendLogs", "Delete vehicle zone")
                        local playerPed = PlayerPedId()
                        local radius = Item.Value
                        if radius and tonumber(radius) then
                            radius = tonumber(radius) + 0.01
                            local vehicles = ESX.Game.GetVehiclesInArea(GetEntityCoords(playerPed, false), radius)

                            for i = 1, #vehicles, 1 do
                                local attempt = 0

                                while not NetworkHasControlOfEntity(vehicles[i]) and attempt < 100 and DoesEntityExist(vehicles[i]) do
                                    Citizen.Wait(100)
                                    NetworkRequestControlOfEntity(vehicles[i])
                                    attempt = attempt + 1
                                end

                                if DoesEntityExist(vehicles[i]) and NetworkHasControlOfEntity(vehicles[i]) then
                                    ESX.Game.DeleteVehicle(vehicles[i])
                                    DeleteEntity(vehicles[i])
                                end
                            end
                        else
                            local vehicle, attempt = ESX.Game.GetVehicleInDirection(), 0

                            if IsPedInAnyVehicle(playerPed, true) then
                                vehicle = GetVehiclePedIsIn(playerPed, false)
                            end

                            while not NetworkHasControlOfEntity(vehicle) and attempt < 100 and DoesEntityExist(vehicle) do
                                Citizen.Wait(100)
                                NetworkRequestControlOfEntity(vehicle)
                                attempt = attempt + 1
                            end

                            if DoesEntityExist(vehicle) and NetworkHasControlOfEntity(vehicle) then
                                ESX.Game.DeleteVehicle(vehicle)
                                DeleteEntity(vehicle)
                            end
                        end
                    end,
                })
            end)
        end

        if (Lixzy.SelfPlayer.isStaffEnabled) then
            RageUI.IsVisible(menurapid, function()
                
                
                RageUI.Separator("↓ ~r~Action rapides ~s~↓")

                

                RageUI.Button('Se teleporter sur lui', nil, {}, true, {
                    onSelected = function()
                        local id = KeyboardInput('Lixzy_BOX_TP', "ID DE LA PERSONNE",'1', 25)
                        TriggerServerEvent("Lixzy:teleport", id)
                    end
                }, menurapid)

                RageUI.Button('Le teleporter sur moi', nil, {}, true, {
                    onSelected = function()
                        local quelid = KeyboardInput('Lixzy_BOX_TP', "ID DE LA PERSONNE",'1', 25)
                        TriggerServerEvent("Lixzy:teleportTo", quelid)
                    end
                }, menurapid)

                RageUI.Button('Le teleporter au Parking Central', nil, {}, true, {
                    onSelected = function()
                        local quelid = KeyboardInput('Lixzy_BOX_TP', "ID DE LA PERSONNE",'1', 25)
                        TriggerServerEvent('Lixzy:teleportcoords', quelid, vector3(215.76, -810.12, 30.73))
                    end
                }, menurapid)

                RageUI.Separator("↓ ~r~ANNONCE~s~ ↓")

                RageUI.Button('Annonce', "~r~Perm~s~: ~n~admin, manager, owner, superadmin", {}, true, {
                    onSelected = function()
                        local quelid = KeyboardInput('Lixzy_BOX_ANNONCE', "Message", "~~ ~~ ~~ ~~ ~~", 500)
                        TriggerServerEvent('Lixzy:annonce', quelid)
                    end
                }, menurapid)

                RageUI.Separator("↓ ~r~REVO PVP~s~ ↓")
               
                RageUI.Button('Reviveall', "~r~Revive tout le monde ~n~ ~r~Perm~s~: ~n~owner, superadmin", {}, true, {
                    onSelected = function()
                        TriggerServerEvent('Lixzy:reviveall')
                    end
                }, menurapid)

                RageUI.Button('Save les joueurs', "Save tout les joueurs du serveur~n~ ~r~Perm~s~: ~n~ owner, superadmin", {}, true, {
                    onSelected = function()
                        TriggerServerEvent('Lixzy:SavellPlayerAuto')
                    end
                }, menurapid)

            end)
        end

        if (Lixzy.SelfPlayer.isStaffEnabled) then
            RageUI.IsVisible(adminmenu, function()
                RageUI.Checkbox("Afficher les Noms", "L'affichage les noms des joueurs vous permet de voir les informations des joueurs, y compris de vous reconnaître entre les membres du personnel grâce à votre couleur.", Lixzy.SelfPlayer.isGamerTagEnabled, { }, {
                    onChecked = function()
                        if Lixzy.Helper:IsLocalStaff() then
                            TriggerServerEvent("Lixzy:SendLogs", "Active Nom")
                            Lixzy.Helper:OnRequestGamerTags()
                        end
                    end,
                    onUnChecked = function()
                        for i, v in pairs(Lixzy.GamerTags) do
                            TriggerServerEvent("Lixzy:SendLogs", "Désactive Nom")
                            RemoveMpGamerTag(v.tags)
                        end
                        Lixzy.GamerTags = {};
                    end,
                    onSelected = function(Index)
                        Lixzy.SelfPlayer.isGamerTagEnabled = Index
                    end
                })
                
                RageUI.Checkbox("NoClip", "Vous permet de vous déplacer librement sur toute la carte sous forme de caméra libre.", Lixzy.SelfPlayer.isClipping, { }, {
                    onChecked = function()
                        TriggerServerEvent("Lixzy:SendLogs", "Active noclip")
                        Lixzy.Helper:onToggleNoClip(true)
                        SetParticle()
                    end,
                    onUnChecked = function()
                        TriggerServerEvent("Lixzy:SendLogs", "Désactive noclip")
                        Lixzy.Helper:onToggleNoClip(false)
                        SetParticle()
                    end,
                    onSelected = function(Index)
                        Lixzy.SelfPlayer.isClipping = Index
                    end
                })
                RageUI.Checkbox("Invisible", nil, Lixzy.SelfPlayer.isInvisible, { }, {
                    onChecked = function()
                        TriggerServerEvent("Lixzy:SendLogs", "Active invisible")
                        SetEntityVisible(Lixzy.SelfPlayer.ped, false, false)
                        SetParticle()
                    end,
                    onUnChecked = function()
                        TriggerServerEvent("Lixzy:SendLogs", "Désactive invisible")
                        SetEntityVisible(Lixzy.SelfPlayer.ped, true, false)
                        SetParticle()
                    end,
                    onSelected = function(Index)
                        Lixzy.SelfPlayer.isInvisible = Index
                    end
                })

                RageUI.Checkbox("Blips", nil, Lixzy.SelfPlayer.IsBlipsActive, { }, {
                    onChecked = function()
                        TriggerServerEvent("Lixzy:SendLogs", "Active Blips")
                        blips = true
                    end,
                    onUnChecked = function()
                        TriggerServerEvent("Lixzy:SendLogs", "Désactive Blips")
                        blips = false
                    end,
                    onSelected = function(Index)
                        Lixzy.SelfPlayer.IsBlipsActive = Index
                    end
                })

                RageUI.Button('~r~Liste des bans', nil, {}, true, {
                    onSelected = function()
                        Lixzy.Bans = Lixzy.Helper:GetBans()
                        ESX.ShowNotification('Récupération de la liste des bans...')
                    end
                }, banmenu) 
            end)
        end

        -- Ban list menu
        if (Lixzy.SelfPlayer.isStaffEnabled) then
            RageUI.IsVisible(banmenu, function()
                if Lixzy.Bans and #Lixzy.Bans > 0 then
                    for i, v in pairs(Lixzy.Bans) do
                        local expText = v.expires_formatted or 'Erreur'
                        local label = string.format('[ID:%s] %s', tostring(v.id), tostring(v.reason or 'Aucune raison'))
                        local subtitle = string.format('Cible: %s | Staff: %s | Expire: %s', 
                        tostring(v.license and v.license:sub(1, 20)..'...' or 'N/A'), 

                        tostring(v.staff or 'N/A'), 
                         expText
                        )
                        -- Bouton principal avec confirmation
                        RageUI.Button(label, subtitle, {}, true, {
                            onSelected = function()
                                local confirm = KeyboardInput('CONFIRM_UNBAN', 'Tapez OUI pour confirmer l\'unban ID '..tostring(v.id), '', 3)
                                if confirm and (confirm == 'OUI' or confirm == 'oui') then
                                    TriggerServerEvent('Lixzy:UnbanPlayer', v.id)
                                    ESX.ShowNotification('Demande de unban envoyée pour ID '..tostring(v.id))
                                    Citizen.Wait(500)
                                    Lixzy.Bans = Lixzy.Helper:GetBans()
                                else
                                    ESX.ShowNotification('Unban annulé')

                                end

                            end

                        })

                        -- Bouton débannir rapide
                        RageUI.Button('~g~→ Débannir (Rapide)', 'Supprime ce ban immédiatement', {}, true, {
                            onSelected = function()
                                TriggerServerEvent('Lixzy:UnbanPlayer', v.id)
                                ESX.ShowNotification('Demande de unban envoyée pour ID '..tostring(v.id))
                                Citizen.Wait(500)
                                Lixzy.Bans = Lixzy.Helper:GetBans()
                            end
                        })
                    end
                else
                    RageUI.Separator('Aucun ban trouvé')
                end
            end)
        end

        if (Lixzy.SelfPlayer.isStaffEnabled) then
            RageUI.IsVisible(selectedMenu, function()
                table.sort(Lixzy.Players, function(a,b) return a.source < b.source end)
                if (selectedIndex == 1) then
                    if (#Lixzy.Players > 0) then

                        for i, v in pairs(Lixzy.Players) do
                            local colors = {
                                ["_dev"] = '~u~DEV',
                                ["superadmin"] = '~y~FONDATEUR',
                                ["owner"] = '~y~OWNER',
                                ["manager"] = '~p~MANAGER',
                                ["admin"] = '~r~ADMIN',
                                ["mod"] = '~b~MODO',
                                ["support"] = '~g~SUPPORT',
                                ["user"] = 'USER',
                            }
                            RageUI.Separator("↓ ~r~GROUPE~s~ ↓ ↓ ~r~NOM~s~ ↓ ↓ ~r~ID~s~ ↓ ↓ ~r~JOB~s~ ↓")
                            RageUI.Button(string.format(cVarLong() .. '→ ~s~ %s  |  %s  |  [%s]  |  %s', colors[v.group], v.name, v.source, v.jobs), nil, {}, true, {
                                onSelected = function()
                                    playerActionMenu:SetSubtitle(string.format('[%s] %s', i, v.name))
                                    Lixzy.SelectedPlayer = v;
                                end
                            }, playerActionMenu)
                        end
                    else
                        RageUI.Separator("Aucun joueurs en ligne.")
                    end
                end
                if (selectedIndex == 2) then
                    if (#Lixzy.PlayersStaff > 0) then
                        for i, v in pairs(Lixzy.PlayersStaff) do
                            local colors = {
                                ["_dev"] = '~u~DEV',
                                ["superadmin"] = '~y~FONDATEUR',
                                ["owner"] = '~y~OWNER',
                                ["manager"] = '~p~MANAGER',
                                ["admin"] = '~r~ADMIN',
                                ["mod"] = '~b~MODO',
                                ["support"] = '~g~SUPPORT',
                                }
                            RageUI.Separator("↓ ~r~GROUPE~s~ ↓ ↓ ~r~NOM~s~ ↓ ↓ ~r~ID~s~ ↓ ↓ ~r~JOB~s~ ↓")
                            RageUI.Button(string.format(cVarLong() .. '→ ~s~ %s  |  %s  |  [%s]  |  %s', colors[v.group], v.name, v.source, v.jobs), nil, {}, true, {
                                onSelected = function()
                                    playerActionMenu:SetSubtitle(string.format('[%s] %s', v.source, v.name))
                                    Lixzy.SelectedPlayer = v;
                                end
                            }, playerActionMenu)
                        end
                    else
                        RageUI.Separator("Aucun joueurs en ligne.")
                    end
                end

                if (selectedIndex == 4) then
                    for i, v in pairs(Lixzy.Players) do
                        if v.source == idtosanctionbaby then
                            RageUI.Separator("↓ ~r~INFORMATION ~s~↓")
                            RageUI.Button('Groupe : ' .. v.group, nil, {}, true, {
                                onSelected = function()
                                end
                            })
                            RageUI.Button('ID : ' .. idtosanctionbaby, nil, {}, true, {
                                onSelected = function()
                                end
                            })
        
                            RageUI.Button('Nom : ' .. v.name, nil, {}, true, {
                                onSelected = function()
                                end
                            })
                            RageUI.Button('Jobs : ' .. v.jobs, nil, {}, true, {
                                onSelected = function()
                                end
                            })
                        end
                    end
                    RageUI.Separator("↓~r~ SANCTION~s~ ↓")
                    RageUI.Button('Raison du kick', nil, { RightLabel = raisontosend }, true, {
                        onSelected = function()
                            local Raison = KeyboardInput('Lixzy_BOX_BAN_RAISON', "Raison du kick", '', 50)
                            raisontosend = Raison
                        end
                    })

                    RageUI.Button('Valider', nil, { RightLabel = "✅" }, true, {
                        onSelected = function()
                            TriggerServerEvent("Lixzy:kick", idtosanctionbaby, raisontosend)
                        end
                    })
                end
                if (selectedIndex == 6) then
                    for i, v in pairs(Lixzy.Players) do
                        if v.source == idtoreport then
                            RageUI.Separator("↓ ~r~INFORMATION ~s~↓")
                            RageUI.Button('Groupe : ~b~' .. v.group, nil, {}, true, {
                                onSelected = function()
                                end
                            })
                            RageUI.Button('ID : ~r~' .. idtoreport, nil, {}, true, {
                                onSelected = function()
                                end
                            })
        
                            RageUI.Button('Nom : ~o~' .. v.name, nil, {}, true, {
                                onSelected = function()
                                end
                            })
                            RageUI.Button('Jobs : ' .. v.jobs, nil, {}, true, {
                                onSelected = function()
                                end
                            })
                        end
                    end

                        -- ACTION RAPIDE: si le joueur est en ligne, proposer les actions habituelles, sinon afficher les infos du report
                    local foundPlayer = false
                    for i, v in pairs(Lixzy.Players) do
                        if v.source == idtoreport then
                            foundPlayer = true
                            RageUI.Separator("↓ ~r~INFORMATION ~s~↓")
                            RageUI.Button('Groupe : ~b~' .. v.group, nil, {}, true, {
                                onSelected = function() end
                            })
                            RageUI.Button('ID : ~r~' .. idtoreport, nil, {}, true, {
                                onSelected = function() end
                            })
                            RageUI.Button('Nom : ~o~' .. v.name, nil, {}, true, {
                                onSelected = function() end
                            })
                            RageUI.Button('Jobs : ' .. v.jobs, nil, {}, true, {
                                onSelected = function() end
                            })

                            RageUI.Separator("↓~r~ ACTION RAPIDE ~s~↓")
                            RageUI.Button('Se teleporter sur lui', nil, {}, true, {
                                onSelected = function()
                                    TriggerServerEvent("Lixzy:teleport", idtoreport)
                                end
                            })
                            RageUI.Separator("")
                            RageUI.Button('Le teleporter sur moi', nil, {}, true, {
                                onSelected = function()
                                    TriggerServerEvent("Lixzy:teleportTo", idtoreport)
                                end
                            })
                            RageUI.Button('Le teleporter au Parking Central', nil, {}, true, {
                                onSelected = function()
                                    TriggerServerEvent('Lixzy:teleportcoords', idtoreport, vector3(215.76, -810.12, 30.73))
                                end
                            })

                            RageUI.Button('Réanimer le joueur ', nil, {}, true, {
                                onSelected = function()
                                    TriggerServerEvent("Lixzy:Revive", idtoreport)
                                end
                            })

                            break
                        end
                    end

                    if not foundPlayer then
                        -- Le joueur n'est pas connecté, afficher les infos du report
                        if Lixzy.SelectedReport then
                            RageUI.Separator("↓ ~r~INFORMATION ~s~↓")
                            RageUI.Button('ID : ~r~' .. (Lixzy.SelectedReport.id_source or "?"), nil, {}, true, {
                                onSelected = function() end
                            })
                            RageUI.Button('Nom : ~o~' .. (Lixzy.SelectedReport.name or "Inconnu"), nil, {}, true, {
                                onSelected = function() end
                            })
                            RageUI.Button('Raison : ~y~' .. (Lixzy.SelectedReport.reason or ""), nil, {}, true, {
                                onSelected = function() end
                            })
                        else
                            RageUI.Separator("Aucune information disponible")
                        end
                    end

                    -- Bouton pour afficher le message complet (si disponible)
                    if Lixzy.SelectedReport then
                        RageUI.Button('Voir le message complet', 'Afficher le message envoyé par l\'utilisateur', {}, true, {
                            onSelected = function()
                                ESX.ShowAdvancedNotification('REPORT', '~b~Message complet', Lixzy.SelectedReport.reason or 'Aucun message', 'CHAR_CHAT_CALL', 1)
                            end
                        })
                    end

                    RageUI.Separator("↓~r~ REPORT~s~ ↓")
                    RageUI.Button('~g~Report Réglée', nil, { }, true, {
                        onSelected = function()
                            -- CORRECTION: Envoyer l'ID du report (reportDbId) au lieu du source ID (idtoreport)
                            TriggerServerEvent("Lixzy:ReportRegle", reportDbId)
                            ESX.ShowNotification('~g~Report réglée et supprimée')
                            -- Attendre un peu pour que le serveur supprime le report
                            Citizen.Wait(300)
                            -- Rafraîchir la liste des reports
                            Lixzy.GetReport = Lixzy.Helper:GetReport()
                            -- Retourner au menu des reports
                            RageUI.GoBack()
                        end
                    }, reportmenu)
                end
            end)

            --test
            RageUI.IsVisible(playerActionMenu, function()
                RageUI.Separator("↓ ~r~INFORMATION ~s~↓")

                for i, v in pairs(Lixzy.Players) do
                    if v.source == Lixzy.SelectedPlayer.source then
                        local colors = {
                            ["_dev"] = '~u~DEV',
                            ["superadmin"] = '~y~FONDATEUR',
                            ["owner"] = '~y~OWNER',
                            ["manager"] = '~p~MANAGER',
                            ["admin"] = '~r~ADMIN',
                            ["mod"] = '~b~MODO',
                            ["support"] = '~g~SUPPORT',
                            ["user"] = 'USER',
                        }
                        RageUI.Button('Groupe : ' .. colors[v.group], nil, {}, true, {
                            onSelected = function()
                            end
                        })
                        RageUI.Button('Role : ~b~' .. v.group, nil, {}, true, {
                            onSelected = function()
                            end
                        })
                        RageUI.Button('ID : ~g~' .. v.source, nil, {}, true, {
                            onSelected = function()
                            end
                        })
                        RageUI.Button('Nom : ' .. v.name, nil, {}, true, {
                            onSelected = function()
                            end
                        })
                        RageUI.Button('Jobs : ' .. v.jobs, nil, {}, true, {
                            onSelected = function()
                            end
                        })
                        end
                    end

                RageUI.Separator("↓ ~r~TELEPORTATION~s~ ↓")

                RageUI.Button('Vous téléporté sur lui', nil, {}, true, {
                    
                    onSelected = function()
                        TriggerServerEvent('Lixzy:teleport', Lixzy.SelectedPlayer.source)
                    end
                })
                
                RageUI.Button('Téléporté vers vous', nil, {}, true, {
                    onSelected = function()
                        TriggerServerEvent('Lixzy:teleportTo', Lixzy.SelectedPlayer.source)
                    end
                })

                RageUI.Button('Le téléporté au Parking Central', nil, {}, true, {
                    onSelected = function()
                        TriggerServerEvent('Lixzy:teleportcoords', Lixzy.SelectedPlayer.source, vector3(215.76, -810.12, 30.73))
                    end
                })

                RageUI.Button('Le téléporté sur un toit', nil, {}, true, {
                    onSelected  = function()
                        TriggerServerEvent('Lixzy:teleporttoit', Lixzy.SelectedPlayer.source, vector3(-75.59, -818.07, 326.17))
                    end
                })

                RageUI.Separator("↓ ~r~JAIL~s~ ↓")

                RageUI.Button('Jail', nil, {}, true, {
                    onSelected  = function()
                        local time = KeyboardInput('Lixzy_BOX_JAIL', "Temps Jail (en minutes)", '', 50)
                        TriggerServerEvent('Lixzy:Jail', Lixzy.SelectedPlayer.source, time)
                    end
                })

                RageUI.Button('~r~Unjail', "~r~Perm~s~: ~n~admin, manager, owner, superadmin", {}, true, {
                    onSelected  = function()
                        TriggerServerEvent('Lixzy:UnJail', Lixzy.SelectedPlayer.source)
                    end
                })

                RageUI.Separator("↓ ~r~MODERATION~s~ ↓")


                RageUI.Button('Message', nil, {}, true, {
                    onSelected = function()
                        local reason = KeyboardInput('Lixzy_BOX_MESSAGE_RAISON', "Message", '', 100)
                        TriggerServerEvent('Lixzy:message', Lixzy.SelectedPlayer.source, reason)
                    end
                })


                RageUI.Button('Clear inventaire', "~r~Perm~s~: ~n~admin, manager, owner, superadmin", {}, true, {
                    onSelected = function()
                        TriggerServerEvent('Lixzy:clearInv', Lixzy.SelectedPlayer.source)
                    end
                })

                RageUI.Button('Clear armes', "~r~Perm~s~: ~n~admin, manager, owner, superadmin", {}, true, {
                    onSelected = function()
                        TriggerServerEvent('Lixzy:clearLoadout', Lixzy.SelectedPlayer.source)
                    end
                })

                RageUI.Button('Wipe', "~r~Perm~s~: ~n~superadmin", {}, true, {
                    onSelected = function()
                        TriggerServerEvent('Lixzy:WipePlayer', Lixzy.SelectedPlayer.source)
                    end
                })
                

                RageUI.Separator("↓ ~r~PERSONNAGE~s~ ↓")

                RageUI.Button('Revive', nil, {}, true, {
                    onSelected = function()
                        ESX.ShowNotification("~r~Revive du joueur en cours...")
                        TriggerServerEvent("Lixzy:Revive", Lixzy.SelectedPlayer.source)
                    end
                })

                RageUI.Button('Prendre Carte d\'identité', nil, {}, true, {
                    onSelected = function()
                        ESX.ShowNotification("~b~Carte d\'identité en cours...")
                        TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId(Lixzy.SelectedPlayer.source)), GetPlayerServerId(PlayerId()));
                    end
                })

                RageUI.Separator("↓ ~r~SANCTION~s~ ↓")

                RageUI.Button('~g~Kick le joueur', nil, {}, true, {
                    onSelected = function()
                        selectedMenu:SetSubtitle(string.format('Kick le joueur'))
                        idtosanctionbaby = Lixzy.SelectedPlayer.source
                        selectedIndex = 4;
                    end
                }, selectedMenu)
                RageUI.Button('~r~Bannir', "Bannir le joueur (utilise l'ID cible)", {}, true, {
                    onSelected = function()
                        local days = KeyboardInput('Lixzy_BOX_BAN_RAISON',"Durée du banissement (en heures)", "", 20, true)
                        if days ~= nil then
                            local reason = KeyboardInput('Lixzy_BOX_BAN_RAISON',"Raison", "", 80, false)
                            if reason ~= nil then
                                ESX.ShowNotification("~y~Application de la sanction en cours...")
                                TriggerServerEvent('Lixzy:BanPlayer', Lixzy.SelectedPlayer.source, tonumber(days) or 0, reason)
                            end
                        end
                    end
                }, playerActionMenu)
            end)
            RageUI.IsVisible(reportmenu, function()
                for i, v in pairs(Lixzy.GetReport) do
                    if i == 0 then
                        return
                    end
                    RageUI.Button("[~r~" .. v.id .. "~s~] " .. v.name, "ID : ~r~" .. v.id .. "~s~\n" .. "Name : ~b~" .. v.name .. "~s~\nRaison :~n~~u~ " .. v.reason, {}, true, {
                        onSelected = function()
                            selectedMenu:SetSubtitle(string.format('Report'))
                            kvdureport = i
                            idtoreport = v.id_source
                            reportDbId = v.id -- CORRECTION: Stocker l'ID du report dans la DB
                            Lixzy.SelectedReport = v -- Stocker l'objet report sélectionné pour usage ultérieur
                            selectedIndex = 6;
                        end
                    }, selectedMenu)
                end
            end)
        end
        for i, onTick in pairs(Lixzy.Menus) do
            onTick();
        end
    end

end)



-- NOTE: client cannot call GetPlayerIdentifiers reliably; use server callback to check license mapping
-- Request custom outfits (if `tenuestaff/outfits.json` exists in that resource)
TriggerServerEvent('Lixzy:RequestOutfits')

-- when the player loads, initialize staff features based on DB group only
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)

    local isStaff = (xPlayer.group == "support"
        or xPlayer.group == "mod"
        or xPlayer.group == "admin"
        or xPlayer.group == "manager"
        or xPlayer.group == "owner"
        or xPlayer.group == "superadmin")

    -- print debug supprimé

    if isStaff then
        local lastToggle = 0

        Keys.Register('F10', 'F10', 'Menu RevoPvP', function()
            local now = GetGameTimer()
            if (now - lastToggle) > 300 then
                lastToggle = now
                TriggerServerEvent("Lixzy:ouvrirmenu1")
            end
        end)

        Keys.Register('F11', 'F11', 'Report RevoPvP', function()
            local now = GetGameTimer()
            if (now - lastToggle) > 300 then
                lastToggle = now
                TriggerServerEvent("Lixzy:ouvrirmenu2")
            end
        end)

        Lixzy.PlayersStaff = Lixzy.Helper:OnGetStaffPlayers()
        Lixzy.GetReport = Lixzy.Helper:GetReport()
    end

    -- notify server that client is fully loaded so server can perform a final ban check (fallback for race conditions)
    TriggerServerEvent('Lixzy:CheckBanOnLoaded')

end)

-- debug client command to check group-based staff status
RegisterCommand('checkstaff', function()
    local group = ESX.GetPlayerData().group or 'user'
    if group ~= 'user' then
        ESX.ShowNotification(('~g~Vous êtes staff: %s'):format(tostring(group)))
    else
        ESX.ShowNotification('~r~Aucun statut staff pour votre compte.')
    end
end, false)
-- print debug supprimé

-- Receive outfits from server if provided and merge into Config.GroupOutfits
RegisterNetEvent('Lixzy:LoadGroupOutfits')
AddEventHandler('Lixzy:LoadGroupOutfits', function(outfits)
    if type(outfits) == 'table' then
        Config = Config or {}
        Config.GroupOutfits = Config.GroupOutfits or {}
        for k,v in pairs(outfits) do
            Config.GroupOutfits[k] = v
        end
        -- print debug supprimé
    end
end)

local function getEntity(player)
    -- function To Get Entity Player Is Aiming At
    local _, entity = GetEntityPlayerIsFreeAimingAt(player)
    return entity
end

local function aimCheck(player)
    -- function to check config value onAim. If it's off, then
    return IsPedShooting(player)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        if (Lixzy.SelfPlayer.isStaffEnabled) then
            if (Lixzy.SelfPlayer.isDelgunEnabled) then
                if IsPlayerFreeAiming(PlayerId()) then
                    local entity = getEntity(PlayerId())
                    local entityType = GetEntityType(entity)
                    if entityType == 2 or entityType == 3 then
                        if aimCheck(GetPlayerPed(-1)) then
                            SetEntityAsMissionEntity(entity, true, true)
                            DeleteEntity(entity)
                        end
                    end
                end
            end

            if (Lixzy.SelfPlayer.isRevogunEnabled) then
                if IsPlayerFreeAiming(PlayerId()) then
                    local entity = getEntity(PlayerId())
                    if entity and entity ~= 0 then
                        local px,py,pz = table.unpack(GetEntityCoords(PlayerPedId()))
                        local ex,ey,ez = table.unpack(GetEntityCoords(entity))
                        DrawLine(px,py,pz, ex,ey,ez, 255, 0, 0, 255)
                        if aimCheck(GetPlayerPed(-1)) then
                            if IsEntityAPed(entity) then
                                for _, pid in ipairs(GetActivePlayers()) do
                                    if GetPlayerPed(pid) == entity then
                                        local serverId = GetPlayerServerId(pid)
                                        local found = false
                                        for _, v in pairs(Lixzy.Players) do
                                            if tonumber(v.source) == tonumber(serverId) then
                                                Lixzy.SelectedPlayer = v
                                                playerActionMenu:SetSubtitle(string.format('[%s] %s', v.source, v.name))
                                                RageUI.Visible(playerActionMenu, true)
                                                found = true
                                                break
                                            end
                                        end
                                        if not found then
                                            local temp = { source = serverId, name = GetPlayerName(pid) }
                                            Lixzy.SelectedPlayer = temp
                                            playerActionMenu:SetSubtitle(string.format('[%s] %s', serverId, GetPlayerName(pid)))
                                            RageUI.Visible(playerActionMenu, true)
                                        end
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if (Lixzy.SelfPlayer.isClipping) then
                local camCoords = GetCamCoord(NoClip.Camera)
                local right, forward, _, _ = GetCamMatrix(NoClip.Camera)
                if IsControlPressed(0, 32) then
                    local newCamPos = camCoords + forward * NoClip.Speed
                    SetCamCoord(NoClip.Camera, newCamPos.x, newCamPos.y, newCamPos.z)
                end
                if IsControlPressed(0, 8) then
                    local newCamPos = camCoords + forward * -NoClip.Speed
                    SetCamCoord(NoClip.Camera, newCamPos.x, newCamPos.y, newCamPos.z)
                end
                if IsControlPressed(0, 34) then
                    local newCamPos = camCoords + right * -NoClip.Speed
                    SetCamCoord(NoClip.Camera, newCamPos.x, newCamPos.y, newCamPos.z)
                end
                if IsControlPressed(0, 9) then
                    local newCamPos = camCoords + right * NoClip.Speed
                    SetCamCoord(NoClip.Camera, newCamPos.x, newCamPos.y, newCamPos.z)
                end
                if IsControlPressed(0, 334) then
                    if (NoClip.Speed - 0.1 >= 0.1) then
                        NoClip.Speed = NoClip.Speed - 0.1
                    end
                end
                if IsControlPressed(0, 335) then
                    if (NoClip.Speed + 0.1 >= 0.1) then
                        NoClip.Speed = NoClip.Speed + 0.1
                    end
                end

                local pedZ = camCoords.z
                local foundZ, groundZ = GetGroundZFor_3dCoord(camCoords.x, camCoords.y, camCoords.z + 2.0, 0)
                if foundZ and groundZ and pedZ < groundZ - 2.0 then
                    pedZ = groundZ + 1.0
                end
                SetEntityCoords(Lixzy.SelfPlayer.ped, camCoords.x, camCoords.y, pedZ)

                local xMagnitude = GetDisabledControlNormal(0, 1)
                local yMagnitude = GetDisabledControlNormal(0, 2)
                local camRot = GetCamRot(NoClip.Camera)
                local x = camRot.x - yMagnitude * 10
                local y = camRot.y
                local z = camRot.z - xMagnitude * 10
                if x < -75.0 then
                    x = -75.0
                end
                if x > 100.0 then
                    x = 100.0
                end
                SetCamRot(NoClip.Camera, x, y, z)
            end

            if (Lixzy.SelfPlayer.isGamerTagEnabled) then
                for i, v in pairs(Lixzy.GamerTags) do
                    local target = GetEntityCoords(v.ped, false)
                    if #(target - GetEntityCoords(PlayerPedId())) < 120 then
                        SetMpGamerTagVisibility(v.tags, 0, true)
                        SetMpGamerTagVisibility(v.tags, 2, true)
                        SetMpGamerTagVisibility(v.tags, 4, NetworkIsPlayerTalking(v.player))
                        SetMpGamerTagAlpha(v.tags, 2, 255)
                        SetMpGamerTagAlpha(v.tags, 4, 255)

                        -- CORRECTION: Couleurs par groupe
                        local colors = {
                            ["_dev"] = 21,        -- Violet
                            ["superadmin"] = 5,   -- Jaune
                            ["owner"] = 5,        -- Jaune
                            ["manager"] = 27,     -- Rose/Purple
                            ["admin"] = 6,        -- Rouge
                            ["mod"] = 3,          -- Bleu
                            ["support"] = 2,      -- Vert
                            ["user"] = 0,         -- Blanc
                        }
                        SetMpGamerTagColour(v.tags, 0, colors[v.group] or 0)
                    else
                        RemoveMpGamerTag(v.tags)
                        Lixzy.GamerTags[i] = nil
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Lixzy.SelfPlayer.ped = GetPlayerPed(-1);
        if (Lixzy.SelfPlayer.isStaffEnabled) then
            if (Lixzy.SelfPlayer.isGamerTagEnabled) then
                Lixzy.Helper:OnRequestGamerTags();
            end
        end

        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(50)
        if (Lixzy.SelfPlayer.isCarParticleEnabled) then
            local ped = PlayerPedId()
            local car = GetVehiclePedIsIn(ped, false);
            local dics = ParticleList[CarParticleIndex].Value[1];
            local name = ParticleList[CarParticleIndex].Value[2];

            if (car) then
                local wheel_lf = GetEntityBoneIndexByName(car, 'wheel_lf')
                local wheel_lr = GetEntityBoneIndexByName(car, 'wheel_lr')
                local wheel_rf = GetEntityBoneIndexByName(car, 'wheel_rf')
                local wheel_rr = GetEntityBoneIndexByName(car, 'wheel_rr')
                if (wheel_lf) then
                    Lixzy.Helper:NetworkedParticleFx(dics, name, car, wheel_lf, 1.0)
                end
                if (wheel_lr) then
                    Lixzy.Helper:NetworkedParticleFx(dics, name, car, wheel_lr, 1.0)
                end
                if (wheel_rf) then
                    Lixzy.Helper:NetworkedParticleFx(dics, name, car, wheel_rf, 1.0)
                end
                if (wheel_rr) then
                    Lixzy.Helper:NetworkedParticleFx(dics, name, car, wheel_rr, 1.0)
                end
                SetVehicleFixed(car)
                SetVehicleDirtLevel(car, 0.0)
                SetPlayerInvincible(ped, true)
            end
        end
    end
end)

RegisterNetEvent('Lixzy:setGroup')
AddEventHandler('Lixzy:setGroup', function(group, lastGroup)
    player.group = group
end)

RegisterNetEvent('Lixzy:teleport')
AddEventHandler('Lixzy:teleport', function(coords)
    if (Lixzy.SelfPlayer.isClipping) then
        SetCamCoord(NoClip.Camera, coords.x, coords.y, coords.z)
        SetEntityCoords(Lixzy.SelfPlayer.ped, coords.x, coords.y, coords.z)
    else
        ESX.Game.Teleport(PlayerPedId(), coords)
    end
end)

RegisterNetEvent('Lixzy:spawnVehicle')
AddEventHandler('Lixzy:spawnVehicle', function(model)
    if (Lixzy.SelfPlayer.isStaffEnabled) then
        model = (type(model) == 'number' and model or GetHashKey(model))

        if IsModelInCdimage(model) then
            local playerPed = PlayerPedId()
            local plyCoords = GetEntityCoords(playerPed)

            ESX.Game.SpawnVehicle(model, plyCoords, 90.0, function(vehicle)
                TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
            end)
        else
            Visual.Subtitle('Invalid vehicle model.', 5000)
        end
    end
end)

local disPlayerNames = 5
local playerDistances = {}

local function DrawText3D(x, y, z, text, r, g, b)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = #(vector3(px, py, pz) - vector3(x, y, z))

    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov

    if onScreen then
        if not useCustomScale then
           
            SetTextScale(0.0 * scale, 0.55 * scale)
        else
            SetTextScale(0.0 * scale, customScale)
        end
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
        DrawText(_x, _y)
    end
end

Citizen.CreateThread(function()
    Wait(500)
    while true do
        if (Lixzy.SelfPlayer.isGamerTagEnabled) then
            for _, id in ipairs(GetActivePlayers()) do
                if playerDistances[id] then
                    if (playerDistances[id] < disPlayerNames) then
                        local x2, y2, z2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
                        
                        -- Récupérer les infos du joueur pour avoir sa couleur
                        local serverId = GetPlayerServerId(id)
                        local playerData = Lixzy.Helper:RetrievePlayersDataByID(serverId)
                        local r, g, b = 255, 255, 255  -- Blanc par défaut
                        
                        if playerData then
                            -- Définir les couleurs RGB selon le groupe
                            local groupColors = {
                                ["_dev"] = {128, 0, 255},      -- Violet
                                ["superadmin"] = {255, 255, 0}, -- Jaune
                                ["owner"] = {255, 255, 0},      -- Jaune
                                ["manager"] = {255, 0, 255},    -- Rose
                                ["admin"] = {255, 0, 0},        -- Rouge
                                ["mod"] = {0, 100, 255},        -- Bleu
                                ["support"] = {0, 255, 0},      -- Vert
                                ["user"] = {255, 255, 255},     -- Blanc
                            }
                            local color = groupColors[playerData.group] or {255, 255, 255}
                            r, g, b = color[1], color[2], color[3]
                        end
                        
                        if NetworkIsPlayerTalking(id) then
                            DrawText3D(x2, y2, z2 + 1, serverId, 130, 100, 255)
                            DrawMarker(23, x2, y2, z2 - 0.97, 0, 0, 0, 0, 0, 0, 1.001, 1.0001, 0.5001, 130, 100, 225, 255, 0, 0, 0, 0)
                        else
                            DrawText3D(x2, y2, z2 + 1, serverId, r, g, b)
                        end
                    elseif (playerDistances[id] < 25) then
                        local x2, y2, z2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
                        if NetworkIsPlayerTalking(id) then
                            DrawMarker(23, x2, y2, z2 - 0.97, 0, 0, 0, 0, 0, 0, 1.001, 1.0001, 0.5001, 130, 100, 225, 255, 0, 0, 0, 0)
                        end
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if (Lixzy.SelfPlayer.isGamerTagEnabled) then
            for _, id in ipairs(GetActivePlayers()) do

                x1, y1, z1 = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
                x2, y2, z2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
                distance = math.floor(#(vector3(x1, y1, z1) - vector3(x2, y2, z2)))
                playerDistances[id] = distance
            end
        end
    end
end)

-- Objets --

function spawnObject(name)
	local plyPed = PlayerPedId()
	local coords = GetEntityCoords(plyPed, false) + (GetEntityForwardVector(plyPed) * 0.5)

	ESX.Game.SpawnObject(name, coords, function(obj)
		SetEntityHeading(obj, GetEntityPhysicsHeading(plyPed))
		PlaceObjectOnGroundProperly(obj)
	end)
end


-- JAIL ------------

local IsJailed = false
local unjail = false
local JailTime = 0
local fastTimer = 0
local JailLocation = Config.JailLocation


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx_jailer:jail')
AddEventHandler('esx_jailer:jail', function(jailTime)
	if IsJailed then 
		return
	end

	JailTime = jailTime
	local sourcePed = GetPlayerPed(-1)
	if DoesEntityExist(sourcePed) then
		Citizen.CreateThread(function()

			-- Clear player
			SetPedArmour(sourcePed, 0)
			ClearPedBloodDamage(sourcePed)
			ResetPedVisibleDamage(sourcePed)
			--ClearPedLastWeaponDamage(sourcePed)
			ResetPedMovementClipset(sourcePed, 0)
			
			SetEntityCoords(sourcePed, JailLocation.x, JailLocation.y, JailLocation.z)
			IsJailed = true
			unjail = false
			while JailTime > 0 and not unjail do
				sourcePed = GetPlayerPed(-1)
				--RemoveAllPedWeapons(sourcePed, false)
				if IsPedInAnyVehicle(sourcePed, false) then
					ClearPedTasksImmediately(sourcePed)
				end

				if JailTime % 120 == 0 then
					TriggerServerEvent('esx_jailer:updateRemaining', JailTime)
				end

				Citizen.Wait(20000)

				-- Is the player trying to escape?
				if GetDistanceBetweenCoords(GetEntityCoords(sourcePed), JailLocation.x, JailLocation.y, JailLocation.z) > 10 then
					SetEntityCoords(sourcePed, JailLocation.x, JailLocation.y, JailLocation.z)
				end
				
				JailTime = JailTime - 20
			end

			-- jail time 
			TriggerServerEvent('esx_jailer:unjailTime', -1)
			SetEntityCoords(sourcePed, Config.JailBlip.x, Config.JailBlip.y, Config.JailBlip.z)
			IsJailed = false

			-- Change back the user skin
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
				TriggerEvent('skinchanger:loadSkin', skin)
			end)
		end)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)

		if JailTime > 0 and IsJailed then
			if fastTimer < 0 then
				fastTimer = JailTime
			end
			draw2dText(("il reste ~r~%s~s~ secondes jusqu’à ce que vous êtes libéré de ~r~prison"):format(ESX.Round(fastTimer)), { 0.390, 0.955 } )
			fastTimer = fastTimer - 0.01
		else
			Citizen.Wait(1000)
		end
	end
end)

RegisterNetEvent('esx_jailer:unjail')
AddEventHandler('esx_jailer:unjail', function(source)
	unjail = true
	JailTime = 0
	fastTimer = 0
end)

-- When player respawns / joins
AddEventHandler('playerSpawned', function(spawn)
	if IsJailed then
		SetEntityCoords(GetPlayerPed(-1), JailLocation.x, JailLocation.y, JailLocation.z)
	else
		TriggerServerEvent('esx_jailer:checkJail')
	end
end)




-- When script starts
Citizen.CreateThread(function()
	Citizen.Wait(2000) -- wait for mysql-async to be ready, this should be enough time
	TriggerServerEvent('esx_jailer:checkJail')
end)


function draw2dText(text, pos)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextScale(0.45, 0.45)
	SetTextColour(255, 255, 255, 255)
	SetTextDropShadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()

	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(table.unpack(pos))
end