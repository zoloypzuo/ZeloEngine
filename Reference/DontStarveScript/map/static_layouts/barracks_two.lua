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
      name = "tiles",
      firstgid = 1,
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "../../../../tools/tiled/dont_starve/tiles.png",
      imagewidth = 512,
      imageheight = 384,
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
        27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        27, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        27, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        27, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        27, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        27, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        27, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        27, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        27, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 27, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0, 27, 0, 0, 0
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
          type = "wall_ruins",
          shape = "rectangle",
          x = 576,
          y = 416,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 576,
          y = 512,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".45"
          }
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 576,
          y = 528,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".45"
          }
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 352,
          y = 576,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".3"
          }
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 368,
          y = 576,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".3"
          }
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 368,
          y = 64,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".3"
          }
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 64,
          y = 128,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 64,
          y = 144,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 64,
          y = 160,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 384,
          y = 64,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 400,
          y = 64,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 416,
          y = 64,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 432,
          y = 64,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 576,
          y = 176,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 576,
          y = 288,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".45"
          }
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 576,
          y = 304,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".45"
          }
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 240,
          y = 64,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 224,
          y = 64,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".3"
          }
        },
        {
          name = "",
          type = "wall_ruins",
          shape = "rectangle",
          x = 64,
          y = 496,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".3"
          }
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 256,
          y = 64,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 208,
          y = 576,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 240,
          y = 576,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 528,
          y = 576,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 224,
          y = 576,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "chessjunk1",
          shape = "rectangle",
          x = 432,
          y = 448,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "chessjunk3",
          shape = "rectangle",
          x = 176,
          y = 432,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "rook_nightmare",
          shape = "rectangle",
          x = 304,
          y = 320,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "bishop_nightmare",
          shape = "rectangle",
          x = 432,
          y = 176,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "bishop_nightmare",
          shape = "rectangle",
          x = 240,
          y = 192,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "knight_nightmare",
          shape = "rectangle",
          x = 144,
          y = 336,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
