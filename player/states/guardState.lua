-- guardState.lua
require("player.baseState")

local animationCycleInterval = 9

guardState = BaseState:extend()
-- apertar guard → guardState (parry window ativa)
--     ├── ataque chega DENTRO da janela → parryState (counter window)
--     │       └── jogador aperta ataque → contra-ataque especial
--     └── ataque chega FORA da janela → guard normal (toma menos dano)
-- parry window de 0.2s
-- mecanica pra nao deixar spamar parry: 
--  contar quantas vezes o parry foi apertado por um tempo x
--  se foi apertado mais de Y vezes, diminuir a parry window pra 0.1
--  se foi apertado mais de K vezes, considerar block sempre.

function guardState:new(spriteSheetPath)
    guardState.super.new(self, "guard", spriteSheetPath, 6)
end

function guardState:init(p)
    guardState.super.init(self, p)
    p.guardBox.active = true
end

function guardState:update(p, dt)
    guardState.super.update(self, p,dt, animationCycleInterval)
    local axis = p:get_axis_inputs()
    p.dx = p.dx + p.acc * axis[1] * 0.075
    p.dy = p.dy + p.acc * axis[2] * 0.075
    if not love.keyboard.isDown(GUARD_KEY) then
        p:set_state(p.state.idle)
    end

end

function guardState:createSprites()
    guardState.super.createSprites(self)
    local quads = self.spritesQuad
    self.animation = {quads[1], quads[2], quads[3], quads[4], quads[5], quads[6]}
end

function guardState:on_key_pressed(p, key)
    if key == ATK_KEY then
        p:set_state(p.state.atk1)
    end
end