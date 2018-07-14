--[=====[
 
 
Standard Forms (typical pseudo structures used):
 
coordinates: raw pars, like f(x,y) or f(x1,y1,x2,y2)
maps: nested lists like {{0,0,0},{1,1,0},{0,1,0}} where 0 is empty
colors: tables with 3 or 4 numbers
 
animations are either: 
lists of love images, or in case of var timings:
 
 
 
 
--]=====]

local moonshine = require 'moonshine' --shaders

local class = require('middleclass').class
local Entity = require('ee_entity')
local SharedClass = require 'ee_sharedclass'
require 'ee_animations'

--[Engine Class]
--The main game manager that runs as a singleton
local Engine = class('Engine', SharedClass)

--NEW CODE FOR TESTING SPAWN FROM MOUSE (REQUIRES TIDY UP)
Engine.debug_spawn_from_cursor = true --spawn things by mouse click 03-07-2018
Engine.debug_spawn_from_cursor_type = 'block' --spawn things by mouse click 03-07-2018
Engine.debug_spawn_from_cursor_snap = true --snap to the grid

--TELEPORT FROM THE EDGE OF THE WORLD LIKE ASTEROIDS! (we cannot collide on both sides of the world atm, neither did asteroids)
Engine.teleport_border = false --RENAME "screen wrap"
Engine.teleport_border_x1 = 0 --left edge --this NEEDS TO BE 0 ATM!
Engine.teleport_border_x2 = 512 --right edge (but the width)
Engine.teleport_border_y1 = 0 --top edge
Engine.teleport_border_y2 = 512 --bottom edge (but the height)
Engine.teleport_border_draw = true --draw the teleport border with lines
-- Engine.teleport_border_mirror_image = true --draw a mirror image of sprites to look so a big thing wanders off one side to the other

function Engine:get_gaussianblur_sigma()
    return self.moonshine_effect.gaussianblur.sigma
end
function Engine:set_gaussianblur_sigma(sigma)
    if self.moonshine_effect and self.moonshine_effect.gaussianblur then
        --warning will crash if we have not yet run init
        self.moonshine_effect.gaussianblur.sigma = sigma
    else
        print('WARNING tried to set sigma but no gaussianblur')
    end
end

function Engine:init_moonshine()
    
    if self.draw_moonshine_pass then
        --standard gaussian, normal effect
        self.moonshine_effect = moonshine(moonshine.effects.gaussianblur) --our standard blur mode
        self.moonshine_effect.gaussianblur.sigma = 1
        
        --note the fast gaussian can look crappy, however with trail it's quite acceptable
        -- self.moonshine_effect = moonshine(moonshine.effects.fastgaussianblur) --our standard blur mode
        -- self.moonshine_effect.fastgaussianblur.taps = 13 --allows it to reach further
        -- -- self.moonshine_effect.fastgaussianblur.offset = 10 --weird one, i think it like skips steps (allows weird effects)
        -- self.moonshine_effect.fastgaussianblur.sigma = 4
        
        -- self.moonshine_effect = moonshine(moonshine.effects.glow) --a glow alternative for vector graphics
        -- self.moonshine_effect.glow.min_luma = 0
        -- self.moonshine_effect.glow.strength = 5
        
        -- self.moonshine_effect = self.moonshine_effect.chain(moonshine.effects.crt) --attempt to chain NOT WORKING??
        
        -- self.moonshine_effect = moonshine(moonshine.effects.gaussianblur)
        -- self.moonshine_effect.chain(moonshine.effects.pixelate)
        -- self.moonshine_effect.pixelate.size = {4, 4}
        
    else
        self.moonshine_effect = nil
    end
    
end

