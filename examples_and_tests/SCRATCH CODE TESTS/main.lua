--[[
 
an area for testing stuff
 
]]

inspect = require 'inspect'

function math.round(n, deci) deci = 10 ^ (deci or 0) return math.floor(n * deci + .5) / deci end

print(math.round(12562.5678))
print(math.round(12562.5678, 2))
print(math.round(-12562.5678, 2))

test_huge_table = {}

for i = 1, 1000000 do
    test_huge_table[i] = math.random()
end
print(#test_huge_table)

print('test time', os.clock())

--i think we just iterate a table by going:
-- i=1, #tbl do
-- end

-- print(inspect(love))

function test_function(x, y, z, w)
    print(x, y, z, w)
end

function test_return()
    return 12, 55
end

test_function(33, test_return())

x = 999
function test_local_assign()
    
    -- local x
    
    for i = 1, 1 do
        x = 44
        print('testest_local_assign')
        print(x)
        
    end
    
    print(x)
    
end

--love.event.quit( "restart" ) this is cool ?
test_local_assign()
love.event.quit()
