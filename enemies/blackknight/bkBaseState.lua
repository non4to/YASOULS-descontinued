-- baseState.lua
local Classic = require("external.classic")

local spriteHeight = 192 
local spriteWidth = 192
local offsetX = spriteWidth/2
local offsetY = spriteHeight/2

local spritesheetCount = 8
local spriteSheetOffset = 0

bkBaseState = Classic:extend()

function bkBaseState:new(name, spriteSheetPath, frameCount)
    self.name = name
    self.frameCount = frameCount
    self.currentFrame = 1
    self.SS = love.graphics.newImage(spriteSheetPath)
    self.SS:setFilter("nearest","nearest")
    self:createSprites()
end

function bkBaseState:init(bk)
    self.currentFrame = 1
    bk.comboReady = false
end

function bkBaseState:update(bk, dt, animationCycleInterval)
    self.currentFrame = self.currentFrame + animationCycleInterval * dt
    if self.currentFrame > #self.animation then
        self.currentFrame = 1
    end
end

function bkBaseState:draw(bk)
    local cFrame = math.floor(self.currentFrame)
    local sprite = self.animation[cFrame]
    local scaleX = 1
    local offsetX = -offsetX
    local offsetY = -offsetY
    if bk.flip then
        scaleX = -1
        offsetX = offsetX + spriteWidth
    end
    love.graphics.draw(self.SS, sprite, bk.x + offsetX, bk.y + offsetY, 0, scaleX, 1)
end

function bkBaseState:createSprites()
    self.spritesQuad = GetQuads(self.SS, spriteWidth, spriteHeight, spritesheetCount, spriteSheetOffset)
    -- Classe base não define animation - cada estado define
end

-- function BaseState:on_key_pressed(p, key)
--     -- Função vazia por padrão
--     -- Estados que precisam podem sobrescrever (override)
-- end