function Engine:init() --renamed "init" so we can test loading the init manually
    
    font = love.graphics.newFont(18) --a default font size
    love.graphics.setFont(font)
    
    --crash if we already have loaded one instance
    assert(not ee_has_init, 'an instance of entity engine has already been loaded! (currently due to physics callbacks)')
    ee_has_init = true --save a global to stop the engine being loaded twice
    print('starting Entity Engine...')
    Engine.entities = {} --lists all spawned objects
    
    self:init_moonshine()
    
    self.physics_world = love.physics.newWorld()
    self.physics_world:setCallbacks(self.beginContact, self.endContact, self.preSolve, self.postSolve)
    
    self.camera = assert(camera) --WE ARE MOVING THE CAMERA HERE AND REMOVING THE GLOBAL
    
    self.mouse = {}
    self.mouse.x = 0
    self.mouse.y = 0
    
    --contains a list of the "animation class" containers
    --all their updates/draws will be handled neatly (reducing spaghetti)
    --these things are not really all animations, the grid for example has moved there
    
    self.background_animations = {
        -- UnicursalHexagramAnimation(),
        -- SpirographAnimation(), --one of the best looking
        
        -- CogAnimation(),
        -- CrowleyAnimation(), --the nice swords thing we done
        
        -- LordsCrossAnimation(),
        
        -- NoiseSquareAnimation(),
        -- TurtleAnimation(),
        
        GridAnimation(), --NOTE THIS SEEMS TO WORK WITHOUT CALLING IT (using brackets, easy bug to make)
        
        -- ParticleSystemAnimation(),
        -- LightningAnimation(),
        
        -- animationType2, --TESTING AnimationType2
        -- AnimationType2_Inherit(), --WORKING ON THESE DELETE THIS SHIT LATER!
        -- AnimationType2Teleport(), --WORKING ON THESE DELETE THIS SHIT LATER!
        -- TreeOfLifeAnimation(),
        -- TeleportAnimation(),
    }
    
    -- print('INSPECT ANI', inspect(AnimationType2Teleport()))
    -- print('INSPECT ANI', AnimationType2Teleport().name)
    -- print('INSPECT ANI', AnimationType2Teleport.name)
    -- print('INSPECT ANI', AnimationType2Teleport().class == AnimationType2Teleport) --SHOWS HOW WE CHECK IF IT IS CERTAIN CLASS
    
    --TRAIL DRAW TEST (WARNING, USES GLOBALS)
    if self.draw_trail_pass then --using slimes example, WARNING GLOBALS!
        trail_pass_scene = love.graphics.newCanvas()
        trail_pass_blur = love.graphics.newCanvas()
        local old_draw = self.draw --in order to blend with old code we back up old draw
        self.draw = function ()
            trail_pass_scene:renderTo(function() --firstly fill scene
                -- love.graphics.clear(0, 0, 0, 1) --necessary???
                old_draw(self) --we call old draw here
                love.graphics.setColor(1, 1, 1, self.draw_trail_alpha) --alpha of 1 is trail forever, alpha of 0.9 etc short trails
                love.graphics.setBlendMode("add")
                love.graphics.draw(trail_pass_blur)
                love.graphics.setBlendMode("alpha")
            end)
            trail_pass_blur:renderTo(function()
                -- love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(trail_pass_scene)
            end)
            -- love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(trail_pass_scene)
        end
        --we could shove gui here
    end
    
    engine = self --ensure the engine is loaded as the global engine (HACK)
    if self.debug_spawn_from_cursor then
        self.debug_spawn_from_cursor_preview_entity = Entity(self.debug_spawn_from_cursor_type)
        self.debug_spawn_from_cursor_preview_entity:setSensor(true)
        self.debug_spawn_from_cursor_preview_entity.name = 'i_am_the_marker'
        self.debug_spawn_from_cursor_preview_entity:initialize_physics()
        self.debug_spawn_from_cursor_preview_entity.physics_object.body:setSleepingAllowed(false) --Needs to be transfered to entity
    end
    
end

Engine.grid_spacing = 16 --still retained for the internal grid calculations, but the visual grid moved to the animations

function Engine:setGravity(x, y)
    self.physics_world:setGravity(x, y)
end
function Engine:getGravity()
    return self.physics_world:getGravity()
end

function Engine:_draw_cursor()
    
    love.graphics.push()
    self:apply_graphics_translations()
    
    --unit to mouse line
    if self.controlled_unit then
        love.graphics.setColor(0.5, 0.5, 1, 0.5)
        love.graphics.line(self.mouse_world_x, self.mouse_world_y, self.controlled_unit:get_x(), self.controlled_unit:get_y())
    end
    
    --grid position marker
    love.graphics.setColor(magenta)
    love.graphics.rectangle('line', self.mouse_grid_x * self.grid_spacing, self.mouse_grid_y * self.grid_spacing, 16, 16)
    
    --spawn preview
    if self.debug_spawn_from_cursor then
        if self.debug_spawn_from_cursor_snap then
            self.debug_spawn_from_cursor_preview_entity.x = self.mouse_grid_x * self.grid_spacing
            self.debug_spawn_from_cursor_preview_entity.y = self.mouse_grid_y * self.grid_spacing
        else
            self.debug_spawn_from_cursor_preview_entity.x = self.mouse_world_x
            self.debug_spawn_from_cursor_preview_entity.y = self.mouse_world_y
        end
        self.debug_spawn_from_cursor_preview_entity:draw()
    end
    
    love.graphics.pop()
    
