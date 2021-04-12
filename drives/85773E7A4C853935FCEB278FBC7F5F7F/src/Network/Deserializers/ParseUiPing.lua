function ParseUiPing(eventData)
    return {
        sender   = eventData[3],
        port     = eventData[4],
        template = eventData[5],
    }
end