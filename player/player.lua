require("player.baseState")
require("player.states.idleState")
require("player.states.runState")
require("player.states.atk1State")
require("player.states.atk2State")
require("player.states.guardState")
require("player.states.hurtState")

Tools = require("tools")
Classic = require("external.classic")
Player = Classic:extend()

--sprite sizes
local spriteHeight = 192 
local spriteWidth = 192
--player ancor:
local offsetX = spriteWidth/2   
local offsetY = spriteHeight/2

--offsets for hitboxes
----walkbox
local walkBoxW = 45
local walkBoxH = 15
local walkBoxOffsetX = 25
local walkBoxOffsetY = 25
----takedmg hitbox
local hurtBoxW = 30
local hurtBoxH = 45
local hurtBoxOffsetX = 15
local hurtBoxOffsetY = 5
----atk hitbox
local atkBoxW = 55
local atkBoxH = 90
local atkBoxOffsetX = 20
local atkBoxOffsetY = 40
local atkFlipOffset = atkBoxOffsetX * 2 + atkBoxW
----guard hitbox
local guardBoxW = 40
local guardBoxH = 60
local guardBoxOffsetX = 5
local guardBoxOffsetY = 20
local guardFlipOffset = guardBoxOffsetX - guardBoxW + 5

--player atributes
local HEALTHPOINTS = 100
local STAMINA = 100

local walkCollisionFilter = function(item, other)
  if item.owner == other.owner then return nil
  elseif other.layer == LAYER.SOLID then return "slide"
  else return "cross"
  end
end

local takeDmgCollisionFilter = function(item, other)
  if item.owner == other.owner then return nil
  elseif other.layer == LAYER.ATKBOX then return "cross"
  else return nil
  end
end

local dealDmgCollisionFilter = function(item, other)
  if item.owner == other.owner then return nil
  elseif other.layer == LAYER.HURTBOX then return "cross"
  else return nil
  end
end

local guardCollisionFilter = function(item, other)
  if item.owner == other.owner then return nil
  elseif other.layer == LAYER.ATKBOX then return "cross"
  else return nil
  end
end

function Player:new(x,y,acceleration,maxSpeed)  
  self.hp = HEALTHPOINTS
  self.sta = STAMINA
  self.x = x
  self.y = y
  self.dx = 0
  self.dy = 0
  self.isPlayer=true
  self.flip=false -- false == right; true == left
  self.location = nil
  self.acc = acceleration
  self.maxSpd = maxSpeed
  
  --walk-box collision
  self.walkBox = {layer=LAYER.SOLID, owner=self, active=true, x=x-walkBoxOffsetX, y=y+walkBoxOffsetY, w=walkBoxW, h=walkBoxH} --layer0 -> walls, obstacles, 'walk thought physics'
  World:add(self.walkBox, self.walkBox.x, self.walkBox.y, self.walkBox.w, self.walkBox.h)

  --hurt-box collision
  self.hurtBox = {layer=LAYER.HURTBOX, owner=self, active=true, x=x-hurtBoxOffsetX, y=y-hurtBoxOffsetY, w=hurtBoxW, h=hurtBoxH,} --layer1 -> hurt detections
  World:add(self.hurtBox, self.hurtBox.x, self.hurtBox.y, self.hurtBox.w, self.hurtBox.h)

  --atk-box collision
  self.atkBox = {layer=LAYER.ATKBOX, owner=self, active=false, x=x+atkBoxOffsetX, y=y-atkBoxOffsetY, w=atkBoxW, h=atkBoxH, targetTable={}} --layer2 -> atk detections
  World:add(self.atkBox, self.atkBox.x, self.atkBox.y, self.atkBox.w, self.atkBox.h)

  --guard-box collision
  self.guardBox = {layer=LAYER.GUARDBOX, owner=self, active=false, x=x-guardBoxOffsetX, y=y-guardBoxOffsetY, w=guardBoxW, h=guardBoxH, targetTable={}} --layer3 -> block detections
  World:add(self.guardBox, self.guardBox.x, self.guardBox.y, self.guardBox.w, self.guardBox.h)


  self.state = {
    idle = idleState("Assets/Player/Warrior_Idle.png"),
    run = runState("Assets/Player/Warrior_Run.png"),
    atk1 = atk1State("Assets/Player/Warrior_Attack1.png"),
    atk2 = atk2State("Assets/Player/Warrior_Attack2.png"),
    guard = guardState("Assets/Player/Warrior_Guard.png"),
    hurt = hurtState("Assets/Player/Sprite-0001.png"),
  }

  self.currentState = self.state.idle
  self.lastState = self.state.idle
  self.comboReady = false
end

