--[[
 
The standard animation class, my framework will make use of middleclass still for this. 
 
These animations contain code that may need to be run in the update loop as well.
 
 
THESE ANIMATIONS ARE LOADED AS GLOBALS, THIS IS BECAUSE WE DON'T WANT FILES FOR EACH ONE
 
 
 
--]]

local class = require 'middleclass'

--[Animation Class]
--A container for various animations like backgrounds etc
--The first usage is for the various pretty backgrounds from the pattern investigations
--The next usage might be for units as well

NoiseSquareAnimation = class('NoiseSquareAnimation')
function NoiseSquareAnimation:initialize()
end
NoiseSquareAnimation.timer = 0
NoiseSquareAnimation.delay = 1
NoiseSquareAnimation.cell_size = 16
NoiseSquareAnimation.width = 16
NoiseSquareAnimation.height = 32

function NoiseSquareAnimation:update(dt)
    --delete the noise on a timer, causing it to reshuffle
    self.timer = self.timer + dt
    if self.timer > self.delay then
        self.timer = self.timer - self.delay
        self.background_data = nil
    end
end
function NoiseSquareAnimation:draw()
    
    if not self.background_data then
        self.background_data = {}
        for i = 1, self.height do
            self.background_data[i] = {}
            for i2 = 1, self.width do
                self.background_data[i][i2] = love.math.random()
            end
        end
    end
    for y = 1, self.height do
        for x = 1, self.width do
            local val = self.background_data[y][x]
            -- if val > 0.5 then --binary fill style
            --     love.graphics.rectangle('fill', (x - 1) * noise_rect_widths, (y - 1) * noise_rect_widths, noise_rect_widths, noise_rect_widths)
            -- end
            love.graphics.setColor(val, 1 - val, 1, 1) --psychedelic colors!
            -- love.graphics.setColor(val, val, 1, 1) --psychedelic colors!
            love.graphics.rectangle('fill', (x - 1) * self.cell_size, (y - 1) * self.cell_size, self.cell_size, self.cell_size)
        end
    end
end

GridAnimation = class('GridAnimation') --maybe our grid
-- GridAnimation.color = {0.5, 0.75, 0.25}
GridAnimation.color = {0.5, 0.75, 0.25, 0.1}
GridAnimation.grid_line_count = 32 --the squares in height/width of grid (32 is 32*32 squares)
GridAnimation.grid_line_width = 1
GridAnimation.grid_spacing = 16
GridAnimation.grid_div = 8 --used to mark where the "fat" lines of the grid are
function GridAnimation:initialize()
end
function GridAnimation:update(dt)
end
function GridAnimation:draw()
    love.graphics.setColor(self.color)
    love.graphics.setLineWidth(self.grid_line_width)
    for i = 0, self.grid_line_count do --actually we have one extra line as we want to have squares
        if i % self.grid_div == 0 then--widen every 8th line like graph paper
            love.graphics.setLineWidth(self.grid_line_width * 3)
        else
            love.graphics.setLineWidth(self.grid_line_width)
        end
        local offset = i * self.grid_spacing
        love.graphics.line(0, offset, self.grid_spacing * self.grid_line_count, offset) --x lines
        love.graphics.line(offset, 0, offset, self.grid_spacing * self.grid_line_count) --y lines
    end
end

local StarAnimation = class('StarAnimation') --maybe a starfield that has parallax
function StarAnimation:initialize()
end
function StarAnimation:update(dt)
end
function StarAnimation:draw()
end

local ParticleAnimation = class('ParticleAnimation') --custom particle system (not love 2D one)
function ParticleAnimation:initialize()
end
function ParticleAnimation:update(dt)
end
function ParticleAnimation:draw()
end

