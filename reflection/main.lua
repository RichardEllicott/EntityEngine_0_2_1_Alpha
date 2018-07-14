--[[
 
loads some physics objects, scans them for the function names and prints as lua tables (to be pasted in main code)
 
]]
inspect = require('inspect') --https://github.com/kikito/inspect.lua

function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

function string.ends(String, End)
    return End == '' or string.sub(String, -string.len(End)) == End
end

function main()
    world = love.physics.newWorld(0, 9.81 * 64, true)
    objects = {}
    objects.ball = {}
    objects.ball.body = love.physics.newBody(world, 650 / 2, 650 / 2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
    objects.ball.shape = love.physics.newCircleShape(20) --the ball's shape has a radius of 20
    objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 1) -- Attach fixture to body and give it a density of 1.
    objects.ball.fixture:setRestitution(0.9) --let the ball bounce
    
    body_functions = {}
    fixture_functions = {}
    shape_functions = {}
    for k, v in pairs(getmetatable(objects.ball.body)) do --proves we can iterate the metadata!!!
        if type(v) == 'function' then
            if not string.starts(k, '_') then
                table.insert(body_functions, k)
            end
        end
    end
    for k, v in pairs(getmetatable(objects.ball.shape)) do --proves we can iterate the metadata!!!
        if type(v) == 'function' then
            if not string.starts(k, '_') then
                table.insert(shape_functions, k)
            end
        end
    end
    for k, v in pairs(getmetatable(objects.ball.fixture)) do --proves we can iterate the metadata!!!
        if type(v) == 'function' then
            if not string.starts(k, '_') then
                table.insert(fixture_functions, k)
            end
        end
    end
    print('Entity.body_functions = '..inspect(body_functions))
    print('Entity.fixture_functions = '..inspect(fixture_functions))
    print('Entity.shape_functions = '..inspect(shape_functions))
end

main()
