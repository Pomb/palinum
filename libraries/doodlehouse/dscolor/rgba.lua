function RGBA (r, g, b, a)
    r = r or 255
    g = g or 255
    b = b or 255
    a = a or 1
    return {r/255, g/255, b/255, a}
  end