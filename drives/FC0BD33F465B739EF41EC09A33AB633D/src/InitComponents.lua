function InitComponents()
    GPU = GetGPU()
    NIC = GetNIC()

    for materialSymbol, _ in pairs(CONTROLS) do
        -- Map {material symbol} => {controls} so we can look up panel displays for output of storage status from network events.
        local materialControls = InitMaterialControls(materialSymbol)
        Controls[materialSymbol] = materialControls

        -- Also map {panel module hash} => {material symbol} so we can look up the materials being modified by panel module events.
        if (materialControls["bypassButton"] ~= nil) then
            ModuleMap[materialControls["bypassButton"].hash] = materialSymbol
        end
        if (materialControls["targetDial"] ~= nil) then
            ModuleMap[materialControls["targetDial"].hash] = materialSymbol
        end
    end
end