end

--I think this is now useless!!
-- Engine.background_animation_timer = 0 --a timer used to time the background animations
-- Engine.background_animation_delay = 0.1

function Engine:_draw_background()
    --draw a pretty background, no gameplay relevance
    --draws first, also used for drawing the pretty visualizations
    love.graphics.push()
    self:apply_graphics_translations() --backgrounds go through the translations
    
    for i = 1, #self.background_animations do
        self.background_animations[i]:draw()
    end
    
    love.graphics.pop()
end

function Engine:spawn(type, x, y, angle)
    --spawn an entity into the game
    --returns entity object
    local spawn = Entity(type, x, y, angle)
    spawn.engine = self --attaches a reference to controlling engine, may be redundant (engine is singleton)
    table.insert(self.entities, spawn)
    return spawn
end

function Engine:trippy_sequence_draw_test()
    --testing a sorta self contain demo sequence
    --(after much research this type of sequence is usually better to write in raw lua)
    --creating an abstract event system can be an issue
    
    local time = love.timer.getTime() % 4
    
    -- if not self.UnicursalHexagramAnimation then
    --     self.UnicursalHexagramAnimation = UnicursalHexagramAnimation()
    -- end
    -- if not self.ParticleSystemAnimation then
    --     self.ParticleSystemAnimation = ParticleSystemAnimation()
    -- end
    -- if not self.LightningAnimation then
    --     self.LightningAnimation = LightningAnimation()
    -- end
    
    if time < 2 then --testing out a basic sequencer
        self.background_animations = {
            -- self.UnicursalHexagramAnimation
        }
    else
        self.background_animations = {
        LightningAnimation()}
    end
    
end

Engine.timer = 0

