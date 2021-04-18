function FlushEventQueue(maxEventsPerTick)
    while true do
        for i = 1, maxEventsPerTick do
            if (event.pull(0) == nil) then
                return
            end
        end
    end
end