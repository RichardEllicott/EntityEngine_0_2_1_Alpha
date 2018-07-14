--[[
 
solves a jittering issue
 
]]

x = 30
y = 30

x_vel = 300

x_acceleration = -100

function love.update(dt)
    x = x + (dt * x_vel)
    -- x_vel = x_vel * 0.99 --friction
    if x_vel < 1 then --simply added a point of rest
        -- x_vel = 0
        x_acceleration = 0
        x_vel = 0
    end
    
    x_vel = x_vel + x_acceleration * dt
end

function love.draw()
    love.graphics.rectangle('fill', x, y, 50, 50)
end
