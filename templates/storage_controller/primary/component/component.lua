-- Manual Switch Splitter
-- Controller to allow a toggle switch on a panel to control whether a splitter transfers items or not.

-- The splitter's nickname on the network.
SPLITTER_NAME = "Splitter"

-- The panel's nickname on the network.
PANEL_NAME = "Panel"

-- The toggle's position on the panel (from the bottom-left).
TOGGLE_POS = { x = 0, y = 0 }

-- Some constants to make code clearer.
OUTPUT_LEFT = 0
OUTPUT_CENTER = 1
OUTPUT_RIGHT = 2
NUM_OUTPUTS = 3

-- State
IsEnabled = false   -- Is the splitter transferring items?
OutputIndex = 0     -- The index of of the output the splitter last transferred an item to.
Splitter = nil
Panel = nil
Toggle = nil

-- Functions
function FindComponents()
    local cSplitter = component.findComponent("Splitter")[1]
    if cSplitter == nil then
        computer.panic("Splitter not found.")
    end

    local cPanel = component.findComponent("Panel")[1]
    if cPanel == nil then
        computer.panic("Panel not found.")
    end

    Splitter = component.proxy(cSplitter)
    Panel = component.proxy(cPanel)
    Toggle = Panel:getModule(
        TOGGLE_POS["x"],
        TOGGLE_POS["y"]
    )
end 

-- Transfer an item to any free output.
-- If the current output belt is blocked, try until one works or all fail.
-- This method should ensure maximum throughput since it will try all 3 outputs before the next Lua step.
function Transfer()
    for i = 1, NUM_OUTPUTS do
        OutputIndex = math.fmod(OutputIndex + 1, 3)
        local transferred = Splitter:transferItem(OutputIndex)
        if Splitter:transferItem(OutputIndex) then
            break
        end
    end
end

-- Main Controller
function Component()
    FindComponents()

    event.listen(Splitter)

    while true do
        IsEnabled = Toggle:getState()
        if IsEnabled then
            -- If the splitter has items already sitting in its input queue, transfer them first.
            -- This will ensure that we start getting input events for new items entering the splitter's input queue.
            if next(Splitter:getMembers()) then
                Transfer()
            end

            -- Transfer an item for each ItemRequest event receives from the splitter, until we disable it.
            local e = event.pull(1)
            if e == "ItemRequest" then
                Transfer()
            end
        else
            -- Prevent "out of time" error for infinite loop timeout.
            computer.skip()
        end
    end
end

-- RUN IT!
Component()