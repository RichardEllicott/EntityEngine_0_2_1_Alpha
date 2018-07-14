--[[
# Entity Engine Version 0.2.0 Alpha
 
 
CURRENTLY:
 
gamera is a bit convoluted for my code, but it has the solutions to rotation and mouse coordinates 
WE NEED TO MAKE THE CAMERA CODE SUPPORT CENTRAL ROTATION FROM THE MIDDLE and the MOUSE POS OF THIS
 
 
 
]]

--global to signal program to make certain debug behaviors (can't be called "debug" as this already exists)
--note this tends to causes crashes if the program is packaged as a love file due to usage of lua's filesystem
ee_debug = true

love.audio.setEffect('reverb', {
    type = 'reverb',
    gain = 2,
    decaytime = 3
})

sound_fire = love.audio.newSource('sounds/fire1.wav', 'static')
sound_death = love.audio.newSource('sounds/bump1.wav', 'static')
-- sound_death:setEffect 'reverb'

sound_zip = love.audio.newSource('sounds/zip1.wav', 'static')

local load_schemes = {}
load_schemes['main_physics_version1'] = function(...)
    -- love.graphics.setBackgroundColor(1, 0, 0)
    
    engine.teleport_border = true --experimental teleport off edges like asteroids
    
    local playerSpawn = engine:spawn('player', grid_coor_to_pos(0, 0))
    playerSpawn.width = 8
    playerSpawn.height = 8
    -- playerSpawn.image = love.graphics.newImage('error.png')
    playerSpawn:initialize_physics()
    -- playerSpawn:setFilterData(2, 1, 1)
    engine.controlled_unit = playerSpawn
    
    local bomb_spawn_test = engine:spawn('animation_test1', grid_coor_to_pos(2, 2)) --pretty much just testing an animation
    bomb_spawn_test:initialize_physics()
    
    local bomb_spawn_test = engine:spawn('animation_test2', grid_coor_to_pos(2, 4)) --pretty much just testing an animation
    bomb_spawn_test:initialize_physics()
    
    local crab_test = engine:spawn('crab', grid_coor_to_pos(5, 10))
    crab_test:initialize_physics()
    
    --with a random polygon
    
    -- local vector_spawn_test = engine:spawn('random_polygon', grid_coor_to_pos(50, 5))
    -- vector_spawn_test:initialize_physics()
    
    --NOTES UPROOTED FROM OLD PROJECT (THANK FUCK FOR THAT)
    -- self:setFilterData(1,1,1) default filter, like walls
    -- self:setFilterData(2,nil,nil) player filter, setting cat 2
    -- self:setFilterData(3,nil,nil) enemy filter, setting cat 3
    -- self:setFilterData(10,2,-1) player missile, ignore cat 2 and self
    -- self:setFilterData(10,3,-1) enemy missile, ignore cat 3 and self (note ignores player missile to)
    --the bug we had may be we cannot unpack nill????
    
    local missile_spawn_test = engine:spawn('missile', grid_coor_to_pos(8, 0))
    missile_spawn_test.radius = 8
    missile_spawn_test:initialize_physics()
    missile_spawn_test:setLinearVelocity(64, 0)
    -- missile_spawn_test:setFilterData(10, 2, -1)
    
    local teleport_test = engine:spawn('teleport', grid_coor_to_pos(4, -8))
    teleport_test:initialize_physics()
    
    -- engine:setGravity(0, 9.8)
    
    local test_modulate_shape = engine:spawn('test_modulate_shape', grid_coor_to_pos(12, 4))
    test_modulate_shape:initialize_physics()
    
    local test_edge = engine:spawn('edge_test', grid_coor_to_pos(14, 9))
    test_edge:initialize_physics()
    
end
load_schemes['animated_logo1'] = function(...)
    engine.debug_draw_message = false
    engine.debug_draw_cursor = false
    engine.background_animations = {
        UnicursalHexagramAnimation(),
        -- SpirographAnimation(), --one of the best looking
        -- CogAnimation(),
        -- CrowleyAnimation(), --the nice swords thing we done
        
        -- LordsCrossAnimation(),
        
        -- NoiseSquareAnimation(),
        -- TurtleAnimation(),
        
        -- GridAnimation(), --NOTE THIS SEEMS TO WORK WITHOUT CALLING IT (using brackets, easy bug to make)
        
        -- ParticleSystemAnimation(),
        -- LightningAnimation(),
        
        -- animationType2, --TESTING AnimationType2
        -- AnimationType2_Inherit(), --WORKING ON THESE DELETE THIS SHIT LATER!
        -- AnimationType2Teleport(), --WORKING ON THESE DELETE THIS SHIT LATER!
        -- TreeOfLifeAnimation(),
        -- TeleportAnimation(),
    }
end
load_schemes['grid_based_game'] = function(...) --game that is a sort of puzzle game
    engine:initialize_grid_map()
end
load_schemes['animations_test'] = function(...)
end
load_schemes['debug'] = function(...) --will be used to activate all the debug messages (none affect game)
    print('activating debug mode!')
end

require 'ee_redruth_library'
love.filesystem.addRequirePath('polygon-master/?.lua') --function from ee_redruth_library
local polygon = require('polygon') --warning i changed this to the relative paths
local class = require 'middleclass'
local json = require('json')
local inspect = require('inspect')
local Engine = require('ee_engine')

grid = {} --may be still used by a loader (deprecate)
grid.scale = 16 --note this is smaller than the engine one at 16 (deprecated, i think was used for json)

function grid_coor_to_pos(x, y)
    x, y = math.round(x) * grid.scale, math.round(y) * grid.scale
    return x, y
end

function pos_to_grid_coor(x, y)
    x, y = math.round(x / grid.scale), math.round(y / grid.scale)
    return x, y
end

function snap_to_grid(x, y)
    return grid_coor_to_pos(pos_to_grid_coor(x, y))
end

--[[
MOVE OR DEPRECATE
 
local ImageCache = class('ImageCache') --stores images, use get(image_path)
function ImageCache:get(image_path)
    if not self[image_path] then
        -- self[image_path] =
        self[image_path] = love.graphics.newImage(image_path)
    end
    return self[image_path]
end
local imageCache = ImageCache()
]]

Camera = require 'ee_camera'

camera = Camera() --GLOBAL, used by engine (TRYING TO MAKE MORE OR LESS COMPATIBLE WITH GAMERA MAYBE)

-- camera.follow_controlled_unit = true

local mouse = {}
mouse.x, mouse.y = 0, 0

screen = {}
screen.width, screen.height = love.graphics.getWidth(), love.graphics.getHeight()

local grid = {} --NO IDEA AGAIN!
grid.scale = 64

function love.load(arg)
    -- love.window.setFullscreen(true) --HACK, we cannot flick this setting yet!
    engine = Engine()
    engine:init() --initialize of engine is now manual
    engine.camera.x = -love.graphics.getWidth() / 2 --locking our camera so that the middle is the
    engine.camera.y = -love.graphics.getHeight() / 2
    
    -- for k, v in pairs(load_schemes) do
    --     v()
    -- end
    
    if ee_debug then --save all load schemes to a files WARNING DISABLED, this was a prototype idea, it crashes the love file
        -- for k, load_scheme in pairs(load_schemes) do
        --     local s = ''
        --     string_to_file('debug/filename_' .. k .. '.md', 'some stuff...') --maybe add to reflection folder for python scripts
        -- end
    end
    
    --LOAD SCHEMES IMPORTANT (we may move this to the actual Engine itself, possibly to another file)
    load_schemes['main_physics_version1']() --the manual load test with physics and stuff
    -- load_schemes['animated_logo1']() --the manual load test with physics and stuff
    -- load_schemes['grid_based_game']() --for the grid based game, note at the moment, we have an init issue,
    -- load_schemes['debug']() --loads the UI messages etc for debugging
    
    --#### TWO ALTERNATE LOADS
    -- new_stuff_love_load()
    
    -- load_from_json_test1()
    
    -- polySpawn = engine:spawn('polygon', grid_coor_to_pos(0, 0))
    -- polySpawn:initialize_physics()
    
    -- orginal_love_load()
    
end

function love.quit()
    
    -- love.filesystem.write( 'Save.lua', save ) --DEPRECATE
    
    print('FIN PROGRAM')
    
end

function load_from_json_test1()
    local filename = 'enity_engine1.tmx.json'
    
    local engine = engine
    
    json_ob = load_json_file(filename)
    
    local load_object_layers = true
    -- local load_tile_layers = true
    
    --set gravity from json
    local gravityX, gravityY = 0, 0
    if json_ob.gravityX then
        gravityX = json_ob.gravityX
    end
    if json_ob.gravityY then
        gravityY = json_ob.gravityY
    end
    world:setGravity(gravityX, gravityY)
    
    --all the tiles
    -- local image_cache = {}
    -- local image_cache_length = 0
    -- for key, val in pairs(json_ob.tiles) do --iterate all the tiles
    --     print('found tile:', key, val.image_source)
    --     local image = love.graphics.newImage(val.image_source)
    --     image_cache[val.image_source] = image
    --     -- image_cache[key] = image
    --     image_cache_length = image_cache_length + 1
    -- end
    -- print('image_cache_length', image_cache_length)
    -- print (inspect(image_cache))
    
    -- print (inspect(json_ob))
    -- print (inspect(json_ob.object_layers))
    
    print('xxxxxxxxxxxxxxxxxxxxxxx', json_ob.backgroundcolor)
    -- love.graphics.setBackgroundColor( json_ob.backgroundcolor )
    -- love.graphics.setBackgroundColor(44, 22, 0)
    
    if load_object_layers then
        for i, layer in ipairs(json_ob.object_layers) do --iterate all object layers
            if layer.visible then
                for _, object in ipairs(layer.objects) do
                    if object.visible then
                        
                        local spawn --we're sort of unsure about when this gets cleaned up (it's nil)!!
                        
                        if object.rotation == nil then
                            object.rotation = 0
                        end
                        
                        local spawn_type = 'static'
                        if object.type == 'dynamic' then
                            spawn_type = 'dynamic'
                        elseif object.type == 'sensor' then
                            -- spawn_type = 'sensor'
                        end
                        
                        if object.type == 'player' then --spawn player --moving down page
                            spawn = engine:spawn('player', object.x, object.y, math.rad(object.rotation))
                            
                            spawn.width = object.width
                            spawn.height = object.height
                            
                            spawn.draw_image = true
                            
                            --test, make player circle
                            spawn.shape = 'circle'
                            spawn.radius = object.width / 2
                            
                            spawn:add_event('beginContact', function (self)
                                print('player beginContact PLAYER', self.name, self.type)
                            end)
                            
                            -- spawn:initialize_physics()
                            engine.controlled_unit = spawn
                            
                            if object.gid then
                                gid_str = string.format('%s', object.gid)
                                local tile = json_ob.tiles[gid_str]
                                -- spawn.image = image_cache[tile.image_source]
                                spawn.image = imageCache:get(tile.image_source)
                            end
                            
                            spawn.debug_draw_physics_shape = true
                            
                            -- spawn:destroy()
                            
                        else
                            if nil then
                                
                            elseif object.object_type == 'ellipse' then
                                -- error('ellipse type not supported')
                                
                                --OFFSET CORRECTION, this is likely the best place for it
                                object.x = object.x + (object.width / 2)
                                object.y = object.y + (object.width / 2)
                                
                                print('WARNING ellipse type not supported, using circle with width')
                                spawn = engine:spawn(spawn_type, object.x, object.y, math.rad(object.rotation))
                                spawn.shape = 'circle'
                                spawn.radius = object.width / 2
                                spawn.width = object.width
                                spawn.height = object.width
                                -- spawn:initialize_physics()
                                
                                spawn.draw_image = true
                                
                            elseif object.object_type == 'rectangle' or object.object_type == 'tile' then
                                
                                --OFFSET CORRECTION, this is likely the best place for it
                                object.x = object.x + (object.width / 2)
                                object.y = object.y + (object.height / 2)
                                
                                spawn = engine:spawn(spawn_type, object.x, object.y, math.rad(object.rotation))
                                spawn.width = object.width
                                spawn.height = object.height
                                spawn.shape = 'rectangle'
                                
                                if object.shape == 'circle' then --for tiles mainly
                                    spawn.shape = 'circle'
                                    spawn.radius = object.width / 2
                                end
                                
                                spawn.draw_image = true
                                
                                if object.gid then
                                    gid_str = string.format('%s', object.gid)
                                    local tile = json_ob.tiles[gid_str]
                                    
                                    -- spawn.image = image_cache[tile.image_source]
                                    spawn.image = imageCache:get(tile.image_source)
                                    
                                end
                                
                            elseif object.object_type == 'polygon' then
                                
                                point_count = #object.polygon_points
                                
                                print('SPAWNING POLYGON', inspect(object.polygon_points))
                                
                                -- print ('point_count:', point_count)
                                -- print('POLYGON POINTS FOR SPAWN:', inspect(object.polygon_points))
                                -- print('IS CONVEX', polygon_is_convex(object.polygon_points))
                                
                                -- number = 13
                                -- if (number % 2 == 1) then
                                --     print('Warning, polygon points must be of an even number')
                                --     error('FEKKING HELL')
                                -- else
                                -- end
                                
                                spawn = engine:spawn(spawn_type, object.x, object.y, math.rad(object.rotation))
                                spawn.shape = 'polygon'
                                
                                -- if #object.polygon_points > 16 then --currently just skip these
                                --     -- error('TOO MANY POLY POINTS')
                                --     spawn.shape = 'advanced_polygon'
                                -- else
                                
                                spawn.polygon_points = object.polygon_points
                                
                            end
                            
                        end
                        
                        if spawn then
                            if object.disable_physics then
                                -- if object.physics and object.physics == false then
                            else
                                spawn:initialize_physics()
                            end
                            
                            if object.color then
                                -- print('COLOOOOOSOSOSOS', inspect(object.color))
                                spawn.image_colorise = object.color
                                
                            end
                        end
                        
                        if object.type == 'sensor' then
                            spawn:setSensor(true)
                        end
                        if spawn then
                            spawn.name = object.name
                        end
                        if object.dead then
                            
                            spawn:destroy()
                        end
                        
                        if object.sensor then
                            spawn:setSensor(true)
                        end
                        
                        if object.destroy_on_contact then
                            spawn:add_event('beginContact', function(self)
                                self:destroy()
                                print('DEATH ON CONTACT!!!!!!!!!!!')
                            end)
                        end
                        
                        if object.collects then
                            spawn.collects = true
                            -- print('collectscollectscollectscollectscollectscollectscollects')
                        end
                        if object.collectable then
                            spawn.collectable = true
                            -- print('collectablecollectablecollectablecollectablecollectablecollectable')
                        end
                        
                        if spawn.physics_object then
                            local LinearVelocityX = 0
                            local LinearVelocityY = 0
                            if object.velocityX then
                                LinearVelocityX = object.velocityX
                            end
                            if object.velocityY then
                                LinearVelocityY = object.velocityY
                            end
                            spawn.physics_object.body:setLinearVelocity(LinearVelocityX, LinearVelocityY)
                        end
                        
                        spawn.width = object.width
                        spawn.height = object.height
                        
                        if object.draw_image then
                            --picks up the custom property, this means we can draw an image for polygons
                            --make sure to also set a height and width as polygons don't usually have this
                            
                            spawn.draw_image = true
                        end
                        
                    end
                end
            end
        end
    end
    
    if load_tile_layers then
        for _, layer in ipairs(json_ob.tile_layers) do --iterate all tile layers
            -- print('found tile_layer:', layer.name)
            
            if layer.visible then
                -- print('SSSXXXX')
                
                for y, row in ipairs(layer.data) do
                    
                    -- print(inspect(row))
                    for x, val in ipairs(row) do
                        
                        if val ~= 0 then
                            -- print('TILE', x, y)
                            
                            local spawn_pos = {(x - 1) * json_ob.tilewidth, (y - 1) * json_ob.tileheight}
                            print('SPAWN TILE', inspect(spawn_pos))
                            
                            --OFFSET correction
                            spawn_pos[1] = spawn_pos[1] + json_ob.tilewidth / 2
                            spawn_pos[2] = spawn_pos[2] + json_ob.tileheight / 2
                            
                            local spawn = engine:spawn('static', spawn_pos[1], spawn_pos[2])
                            spawn.shape = 'rectangle'
                            spawn.width = json_ob.tilewidth
                            spawn.height = json_ob.tileheight
                            
                            spawn.draw_image = true
                            
                            -- engine:spawn('player', object.x, object.y, math.rad(object.rotation))
                            
                            -- spawn:initialize_physics()
                        end
                        
                    end
                end
                
            end
            
            -- print_map(layer.data)
            
        end
    end
    
    -- print(inspect(json_ob))
    
    -- print(json_ob.tilewidth)
    
    -- print('inspect(image_cache)',inspect(image_cache))
    
    if engine.controlled_unit then
        -- camera.scale = 2
        camera.x = -engine.controlled_unit:getX() + (screen.width / 2)
        camera.y = -engine.controlled_unit:getY() + (screen.height / 2)
    end
    -- engine.controlled_unit = spawn
    
