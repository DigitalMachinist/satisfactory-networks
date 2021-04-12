FEEDBACK_RATE_MS        = 500       -- How many ms between updates of the UI?
TIMEOUT_PERIOD_MS       = 10000     -- How many ms without any updates for a storage unit until we mark is as timed out?
MAX_EVENT_HANDLING_RATE = 1         -- Max number of events that can be handled per-lua-tick.
TARGET_DIAL_SENSITIVITY = 5         -- Percentage points to adjust TargetPercent by with each rotation of the TargetDial.
CONTROLS = {                        -- Map {material symbol} => {panel & anchor position} so we can find the related panel controls/displays.
    CONC = {
        panelName  = "Panel01",
        panelIndex = 2,
        anchorPos  = Vector2(1, 1),
    },
}