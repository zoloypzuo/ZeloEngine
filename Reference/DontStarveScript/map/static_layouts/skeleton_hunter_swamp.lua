return {
    version = "1.1",
    luaversion = "5.1",
    orientation = "orthogonal",
    width = 24,
    height = 24,
    tilewidth = 16,
    tileheight = 16,
    properties = {},
    tilesets = {
        {
            name = "tiles",
            firstgid = 1,
            tilewidth = 64,
            tileheight = 64,
            spacing = 0,
            margin = 0,
            image = "../../../../tools/tiled/dont_starve/tiles.png",
            imagewidth = 512,
            imageheight = 128,
            properties = {},
            tiles = {}
        }
    },
    layers = {
        {
            type = "tilelayer",
            name = "BG_TILES",
            x = 0,
            y = 0,
            width = 24,
            height = 24,
            visible = true,
            opacity = 1,
            properties = {},
            encoding = "lua",
            data = {
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0
            }
        },
        {
            type = "objectgroup",
            name = "FG_OBJECTS",
            visible = true,
            opacity = 1,
            properties = {},
            objects = {
                {
                    name = "",
                    type = "skeleton",
                    shape = "rectangle",
                    x = 193,
                    y = 206,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "beefalohat",
                    shape = "rectangle",
                    x = 235,
                    y = 236,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "beefalowool",
                    shape = "rectangle",
                    x = 179,
                    y = 248,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "beefalowool",
                    shape = "rectangle",
                    x = 144,
                    y = 150,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "beefalowool",
                    shape = "rectangle",
                    x = 227,
                    y = 185,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "houndbone",
                    shape = "rectangle",
                    x = 229,
                    y = 150,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "houndbone",
                    shape = "rectangle",
                    x = 202,
                    y = 142,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "houndbone",
                    shape = "rectangle",
                    x = 133,
                    y = 228,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "houndstooth",
                    shape = "rectangle",
                    x = 103,
                    y = 194,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "houndstooth",
                    shape = "rectangle",
                    x = 113,
                    y = 153,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "houndstooth",
                    shape = "rectangle",
                    x = 278,
                    y = 210,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "houndstooth",
                    shape = "rectangle",
                    x = 271,
                    y = 167,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "spear",
                    shape = "rectangle",
                    x = 181,
                    y = 172,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "tentacle",
                    shape = "rectangle",
                    x = 48,
                    y = 288,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "tentacle",
                    shape = "rectangle",
                    x = 80,
                    y = 320,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "tentacle",
                    shape = "rectangle",
                    x = 128,
                    y = 336,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "tentacle",
                    shape = "rectangle",
                    x = 181,
                    y = 354,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "tentacle",
                    shape = "rectangle",
                    x = 233,
                    y = 355,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "tentacle",
                    shape = "rectangle",
                    x = 272,
                    y = 336,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "tentacle",
                    shape = "rectangle",
                    x = 304,
                    y = 304,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "tentacle",
                    shape = "rectangle",
                    x = 336,
                    y = 272,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "tentacle",
                    shape = "rectangle",
                    x = 352,
                    y = 224,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "tentacle",
                    shape = "rectangle",
                    x = 352,
                    y = 176,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "tentacle",
                    shape = "rectangle",
                    x = 336,
                    y = 128,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "tentacle",
                    shape = "rectangle",
                    x = 304,
                    y = 80,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "tentacle",
                    shape = "rectangle",
                    x = 256,
                    y = 48,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "tentacle",
                    shape = "rectangle",
                    x = 190,
                    y = 37,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "tentacle",
                    shape = "rectangle",
                    x = 120,
                    y = 47,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "tentacle",
                    shape = "rectangle",
                    x = 72,
                    y = 81,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "tentacle",
                    shape = "rectangle",
                    x = 32,
                    y = 128,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "tentacle",
                    shape = "rectangle",
                    x = 16,
                    y = 176,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "tentacle",
                    shape = "rectangle",
                    x = 28,
                    y = 238,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                }
            }
        }
    }
}
