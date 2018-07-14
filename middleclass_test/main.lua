--[[
 
testing middleclass
 
 
we where trying to find how to clone a class instance
 
ie
 
classInstance = Class1()
 
then clone the instance itself, as it's pars may have changed
 
]]

local class = require 'middleclass'
local inspect = require 'inspect'

local Class1 = class('Class1', SharedClass)

Class1.x = 67

class1 = Class1()

print(class1.x)

class1.x = 22

-- class2 = class1()

print(inspect(class1))

class2 = class1.new() --WE CAN'T SEEM TO CLONE A CLASS

