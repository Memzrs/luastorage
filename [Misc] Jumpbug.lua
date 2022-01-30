-- Jump bug assist for Counter-Strike: Global Offensive, by nicole
-- Libraries
local trace = require "gamesense/trace"
local vector = require "vector"

-- Localized functions
local bit_band, ui_get, entity_get_prop, entity_get_local_player, entity_get_origin, globals_tickinterval, globals_tickcount, renderer_indicator = bit.band, ui.get, entity.get_prop, entity.get_local_player, entity.get_origin, globals.tickinterval, globals.tickcount, renderer.indicator

-- Other definitions
local virtual_key_e =
{
    xbutton2 = 6
}

local flags_e =
{
    onground = bit.lshift(1, 0)
}

local contents_e =
{
    solid = bit.lshift(1, 0),
    window = bit.lshift(1, 1),
    grate = bit.lshift(1, 3),
    moveable = bit.lshift(1, 14),
    playerclip = bit.lshift(1, 16),
    monster = bit.lshift(1, 25)
}

local masks_e =
{
    player_solid = bit.bor(contents_e.solid, contents_e.moveable, contents_e.playerclip, contents_e.window, contents_e.monster, contents_e.grate)
}

local JUMPBUG_TICKS_TO_UNCROUCH = 2 -- Arbitrary number. This is the amount of ticks we need to stay uncrouched prior to hitting the ground. Works fine from my testing on 128 tickrate.
local JUMPBUG_TICKS_STAY_UNCROUCHED = 5

-- Globals
local g_pJumpBugEnabled = ui.new_checkbox("MISC", "Movement", "Jump bug")
local g_pJumpBugHotkey = ui.new_hotkey("MISC", "Movement", "Jump bug", true, virtual_key_e.xbutton2)
local g_pJumpBugColorLabel = ui.new_label("MISC", "Movement", "Indicator color")
local g_pJumpBugColor = ui.new_color_picker("MISC", "Movement", "Indicator color", 255, 255, 255, 255)
local g_nLastJumpBugTick = nil
local g_bInAction = false

-- p100 function naming owo
local function extrapolate_pos_with_velocity_by_ticks(pos, vel, ticks)
    local vecFinalPosition = pos:scaled(1) -- copy pos to vecFinalPosition
    local flTickInterval = globals_tickinterval()

    vecFinalPosition.x = vecFinalPosition.x + (vel.x * flTickInterval * ticks)
    vecFinalPosition.y = vecFinalPosition.y + (vel.y * flTickInterval * ticks)
    vecFinalPosition.z = vecFinalPosition.z + (vel.z * flTickInterval * ticks)

    return vecFinalPosition
end

local function on_level_init()
   g_nLastJumpBugTick = nil
end

local function on_setup_command(cmd)
    if not ui_get(g_pJumpBugHotkey) then
        g_bInAction = false

        return
    end

    local nLocalPlayer = entity_get_local_player()
    local vecVelocity = vector(entity_get_prop(nLocalPlayer, "m_vecVelocity"))
    local nTickCount = globals_tickcount()

    -- Don't do anything when we are on ground
    if bit_band(entity_get_prop(nLocalPlayer, "m_fFlags"), flags_e.onground) > 0 or (g_nLastJumpBugTick ~= nil and nTickCount - g_nLastJumpBugTick < JUMPBUG_TICKS_STAY_UNCROUCHED) then
        cmd.in_duck = false
        g_bInAction = false

        return
    end

    g_bInAction = true

    local vecOrigin = vector(entity_get_origin(nLocalPlayer))
    local vecOriginExtrapolated = extrapolate_pos_with_velocity_by_ticks(vecOrigin, vecVelocity, JUMPBUG_TICKS_TO_UNCROUCH)

    local vecMins = vector(entity_get_prop(nLocalPlayer, "m_vecMins"))
    local vecMaxs = vector(entity_get_prop(nLocalPlayer, "m_vecMaxs"))

    -- https://github.com/momentum-mod/game/blob/616464affecfec0485439d5acd7ea7a7186006dd/mp/src/game/shared/momentum/mom_gamemovement.cpp#L3362
    local pTraceHull = trace.hull(vecOrigin, vecOriginExtrapolated, vecMins, vecMaxs, { skip = nLocalPlayer, mask = masks_e.player_solid })

    if bit_band(pTraceHull.contents, masks_e.player_solid) > 0 then
        cmd.in_duck = false
        g_nLastJumpBugTick = nTickCount
    else
        cmd.in_duck = true
    end
end

local function on_paint()
    if not g_bInAction then
        return
    end

    local nRed, nGreen, nBlue, nAlpha = ui_get(g_pJumpBugColor)

    if nAlpha > 0 then
        renderer_indicator(nRed, nGreen, nBlue, nAlpha, "JB")
    end
end

local function on_ui_callback(ref)
    local bEnabled = ui.get(ref)
    local pfnFunc = bEnabled and client.set_event_callback or client.unset_event_callback
    pfnFunc("level_init", on_level_init)
    pfnFunc("setup_command", on_setup_command)
    pfnFunc("paint", on_paint)

    ui.set_visible(g_pJumpBugColorLabel, bEnabled)
    ui.set_visible(g_pJumpBugColor, bEnabled)
end

ui.set_callback(g_pJumpBugEnabled, on_ui_callback)