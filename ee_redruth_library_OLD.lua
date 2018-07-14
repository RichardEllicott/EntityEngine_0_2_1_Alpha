--[[
 
this was the old library, all one file, full of solutions not yet organized
 
DO NOT DELETE!!!!!!!!
 
 
 
]]

print('loading my_lua_lib')
local inspect = require('inspect')
local json = require('json')

local override_print = false
--https://stackoverflow.com/questions/25125435/lua-global-override
if override_print then
    old_print = print
    print = function(...)
        local calling_script = debug.getinfo(2).short_src
        old_print('<' .. calling_script .. '>', ...)
    end
end

local test_map = {--a test map example for our functions
    {0, 0, 1, 0},
    {0, 0, 1, 0},
    {0, 0, 0, 0},
    {0, 0, 1, 0},
}

function load_json_file(filename)
    local json_string = file_to_string(filename)
    return json.decode(json_string)
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

function file_to_string_lovefs(filename) --FUNCTION KEPT AS NOTES
    return love.filesystem.read(filename)
end

function string_to_file_lovefs(filename, string) --FUNCTION KEPT AS NOTES
    love.filesystem.write(filename, string)
end

function save_data_demo()
    
    local save_data_filename = 'savedata.json'
    
    local save_data = love.filesystem.read(save_data_filename) --try to read file
    if save_data then
        save_data = json.decode(save_data) --if it exists load as json
    else
        save_data = {} --if not create blank table
    end
    
    print('save_data:', inspect(save_data)) --inspect this table (may be empty)
    
    save_data.some_var = 'hahaha' --add a persistant varible
    
    love.filesystem.write(save_data_filename, json.encode(save_data))
end

function array_to_chuncks(array, chunk_size)
    --split an array into chucks
    -- ie {1,2,3,4,5,6} => {{1,2},{3,4},{5,6}} if the chunk size is 2
    --useful for dealing with love 2D points arrays
    chunk_size = chunk_size or 2 --default size of 2
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
        print('WARNING, CHUNKING ERROR')
        error('array was the wrong size to split into chunks')
    end
    return chunk_array
end

function gen_poly_square(x, y, width, height)
    --make a sqaure as a polygon, note this has an orgin of the top left
    return {x, y, x + width, y, x + width, y + height, x, y + height}
end

function inspect_map(map) --turn map to a formatted lua string
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

function print_map(map) --print a 2D map as a formatted lua string
    print(inspect_map(map))
end

function pathfind(map, x2, y2, x1, y1) --return the directions from x1,y1 to x2,y2
    --example output: { { 1, 1 }, { 1, 2 }, { 1, 3 }, { 2, 3 }, { 3, 3 }, { 4, 3 }, { 4, 4 } }
    --TODO: does not yet eliminate blocked start and fin cases, may need a timeout
    
    local map_width = #map[1]
    local map_height = #map
    
    local function in_bounds(x, y) --check location is in bounds of map
        return x > 0 and
        y > 0 and
        x <= map_width and
        y <= map_height
    end
    
    local translations = {--valid move directions, note we do not have diagonal translations
        {0, 1},
        {1, 0},
        {0, -1},
    {-1, 0}}
    
    local path_map = {} --generate a new map of 0s that has the same dimensions
    for y, row in ipairs (map) do
        local new_row = {}
        for x, val in ipairs(row) do
            table.insert(new_row, 0)
        end
        table.insert(path_map, new_row)
    end
    
    local fill_positions = {{x1, y1, 9}} -- startx, starty, currentvalue .. this is a list of positions to check next
    
    local sucess = false
    
    while #fill_positions > 0 do
        
        local current_pos = table.remove(fill_positions, 1) --lua "pop" the first element in a table
        
        local xPos = current_pos[1]
        local yPos = current_pos[2]
        local count = current_pos[3]
        
        if in_bounds(xPos, yPos) then
            if map[yPos][xPos] == 0 and path_map[yPos][xPos] == 0 then --both squares on maps are free
                path_map [yPos][xPos] = count + 1 --mark with count + 1
                
                if xPos == x2 and yPos == y2 then
                    sucess = true
                    break --if we reach destination we can cancel flood fill
                end
                
                for _, translation in ipairs(translations) do --add all the surrounding squares to a check list
                    -- print(inspect(translation))
                    local new_fill_pos = {xPos + translation[1], yPos + translation[2], count + 1}
                    table.insert(fill_positions, new_fill_pos)
                end
            end
        end
    end
    
    local results = {}
    local results2 = {}
    
    if sucess then
        
        local current_pos = {x2, y2}
        table.insert (results, current_pos)
        -- table.insert (results2, current_pos[1]) --NEW
        -- table.insert(results2, current_pos[2])
        
        while true do
            local current_number = path_map[current_pos[2]][current_pos[1]]
            if current_number == 10 then --we must have reached the destination (value 10)
                break --so break loop
            end
            
            for _, translation in ipairs(translations) do --look for first tile surrounding with a number one lower
                local check_pos = {current_pos[1] + translation[1], current_pos[2] + translation[2]}
                if in_bounds(check_pos[1], check_pos[2]) then
                    if path_map[check_pos[2]][check_pos[1]] == current_number - 1 then
                        
                        table.insert(results, check_pos) --save the result
                        -- table.insert (results2, check_pos[1]) --NEW
                        -- table.insert (results2, check_pos[2])
                        
                        current_number = current_number - 1 --lower the current number
                        current_pos = check_pos
                        break --don't check any more translations as this one was okay (loop will continue)
                    end
                end
            end
        end
        return results
    end
