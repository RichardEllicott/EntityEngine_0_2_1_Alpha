--[[
 
These are sort of callable events, used by the shared class for the event system
 
--]]

local class = require('middleclass').class
--Event class, allows adding a list of functions and invoking all of them at once
local Event = class('Event')
function Event:add(funct) --add a function to be invoked
    if not self.events then
        self.events = {}
    end
    table.insert(self.events, funct)
end
function Event:run(...) --run all functions passing the arguments
    if self.events then
        for pos, funct in ipairs(self.events) do --convert to pairs
            funct(...)
        end
    end
end

return Event
