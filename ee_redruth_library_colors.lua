local inspect = require('inspect') --https://github.com/kikito/inspect.lua
-- print('loading ee_redruth_library_colors...')
local function load_color_constants()
    --loads constants like red,yellow,green etc
    color = {}
    color['red'] = {1, 0, 0}
    color['yellow'] = {1, 1, 0}
    color['green'] = {0, 1, 0}
    color['cyan'] = {0, 1, 1}
    color['blue'] = {0, 0, 1}
    color['magenta'] = {1, 0, 1}
    -- print('load_color_constants:')
    for i, v in pairs(color) do --add all these colors to be a global varible
        -- print('\t' .. i .. ' = ' .. inspect(v))
        -- print(i, inspect(v))
        _G[i] = v
    end
end
load_color_constants()
function color_cycle(color1, color2, pos)
    --take two colors, cycle them by the position 0-1
    local pos = pos % 1
    local neg_pos = 1 - pos
    local ret_color = {}
    local colo_len = #color1
    for i = 1, colo_len do
        ret_color[i] = color1[i] * pos + color2[i] * neg_pos
    end
    return ret_color
end

function color_cycle1(pos)
    local pos = pos % 1
    local neg_pos = 1 - pos
    return {pos, neg_pos, 0} -- green => red
    -- return 0, pos, neg_pos -- blue => green
    -- return neg_pos, 0, pos -- red => blue
    
    -- return pos, neg_pos, 1 -- cyan => magenta
    -- return 1, pos, neg_pos -- magenta => yellow
    -- return neg_pos, 1, pos -- yellow => cyan
    
    -- return 1, pos, 0 -- red => yellow
    -- return neg_pos, 1, 0 -- yellow => green
    -- return 0, 1, pos -- green => cyan
    -- return 0, neg_pos, 1 -- cyan => blue
    -- return pos, 0, 1 -- blue => magenta
    -- return 1, 0, neg_pos -- magenta => red
end

function multiply_colors(color1, color2)
    local return_color = {}
    for i, v in ipairs(color1) do
        return_color[i] = color1[i] * color2[i]
    end
    return return_color
end

function multiply_array(array1, array2)
    --multiply arrays (scale vectors), they should be of the same length
    --i.e. {1,2}*{2,2}={2,4} or {1,2,3}*{1,2,3}*{1,2,3}={1,8,27}
    --also {1,2,3}*{3}={3,2,3} (if array sizes differ, carry the values)
    --so the function is liberal in the sense red {1,0,0} (or any color) could be multiplied by an alpha for example {1,1,1,0.5} to get {1,0,0,0.5}
    local ret = {}
    if #array1 < #array2 then --ensure that array1 is always the longest
        local array1old = array1
        array1 = array2
        array2 = array1old
    end
    for i, v in ipairs(array1) do
        ret[i] = array1[i] --first copy array1
        pcall(--then try to multiply (if we crash out the array was too long)
            function()
                ret[i] = array1[i] * array2[i]
            end
        )
    end
    return ret
end

function color_cycle_hue(pos) -- 0 to 1 gives a cycle of red yellow green cyan blue magenta
    --cycle vars:
    local pos = pos % 1 --firstly make it cycle to 1
    local pos = pos * 6 --multiply by 6 for 6 cycle functions
    local color_cycle = math.floor(pos) --find the cycle function ref 0-5
    pos = pos % 1 --find the position in the cycle function
    --cycle functions:
    if color_cycle == 0 then
        return {1, pos, 0} -- red => yellow
    elseif color_cycle == 1 then
        return {1 - pos, 1, 0} -- yellow => green
    elseif color_cycle == 2 then
        return {0, 1, pos} -- green => cyan
    elseif color_cycle == 3 then
        return {0, 1 - pos, 1} -- cyan => blue
    elseif color_cycle == 4 then
        return {pos, 0, 1} -- blue => magenta
    elseif color_cycle == 5 then
        return {1, 0, 1 - pos} -- magenta => red
    end
end

function get_random_color(cycle_function)
    --get a random color from the cycle_function (a higher order function that converts 0-1 to a color like {1,1,1})
    --default cycle is the hue cycle (all colors)
    cycle_function = cycle_function or color_cycle_hue
    --red 0/6
    --yellow 1/6
    --green 2/6
    --cyan 3/6
    --blue 4/6
    --magenta 5/6
    -- hue_start = hue_start or 0 --default red to red (full hue range)
    -- hue_range = hue_range or 1
    return cycle_function(math.random())
end
