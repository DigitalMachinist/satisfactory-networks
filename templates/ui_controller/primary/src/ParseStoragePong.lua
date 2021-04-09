function ParseStoragePong(eventData)
    return {
        sender     = eventData[3],
        port       = eventData[4],
        template   = eventData[5],
        material   = eventData[6],
        storeSize  = eventData[7],
        numStored  = eventData[8],
        targetNum  = eventData[9],
        isBypassed = eventData[10],
    }
end