ParticleSystemAnimation = class('ParticleSystemAnimation') --using love 2d particle system
function ParticleSystemAnimation:initialize()
    local img = love.graphics.newImage('whitelight32.png')
    
    self.psystem = love.graphics.newParticleSystem(img, 100)
    self.psystem:setParticleLifetime(0, 50) -- Particles live at least 2s and at most 5s.
    -- self.psystem:setLinearAcceleration(-5, -5, 50, 100) -- Randomized movement towards the bottom of the screen.
    
    local linearAcceleration = 15
    
    self.psystem:setLinearAcceleration(linearAcceleration, linearAcceleration, -linearAcceleration, -linearAcceleration) -- Randomized movement towards the bottom of the screen.
    self.psystem:setColors(1, 1, 1, 1, 1, 1, 1, 0) -- Fade to black.
    self.psystem:setEmissionRate(10)
    self.psystem:setSizes(0.5, 0.1)
    self.psystem:setParticleLifetime(2)
    self.psystem:setSizes(0.5, 0.5)
    
    self.timer = 0
    self.delay = 0.1
    
end
function ParticleSystemAnimation:update(dt)
    self.psystem:update(dt)
    self.timer = self.timer + dt
    
    if self.timer > self.delay then
        -- self.psystem:emit(1)
        self.timer = self.timer - self.delay
    end
end
function ParticleSystemAnimation:draw()
    -- Draw the particle system at the center of the game window.
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.psystem, 0, 0)
end

TurtleAnimation = class('TurtleAnimation') --using our logo turtle emulation
function TurtleAnimation:initialize()
    self.turtle = Turtle()
    -- self.turtle:example1() --8 petal
    -- self.turtle:example2() -- 8 square star
    -- self.turtle:example3() --pentaflower
    -- self.turtle:example4() -- symmetric cleff
    self.turtle:example5()
    -- self.turtle:example6()
end
function TurtleAnimation:update(dt)
end
function TurtleAnimation:draw()
    love.graphics.setColor(0.5, 0.5, 1, 0.1)
    love.graphics.setPointSize(5)
    self.turtle:draw()
end

SpirographAnimation = class('SpirographAnimation') --using our logo turtle emulation
function SpirographAnimation:initialize()
    
end
function SpirographAnimation:update_points()
    -- self.points = scale_points(get_spirograph_ellipse_points(128, 4, 0.5), 100)
    self.points = scale_points(get_spirograph_ellipse_points(
        128,
        4 + 3,
        math.sin(math.rad(
        love.timer.getTime()) * 360 / 6
    )),
    100
)
table.insert(self.points, self.points[1])
table.insert(self.points, self.points[2])

end
function SpirographAnimation:update(dt)
    self:update_points()
end
function SpirographAnimation:draw()
    -- love.graphics.setColor(0, 0.5, 1)
    love.graphics.setColor(0, 1, 1)
    -- love.graphics.setPointSize(5)
    love.graphics.setLineWidth(1)
    love.graphics.line(self.points)
end

LightningAnimation = class('LightningAnimation') --using our logo turtle emulation
LightningAnimation.delay = 0
LightningAnimation.random_delay = 1
LightningAnimation.timer = 1
LightningAnimation.current_delay = 0
LightningAnimation.x1 = -100
LightningAnimation.y1 = 0
LightningAnimation.x2 = 100
LightningAnimation.y2 = 0
LightningAnimation.segments = 9
LightningAnimation.variance = 30
LightningAnimation.spark_hold_time = 0.05
LightningAnimation.color = {1, 1, 1}
LightningAnimation.line_width = 1
function LightningAnimation:initialize()
    self:update_positions()
end
function LightningAnimation:update(dt)
    self.timer = self.timer + dt
    if self.timer > self.current_delay then
        self.timer = 0
        -- self.color = color_cycle_hue(math.random()) --for random color
        self.line_width = math.random() * 1
        self.segments = math.floor(love.math.random() * 4) + 4
        
        self.current_delay = self.delay + math.random() * self.random_delay
        self:update_positions()
    end
