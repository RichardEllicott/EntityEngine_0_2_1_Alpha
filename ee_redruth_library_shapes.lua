--[[
 
making shapes and things (not turtle ones)... spirograph pattern etc
 
 
]]

function get_ellipse_points(segments, xRadius, yRadius)
    --standard ellipse (or circle)
    xRadius = xRadius or 1 --default to 1
    yRadius = yRadius or xRadius --default to circle
    
    local positions = {}
    local angle = 0
    local angle_inc = math.rad(360 / segments)
    for i = 1, segments do
        local x = math.sin(angle) * xRadius
        local y = math.cos(angle) * yRadius
        table.insert(positions, x)
        table.insert(positions, y)
        angle = angle + angle_inc
    end
    return positions
end

function get_cog_points(segments, radius, depth, period)
    period = period or 2
    local positions = {}
    local angle = 0
    local angle_inc = math.rad(360 / segments)
    
    local counter = 0
    local inner = true
    
    for i = 1, segments do
        local depth1 = 0
        
        if counter >= period then
            inner = not inner
            counter = 0
        end
        if inner then
            depth1 = -depth
        end
        
        local x = math.sin(angle) * (radius - depth1)
        local y = math.cos(angle) * (radius - depth1)
        table.insert(positions, x)
        table.insert(positions, y)
        angle = angle + angle_inc
        
        counter = counter + 1
    end
    return positions
    
end

function get_ellipse_points_ran(segments, seed)
    --making a random boulder type thing from ellipse
    local angles = {}
    local total_ang = 0
    for i = 1, segments do
        r = math.random()
        table.insert(angles, r)
        total_ang = total_ang + r
    end
    for i = 1, #angles do --ensure the total of angles add up to 1 for 1 rotation
        angles[i] = angles[i] / total_ang
    end
    
    local positions = {} --FAILED! was attempting to take random points on a circle
    local angle = 0
    for i = 1, segments do
        local x = math.sin(angle)
        local y = math.cos(angle)
        table.insert(positions, x)
        table.insert(positions, y)
        angle = angle + math.rad((360 - 10) / angles[i])
    end
    print('pspspssp', inspect(positions))
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

function get_lightning_positions(x1, y1, x2, y2, divisions, variance)
    --get positions of lightning for a lighting bolt
    --x1,y1 is the start position
    --x2,y2 is the end position
    --divisions is the amount of times to have a break in the line
    --this function is typically called at random time intervals with random divisions perhaps
    local points = get_points_on_line(x1, y1, x2, y2, divisions + 2) --makes the first and last coordinates stationary
    for i = 3, #points - 2 do
        points[i] = points[i] + math.random() * variance - variance / 2
    end
    return points
end

--[[
Follows is the polygon reduction code, this code was inspired by:
https://uk.mathworks.com/matlabcentral/fileexchange/45342-polygon-simplification
functions:
* polygon_vertex_at_position
* polygon_vertex_at_position_wrapped
* math.dist
* math.angle
* polygon_vertex_importance
* polygon_reduce1
* polygon_reduce
 
possible optimizations:
* it simply runs the same function for removing more than one vertex at the moment as I have just used a quick and easy recursion
    -that is why we have "polygon_reduce1", which won't be there later
]]

function polygon_vertex_at_position(polygon, position)
    --gets a vertex by reference number (starts at 1 like lua)
    return polygon[position * 2 - 1], polygon[position * 2]
end

function polygon_vertex_at_position_wrapped(polygon, position)
    --wrapped version, makes it easy to get next vertex even when at end, you could input any number
    local new_vertex_pos = ((position - 1) % (#polygon / 2)) + 1
    return polygon_vertex_at_position(polygon, new_vertex_pos)
end

function math.dist(x1, y1, x2, y2)
    --distance between two points
    return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5
end
function math.angle(x1, y1, x2, y2)
    --angle between two vectors
    return math.atan2(y2 - y1, x2 - x1)
end

function polygon_vertex_importance(polygon, position) --v is vertex number, polygon is points, numv is total number vertexes
    --generate a value of vertex importance
    local x, y = polygon_vertex_at_position_wrapped(polygon, position)
    local xp, yp = polygon_vertex_at_position_wrapped(polygon, position + 1)
    local xn, yn = polygon_vertex_at_position_wrapped(polygon, position - 1)
    
    local product_of_face_lengths = math.dist(x, y, xn, yn) * math.dist(x, y, xp, yp)
    
    local angle1 = math.angle(x, y, xn, yn) --get the two angles that go out from the vertex
    local angle2 = math.angle(x, y, xp, yp)
    
    --we need to find the angle between the two angles, possible refactor here
    local angle_between = angle1 - angle2
    
    local angle_difference_from_180 = (180 + math.deg(angle_between)) % 360 --the mods sort out a wrapping issue
    if angle_difference_from_180 > 180 then --this means if the angle is over 180 reverse it
        angle_difference_from_180 = 360 - angle_difference_from_180
    end
    
    return angle_difference_from_180 * product_of_face_lengths --angle importance is built of the divergence from 180 it is, and the lengths multiplied
    
end

function polygon_reduce1(polygon)
    --take an input polygon (a table like {x1,y1,x2,y2...})
    --find the least important vertex
    --return a new polygon with this vertex removed
    local number_of_vertices = #polygon / 2 --the number of coordinates in this table
    local vertex_importances = {} --gather the ver
    for i = 1, number_of_vertices do
        table.insert(vertex_importances, polygon_vertex_importance(polygon, i))
    end
    local lowest_vertex_importance = vertex_importances[1] --find which vertex importance is lowest
    local least_important_vertex = 1
    for i, v in ipairs(vertex_importances) do
        if v < lowest_vertex_importance then
            lowest_vertex_importance = v
            least_important_vertex = i
        end
    end
    local new_polygon = {} --finally rebuild a new polygon with the least important vertex removed
    for i = 1, number_of_vertices do
        if i ~= least_important_vertex then
            local x, y = polygon_vertex_at_position(polygon, i)
            table.insert(new_polygon, x)
            table.insert(new_polygon, y)
        end
    end
    return new_polygon
end

function polygon_reduce(polygon, vertices_to_remove)
    --reduce a polygons detail by removing least important vertices
    --vertices_to_remove is the number of vertices to shave, default is one
    --note: this code is very much similar to what would be used in a vector graphics package, i use it to reduce the detail after chopping polygons up with boolean functions
    --was inspired by "https://uk.mathworks.com/matlabcentral/fileexchange/45342-polygon-simplification" but we couldn't figure out the matrix code, has some difference in the maths but gives the same results
    vertices_to_remove = vertices_to_remove or 1 --default remove one vertex
    for i = 1, vertices_to_remove do
        polygon = polygon_reduce1(polygon)
    end
    return polygon
end
