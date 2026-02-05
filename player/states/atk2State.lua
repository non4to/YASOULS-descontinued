-- atk2State.lua
require("player.baseState")

local animationCycleInterval = 9

atk2State = BaseState:extend()

function atk2State:new(spriteSheetPath)
    atk2State.super.new(self, "atk2", spriteSheetPath, 4)
end

function atk2State:update(p, dt)
    atk2State.super.update(self, p,dt, animationCycleInterval)
    local axis = p:get_axis_inputs()
    p.dx = p.dx + p.acc * axis[1] * 0.15
    p.dy = p.dy + p.acc * axis[2] * 0.15
    if self.currentFrame > #self.animation then
        if love.keyboard.isDown(GUARD_KEY) then
            p:set_state(p.state.guard)
        elseif p.comboReady then
            p:set_state(p.state.atk1)
        else
            p:set_state(p.state.idle)
        end
    end

end

function atk2State:createSprites()
    atk2State.super.createSprites(self)
    local quads = self.spritesQuad
    self.animation = {quads[1], quads[2], quads[3], quads[4]}
end

function atk2State:on_key_pressed(p, key)
    if key == ATK_KEY then
        p.comboReady = true
    end
end