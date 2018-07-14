require "class" --jonstoler's class lib (not middleclass)
local inspect = require('inspect')

MyAwesomeClass = class()
MyAwesomeClass:set{
    _property = "something",
    property = {
        get = function (self)
            return self._property
        end,
        set = function (self, value)
            self._property = value
        end,
    },
    _property2 = "else",
    property2 = {
        get = function (self)
            return self._property2
        end,
        set = function (self, value)
            self._property2 = value
        end,
    },
}
MyAwesomeClass:set{
    _property = "something",
    property = {
        get = function (self)
            return self._property
        end,
        set = function (self, value)
            self._property = value
        end,
    },
    _property3 = "else",
    property3 = {
        get = function (self)
            return self._property3
        end,
        set = function (self, value)
            self._property3 = value
        end,
    },
}

local c = MyAwesomeClass()
print(c.property)
c.property = 'hahaha'
print(c.property2)
c.property2 = 'fuckckck'
print(c.property2)
print(inspect(c))