function Engine:update(dt)
    self.timer = self.timer + dt
    
    -- self:trippy_sequence_draw_test() --WARNING THIS OVERRIDES THE BACKGROUND, IT'S JUST A TEST
    
    for i = 1, #self.background_animations do --update all the pretty background animations
        self.background_animations[i]:update(dt)
    end
    
    self.physics_world:update(dt) --update physics_world
    
    for i = #self.entities, 1, -1 do --backward iterate entities (enables deleting them in one pass)
        
        local entity = self.entities[i]
        
        entity:update(dt) --backward, but one iteration
        
        if entity.dead then --entity garbage collection
            print('ee_engine deleting entity', entity.type, entity.name)
            entity:deinitialize_physics() --this is important to remove the actual physics object from the world
            table.remove(self.entities, i)
        end
        
        if self.teleport_border then
            local x, y = entity:getX(), entity:getY()
            if x < self.teleport_border_x1 then --crosses left border
                entity:setX(x + self.teleport_border_x2)
            elseif x > self.teleport_border_x2 then --crosses right border
                entity:setX(x - self.teleport_border_x2)
            end
            if y < self.teleport_border_y1 then --crosses top border
                entity:setY(y + self.teleport_border_y2)
            elseif y > self.teleport_border_y2 then --crosses bottom border
                entity:setY(y - self.teleport_border_y2)
            end
        end
    end
    
    self:update_scheduled_events(dt) --scheduled event timer, triggers global events (not attached to entities)
    
    --gather mouse information (grid position etc)
    self.mouse_x, self.mouse_y = love.mouse.getPosition()
    self.mouse_world_x = ((self.mouse_x + self.camera.x - self.mouse_zoom_center_x) / self.camera.scale) + self.mouse_zoom_center_x
    self.mouse_world_y = ((self.mouse_y + self.camera.y - self.mouse_zoom_center_y) / self.camera.scale) + self.mouse_zoom_center_y
    self.mouse_grid_x, self.mouse_grid_y = math.floor(self.mouse_world_x / self.grid_spacing), math.floor(self.mouse_world_y / self.grid_spacing)
    
    self.debug_message = string.format('mouse pos (%s, %s), world pos (%s, %s), grid pos (%s, %s)',
        self.mouse_x, self.mouse_y,
        math.round(self.mouse_world_x, 1), math.round(self.mouse_world_y, 1),
        self.mouse_grid_x, self.mouse_grid_y
    )
    
    if love.keyboard.isDown(self.keys.camera_up) then --N
        camera.y = camera.y - (dt * camera.speed)
    end
    if love.keyboard.isDown(self.keys.camera_right) then --E
        camera.x = camera.x + (dt * camera.speed)
    end
    if love.keyboard.isDown(self.keys.camera_down) then --S
        camera.y = camera.y + (dt * camera.speed)
    end
    if love.keyboard.isDown(self.keys.camera_left) then --W
        camera.x = camera.x - (dt * camera.speed)
    end
    if love.keyboard.isDown(self.keys.camera_zoom_in) then --zoom in
        -- camera.x = camera.x - (dt * camera.speed)
        -- camera.x_scale = camera.x_scale + dt
        -- camera.y_scale = camera.y_scale + dt
        camera:zoom_in(dt)
    end
    if love.keyboard.isDown(self.keys.camera_zoom_out) then --zoom out
        -- camera.x = camera.x - (dt * camera.speed)
        -- camera.x_scale = camera.x_scale - dt
        -- camera.y_scale = camera.y_scale - dt
        camera:zoom_out(dt)
    end
    if love.keyboard.isDown(self.keys.camera_rotate_right) then
        camera:rotate_right(dt)
    end
    if love.keyboard.isDown(self.keys.camera_rotate_left) then
        camera:rotate_left(dt)
    end
    
    if love.keyboard.isDown(self.keys.screenshot) then
        love.graphics.captureScreenshot('ee_screenshot_' ..os.time() .. ".png")
    end
    
    if self.controlled_unit then
        
        local controller_x, controller_y
        local player_moved = false
        
        if love.keyboard.isDown(self.keys.right) then
            controller_x = 1
            player_moved = true
        elseif love.keyboard.isDown(self.keys.left) then
            controller_x = -1
            player_moved = true
        end
        if love.keyboard.isDown(self.keys.down) then
            controller_y = 1
            player_moved = true
        elseif love.keyboard.isDown(self.keys.up) then
            controller_y = -1
            player_moved = true
        end
        if love.keyboard.isDown(self.keys.fire1) then
            self.controlled_unit:fire()
        end
        
        if love.mouse.isDown(1) then
            -- print(self.controlled_unit, 'FIRE BUTTON NOT IMPLEMENTED')
            
        end
        
        if player_moved then
            engine.controlled_unit:move(dt, controller_x, controller_y)
            
            engine.controller_last_x = controller_x or 0
            engine.controller_last_y = controller_y or 0
        end
        
        -- if engine.controlled_unit then
        -- camera.scale = 2
        
        if self.camera.follow_controlled_unit then --absolute follow the target unit, BUGGED by zoom code
            self.camera.x = engine.controlled_unit:getX() * self.camera.scale - (screen.width / 2)
            self.camera.y = engine.controlled_unit:getY() * self.camera.scale - (screen.height / 2)
        end
        -- end
        
    end
end

function love.mousepressed(x, y, button, istouch)
    --WARNING, this alters the consistency of the code since we use this Love Engine global (which is easier)
    --assumes of course we have made the Engine object the global:
    --engine = Engine()
    --this means should we move to engine, change 'engine' refs to 'self'
    
    if button == 1 then -- Versions prior to 0.10.0 use the MouseConstant 'l'
        if engine.debug_spawn_from_cursor then
            if engine.debug_spawn_from_cursor_snap then
                local spawn = engine:spawn('block',
                    engine.mouse_grid_x * engine.grid_spacing,
                    engine.mouse_grid_y * engine.grid_spacing
                )
                spawn:initialize_physics()
            else
                local spawn = engine:spawn('block', engine.mouse_world_x, engine.mouse_world_y)
                spawn:initialize_physics()
            end
        end
    end
end

Engine.draw_background_pass = true
Engine.draw_moonshine_pass = true --draw the graphics in the moonshine pass (game,background)
-- Engine.draw_standard_pass = true --draw the graphics in a non moonshine pass
-- Engine.draw_trail_pass = true --for our non-shader based trail (NOTE DOES NOT SUPPORT FULLSCREEN YET)
Engine.draw_trail_alpha = 0.95
Engine.debug_draw_cursor = true --a debug cursor (Engine._draw_cursor)

