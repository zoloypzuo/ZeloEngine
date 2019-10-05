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
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 13, 0, 0, 0, 13, 0, 0, 0, 13, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 13, 0, 0, 0, 13, 0, 0, 0, 13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 13, 0, 0, 0, 13, 0, 0, 0, 13, 0, 0, 0, 13, 0, 0, 0, 13, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 13, 0, 0, 0, 13, 0, 0, 0, 13, 0, 0, 0, 13, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 13, 0, 0, 0, 13, 0, 0, 0, 13, 0, 0, 0, 0, 0, 0, 0
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
          type = "treasurechest",
          shape = "rectangle",
          x = 89,
          y = 257,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["scenario"] = "chest_cavesupplies"
          }
        },
        {
          name = "",
          type = "skeleton",
          shape = "rectangle",
          x = 236,
          y = 144,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "flower_cave",
          shape = "rectangle",
          x = 94,
          y = 146,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "flower_cave_double",
          shape = "rectangle",
          x = 128,
          y = 193,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "flower_cave",
          shape = "rectangle",
          x = 93,
          y = 299,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "flower_cave",
          shape = "rectangle",
          x = 200,
          y = 292,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "flower_cave_triple",
          shape = "rectangle",
          x = 222,
          y = 182,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "bedroll_furry",
          shape = "rectangle",
          x = 178,
          y = 259,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "icebox",
          shape = "rectangle",
          x = 97,
          y = 218,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["scenario"] = "chest_cavefood"
          }
        },
        {
          name = "",
          type = "researchlab",
          shape = "rectangle",
          x = 100,
          y = 177,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pickaxe",
          shape = "rectangle",
          x = 183,
          y = 222,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "lantern",
          shape = "rectangle",
          x = 171,
          y = 184,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
