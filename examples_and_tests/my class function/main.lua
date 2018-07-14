--[[
 
 https://stackoverflow.com/questions/39886333/middleclass-add-getter-setter-support-for-properties
 
 using a mixin
 
]]

-- local class = require 'ee_redruth_library_class'

local class = require 'middleclass'
local Properties = require 'properties'

local Entity = class('Rect'):include(Properties)

function Entity:initialize()
    print('create properties entity...')
end

function Entity:get_x()
    return self._x
end

function Entity:set_x(v)
    self._x = v + 1
end

entity = Entity()
entity.x = 999
print(entity.x)
