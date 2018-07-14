--[[
 
an ignore collision sample someone provided me on thread:
 
https://love2d.org/forums/viewtopic.php?f=4&t=85425&p=222000#p222000
 
 
not yet used, can apparently be used to set all the filter groups to -1, then controls all the collisions apparently
 
 
]]

--[=======================================================================[--
 
Simple library to implement a function that allows causing two given fixtures
to not collide which each other.
 
Usage:
 
local world = love.physics.newWorld(...)
local ignoreCollision = require('stopCollision')(world)
 
...
 
ignoreCollision(fixture1, fixture2, true) -- add pair to ignore list
ignoreCollision(fixture1, fixture2, false) -- remove pair from ignore list
 
Written by Pedro Gimeno, donated to the public domain.
 
--]=======================================================================]--

local weak = {__mode = 'k'}

return function(world)
    local collisionPairs = setmetatable({}, weak)
    world:setContactFilter(function (fixt1, fixt2)
        return not (collisionPairs[fixt1] and collisionPairs[fixt1][fixt2]
        or collisionPairs[fixt2] and collisionPairs[fixt2][fixt1])
    end)
    return function(fixt1, fixt2, ignore)
        if ignore then
            -- Try to not duplicate pairs
            if collisionPairs[fixt1] and collisionPairs[fixt1][fixt2] then return end
            if collisionPairs[fixt2] then
                collisionPairs[fixt2][fixt1] = true
                return
            end
            if not collisionPairs[fixt1] then
                collisionPairs[fixt1] = setmetatable({}, weak)
            end
            collisionPairs[fixt1][fixt2] = true
            return
        end
        
        -- ignore is false - remove the entry
        if collisionPairs[fixt1] then
            collisionPairs[fixt1][fixt2] = nil
        end
        if collisionPairs[fixt2] then
            collisionPairs[fixt2][fixt1] = nil
        end
    end
end
