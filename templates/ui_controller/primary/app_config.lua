-- The control panel is where all controls and displays will appear.
PANEL_NAME        = "Panel"
FLOW_LED_POS      = { x = 5, y = 10 }
TARGET_DIAL_POS   = { x = 5, y =  9 }
BYPASS_BUTTON_POS = { x = 5, y = 10 }

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

-- Port mapping
-- We're making a map of {port} => {material symbol} here so we can quickly look up material info related to network messages
-- by using the port to look up the material symbol, then looking up the symbol in the MATERIALS map to get more info. 
PORTS = {}
for symbol, material in pairs(MATERIALS) do
    PORTS[material['defaultPort']] = symbol
end