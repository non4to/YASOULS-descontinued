-- parryState.lua
require("player.baseState")
local animationCycleInterval = 40

parryState = BaseState:extend()

function parryState:new(spriteSheetPath)
    parryState.super.new(self, "hurt", spriteSheetPath, 5)
end

function parryState:init(p, knockbackDir)
    parryState.super.init(self, p)

end

function parryState:update(p,dt)    
    if self.currentFrame > #self.animation then
        p:set_state(p.state.guard)
    end
    self.currentFrame = self.currentFrame + animationCycleInterval * dt
end

function parryState:createSprites()
    parryState.super.createSprites(self)
    local q = self.spritesQuad
    self.animation = {q[1],q[2],q[3],q[4], q[5]}
end