Engine.mouse_zoom_center_x = 0 --used for zoom and rotate center
Engine.mouse_zoom_center_y = 0

function Engine:apply_graphics_translations()
    --notes about cameras:
    --https://gamedev.stackexchange.com/questions/16719/what-is-the-correct-order-to-multiply-scale-rotation-and-translation-matrices-f
    --http://nova-fusion.com/2011/04/19/cameras-in-love2d-part-1-the-basics/
    love.graphics.translate(-self.camera.x, -self.camera.y) --standard order, translate->rotate->scale
    
    --corrections that allow the zoom to rotate and zoom from the center of the screen
    self.mouse_zoom_center_x, self.mouse_zoom_center_y = self.camera.x + love.graphics.getWidth() / 2, self.camera.y + love.graphics.getHeight() / 2 --this one zooms to top left of screen fine!!
    love.graphics.translate(self.mouse_zoom_center_x, self.mouse_zoom_center_y) --MODIFICATION FOR ZOOM CENTER
    
    love.graphics.rotate(-self.camera.rotation)
    love.graphics.scale(self.camera.scale)
    
    love.graphics.translate(-self.mouse_zoom_center_x, -self.mouse_zoom_center_y) --MODIFICATION FOR ZOOM CENTER
    
end

Engine.debug_draw_message = true
Engine.debug_message = 'no debug_message!' --if this has some text, display on screen
Engine.debug_message_size = 1 --NOT WORKING YET, NEED FONT SIZE
Engine.debug_message_color = {0.7, 1, 0}

function Engine:draw_main() --this is the complete draw of entities etc, it is here so it can be called first in shader, then in standard
    if self.draw_background_pass then
        self:_draw_background() --first pass for pretty backgrounds and animations
    end
    
    love.graphics.push() --draw all our entities in the moonshine shader (usually blur)
    self:apply_graphics_translations() --TODO inconsistent translations
    for _, entity in pairs(self.entities) do
        entity:draw()
        
        --THIS CODE BLOCK IS EXPERIMENTAL, IT SHOULD DEMONSTRATE DRAWING 3 COPIES OF THE GAME AREA FOR ASTEROIDS ILLUSION
        if self.teleport_border then --test code, will draw the mirror image that allows an asteroids like illusion
            if self.teleport_border_mirror_image then --EXPERIMENTAL CODE, we reckon we'll need three extra translates for the full illusion
                
                local x, y = self.teleport_border_x2, self.teleport_border_y2
                
                love.graphics.push() --E
                love.graphics.translate(x, 0)
                entity:draw()
                love.graphics.pop()
                
                love.graphics.push() --SE
                love.graphics.translate(x, y)
                entity:draw()
                love.graphics.pop()
                
                love.graphics.push() --S
                love.graphics.translate(0, y)
                entity:draw()
                love.graphics.pop()
                
                love.graphics.push() --N
                love.graphics.translate(0, -y)
                entity:draw()
                love.graphics.pop()
                
                love.graphics.push() --NW
                love.graphics.translate(-x, -y)
                entity:draw()
                love.graphics.pop()
                
                love.graphics.push() --NE
                love.graphics.translate(x, -y)
                entity:draw()
                love.graphics.pop()
                
                love.graphics.push() --W
                love.graphics.translate(-x, 0)
                entity:draw()
                love.graphics.pop()
                
                love.graphics.push() --W
                love.graphics.translate(-x, y)
                entity:draw()
                love.graphics.pop()
                
            end
        end
        
    end
    love.graphics.pop()
end

--background color will multiply up with the trail render, best left black
--it actually only needs to be set once
-- Engine.background_color = {0, 0, 0}

function Engine:draw()
    if self.background_color then
        love.graphics.setBackgroundColor(self.background_color) --TESTING THIS
    end
    
    love.graphics.setColor(1, 1, 1)
    
    if self.draw_moonshine_pass then
        self.moonshine_effect(function()
            self:draw_main()
        end)
    end
    
    if self.draw_standard_pass then
        self:draw_main()
    end
    
    if self.teleport_border then --experimental feature at the moment, the teleport border emulates asteroids
        if self.teleport_border_draw then --draw the teleport border boundary
            love.graphics.push()
            self:apply_graphics_translations()
            love.graphics.line(
                self.teleport_border_x1, self.teleport_border_y1,
                self.teleport_border_x2, self.teleport_border_y1,
                self.teleport_border_x2, self.teleport_border_y2,
                self.teleport_border_x1, self.teleport_border_y2,
                self.teleport_border_x1, self.teleport_border_y1
            )
            love.graphics.pop()
        end
    end
    
    if self.debug_draw_cursor then --a debug feature shows our grid lines up, shows a line and a grid square atm
        self:_draw_cursor()
    end
    
    if self.debug_draw_message then --if we have a debug message for the GUI
        love.graphics.setColor(self.debug_message_color)
        love.graphics.print(self.debug_message)
    end
    
