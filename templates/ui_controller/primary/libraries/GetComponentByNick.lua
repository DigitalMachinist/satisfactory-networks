function GetComponentByNick(nickname)
    local cComponent = component.findComponent(nickname)[1]
    if cComponent == nil then
        computer.panic("Panel ("..nickname..") not found.")
    end

    return component.proxy(cComponent)
end
