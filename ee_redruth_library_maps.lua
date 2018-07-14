--[[
 
map functions
 
"maps" in entity engine are 2D arrays like:
 
local map = {
    {0, 0, 1},
    {0, 0, 0},
    {0, 1, 1},
    }}
 
usually 0 is empty, 1 or more is filled 
 
]]

print('loading ee_redruth_library_maps...')

function inspect_map(map)
    --turn map to a formatted string
    --a map is a 2 dimensional array like {{0,0,0},{1,1,0},{0,0,1}}
    --makes visualizing a map easier for debugging
    local width = #map[1]
    local height = #map
    local s = ''
    -- s = s .. '{'
    for y = 1, height do
        s = s .. inspect(map[y])
        if y ~= height then
            s = s .. ',\n'
        end
    end
    return s
end

function print_map(map)
    --print a map
    --a map is a 2 dimensional array like {{0,0,0},{1,1,0},{0,0,1}}
    --makes visualizing a map easier for debugging
    print(inspect_map(map))
end

function get_multidimensional_array (initVal, ...)
    --shortcut to create a multidimensional array, like a map, to create a 2D array:
    -- multiArray(0,4,4) --a 4x4 empty map
    --https://rosettacode.org/wiki/Multi-dimensional_array#Lua
    local function copy (t)
        local new = {}
        for k, v in pairs(t) do
            if type(v) == "table" then
                new[k] = copy(v)
            else
                new[k] = v
            end
        end
        return new
    end
    local dimensions, arr, newArr = {...}, {}
    for i = 1, dimensions[#dimensions] do
        table.insert(arr, initVal)
    end
    for d = #dimensions - 1, 1, -1 do
        newArr = {}
        for i = 1, dimensions[d] do
            table.insert(newArr, copy(arr))
        end
        arr = copy(newArr)
    end
    return arr
end

function get_empty_map(width, height, init_val)
    init_val = init_val or 0
    return get_multidimensional_array(init_val, height, width)
end

function get_map_tile(map, x, y)
    --return a tile from a map (or nill if no tile)
    --checks if the x,y is actually valid, does not crash
    --kept as notes
    local width, height = #map[1], #map
    if x > 0 and y > 0 and x <= width and y <= height then --check coordinate is valid, note they start from 1,1 in lua, not 0,0
        return map[y][x]
    end
end
