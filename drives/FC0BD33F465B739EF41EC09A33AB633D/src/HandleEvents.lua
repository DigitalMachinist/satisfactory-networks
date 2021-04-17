function HandleEvents(maxEventsToPop)
    for i = 1, maxEventsToPop do
        local eventData = {event.pull(0)}
        local eventType = eventData[1]
        if eventType == nil then
            -- If no eventType was set, the last event has been popped and we should return to the caller.
            return
        end

        --print("Event: "..eventType)
        if eventType == "NetworkMessage" then
            HandleNetworkMessage(eventData)
            return
        end

        local materialSymbol = ModuleMap[eventData[2].hash]
        if eventType == "Trigger" then
            -- Toggle IsBypassed
            if (materialSymbol ~= nil) then
                HandleBypassButtonPush(materialSymbol)
            end
        elseif eventType == "PotRotate" then
            -- Update the target number of items to store based on the target dial being rotated.
            if (materialSymbol ~= nil) then
                local anticlockwise = eventData[3]
                HandleTargetDialChange(materialSymbol, anticlockwise)
            end
        end
    end
end