function Player:update(dt)
  self.currentState:update(self, dt)
  self.dx = self.dx * (FRICTION^(dt * FPScale)) 
  self.dy = self.dy * (FRICTION^(dt * FPScale)) 
  self.dx = math.clamp(self.dx, -self.maxSpd, self.maxSpd)
  self.dy = math.clamp(self.dy, -self.maxSpd, self.maxSpd)

  --moving box
  local goalX = self.walkBox.x + (self.dx * dt * FPScale)
  local goalY = self.walkBox.y + (self.dy * dt * FPScale)
  local actualX, actualY, cols, len = World:move(self.walkBox, goalX, goalY, walkCollisionFilter)
  self.walkBox.x, self.walkBox.y = actualX, actualY
  self.x, self.y = actualX + walkBoxOffsetX, actualY - walkBoxOffsetY

  --hurt box
  local hurtboxGoalX = self.x - hurtBoxOffsetX
  local hurtboxGoalY = self.y - hurtBoxOffsetY
  local hBoxActualX, hBoxActualY, cols, len = World:move(self.hurtBox, hurtboxGoalX, hurtboxGoalY, takeDmgCollisionFilter)
  self.hurtBox.x, self.hurtBox.y = hBoxActualX, hBoxActualY
  for i=1, len do
    local other = cols[i].other
    if other.layer==LAYER.ATKBOX then
      if not tableContains(self.guardBox.targetTable, other.owner) then
        --only gets hit if its not blocking
        self:set_state(self.state.hurt)
      end
    end
  end

  --atk box
  if self.atkBox.active then
    --player is atking
    local atkboxGoalX = self.x + atkBoxOffsetX
    if self.flip then
        atkboxGoalX = atkboxGoalX - atkFlipOffset
    end
    local atkboxGoalY = self.y - atkBoxOffsetY
    local atkBoxActualX, atkBoxActualY, cols, len = World:move(self.atkBox, atkboxGoalX, atkboxGoalY, dealDmgCollisionFilter)

    for i=1, len do
      local other = cols[i].other
      if other.layer==LAYER.HURTBOX then
        if not tableContains(self.atkBox.targetTable, other.owner) then
          table.insert(self.atkBox.targetTable, other.owner)
          COUNTER = COUNTER + 1
          print(COUNTER) --play hit sound
        end
      end
    end
  end

  --guard box
  if self.guardBox.active then
    --player is guarding
    local guardboxGoalX = self.x - guardBoxOffsetX
    if self.flip then
        guardboxGoalX = guardboxGoalX + guardFlipOffset
    end
    local guardboxGoalY = self.y - guardBoxOffsetY
    local guardBoxActualX, guardBoxActualY, cols, len = World:move(self.guardBox, guardboxGoalX, guardboxGoalY, guardCollisionFilter)

    for i=1, len do
      local other = cols[i].other
      if other.layer==LAYER.ATKBOX then
        if not tableContains(self.guardBox.targetTable, other.owner) then
          table.insert(self.guardBox.targetTable, other.owner)
        end
        COUNTER = COUNTER + 1
        print(COUNTER) --play block sound
      end
    end
  end



  -- self:update_all_positions(actualX,actualY)
  -- self:check_hurt_collisions()


end

function Player:draw()
  self.currentState:draw(self)

  -- Debug: drawStuff
  
  -- love.graphics.setColor(0, 1, 1) -- vermelho
  -- love.graphics.setColor(1, 1, 1) -- volta pro branco
end

function Player:set_state(newState)
  self.atkBox.active = false
  self.atkBox.targetTable = {}

  self.guardBox.active = false
  self.guardBox.targetTable = {}

  self.hurtBox.active = true 


  self.lastState = self.currentState
  self.currentState = newState
  self.currentState:init(self)
end

function Player:get_axis_inputs()
  local x = 0
  local y = 0
  if love.keyboard.isDown("left") then
    x = -1
    self.flip = true
  elseif love.keyboard.isDown("right") then
    x = 1
    self.flip = false
  end

  if love.keyboard.isDown("up") then
    y = -1
  elseif love.keyboard.isDown("down") then
    y = 1
  end
  return {x,y}
end

function Player:on_key_pressed(key)
    self.currentState:on_key_pressed(self, key)
end

function Player:update_all_positions(newX,newY)
  self.walkBox.x, self.walkBox.y  = newX, newY
  self.x, self.y = newX + walkBoxOffsetX, newY - walkBoxOffsetY

  local hurtposX = self.x - hurtBoxOffsetX
  local hurtposY = self.y - hurtBoxOffsetY
  
  local atkposX = self.x + atkBoxOffsetX
  local atkposY = self.y - atkBoxOffsetY

  local guardposX = self.x - guardBoxOffsetX
  local guardposY = self.y - guardBoxOffsetY

  if self.flip then
    atkposX = atkposX - atkFlipOffset
    guardposX = guardposX + guardFlipOffset
  end

  World:update(self.atkBox, atkposX, atkposY)
  World:update(self.guardBox, guardposX, guardposY)
  World:update(self.hurtBox, hurtposX, hurtposY)

end

-- function Player:check_hurt_collisions()
--   local items, len = World:queryRect(self.hurtBox.x, self.hurtBox.y, self.hurtBox.w, self.hurtBox.h)
--   for i=1,len do
--     local other = items[i]
--     print(other.name)
--     if (other.owner ~= self) and (other.layer==) and (other.active) then
--       self:set_state(self.state.hurt)
--       print("OUCH!")
--     end
--   end
  

-- end

