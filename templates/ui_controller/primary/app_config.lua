-- The control panel is where all controls and displays will appear.
PANEL_NAME        = "Panel"
FLOW_LED_POS      = { x = 5, y = 10 }
TARGET_DIAL_POS   = { x = 5, y =  9 }
BYPASS_BUTTON_POS = { x = 5, y = 10 }

-- The containers make up the actual storage medium backing the storage controller.
CONTAINER_NAME = "Container"

-- The splitter is used to control item flow and maintain the target number of items.
SPLITTER_NAME   = "Splitter"
SPLITTER_OUTPUT = SPLITTER_OUTPUT_CENTER

-- Output displays
TEXT_STATUS_SCREEN_POS     = { x = 1, y = 10 }
TEXT_STATUS_SCREEN_SIZE    = 36
GRAPHIC_STATUS_SCREEN_POS  = { x = 6, y = 10 }
GRAPHIC_STATUS_SCREEN_SIZE = { x = 119, y = 30 }
UI_CLEAR_COLOR             = { 0, 0, 0, 0 }
UI_METER_BG_COLOR          = { 0.02, 0.02, 0.02, 1 }
UI_METER_FG_COLOR          = { 0.05, 0.06, 0.15, 1 }
UI_METER_BORDER_COLOR      = { 1, 1, 1, 1 }
UI_METER_TARGET_COLOR      = { 1, 1, 1, 1 }

-- Colours
COLOR_OVERBYPASS = { 0.1, 1.0, 1.0, 1.0 } -- Bypassed but it would flow even if it wasn't
COLOR_BYPASSED   = { 0.1, 0.1, 1.0, 1.0 }
COLOR_FLOWING    = { 0.1, 1.0, 0.1, 1.0 }
COLOR_HOLDING    = { 1.0, 0.1, 0.1, 1.0 }

-- The important stuff
ITEM_TYPE                = "Concrete"    -- To visually display the type of item stored.
ITEM_STACK_SIZE          = 500           -- Stack size of the stored item (to project total storage capacity).
MAX_ITEM_TRANSFER_RATE   = 10            -- Max number of items that can be transferred per-lua-tick.
MAX_EVENT_HANDLING_RATE  = 10            -- Max number of events that can be handled per-lus-tick.
TARGET_DIAL_SENSITIVITY  = 5             -- Percentage points to adjust TargetPercent by with each rotation of the TargetDial.
FEEDBACK_RATE_MS         = 500           -- How many ms between polled updates of the UI?