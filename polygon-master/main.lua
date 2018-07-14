--[[
 
current tests for integration of this code into my framework
 
IMPORTANT LINK:
 
https://github.com/AlexarJING/polygon/
 
maybe submit support:
Hi
 
two squares:
p1{ 100, 100, 200, 100, 200, 200, 100, 200 }
p2{ 150, 100, 250, 100, 250, 200, 150, 200 }
 
"not" =>
 
p3{ { 150, 100, 150, 200, 150, 200, 100, 200, 100, 100 }, { 200, 100, 250, 100, 250, 200, 200, 200, 200, 100 } }
 
I was trying to figure out why this happens, i imagine what I'm doing is bad practise but I still liked to figure it out!
 
 
 
also the "donut", slicing a hole in the middle:
 
p1{ 100, 100, 200, 100, 200, 200, 100, 200 }
p2{ 120, 120, 180, 120, 180, 180, 120, 180 }
p3{ 100, 100, 200, 100, 200, 200, 100, 200, 120, 120, 180, 120, 180, 180, 120, 180 }
 
 
]]

inspect = require 'inspect'

io.stdout:setvbuf("no")
local polygon = require "polygon"
local polybool = require "polybool"

love.math.setRandomSeed(os.time())

-- local p1 = polygon.random(400,300,30,3)
-- local p2 = polygon.random(500,400,30,2)

function gen_poly_square(x, y, width, height)
    --generate a square shape as a polygon
    return {x, y, x + width, y, x + width, y + height, x, y + height}
end

p1 = gen_poly_square(100, 100, 100, 100) --original square
-- p1 = {100, 100, 200, 100, 170, 150, 200, 200, 100, 200} --shows concave p1 reverses the result!
p2 = gen_poly_square(150, 150, 100, 100) --nice clean corner overlap (works)
p2 = {175, 150, 250, 150, 250, 250, 150, 250, 150, 175, 175, 175} --concave slice of p1 works!!!
p2 = {175, 150, 250, 150, 250, 250, 150, 250, 150, 175, 190, 190} --as above works again
p2 = {175, 150, 250, 150, 250, 250, 150, 250, 150, 175, 200, 200} --this cut makes two intersections, this also crashes!
-- p2 = gen_poly_square(120, 120, 60, 60) --donut CRASHSHSH!!
-- p2 = gen_poly_square(200, 200, 100, 100) --this one corner touch (BUG) --SOLUTION SIMPLY FAIL THESE
-- p2 = gen_poly_square(250, 250, 100, 100) --this one misses
-- p2 = gen_poly_square(120, 80, 60, 140) --slice in half WORKS

perform_the_boolean = true

--NEW TEST CASE, PARTIALLY OKAY ON ONE LINE
-- local p2 = gen_poly_square(150, 100, 100, 100) --HAVE A WEIRD BUG

-- p2 = {}
-- for _,v in ipairs(p1) do
-- table.insert(p2,v + 10)
-- end
if perform_the_boolean then
    p3 = polybool(p1, p2, "not") --slicing
    -- p3 = polybool(p1, p2, "or") --welding
end

print('p1', inspect(p1))
print('p2', inspect(p2))
print('p3', inspect(p3))

if type(p3[1]) == 'number' then --a little hack to try triangulating donut (doesn't work)
    p3 = {p3}
end

function love.draw()
    love.graphics.setPointSize(10)
    
    love.graphics.setColor(0, 0, 1) --draw our original one
    love.graphics.polygon("line", p1)
    -- love.graphics.points(p1)
    
    love.graphics.setColor(1, 0, 0) --draw our slice
    love.graphics.polygon("line", p2)
    -- love.graphics.points(p2)
    
    -- love.graphics.setColor(255, 255, 0, 255) --draw our sliced one (doesn't work)
    -- love.graphics.polygon('line', p3)
    if perform_the_boolean then
        -- p3 = {p3} --HACK, maybe we just get one poly back
        for i, v in ipairs(p3) do
            -- print('triangulate', inspect(v))
            for i, t in ipairs(love.math.triangulate(v)) do --draw all resulting polys in table
                love.graphics.setColor(0, 1, 0, 0.5)
                love.graphics.polygon("fill", t)
                love.graphics.setColor(0, 1, 0, 0.5)
                love.graphics.polygon("line", t)
                love.graphics.points(t)
            end
        end
        
    end
    
end
