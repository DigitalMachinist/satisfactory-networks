-- Transfer an item to any free output.
-- If the current output belt is blocked, try until one works or all fail.
-- This method should ensure maximum throughput since it will try all 3 outputs before the next Lua step.
function Transfer()
    for i = 1, SPLITTER_NUM_OUTPUTS do
        SplitterOutIndex = math.fmod(SplitterOutIndex + 1, SPLITTER_NUM_OUTPUTS)
        if Splitter:transferItem(SplitterOutIndex) then
            break
        end
    end
end
