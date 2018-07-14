--[[
 
redruth table functions, 
 
 
]]

function table.shuffle(tbl, seed)
    --return a shuffled version of the table
    --if a seed is added (a number), this can be used for procedural
    --note i added it to the table functions
    if seed then
        math.randomseed(seed) --procedural
    end
    local shuffled = {}
    for i = 1, #tbl do
        local pos = math.random(1, #shuffled + 1)
        table.insert(shuffled, pos, tbl[i])
    end
    return shuffled
end
