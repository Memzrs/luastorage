local ffi = require 'ffi'

ffi.cdef[[
    struct vec3_t {
		float x;
		float y;
		float z;	
    };
        
    struct ColorRGBExp32{
        unsigned char r, g, b;
        signed char exponent;
    };
    
    struct dlight_t {
        int flags;
        struct vec3_t origin;
        float radius;
        struct ColorRGBExp32 color;
        float die;
        float decay;
        float minlight;
        int key;
        int style;
        struct vec3_t direction;
        float innerAngle;
        float outerAngle;
    };
]]

local function uuid(len)
    local res, len = '', len or 32
    for i=1, len do
        res = res .. string.char(client.random_int(97, 122))
    end
    return res
end

local interface_mt = {}

function interface_mt.get_function(self, index, ret, args)
    local ct = uuid() .. '_t'

    args = args or {}
    if type(args) == 'table' then
        table.insert(args, 1, 'void*')
    else
        return error('args has to be of type table', 2)
    end
    local success, res = pcall(ffi.cdef, 'typedef ' .. ret .. ' (__thiscall* ' .. ct .. ')(' .. table.concat(args, ', ') .. ');')
    if not success then
        error('invalid typedef: ' .. res, 2)
    end

    local interface = self[1]
    local success, func = pcall(ffi.cast, ct, interface[0][index])
    if not success then
        return error('failed to cast: ' .. func, 2)
    end

    return function(...)
        local success, res = pcall(func, interface, ...)

        if not success then
            return error('call: ' .. res, 2)
        end

        if ret == 'const char*' then
            return res ~= nil and ffi.string(res) or nil
        end
        return res
    end
end

local function create_interface(dll, interface_name)
    local interface = (type(dll) == 'string' and type(interface_name) == 'string') and client.create_interface(dll, interface_name) or dll
    return setmetatable({ffi.cast(ffi.typeof('void***'), interface)}, {__index = interface_mt})
end

local effects = create_interface('engine.dll', 'VEngineEffects001')
local alloc_dlight = effects:get_function(4, 'struct dlight_t*', {'int'})

local draw_dlight = function(pos, time, data)
    local dlight = alloc_dlight(-1)

    dlight.key = -1
    dlight.color.r = data.color[1]
    dlight.color.g = data.color[2]
    dlight.color.b = data.color[3]
    dlight.color.exponent = data.color[4] / 8.5
    dlight.flags = 0x2
    dlight.style = data.style
    dlight.radius = data.radius
    dlight.die = globals.curtime() + globals.tickinterval()*1
    dlight.decay = data.radius / 5

    dlight.direction = pos
    dlight.origin = pos
end

local host_state = client.find_signature('engine.dll', '\x39\x88\xCC\xCC\xCC\xCC\x0F\x8E\xCC\xCC\xCC\xCC\x33\xDB') or error('Outdated signature')

local ent_dlights = {
    enable = ui.new_checkbox('visuals', 'effects', 'Entity dlights'),
    color = ui.new_color_picker('visuals', 'effects', 'dlights_color', 255,255,255,80),
    radius = ui.new_slider('visuals', 'effects', '\ndlight_radius', 0, 250, 165, true, 'ft'),
    style = ui.new_slider('visuals', 'effects', '\ndlight_style', 1, 11, 1)
}

local pos = ffi.new('struct vec3_t')
local origin = { 0, 0, 0 }
local lighttime = 0

client.set_event_callback('setup_command', function(c)
    origin = { entity.get_prop(entity.get_local_player(), 'm_vecOrigin') }
end)

client.set_event_callback('setup_command', function()
    -- local x = ffi.cast('char*', ffi.cast('uintptr_t', host_state))+170
    -- local count = ffi.cast('int*', x)[0]
    -- print(count)

    local me = entity.get_local_player()

    if me == nil or not entity.is_alive(me) or origin[1] == nil then
        return
    end

    local data = {
        radius = ui.get(ent_dlights.radius),
        style = ui.get(ent_dlights.style),
        color = { ui.get(ent_dlights.color) }
    }

    if ui.get(ent_dlights.enable) then
        pos.x = origin[1]
        pos.y = origin[2]
        pos.z = origin[3]+1

        lighttime = globals.curtime() + globals.tickinterval()*1

        draw_dlight(pos, lighttime, data)
    end

    -- for i=1, get_highest_entity_by_index() do end
end)