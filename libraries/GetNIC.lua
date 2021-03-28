function GetNIC(isCritical)
    local cNIC = component.findComponent("NetworkCard_C")[1]
    if cNIC == nil then
        computer.panic("NIC (NetworkCard_C) not found.")
    end

    return component.proxy(cNIC)
end
