function GetComponentByNick(nickname, isCritical)
    if (isCritical == nil) then
        isCritical = true
    end
    local cComponent = component.findComponent(nickname)[1]
    if (cComponent == nil) then
        if (isCritical) then
            computer.panic("No component matching "..nickname.." found.")
        else
            return nil
        end
    end

    return component.proxy(cComponent)
end
