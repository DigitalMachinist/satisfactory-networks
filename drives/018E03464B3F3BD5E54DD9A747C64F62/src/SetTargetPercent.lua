function SetTargetPercent(newTargetPercent)
    TargetPercent = Clamp(newTargetPercent, 0, 100)
    ValueFileWrite("/primary/data/TargetPercentStored", TargetPercent)
    TargetNumStored = ComputeTargetNumStored(TargetPercent)
    OutputFeedback()
end
