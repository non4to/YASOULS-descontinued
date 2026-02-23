require("enemies.baseEnemy")
require("enemies.blackknight.states.bk_idleState")
-- require("enemies.blackknight.states.bk_runState")
require("enemies.blackknight.states.bk_atk1State")
-- require("enemies.blackknight.states.bk_atk2State")
-- require("enemies.blackknight.states.bk_guardState")
require("enemies.blackknight.states.bk_hurtState")
require("enemies.blackknight.states.bk_s_staggerState")
require("enemies.baseEnemy")

local Tools = require("tools")

BlackKnight = Enemy:extend()

--sprite sizes
local spriteHeight = 192 
local spriteWidth = 192
--BlackKnight ancor:
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

--enemies atributes
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

function BlackKnight:new(x,y,acceleration,maxSpeed)    
  BlackKnight.super.new(self, x,y,acceleration,maxSpeed)

  self.counter = 0

  --walk-box collision
  self.walkBox = {layer=LAYER.SOLID, owner=self, active=true, x=x-walkBoxOffsetX, y=y+walkBoxOffsetY, w=walkBoxW, h=walkBoxH} --layer0 -> walls, obstacles, 'walk thought physics'
  World:add(self.walkBox, self.walkBox.x, self.walkBox.y, self.walkBox.w, self.walkBox.h)

  --hurt-box collision
  self.hurtBox = {layer=LAYER.HURTBOX, owner=self, active=true, x=x-hurtBoxOffsetX, y=y-hurtBoxOffsetY, w=hurtBoxW, h=hurtBoxH,} --layer1 -> hurt detections
  World:add(self.hurtBox, self.hurtBox.x, self.hurtBox.y, self.hurtBox.w, self.hurtBox.h)

  --atk-box collision
  self.atkBox = {layer=LAYER.ATKBOX, owner=self, active=false, x=x+atkBoxOffsetX, y=y-atkBoxOffsetY, w=atkBoxW, h=atkBoxH, targetTable={}} --layer2 -> atk detections
  World:add(self.atkBox, self.atkBox.x, self.atkBox.y, self.atkBox.w, self.atkBox.h)

  -- --guard-box collision
  -- self.guardBox = {layer=LAYER.GUARDBOX, owner=self, active=false, x=x-guardBoxOffsetX, y=y-guardBoxOffsetY, w=guardBoxW, h=guardBoxH, targetTable={}} --layer3 -> block detections
  -- World:add(self.guardBox, self.guardBox.x, self.guardBox.y, self.guardBox.w, self.guardBox.h)


  self.state = {
    idle = bkidleState("Assets/Enemies/BlackKnight/BlackKnight_Idle.png"),
    -- run = runState("Assets/Enemies/BlackKnight/BlackKnight_Run.png"),
    atk1 = bkatk1State("Assets/Enemies/BlackKnight/BlackKnight_Attack1.png"),
    -- atk2 = atk2State("Assets/Enemies/BlackKnight/BlackKnight_Attack2.png"),
    -- guard = guardState("Assets/Enemies/BlackKnight/BlackKnight_Guard.png"),
    hurt = bkhurtState("Assets/Enemies/BlackKnight/BlackKnight_Hurt.png"),
    s_stagger = bks_staggerState("Assets/Enemies/BlackKnight/BlackKnight_Hurt.png")
  }

  self.currentState = self.state.idle
  self.lastState = self.state.idle
  self.comboReady = false
end

function BlackKnight:update(dt)
  self.currentState:update(self, dt)
----------------------------------------------
  self.counter = self.counter + 1
  if self.counter > 200 then
    self:set_state(self.state.atk1)
    self.counter = 0
  end
----------------------------------------------


  self.dx = self.dx * (FRICTION^(dt * FPScale)) 
  self.dy = self.dy * (FRICTION^(dt * FPScale)) 
  self.dx = math.clamp(self.dx, -self.maxSpd, self.maxSpd)
  self.dy = math.clamp(self.dy, -self.maxSpd, self.maxSpd)

  ------------------------------
  -- MOVING
  ------------------------------
  --walkbox
  local goalX = self.walkBox.x + (self.dx * dt * FPScale)
  local goalY = self.walkBox.y + (self.dy * dt * FPScale)
  local actualX, actualY, cols, len = World:move(self.walkBox, goalX, goalY, walkCollisionFilter)
  self.walkBox.x, self.walkBox.y = actualX, actualY
  self.x, self.y = actualX + walkBoxOffsetX, actualY - walkBoxOffsetY
  --hurtbox
  local hurtboxGoalX = self.x - hurtBoxOffsetX
  local hurtboxGoalY = self.y - hurtBoxOffsetY
  local hBoxActualX, hBoxActualY, cols, len = World:move(self.hurtBox, hurtboxGoalX, hurtboxGoalY, takeDmgCollisionFilter)
  self.hurtBox.x, self.hurtBox.y = hBoxActualX, hBoxActualY

  ------------------------------
  -- ATK
  ------------------------------
  if self.atkBox.active then
    --player is atking
    local atkboxGoalX = self.x + atkBoxOffsetX
    local dir = 1
    if self.flip then
        atkboxGoalX = atkboxGoalX - atkFlipOffset
        dir = -1
    end
    local atkboxGoalY = self.y - atkBoxOffsetY
    local atkBoxActualX, atkBoxActualY, cols, len = World:move(self.atkBox, atkboxGoalX, atkboxGoalY, dealDmgCollisionFilter)

    for i=1, len do
      local other = cols[i].other
      if other.layer==LAYER.HURTBOX then
        if not tableContains(self.atkBox.targetTable, other) then
          table.insert(self.atkBox.targetTable, other)
          if other.owner.isPlayer then
            local isGuarding = other.owner.currentState.name == "guard"
            local backStab = self.flip == other.owner.flip
            if other.owner.parryWindowOpen then
              print("PARRIED!")
              other.owner:parry()
              self:parried()
              SOUND.atk1:stop()
              SOUND.atk1:stop()
              SOUND.parry:play()
            elseif isGuarding and not(backStab) then
              a=1 --funcao de bloquear
              print("BLOCK!")
            else
              other.owner:take_damage(dir)
            end
          COUNTER = COUNTER + 1
          print(COUNTER) --play hit sound
          end
        end
      end
    end
  end

end

function BlackKnight:draw()
  self.currentState:draw(self)

  -- Debug: drawStuff
end

function BlackKnight:set_state(newState, ...)
  self.atkBox.active = false
  self.atkBox.targetTable = {}

  -- self.guardBox.active = false
  -- self.guardBox.targetTable = {}

  self.hurtBox.active = true 

  self.lastState = self.currentState
  self.currentState = newState
  self.currentState:init(self, ...)
end

function BlackKnight:take_damage(knockbackDir)
  HITSTOP.active=true
  HITSTOP.timer = HITSTOP_STANDARD.hit
  self:set_state(self.state.hurt, knockbackDir)
end

function BlackKnight:parried()
  self:set_state(self.state.s_stagger)
end