--[=====[
 
 
 
--]=====]

local class = require 'middleclass'
local Properties = require('middleclass_properties') --a mixin that adds properties to middleclass

local SharedClass = require 'ee_sharedclass'
local inspect = require('inspect')
local polygon = require('polygon') --warning i changed this to the relative paths

local Entity = class('Entity', SharedClass)
Entity = Entity:include(Properties) --new properties version

function Entity:initialize(type, x, y, angle)
    
    -- self.death_sound = love.audio.newSource('sounds/058385b1e6d806e2.wav', 'static')
    
    -- print(string.format('new Entity: %s %s %s %s', type, x, y, angle))
    self:position(x, y, angle)
    self.type = type
    self:setup(type) --note runs after default values
    
end
Entity._x = 0
Entity._y = 0
Entity._angle = 0
Entity.radius = 32

Entity.shape = 'circle'
Entity.width = 64
Entity.height = 64

-- Entity.alive = true --Not used, instead Entity is assumed alive, if dead, Entity.dead = true
function Entity:destroy()
    self.dead = true
    
    if self.physics_object then
        for _, fixture in ipairs(self.physics_object.fixtures) do
            fixture:destroy()
        end
        self.physics_object.body:destroy()
    end
    
    self:run_events('destroy') --event system not yet used
    
end

Entity.engine = nil

function Entity:setup(string) --string is the 'type'
    
    -- self:setFixtureGroupIndex(0)
    -- self.type = string
    
    if not string or string == '' then
        error('empty setup string!')
        
    elseif string == 'player' then --IMPORTANT
        self.name = 'player1'
        self.physics_body_type = 'dynamic'
        -- self.shape = 'circle'
        self.shape = 'rectangle'
        self.height = 32
        self.width = 32
        self.radius = 8
        self.fixed_rotation = true
        self.physics_linear_damping = 1
        self.move_speed = 10
        self.move_mode = 0
        
        -- self.animation = CogAnimation()
        self.animation = ParticleSystemAnimation()
        
        -- self:setFixtureGroupIndex(0)
        
        -- print('TESTING NEW REFLECTION...')
        -- self:setRestitution_(10) --TESTING NEW REFLECTION (WE MIGHT NOT USE THIS)
        
    elseif string == 'missile' then --IMPORTANT
        
        self.physics_body_type = 'dynamic'
        self.destroy_on_contact = true --MAY REPLACE WITH EVENT SYSTEM
        self:setSensor(true)
        self.radius = 8
        
        self.death_timer = 4 --timer for automatic death
        
        -- self:add_beginContact_event( --THIS EVENT SYSTEM DOES NOT WORK AT THE MOMENT, MAY BE OVER ENGINEERED
        --     function ()
        --         print('missile contact')
        --     end
        -- )
        
    elseif string == 'crab' then
        self.polygon_points = {0, 0, 32, 64, 64, 64, 96, 0, 80, -32, 64, -16, 80, 16, 16, 16, 32, -16, 16, -32} --crab ship
        self.shape = 'polygon'
        self.name = 'poly the crab'
        
    elseif string == 'block' then --typically the static game "grid" sized blocks, first test of mouse spawning
        self.shape = 'rectangle'
        self.width = 16
        self.height = 16
        self.physics_body_type = 'static'
        -- self.image = love.graphics.newImage('error.png')
        
    elseif string == 'animation_test1' then --standard frames
        
        self.height = 16
        self.width = 16
        self.frames = {
            love.graphics.newImage('error.png'),
            love.graphics.newImage('error2.png'),
        }
        self.frame_durations = {1, 0.2}
        -- self.animate = true --this one now enables animation
        self.frame_duration = 0.2
        self.animation_timer = 0
        self.frame_position = 1
        self.radius = 8
        
    elseif string == 'animation_test2' then --testing animation system
        
    elseif string == 'platform' then --TEST
        self.physics_body_type = 'static'
        self.shape = 'rectangle'
        self.width = 64 * 8
        self.height = 64
        
    elseif string == 'static' then --TEST
        self.physics_body_type = 'static'
        -- self.shape = 'rectangle'
        
    elseif string == 'sensor' then --TEST
        self.physics_body_type = 'static'
        -- self.shape = 'rectangle'
        self:setSensor(true)
        
    elseif string == 'dynamic' then --TEST
        self.physics_body_type = 'dynamic'
        -- self.shape = 'rectangle'
        
    elseif string == 'polygon' then --TEST
        self.physics_body_type = 'static'
        -- self.shape = 'polygon'
        self.shape = 'polygon'
        -- self.polygon_points = {{0, 0}, {40, -16}, {64, 16}, {16, 24}}
        self.polygon_points = {0, 0, 40, -16, 64, 16, 16, 24} --change to just "points"?
        
    elseif string == 'edge_test' then
        self.physics_body_type = 'static'
        self.shape = 'edge'
        self.edge_points = {0, 0, 20, 20}
        
    elseif string == 'teleport' then --IMPORTANT
        
        self.physics_body_type = 'sensor'
        self.shape = 'circle'
        self.physics_body_type = 'static'
        self.physics_sensor = true
        
    elseif string == 'test_modulate_shape' then --IT SEEMS WE WOULD NEED TO ACTUALLY DESTORY AND CREATE THE SHAPE
        self.physics_body_type = 'static'
        self.shape = 'circle' --we have only managed to check circle so far
        -- self.shape = 'rectangle'
        self.test_modulate_shape = true
        
    elseif string == 'random_polygon' then --IMPORTANT
        self.polygon_points = polygon.random(0, 0, 30, 5) --note this polygon code is odd, replace
        -- self:setSensor(true) --PROVES SENSORS HIT SENSORS
        self.shape = 'polygon'
        
        -- self.polygon_points = scale_points(get_ellipse_points(10), 100, 100)
        -- self.polygon_points = scale_points(get_ellipse_points_ran(10), 100, 100)
        
        -- vector_spawn_test.x = 500
        -- vector_spawn_test.physics_body_type = 'dynamic'
        -- vector_spawn_test:initialize_physics()
        --LOOKUP THREADS, love vs lua
    elseif string == 'grid_map_object' then --IMPORTANT, testing the new grid map mode
        self.shape = 'rectangle'
        self.width = engine.grid_spacing
        self.height = engine.grid_spacing
        
    else
        print('WARNING, unrecognized setup string: ' .. string)
        error('fuck')
    end
