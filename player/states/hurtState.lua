-- hurtState.lua
require("player.baseState")
local animationCycleInterval = 10

hurtState = BaseState:extend()

function hurtState:new(spriteSheetPath)
    hurtState.super.new(self, "hurt", spriteSheetPath, 4)
end

function hurtState:init(p, knockbackDir)
    hurtState.super.init(self, p)
    p.dx = knockbackDir * 1.2

end

function hurtState:update(p,dt)    
    if self.currentFrame > #self.animation then
        p:set_state(p.state.idle)
    end
    
    self.currentFrame = self.currentFrame + animationCycleInterval * dt
end

function hurtState:createSprites()
    hurtState.super.createSprites(self)
    local q = self.spritesQuad
    self.animation = {q[1],q[2],q[3],q[4]}
end