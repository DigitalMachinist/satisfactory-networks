
function SetBypassButtonStatus()
    if (BypassButton == nil) then
        return
    end

    local color = nil
    if (IsBypassed and (NumStored >= TargetNumStored)) then
        color = COLOR_OVERBYPASS
    elseif (NumStored >= TargetNumStored) then
        color = COLOR_FLOWING
    elseif (IsBypassed) then
        color = COLOR_BYPASSED
    else
        color = COLOR_HOLDING
    end

    BypassButton:setColor(color[1], color[2], color[3], color[4]);
end
