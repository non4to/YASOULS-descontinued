-- idleState.lua
require("player.baseState")
local animationCycleInterval = 10

idleState = BaseState:extend()

function idleState:new(spriteSheetPath)
    idleState.super.new(self, "idle", spriteSheetPath, 8)
end

function idleState:init(p)
    idleState.super.init(self, p)
end

function idleState:update(p,dt)
    idleState.super.update(self,p,dt,animationCycleInterval)

    local axis = p:get_axis_inputs()
    if axis[1] ~= 0 or axis[2] ~= 0 then
        p:set_state(p.state.run)
    end
end

function idleState:createSprites()
    idleState.super.createSprites(self)
    local q = self.spritesQuad
    self.animation = {q[1], q[2], q[3], q[4], q[5], q[6], q[7], q[8]}
end

function idleState:on_key_pressed(p, key)
    if key == ATK_KEY then
        p:set_state(p.state.atk1)
    elseif key == GUARD_KEY then
        p:set_state(p.state.guard)
    elseif key == TEST_KEY then
        p:set_state(p.state.hurt)
    end
end
