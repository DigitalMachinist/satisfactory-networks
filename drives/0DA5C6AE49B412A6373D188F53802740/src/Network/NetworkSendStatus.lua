function NetworkSendStatus()
    if (NIC == nil) then
        return
    end

    if (NetworkUI == nil) then
        return
    end

    NIC:send(NetworkUI, PORT_STORAGE, StorageStatus())
    print("[TX] STORAGE: StorageStatus "..NumStored.."/"..StoreSize)
end
