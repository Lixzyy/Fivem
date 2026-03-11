
-- UI, markers and progress bar

local drawProgress = false
local progressStart, progressDuration = 0, 0

function UI_Draw3DText(coords, text)
    local onScreen,_x,_y = World3dToScreen2d(coords.x, coords.y, coords.z)
    local camCoords = GetGameplayCamCoords()
    local dist = #(coords - camCoords)

    local scale = (1 / dist) * 2.0
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    if onScreen then
        SetTextScale(0.35 * scale, 0.35 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextCentre(1)
        BeginTextCommandDisplayText('STRING')
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(_x, _y)
    end
end

function UI_DrawMarker(coords)
    if not Config.Crate.marker.enabled then return end
    DrawMarker(
        Config.Crate.marker.type,
        coords.x, coords.y, coords.z + 0.5,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        Config.Crate.marker.scale.x,
        Config.Crate.marker.scale.y,
        Config.Crate.marker.scale.z,
        Config.Crate.marker.color.r,
        Config.Crate.marker.color.g,
        Config.Crate.marker.color.b,
        Config.Crate.marker.color.a,
        false, true, 2, false, nil, nil, false
    )
end

function UI_ShowProgress(seconds, label)
    drawProgress = true
    progressStart = GetGameTimer()
    progressDuration = seconds * 1000
    Citizen.CreateThread(function()
        while drawProgress do
            Citizen.Wait(0)
            local now = GetGameTimer()
            local pct = math.min(1.0, (now - progressStart) / progressDuration)

            local sw, sh = 0.23, 0.025
            local x, y = 0.5, 0.88
            DrawRect(x, y, sw, sh, 0, 0, 0, 180)
            DrawRect(x - sw/2 + (sw * pct)/2, y, sw * pct, sh - 0.006, 200, 0, 0, 220)

            SetTextFont(4)
            SetTextScale(0.35, 0.35)
            SetTextCentre(true)
            SetTextColour(255,255,255,255)
            BeginTextCommandDisplayText('STRING')
            AddTextComponentSubstringPlayerName(label or 'Ouverture du colis...')
            EndTextCommandDisplayText(x, y - 0.015)

            if pct >= 1.0 then
                drawProgress = false
            end
        end
    end)
end

function UI_HideProgress()
    drawProgress = false
end

