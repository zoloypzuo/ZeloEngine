return {
    version = "1.1",
    luaversion = "5.1",
    orientation = "orthogonal",
    width = 40,
    height = 40,
    tilewidth = 16,
    tileheight = 16,
    properties = {},
    tilesets = {
        {
            name = "ground",
            firstgid = 1,
            filename = "../../../../tools/tiled/dont_starve/ground.tsx",
            tilewidth = 64,
            tileheight = 64,
            spacing = 0,
            margin = 0,
            image = "../../../../tools/tiled/dont_starve/tiles.png",
            imagewidth = 512,
            imageheight = 256,
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
            width = 40,
            height = 40,
            visible = true,
            opacity = 1,
            properties = {},
            encoding = "lua",
            data = {
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 10, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 11, 0, 0, 0, 10, 0, 0, 0, 10, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 10, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                11, 0, 0, 0, 11, 0, 0, 0, 10, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                11, 0, 0, 0, 11, 0, 0, 0, 10, 0, 0, 0, 10, 0, 0, 0, 10, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 11, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
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
                    type = "teleportato_base",
                    shape = "rectangle",
                    x = 336,
                    y = 338,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "bishop",
                    shape = "rectangle",
                    x = 490,
                    y = 158,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "bishop",
                    shape = "rectangle",
                    x = 157,
                    y = 481,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "knight",
                    shape = "rectangle",
                    x = 540,
                    y = 364,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "knight",
                    shape = "rectangle",
                    x = 167,
                    y = 162,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 325,
                    y = 139,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 251,
                    y = 92,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 243,
                    y = 236,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 547,
                    y = 315,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 470,
                    y = 27,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 65,
                    y = 471,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 407,
                    y = 142,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 288,
                    y = 32,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "marblepillar",
                    shape = "rectangle",
                    x = 61,
                    y = 293,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "marbletree",
                    shape = "rectangle",
                    x = 408,
                    y = 416,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "marbletree",
                    shape = "rectangle",
                    x = 469,
                    y = 305,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "marbletree",
                    shape = "rectangle",
                    x = 226,
                    y = 415,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "marbletree",
                    shape = "rectangle",
                    x = 160,
                    y = 413,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "marbletree",
                    shape = "rectangle",
                    x = 293,
                    y = 556,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "marbletree",
                    shape = "rectangle",
                    x = 222,
                    y = 556,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 347,
                    y = 400,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 412,
                    y = 291,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 287,
                    y = 311,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 352,
                    y = 256,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 400,
                    y = 352,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "statueharp",
                    shape = "rectangle",
                    x = 364,
                    y = 100,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "marbletree",
                    shape = "rectangle",
                    x = 414,
                    y = 223,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "marbletree",
                    shape = "rectangle",
                    x = 291,
                    y = 219,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 132,
                    y = 358,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "marblepillar",
                    shape = "rectangle",
                    x = 500,
                    y = 476,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 171,
                    y = 559,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 158,
                    y = 610,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 502,
                    y = 417,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 396,
                    y = 517,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 496,
                    y = 546,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "marbletree",
                    shape = "rectangle",
                    x = 230,
                    y = 299,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 53,
                    y = 359,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 551,
                    y = 95,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower_evil",
                    shape = "rectangle",
                    x = 97,
                    y = 212,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "marblepillar",
                    shape = "rectangle",
                    x = 562,
                    y = 417,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "marbletree",
                    shape = "rectangle",
                    x = 105,
                    y = 36,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "marbletree",
                    shape = "rectangle",
                    x = 608,
                    y = 160,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "statueharp",
                    shape = "rectangle",
                    x = 116,
                    y = 596,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "diviningrodbase",
                    shape = "rectangle",
                    x = 286,
                    y = 390,
                    width = 0,
                    height = 0,
                    visible = true,
                    properties = {}
                },
            }
        }
    }
}
