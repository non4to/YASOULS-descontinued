-- bkatk1State.lua
require("enemies.blackknight.bkBaseState")
local animationCycleInterval = 11

bkatk1State = bkBaseState:extend()

function bkatk1State:new(spriteSheetPath)
    bkatk1State.super.new(self, "atk1", spriteSheetPath, 4)
end

function bkatk1State:init(bk)
    bkatk1State.super.init(self, bk)
end

function bkatk1State:update(bk, dt)
    if self.currentFrame > 4 then
        -- print(self.currentFrame)
        SOUND.atk1:stop()
        SOUND.atk1:play()

        if not bk.atkBox.active then
            bk.atkBox.active = true
        end

    end

    if self.currentFrame > #self.animation then
        bk:set_state(bk.state.idle)
    end
    self.currentFrame = self.currentFrame + animationCycleInterval * dt
end

function bkatk1State:createSprites()
    bkatk1State.super.createSprites(self)
    local quads = self.spritesQuad
    self.animation = {quads[1], quads[1], quads[1], quads[2], quads[3], quads[4], quads[4]}
end