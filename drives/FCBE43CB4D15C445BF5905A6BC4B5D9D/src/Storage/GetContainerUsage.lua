function GetContainerUsage()
    local totalSize = 0;
    local totalUsed = 0;
    local materialStackSize = MATERIALS[MATERIAL_SYMBOL]["stackSize"]
    for _, container in pairs(Containers) do
        for _, inventory in pairs(container:getInventories()) do
            totalSize = totalSize + inventory.size * materialStackSize
            totalUsed = totalUsed + inventory.itemCount
        end
    end

    return totalUsed, totalSize
end
