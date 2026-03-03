local Classic = require("external.classic")
Enemy = Classic:extend()

function Enemy:new(x,y,acceleration, maxSpeed)
  self.hp = HEALTHPOINTS
  self.sta = STAMINA
  self.x = x
  self.y = y
  self.dx = 0
  self.dy = 0
  self.isEnemy=true
  self.flip=false -- false == right; true == left
  self.location = nil
  self.acc = acceleration
  self.maxSpd = maxSpeed
end
