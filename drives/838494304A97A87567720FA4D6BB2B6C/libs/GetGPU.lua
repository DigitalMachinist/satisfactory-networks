function GetGPU(isCritical)
    if (isCritical == nil) then
        isCritical = true
    end
    local gpu = computer.getGPUs()[1]
    if (gpu == nil) then
        if (isCritical) then
            computer.panic("GPU not found.")
        else
            return nil
        end
    end

    return gpu
end
