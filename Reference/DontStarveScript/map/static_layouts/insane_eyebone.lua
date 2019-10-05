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
      name = "asdf",
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
        8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0, 8, 0, 0, 0
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
          name = "chester_eyebone",
          type = "chester_eyebone",
          shape = "rectangle",
          x = 112,
          y = 112,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sanityrock",
          shape = "rectangle",
          x = 128,
          y = 240,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sanityrock",
          shape = "rectangle",
          x = 64,
          y = 240,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sanityrock",
          shape = "rectangle",
          x = 160,
          y = 240,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "basalt",
          shape = "rectangle",
          x = 192,
          y = 240,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "basalt",
          shape = "rectangle",
          x = 192,
          y = 176,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "basalt",
          shape = "rectangle",
          x = 192,
          y = 112,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "basalt",
          shape = "rectangle",
          x = 192,
          y = 48,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "basalt",
          shape = "rectangle",
          x = 0,
          y = 240,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "basalt",
          shape = "rectangle",
          x = 0,
          y = 176,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "basalt",
          shape = "rectangle",
          x = 0,
          y = 48,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "basalt",
          shape = "rectangle",
          x = 0,
          y = 112,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "basalt",
          shape = "rectangle",
          x = 64,
          y = 48,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "basalt",
          shape = "rectangle",
          x = 128,
          y = 48,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "sanityrock",
          shape = "rectangle",
          x = 96,
          y = 240,
          width = 16,
          height = 16,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