end

--physics hooks are GLOBAL, do not create more than one engine object (this is set to crash anyway)
--this is because we do not have a way of the physics engine calling "self"
--although this could be solved, it's easier to treat engine as a global
-- debug_print_physics_collisions = true

function Engine.beginContact(a, b, coll) --NEEDS TO BE GLOBAL ATM (THERE IS NO SELF REFERENCE PASSED ON CALLBACK)
    local coll_type = 'beginContact'
    
    local x, y = coll:getNormal()
    local aUserData, bUserData = a:getUserData(), b:getUserData()
    
    --DEBUG CODE BLOCK START (copied the same in all debug physics messages)
    if debug_print_physics_collisions then
        print(
            coll_type,
            string.format('%s:%s', aUserData.type, aUserData.name),
            string.format('%s:%s', bUserData.type, bUserData.name),
            string.format('(%s,%s)', x, y),
            -- string.format('persist(%s,%s)', aUserData.persisting, bUserData.persisting),
            '' --put this here just for quick out commenting (no comma at end)!
        )
    end
    --DEBUG CODE BLOCK END
    
    bUserData.persisting = 0 --THE PERSISTING CODE WILL NEED TO TRACK INDIVIDUAL PERSISTINGS
    
    aUserData:beginContact(bUserData, coll)
    bUserData:beginContact(aUserData, coll)
    -- aUserData:run_events('beginContact',b,coll) --this pattern depreciated (a bit complex)
    -- bUserData:run_events('beginContact',a,coll)
    
end

function Engine.endContact(a, b, coll)
    local coll_type = 'endContact'
    
    local x, y = coll:getNormal()
    local aUserData, bUserData = a:getUserData(), b:getUserData()
    
    --DEBUG CODE BLOCK START (copied the same in all debug physics messages)
    if debug_print_physics_collisions then
        print(
            coll_type,
            string.format('%s:%s', aUserData.type, aUserData.name),
            string.format('%s:%s', bUserData.type, bUserData.name),
            string.format('(%s,%s)', x, y),
            -- string.format('persist(%s,%s)', aUserData.persisting, bUserData.persisting),
            '' --put this here just for quick out commenting (no comma at end)!
        )
    end
    --DEBUG CODE BLOCK END
    
    bUserData.persisting = 0
    
    aUserData:endContact()
    bUserData:endContact()
    -- aUserData:run_events('endContact',b,coll)
    -- bUserData:run_events('endContact',a,coll)
end

persisting = 0 --global persisting (BAD)

function Engine.preSolve(a, b, coll)
    local coll_type = 'preSolve'
    
    local x, y = coll:getNormal()
    local aUserData, bUserData = a:getUserData(), b:getUserData()
    
    --DEBUG CODE BLOCK START (copied the same in all debug physics messages)
    if debug_print_physics_collisions then
        print(
            coll_type,
            string.format('%s:%s', aUserData.type, aUserData.name),
            string.format('%s:%s', bUserData.type, bUserData.name),
            string.format('(%s,%s)', x, y),
            -- string.format('persist(%s,%s)', aUserData.persisting, bUserData.persisting),
            '' --put this here just for quick out commenting (no comma at end)!
        )
    end
    --DEBUG CODE BLOCK END
    
    -- bUserData:preSolve(aUserData, coll) --dynamic that hits static
    -- aUserData:preSolve(bUserData, coll)
    
    bUserData.persisting = bUserData.persisting + 1
    
    aUserData:preSolve()
    bUserData:preSolve()
    -- aUserData:run_events('preSolve',b,coll)
    -- bUserData:run_events('preSolve',a,coll)
    
    --MYADDED END
    
    --NEED TO TRACK INDIVIDUAL PERSISTING!!!! we currenly have global
    
    if persisting == 0 then -- only say when they first start touching
        -- text = text.."\n"..tostring(a:getUserData()).." touching "..tostring(b:getUserData())
    elseif persisting < 20 then -- then just start counting
        -- text = text.." "..persisting
    end
    persisting = persisting + 1 -- keep track of how many updates they've been touching for
    
    -- print('collPos:',coll:getPositions())
    -- print('aPos:',a:getUserData():getX(), a:getUserData():getY())
    -- print('bPos:',b:getUserData():getX(), b:getUserData():getY())
    
    -- local x1, y1, x2, y2 = coll:getPositions()
    
    --x1, y1, x2, y2 = Contact:getPositions()
