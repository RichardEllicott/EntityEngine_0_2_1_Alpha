
--[[
 
https://www.mathworks.com/matlabcentral/fileexchange/45342-polygon-simplification
https://blogs.mathworks.com/pick/2014/02/07/downsampling-polygons/
 
this port is not exactly the same, but i am pretty sure it does exactly the same
 
an "importance" value is generated for each vertex
this is based on the product of the lengths of the two connected faces
then it is multiplied by the difference the angle is from the ideal 180 (we can loose any 180 degree vertices)
 
the original matlab version used matrices, i did not. Also I notice it used "acos" at the point I had difficulty understanding the matlab code
my solution uses atan2 to get the angle
 
]]

example_polygon = {--example polygon
    100, 50, --1
    200, 50,
    300, 100,
    400, 100,
    500, 200,
    500, 300,
    400, 400,
    300, 300,
    200, 400,
    100, 400,
    200, 300,
    100, 150, --12
}

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

reduced_example_polygon = polygon_reduce(example_polygon, 3)

function draw_lines_of_polygon(polygon)
    --take polygon points, and draws lines for all these points
    --but also draws the final line from the end back to the start again to we can see the polygon easily
    love.graphics.line(polygon)
    love.graphics.line(polygon[1], polygon[2], polygon[#polygon - 1], polygon[#polygon])
    -- love.graphics.points(polygon)
end

function love.draw()
    
    love.graphics.setPointSize(10)
    love.graphics.setLineWidth(4)
    
    love.graphics.setColor(1, 1, 0, 0.5)
    draw_lines_of_polygon(example_polygon)
    
    love.graphics.setColor(1, 1, 1)
    draw_lines_of_polygon(reduced_example_polygon)
    
end
