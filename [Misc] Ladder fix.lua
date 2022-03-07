local entity_get_prop = entity.get_prop
local key_state = client.key_state
local ui_get = ui.get
local client_camera_angles = client.camera_angles
local fast_ladder = ui.new_multiselect("MISC", "Movement", "Fast ladder", "Ascending", "Descending")
local ladder_yaw180 = ui.new_checkbox("AA", "Anti-aimbot angles", "Ladder yaw 180")

local function contains(tbl, val) 
    for i=1, #tbl do
        if tbl[i] == val then return true end 
    end 
    return false 
end

client.set_event_callback("setup_command", function(e)
    local local_player = entity.get_local_player()
    local pitch, yaw = client_camera_angles()
    if entity_get_prop(local_player, "m_MoveType") == 9 then
        e.roll = 0
        if ui_get(ladder_yaw180) then
            if not key_state(0x57) and not key_state(0x53) then
                if key_state(0x41) or key_state(0x44) then
                    e.pitch = 89
                    e.yaw = e.yaw + 180
                    if key_state(0x41) and not key_state(0x44) then
                        e.in_moveleft = 0
                        e.in_moveright = 1
                    end
                    if key_state(0x44) and not key_state(0x41) then
                        e.in_moveleft = 1
                        e.in_moveright = 0
                    end
                end
            end
        end

        if contains(ui_get(fast_ladder), "Ascending") then
            if key_state(0x57) and not key_state(0x53) then
                e.pitch = 89
                if pitch < 45 then
                    e.in_moveright = 1
                    e.in_moveleft = 0
                    e.in_forward = 0
                    e.in_back = 1
                    if not key_state(0x41) and not key_state(0x44) then
                        e.yaw = e.yaw + 90
                    end
                    if key_state(0x41) and not key_state(0x44) then
                        e.yaw = e.yaw + 150
                    end
                    if not key_state(0x41) and key_state(0x44) then
                        e.yaw = e.yaw + 30
                    end
                end 
            end
        end
        if contains(ui_get(fast_ladder), "Descending") then
            if key_state(0x53) and not key_state(0x57) or key_state(0x57) and pitch >= 45 and not key_state(0x53) then
                e.pitch = 89
                e.in_moveleft = 1
                e.in_moveright = 0
                e.in_forward = 1
                e.in_back = 0
                if not key_state(0x41) and not key_state(0x44) then
                    e.yaw = e.yaw + 90
                end
                if not key_state(0x41) and key_state(0x44) then
                    e.yaw = e.yaw + 150
                end
                if key_state(0x41) and not key_state(0x44) then
                    e.yaw = e.yaw + 30
                end
            end
        end
    end
end)