end

-- print('pathfind TESTSTSTSTS')
-- print(inspect(pathfind(test_map, 1, 1, 4, 4)))

local function marchingSquares(map) --https://en.wikipedia.org/wiki/Marching_squares
    
    local width = #map[1]
    local height = #map
    
    local ret = {} --build a new map
    
    for y = 1, height - 1 do
        
        local ret_row = {}
        
        for x = 1, width - 1 do
            
            local mval = 0
            
            --matches the same lookup table here
            --https://en.wikipedia.org/wiki/Marching_squares#Basic_algorithm
            if map[y][x] == 0 then
                mval = mval + 8
            end
            if map[y][x + 1] == 0 then
                mval = mval + 4
            end
            if map[y + 1][x] == 0 then
                mval = mval + 1
            end
            if map[y + 1][x + 1] == 0 then
                mval = mval + 2
            end
            
            table.insert(ret_row, mval)
            
        end
        
        table.insert(ret, ret_row)
    end
    
    return ret
end

-- local test_map = {
--     {0, 0, 0, 0, 0},
--     {0, 1, 1, 1, 0},
--     {0, 1, 1, 1, 0},
--     {0, 1, 1, 1, 0},
--     {0, 0, 0, 0, 0},
-- }

-- local test_map = {--creating a case of 15
--     {0, 0, 0, 0, 0},
--     {0, 1, 1, 0, 0},
--     {0, 1, 1, 1, 0},
--     {0, 1, 1, 1, 0},
--     {0, 0, 0, 0, 0},
-- }

-- local test_map = { --testing lone square
--     {0, 0, 0, 0, 0},
--     {0, 0, 0, 0, 0},
--     {0, 0, 1, 0, 0},
--     {0, 0, 0, 0, 0},
--     {0, 0, 0, 0, 0},
-- }

-- local test_map = {
--     {1, 1, 1, 1, 1},
--     {1, 1, 1, 1, 1},
--     {1, 1, 1, 1, 1},
--     {1, 1, 1, 1, 1},
-- }

-- print('marchingSquares:')
-- for y, row in ipairs(marchingSquares(test_map)) do
--     print(inspect(row)) --please note i tend to use the "inspect" lua package
-- end

-- print('test 0 index')

-- local table_test = {}

-- table_test[0] = 'hello'

-- print(inspect(table_test))

function reverse_table(table) --reverse an array, {1,2,3,4} => {4,3,2,1}
    local reversedTable = {}
    local itemCount = #table
    for k, v in ipairs(table) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

local function copy_map(map) --copy a 2D map (beware of reference types inside the map)
    local new_map = {}
    for y, row in ipairs(map) do
        local new_row = {}
        for x, val in ipairs(row) do
            table.insert(new_row, val)
        end
        table.insert(new_map, new_row)
    end
    return new_map
end

local function pad_map(map, pad_value) --add a boundry spacing of 1 to map, 5x5 becomes 7x7 etc ... creates a new map for this
    
    local width = #map[1]
    local height = #map
    
    local new_map = {}
    
    local top_row = {} --build top and bottom
    local bottom_row = {}
    for i = 1, width + 2 do
        top_row[i] = pad_value
        bottom_row[i] = pad_value
    end
    table.insert(new_map, top_row) --pad top
    
    for y, row in ipairs(map) do
        local new_row = {}
        table.insert(new_row, pad_value) --pad left
        for x, val in ipairs(row) do
            table.insert(new_row, val)
        end
        table.insert(new_row, pad_value) --pad right
        table.insert(new_map, new_row)
    end
    
    table.insert(new_map, bottom_row) --pad bottom
    return new_map
end

local function floodfill_function(map, x, y, fill_value, translations) --warning affects original map
    
    local count = 0
    
    local start_val = map[y][x] --all values that match this value and join get filled (ie this is red, fill with blue)
    
    if start_val ~= fill_value then --prevent infinite loop (if start and fill the same)
        
        local fill_positions = {{x, y}}
        
        while #fill_positions > 0 do
            
            local current_pos = table.remove(fill_positions, 1) --lua "pop" the first element in a table
            
            pcall(function () --exception if out of range
                if map[current_pos[2]][current_pos[1]] == start_val then
                    map[current_pos[2]][current_pos[1]] = fill_value
                    
                    count = count + 1
                    
                    for _, translation in ipairs(translations) do
                        table.insert(fill_positions, {current_pos[1] + translation[1], current_pos[2] + translation[2]})
                    end
                end
            end)
        end
    end
    return count
