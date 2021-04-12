function HandleTargetDialChange(anticlockwise)
    local change = -TARGET_DIAL_SENSITIVITY
    if (anticlockwise) then
        change = -1 * change
    end

    SetTargetPercent(TargetPercent + change)
end
