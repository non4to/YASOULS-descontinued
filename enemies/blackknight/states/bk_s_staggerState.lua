-- bks_staggerState.lua
require("enemies.blackknight.bkBaseState")
local animationCycleInterval = 5

bks_staggerState = bkBaseState:extend()

function bks_staggerState:new(spriteSheetPath)
    bks_staggerState.super.new(self, "stagger", spriteSheetPath, 5)
end

function bks_staggerState:init(bk, knockbackDir)
    bks_staggerState.super.init(self, bk)
end

function bks_staggerState:update(bk,dt)    
    if self.currentFrame > #self.animation then
        bk:set_state(bk.state.idle)
    end
    self.currentFrame = self.currentFrame + animationCycleInterval * dt
end

function bks_staggerState:createSprites()
    bks_staggerState.super.createSprites(self)
    local q = self.spritesQuad
    self.animation = {q[2]}
end