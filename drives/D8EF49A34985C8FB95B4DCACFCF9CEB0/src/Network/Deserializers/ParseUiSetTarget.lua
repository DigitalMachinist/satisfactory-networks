function ParseUiSetTarget(eventData)
    return {
        sender = eventData[3],
        port   = eventData[4],
        type   = eventData[5],
        value  = eventData[6],
    }
end