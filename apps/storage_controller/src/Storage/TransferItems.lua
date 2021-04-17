function TransferItems(maxItemsToTransfer)
    for i = 1, maxItemsToTransfer do
        -- If the splitter's input buffer is empty, return immediately.
        if (Splitter:getInput().type == nil) then
            return;
        end

        -- If storage is still filling up to the target and the bypass hasn't been enabled, we don't want to transfer.
        if ((NumStored < TargetNumStored) and not IsBypassed) then
            return
        end

        -- Otherwise transfer (if the storage is at target or bypass is enabled).
        Transfer()
    end
end
