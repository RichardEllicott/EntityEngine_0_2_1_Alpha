--[=====[
 
 
 
--]=====]
local class = require('middleclass').class

local Camera = class('Camera')
Camera.x, Camera.y = 0, 0
-- Camera.x_scale, Camera.y_scale = 1,1
Camera.scale = 1
Camera.rotation = 0
Camera.speed = 500
Camera.zoom_speed = 1
-- Camera.follow_controlled_unit = true

function Camera:zoom(dt, val)
    --a zoom function such that negative values applied ie zoom(dt,-1) is a zoom out
    -- self.x_scale = val * self.zoom_speed * dt + self.x_scale
    -- self.y_scale = val * self.zoom_speed * dt + self.y_scale
    self.scale = val * self.zoom_speed * dt + self.scale
end
function Camera:zoom_in(dt)
    self:zoom(dt, 1)
end
function Camera:zoom_out(dt)
    self:zoom(dt, -1)
end
function Camera:rotate(dt, val)
    self.rotation = val * self.zoom_speed * dt + self.rotation
end
function Camera:rotate_right(dt)
    self:rotate(dt, 1)
end
function Camera:rotate_left(dt)
    self:rotate(dt, -1)
end

return Camera
