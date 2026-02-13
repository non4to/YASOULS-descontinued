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

local playerAcceleration = 1--0.5
local playerMaxSpeed = 5
----------------------------------------------------------------------------

-----------------------------------------------------------------------------
function love.load()
  FRICTION = 0.8
  FPScale = 60
  
  ATK_KEY = "z"
  GUARD_KEY = "x"
  TEST_KEY="d"

  World = Bump.newWorld()
  player = Player(100, 100, playerAcceleration, playerMaxSpeed)
  
  fakeEnemy = {hp=100, isPlayer=false}
  R1 = {layer=2, owner=fakeEnemy, active=true, x=300,y=300,w=50,h=50}
  World:add(R1,R1.x,R1.y,R1.w,R1.h)

end
-----------------------------------------------------------------------------
function love.update(dt)
  player:update(dt)
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
  
  player:draw()



  
  ------------
  --DRAW ALL BUMP STUFF
  local items = World:getItems()
  for _, item in ipairs(items) do
    local x, y, w, h = World:getRect(item)
    if item.layer==0 then 
      love.graphics.setColor(1, 1, 1) -- white for walking collision
    elseif item.layer == 1 then
      love.graphics.setColor(1, 0, 0) -- red for take dmg collision
    elseif item.layer == 2 then
      love.graphics.setColor(0, 1, 0) -- green for deal dmg collision
    elseif item.layer == 3 then
      love.graphics.setColor(1, 0, 1) -- purple for deal dmg collision
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



