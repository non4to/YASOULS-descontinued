-- bkhurtState.lua
require("enemies.blackknight.bkBaseState")
local animationCycleInterval = 10

bkhurtState = bkBaseState:extend()

function bkhurtState:new(spriteSheetPath)
    bkhurtState.super.new(self, "hurt", spriteSheetPath, 4)
end

function bkhurtState:init(bk, knockbackDir)
    bkhurtState.super.init(self, bk)
    bk.dx = knockbackDir * 1.2
end

function bkhurtState:update(bk,dt)    
    if self.currentFrame > #self.animation then
        bk:set_state(bk.state.idle)
    end    
    self.currentFrame = self.currentFrame + animationCycleInterval * dt
end

function bkhurtState:createSprites()
    bkhurtState.super.createSprites(self)
    local q = self.spritesQuad
    self.animation = {q[1],q[2],q[3],q[4]}
end