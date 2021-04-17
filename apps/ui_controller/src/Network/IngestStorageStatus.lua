function IngestStorageStatus(message)
    local materialSymbol = message["material"]
    if (Materials[materialSymbol] == nil) then
        Materials[materialSymbol] = {}
    end

    Materials[materialSymbol]["sender"] = message["sender"]
    Materials[materialSymbol]["timestamp"] = computer.millis()

    -- Only mark the material as dirty if it has actually changed from the last time its status was provided.
    Materials[materialSymbol]["timeout"] = false
    Materials[materialSymbol]["isDirty"] = Materials[materialSymbol]["storeSize"] ~= message["storeSize"]
                                        or Materials[materialSymbol]["numStored"] ~= message["numStored"]
                                        or Materials[materialSymbol]["targetNum"] ~= message["targetNum"]
                                        or Materials[materialSymbol]["isIypassed"] ~= message["isBypassed"]

    Materials[materialSymbol]["symbol"] = message["material"]
    Materials[materialSymbol]["storeSize"] = message["storeSize"]
    Materials[materialSymbol]["numStored"] = message["numStored"]
    Materials[materialSymbol]["targetNum"] = message["targetNum"]
    Materials[materialSymbol]["isBypassed"] = message["isBypassed"]
    Materials[materialSymbol]["percentStored"] = math.floor((100 * message["numStored"] / message["storeSize"]) + 0.5)
    Materials[materialSymbol]["targetPercent"] = math.floor((100 * message["targetNum"] / message["storeSize"]) + 0.5)
end
