return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 16,
  height = 16,
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
      width = 16,
      height = 16,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0
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
          x = 112,
          y = 128,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "minerhat",
          shape = "rectangle",
          x = 128,
          y = 96,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pickaxe",
          shape = "rectangle",
          x = 144,
          y = 144,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 51,
          y = 123,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 164,
          y = 62,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 184,
          y = 105,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 79,
          y = 163,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "rocks",
          shape = "rectangle",
          x = 86,
          y = 103,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "goldnugget",
          shape = "rectangle",
          x = 108,
          y = 63,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "goldnugget",
          shape = "rectangle",
          x = 52,
          y = 82,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "goldnugget",
          shape = "rectangle",
          x = 132,
          y = 171,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "leif",
          shape = "rectangle",
          x = 224,
          y = 222,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "leif",
          shape = "rectangle",
          x = 224,
          y = 34,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "leif",
          shape = "rectangle",
          x = 36,
          y = 34,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "leif",
          shape = "rectangle",
          x = 37,
          y = 224,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
