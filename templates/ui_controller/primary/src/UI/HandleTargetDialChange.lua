function HandleTargetDialChange(materialSymbol, anticlockwise)
    local material = Materials[materialSymbol]
    if (material == nil) then
        return
    end

    local change = -TARGET_DIAL_SENSITIVITY
    if (anticlockwise) then
        change = -1 * change
    end

    local targetPercent = math.floor((100 * material["targetNum"] / material["storeSize"]) + 0.5)
    local newTargetPercent = Clamp(material["targetPercent"] + change, 0, 100)
    NIC:send(material["sender"], PORT_STORAGE, UiSetTarget(newTargetPercent))
    print("[TX] STORAGE: SetTarget "..newTargetPercent.." on "..material["sender"])
end
