function DrawText()
    if (TextStatusScreen == nil) then
        return
    end

    local lines = {
        " "..MATERIAL_SYMBOL.." ("..tonumber(string.format("%.0f", PercentStored)).."%)",
        " = "..NumStored.." / "..StoreSize,
        " > "..TargetNumStored.." ("..TargetPercent.."%)"
    }

    TextStatusScreen.size = 36
    TextStatusScreen.text = table.concat(lines, '\n')
end
