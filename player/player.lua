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

local spriteHeight = 192 
local spriteWidth = 192

local walkBoxW = 45
local walkBoxH = 10
local walkboxOffsetW = 20
local walkboxOffsetH = 10



local hurtBoxWOffset = 5
local hurtBoxW = walkBoxW
local hurtBoxH = 40

local playerCollisionFilter = function(item, other)
  if item.owner == other.owner then return nil
  elseif other.layer == 0 then return "slide"
  else return "cross"
  end
end

function Player:new(x,y,acceleration,maxSpeed)  
  self.dx = 0
  self.dy = 0
  self.isPlayer=true
  self.flip=false -- false == right; true == left
  self.location = nil
  self.acc = acceleration
  self.maxSpd = maxSpeed
  
  --walk-box collision
  self.walkBox = {layer=0, owner=self, x=x, y=y, w=walkBoxW, h=walkBoxH} --layer0 -> walls, obstacles, 'walk thought physics'
  World:add(self.walkBox, self.walkBox.x, self.walkBox.y, self.walkBox.w, self.walkBox.h)

  --hurt-box collision
  -- self.hurtBox = {layer=1, owner=self, x=self.x, y=self.y, w=hurtBoxW, h=hurtBoxH,} --layer1 -> hurt detections
  -- World:add(self.hurtBox, self.hurtBox.x, self.hurtBox.y-self.hurtBox.h, self.hurtBox.w, self.hurtBox.h)

  --atk-box collision

  self.state = {
    idle = idleState("Assets/Player/Warrior_Idle.png"),
    run = runState("Assets/Player/Warrior_Run.png"),
    atk1 = atk1State("Assets/Player/Warrior_Attack1.png"),
    atk2 = atk2State("Assets/Player/Warrior_Attack2.png"),
    guard = guardState("Assets/Player/Warrior_Guard.png"),
    -- hurt = hurtState("Assets/Player/Warrior_Hurt.png"),
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

  local goalX = self.walkBox.x + (self.dx * dt * FPScale)
  local goalY = self.walkBox.y + (self.dy * dt * FPScale)
  local actualX, actualY, cols, len = World:move(self.walkBox, goalX, goalY, playerCollisionFilter)
  self.walkBox.x = actualX
  self.walkBox.y = actualY
  self.x = self.walkBox.x
  -- self.y = self.walkBox.y


end

function Player:draw()
  self.currentState:draw(self)

  -- Debug: drawStuff
  
  -- love.graphics.setColor(0, 1, 1) -- vermelho
  -- love.graphics.setColor(1, 1, 1) -- volta pro branco
end

function Player:set_state(newState)
  self.lastState = self.currentState
  self.currentState = newState
  self.comboReady = false
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