end

function new_stuff_love_load_test()
    local filename = 'TestGID.tmx.format1.json'
    
    -- local jstuff = json.open('TestGID.tmx.format1.json')
    local file, message = io.open(filename, "r")
    
    json_string = file:read('*a')
    -- print (json_string)
    
    json_ob = json.decode(json_string)
    
    print('tiles', inspect(json_ob.tiles))
    -- print('map', inspect(json_ob.map))
    -- print('tiles', inspect(json_ob.tiles))
    
    -- print (inspect(json.decode('[1,2,3,{"x":10}]')))
    
    -- print ('testtilelookup',inspect(json_ob.tiles["1"]))
    print ('testtilelookup', json_ob.tiles["1"].image_source)
    print ('testtilelookup', json_ob.tiles["100"])
    
    for y, row in ipairs(json_ob.map) do
        row_string = ''
        for x, v in ipairs(row)do
            if v ~= 0 then
                
                row_string = row_string .. v[1] .. ', '
            else
                row_string = row_string .. 0 .. ', '
            end
            row_string = row_string .. x - 1 .. ',' .. y - 1 .. ' '
            
            -- print (string.format ("To wield the %s you need to be level %i", "sword", 10))
            
        end
        print('row_string', row_string)
        -- for j, v2 in ipairs(v) do -- takes the 'object' in 'v' and iterates sub
        -- print(i .. ' ' .. j .. ': ' .. v2 .. 'name or xp');
        -- end
    end
    
    test_list = {1, 3, 5, 6, 7, 8}
    print(inspect(test_list))
    
    print('stufffff', test_list[4])
    
    function testFuct(...)
        
        -- body
    end
    
    print(testFuct)
    print(inspect(testFuct))
    
    NIL = {}
    
    nil_table_test = {2, 3, 4, NIL, 5, NIL, 7}
    print('sss', inspect(nil_table_test))
    
    nil_table_test = {2, 3, 4, nil, 5, 6, 7}
    print('sss', inspect(nil_table_test))
    
    nil_table_test = {1, 2, 3, 4, 8}
    print('sss', inspect(nil_table_test))
    
end

function orginal_love_load_test() --written ages ago showing the light stuff
    
    engine = Engine()
    
    spawn1 = engine:spawn('test', 20, 0)
    spawn2 = engine:spawn('test2', grid_coor_to_pos(1, 1))
    
    -- spawn3 = engine:spawn('static', grid_coor_to_pos(0,4))
    spawn3 = engine:spawn('platform', grid_coor_to_pos(0, 4))
    
    -- spawn1:setSensor(true)
    
    spawn1:initialize_physics()
    spawn2:initialize_physics()
    spawn3:initialize_physics()
    
    spawn4 = engine:spawn('test2', grid_coor_to_pos(1, 1))
    spawn4:initialize_physics()
    
    playerSpawn = engine:spawn('player', grid_coor_to_pos(0, 0))
    playerSpawn:initialize_physics()
    engine.controlled_unit = playerSpawn
    
    for n, v in ipairs(engine.entities) do
        print(n, v, v.type)
    end
end

function love.update(dt)
    engine:update(dt) --the engine now handles the physics updates etc
end

function love.draw()
    engine:draw()
end

