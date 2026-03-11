
-- Visual & audio effects for the airdrop

Effects = {}

local redSmokeFx = nil

function Effects.StartRedSmokeAt(coords)
    if not Config.Effects.redSmoke then return end
    UseParticleFxAssetNextCall('core')
    local fx = StartParticleFxLoopedAtCoord('exp_grd_grenade_smoke', coords.x, coords.y, coords.z + 0.2, 0.0, 0.0, 0.0, 1.8, false, false, false, false)
    SetParticleFxLoopedColour(fx, 1.0, 0.0, 0.0) -- red
    redSmokeFx = fx
end

function Effects.StopRedSmoke()
    if redSmokeFx then
        StopParticleFxLooped(redSmokeFx, 0)
        redSmokeFx = nil
    end
end

function Effects.PlayCrateLandSound(entity)
    if not Config.Effects.crateLandingSound then return end
    PlaySoundFromEntity(-1, 'CHECKPOINT_NORMAL', entity, 'HUD_MINI_GAME_SOUNDSET', false, 0)
end

function Effects.PlayPlaneEngine(plane)
    if not Config.Effects.planeEngineSound then return end
    -- Attempt a few common aviation loop sounds, harmless if missing
    local tried = false
    tried = PlaySoundFromEntity(-1, 'Plane_In_Dist', plane, 'BASEJUMPS_SOUNDS', false, 0)
    if not tried then
        PlaySoundFromEntity(-1, 'DLC_AW_DETONATE', plane, 'DLC_AW_Frontend_Sounds', false, 0)
    end
end
