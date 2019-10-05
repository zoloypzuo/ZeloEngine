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
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0
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
          type = "item_area",
          shape = "rectangle",
          x = 3,
          y = 0,
          width = 44,
          height = 124,
          visible = true,
          properties = {
            ["scenario"] = "random_damage"
          }
        },
        {
          name = "",
          type = "resource_area",
          shape = "rectangle",
          x = 81,
          y = 2,
          width = 44,
          height = 123,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "skeleton",
          shape = "rectangle",
          x = 48,
          y = 17,
          width = 32,
          height = 87,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
