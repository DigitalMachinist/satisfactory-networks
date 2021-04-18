function ClearGraphicDisplay(gpu, display, color, flush)
    if color == nil then
        color = { 0, 0, 0, 1 }
    end
    
    if flush == nil then
        flush = true
    end

    GPU:bindScreen(display)
    GPU:setBackground(color[1], color[2], color[3], color[4])
    GPU:fill(0, 0, UI_MODULE_SCREEN_SIZE["x"], UI_MODULE_SCREEN_SIZE["y"], " ", " ")

    if flush then
        GPU:flush() 
    end
end