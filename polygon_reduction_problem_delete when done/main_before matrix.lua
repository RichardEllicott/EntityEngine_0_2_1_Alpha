
--https://www.mathworks.com/matlabcentral/fileexchange/45342-polygon-simplification
--https://blogs.mathworks.com/pick/2014/02/07/downsampling-polygons/

example_polygon = {--example polygon
    100, 100, --1
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

function get_vertex_count(poly)
    local count = #poly
    assert(count % 2 == 0) --must be an even number to be coordinates
    return count / 2
end

print('get_vertex_count', get_vertex_count(example_polygon))

function get_vertex(poly, v) --gets a vertex by reference number (starts at 1 like lua)
    return poly[v * 2 - 1], poly[v * 2]
end

function get_vertex_wrapped(poly, v) --includes luas confusing modulo, function made just to simplify this
    local new_vertex_pos = ((v - 1) % get_vertex_count(poly)) + 1
    return get_vertex(poly, new_vertex_pos)
end

-- print('get_vertex_wrapped', get_vertex_wrapped(example_polygon, 0))

-- print('get_vertex', get_vertex(example_polygon, 1))

print('list our coordinates...')
for i = 1, #example_polygon / 2 do
    print('get_vertex', i, get_vertex(example_polygon, i))
end

function vertex_importance(v, poly, numv) --v is vertex number, poly is points, numv is total number vertexes
    local x, y = get_vertex_wrapped(poly, v)
    local xp, yp = get_vertex_wrapped(poly, v + 1)
    local xn, yn = get_vertex_wrapped(poly, v - 1)
    
    --WE GOT UP TO GATHER ADJACENT VERTEX COORDINATES
    
    --we now need to get the lengths of the lines as vectors, arccos them
    
    -- local p_len =
    
end

print('vertex_importance', vertex_importance(1, example_polygon, 11))

function poly_reduce(poly)
    
    numv = #poly / 2
    print('numv', numv)
    
    new_poly = {}
    for _, v in ipairs(poly) do
        -- print(v)
        --we will need the polygon in coors (x,y)
        
    end
    
    return poly
end

reduced_example_polygon = poly_reduce(example_polygon, 1)

love.graphics.setPointSize(10)

function love.draw()
    love.graphics.setColor(1, 1, 0)
    love.graphics.line(example_polygon)
    love.graphics.points(example_polygon)
    
    love.graphics.setColor(1, 0, 1)
    love.graphics.line(reduced_example_polygon)
    love.graphics.points(reduced_example_polygon)
    
end
