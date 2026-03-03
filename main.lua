--requirements and setups
require("player.player")
-- require("enemies.baseEnemy")
require("enemies.blackknight.blackknight")
require("tools")
Bump = require("external.bump")

--push takes care of window sizes
local push = require "external.push"
local gameWidth, gameHeight = 960, 640 --fixed game resolution
local windowWidth, windowHeight = love.window.getDesktopDimensions()
local windowScale = 0.5 
local gbaScaleX, gbaScaleY = gameWidth/240, gameHeight/160
windowWidth, windowHeight = windowWidth*windowScale, windowHeight*windowScale --make the window a bit smaller than the screen itself
push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false})

local playerAcceleration = 1
local playerMaxSpeed = 2
----------------------------------------------------------------------------

-----------------------------------------------------------------------------
function love.load()
  LAYER = {
    SOLID = 0,
    HURTBOX = 1,
    ATKBOX = 2,
    GUARDBOX = 3 
  }

  HITSTOP = {
    active = false,
    timer = 0,
  }

  HITSTOP_STANDARD = {
    parry = 5*(1/60),
    hit = 5*(1/60),
    block = 7*(1/60),
  }

  FRICTION = 0.8
  FPScale = 60
  PARRY_WINDOW = 0.2
  
  ATK_KEY = "z"
  GUARD_KEY = "x"
  TEST_KEY="d"

  World = Bump.newWorld()
  player = Player(50, 50, playerAcceleration, playerMaxSpeed)
  bk = BlackKnight(150,150, playerAcceleration, playerMaxSpeed)
  bk2 = BlackKnight(150,300, playerAcceleration, playerMaxSpeed)


  COUNTER = 0
  fakeEnemy = {hp=100}
  -- R1 = {name="ret", layer=LAYER.ATKBOX, owner=fakeEnemy, active=true, x=300,y=400,w=50,h=50}
  -- R2 = {name="ret2", layer=LAYER.HURTBOX, owner=fakeEnemy, active=true, x=300,y=100,w=50,h=50}

  
  -- World:add(R1,R1.x,R1.y,R1.w,R1.h)
  -- World:add(R2,R2.x,R2.y,R2.w,R2.h)

  --sounds
  SOUND ={
    atk1 = love.audio.newSource("Assets/Sound/Sword Attacks Hits and Blocks/Sword Attack 2.ogg", "static"),
    atk2 = love.audio.newSource("Assets/Sound/Sword Attacks Hits and Blocks/Sword_Attack_1.ogg", "static"),
    hit1 = love.audio.newSource("Assets/Sound/Sword Attacks Hits and Blocks/Sword Impact Hit 1.ogg", "static"),
    hit2 = love.audio.newSource("Assets/Sound/Sword Attacks Hits and Blocks/Sword Impact Hit 2.ogg", "static"),
    hit3 = love.audio.newSource("Assets/Sound/Sword Attacks Hits and Blocks/Sword Impact Hit 3.ogg", "static"),
    parry = love.audio.newSource("Assets/Sound/Sword Attacks Hits and Blocks/Sword Parry 1.ogg", "static"),
    block = love.audio.newSource("Assets/Sound/Sword Attacks Hits and Blocks/Sword Blocked 1.ogg", "static"),

  } 
end
-----------------------------------------------------------------------------
function love.update(dt)
  if HITSTOP.active then
    HITSTOP.timer = HITSTOP.timer - dt
    if HITSTOP.timer < 0 then
      HITSTOP.active = false
    end
    return
  end

  player:update(dt)
  bk:update(dt)
  bk2:update(dt)
  -- print(player.currentState.name)
end
-----------------------------------------------------------------------------
function love.draw()
  push:start()
--gray background
  love.graphics.setColor(0.4, 0.4, 0.4)
  love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)
  love.graphics.setColor(1, 1, 1) -- Volta para branco
--------------------------------------------
  
  bk:draw()
  bk2:draw()  
  player:draw()

  ------------
  --DRAW ALL BUMP STUFF
  local items = World:getItems()
  for _, item in ipairs(items) do
    local x, y, w, h = World:getRect(item)
    love.graphics.setColor(1, 1, 0 ) -- yellow for everything else
    if item.layer==LAYER.SOLID then 
      love.graphics.setColor(1, 1, 1) -- white for walking collision
    elseif item.layer == LAYER.HURTBOX then
      love.graphics.setColor(1, 0, 0) -- red for take dmg collision
    elseif item.layer == LAYER.ATKBOX then
      love.graphics.setColor(0, 1, 0) -- green for deal dmg collision
    elseif item.layer == LAYER.GUARDBOX then
      love.graphics.setColor(1, 0, 1) -- purple for block collision
    end
    if item.active then
      love.graphics.rectangle("line", x, y, w, h)
    end
    love.graphics.setColor(1, 1, 1) 
  end
  ------------
  love.graphics.setColor(0, 0, 1)
  love.graphics.rectangle("line", 0, 0, player.x, player.y)
  love.graphics.setColor(1, 1, 1) 

  -------------
  push:finish()
end
-----------------------------------------------------------------------------
--read pressed keys
function love.keypressed(key)
    player:on_key_pressed(key)
end
-----------------------------------------------------------------------------