end
function LightningAnimation:draw()
    love.graphics.circle('fill', self.x1, self.y1, 4)
    love.graphics.circle('fill', self.x2, self.y2, 4)
    love.graphics.setColor(self.color)
    if self.timer < self.spark_hold_time then
        love.graphics.setLineWidth(self.line_width)
        love.graphics.line(self.points)
    end
end
function LightningAnimation:update_positions()
    self.points = get_lightning_positions(self.x1, self.y1, self.x2, self.y2, self.segments, 30)
end

function get_coor_from_points(points, position)
    --takes a set of points in the form {x1,y1,x2,y2...}
    --returns the coordinate in the form "x, y" by using a position reference 0 or more
    --the first coordinate is 0, the second is 1 etc...
    local actual_pos = position * 2 + 1
    return points[actual_pos], points[actual_pos + 1]
end

function get_weaved_points(points, weave_pattern)
    --this function takes a load of points (points) like {x1,y1,x2,y2...}
    --it applies a "weave pattern" (weave_pattern) like {0,2,3,6...}
    --it returns the coordinates for the lines like {x1,y1,x2,y2...}
    --requires: get_coor_from_points
    ret = {}
    for _, v in ipairs (weave_pattern) do
        local x, y = get_coor_from_points(points, v)
        table.insert(ret, x)
        table.insert(ret, y)
    end
    return ret
end

function points_to_line_points(points)
    --takes points that might be the vertices of a shape for example
    --returns a new set of points with the first point added to the end
    --use to take points to render, like say a pentagon, and make sure the love.graphics.line goes back to the start
    ret = {}
    for _, v in ipairs(points) do
        table.insert(ret, v)
    end
end

function get_unicursal_hexagram(size)
    return get_weaved_points(get_ellipse_points(6, size), {0, 2, 5, 3, 1, 4, 0})
end

UnicursalHexagramAnimation = class('UnicursalHexagramAnimation') --maybe a starfield that has parallax
UnicursalHexagramAnimation.size = 100
function UnicursalHexagramAnimation:initialize()
    
    self.points = get_unicursal_hexagram(self.size)
    
    self.points2 = get_ellipse_points(6 * 4, self.size / 3)
    table.insert(self.points2, self.points2[1])
    table.insert(self.points2, self.points2[2])
    
    self.ellipse_points = get_ellipse_points(6, self.size / 2)
    
    self.david_points1 = get_weaved_points(self.ellipse_points, {0, 2, 4, 0})
    self.david_points2 = get_weaved_points(self.ellipse_points, {1, 3, 5, 1})
    
end
function UnicursalHexagramAnimation:update(dt)
end

function drawColorCyclePoints(colorCycle, ...)
    --draws the line like drawline, except cycles the color by the color cycle
    local points = ...
    local points_len = #points
    for i = 1, #points - 2, 2 do
        local hue_pos = (i - 1) / (points_len - 2) --due to lua weirdness, tested
        love.graphics.setColor(colorCycle(hue_pos))
        
        love.graphics.points(points[i], points[i + 1], points[i + 2], points[i + 3]) --HACK LIKE CODE, not like line
        love.graphics.circle('fill', points[i], points[i + 1], 10)
    end
end

function UnicursalHexagramAnimation:draw()
    --TRIPPY VERSION
    local points = self.points
    local points2 = self.points2
    local freq = 1 / 4
    
    local sin_pos = math.sin(math.rad(love.timer.getTime() * 360 * freq)) --oscillating version
    local cos_pos = math.cos(math.rad(love.timer.getTime() * 360 * freq))
    
    -- points = scale_points(points, sin_pos) --oscillating version (scale the points)
    -- points2 = scale_points(points2, cos_pos)
    
    love.graphics.setColor(color_cycle_hue(sin_pos))
    love.graphics.line(points)
    
    -- love.graphics.push()
    -- love.graphics.rotate(math.rad(90))
    -- love.graphics.line(points)
    -- love.graphics.pop()
    
    -- love.graphics.line(points2)
    
    -- love.graphics.line(self.david_points1)
    -- love.graphics.line(self.david_points2)
    
    -- drawColorCycleLine(color_cycle_hue, points)
    -- drawColorCycleLine(color_cycle_hue, points)
    
    -- drawColorCyclePoints(color_cycle_hue, points)
    -- drawColorCyclePoints(color_cycle_hue, points)
