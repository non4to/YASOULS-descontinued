-- runState.lua
require("player.baseState")
local animationCycleInterval = 10

runState = BaseState:extend()

function runState:new(spriteSheetPath)
    runState.super.new(self, "run", spriteSheetPath, 6)
end

function runState:init(p)
    runState.super.init(self, p)
end

function runState:update(p, dt)
    runState.super.update(self, p,dt, animationCycleInterval)

    local axis = p:get_axis_inputs()
    if axis[1] == 0 and axis[2] == 0 then
        p:set_state(p.state.idle)
    else
        p.dx = p.dx + p.acc * axis[1]
        p.dy = p.dy + p.acc * axis[2]
    end
end

function runState:createSprites()
    runState.super.createSprites(self)
    local quads = self.spritesQuad
    self.animation = {quads[1], quads[2], quads[3], quads[4], quads[5], quads[6]}
end

function runState:on_key_pressed(p, key)
    if key == ATK_KEY then
        p:set_state(p.state.atk1)
    elseif key == GUARD_KEY then
        p:set_state(p.state.guard)
    end
end