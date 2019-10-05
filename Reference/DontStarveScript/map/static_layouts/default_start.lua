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
      width = 16,
      height = 16,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        26, 26, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 0, 0, 0, 0,
        22, 22, 26, 22, 22, 22, 22, 22, 22, 22, 22, 22, 0, 0, 0, 22,
        22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 0, 0, 22,
        0, 22, 22, 22, 6, 22, 22, 22, 6, 22, 22, 22, 6, 0, 0, 22,
        22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 0, 0, 22, 22,
        22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
        22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
        0, 22, 22, 22, 0, 22, 22, 22, 6, 22, 22, 22, 6, 22, 22, 22,
        22, 22, 22, 0, 0, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
        22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
        22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
        6, 22, 22, 22, 6, 22, 22, 22, 6, 22, 22, 22, 0, 22, 22, 22,
        22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
        22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
        22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
        0, 22, 22, 22, 0, 22, 22, 22, 6, 22, 22, 22, 6, 22, 22, 0
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
          type = "spawnpoint",
          shape = "rectangle",
          x = 160,
          y = 160,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "flower",
          shape = "rectangle",
          x = 192,
          y = 80,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "flower",
          shape = "rectangle",
          x = 128,
          y = 48,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "flower",
          shape = "rectangle",
          x = 32,
          y = 144,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
