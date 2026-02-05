-- hurtState.lua
require("player.baseState")
local animationCycleInterval = 10

hurtState = BaseState:extend()

function hurtState:new(spriteSheetPath)
    hurtState.super.new(self, "hurt", spriteSheetPath, 2)
end

function hurtState:update(p,dt)
    hurtState.super.update(self,p,dt,animationCycleInterval)
    
    if self.currentFrame > #self.animation then
        p:set_state(p.state.idle)
    end

end

function hurtState:createSprites()
    hurtState.super.createSprites(self)
    local q = self.spritesQuad
    self.animation = {q[2],q[2],q[1],q[1],q[1]}
end