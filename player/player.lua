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
local walkBoxW = 40
local walkBoxH = 20
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
  self.walkBox = {layer=0, owner=self, x=self.x, y=self.y, w=walkBoxW, h=walkBoxH} --layer0 -> walls, obstacles, 'walk thought physics'
  World:add(self.walkBox, self.walkBox.x, self.walkBox.y, self.walkBox.w, self.walkBox.h)

  --hurt-box collision
  self.hurtBox = {layer=1, owner=self, x=self.x, y=self.y, w=hurtBoxW, h=hurtBoxH,} --layer1 -> hurt detections
  World:add(self.hurtBox, self.hurtBox.x, self.hurtBox.y-self.hurtBox.h, self.hurtBox.w, self.hurtBox.h)

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

  self.dx = self.dx * FRICTION
  self.dy = self.dy * FRICTION

  self.dx = math.clamp(self.dx, -self.maxSpd, self.maxSpd)
  self.dy = math.clamp(self.dy, -self.maxSpd, self.maxSpd)

  local goalX, goalY = self.x + self.dx, self.y + self.dy
  local actualX, actualY, cols, len = World:move(self.walkBox, goalX, goalY, playerCollisionFilter)
  self.x, self.y = actualX, actualY

  local hurtBoxX = self.x - (walkBoxW - hurtBoxW) / 2 
  local hurtBoxY = self.y - self.hurtBox.h
  World:update(self.hurtBox, hurtBoxX, hurtBoxY)

  -- self.x = self.x + self.dx
  -- self.y = self.y + self.dy

end

function Player:draw()
  self.currentState:draw(self)


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

