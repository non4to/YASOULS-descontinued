-- atk1State.lua
require("player.baseState")

local animationCycleInterval = 11

atk1State = BaseState:extend()

function atk1State:new(spriteSheetPath)
    atk1State.super.new(self, "atk1", spriteSheetPath, 4)
end

function atk1State:init(p)
    atk1State.super.init(self, p)
    p.atkBox.active = true
    SOUND.atk1:stop()
    SOUND.atk1:play()
end

function atk1State:update(p, dt)
    local axis = p:get_axis_inputs()
    p.dx = p.dx + p.acc * axis[1] * 0.15
    p.dy = p.dy + p.acc * axis[2] * 0.15

    if self.currentFrame > #self.animation then
        if love.keyboard.isDown(GUARD_KEY) then
            p:set_state(p.state.guard)
        elseif p.comboReady then
            p:set_state(p.state.atk2)
        else
            p:set_state(p.state.idle)
        end
    end
    self.currentFrame = self.currentFrame + animationCycleInterval * dt
end

function atk1State:createSprites()
    atk1State.super.createSprites(self)
    local quads = self.spritesQuad
    self.animation = {quads[1], quads[2], quads[3], quads[4], quads[4]}
end

function atk1State:on_key_pressed(p, key)
    if key == ATK_KEY then
        p.comboReady = true
    end
end