end
isometric_ratio = 1 / math.sqrt(3)
function get_isometric_projection(xPos, yPos)
    --global constant "isometric_ratio" must be declared:
    --isometric_ratio = 1 / math.sqrt(3)
    local screen_x, screen_y = 0, 0
    screen_x = screen_x - xPos --do the SW projection (x), we move x and y just taking into account x projection (SW)
    screen_y = screen_y + (isometric_ratio * xPos)
    screen_x = screen_x + yPos --do the SE projection (y), we move x and y just taking into account y projection (SE)
    screen_y = screen_y + (isometric_ratio * yPos)
    return screen_x, screen_y
end

TreeOfLifeAnimation = class('TreeOfLifeAnimation') --maybe a starfield that has parallax
function TreeOfLifeAnimation:initialize()
    
    self.sephroth_positions = {}
    self.sephroth_positions[1] = {0, 0}
    self.sephroth_positions[2] = {0, 1}
    self.sephroth_positions[3] = {1, 0}
    self.sephroth_positions[4] = {1, 2}
    self.sephroth_positions[5] = {2, 1}
    self.sephroth_positions[6] = {2, 2}
    self.sephroth_positions[7] = {2, 3}
    self.sephroth_positions[8] = {3, 2}
    self.sephroth_positions[9] = {3, 3}
    self.sephroth_positions[10] = {4, 4}
    
    self.map = get_multidimensional_array(0, 20, 20)
    self.map[10][10] = 1
    self.map[10][11] = 2
    self.map[11][10] = 3
    self.map[11][12] = 4
    self.map[12][11] = 5
    self.map[12][12] = 6
    self.map[12][13] = 7
    self.map[13][12] = 8
    self.map[13][13] = 9
    self.map[14][14] = 10
    
    self.paths = {}
    self.paths[1] = {1, 2}
    self.paths[2] = {1, 3}
    self.paths[3] = {1, 6}
    self.paths[4] = {2, 3}
    self.paths[5] = {2, 6}
    self.paths[6] = {2, 4}
    self.paths[7] = {3, 6}
    self.paths[8] = {3, 5}
    self.paths[9] = {4, 5}
    self.paths[10] = {4, 6}
    self.paths[11] = {5, 6}
    self.paths[12] = {4, 7}
    self.paths[13] = {5, 8}
    self.paths[14] = {6, 7}
    self.paths[15] = {6, 9}
    self.paths[16] = {6, 8}
    self.paths[17] = {7, 8}
    self.paths[18] = {7, 9}
    self.paths[19] = {7, 10}
    self.paths[20] = {8, 9}
    self.paths[21] = {8, 10}
    self.paths[22] = {9, 10}
    
    --[]SW []SE
    
    -- self.map[]
