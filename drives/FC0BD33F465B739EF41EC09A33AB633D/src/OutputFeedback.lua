function OutputFeedback(force)
    if force == nil then
        force = true
    end

    for materialSymbol, _ in pairs(Materials) do
        if (force or Materials[materialSymbol]["isDirty"]) then
            SetBypassButtonStatus(materialSymbol)
            DrawText(materialSymbol)
            DrawGraphics(materialSymbol)
        end
    end

    PrevFeedbackTime = computer.millis()
end
