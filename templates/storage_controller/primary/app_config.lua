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

-- Colours
COLOR_OVERBYPASS = { r = 0.1, g = 1.0, b = 1.0, a = 1.0 } -- Bypassed but it would flow even if it wasn't
COLOR_BYPASSED   = { r = 0.1, g = 0.1, b = 1.0, a = 1.0 }
COLOR_FLOWING    = { r = 0.1, g = 1.0, b = 0.1, a = 1.0 }
COLOR_HOLDING    = { r = 1.0, g = 0.1, b = 0.1, a = 1.0 }

-- The important stuff
ITEM_TYPE               = "Concrete"    -- To visually display the type of item stored.
ITEM_STACK_SIZE         = 500           -- Stack size of the stored item (to project total storage capacity).
MAX_ITEM_TRANSFER_RATE  = 10            -- Max number of items that can be transferred per-lua-tick.
MAX_EVENT_HANDLING_RATE = 10            -- Max number of events that can be handled per-lus-tick.
TARGET_DIAL_SENSITIVITY = 5             -- Percentage points to adjust TargetPercent by with each rotation of the TargetDial.
