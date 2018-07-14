--[[
 
 
 
]]
inspect = require('inspect') --https://github.com/kikito/inspect.lua
json = require('json') --https://github.com/rxi/json.lua
function load_json_file(filename)
    return json.decode(assert(love.filesystem.read(filename)))
end
function save_json_file(filename, data)
    save_file(filename, json.encode(data))
end
function love.load()
    -- print(inspect(love))
    -- filename = './testfile.txt'
    -- save_to_file(filename, "test data")
    -- print(load_from_file(filename))
    -- save_to_file('inspect.love.txt', inspect(love))
    
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

function love_api_test()
    local big_love_table = love.filesystem.load("love_api.lua")() -- load the chunk
    -- print(inspect(big_love_table))
    
    -- local result = chunk() -- execute the chunk
    -- print('result: ' .. tostring(result)) -- prints 'result: 2'
    
    for _, v in pairs(big_love_table.functions) do
        print(_, v)
    end
end

function test_explore_api()
    print('test_explore_api...')
    
    --let's create a ball
    world = love.physics.newWorld(0, 9.81 * 64, true)
    
    objects = {}
    objects.ball = {}
    objects.ball.body = love.physics.newBody(world, 650 / 2, 650 / 2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
    objects.ball.shape = love.physics.newCircleShape(20) --the ball's shape has a radius of 20
    objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 1) -- Attach fixture to body and give it a density of 1.
    objects.ball.fixture:setRestitution(0.9) --let the ball bounce
    
    -- print(objects.ball.body)
    
    -- print(objects.ball.fixture)
    
    body_functions = {}
    fixture_functions = {}
    shape_functions = {}
    for k, v in pairs(getmetatable(objects.ball.body)) do --proves we can iterate the metadata!!!
        if type(v) == 'function' then
            table.insert(body_functions, k)
        end
    end
    for k, v in pairs(getmetatable(objects.ball.shape)) do --proves we can iterate the metadata!!!
        if type(v) == 'function' then
            table.insert(shape_functions, k)
        end
    end
    for k, v in pairs(getmetatable(objects.ball.fixture)) do --proves we can iterate the metadata!!!
        if type(v) == 'function' then
            table.insert(fixture_functions, k)
        end
    end
    print('Entity.body_functions = '..inspect(body_functions))
    print('Entity.fixture_functions = '..inspect(fixture_functions))
    print('Entity.shape_functions = '..inspect(shape_functions))
    
    save_json_file('physics_funtions.json', {
        body = body_functions,
        fixture = fixture_functions,
        shape = shape_functions
    })
    
end

test_explore_api()
