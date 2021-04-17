function ComputeTargetNumStored(targetPercent)
    local targetFraction = targetPercent / 100
    return math.floor(targetFraction * StoreSize + 0.5)
end
