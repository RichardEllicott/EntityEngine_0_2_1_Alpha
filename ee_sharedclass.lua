--[[
 
Contains some common class functions, here for convenience.
 
Mainly the event system. Timers etc, may be used by the Engine class or the Entity
The design is somewhat unusual liberal, for example the contact events will end up also being on the Engine, despite these being of no use.
Actually, no extra memory is used for this, but redundant functions technically exist on the Engine class
 
]]

local class = require 'middleclass'

-- local default_image = love.graphics.newImage('error.png')

local SharedClass = class('SharedClass')

local Event = require 'ee_event'

SharedClass.event_types = {
    'update',
    'collect',
    'collected',
    'beginContact',
    
}

function SharedClass:sharedclass_test()
    print('SharedClass:test!!!')
end

function SharedClass:add_event(event_key, funct) --NEW non action class
    
    if not self.events then
        self.events = {}
    end
    
    if not self.events[event_key] then
        -- self[event_key] = {}
        self.events[event_key] = {}
    end
    -- table.insert(self[event_key], funct)
    table.insert(self.events[event_key], funct)
end

function SharedClass:run_events(event_key, ...)
    -- if self[event_key] then
    --     for _,funct in ipairs(self[event_key]) do
    --         funct(self)
    --     end
    -- end
    if self.events then
        if self.events[event_key] then
            print('SharedClass:run_events', ...)
            
            for _, funct in ipairs(self.events[event_key]) do
                funct(self)
            end
        end
    end
end

function SharedClass:clear_events(event_key)
    -- self[event_key] = nil
    self.events = nil
end

-- function  SharedClass:add_future_event(wait_time, funct)

-- end

function SharedClass:add_update_event(funct) --update evenst run each update, used by GameObject and GameManager
    if not self.update_events then
        self.update_events = Event()
    end
    self.update_events:add_function(funct)
end
function SharedClass:run_update_events(dt)
    if self.update_events then
        self.update_events:invoke(dt)
    end
end
function SharedClass:add_collect_event(funct) --update events run each update, used by GameObject and GameManager
    if not self.collect_events then
        self.collect_events = Event()
    end
    self.collect_events:add_function(funct)
end
function SharedClass:run_collect_events(collected_object)
    if self.collect_events then
        self.collect_events:invoke(collected_object)
    end
end
function SharedClass:add_collected_event(funct) --update events run each update, used by GameObject and GameManager
    if not self.collected_events then
        self.collected_events = Event()
    end
    self.collected_events:add_function(funct)
end
function SharedClass:run_collected_events(collected_object)
    if self.collected_events then
        self.collected_events:invoke(collected_object)
    end
end
function SharedClass:add_beginContact_event(funct) --begin contact events are for physics, only used by GameObject
    if not self.beginContact_events then
        self.beginContact_events = Event()
    end
    self.beginContact_events:add(funct)
end
function SharedClass:run_beginContact_events(collision_object, coll)
    --collision_object is the other object we hit, like we are ball we hit wall
    if self.beginContact_events then
        self.beginContact_events:invoke(collision_object, coll)
    end
end

--EVENT TIMER, add events to future
function SharedClass:add_scheduled_event(time_till_event, event_function)
    --event system, allows adding of future events as lambda function
    if not self.scheduled_events then --if no self.events
        self.scheduled_events = {} --add a table
    end
    --insert the event at the end
    --self.events looks like a list of tuples {{event_time, event_function}...}
    table.insert(self.scheduled_events, {time_till_event + love.timer.getTime(), event_function})
    --compare function checks the event_times to sort the list of events
    local function compare(a, b)
        return a[1] < b[1] --if this event is sooner than the compared one
    end
    --sorts events from soonest (first), to latest (last)
    table.sort(self.scheduled_events, compare)
end
function SharedClass:print_scheduled_events()
    --for debug, print pending events
    if self.scheduled_events then
        for n, v in ipairs(self.scheduled_events) do --debug print
            print (v[1] .. ', ' .. tostring(v[2]))
        end
    end
end
function SharedClass:update_scheduled_events()
    --run on update, to run all due events
    --runs in update on Engine and Entities
    if self.scheduled_events then
        if #self.scheduled_events > 0 then
            local current_event = self.scheduled_events[1] --first is start of list
            local event_time = current_event[1]
            local event_lambda = current_event[2]
            if love.timer.getTime() >= current_event[1] then
                if type(event_lambda) == 'string' then
                    print('event string: ' .. event_lambda)
                elseif type(event_lambda) == 'function' then
                    event_lambda(self, dt)
                end
                table.remove(self.scheduled_events, 1) --remove the triggered event from the start of the list
                self:update_scheduled_events() --try a recurse, in-case there are other events at the same time
            end
        end
    end
end

return SharedClass
