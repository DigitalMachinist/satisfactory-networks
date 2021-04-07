function GetNIC(isCritical)
    if (isCritical == nil) then
        isCritical = true
    end
    local cNIC = component.findComponent(findClass("NetworkCard_C"))[1]
    if (cNIC == nil) then
        if (isCritical) then
            computer.panic("NIC not found.")
        else
            return nil
        end
    end

    return component.proxy(cNIC)
end
