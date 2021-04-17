function SetBypassButtonStatus(materialSymbol)
    if (Controls[materialSymbol] == nil) then
        return
    end

    if (Controls[materialSymbol]["bypassButton"] == nil) then
        return
    end

    if (Materials[materialSymbol] == nil) then
        return
    end

    local button = Controls[materialSymbol]["bypassButton"]
    local timeout = Materials[materialSymbol]["timeout"]
    local isBypassed = Materials[materialSymbol]["isBypassed"]
    local numStored = Materials[materialSymbol]["numStored"]
    local targetNumStored = Materials[materialSymbol]["targetNum"]

    local color = nil
    if timeout then
        color = COLOR_TIMEOUT
    elseif (isBypassed and (numStored >= targetNumStored)) then
        color = COLOR_OVERBYPASS
    elseif (numStored >= targetNumStored) then
        color = COLOR_FLOWING
    elseif (isBypassed) then
        color = COLOR_BYPASSED
    else
        color = COLOR_HOLDING
    end

    button:setColor(color[1], color[2], color[3], color[4]);
end
