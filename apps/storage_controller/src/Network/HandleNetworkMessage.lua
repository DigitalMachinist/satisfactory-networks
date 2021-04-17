function HandleNetworkMessage(eventData)
    local sender = eventData[3]
    local port = eventData[4]
    if (port == PORT_PING) then
        -- If a ping is received, store the sender's address so we can message the UI controller directly from now on.
        local ping = ParseUiPing(eventData)
        print("[RX] PING: "..ping["template"].." from "..sender)

        if (ping["template"] ~= "ui_controller") then
            return
        end

        NetworkUI = sender
        NIC:send(NetworkUI, PORT_PONG, StoragePong())
        print("[TX] PONG")
    elseif (port == PORT_PONG) then
        -- If a ping response is received, store the sender's address so we can message the UI controller directly from now on.
        local pong = ParseUiPong(eventData)
        print("[RX] PONG: "..pong["template"].." from "..sender)

        if (pong["template"] ~= "ui_controller") then
            return
        end

        NetworkUI = sender
    elseif (port == PORT_STORAGE) then
        -- Handle storage control signals
        local type = eventData[5]
        print("[RX] STORAGE: "..type.." from "..sender)

        -- If a storage control signal is received, it *must* come from the registered UI controller to be considered valid.
        if (sender ~= NetworkUI) then
            return
        end
        
        if (type == "SetIsBypassed") then
            -- Handle control signal to toggle the bypass on or off.
            local message = ParseUiSetIsBypassed(eventData)
            SetIsBypassed(message["value"])
            print("Bypass updated to "..tostring(IsBypassed))
        elseif (type == "SetTarget") then
            -- Handle control signal to set the target number of items stored.
            local message = ParseUiSetTarget(eventData)
            SetTargetPercent(message["value"])
            print("Target updated to "..TargetPercent.." ("..TargetNumStored..")")
        end
    end
end
