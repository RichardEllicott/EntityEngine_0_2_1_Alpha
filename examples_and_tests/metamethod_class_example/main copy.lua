t = {} -- original table (created somewhere)
-- keep a private access to the original table
local _t = t
-- create proxy
t = {}
-- create metatable
local mt = {
    __index = function (t, k)
        print("*access to element " .. tostring(k))
        -- return _t[k] -- access the original table
        return rawget(t, k)
    end
    ,
    __newindex = function (t, k, v)
        print("*update of element " .. tostring(k) ..
        " to " .. tostring(v))
        -- _t[k] = v -- update original table
        rawset(t, k, v)
    end
}
setmetatable(t, mt)

t[2] = "hello"
print(t[2])

rawset(t, 2, 'gggg')
print(rawget(t, 2))
