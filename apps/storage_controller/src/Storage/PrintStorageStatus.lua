function PrintStorageStatus()
    FractionStored = NumStored / StoreSize
    PercentStored = FractionStored * 100
    print("Material: "..MATERIAL_SYMBOL.. " ("..MATERIALS[MATERIAL_SYMBOL]["name"]..")")
    print("Usage: "..NumStored.." / "..StoreSize)
    print("Percent: "..tonumber(string.format("%.0f", PercentStored)).."%")
    print("Target Usage: "..TargetNumStored.." / "..StoreSize)
    print("Target Percent: "..tonumber(string.format("%.0f", TargetPercent)).."%")
end
