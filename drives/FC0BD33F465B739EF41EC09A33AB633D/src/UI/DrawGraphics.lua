function DrawGraphics()
    if (GPU == nil) then
        return
    end

    if (GraphicStatusScreen == nil) then
        return
    end

    -- Clear the screen back to black (this also binds the display to the GPU so we don't need to do that).
    ClearGraphicDisplay(GPU, GraphicStatusScreen, UI_CLEAR_COLOR, false)

    -- Draw fill meter.
    local x = 0
    local y = math.floor(UI_MODULE_SCREEN_SIZE["y"] / 4)
    local w = UI_MODULE_SCREEN_SIZE["x"]
    local h = UI_MODULE_SCREEN_SIZE["y"] / 2
    local targetFraction = TargetPercent / 100
    local targetThickness = 1
    local borderPadding = 2
    ProgressBar(
        GPU,
        FractionStored, x, y, w, h, UI_METER_BG_COLOR, UI_METER_FG_COLOR,  -- Progress
        borderPadding, UI_METER_BORDER_COLOR,                              -- Border
        targetFraction, targetThickness, UI_METER_TARGET_COLOR             -- Target
    )

    GPU:flush()
end
