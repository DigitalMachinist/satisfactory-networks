function HandleNetworkMessage(eventData)
    local sender = eventData[3]
    local port = eventData[4]
    if (port == PORT_PING) then
        -- Handle pings from storage controllers by ingesting their status and registering them.
        -- We also reply directly to the sender so they can register this as their UI controller.
        local ping = ParseStoragePing(eventData)
        print("[RX] PING: "..ping["template"].." from "..sender)

        if (ping["template"] ~= "storage_controller") then
            return
        end

        IngestStorageStatus(ping)
        NIC:send(sender, PORT_PING, UiPong())
        print("[TX] PONG")
    elseif (port == PORT_PONG) then
        -- Handle pings from storage controllers by ingesting their status and registering them.
        local pong = ParseStoragePong(eventData)
        print("[RX] PONG: "..ping["template"].." from "..sender)

        if (pong["template"] ~= "storage_controller") then
            return
        end

        IngestStorageStatus(pong)
    elseif (port == PORT_STORAGE) then
        -- Handle storage status updates
        local message = ParseStorageStatus(eventData)
        print("[RX] MESSAGE: "..message["type"].." from "..sender)

        if (message["type"] == "StorageStatus") then
            -- Handle storage status updates by ingesting the data and updating the UI.
            IngestStorageStatus(message)
        end
    end
end
