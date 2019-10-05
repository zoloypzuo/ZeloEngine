return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 8,
  height = 8,
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
      width = 8,
      height = 8,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        9, 0, 0, 0, 9, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        9, 0, 0, 0, 9, 0, 0, 0
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
          type = "resurrectionstone",
          shape = "rectangle",
          x = 64,
          y = 64,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pighead",
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
          type = "pighead",
          shape = "rectangle",
          x = 128,
          y = 64,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pighead",
          shape = "rectangle",
          x = 0,
          y = 64,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pighead",
          shape = "rectangle",
          x = 64,
          y = 0,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "resource_area",
          shape = "rectangle",
          x = -55,
          y = 10,
          width = 51,
          height = 112,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
