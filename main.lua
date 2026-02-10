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
----------------------------------------------------------------------------

-----------------------------------------------------------------------------
function love.load()
  FRICTION = 0.8
  
  ATK_KEY = "z"
  GUARD_KEY = "x"
  TEST_KEY="d"

  World = Bump.newWorld()
  player = Player(100, 100, playerAcceleration, playerMaxSpeed)
  
  R1 = {layer=0, x=300,y=300,w=50,h=50}
  World:add(R1,R1.x,R1.y,R1.w,R1.h)


end
-----------------------------------------------------------------------------
function love.update(dt)
  player:update(dt)
end
-----------------------------------------------------------------------------
function love.draw()
  push:start()


  
  player:draw()



  
  ------------
  --DRAW ALL BUMP STUFF
  local items = World:getItems()
  for _, item in ipairs(items) do
    local x, y, w, h = World:getRect(item)
    love.graphics.rectangle("line", x, y, w, h)
  end
  ------------
  -------------
  push:finish()
end
-----------------------------------------------------------------------------
--read pressed keys
function love.keypressed(key)
    player:on_key_pressed(key)
end
-----------------------------------------------------------------------------



