--[[
 
simple turtle library
 
doesn't draw like an old turtle though, save points for rendering with lines etc
oldschool commands, rt lt accepts degrees rather than radians for quick copying of logo code
 
]]

local class = require('middleclass').class

local Turtle = class('Turtle')

function Turtle:initialize()
    self.x = 0
    self.y = 0
    self.angle = 0
    self.points = {}
    table.insert(self.points, self.x)
    table.insert(self.points, self.y)
    self.points_len = 2
    
    self.animation_points = {}
    self.animation_points_len = 0
end

function Turtle:right(angle)
    self.angle = self.angle + angle
end

function Turtle:rt(angle_degrees)
    self:right(math.rad(angle_degrees))
end

function Turtle:left(angle)
    self.angle = self.angle - angle
end

function Turtle:lt(angle_degrees)
    self:left(math.rad(angle_degrees))
end

function Turtle:forward(distance)
    self.x = self.x + math.cos(self.angle) * distance
    self.y = self.y + math.sin(self.angle) * distance
    table.insert(self.points, self.x)
    table.insert(self.points, self.y)
    self.points_len = self.points_len + 1
end

function Turtle:backward(distance)
    self:forward(-distance)
end

function Turtle:fd(distance)
    self:forward(distance)
end

function Turtle:bk(distance)
    self:backward(distance)
end

function Turtle:animation_nextframe()
    table.insert(self.animation_points, self.points[self.animation_points_len + 1])
    table.insert(self.animation_points, self.points[self.animation_points_len + 2])
    self.animation_points_len = self.animation_points_len + 2
end

Turtle.line = true
Turtle.points = true

Turtle.pointSize = 5

function Turtle:draw()
    love.graphics.setLineWidth(0.01)
    love.graphics.line(self.points) --lines seem to fuck up
    
    -- love.graphics.setPointSize(camera.scale * self.pointSize) --points need to be scaled but are square things!
    -- love.graphics.points(self.points)
    -- love.graphics.points(self.points[1], self.points[2]) --first point
    -- love.graphics.points(self.points[#self.points - 1], self.points[#self.points]) --last point
    
end

function Turtle:example1(pattern_var)
    --http://www.mathcats.com/gallery/15wordcontest.html
    --Dahlia
    --8 point flower shapes, var 1-7 then repeats (4 same as 8)
    --repeat 8 [rt 45 repeat 6 [repeat 90 [fd 2 rt 2] rt 90]]
    pattern_var = pattern_var or 6
    for i = 1, 8 do
        self:rt(45)
        for i2 = 1, pattern_var do
            local div = 2
            for i3 = 1, 180 / div do
                self:fd(div)
                self:rt(div)
            end
            self:rt(90)
        end
    end
end

function Turtle:example2()
    --8 point square star thing (i think Hypercube)
    --repeat 8 [repeat 4 [rt 90 fd 100] bk 100 lt 45]
    for i = 1, 8 do
        for i2 = 1, 4 do
            self:rt(90)
            self:fd(100)
        end
        self:fd(-100)
        self:lt(45)
    end
end

function Turtle:example3()
    --Penta-octagon
    --for [i 100 10 -10] [repeat 5 [repeat 5 [fd :i lt 72] lt 72]]
    for i = 100, 10, -10 do
        for i2 = 1, 5 do
            for i3 = 1, 5 do
                self:fd(i)
                self:rt(-72)
            end
            self:rt(-72)
        end
    end
end

function Turtle:example4()
    --Growing Scrolls variation 1
    for i = -1, 4 do
        for i2 = 1, 720 do
            self:fd(i * i)
            self:rt(i2)
        end
    end
end

function Turtle:example5()
    --5 point Growing Scrolls variation
    for i = 1, 1800 do
        self:fd(10)
        self:rt(i + 0.1)
    end
    -- for i = 1, 1800 do
    --     self:fd(10)
    --     self:rt(i + 0.1)
    -- end
end

--try repeat 11 [for [i 0 359] [fd 1 rt (sin :i / 2)]]

function Turtle:example6(var) --pentagram
    local star_points = var * 2 + 5
    for i = 1, star_points do
        self:fd(100)
        self:rt(360 / star_points * 2)
    end
end

function Turtle:example7(var) --pentagram
    -- for i =1,14 do
    --     self:fd(100)
    --     for i2 =1, 360/4 do
    --         self:fd(50)
    --         self:rt(-360/4)
    --     end
    --     self:rt(360/7)
    -- end
    -- for i =1,14 do --use for animate
    --     self:fd(100)
    --     for i2 =1, 360/4 do
    --         self:fd(var)
    --         self:rt(-360/4)
    --     end
    --     self:rt(360/7)
    -- end
    
    -- var = 40
    -- for i =1,14 do --use for animate
    --     self:fd(var*10)
    --     for i2 =1, 360/12 do
    --         self:fd(var)
    --         -- self:fd(10)
    --         self:rt(-360/12)
    --     end
    --     self:rt(360/7)
    -- end
    
    pattern_var = pattern_var or 6 --dalia var (crazy)
    outer = 9
    for i = 1, outer do
        self:rt(360 / outer)
        for i2 = 1, pattern_var do
            -- local div = 12
            local div = 2
            for i3 = 1, 180 / div do
                self:fd(div)
                self:rt(div)
            end
            self:rt(360 / outer * 2)
        end
    end
    
end

function Turtle:crowley_swords(var)
    --Frieda Harris swords wings
    self.points = {}
    var = var or 0
    -- var = 0
    local x_center = 0
    local y_center = 0
    for i = 1, 4 do
        x_center = x_center + self.x
        y_center = y_center + self.y
        self:fd(120 - var)
        self:lt(140)
        self:fd(20 + var / 3)
        self:lt(30)
        -- self:lt(30 + var / 16)
        self:fd(120) -- 120
        self:rt(90)
        -- self:rt(90 - var / 16)
        self:fd(30)
        self:rt(170)
    end
    x_center = x_center / 4
    y_center = y_center / 4
    for i = 1, #self.points, 2 do --iterate the coordinates to correct the center
        self.points[i], self.points[i + 1] = self.points[i] - x_center, self.points[i + 1] - y_center
    end
    -- print('total lines', #self.points / 2)
    
    table.insert(self.points, self.points[1]) --add a line back to origin
    table.insert(self.points, self.points[2])
end

return Turtle

