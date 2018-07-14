-- local func_example = setmetatable({}, {__index = function (t, k) -- {} an empty table, and after the comma, a custom function failsafe
--     print('HOOOK for ', t, k)
--     return "key doesn't exist"
-- end})

-- local fallback_tbl = setmetatable({-- some keys and values present, together with a fallback failsafe
--     foo = "bar",
--     [123] = 456,
-- }, {__index = func_example})

-- local fallback_example = setmetatable({}, {__index = fallback_tbl}) -- {} again an empty table, but this time with a fallback failsafe

-- print(func_example[1]) --> key doesn't exist
-- print(fallback_example.foo) --> bar
-- print(fallback_example[123]) --> 456
-- print(fallback_example[456]) --> key doesn't exist

-- --my example:

-- default_table = {
--     x = 99,
--     y = 777
-- }

function TableWithHook() --generates a class that has a get set intercept
    
    local inherit_tbl = {testvar = 9999}
    local tbl = {} --the actual table we see
    
    tbl.mydata = {} --we need a subtable to store the actual variables themselves
    
    function tbl:testfunct ()
        print('fuckckck')
    end
    local mt = {
        __index = function (t, k) -- {} an empty table, and after the comma, a custom function failsafe
            -- print('try to get key ', t, k)
            print(string.format ('get "%s" from "%s"...', k, t))
            -- return rawget(t.mydata, k) --set the var as normal
            return t.mydata[k]
        end,
        __newindex = function (t, k, v)
            -- print('set hook', t, k, v)
            print(string.format ('set "%s" from "%s" to "%s"', k, t, v))
            
            -- rawset(t.mydata, k, v) --get var as normal
            t.mydata[k] = v
        end
    }
    return setmetatable(tbl, mt)
end

local table_with_hook = TableWithHook()

table_with_hook.x = 77
table_with_hook.x = 77
print('table_with_hook.x', table_with_hook.x)
print('table_with_hook.y', table_with_hook.y)
print('table_with_hook.testvar', table_with_hook.testvar)

table_with_hook.hahaha = 'sss'

function test_various_loop_speeds()
    --tests comparing various ways of iteration
    --FINDINGS:
    --backing up the length with a local variable seems to SLOW DOWN some of the tests (wtf?)
    
    --FASTEST WAY TO BUILD ARRAY SEEMS TO BE THE PATTERN:
    -- table = {}
    -- for i = 1, repeats do
    --     table[i] = i
    -- end
    
    --THE RAWSET IS A BIT SLOWER! (but not as slow as table.insert, which we need for proper list management (insert, delete etc))
    
    --THIS MEANS DO NOT USE RAWSET HERE, THERE IS NO POINT (unless working with metatables etc)
    
    --seems the case when in Lua:
    --use for i=1, #table do end
    
    print('test_various_loop_speeds...')
    local repeats = 1000000
    
    local time_unit = 1000 --milliseconds
    
    --ADD DATA TO A TABLE TESTS
    --TEST 1
    local start1 = love.timer.getTime()
    local table1 = {}
    for i = 1, repeats do
        table1[i] = i
    end
    local runtime1 = love.timer.getTime() - start1
    print('runtime (table[i]= assignment):', runtime1 * time_unit)
    --TEST 2
    local start2 = love.timer.getTime()
    local table2 = {}
    for i = 1, repeats do
        table.insert(table2, i)
    end
    local runtime2 = love.timer.getTime() - start2
    print('runtime (table.insert):', runtime2 * time_unit)
    --TEST 3
    local start3 = love.timer.getTime()
    local table3 = {}
    for i = 1, repeats do
        table.insert(table3, 0)
    end
    local runtime3 = love.timer.getTime() - start3
    print('runtime (table.insert (to the front)):', runtime3 * time_unit)
    
    --TEST 4
    local start4 = love.timer.getTime()
    table4 = {}
    for i = 1, repeats do
        rawset(table4, i, i)
    end
    local runtime4 = love.timer.getTime() - start4
    print('runtime (rawset the table):', runtime4 * time_unit)
    
    --ITERATE THE TABLES TESTS...
    
    print('iterate table tests on table4', #table4)
    
    --TEST 5
    local start5 = love.timer.getTime()
    for i, v in ipairs(table4) do
        --we just iterate it empty
    end
    local runtime5 = love.timer.getTime() - start5
    print('runtime (ipairs iterate)', runtime5)
    
    --TEST 6
    local start6 = love.timer.getTime()
    for i = 1, #table4 do
        local v = table4[i]
    end
    local runtime6 = love.timer.getTime() - start6
    print('runtime (iterate table using the # operator, but not backing up the length', runtime6)
    
    --TEST 7
    local start7 = love.timer.getTime()
    local len4 = #table4
    for i = 1, len4 do
        local v = table[i]
    end
    local runtime7 = love.timer.getTime() - start7
    print('as above but making a copy of the length', runtime7)
    
    --TEST 8
    local start8 = love.timer.getTime()
    for i = 1, #table4 do
        local v = rawget(table4, i)
    end
    local runtime8 = love.timer.getTime() - start8
    print('iterate a rawget (skips the metatable) using the # operator', runtime8)
    
    --TEST 9
    local start9 = love.timer.getTime()
    local len9 = #table4
    for i = 1, len9 do
        local v = rawget(table4, i)
    end
    local runtime9 = love.timer.getTime() - start9
    print('iterate a rawget (skips the metatable), only getting the length once', runtime9)
    
end

test_various_loop_speeds()

