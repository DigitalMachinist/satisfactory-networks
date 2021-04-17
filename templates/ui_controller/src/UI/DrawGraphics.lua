function DrawGraphics(materialSymbol)
    if (GPU == nil) then
        return
    end

    local graphicDisplay = Controls[materialSymbol]["graphicDisplay"]
    if (graphicDisplay == nil) then
        return
    end

    -- Clear the screen back to black (this also binds the display to the GPU so we don't need to do that).
    ClearGraphicDisplay(GPU, graphicDisplay, UI_CLEAR_COLOR, false)

    -- Draw fill meter.
    local x = 0
    local y = math.floor(UI_MODULE_SCREEN_SIZE["y"] / 4)
    local w = UI_MODULE_SCREEN_SIZE["x"]
    local h = UI_MODULE_SCREEN_SIZE["y"] / 2
    local storedFraction = Materials[materialSymbol]["percentStored"] / 100
    local targetFraction = Materials[materialSymbol]["targetPercent"] / 100
    local targetThickness = 1
    local borderPadding = 2
    ProgressBar(
        GPU,
        storedFraction, x, y, w, h, UI_METER_BG_COLOR, UI_METER_FG_COLOR,  -- Progress
        borderPadding, UI_METER_BORDER_COLOR,                              -- Border
        targetFraction, targetThickness, UI_METER_TARGET_COLOR             -- Target
    )

    GPU:flush()
end
