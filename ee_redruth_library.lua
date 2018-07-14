--[[
 
redruth (lua library for ee and others)
 
 
was "my_lua_lib" (late 2017, last updates where in lua test projects for shaders and map drawing etc)
 
old code stashed in OLD
 
FRESH START CODE 
 
 
i like the convention here even if i can't find the module:
https://stevedonovan.github.io/ldoc/manual/doc.md.html
 
 
 
CONVENTIONS:
-trying to use doc strings, see first function (addRequirePath)
-most this whole library are quick and simple functions, therefore we adopt styles like this:
--list of coordinates {x1,y1,x2,y2...}
--when return a coordinate, return x, y
--when entering coordinates as pars someCalc(x1,y1,x2,y2) 
--"maps" as in ones for in games, like for pathfinding are nested lists where 0 is empty, 1 or more is an object 
 
 
Similar to TOML style used to markup this document:
https://en.wikipedia.org/wiki/TOML
--[system functions]
--[json functions]
these mark "code regions" in this document
 
 
]]
inspect = require('inspect') --https://github.com/kikito/inspect.lua
json = require('json') --https://github.com/rxi/json.lua
require 'ee_redruth_library_colors'
require 'ee_redruth_library_math'
require 'ee_redruth_library_maps'
require 'ee_redruth_library_shapes'
require 'ee_redruth_library_table'
Turtle = require 'ee_redruth_library_turtle'

--[test functions]
local function run_ee_redruth_library_tests()
    print('run_ee_redruth_library_tests...')
    
    -- testJson = {} --tested a json save DEPRECATED
    -- testJson.x = 6565
    -- testJson.s = 'hshshs'
    -- save_json_file('test.json', testJson)
    -- testJson2 = load_json_file('test.json')
    -- print(inspect(testJson2))
    
    -- arraytest = get_multidimensional_array(0, 2, 2) --tests a quick generate multidimensional array function DEPRECATED
    -- print('arraytest', inspect(arraytest))
end

--[debug functions]

local override_print = true
--https://stackoverflow.com/questions/25125435/lua-global-override
--override the print function
if override_print then
    local old_print = print
    print = function(...)
        local calling_script = debug.getinfo(2).short_src
        old_print('<' .. calling_script .. '>', ...)
    end
end

function mod1(input, modulo)
    --to prevent further insanity, we have a corrected modulo that allows us to modulo lua's odd array references:
    --for example normal mod 4 would create the pattern 0,1,2,3,0,1...
    --mod1 creates the pattern 1,2,3,4,1,2...
    --this is because when referencing arrays we start counting at 1 in lua, making many of the interactions between modulo and < or <= different in lua when dealing with arrays
    input = input - 1
    input = input % modulo
    return input + 1
end

function file_to_string(filename) --returns nil if no file
    local f = io.open(filename, "rb")
    if f then
        local content = f:read("*all")
        f:close()
        return content
    end
end

function string_to_file(filename, string)
    local f = io.open(filename, "wb")
    local content = f:write(string)
    f:close()
    return content
end

--[map functions]

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

--[system functions]

function hook_function(function1, function2)
    --[[
    WARNING, THIS IS A HACK!
    
    testing lua flexibility as it is a dynamic language
    this technique could be used to "hook" a function
 
    this example would add to events that are called after the love.quit event in this case:
 
    love.quit = hook_function(love.quit, function(...)
        print('quit hook1')
    end)
    love.quit = hook_function(love.quit, function(...)
        print('quit hook2')
    end)
 
    this is altogether a bad idea but shows what could be done as a hack if you didn't understand the original code base
 
    ]]
    
    return function (...)
        function1(...)
        function2(...)
    end
end

function love.filesystem.addRequirePath(path)
    --shortcut to append the require paths
    --@usage: love.filesystem.addRequirePath('polygon-master/?.lua')
    love.filesystem.setRequirePath(love.filesystem.getRequirePath() .. ';' .. path)
end

function save_file (filename, data)
    --saves a file using lua itself
    --(this is for debug purposes only, normally use love filesystem)
    local file = assert(io.open(filename, "w"))
    file:write(data)
    file:close()
end

function load_file(filename)
    --load a file using lua itself
    --(this is for debug purposes only, normally use love filesystem)
    local file = assert(io.open(filename, "r"))
    ret = file:read()
    file:close()
    return ret
end

--[table functions]

function table.contains(target_table, contains) --true if table contains a value (like python)
    -- for _, v in pairs(target_table) do
    --     if v == contains then
    --         return true
    --     end
    -- end
    -- return false
    for _, v in pairs(target_table) do
        if v == contains then
            return true
        end
    end
    return false
end

--[json functions]
function load_json_file(filename)
    return json.decode(assert(love.filesystem.read(filename)))
end
function save_json_file(filename, data)
    love.filesystem.write(filename, json.encode(data))
end

--[misc functions]

local image_cache_cache = {}

function image_cache(filename)
    -- filename = 'images/'..filename
    if not image_cache_cache[filename] then
        image_cache_cache[filename] = love.graphics.newImage(filename)
    end
    return image_cache_cache[filename]
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

function create_empty_map(width, height, fill_value) --create an empty map filled with the "fill_value" (default is 0)
    fill_value = fill_value or 0 --default value 0
    local map = {}
    for y = 1, height do
        local row = {}
        for x = 1, width do
            row[x] = fill_value
        end
        table.insert(map, row)
    end
    return map
end

function array_chunk(array, chunk_size)
    --split an array into chucks, name taken from php
    -- i.e. {1,2,3,4,5,6} => {{1,2},{3,4},{5,6}}
    chunk_size = chunk_size or 2 --default 2 (for 2D coordinates)
    local chunk_array = {}
    local chunk = {}
    for i, v in ipairs(array) do
        table.insert(chunk, v)
        if #chunk == chunk_size then
            table.insert(chunk_array, chunk)
            chunk = {}
        end
    end
    if #chunk > 0 then
        -- print('WARNING, CHUNKING ERROR')
        error('array was the wrong size to split into chunks')
    end
    return chunk_array
end

function gen_poly_square(x, y, width, height)
    --return the coordinates to draw a square, referenced from the top left
    return {x, y, x + width, y, x + width, y + height, x, y + height}
end

--[end of file]
run_ee_redruth_library_tests()

