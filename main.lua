--requirements and setups
require("player.player")
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

local playerAcceleration = 0.5
local playerMaxSpeed = 5

-----------------------------------------------------------------------------
function love.load()
  FRICTION = 0.8
  
  ATK_KEY = "z"
  GUARD_KEY = "x"
  TEST_KEY="d"

  World = Bump.newWorld()
  player = Player(540, 360, playerAcceleration, playerMaxSpeed)
  
  R1 = {x=300,y=300,w=50,h=50}
  World:add(R1,R1.x,R1.y,R1.w,R1.h)


end
-----------------------------------------------------------------------------
function love.update(dt)
  player:update(dt)
end
-----------------------------------------------------------------------------
function love.draw()
  push:start()


  
  love.graphics.rectangle("line",R1.x,R1.y,R1.w,R1.h)
  player:draw()

  push:finish()
end
-----------------------------------------------------------------------------
--read pressed keys
function love.keypressed(key)
    player:on_key_pressed(key)
end
-----------------------------------------------------------------------------



