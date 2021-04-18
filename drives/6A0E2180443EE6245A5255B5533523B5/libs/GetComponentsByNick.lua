function GetComponentsByNick(nickname, isCritical)
    if (isCritical == nil) then
        isCritical = true
    end
    local cComponents = component.findComponent(nickname)
    if (cComponents == nil) then
        if (isCritical) then
            computer.panic("No components matching "..nickname.." were found.")
        else
            return {}
        end
    end

    return component.proxy(cComponents)
end