end

Entity.mass = 1
Entity.physics_linear_damping = 0
Entity.physicsAngularDamping = 1
Entity.restitution = 0.4

Entity.physics_body_type = 'dynamic'

Entity.physics_fixture_density = 1

Entity.fixed_rotation = false

Entity.collects = false --this unit "collects" other units that are "collectable"
Entity.collectable = false

function Entity:initialize_physics()
    
    --STUFF WE MIGHT WANT TO CHANGE REALTIME:
    --position angle done
    --size?!?! bouncy, strip project to remove bug
    
    if not self.physics_object then
        
        self.physics_object = {} --create a container for the physics_data
        
        self.physics_object.settings = {} --used by the reflections system to save physics settings *before* physics is initialized
        
        local body = love.physics.newBody(engine.physics_world, self._x, self._y, self.physics_body_type) --warning uses global, the issue cropped up when making that sensor for the cursor spawning
        -- self.physics_object.b = body --CORRECTION TO OFFSET
        self.physics_object.body = body
        
        -- body:setMass(self.mass)
        
        local shapes = {}
        self.physics_object.shapes = shapes
        local fixtures = {}
        self.physics_object.fixtures = fixtures
        -- self.physics_object.f = fixtures
        
        if self.shape == 'circle' then --circle
            local circle = love.physics.newCircleShape(self.radius)
            table.insert(shapes, circle)
            -- self.physics_object.s = circle
            self.circle = true --booleans are quicker to check on draw
            
            --OFFSET CORRECTION, moved to JSON SPAWN
            -- self:setX(self._x + self.radius) --correction for circle WARNING WRONG PLACE FOR THIS CORRECTION
            -- self:setY(self._y + self.radius)
            
        elseif self.shape == 'rectangle' then --rectangle
            
            local rectangle = love.physics.newRectangleShape(self.width, self.height)
            table.insert(shapes, rectangle)
            
            --OFFSET CORRECTION, moved to JSON SPAWN
            -- self:setX(self._x + (self.width / 2)) --rectangle is from the center, therefore we need to correct this WARNING WRONG PLACE FOR THIS CORRECTION
            -- self:setY(self._y + (self.height / 2))
            
            self.physics_object.s = rectangle
            self.rectangle = true
            
        elseif self.shape == 'edge' then
            print('WARNING!!!! EDGE NOT FULLY WORKING!!! ALSO LOOK AT CHAIN')
            assert (#self.edge_points == 4) --must be 4 coordinates, for 1 edge, no more or less
            local edge = love.physics.newEdgeShape(self.edge_points[1], self.edge_points[2], self.edge_points[3], self.edge_points[4])
            table.insert(shapes, edge)
            
        elseif self.shape == 'polygon' then --simple polygon
            self.polygon = true
            
            self:setX(self._x) --the origin of a polygon is from the first point
            self:setY(self._y)
            
            self.triangulate_shape = true --default is false
            if not love.math.isConvex(self.polygon_points) or #self.polygon_points > 16 then --if the polygon is concave
                self.triangulate_shape = true --ensure it is triangulated
            end
            
            if self.triangulate_shape then
                --triangulate
                local triangles = love.math.triangulate(self.polygon_points)
                -- print(inspect(triangles))
                for _, triangle in ipairs(triangles) do
                    local polygon = love.physics.newPolygonShape(triangle)
                    table.insert(shapes, polygon)
                end
            else
                local polygon = love.physics.newPolygonShape(self.polygon_points)
                table.insert(shapes, polygon)
            end
            
        else
            error('unrecognized shape!', self.shape)
        end
        
        for _, shape in ipairs(shapes) do --turn all shapes to fixtures (part of the support for multiple shapes)
            local thisFixture = love.physics.newFixture(self.physics_object.body, shape, self.physics_fixture_density)
            thisFixture:setUserData(self)
            table.insert(fixtures, thisFixture)
        end
        
        body:setFixedRotation(self.fixed_rotation) --fix rotation
        
        self:setAngle(self._angle)
        
        self.physics_object.body:setLinearDamping(self.physics_linear_damping, self.physics_linear_damping) --like drag
        self.physics_object.body:setAngularDamping(self.physicsAngularDamping)
        
        -- self:setSensor(self.physics_sensor)
        
        self:setFilterData(
            self.physics_category_list,
            self.physics_mask_list,
            self.physics_group
        )
        
        self:setRestitution(self.restitution) --applied after fixtures created
        
        if self.physics_sensor then
            self:setSensor(self.physics_sensor) --the fixtures need to be set as sensors after created to
        end
        
        -- print('more reflection tests...') --REFLECTION MAY BE DEPRECATED as it seems work is unavoidable here
        -- for k, v in pairs(self:getFixtures()) do
        --     print(k, v)
        -- end
        
    end
    
end

function Entity:deinitialize_physics()
    if self.physics_object then
        self.physics_object.body:destroy() --WARNING POSSIBLE MULTITHREADING
        self.physics_object = nil
    end
end

-- self:setRestitution_(0) --TESTING NEW REFLECTION (DELETE)

function Entity:getFixtures()
    --simply return fixtures from the body
    return self.physics_object.body:getFixtures()
end

function Entity:macroSetFixture(funct, ...)
    --UNTESTED (we are unsure this will work)
    --WE MAY ATTEMPT THIS REFLECTION WE MAY NOT (things like apply forces and things contradict)
    
    print('macroSetFixture', funct)
    
    self.physics_object.settings[funct] = {...} --save the settings in a table
    
    if self.physics_object then
        -- self.physics_object.f:setCategory(...)
        for _, fixture in ipairs(self.physics_object.fixtures) do
            print('try to set fixture macro', funct, ...)
            fixture[funct](self, ...)
        end
        -- else
        --     self.physics_category_list = {...} --save as table, need to load after physics
    end
end

--[physics reflection system]
-- reflects all the physics functions into the entity object
-- this serves the purpose of being able to set the physics settings *before* the physics object is actually created
-- also with fixtures, it runs a macro that will set all the fixtures the same (ensuring triangulated polygons work okay)

Entity.body_functions = {"getJointList", "isBullet", "getType", "setBullet", "getWorldVector", "getWorld", "getLinearVelocityFromLocalPoint", "getAngularDamping", "getContactList", "setAngularDamping", "setMass", "applyAngularImpulse", "applyForce", "getInertia", "setInertia", "isSleepingAllowed", "setSleepingAllowed", "destroy", "setPosition", "getWorldPoints", "getY", "getContacts", "getJoints", "isDestroyed", "setGravityScale", "isTouching", "applyTorque", "getLinearDamping", "setAwake", "resetMassData", "isActive", "getFixtures", "isFixedRotation", "setActive", "getLocalPoint", "getLinearVelocity", "getLocalVector", "setX", "setY", "getFixtureList", "setFixedRotation", "getWorldCenter", "applyLinearImpulse", "setAngularVelocity", "isAwake", "setUserData", "getGravityScale", "release", "type", "typeOf", "getMassData", "setLinearVelocity", "getAngularVelocity", "getPosition", "getLocalCenter", "setAngle", "getX", "getMass", "getLinearVelocityFromWorldPoint", "setMassData", "getUserData", "getAngle", "getWorldPoint", "setLinearDamping", "setType"}
Entity.fixture_functions = {"getCategory", "isDestroyed", "getType", "getBody", "rayCast", "setFriction", "getShape", "setFilterData", "setSensor", "getBoundingBox", "getFilterData", "setUserData", "testPoint", "setRestitution", "destroy", "typeOf", "getDensity", "release", "getGroupIndex", "isSensor", "setMask", "getFriction", "setGroupIndex", "getRestitution", "getMassData", "getUserData", "type", "setCategory", "setDensity", "getMask"}
Entity.shape_functions = {"setRadius", "getRadius", "getType", "testPoint", "rayCast", "computeMass", "getChildCount", "computeAABB", "setPoint", "typeOf", "type", "release", "getPoint"}

Entity.physics_group = 1

for _, v in ipairs(Entity.body_functions) do --add a reflected fixture function for every function on body
    Entity[v .. '_'] = function (self, ...)
        -- print('test reflection456 body', v)
        self:macroSetFixture(v, ...)
    end
end

for _, v in ipairs(Entity.fixture_functions) do --add a reflected fixture function for every function on fixtures
    Entity[v .. '_'] = function (self)
        print('test reflection456 fixture', v)
    end
end

function Entity:setFilterData(categories, mask, group)
    self:setFixtureCategory(categories)
    self:setFixtureMask(mask)
    self:setFixtureGroupIndex(group)
end

Entity.physics_category_list = 1
function Entity:setFixtureCategory(...)
    if self.physics_object then
        -- self.physics_object.f:setCategory(...)
        for _, fixture in ipairs(self.physics_object.fixtures) do
            fixture:setCategory(...)
        end
    else
        self.physics_category_list = {...} --save as table, need to load after physics
    end
end

Entity.physics_mask_list = 1
function Entity:setFixtureMask(...)
    if self.physics_object then
        -- self.physics_object.f:setMask(...)
        for _, fixture in ipairs(self.physics_object.fixtures) do
            fixture:setMask(...)
        end
    else
        self.physics_mask_list = {...} --save as table, need to load after physics
    end
end

function Entity:setFixtureGroupIndex(group)
    if self.physics_object then
        -- self.physics_object.f:setGroupIndex(group)
        for _, fixture in ipairs(self.physics_object.fixtures) do
            fixture:setGroupIndex(group)
        end
    else
        self.physics_group = group
    end
end

function Entity:setSensor(bool)
    if self.physics_object then
        -- self.physics_object.f:setSensor(bool)
        for _, fixture in ipairs(self.physics_object.fixtures) do
            fixture:setSensor(bool)
        end
    else
        self.physics_sensor = bool
    end
end

-- function Entity:getSensor()
--     if self.physics_object then
--         return self.physics_object.f:isSensor()
--     end
-- end

function Entity:setRestitution(restitution)
    -- self.physics_object.f:setRestitution(0.4)
    -- restitution = restitution or self.physics_restitution
    if self.physics_object then
        
        -- for _, fixture in ipairs(self.physics_object.fixtures) do
        for _, fixture in ipairs(self:getFixtures()) do
            fixture:setRestitution(restitution)
        end
        
        -- self.physics_object.f:setRestitution(restitution)
    else
        self.restitution = restitution
    end
end

function Entity:getX()
    if self.physics_object then
        return self.physics_object.body:getX()
    else
        return self._x --if no physics_object
    end
end

function Entity:get_x()
    return self:getX()
end

function Entity:set_x(v)
    self:setX(v)
end

function Entity:get_y()
    return self:getY()
end

function Entity:set_y(v)
    self:setY(v)
end

function Entity:getY()
    if self.physics_object then
        return self.physics_object.body:getY()
    else
        return self._y --if no physics_object
    end
end
function Entity:setX(x)
    if self.physics_object then
        self.physics_object.body:setX(x)
    else
        self._x = x --if no physics_object
    end
end
function Entity:setY(y)
    if self.physics_object then
        self.physics_object.body:setY(y)
    else
        self._y = y --if no physics_object
    end
end
function Entity:getAngle(angle)
    if self.physics_object then
        return self.physics_object.body:getAngle()
    else
        return self._angle --if no physics_object
    end
end
function Entity:setAngle(angle)
    if self.physics_object then
        self.physics_object.body:setAngle(angle)
    else
        self._angle = angle --if no physics_object
    end
end
function Entity:position(x, y, angle)
    --EXERIMENTAL
    --can get and set all position pars
    --maybe slow if you use this to set pars
    if x then
        self:setX(x)
    end
    if y then
        self:setY(y)
    end
    if angle then
        self:setAngle(angle)
    end
    return self:getX(), self:getY(), self:getAngle()
end

Entity.move_speed = 1000 --actually force
function Entity:apply_force(dt, x, y, angle) --was warp now physics move
    -- if x then self.physics_object.b:setX(x) end
    -- if y then self.physics_object.b:setY(y) end
    
    if self.physics_object then
        if x then
            --unknown if we need to use dt????
            self.physics_object.body:applyForce(x * self.move_speed, 0)
        end
        if y then
            self.physics_object.body:applyForce(0, y * self.move_speed)
        end
        if angle then
            self.physics_object.body:applyTorque(angle * self.move_speed)
        end
    end
end
function Entity:apply_relative_force(dt, x, y, angle)
    --[[
    --BUG won't reverse!
    local forward_vector_x, forward_vector_y = math.angle_to_vector(self:getAngle()) --get the angle we face as a vector
    local force_vector_x, force_vector_y = 0, 0 --this will be the actual force to apply
    -- print(forward_vector_x, forward_vector_y)
    if x then
        force_vector_x = force_vector_x + forward_vector_y --note vector flipped
        force_vector_y = force_vector_y + forward_vector_x
    end
    if y then
        force_vector_x = force_vector_x + forward_vector_x
        force_vector_y = force_vector_y + forward_vector_y
    end
    
    self.physics_object.body:applyForce(force_vector_x * self.move_speed, force_vector_y * self.move_speed)
    
    print('APPLYING FORCE', force_vector_x, force_vector_y)
    ]]
    
    if y then --if we have a y force (forward or backwards force)
        local xForce, yForce = math.angle_to_vector(self:getAngle())
        xForce, yForce = xForce * -y, yForce * -y
        self.physics_object.body:applyForce(xForce, yForce)
    end
    if angle then --WORKS
        self.physics_object.body:applyTorque(angle * self.move_speed)
    end
    
end

Entity.fire_timer = 0
Entity.fire_delay = 0.1
Entity.fire_velocity = 100
function Entity:fire()
    if self.fire_timer >= self.fire_delay then
        local missile = self:spawn('missile', self:getX(), self:getY(), self:getAngle())
        missile:initialize_physics()
        local xVel, yVel = math.angle_to_vector(self:getAngle())
        xVel, yVel = xVel * self.fire_velocity, yVel * self.fire_velocity
        missile:applyLinearImpulse(xVel, yVel)
        self.fire_timer = 0
        
    end
end

--spawn.physics_object.body:setLinearVelocity( LinearVelocityX, LinearVelocityY )
function Entity:setLinearVelocity(x, y)
    
    if not x then
        x = 0
    end
    if not y then
        y = 0
    end
    
    -- if self.physics_object then
    self.physics_object.body:setLinearVelocity(x, y)
    -- end
    
end

--Body:applyLinearImpulse

function Entity:applyLinearImpulse(x, y)
    if self.physics_object then
        self.physics_object.body:applyLinearImpulse(x, y)
    end
end

--[[
move_mode:
0 = absolute force
1 = rotate force
2 = jump mode
3 = set velocity
]]
Entity.move_mode = 0

Entity.jump_velocity = 5

Entity.persisting = 0

function Entity:move(dt, x, y, angle)
    
    if self.physics_object then
        
        if self.move_mode == 0 then --absolute move
            self:apply_force(dt, x, y, angle)
            
        elseif self.move_mode == 1 then -- x rotates, y moves forward (buggy, won't reverse)
            if x then
                x = x / 10
            end
            self:apply_relative_force(dt, nil, y, x)
            
        elseif self.move_mode == 2 then --physics platformer jump move (work in progress)
            
            if self.persisting > 5 then
                self.grounded = true
                self.persisting = 0
            else
                self.grounded = false
            end
            
            if x then
                self:apply_force(dt, x, nil)
            end
            
            if self.grounded then
                if y then
                    -- self:apply_force(dt, x, nil)
                    -- self:setLinearVelocity(nil,-self.jump_velocity)
                    self:applyLinearImpulse(0, -self.jump_velocity)
                    self.persisting = 0
                end
            end
            
        elseif self.move_mode == 3 then
            
            --Body:setLinearVelocity( x, y )
            
            if not x then x = 0 end
            if not y then y = 0 end
            
            self.physics_object.body:setLinearVelocity(x * self.move_speed, y * self.move_speed)
            
        end
        
    elseif not self.physics_object then --no physics
        
        if self.move_mode == 0 then
            
            self:non_physics_abs_move(dt, x, y)
            
        end
        
    end
end

function Entity:non_physics_abs_move(dt, x, y) --used for move mode 0 when no physics
    
    if not x then
        x = 0
    end
    if not y then
        y = 0
    end
    
    -- self:setX(self:getX() + (x*dt* self.move_speed))
    -- self:setY(self:getY() + (y*dt* self.move_speed))
    self._x = self._x + (x * dt * self.move_speed)
    self._y = self._y + (y * dt * self.move_speed)
    
end

Entity.color_cycle = color_cycle_hue

function Entity:update(dt)
    
    if self.test_modulate_shape then
        if self.physics_object then
            if self.shape == 'circle' then
                self.physics_object.shapes[1]:setRadius(20)
            elseif self.shape == 'rectangle' then
                self.physics_object.shapes[1]:setWidth(20)
            end
        end
    end
    
    if self.animation then --if we have an animation object as per the animation system
        self.animation:update(dt)
    end
    
    local freq = 1 --UNKNOWN
    
    self.fire_timer = self.fire_timer + dt
    
    if self.color_cycle then
        self.color = self.color_cycle((math.sin(love.timer.getTime() * freq) / 2 + 0.5))
    end
    
    if self.death_timer then --if we have a "death_timer" property, we kill this unit after a time period
        self.death_timer = self.death_timer - dt
        if self.death_timer < 0 then
            self.dead = true
        end
    end
    
    self:run_events('update')
    
    self:update_scheduled_events() --run any scheduled_events
    
    if self.animate and self.frames then --animation system
        
        self.animation_timer = self.animation_timer + dt --increment timer
        
        if self.animation_timer > self.frame_duration then --if frame change due
            self.animation_timer = self.animation_timer - self.frame_duration --preserve overshoot to keep sync
            
            self.frame_position = self.frame_position + 1
            
            if self.frame_position > #self.frames then --if position more than frames
                self.frame_position = 1 --set to first frame
            end
            
            self.image = self.frames[self.frame_position] --update the displayed image
            
            if self.frame_durations then --if we have different frame durations
                self.frame_duration = self.frame_durations[self.frame_position]
            end
            
        end
        
    end
    
end

Entity.debug_draw_physics_shape = true --draw the actual physics shapes as outlines for debug

Entity.draw_physics_shape_drawmode = 'line'
-- Entity.draw_physics_shape_fillmode = 'fill'

function Entity:draw_physics_shape()
    --debug function visualizes physics shapes, not optimized for gameplay, just debug
    --static draws red
    --sensors draws orange
    --dynamic draws green
    
    love.graphics.setLineWidth(1)
    
    if self.physics_object then --if we have physics
        
        local alpha = 127
        -- local alpha = 255
        
        if self.physics_object.fixtures[1]:isSensor() then --if it is a sensor, highlight it orange
            love.graphics.setColor(255, 127, 0, alpha)
            
            -- elseif self.physics_object.b:isDynamic() then --UNKNOWN BUG ATM WE WANT TO CHECK THIS REALTIME
        elseif self.physics_body_type == 'static' then --WORKAROUND IS USE THE VARIBLE I SET
            
            love.graphics.setColor(255, 0, 0, alpha) --Static bodies RED
        elseif self.physics_body_type == 'dynamic' then --WORKAROUND IS USE THE VARIBLE I SET
            
            love.graphics.setColor(0, 255, 0, alpha) --Dynamic bodies RED
        end
        
        --iterate all shapes drawing them (shows triangulate)
        for _, shape in ipairs(self.physics_object.shapes) do
            local shape_type = shape:type() --check for shape (slow) and draw based on shape:
            if shape_type == 'CircleShape' then
                love.graphics.circle(self.draw_physics_shape_drawmode, self.physics_object.body:getX(), self.physics_object.body:getY(), self.physics_object.shapes[1]:getRadius())
            elseif shape_type == 'PolygonShape' then
                love.graphics.polygon(self.draw_physics_shape_drawmode, self.physics_object.body:getWorldPoints(shape:getPoints()))
            elseif shape_type == 'EdgeShape' then
                -- love.graphics.line(self.physics_object.body:getWorldPoints(shape:getPoints()))
            else
                error('unsupported shape: ' .. shape_type)
            end
        end
        
    end
    
end

function Entity:draw_polygon(mode, linewidth)
    --this pass draws the polygon (but not from the physics shapes), thusly it will draw the shape hiding the triangulation
    --"draw_polygon" is a bit misleading
    
    mode = mode or 'line'
    -- mode = mode or 'fill' --BUG fill mode doesn't like concave polygons (we could use triangulated data)
    
    linewidth = linewidth or 1
    --draws the polygon points as a fancy polygon graphic (doesn't need physics)
    love.graphics.push()
    love.graphics.setLineWidth(linewidth)
    local x, y, r = self:get_x(), self:get_y(), self:getAngle()
    if self.polygon_points then
        love.graphics.translate(x, y)
        love.graphics.rotate(r)
        love.graphics.polygon(mode, self.polygon_points)
    elseif self.shape == 'rectangle' then --corrected for rotations, draws from center to match physics rectangles
        love.graphics.translate(x, y)
        love.graphics.rotate(r)
        love.graphics.rectangle(mode, -self.width / 2, -self.height / 2, self.width, self.height) --draws from center
    elseif self.shape == 'circle' then
        love.graphics.circle(mode, self:get_x(), self:get_y(), self.radius)
    elseif self.shape == 'edge' then
        love.graphics.translate(x, y)
        love.graphics.rotate(r)
        love.graphics.line(self.edge_points)
    else
        error('unrecognized shape: ' .. self.shape)
    end
    love.graphics.pop()
end

Entity.color = {0, 0.7, 1, 1}

-- debug_direction_line = true --a line to show direction

function Entity:draw()
    --this pass is used to draw the Circle/Rectangle/Polygon Physics shapes, SOON TO BE "DEBUG DRAW"
    love.graphics.setColor(self.color)
    
    self:draw_polygon() --the main draw of the entity, like the circles, squares and original (even concave) polygons
    
    self:image_draw() --the drawing of a sprite image
    
    if self.animation then
        love.graphics.push()
        love.graphics.translate(self:getX(), self:getY()) --NOTE we are calling this get set a bit??
        love.graphics.rotate(self:getAngle()) --NOTE we might rename this 'r' like love itself
        self.animation:draw()
        love.graphics.pop()
    end
    
    if self.debug_draw_physics_shape then --a debug draw to highlight the actual physics shape(s), shows triangulations, hidden sensors etc
        self:draw_physics_shape()
    end
    
    if debug_direction_line then --another debug draw for direction of the unit, a little circle for the middle and a line
        love.graphics.setColor(0.2, 1, 0)
        love.graphics.setLineWidth(1)
        local x, y, angle = self:getX(), self:getY(), self:getAngle()
        -- love.graphics.rectangle('line', x, y, self.width, self.height)
        --debug circle with line facing direction
        -- love.graphics.circle('line', x, y, self.radius)
        local x_dir, y_dir = math.angle_to_vector(self:getAngle())
        love.graphics.circle('line', x, y, 2)
        love.graphics.line(x, y, x + x_dir * 20, y + y_dir * 20)
    end
    
end

-- Entity.draw_image = false --draw a sprite image
Entity.image_colorise = {255, 255, 255} --note duplicate

function Entity:image_draw()
    
    if self.image then
        local x, y, angle = self:getX(), self:getY(), self:getAngle()
        
        -- love.graphics.setColor(255, 255, 255)
        love.graphics.setColor(self.image_colorise)
        
        -- love.graphics.rectangle('line', x-(self.width/2), y-(self.height/2), self.width, self.height)
        --debug circle with line facing direction
        
        -- love.graphics.circle('fill', x,y,self.radius)
        
        -- local x_dir, y_dir = math.angle_to_vector(self:getAngle())
        -- love.graphics.line(x, y, x + x_dir * self.radius, y+y_dir * self.radius)
        
        local image_width, image_height = self.image:getWidth(), self.image:getHeight()
        local x_scale, y_scale = self.width / image_width, self.height / image_height
        
        -- if self.rectangle or self.circle or self.shape then
        if self.shape == 'rectangle' or self.shape == 'circle' then
            --with circle rectangle, sprite is stretched and positioned to line up
            love.graphics.draw(
                self.image,
                x, --position
                y,
                angle, --rotation
                x_scale, --scale
                y_scale,
                image_width / 2,
                image_height / 2
            )
            -- elseif self.polygon then
        elseif self.shape == 'polygon' then
            --in case of polygon, only polygons draw with top left origin and correct width and height added will work
            love.graphics.draw(
                self.image,
                x, --position
                y,
                angle, --rotation
                x_scale, --scale
                y_scale
                -- image_width / 2,
                -- image_height / 2
            )
        end
        
        -- local draw_outline_shapes = true --new mode to draw an outline shape (NOT ATTACHED TO THE PHYSICS)
        -- if self.rectangle then
        
        -- elseif self.circle then
        -- end
        
    end
    
end

function Entity:spawn(type, x, y, angle)
    -- error('spawn not implemented!')
    --spawn another entity from this entity
    local spawn = engine:spawn(type, x, y, angle)
    spawn.parent = self
    return spawn
    
end

--THESE FUNCTIONS MAY CHANGE IN TIME AS WE WHERE GOING TO HAVE A DYNAMIC EVENT SYSTEM

Entity.monitor_persistance = true --new code, watches what a gameobject is persisting with

Entity.destroy_on_contact_ignore_parent_collision = true --ignores the collisions with the creator (object that spawned it)

Entity.death_sound = sound_death

-- Physics Events
function Entity:beginContact(entity, collision)
    
    -- print (self.name, 'beginContact')
    self:run_events('beginContact')
    
    --THESE FUNCTIONS MAY CHANGE IN TIME AS WE WHERE GOING TO HAVE A DYNAMIC EVENT SYSTEM
    if self.destroy_on_contact then
        
        local dead = false
        if self.destroy_on_contact_ignore_parent_collision then
            
            if self.parent ~= entity then
                dead = true
            end
        else
            dead = true
        end
        
        if dead then
            if self.death_sound then
                self.death_sound:stop()
                self.death_sound:play()
                print('PLAY SOUND!!!!!!')
            end
        end
        
        self.dead = dead
    end
end
function Entity:endContact()
    -- print (self.name, 'endContact')
    self:run_events('endContact')
end
function Entity:preSolve()
    -- print (self.name, 'preSolve')
    self:run_events('preSolve')
end
function Entity:postSolve()
    -- print (self.name, 'postSolve')
    self:run_events('postSolve')
end

return Entity