end

local function floodfill(map, x, y, fill_value) --like a paint floodfill, warning does not copy map
    local translations = {--valid move directions, note we do not have diagonal translations
        {0, 1},
        {1, 0},
        {0, -1},
    {-1, 0}}
    return floodfill_function(map, x, y, fill_value, translations)
end

local function floodfill_diagonal(map, x, y, fill_value) --like a paint floodfill (but with diagonal translations), warning does not copy map
    local translations = {--valid move directions, note we do not have diagonal translations
        {0, 1},
        {1, 0},
        {0, -1},
        {-1, 0},
        {1, 1},
        {-1, -1},
        {1, -1},
    {-1, 1}}
    return floodfill_function(map, x, y, fill_value, translations)
end

-- test_floodfill = {
--     {1, 1, 1, 0},
--     {1, 1, 1, 0},
--     {1, 1, 0, 0},
-- {0, 0, 1, 1}}

-- print('TEST FLOODFILL')
-- print_map(test_floodfill)
-- print(floodfill_diagonal(test_floodfill, 1, 1, 8))
-- print(floodfill_diagonal(test_floodfill, 1, 1, 8))
-- print('TEST FLOODFILL')
-- print_map(test_floodfill)
-- print('END')

local function map_to_poly(map)
    --[[
    convert a square map of 1 and 0's to polygon points of it's boundry
    crashes if more than one found (a hole or two joined square sections)
 
    UNFINISHED
 
    --EXAMPLES
    normal_map = { --a bog standard map, no holes, works to create a valid polygon
        {1, 1, 1, 0}, 
        {0, 1, 1, 0}, 
        {0, 1, 1, 0}, 
    }
    diagonal_hole_map = { --actually, not technically a hole, this is handled due to the way the edges are joined clockwise
        {1, 1, 1, 1}, 
        {0, 1, 0, 1}, 
        {0, 1, 1, 0}, 
    }
    hole_map = { --an isolated hole will crash
        {1, 1, 1, 1}, 
        {0, 1, 0, 1}, 
        {0, 1, 1, 1}, 
    }
    ]]
    
    local map = pad_map(map, 0) --create a padded map
    
    --all squares that are 1 but next to a zero, mark 9 (boundry)
    
    --an edge map should be represented such that for a given square, the first val is the left side, the second the top
    --left side is the first instance "0", top the second "1"
    --[[
 
    0--0--0
    |1 |2 |
    0--0--0
    |3 |4 |
    0--0--0
 
    from square 4 {1,1,0} left edge
 
    ]]
    
    --EDGE TRACING (AROUND THE SQUARES) MIGHT BE HARDER
    --COLLECTING BOUNDRIES FASTER *** try this
    
    --COLLECTING BOUNDRIES METHOD:
    --WE NEED TO FIND ALL TILES THAT MEET EDGE SUCH
    
    --SUCESS!!
    
    --noted ineffeciencies:
    --that we have to pad the map
    
    local width = #map[1]
    local height = #map
    
    local edges = {} --collect edges in form
    
    for y = 2, height - 1 do --for all (non-pad) squares in the map
        for x = 2, width - 1 do
            
            if map[y][x] == 1 then --if a square is filled, check it's neighbours (to detect an edge)
                
                if map[y - 1][x] == 0 then --check N edge
                    table.insert(edges, {{x, y}, {x + 1, y}}) --(0,0) (1,0) note the translations go clockwise, this ensures they join up!
                end
                if map[y][x + 1] == 0 then --check E edge
                    table.insert(edges, {{x + 1, y}, {x + 1, y + 1}}) --(1,0) (1,1)
                end
                if map[y + 1][x] == 0 then --check S edge
                    table.insert(edges, {{x + 1, y + 1}, {x, y + 1}}) --(1,1) (0,1)
                end
                if map[y][x - 1] == 0 then --check W edge
                    table.insert(edges, {{x, y + 1}, {x, y}}) --(0,1) (0,0)
                end
                
            end
        end
    end
    
    -- debug_edges = {} --output for test script (DELETE)
    -- for _, edge in ipairs(edges) do
    --     -- print(inspect(edge))
    
    --     debug_line = {}
    
    --     for _,coor in ipairs(edge) do
    --         table.insert(debug_line, coor[1])
    --         table.insert(debug_line, coor[2])
    --     end
    
    --     table.insert(debug_edges, debug_line)
    -- end
    
    local function coor_equal(coor1, coor2) --check two coordinates match
        return coor1[1] == coor2[1] and coor1[2] == coor2[2]
    end
    
    for ttl = 1, 1000 do --we have a timeout to prevent more than 1000 checks
        
        local found_edge_match_last_cycle = false --we use this to break the loop
        
        if #edges > 1 then --we will attempt to consolidate these edges
            
            local first_edge = edges[1] --first edge in edges, does it join other edges
            
            for check_edge_index = 2, #edges do --iterate the other edges --BREAKPOINT 10
                
                local check_edge = edges[check_edge_index] --first edge to check
                
                local end_of_first_edge = first_edge[#first_edge] --the end of this edge is the last coor in it
                
                if coor_equal(end_of_first_edge, check_edge[1]) then --if this coor matches, join them
                    
                    for check_edge_index = 2, #check_edge do --we ignore the first coor as it's the same
                        local insert_coor = check_edge[check_edge_index] --we insert just the remaining coors
                        table.insert(first_edge, insert_coor)
                    end
                    
                    table.remove(edges, check_edge_index) --finally remove this edge
                    
                    found_edge_match_last_cycle = true
                    break --BREAKPOINT 10
                    
                end
                
            end
            
        end
        
        if not found_edge_match_last_cycle then
            break
        end
        
    end
    
    if #edges == 1 then --we have successfully joined all the seperate edge lines (because there is now just one set of points)
        
        local edges = edges[1]
        
        local function remove_inline_points(points)
            --this function runs through x and y axis, checking for in-line polygon points
            --it removes in-between points to reduce the polygon complexity
            --it actually assumes the input polygon terminates in the same starting coordinate (we will remove this later)
            
            for axis = 1, 2 do --current axis (x or y to check)
                
                local remove_list = {} --indexs to delete from points
                
                local match_count = 0 --count of current matching points
                
                local points_len = #points
                
                for i = 1, points_len do
                    
                    if i < points_len and points[i][axis] == points[i + 1][axis] then --this point is in-line with the next (and not the last point)
                        
                        match_count = match_count + 1 --increment the match count
                        
                    else --this point is not in-line with the next (or it was the last point in the list)
                        if match_count > 1 then --there where enough matches to make a delete case
                            local delete_start = i - (match_count - 1) --first index to delete
                            local delete_end = i - 1 --last index to delete
                            
                            for i2 = delete_start, delete_end do --add these index to a remove list
                                table.insert(remove_list, i2)
                            end
                        end
                        
                        match_count = 0
                        
                    end
                    
                end
                
                for i = #remove_list, 1, -1 do --iterate the move list backwards to ensure the order of the array is not messed up
                    table.remove(points, remove_list[i])
                end
                
            end
            
        end
        
        remove_inline_points(edges) --this LONG function, removes inline points, it needs a map that terminates in the same start point
        
        table.remove(edges, #edges) --remove the last coordinate, this is because it WILL be the same as the first
        
        local polygon_points = {} --turn our coordinate list to polygon points {{0,0},{1,1}...} => {0,0,1,1...}
        for _, coor in ipairs(edges) do
            table.insert(polygon_points, coor[1] - 2) --minus 2 is the correction we make due to the padding and offsets etc
            table.insert(polygon_points, coor[2] - 2)
        end
        
        return polygon_points
        
    else --some errors, set to CRASH!!!
        if #edges == 0 then
            error('no edges found!')
        else
            error('found edges did not join') --could be a hole, or two seperate islands of squares
        end
    end
end

-- test_map = {--shows that a sort of diagonal hole, doesn't break the poly!
--     {1, 1, 1, 0},
--     {1, 0, 1, 1},
--     {1, 1, 0, 1},
-- {0, 1, 1, 0}}

-- test_map = {--shows that a sort of diagonal hole, doesn't break the poly!
--     {1, 1, 1, 1},
--     {0, 1, 1, 1},
--     {1, 1, 0, 1},
-- {1, 1, 1, 0}}

-- test_map = {--shows that a sort of diagonal hole, doesn't break the poly!
--     {1, 1},
--     {1, 1}
-- }

-- test_map = {--shows that a sort of diagonal hole, doesn't break the poly!
--     {1}
-- }

-- test_map = {--shows that a sort of diagonal hole, doesn't break the poly!
--     {0, 0, 0, 0},
--     {0, 1, 1, 1},
--     {0, 1, 0, 1},
--     {0, 1, 1, 1}
-- }

-- test_map = { --breaks
--     {1, 1, 0, 0},
--     {0, 0, 0, 1},
--     {0, 1, 1, 1},
--     {0, 1, 0, 0}
-- }

-- test_map = {
-- {0,0},
-- {0,1}
-- }

-- debug_polygon = map_to_poly(test_map) --global for a test

function scale_points(points, coefficient) --take a list of points like {0,0,3,4,5,8, ...} and multiply them
    local len = #points
    new_points = {}
    for i = 1, len do
        new_points[i] = points[i] * coefficient
    end
    return new_points
end

function scale_points(points, xScale, yScale) --take a list of points like {0,0,3,4,5,8, ...} and multiply them
    yScale = yScale or xScale
    local len = #points
    new_points = {}
    for i = 1, len do
        if i % 2 == 1 then
            new_points[i] = points[i] * xScale
        else
            new_points[i] = points[i] * yScale
        end
    end
    return new_points
end

function offset_points(points, xOffset, yOffset) --take a list of points like {0,0,3,4,5,8, ...} and offset them by x and y vals
    local len = #points
    new_points = {}
    for i = 1, len do
        if i % 2 == 1 then
            new_points[i] = points[i] + xOffset
        else
            new_points[i] = points[i] + yOffset
        end
    end
    return new_points
end

-- debug_polygon = scale_points(debug_polygon, 32)
-- print(inspect(debug_polygon))

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

-- print('create_empty_map')
-- print_map(create_empty_map(5, 5))

function get_map_supercover(map) --return the covered area of a map as 1s and 0s
    
    local outside_value = {} --we use this to mark the outside of the map
    
    local map = pad_map(map, 0) --a new padded copy is created allowing the floodfill to surround the squares
    floodfill(map, 1, 1, outside_value) --floodfill affects this map
    -- floodfill_diagonal(map, 1, 1, outside_value) --floodfill affects this map
    
    local width = #map[1]
    local height = #map
    
    local return_map = {}
    
    for y = 2, height - 1 do
        local return_row = {}
        for x = 2, width - 1 do
            if map[y][x] == outside_value then
                table.insert(return_row, 0)
            else
                table.insert(return_row, 1)
            end
        end
        table.insert(return_map, return_row)
    end
    
    return return_map
end

-- test_map2 = {
--     {0, 1, 1, 0},
--     {1, 0, 1, 0},
--     {1, 1, 1, 0},
--     {0, 1, 1, 1},
-- }

-- print_map(get_map_supercover(test_map2))

function analyse_map(map) --debug function to check for holes etc
    
    --width and height of map
    --covered tiles
    --supercovered tiles
    --valid for polygon
    --hole count
    
    width = #map[1]
    height = #map
    
    print('analyse_map:')
    print_map(map)
    print (string.format('dimensions = %sx%s', width, height))
    
    local filled_tiles = 0
    
    for y = 1, height do
        for x = 1, width do
            tile = map[y][x]
            if tile ~= 0 then
                filled_tiles = filled_tiles + 1
            end
        end
    end
    
    print(string.format('filled_tiles = %s', filled_tiles))
    
    local supercover_map = get_map_supercover(map)
    
    local island_map = copy_map(map)
    
    print('island_map:')
    print_map(island_map)
    local island_count = 0
    local island_marker = 9
    for y = 1, height - 1 do
        for x = 1, width - 1 do
            local tile = island_map[y][x]
            -- print('cyclesss', x, y)
            if (tile ~= 0) and (tile ~= island_marker) then
                -- floodfill(island_map, x, y, 9)
                -- floodfill_diagonal(map,1,1,9)
                island_count = island_count + 1
            end
        end
    end
    print(string.format('island_count = %s', island_count))
    print_map(island_map)
    
end

-- analyse_map(test_map2)

-- test_map = {--a two island map
--     {1, 1, 1, 1},
--     {1, 1, 0, 0},
--     {1, 0, 0, 1},
--     {1, 0, 0, 1},
-- }

-- test_map = {--a two island map
--     {1, 1, 1, 1},
--     {1, 1, 0, 0},
--     {1, 0, 0, 1},
--     {0, 1, 0, 2},
-- }

function count_islands_in_map(map)
    
    local map = copy_map(map)
    
    local island_count = 0
    local island_marker = {} --use a unique reference to mark the islands
    
    print('function count_islands_in_map')
    
    local width = #map[1]
    local height = #map
    
    print_map(map)
    
    local square_count = 0
    
    for y = 1, height do
        for x = 1, width do
            
            if map[y][x] ~= 0 and map[y][x] ~= island_marker then
                
                print('island found', floodfill_diagonal(map, x, y, island_marker), 'squares big')
                island_count = island_count + 1
                
            end
            
            -- print('xy', x, y)
            square_count = square_count + 1
            
        end
    end
    
    print('square_count', square_count)
    print('island_count', island_count)
    
end

-- count_islands_in_map(test_map)

-- print_map(test_map)

function get_points_on_line(x1, y1, x2, y2, n) --get n points on a line (including start and finish) WARNING: enter a minimum of 2
    local points = {}
    local n = n - 1
    for i = 0, n do
        local start_weight = (n - i) / n
        local end_weight = i / n
        table.insert(points, x1 * start_weight + x2 * end_weight)
        table.insert(points, y1 * start_weight + y2 * end_weight)
    end
    return points
end

function randomize_points(points, random_value)
    new_points = {}
    for i, v in ipairs(points) do
        new_points[i] = v + math.random(-random_value, random_value)
    end
    return new_points
end

function get_lightning_positions(x1, y1, x2, y2, divisions, variance) --divisions is the segments, variance the random value
    local points = get_points_on_line(x1, y1, x2, y2, divisions + 2) --makes the first and last coors stationary
    for i = 3, #points - 2 do
        points[i] = points[i] + math.random() * variance - variance / 2
    end
    return points
end

function get_poly_dimensions(points) --returns the cover dimensions of a polygon, returns 4 vals (min_x, min_y, max_x, max_y)
    
    local max_x = points[1]
    local max_y = points[2]
    local min_x = points[1]
    local min_y = points[2]
    
    for i, v in ipairs(points) do
        if i % 2 == 1 then
            if v > max_x then
                max_x = v
            elseif v < min_x then
                min_x = v
            end
        else
            if v > max_y then
                max_y = v
            elseif v < min_y then
                min_y = v
            end
        end
    end
    return min_x, min_y, max_x, max_y
end
function get_poly_center(points) --return the center coordinate of a polygon (center_x, center_y)
    local min_x, min_y, max_x, max_y = get_poly_dimensions(points)
    return (max_x + min_x) / 2, (max_y + min_y) / 2
end
function center_poly_coors(points) --take polygon coordinates, and move them all so the center is (0,0), makes for easy rotation of this poly
    local xCenter, yCenter = get_poly_center(points)
    local new_points = {}
    for i, v in ipairs(points) do
        if i % 2 == 1 then
            new_points[i] = v - xCenter
        else
            new_points[i] = v - yCenter
        end
    end
    return new_points
end
function scale_poly_coors(points, scale) --scale a polygon, ie scale of 2 doubles it's size
    local new_points = {}
    for i, v in ipairs(points) do
        new_points[i] = v * scale
    end
    return new_points
end

function print_global_varibles() --print all globals for debug
    for n, v in pairs(_G) do
        print('print_global_varibles', n) --just names
        print('print_global_varibles', n, type(v))
    end
end

-- print('global varibles test')
-- print_global_varibles()

-- print(inspect(_G))

function locals() --like python locals, https://stackoverflow.com/questions/2834579/print-all-local-variables-accessible-to-the-current-scope-in-lua
    local variables = {}
    local idx = 1
    while true do
        local ln, lv = debug.getlocal(2, idx)
        if ln ~= nil then
            variables[ln] = lv
        else
            break
        end
        idx = 1 + idx
    end
    return variables
end

-- print(inspect(locals()))

function testImageManipulation()
    
    print('TEST IMAGE MANIPULATION')
    
    mainImageData = love.image.newImageData('error.png')
    mainImage = love.graphics.newImage(mainImageData)
    
    local width, height = mainImageData:getDimensions()
    
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            -- print (mainImageData:getPixel(x, y))
        end
    end
    
    --MAP PIXEL
    --https://love2d.org/wiki/ImageData:mapPixel (higher order function)
    function brighten(x, y, r, g, b, a)
        r = math.min(r * 3, 255)
        g = math.min(g * 3, 255)
        b = math.min(b * 3, 255)
        return r, g, b, a
    end
    -- mainImageData:mapPixel(brighten)
    function stripey(x, y, r, g, b, a)
        r = math.min(r * math.sin(x * 100) * 2, 255)
        g = math.min(g * math.cos(x * 150) * 2, 255)
        b = math.min(b * math.sin(x * 50) * 2, 255)
        return r, g, b, a
    end
    mainImageData:mapPixel(stripey)
    
    --make a new image data (generate stuff etc)
    --https://love2d.org/wiki/love.image.newImageData
    -- imageData = love.image.newImageData(width, height)
    
    --save it
    mainImageData:encode('png', 'error_export.png')
    -- mainImageData = love.image.newImageData('error_export.png') --load it again from '~/Library/Application\ Support/LOVE/'
    
end

-- testImageManipulation()

function save_canvas_to_file(canvas, filename)
    canvas:getImageData():encode(filename)
    
    --WARNING FROM WIKI:
    --filedata = ImageData:encode( format, filename ) --may need format
    --https://love2d.org/wiki/ImageData:encode
    
end

local random_cache_length = 100
function random_cache()
    
    -- print('random_cache>>')
    
    if not random_cache_data then --if no cache yet, generate it
        
        -- local over_point5_count = 0
        
        random_cache_data = {}
        random_cache_pos = 1
        love.math.setRandomSeed(1)
        for i = 1, random_cache_length do
            random_cache_data[i] = love.math.random()
            if random_cache_data[i] > 0.5 then
                -- over_point5_count = over_point5_count + 1
            end
        end
        -- print('over_point5_count',over_point5_count)
    end
    
    -- print(inspect(random_cache_data))
    
    local random_val = random_cache_data[(random_cache_pos % random_cache_length) + 1]
    random_cache_pos = random_cache_pos + 1
    
    -- if random_cache_data_pos > random_cache_length then
    --     random_cache_data_pos = 1
    -- end
    
    return random_val
    
end

-- print('random_cache_test')
-- for i = 1, 10 do
--     print(random_cache())
-- end

-- function get_lightning_positions(x1, y1, x2, y2, divisions, variance) --TEST VERSION WITH random_cache
--     local points = get_points_on_line(x1, y1, x2, y2, divisions + 2) --makes the first and last coors stationary
--     for i = 3, #points - 2 do
--         local ran_cache_val = (random_cache() * 2 - 1)
--         -- print(ran_cache_val)
--         points[i] = points[i] + (ran_cache_val * variance)
--     end
--     return points
-- end

-- function get_ellipse_points(xPos, yPos, xRadius, yRadius, segments)
--     local positions = {}
--     local angle = 0
--     for i = 1, segments do
--         local x = math.sin(angle) * xRadius + xPos
--         local y = math.cos(angle) * yRadius + yPos
--         table.insert(positions, x)
--         table.insert(positions, y)
--         angle = angle + math.rad(360 / segments)
--     end
--     return positions
-- end

function get_ellipse_points(segments, xRadius, yRadius)
    
    xRadius = xRadius or 1 --default to 1
    yRadius = yRadius or xRadius --default to circle
    
    local positions = {}
    local angle = 0
    for i = 1, segments do
        local x = math.sin(angle) * xRadius
        local y = math.cos(angle) * yRadius
        table.insert(positions, x)
        table.insert(positions, y)
        angle = angle + math.rad(360 / segments)
    end
    return positions
end

function table.slice(tbl, first, last, step)
    local sliced = {}
    
    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced + 1] = tbl[i]
    end
    
    return sliced
end

function get_star_points(segments)
    if segments % 2 == 0 then
        local coor_limit = segments * 2
        local weave = segments / 2
        return get_ellipse_weave_points(segments, weave, coor_limit)
        
    else
        local coor_limit = segments
        local weave = math.floor(segments / 2) + 1
        return get_ellipse_weave_points(segments, weave, coor_limit)
        
    end
    
    -- return get_ellipse_weave_points(3,2,3) --triangle
    -- return get_ellipse_weave_points(4,2,8) --square thing
    -- return get_ellipse_weave_points(5,3,5) --pentagram
    -- return get_ellipse_weave_points(6,3,12)
    
    -- return get_ellipse_weave_points(6,3,12)
end

function get_ellipse_weave_points(segments, weave, coor_limit) --generate star patterns
    
    -- segments = 7 --the amount of points on the circle, eg 5 when we make a pentagram
    -- local weave = 4 --amount of coors to skip over, eg making a pentagram by skipping 3 coors
    -- local coor_limit = 7 --max number of coors to return, eg pentagram should have just 5 coors
    
    -- segments = 6 --the amount of points on the circle, eg 5 when we make a pentagram
    -- local weave = 3 --amount of coors to skip over, eg making a pentagram by skipping 3 coors
    -- local coor_limit = 12 --max number of coors to return, eg pentagram should have just 5 coors
    
    -- 5,3,5 => pentagram
    -- 7,4,7 => 7 point star
    
    --6,3,12 => 6 point , alt weave, for even? odd has dissection lines
    --12,6,24 => 12 point, alt weave
    
    local ellipse_points = get_ellipse_points(segments)
    
    local count = #ellipse_points
    
    local points_count = count / 2
    
    -- print('get_star_points', count)
    
    local star_points = {}
    
    local firstX, firstY = ellipse_points[1], ellipse_points[2]
    
    local coor_count = 0
    
    for i = 1, count, 2 do
        
        local x, y = ellipse_points[i], ellipse_points[i + 1]
        -- xPos = i * 2
        -- yPos =
        
        -- print(i, x, y)
        
        -- i2 = (i+4) % count --works sorta
        i2 = (i + weave * 2) % count
        
        -- print(i, i2)
        
        local x2, y2 = ellipse_points[i2], ellipse_points[i2 + 1]
        
        table.insert(star_points, x)
        table.insert(star_points, y)
        coor_count = coor_count + 1
        
        if coor_count == coor_limit then
            break
        end
        
        table.insert(star_points, x2)
        table.insert(star_points, y2)
        coor_count = coor_count + 1
        
        if coor_count == coor_limit then
            break
        end
        
    end
    
    -- star_points = table.slice(star_points,1, 10)
    
    -- for i,v in ipairs(star_points) do
    --     print('star_points',i,v)
    
    -- end
    -- print('points end')
    
    return star_points
end

function get_sin_line(div, cycles, offset)
    --get a sine line
    --cycles is amount of occilations (frequency)
    --div is number of coordinates
    --offset is 0 sine, 0.5 cosine, 1 sine
    
    offset = offset or 0
    
    local positions = {}
    
    -- local div = 5
    div = div - 1
    local scale = 400
    
    for i = 0, div do
        
        -- print(i/div) --goes 0-1
        i = i / div
        
        local val = math.sin(math.rad(i * 360 * cycles + offset * 360))
        local x = i
        local y = val
        
        table.insert(positions, x)
        table.insert(positions, y)
    end
    return positions
    
end

print(inspect(get_sin_line(1, 5)))

function get_spirograph_ellipse_points(segments, ...) --multiple pars must be in multiples of 2
    --segments is number of points
    --subsequent pars, amount of subcircles and subcircle maginitude
    --eg. funct(segments, 6, 0.5) looks like a spirograph
    local positions = {}
    local angle = 0
    for i = 1, segments do
        local x = math.sin(angle) --the basic circle
        local y = math.cos(angle)
        
        local pars = {...}
        local par_count = #pars
        for i = 1, par_count, 2 do
            local subcircles = pars[i]
            local subcircle_mag = pars[i + 1]
            x = x + math.sin(angle * subcircles) * subcircle_mag --the second circle offset
            y = y + math.cos(angle * subcircles) * subcircle_mag
        end
        
        table.insert(positions, x)
        table.insert(positions, y)
        angle = angle + math.rad(360 / segments)
    end
    return positions
end

function get_sin_ellipse_points(segments, ...)
    --segments: number of points
    --wiggles: number of loopy wiggles, eg 8 is 8 wiggles (best to keep int)
    --wiggle_mag: 1 means wiggles meet middle, 0.5 means they get half way in ellipse
    
    local positions = {}
    local angle = 0
    for i = 1, segments do
        
        local x = math.sin(angle) --basic circle
        local y = math.cos(angle)
        
        local pars = {...}
        local par_count = #pars
        for i = 1, par_count, 2 do
            local wiggles = pars[i]
            local wiggle_mag = pars[i + 1]
            x = x + x * math.sin(angle * wiggles) * wiggle_mag --the second circle offset
            y = y + y * math.sin(angle * wiggles) * wiggle_mag
        end
        
        table.insert(positions, x)
        table.insert(positions, y)
        angle = angle + math.rad(360 / segments)
    end
    return positions
end

function get_random_points(number) --get random points as floats between -1 and 1
    local points = {}
    for i = 1, number do
        table.insert(points, math.random() * 2 - 1)
        table.insert(points, math.random() * 2 - 1)
    end
    return points
end

function get_random_circle_points(number) --get random points inside a circle (with radius of 1, points ranging from -1 to 1)
    local points = {}
    for i = 1, number do
        local angle = math.rad(360 * math.random()) --random angle
        local magnitude = math.random() --distance from center
        local xPos = magnitude * math.cos(angle)
        local yPos = magnitude * math.sin(angle)
        table.insert(points, xPos)
        table.insert(points, yPos)
    end
    return points
end

local math_e = 2.71828
function normal_distribution(z) --kinda (not really)
    local ret = 1 / math.sqrt(2 * math.pi)
    ret = ret * math_e
    ret = math.pow(ret, -(math.pow(z, 2) / 2))
    return ret
end

-- function lerp(a,b,t) return (1-t)*a + t*b end
function lerp(a, b, t) return a + (b - a) * t end --linear interpolation

function lerp_2D(x1, y1, x2, y2, t)
    return lerp(x1, x2, t), lerp(y1, y2, t)
end

function random_point_on_line(x1, y1, x2, y2)
    local t = math.random()
    local x = lerp(x1, x2, t)
    local y = lerp(y1, y2, t)
    return x, y
end

function random_gaussian_point_on_line(x1, y1, x2, y2) --not always on the line, may be anywhere (in line with the line!)
    local guasian_val = ran_gaussian_distro_2D() --just get one nuber here
    return lerp_2D(x1, y1, x2, y2, (guasian_val) * 2 - 1)
end

function ran_gaussian_distro_2D(scale) --http://www.design.caltech.edu/erik/Misc/Gaussian.html //like a circle guasian
    -- scale = scale or 1
    local r1, r2 = math.random(), math.random()
    x = math.sqrt(-2 * math.log(r1)) * math.cos(2 * math.pi * r2)
    y = math.sqrt(-2 * math.log(r1)) * math.sin(2 * math.pi * r2)
    x, y = x * scale, y * scale
    return x, y
end

function gaussian_distro_1D_line(x1, y1, x2, y2, var) --does not cenxter properly yet --NOTT!!
    -- var = var or 1
    local x, y
    local ran = math.random()
    local ran = (ran_gaussian_distro_2D(var) + 1) / 2
    x, y = lerp_2D(x1, y1, x2, y2, ran)
    return x, y
end

function gaussian_distro_2D_line(x1, y1, x2, y2, lineVar, circleVar)
    --creates a random point based on a 2D line that is mostly between this line based on a normal distro
    --lineVar (normal point along line)
    --circleVar (normal point based on this line point)
    
    -- lineVar = lineVar or 1
    -- cirleVar = cirleVar or 1
    local ran = math.random()
    local x, y = 0, 0
    local xLine, yLine = gaussian_distro_1D_line(x1, y1, x2, y2, lineVar)
    x = x + xLine
    y = y + yLine
    
    local xGaussian, yGaussian = ran_gaussian_distro_2D(circleVar)
    
    x, y = x + xGaussian, y + yGaussian
    
    return x, y
    
end

print('EEEEE', math.exp(1))

require('my_lua_lib_colors')
