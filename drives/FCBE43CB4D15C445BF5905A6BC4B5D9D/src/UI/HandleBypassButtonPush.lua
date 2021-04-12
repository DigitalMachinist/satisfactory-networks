function HandleBypassButtonPush(materialSymbol)
    local material = Materials[materialSymbol]
    if (material == nil) then
        return
    end

    local newIsBypassed = not material["isBypassed"]
    NIC:send(material["sender"], PORT_STORAGE, UiSetIsBypassed(newIsBypassed))
    print("[TX] STORAGE: SetIsBypassed on "..material["sender"])
end
