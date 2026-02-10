-- baseState.lua
Classic = require("external.classic")

local spriteHeight = 192 
local spriteWidth = 192
local walkboxOffsetW = 72
local walkboxOffsetH = 120
local spritesheetCount = 8
local spriteSheetOffset = 0

BaseState = Classic:extend()

function BaseState:new(name, spriteSheetPath, frameCount)
    self.name = name
    self.frameCount = frameCount
    self.currentFrame = 1
    self.SS = love.graphics.newImage(spriteSheetPath)
    self.SS:setFilter("nearest","nearest")
    self:createSprites()
end

function BaseState:init(p)
    self.currentFrame = 1
end

function BaseState:update(p, dt, animationCycleInterval)
    self.currentFrame = self.currentFrame + animationCycleInterval * dt
    if self.currentFrame > #self.animation + 1 then
        self.currentFrame = 1
    end
end

function BaseState:draw(p)
    local cFrame = math.floor(self.currentFrame)
    local sprite = self.animation[cFrame]
    local scaleX = 1
    local offsetX = -walkboxOffsetW
    local offsetY = -walkboxOffsetH
    if p.flip then
        scaleX = -1
        offsetX = offsetX + spriteWidth - 3
    end
    love.graphics.draw(self.SS, sprite, p.walkBox.x + offsetX, p.walkBox.y + offsetY, 0, scaleX, 1)
end

function BaseState:createSprites()
    self.spritesQuad = GetQuads(self.SS, spriteWidth, spriteHeight, spritesheetCount, spriteSheetOffset)
    -- Classe base não define animation - cada estado define
end

function BaseState:on_key_pressed(p, key)
    -- Função vazia por padrão
    -- Estados que precisam podem sobrescrever (override)
end