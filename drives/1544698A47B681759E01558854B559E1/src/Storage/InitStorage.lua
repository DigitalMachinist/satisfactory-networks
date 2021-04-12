function InitStorage()
    NumStored, StoreSize = GetContainerUsage()
    IsBypassed = ValueFileRead("/primary/data/IsBypassed") == "true"
    TargetPercent = tonumber(ValueFileRead("/primary/data/TargetPercentStored"))
    TargetNumStored = ComputeTargetNumStored(TargetPercent)
end