end
function TreeOfLifeAnimation:update(dt)
end
function TreeOfLifeAnimation:draw()
    
    --[[
    notes:
    -we found at a certain angle it disrupts the brain, interesting (might actually be the imperfect isometric projection)
    -some really nice nature patterns, more brain information: https://www.pinterest.co.uk/c1crawford/geometric-patterns-in-nature/?lp=true
    -
 
 
    ]]
    
    local scale = 32
    local sephroth_positions = self.sephroth_positions
    
    local color_pos = (love.timer.getTime() / 10) % 1
    
    love.graphics.setColor(color_cycle_hue(1 - color_pos))
    for i, v in ipairs(sephroth_positions) do
        local x, y = get_isometric_projection(v[1] * scale, v[2] * scale)
        love.graphics.circle('fill', x, y, 6)
    end
    
    love.graphics.setColor(color_cycle_hue(color_pos))
    for v, path in ipairs(self.paths) do --draw the paths
        local sep1, sep2 = path[1], path[2]
        local x1, y1 = get_isometric_projection(sephroth_positions[sep1][1] * scale, sephroth_positions[sep1][2] * scale)
        local x2, y2 = get_isometric_projection(sephroth_positions[sep2][1] * scale, sephroth_positions[sep2][2] * scale)
        love.graphics.line(x1, y1, x2, y2)
    end
    
    --this code done an isometric map (old way, keep code for isometric dot illusion)
    -- local map = self.map
    -- local width, height = #map[1], #map
    
    -- for y = 1, height do
    --     for x = 1, width do
    --         tile = self.map[y][x]
    
    --         local xPos, yPos = x * scale, y * scale --non isometric projection
    --         local xPos, yPos = get_isometric_projection(x * scale, y * scale)
    
    --         if tile ~= 0 then
    --             love.graphics.setColor(1, 0, 0)
    --         else
    --             love.graphics.setColor(1, 1, 0, 0)
    --         end
    --         -- love.graphics.circle('fill', xPos, yPos, 10)
    
    --     end
    -- end
    
end

TeleportAnimation = class('TeleportAnimation') --maybe a starfield that has parallax
function TeleportAnimation:initialize()
    
    self.pos_length = 64
    self.points = get_ellipse_points(self.pos_length, 16)
    self.timer = 0
    self.duration = 1 / 10
    self.position = 0
    -- self.offsets = {0, 4, 8, 12}
    -- self.offsets = {0, self.pos_length * 1 / 4, self.pos_length * 2 / 4, self.pos_length * 3 / 4}
    -- self.offsets = {0, self.pos_length * 1 / 4, self.pos_length * 2 / 4}
    
    self.dots_to_draw = 8
    self.offsets = {}
    for i = 1, self.dots_to_draw do
        table.insert(self.offsets, self.pos_length * i / 4)
    end
    
end
function TeleportAnimation:update(dt)
    self.timer = self.timer + dt
    if self.timer > self.duration then
        self.timer = 0
        self.position = (self.position + 1)
    end
    
