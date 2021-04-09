------------------------------------------------------------------------------------------------------------------------------------------------------
-- Overwrite these in env_config.lua -----------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
MATERIAL_SYMBOL         = "CONC"    -- To look up the material being stored (stack size, name, etc)
FEEDBACK_RATE_MS        = 500       -- How many ms between updates of the UI?
MAX_EVENT_HANDLING_RATE = 10        -- Max number of events that can be handled per-lua-tick.
MAX_ITEM_TRANSFER_RATE  = 10        -- Max number of items that can be transferred per-lua-tick.
TARGET_DIAL_SENSITIVITY = 5         -- Percentage points to adjust TargetPercent by with each rotation of the TargetDial.
SPLITTER_OUTPUT         = SPLITTER_OUTPUT_CENTER
------------------------------------------------------------------------------------------------------------------------------------------------------

-- Components
CONTAINER_NAME          = "Container"
SPLITTER_NAME           = "Splitter"
PANEL_NAME              = "Panel"
BYPASS_BUTTON_POS       = Vector2(5, 10)
TARGET_DIAL_POS         = Vector2(5, 9)

-- Output displays
UI_CLEAR_COLOR             = { 0, 0, 0, 0 }
UI_METER_BG_COLOR          = { 0.02, 0.02, 0.02, 1 }
UI_METER_FG_COLOR          = { 0.05, 0.06, 0.15, 1 }
UI_METER_BORDER_COLOR      = { 1, 1, 1, 1 }
UI_METER_TARGET_COLOR      = { 1, 1, 1, 1 }
GRAPHIC_STATUS_SCREEN_POS  = Vector2(6, 10)
TEXT_STATUS_SCREEN_POS     = Vector2(1, 10)

-- Colours
COLOR_OVERBYPASS = { 0.1, 1.0, 1.0, 1.0 } -- Bypassed but it would flow even if it wasn't
COLOR_BYPASSED   = { 0.1, 0.1, 1.0, 1.0 }
COLOR_FLOWING    = { 0.1, 1.0, 0.1, 1.0 }
COLOR_HOLDING    = { 1.0, 0.1, 0.1, 1.0 }
