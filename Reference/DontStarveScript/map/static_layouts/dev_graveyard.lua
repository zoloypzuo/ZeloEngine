return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 32,
  height = 32,
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
      width = 32,
      height = 32,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        10, 0, 0, 0, 10, 0, 0, 0, 10, 0, 0, 0, 10, 0, 0, 0, 10, 0, 0, 0, 10, 0, 0, 0, 10, 0, 0, 0, 10, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        10, 0, 0, 0, 7, 0, 0, 0, 7, 0, 0, 0, 7, 0, 0, 0, 7, 0, 0, 0, 7, 0, 0, 0, 7, 0, 0, 0, 10, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        10, 0, 0, 0, 7, 0, 0, 0, 7, 0, 0, 0, 7, 0, 0, 0, 7, 0, 0, 0, 7, 0, 0, 0, 7, 0, 0, 0, 10, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        10, 0, 0, 0, 7, 0, 0, 0, 7, 0, 0, 0, 7, 0, 0, 0, 7, 0, 0, 0, 7, 0, 0, 0, 7, 0, 0, 0, 10, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        10, 0, 0, 0, 10, 0, 0, 0, 10, 0, 0, 0, 10, 0, 0, 0, 10, 0, 0, 0, 10, 0, 0, 0, 10, 0, 0, 0, 10, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
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
          name = "Bryce",
          type = "gravestone",
          shape = "rectangle",
          x = 416,
          y = 224,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.setepitaph"] = "Bryce"
          }
        },
        {
          name = "Kelly",
          type = "gravestone",
          shape = "rectangle",
          x = 160,
          y = 288,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.setepitaph"] = "Kelly"
          }
        },
        {
          name = "Sloth",
          type = "gravestone",
          shape = "rectangle",
          x = 416,
          y = 160,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.setepitaph"] = "Sloth"
          }
        },
        {
          name = "Alex",
          type = "gravestone",
          shape = "rectangle",
          x = 160,
          y = 160,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.setepitaph"] = "Alex"
          }
        },
        {
          name = "Brook",
          type = "gravestone",
          shape = "rectangle",
          x = 352,
          y = 288,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.setepitaph"] = "Brook"
          }
        },
        {
          name = "Alia",
          type = "gravestone",
          shape = "rectangle",
          x = 288,
          y = 288,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.setepitaph"] = "Alia"
          }
        },
        {
          name = "Tatham",
          type = "gravestone",
          shape = "rectangle",
          x = 352,
          y = 160,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.setepitaph"] = "Tatham"
          }
        },
        {
          name = "Graham",
          type = "gravestone",
          shape = "rectangle",
          x = 288,
          y = 160,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.setepitaph"] = "Graham"
          }
        },
        {
          name = "Kevin",
          type = "gravestone",
          shape = "rectangle",
          x = 224,
          y = 224,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.setepitaph"] = "Kevin",
            ["scenario"] = "graveyard_ghosts"
          }
        },
        {
          name = "Ju-lian",
          type = "gravestone",
          shape = "rectangle",
          x = 416,
          y = 288,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.setepitaph"] = "Ju-lian"
          }
        },
        {
          name = "Jeff",
          type = "gravestone",
          shape = "rectangle",
          x = 224,
          y = 288,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.setepitaph"] = "Jeff"
          }
        },
        {
          name = "Wade",
          type = "gravestone",
          shape = "rectangle",
          x = 160,
          y = 224,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.setepitaph"] = "Wade"
          }
        },
        {
          name = "Charles",
          type = "gravestone",
          shape = "rectangle",
          x = 224,
          y = 160,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.setepitaph"] = "Charles"
          }
        },
        {
          name = "Jamie",
          type = "gravestone",
          shape = "rectangle",
          x = 288,
          y = 224,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.setepitaph"] = "Jamie"
          }
        },
        {
          name = "Corey",
          type = "gravestone",
          shape = "rectangle",
          x = 96,
          y = 160,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.setepitaph"] = "Corey"
          }
        },
        {
          name = "Joe",
          type = "gravestone",
          shape = "rectangle",
          x = 96,
          y = 224,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.setepitaph"] = "Joe"
          }
        },
        {
          name = "Matt",
          type = "gravestone",
          shape = "rectangle",
          x = 96,
          y = 288,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.setepitaph"] = "Matt"
          }
        },
        {
          name = "",
          type = "statuemaxwell",
          shape = "rectangle",
          x = 256,
          y = 416,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "evergreen_normal",
          shape = "rectangle",
          x = 368,
          y = 464,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "marblepillar",
          shape = "rectangle",
          x = 64,
          y = 320,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "evergreen_normal",
          shape = "rectangle",
          x = 432,
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
          x = 448,
          y = 128,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "evergreen_normal",
          shape = "rectangle",
          x = 128,
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
          x = 448,
          y = 320,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "evergreen_normal",
          shape = "rectangle",
          x = 496,
          y = 416,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "evergreen_normal",
          shape = "rectangle",
          x = 160,
          y = 480,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "evergreen_short",
          shape = "rectangle",
          x = 368,
          y = 16,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "marblepillar",
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
          type = "shovel",
          shape = "rectangle",
          x = 352,
          y = 432,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "statuemaxwell",
          shape = "rectangle",
          x = 256,
          y = 32,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "flower_evil",
          shape = "rectangle",
          x = 304,
          y = 192,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "flower_evil",
          shape = "rectangle",
          x = 230,
          y = 258,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "flower_evil",
          shape = "rectangle",
          x = 128,
          y = 240,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "flower_evil",
          shape = "rectangle",
          x = 128,
          y = 160,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "flower_evil",
          shape = "rectangle",
          x = 384,
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
          x = 416,
          y = 192,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "flower_evil",
          shape = "rectangle",
          x = 368,
          y = 416,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "flower_evil",
          shape = "rectangle",
          x = 128,
          y = 448,
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
          y = 32,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "flower_evil",
          shape = "rectangle",
          x = 160,
          y = 32,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "David",
          type = "gravestone",
          shape = "rectangle",
          x = 352,
          y = 224,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.setepitaph"] = "David"
          }
        }
      }
    }
  }
}
