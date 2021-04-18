function BackgroundSquareStroke(gpu, x, y, w, h, color, char)
    if (color == nil) then
        color = { 1.0, 1.0, 1.0, 1.0 }
    end

    if (char == nil) then
        char = " "
    end

    gpu:setBackground(color[1], color[2], color[3], color[4])
    gpu:fill(x,   y,     w, 1,   char, char) -- Top
    gpu:fill(x,   y+h-1, w, 1,   char, char) -- Bottom
    gpu:fill(x,   y+1,   1, h-2, char, char) -- Left
    gpu:fill(w-1, y+1,   1, h-2, char, char) -- Right
end