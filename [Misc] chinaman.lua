local onoffupdown               = ui.new_checkbox("CONFIG", "Presets", "cHiNaSYNC p100 batsoup.dll")
ui.new_label("CONFIG", "Lua", " ")
ui.new_label("CONFIG", "Lua", " ")
ui.new_label("CONFIG", "Lua", " ")
ui.new_label("CONFIG", "Lua", " ")
ui.new_label("CONFIG", "Lua", " ")
ui.new_label("CONFIG", "Lua", " ")
ui.new_button("CONFIG", "Lua", "inject otc", function() end)
if not ui.get(onoffupdown) then client.set_clan_tag("") end
local vars                      = {
    iter                        = 0,
    cur_iter                    = -1,
    raw_latency                 = 0,
    latency                     = 0,
    tickcount_p                 = 0
}
local tag_string                = {   
    [1]                         = '高',
    [2]                         = '高',
    [3]                         = '高兴',
    [4]                         = '高兴',
    [5]                         = '高兴',
    [6]                         = '高兴 :D',
    [7]                         = '高兴 :DD',
    [8]                         = '高兴 :DDD',
    [9]                         = '高兴 :DDDD',
    [10]                        = '高兴 :DDDDD',
    [11]                        = '高兴 :DDDDDD',
    [12]                        = '高兴 :DDDDDD',
    [13]                        = '高兴 :DDDDDD',
    [14]                        = '高兴 :DDDDDD',
    [15]                        = '高兴 :DDDDDD',
    [16]                        = '高兴 :DDDDDD',
    [17]                        = '高兴 :DDDDDD',
    [18]                        = '高兴 :DDDDDD',
    [19]                        = '高兴 :DDDDDD',
    [20]                        = '高兴 :DDDDDD',
    [21]                        = '高兴 :DDDDDD',
    [22]                        = 'F',
    [23]                        = 'FU',
    [24]                        = 'FUG',
    [25]                        = 'FUGG',
    [26]                        = 'FUGG :D',
    [27]                        = 'FUGG :DD',
    [28]                        = 'FUGG :DDD',
    [29]                        = 'FUGG :DDD',
    [30]                        = 'FUGG :DDD',
    [31]                        = '日本动漫还不箝',
    [32]                        = 'FUGG :DDD',
    [33]                        = 'FUGG :DDD',
    [34]                        = 'FUGG :DDD',
    [35]                        = 'FUGG :DDD',
    [36]                        = 'FUGG :DD',
    [37]                        = 'FUGG :D',
    [38]                        = 'FUGG',
    [39]                        = 'FUGG',
    [40]                        = '日本动漫还不箝'
}
local function mod(nigger, white_person)
    return nigger - math.floor(nigger/white_person)*white_person
end
local function chinaman_clantag()
    if (vars.iter == nil)          then return end
    if (vars.cur_iter == nil)      then return end
    if (vars.raw_latency == nil)   then return end
    if (vars.latency == nil)       then return end
    if (vars.tickcount_p == nil)   then return end
    for i=1, 38 do if (tag_string[i] == nil) then return end end
    vars.raw_latency            = client.latency()
    vars.latency                = vars.raw_latency / globals.tickinterval()
    vars.tickcount_p            = globals.tickcount() + vars.latency
    vars.iter                   = math.floor(mod(vars.tickcount_p / 20, 40))
    if ui.get(onoffupdown) then
        if entity.get_local_player() then
            if vars.iter ~= vars.cur_iter then
                local tag       = tag_string[vars.iter]
                if tag == nil then return end
                client.set_clan_tag(tag)
                vars.cur_iter   = vars.iter
            end
        end
    end
end
client.set_event_callback("paint_ui", chinaman_clantag)
client.set_event_callback("shutdown", function()
    client.set_clan_tag("")
end)
ui.set_callback(onoffupdown, function()
    if not ui.get(onoffupdown) then
        client.set_clan_tag("")
    end
end)