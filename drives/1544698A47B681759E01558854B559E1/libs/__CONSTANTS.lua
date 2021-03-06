
-- Splitter contants
SPLITTER_OUTPUT_LEFT   = 0
SPLITTER_OUTPUT_CENTER = 1
SPLITTER_OUTPUT_RIGHT  = 2
SPLITTER_NUM_OUTPUTS   = 3

-- UI Modules
UI_MODULE_SCREEN_SIZE = { x = 119, y = 30 }

-- Utility ports
PORT_LOGS    = 1
PORT_STORAGE = 2
PORT_PING    = 3
PORT_PONG    = 4
PORT_ALERTS  = 5

-- Materials
MATERIALS = {
    -- Raw organics
    LEAF = {
        symbol      = "LEAF",
        name        = "Leaves",
        stackSize   = 500,
        defaultPort = 10,
        state       = "solid",
    },
    FLWR = {
        symbol      = "FLWR",
        name        = "Flower Petals",
        stackSize   = 200,
        defaultPort = 20,
        state       = "solid",
    },
    WOOD = {
        symbol      = "WOOD",
        name        = "Wood",
        stackSize   = 100,
        defaultPort = 30,
        state       = "solid",
    },
    MYCL = {
        symbol      = "MYCL",
        name        = "Mycelia",
        stackSize   = 200,
        defaultPort = 40,
        state       = "solid",
    },
    CARP = {
        symbol      = "CARP",
        name        = "Alien Carapace",
        stackSize   = 50,
        defaultPort = 50,
        state       = "solid",
    },
    OGRN = {
        symbol      = "ORGN",
        name        = "Alien Organs",
        stackSize   = 50,
        defaultPort = 60,
        state       = "solid",
    },
    -- Raw extracted materials
    BAUX = {
        symbol      = "BAUX",
        name        = "Bauxite",
        stackSize   = 100,
        defaultPort = 200,
        state       = "solid",
    },
    CA = {
        symbol      = "CA",
        name        = "Caterium Ore",
        stackSize   = 100,
        defaultPort = 210,
        state       = "solid",
    },
    COAL = {
        symbol      = "COAL",
        name        = "Coal",
        stackSize   = 100,
        defaultPort = 220,
        state       = "solid",
    },
    CU = {
        symbol      = "CU",
        name        = "Copper Ore",
        stackSize   = 100,
        defaultPort = 230,
        state       = "solid",
    },
    FE = {
        symbol      = "FE",
        name        = "Iron Ore",
        stackSize   = 100,
        defaultPort = 240,
        state       = "solid",
    },
    LIME = {
        symbol      = "LIME",
        name        = "Limestone",
        stackSize   = 100,
        defaultPort = 250,
        state       = "solid",
    },
    OIL = {
        symbol      = "OIL",
        name        = "Crude Oil",
        stackSize   = 1,
        defaultPort = 260,
        state       = "liquid",
    },
    Q = {
        symbol      = "Q",
        name        = "Raw Quartz",
        stackSize   = 100,
        defaultPort = 270,
        state       = "solid",
    },
    S = {
        symbol      = "S",
        name        = "Sulphur",
        stackSize   = 100,
        defaultPort = 280,
        state       = "solid",
    },
    SAMO = {
        symbol      = "SAMO",
        name        = "SAM Ore",
        stackSize   = 100,
        defaultPort = 290,
        state       = "solid",
    },
    U = {
        symbol      = "U",
        name        = "Uranium",
        stackSize   = 100,
        defaultPort = 300,
        state       = "solid",
    },
    H2O = {
        symbol      = "H2O",
        name        = "Water",
        stackSize   = 1,
        defaultPort = 310,
        state       = "liquid",
    },
    -- Tier 0 refined products
    BIOM = {
        symbol      = "BIOM",
        name        = "Biomass",
        stackSize   = 200,
        defaultPort = 400,
        state       = "solid",
    },
    CABL = {
        symbol      = "CABL",
        name        = "Cable",
        stackSize   = 100,
        defaultPort = 410,
        state       = "solid",
    },
    CONC = {
        symbol      = "CONC",
        name        = "Concrete",
        stackSize   = 500,
        defaultPort = 420,
        state       = "solid",
    },
    CUIN = {
        symbol      = "CUIN",
        name        = "Copper Ingot",
        stackSize   = 100,
        defaultPort = 430,
        state       = "solid",
    },
    FEIN = {
        symbol      = "FEIN",
        name        = "Iron Ingot",
        stackSize   = 100,
        defaultPort = 440,
        state       = "solid",
    },
    FEP = {
        symbol      = "FEP",
        name        = "Iron Plate",
        stackSize   = 100,
        defaultPort = 450,
        state       = "solid",
    },
    FER = {
        symbol      = "FER",
        name        = "Iron Rod",
        stackSize   = 100,
        defaultPort = 460,
        state       = "solid",
    },
    RIP = {
        symbol      = "RIP",
        name        = "Reinforced Iron Plate",
        stackSize   = 100,
        defaultPort = 470,
        state       = "solid",
    },
    SCRU = {
        symbol      = "SCRU",
        name        = "Screw",
        stackSize   = 500,
        defaultPort = 480,
        state       = "solid",
    },
    WIRE = {
        symbol      = "WIRE",
        name        = "Wire",
        stackSize   = 500,
        defaultPort = 490,
        state       = "solid",
    },
    -- Tier 2 refined products
    CUSH = {
        symbol      = "CUSH",
        name        = "Copper Sheet",
        stackSize   = 100,
        defaultPort = 600,
        state       = "solid",
    },
    BIOF = {
        symbol      = "BIOF",
        name        = "Solid Biofuel",
        stackSize   = 200,
        defaultPort = 610,
        state       = "solid",
    },
    MF = {
        symbol      = "MF",
        name        = "Modular Frame",
        stackSize   = 50,
        defaultPort = 620,
        state       = "solid",
    },
    ROTR = {
        symbol      = "ROTR",
        name        = "Rotor",
        stackSize   = 100,
        defaultPort = 630,
        state       = "solid",
    },
    SP = {
        symbol      = "SP",
        name        = "Smart Plating",
        stackSize   = 50,
        defaultPort = 640,
        state       = "solid",
    },
    -- Tier 3 refined products
    STB = {
        symbol      = "STB",
        name        = "Steel Beam",
        stackSize   = 100,
        defaultPort = 800,
        state       = "solid",
    },
    STIN = {
        symbol      = "STIN",
        name        = "Steel Ingot",
        stackSize   = 100,
        defaultPort = 810,
        state       = "solid",
    },
    STP = {
        symbol      = "STP",
        name        = "Steel Pipe",
        stackSize   = 100,
        defaultPort = 820,
        state       = "solid",
    },
    VF = {
        symbol      = "VF",
        name        = "Versatile Framework",
        stackSize   = 50,
        defaultPort = 830,
        state       = "solid",
    },
    -- Tier 4 refined products
    AW = {
        symbol      = "AW",
        name        = "Automated Wiring",
        stackSize   = 50,
        defaultPort = 1000,
        state       = "solid",
    },
    EIB = {
        symbol      = "EIB",
        name        = "Encased Industrial Beam",
        stackSize   = 100,
        defaultPort = 1010,
        state       = "solid",
    },
    HMF = {
        symbol      = "HMF",
        name        = "Heavy Modular Frame",
        stackSize   = 50,
        defaultPort = 1020,
        state       = "solid",
    },
    MOTR = {
        symbol      = "MOTR",
        name        = "Motor",
        stackSize   = 50,
        defaultPort = 1030,
        state       = "solid",
    },
    STAT = {
        symbol      = "STAT",
        name        = "Stator",
        stackSize   = 100,
        defaultPort = 1040,
        state       = "solid",
    },
    -- Tier 5 refined products
    ACU = {
        symbol      = "ACU",
        name        = "Adaptive Control Unit",
        stackSize   = 50,
        defaultPort = 1200,
        state       = "solid",
    },
    CB = {
        symbol      = "CB",
        name        = "Circuit Board",
        stackSize   = 200,
        defaultPort = 1210,
        state       = "solid",
    },
    CPU = {
        symbol      = "CPU",
        name        = "Computer",
        stackSize   = 50,
        defaultPort = 1220,
        state       = "solid",
    },
    ECAN = {
        symbol      = "ECAN",
        name        = "Empty Canister",
        stackSize   = 100,
        defaultPort = 1230,
        state       = "solid",
    },
    FUEL = {
        symbol      = "FUEL",
        name        = "Fuel",
        stackSize   = 1,
        defaultPort = 1240,
        state       = "liquid",
    },
    FCAN = {
        symbol      = "FCAN",
        name        = "Packaged Fuel",
        stackSize   = 100,
        defaultPort = 1250,
        state       = "solid",
    },
    HOR = {
        symbol      = "HOR",
        name        = "Heavy Oil Residue",
        stackSize   = 1,
        defaultPort = 1260,
        state       = "liquid",
    },
    RCAN = {
        symbol      = "RCAN",
        name        = "Packaged Heavy Oil Residue",
        stackSize   = 100,
        defaultPort = 1270,
        state       = "solid",
    },
    BIOL = {
        symbol      = "BIOL",
        name        = "Liquid Biofuel",
        stackSize   = 1,
        defaultPort = 1280,
        state       = "liquid",
    },
    BCAN = {
        symbol      = "BCAN",
        name        = "Packaged Liquid Biofuel",
        stackSize   = 100,
        defaultPort = 1290,
        state       = "solid",
    },
    ME = {
        symbol      = "ME",
        name        = "Modular Engine",
        stackSize   = 50,
        defaultPort = 1300,
        state       = "solid",
    },
    COKE = {
        symbol      = "COKE",
        name        = "Petroleum Coke",
        stackSize   = 200,
        defaultPort = 1310,
        state       = "solid",
    },
    PLAS = {
        symbol      = "PLAS",
        name        = "Plastic",
        stackSize   = 100,
        defaultPort = 1320,
        state       = "solid",
    },
    POLY = {
        symbol      = "POLY",
        name        = "Polymer Resin",
        stackSize   = 200,
        defaultPort = 1330,
        state       = "solid",
    },
    RUBR = {
        symbol      = "RUBR",
        name        = "Rubber",
        stackSize   = 100,
        defaultPort = 1340,
        state       = "solid",
    },
    -- Tier 7 refined products
    ALSO = {
        symbol      = "ALSO",
        name        = "Alumina Solution",
        stackSize   = 1,
        defaultPort = 1400,
        state       = "liquid",
    },
    ALSH = {
        symbol      = "ALSH",
        name        = "Alclad Aluminum Sheet",
        stackSize   = 100,
        defaultPort = 1410,
        state       = "solid",
    },
    ALIN = {
        symbol      = "ALIN",
        name        = "Aluminum Ingot",
        stackSize   = 100,
        defaultPort = 1420,
        state       = "solid",
    },
    ALS = {
        symbol      = "ALS",
        name        = "Aluminum Scrap",
        stackSize   = 500,
        defaultPort = 1430,
        state       = "solid",
    },
    BTRY = {
        symbol      = "BTRY",
        name        = "Battery",
        stackSize   = 100,
        defaultPort = 1440,
        state       = "solid",
    },
    EMCR = {
        symbol      = "EMCR",
        name        = "Electromagnetic Control Rod",
        stackSize   = 100,
        defaultPort = 1450,
        state       = "solid",
    },
    EUC = {
        symbol      = "EUC",
        name        = "Encased Uranium Cell",
        stackSize   = 200,
        defaultPort = 1460,
        state       = "solid",
    },
    SINK = {
        symbol      = "SINK",
        name        = "Heatsink",
        stackSize   = 100,
        defaultPort = 1470,
        state       = "solid",
    },
    NFR = {
        symbol      = "NFR",
        name        = "Nuclear Fuel Rod",
        stackSize   = 50,
        defaultPort = 1480,
        state       = "solid",
    },
    NUKE = {
        symbol      = "NUKE",
        name        = "Nuclear Waste",
        stackSize   = 500,
        defaultPort = 1490,
        state       = "solid",
    },
    SA = {
        symbol      = "SA",
        name        = "Sulfuric Acid",
        stackSize   = 1,
        defaultPort = 1500,
        state       = "liquid",
    },
    TM = {
        symbol      = "TM",
        name        = "Turbo Motor",
        stackSize   = 50,
        defaultPort = 1510,
        state       = "solid",
    },
    UP = {
        symbol      = "UP",
        name        = "Uranium Pellet",
        stackSize   = 200,
        defaultPort = 1520,
        state       = "solid",
    },
    -- MAM refined products
    AIL = {
        symbol      = "AIL",
        name        = "AI Limiter",
        stackSize   = 100,
        defaultPort = 1600,
        state       = "solid",
    },
    BLAK = {
        symbol      = "BLAK",
        name        = "Black Powder",
        stackSize   = 100,
        defaultPort = 1610,
        state       = "solid",
    },
    CAIN = {
        symbol      = "CAIN",
        name        = "Caterium Ingot",
        stackSize   = 100,
        defaultPort = 1620,
        state       = "solid",
    },
    CCOL = {
        symbol      = "CCOL",
        name        = "Compacted Coal",
        stackSize   = 100,
        defaultPort = 1630,
        state       = "solid",
    },
    FABR = {
        symbol      = "FABR",
        name        = "Fabric",
        stackSize   = 100,
        defaultPort = 1640,
        state       = "solid",
    },
    CONN = {
        symbol      = "CONN",
        name        = "High-Speed Connector",
        stackSize   = 100,
        defaultPort = 1650,
        state       = "solid",
    },
    QW = {
        symbol      = "QW",
        name        = "Quickwire",
        stackSize   = 500,
        defaultPort = 1660,
        state       = "solid",
    },
    POWR = {
        symbol      = "POWR",
        name        = "Power Shard",
        stackSize   = 100,
        defaultPort = 1670,
        state       = "solid",
    },
    QC = {
        symbol      = "QC",
        name        = "Quartz Crystal",
        stackSize   = 100,
        defaultPort = 1680,
        state       = "solid",
    },
    SILI = {
        symbol      = "SILI",
        name        = "Silica",
        stackSize   = 100,
        defaultPort = 1690,
        state       = "solid",
    },
    COSC = {
        symbol      = "COSC",
        name        = "Crystal Oscillator",
        stackSize   = 100,
        defaultPort = 1700,
        state       = "solid",
    },
    RCU = {
        symbol      = "RCU",
        name        = "Radio Control Unit",
        stackSize   = 50,
        defaultPort = 1710,
        state       = "solid",
    },
    SCPU = {
        symbol      = "SCPU",
        name        = "Supercomputer",
        stackSize   = 50,
        defaultPort = 1720,
        state       = "solid",
    },
    TFUL = {
        symbol      = "TFUL",
        name        = "Turbofuel",
        stackSize   = 1,
        defaultPort = 1730,
        state       = "liquid",
    },
    TCAN = {
        symbol      = "TCAN",
        name        = "Packaged Turbofuel",
        stackSize   = 100,
        defaultPort = 1740,
        state       = "solid",
    },
    -- MAM Equipment
    -- TODO?
}