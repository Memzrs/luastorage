-- local variables for API functions. any changes to the line below will be lost on re-generation
local client_userid_to_entindex, entity_get_local_player, entity_get_player_name, entity_hitbox_position, globals_curtime, math_max, math_min, renderer_text, renderer_world_to_screen, table_insert, table_remove, ui_get, ui_set_visible, client_set_event_callback, client_unset_event_callback, math_sin= client.userid_to_entindex, entity.get_local_player, entity.get_player_name, entity.hitbox_position, globals.curtime, math.max, math.min, renderer.text, renderer.world_to_screen, table.insert, table.remove, ui.get, ui.set_visible, client.set_event_callback, client.unset_event_callback, math.sin

--menu references
local menu = {
    enabled = ui.new_checkbox("VISUALS", "Effects", "Floating damage"),
    hide = ui.new_checkbox("VISUALS", "Effects", "Show options"),
    flags = ui.new_combobox("VISUALS", "Effects", "\nDamage text", "Bold", "Large", "Medium", "Small"),
    color = ui.new_color_picker("VISUALS", "Effects", "Damage color", 0, 255, 0, 255),
    time = ui.new_slider("VISUALS", "Effects", "Fade", 1, 100, 20, true, "s", 0.1),
    distance = ui.new_slider("VISUALS", "Effects", "\nFade distance", 3, 128, 16, true, "u", 1, {[3] = "Static"}),
    clip = ui.new_slider("VISUALS", "Effects", "Clip", 1, 11, 11, true, nil, 1, {[11] = "∞"}),
    squiggle = ui.new_checkbox("VISUALS", "Effects", "Squiggle")
}

--variables
local r, g, b, a = 0, 0, 0, 0
local time = 2
local distance = 16
local flags = ""
local clip = 1
local should_squiggle = true
local render_custom = renderer_text
local cb_to_flags = {
    ["Bold"] = "cb",
    ["Large"] = "c+",
    ["Medium"] = "c",
    ["Small"] = "c-"
}

local hitgroup_to_hitbox = {
    [0] = 0,
    [1] = 0,
    [2] = 3,
    [3] = 2,
    [4] = 13,
    [5] = 14,
    [6] = 11,
    [7] = 12,
    [10] = 0
}

local shots = {}

--callback events
local function push_hurt(event)
    if client_userid_to_entindex(event.attacker) == entity_get_local_player() then 
        local target = client_userid_to_entindex(event.userid)
        table_insert(shots, 
        { 
            event.dmg_health, 
            globals_curtime(), 
            entity_get_player_name(target),
            { entity_hitbox_position(target, hitgroup_to_hitbox[event.hitgroup]) },
        })

        if #shots > clip then 
            table_remove(shots, 1)
        end
    end
end

local function on_level_init()
    shots = {}
end

local function squiggler(x, y, a_mod, cur_shot)
    renderer_text(x-2+(math_sin((globals_curtime()-cur_shot[2])*4)*4), y, r, g, b, a * a_mod, flags, 0, cur_shot[1])
end

local function straight(x, y, a_mod, cur_shot)
    renderer_text(x-2, y, r, g, b, a * a_mod, flags, 0, cur_shot[1])
end

local function render_hitmarkers(ctx)
    render_custom = should_squiggle and squiggler or straight
    local removeindex = {}
    for i = 1, #shots do 
        local cur_shot = shots[i]
        if cur_shot == nil then return end
        local a_mod = math_max(math_min(1, (0 - ((globals_curtime() - cur_shot[2]) - time) / time)), 0)
        if a_mod == 0 then 
            removeindex[#removeindex+1] = i
        else 
            local x, y = renderer_world_to_screen(cur_shot[4][1], cur_shot[4][2], cur_shot[4][3]+distance+16-(distance*a_mod))
            if x ~= nil then 
                render_custom(x, y, a_mod, cur_shot)
            end
        end
    end

    for i = 1, #removeindex do 
        table_remove(shots, removeindex[i])
    end
end

local function visibility()
    local state = ui_get(menu.enabled)
    ui_set_visible(menu.hide, state)
    state = (ui_get(menu.hide) and state) and state or false
    ui_set_visible(menu.color, state)
    ui_set_visible(menu.flags, state)
    ui_set_visible(menu.time, state)
    ui_set_visible(menu.distance, state)
    ui_set_visible(menu.clip, state)
    ui_set_visible(menu.squiggle, state)
end

local function on_script_toggle(self)
    local state = ui_get(self)
    local update_callback = state and client_set_event_callback or client_unset_event_callback
    update_callback("paint", render_hitmarkers)
    update_callback("level_init", on_level_init)
    update_callback("player_hurt", push_hurt)
    visibility()
    shots = {}
end

--init
do 
    ui.set_callback(menu.enabled, on_script_toggle)
    ui.set_callback(menu.hide, visibility)

    ui.set_callback(menu.color, function(self) 
        r, g, b, a = ui_get(self) 
    end) 
    r, g, b, a = ui_get(menu.color)

    ui.set_callback(menu.flags, function(self) 
        flags = cb_to_flags[ui_get(self)] 
    end) 
    flags = cb_to_flags[ui_get(menu.flags)]

    ui.set_callback(menu.time, function(self) 
        time = ui_get(self)*0.1 
    end) 
    time = ui_get(menu.time)*0.1

    ui.set_callback(menu.distance, function(self) 
        local slider = ui_get(self) 
        distance = (slider == 3) and 0 or slider 
    end) 
    local slider = ui_get(menu.distance) 
    distance = (slider == 3) and 0 or slider

    ui.set_callback(menu.clip, function(self)
        local clip_c = ui_get(self)
        clip = (clip_c == 11) and 1000 or clip_c

        for i = 1, (#shots-clip) do 
            table_remove(shots, 1)
        end
    end)
    local clip_c = ui_get(menu.clip)
    clip = (clip_c == 11) and 1000 or clip_c

    ui.set_callback(menu.squiggle, function(self)
        should_squiggle = ui.get(self)
    end)
    should_squiggle = ui.get(menu.squiggle)

    on_script_toggle(menu.enabled)
end