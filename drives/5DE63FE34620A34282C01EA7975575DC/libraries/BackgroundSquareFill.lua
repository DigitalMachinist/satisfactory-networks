function BackgroundSquareFill(gpu, x, y, w, h, color, char)
    if (color == nil) then
        color = { 1.0, 1.0, 1.0, 1.0 }
    end

    if (char == nil) then
        char = " "
    end

    gpu:setBackground(color[1], color[2], color[3], color[4])
    gpu:fill(x, y, w, h, char, char)
end