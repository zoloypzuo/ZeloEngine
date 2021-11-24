-- craft.lua
-- created on 2021/11/23
-- author @zoloypzuo
function CraftInitialize()
    -- TODO tex params
    --    // LOAD TEXTURES //
    --    GLuint texture;
    --    glGenTextures(1, &texture);
    --    glActiveTexture(GL_TEXTURE0);
    --    glBindTexture(GL_TEXTURE_2D, texture);
    --    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    --    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    --    load_png_texture("textures/texture.png");
    --
    --    GLuint font;
    --    glGenTextures(1, &font);
    --    glActiveTexture(GL_TEXTURE1);
    --    glBindTexture(GL_TEXTURE_2D, font);
    --    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    --    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    --    load_png_texture("textures/font.png");
    --
    --    GLuint sky;
    --    glGenTextures(1, &sky);
    --    glActiveTexture(GL_TEXTURE2);
    --    glBindTexture(GL_TEXTURE_2D, sky);
    --    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    --    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    --    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    --    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    --    load_png_texture("textures/sky.png");
    --
    --    GLuint sign;
    --    glGenTextures(1, &sign);
    --    glActiveTexture(GL_TEXTURE3);
    --    glBindTexture(GL_TEXTURE_2D, sign);
    --    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    --    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    --    load_png_texture("textures/sign.png");
    LoadResource("texture.png")
    LoadResource("sky.png")
    LoadResource("sign.png")
end