end
function TeleportAnimation:draw()
    
    -- local pos = mod1(love.timer.getTime(), #self.points / 2)
    -- pos = math.floor(pos)
    -- -- print('pos', pos)
    -- local x, y = self.points[pos], self.points[pos + 1]
    -- print('xy', x, y)
    love.graphics.setLineWidth(1)
    
    local position = self.position % self.pos_length
    local x, y = self.points[(position * 2) + 1], self.points[(position * 2) + 2]
    love.graphics.setColor(0.5, 0.2, 0.5)
    love.graphics.line(self.points) --a line of the circle
    --draw last line to fill gap
    love.graphics.line(self.points[self.pos_length * 2 - 1], self.points[self.pos_length * 2], self.points[1], self.points[2])
    --the circle animations
    -- love.graphics.circle('fill', x, y, 4)
    for i, v in ipairs(self.offsets) do
        love.graphics.setColor(1, 0.2, 0)
        local position = (self.position + v) % self.pos_length
        local x, y = self.points[(position * 2) + 1], self.points[(position * 2) + 2]
        love.graphics.circle('fill', x, y, 3)
        
        love.graphics.setColor(1, 0.2, 0.4)
        local position = (self.position + v) % self.pos_length --the other circle way
        position = self.pos_length - position - 1
        local x, y = self.points[(position * 2) + 1], self.points[(position * 2) + 2]
        love.graphics.circle('fill', x, y, 2)
    end
end

CrowleyAnimation = class('CrowleyAnimation')
CrowleyAnimation.r1 = 0
function CrowleyAnimation:initialize()
    self.turtle1 = Turtle()
    -- self.turtle:example1() --8 petal
    -- self.turtle:example2() -- 8 square star
    self.turtle1:example3() --pentaflower
    -- self.turtle:example4() -- symmetric cleff
    -- self.turtle:example5() --pentacleff
    -- self.turtle:example6()
    
    self.turtle2 = Turtle()
    self.turtle2:crowley_swords()
    
end
function CrowleyAnimation:update(dt)
    self.r1 = self.r1 + math.rad(dt * 360 / 16) --1 second period
    
    self.turtle2:crowley_swords(math.sin(math.rad(love.timer.getTime() * 360 / 16)) * 20)
end
function CrowleyAnimation:draw()
    -- love.graphics.push()
    -- love.graphics.setColor(0.5, 0.5, 1, 0.1)
    -- love.graphics.rotate(self.r1)
    -- self.turtle1:draw()
    -- love.graphics.pop()
    -- love.graphics.push()
    -- love.graphics.setColor(0.5, 1, 0.5, 0.1)
    -- love.graphics.rotate(-self.r1)
    -- self.turtle1:draw()
    -- love.graphics.pop()
    
    love.graphics.push()
    love.graphics.setColor(0.5, 1, 0.5, 1)
    -- love.graphics.rotate(-self.r1)
    
    self.turtle2:draw()
    -- love.graphics.circle('fill', self.turtle2.x_center, self.turtle2.y_center, 1)
    love.graphics.pop()
    
end

LordsCrossAnimation = class('LordsCrossAnimation')
function LordsCrossAnimation:initialize()
end
function LordsCrossAnimation:update(dt)
end
function LordsCrossAnimation:draw_standard_cross()
    love.graphics.push()
    love.graphics.translate(-30, -60)
    love.graphics.line(30, 0, 30, 120)
    love.graphics.line(0, 30, 60, 30)
    love.graphics.pop()
end
function LordsCrossAnimation:draw_crusaders_cross()
    local scale = 120
    local cut = 30
    local small_cross = 30
    love.graphics.push()
    for i = 1, 4 do
        love.graphics.rotate(math.rad(90))
        love.graphics.line(0, 0, scale, 0)
        love.graphics.line(120, cut, 120, -cut)
        local x, y = scale / 2, scale / 2
        love.graphics.circle('line', scale / 2, scale / 2, cut / 4)
        love.graphics.line(x - small_cross, y, x + small_cross, y)
        love.graphics.line(x, y - small_cross, x, y + small_cross)
    end
    love.graphics.pop()
end
LordsCrossAnimation.lineWidth = 3
LordsCrossAnimation.speed = 0.5
function LordsCrossAnimation:draw()
    love.graphics.push()
    -- love.graphics.scale(math.sin(math.rad(love.timer.getTime() * 360 * self.speed)), 1)
    
    love.graphics.setLineWidth(1)
    
    love.graphics.setColor(1, 0, 0.5)
    -- love.graphics.circle('fill', 0, 0, 120)
    
    love.graphics.setLineWidth(2 * self.lineWidth)
    love.graphics.setColor(0.5, 0, 0.1)
    self:draw_crusaders_cross()
    love.graphics.setLineWidth(1 * self.lineWidth)
    love.graphics.setColor(1, 1, 1)
    self:draw_standard_cross()
    
    love.graphics.pop()
    
end

CogAnimation = class('CogAnimation')
function CogAnimation:initialize()
    self.points = get_cog_points(128, 100, 10, 4)
    table.insert(self.points, self.points[1])
    table.insert(self.points, self.points[2])
end
CogAnimation.r = 0
CogAnimation.speed = 1 / 16
function CogAnimation:update(dt)
    -- self.speed = math.sin(love.timer.getTime())
    self.r = self.r + math.rad(dt * 360 * self.speed) --1 second period
end
function CogAnimation:draw()
    love.graphics.push()
    love.graphics.rotate(self.r)
    love.graphics.line(self.points)
    love.graphics.circle('line', 0, 0, 80)
    love.graphics.pop()
    
end

--[[
 
Animation type 2 is a prototype design for now that includes scaling features, we're still making the odd "Animation" (type 1)
 
]]

AnimationType2 = class('AnimationType2') --new animation type 2 design for inheritance
AnimationType2.x = 0
AnimationType2.y = 0
AnimationType2.r = 0
AnimationType2.width = 1 --the default size of 1 is like a scale of one
AnimationType2.height = 1
function AnimationType2:initialize()
end
function AnimationType2:update(dt)
    -- self.r = self.r + dt
end
function AnimationType2:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y) --we translate first otherwise our scale will mess up the x,y positions
    love.graphics.scale(self.width, self.height) --the order of these two do not seem to make a difference
    love.graphics.rotate(self.r)
    self:draw2() --finally call the custom code part
    love.graphics.pop()
    