end

function Engine.postSolve(a, b, coll, normalimpulse, tangentimpulse)
    local coll_type = 'postSolve'
    
    local x, y = coll:getNormal()
    local aUserData, bUserData = a:getUserData(), b:getUserData()
    
    --DEBUG CODE BLOCK START (copied the same in all debug physics messages)
    if debug_print_physics_collisions then
        print(
            coll_type,
            string.format('%s:%s', aUserData.type, aUserData.name),
            string.format('%s:%s', bUserData.type, bUserData.name),
            string.format('(%s,%s)', x, y),
            -- string.format('persist(%s,%s)', aUserData.persisting, bUserData.persisting),
            '' --put this here just for quick out commenting (no comma at end)!
        )
    end
    --DEBUG CODE BLOCK END
    
    aUserData:postSolve()
    bUserData:postSolve()
    -- aUserData:run_events('postSolve',b,coll)
    -- bUserData:run_events('postSolve',a,coll)
    
end

--new experimental feature, the grid map, used to create limited grid based puzzles, maybe porting atomix
-- Engine.create_grid_map = true
Engine.grid_map_width = 8
Engine.grid_map_height = 8
function Engine:initialize_grid_map() --adding in the features of a "grid map", much like a chess map, used for puzzle games
    print('create_grid_map')
    self.grid_map = get_multidimensional_array(0, self.grid_map_width, self.grid_map_height)
    self.grid_map[1][1] = 1
    self.grid_map[3][6] = 1
    self.grid_map[4][5] = 1
    self.grid_map[4][7] = 1
    print('grid_map:\n' .. inspect_map(self.grid_map))
    
    for y = 1, #self.grid_map do
        for x = 1, #self.grid_map[1]do
            local tile = self.grid_map[y][x]
            if tile == 1 then --default test, we just use 1 for filled
                tile = self:spawn(
                    'grid_map_object',
                    self.grid_spacing * x - self.grid_spacing / 2, --note the correction!
                    self.grid_spacing * y - self.grid_spacing / 2
                )
                tile.image = love.graphics.newImage('images_atomix/block1.png')
                -- tile.image = love.graphics.newImage('error.png')
                self.grid_map[y][x] = tile
            end
        end
    end
end

function Engine:getFullscreen()
    return love.window.getFullscreen()
end

function Engine:setFullscreen(fullscreen)
    --[[
    love.window.setFullscreen(not love.window.getFullscreen()) --set fullscreen
    screen_width = love.graphics.getWidth() --recopy width/height
    screen_height = love.graphics.getHeight()
    scene_canvas = love.graphics.newCanvas(screen_width, screen_height) --reset the canvases to new res
    blur_canvas = love.graphics.newCanvas(screen_width, screen_height)
    moonshine_load() --load shaders at new res
    print('resized canvas size', screen_width, screen_height)
    ]]
    
    love.window.setFullscreen(fullscreen)
    local screen_width, screen_height = love.graphics.getWidth(), love.graphics.getHeight() --recopy width/height
    
    if draw_trail_pass then --if we have a trail, we need to resize those canvases (maybe add an init trail later)
        trail_pass_scene = love.graphics.newCanvas(screen_width, screen_height) --GLOBALS!
        trail_pass_blur = love.graphics.newCanvas(screen_width, screen_height)
    end
    
    self:init_moonshine()
    
end

Engine.keys = {--game controls
    camera_up = 'w',
    camera_down = 's',
    camera_right = 'd',
    camera_left = 'a',
    camera_zoom_in = 'x',
    camera_zoom_out = 'c',
    camera_rotate_right = 'e',
    camera_rotate_left = 'q',
    up = 'up',
    down = 'down',
    left = 'left',
    right = 'right',
    fire1 = 'space',
    screenshot = 'p',
}

return Engine

--[end of file]
