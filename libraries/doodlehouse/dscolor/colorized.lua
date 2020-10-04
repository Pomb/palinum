function RGBA (r, g, b, a)
    r = r or 255
    g = g or 255
    b = b or 255
    a = a or 1
    return {r/255, g/255, b/255, a}
  end
  
  function VEC4 (r, g, b, a)
    return {r or 1, g or 1, b or 1, a or 1}
  end
  
  function HEX (value, A)
    HexVal = string.sub(value, 2)
    HexVal = string.upper(HexVal)
    if #HexVal == 3 then
      F = HexVal:sub(1,1)
      S = HexVal:sub(2,2)
      T = HexVal:sub(3,3)
      HexVal = F..F..S..S..T..T
    end
    Val = {}
  
    for i=1, #HexVal do
      Char = HexVal:sub(i, i)
      if Char == "0" then
        Val[i] = tonumber(Char)+1
      elseif Char == "1" then
        Val[i] = tonumber(Char)+1
      elseif Char == "2" then
        Val[i] = tonumber(Char)+1
      elseif Char == "3" then
        Val[i] = tonumber(Char)+1
      elseif Char == "4" then
        Val[i] = tonumber(Char)+1
      elseif Char == "5" then
        Val[i] = tonumber(Char)+1
      elseif Char == "6" then
        Val[i] = tonumber(Char)+1
      elseif Char == "7" then
        Val[i] = tonumber(Char)+1
      elseif Char == "8" then
        Val[i] = tonumber(Char)+1
      elseif Char == "9" then
        Val[i] = tonumber(Char)+1
      elseif Char == "A" then
        Val[i] = 11
      elseif Char == "B" then
        Val[i] = 12
      elseif Char == "C" then
        Val[i] = 13
      elseif Char == "D" then
        Val[i] = 14
      elseif Char == "E" then
        Val[i] = 15
      elseif Char == "F" then
        Val[i] = 16
      end
    end
  
    R = R or 255
    G = G or 255
    B = B or 255
    A = A or 255
    R = Val[1] * 16 + Val[2]
    G = Val[3] * 16 + Val[4]
    B = Val[5] * 16 + Val[6]
  
    return {R/255, G/255, B/255, A}
  end