end
function AnimationType2:draw2() --in AnimationType2 override this
end

AnimationType2_Inherit = class('AnimationType2_Inherit', AnimationType2) --MORE OR LESS A TEST!
AnimationType2_Inherit.width = 32
AnimationType2_Inherit.height = 32
function AnimationType2_Inherit:draw2() --in animation type 2 this is our function we need to override (a bit messy maybe?)
    love.graphics.setColor(0.3, 0.6, 1, 0.1)
    love.graphics.rectangle('fill', 0, 0, 1, 1) --if we draw here from 0,0 we will rotate from the top left corner
    -- love.graphics.rectangle('fill', -1, -1, 2, 2) --example of rotate from center because we've positions this 2x2 box at -1,-1
end

--[[
 
trying to get good teleport animation, perhaps shoot lights round a circle
 
]]
AnimationType2Teleport = class('AnimationType2Teleport', AnimationType2)
AnimationType2Teleport.x = 32
AnimationType2Teleport.y = -16
AnimationType2Teleport.width = 32
AnimationType2Teleport.height = 32

function AnimationType2Teleport:initialize()
    
    -- self.points = get_sin_ellipse_points(64, 8, 0.1)
    -- table.insert(self.points, self.points[1]) --add first point to end (for line)
    -- table.insert(self.points, self.points[2])
    
    -- self.points = get_spirograph_ellipse_points(16, 7, 0.5)
    -- table.insert(self.points, self.points[1]) --add first point to end (for line)
    -- table.insert(self.points, self.points[2])
    
    self.points = get_ellipse_weave_points(7, 4, 7)
    table.insert(self.points, self.points[1]) --add first point to end (for line)
    table.insert(self.points, self.points[2])
    
end

function AnimationType2Teleport:draw2()
    love.graphics.setColor(0.3, 0.6, 1, 1)
    love.graphics.setLineWidth(0.01)
    love.graphics.line(self.points)
    -- love.graphics.circle('fill', 0, 0, 1)
    
end

function AnimationType2Teleport:update(dt)
    -- self.r = self.r + dt
    
    -- self.points = get_spirograph_ellipse_points(256, 7, math.sin(love.timer.getTime() * 2))
    -- table.insert(self.points, self.points[1]) --add first point to end (for line)
    -- table.insert(self.points, self.points[2])
    
end

--DOT ONE:
AnimationType2Teleport.position = 0
AnimationType2Teleport.width = 16
AnimationType2Teleport.height = 16
AnimationType2Teleport.delay = 10
AnimationType2Teleport.timer = 0
AnimationType2Teleport.points_len = 16

function AnimationType2Teleport:initialize()
    self.points = get_ellipse_points(self.points_len)
end
function AnimationType2Teleport:update(dt)
    self.timer = self.timer + dt
    if self.timer > self.delay then
        self.position = self.position + 1 --possible threading issue
        if self.position > self.points_len then
            self.position = 0
        end
    end
    
end
function AnimationType2Teleport:draw2()
    local x = self.points[self.position + 1]
    local y = self.points[self.position + 2]
    -- love.graphics.circle('fill', x, y, 0.1)
    love.graphics.points(x, y)
end
