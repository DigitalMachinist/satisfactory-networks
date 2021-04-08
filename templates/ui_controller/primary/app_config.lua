-- The important stuff
FEEDBACK_RATE_MS        = 500       -- How many ms between updates of the UI?
TIMEOUT_PERIOD_MS       = 10000     -- How many ms without any updates for a storage unit until we mark is as timed out?
MAX_EVENT_HANDLING_RATE = 3         -- Max number of events that can be handled per-lua-tick.
TARGET_DIAL_SENSITIVITY = 5         -- Percentage points to adjust TargetPercent by with each rotation of the TargetDial.
CONTROLS = {                        -- Map {material symbol} => {panel & anchor position} so we can find the related panel controls/displays.
    CONC = {
        panelName  = "Panel01",
        panelIndex = 0,
        anchorPos  = Vector2(1, 10),
    },
}

-- Offsets (from an anchor position on a panel)
CONTROL_OFFSET_TEXT_DISPLAY    = Vector2(0, 0)
CONTROL_OFFSET_GRAPHIC_DISPLAY = Vector2(5, 0)
CONTROL_OFFSET_BYPASS_BUTTON   = Vector2(4, 0)
CONTROL_OFFSET_TARGET_DIAL     = Vector2(4, -1)

-- UI Display settings
UI_CLEAR_COLOR          = { 0, 0, 0, 0 }
UI_METER_TIMEOUT_COLOR  = { 0.05, 0.05, 0.05, 1 }
UI_METER_BG_COLOR       = { 0.02, 0.02, 0.02, 1 }
UI_METER_FG_COLOR       = { 0.05, 0.06, 0.15, 1 }
UI_METER_BORDER_COLOR   = { 1, 1, 1, 1 }
UI_METER_TARGET_COLOR   = { 1, 1, 1, 1 }

-- Colours
COLOR_OVERBYPASS = { 0.1, 1.0, 1.0, 1 } -- Bypassed but it would flow even if it wasn't
COLOR_BYPASSED   = { 0.1, 0.1, 1.0, 1 }
COLOR_FLOWING    = { 0.1, 1.0, 0.1, 1 }
COLOR_HOLDING    = { 1.0, 0.1, 0.1, 1 }
COLOR_TIMEOUT    = { 0.0, 0.0, 0.0, 1 }
