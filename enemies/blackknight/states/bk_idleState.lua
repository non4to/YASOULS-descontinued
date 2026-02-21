-- idleState.lua
require("enemies.blackknight.bkBaseState")
local animationCycleInterval = 10

bkidleState = bkBaseState:extend()

function bkidleState:new(spriteSheetPath)
    bkidleState.super.new(self, "idle", spriteSheetPath, 8)
end

function bkidleState:init(bk)
    bkidleState.super.init(self, bk)
end

function bkidleState:update(bk,dt)
    bkidleState.super.update(self,bk,dt,animationCycleInterval)

    -- local axis = bk:get_axis_inputs()
    -- if axis[1] ~= 0 or axis[2] ~= 0 then
    --     bk:set_state(bk.state.run)
    -- end
end

function bkidleState:createSprites()
    bkidleState.super.createSprites(self)
    local q = self.spritesQuad
    self.animation = {q[1], q[2], q[3], q[4], q[5], q[6], q[7], q[8]}
end

-- function idleState:on_key_pressed(bk, key)
--     if key == ATK_KEY then
--         bk:set_state(bk.state.atk1)
--     elseif key == GUARD_KEY then
--         bk:set_state(bk.state.guard)
--     elseif key == TEST_KEY then
--         bk:set_state(bk.state.hurt)
--     end
-- end
