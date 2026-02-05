function GetQuads(spriteSheet,spriteWidth,spriteHeight,spriteCount,spriteOffset)
--function used to return quads from a sprite sheet
  local quads = {}
  for i = 1, spriteCount do
      local x = (i - 1) * (spriteOffset+spriteWidth)
      quads[i] = love.graphics.newQuad(x, 0, spriteWidth, spriteHeight, spriteSheet:getDimensions())
  end
  return quads
end

function math.clamp(value, min, max)
    return math.max(min, math.min(value, max))
end