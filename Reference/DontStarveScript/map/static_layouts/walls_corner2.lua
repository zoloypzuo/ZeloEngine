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
        29, 0, 0, 0, 29, 0, 0, 0, 29, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        29, 0, 0, 0, 29, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        29, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 29, 0, 0, 0, 0, 0, 0, 0
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
          x = 0,
          y = 32,
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
          x = 0,
          y = 48,
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
          x = 0,
          y = 224,
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
          x = 48,
          y = 0,
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
          y = 0,
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
          x = 80,
          y = 0,
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
          x = 0,
          y = 240,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            [""] = ""
          }
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 96,
          y = 0,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            [""] = ""
          }
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 112,
          y = 0,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            [""] = ""
          }
        },
        {
          name = "",
          type = "brokenwall_ruins",
          shape = "rectangle",
          x = 16,
          y = 0,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            [""] = ""
          }
        }
      }
    }
  }
}
