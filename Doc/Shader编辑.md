# Shader编辑

## IDE

IDE，目前选择的是VSCode，有高亮

## Shader Language

没有现成的Shader Language，只能基于glsl去简单改，造DSL轮子收益预期很低

目前的Shader仍然靠人肉Code Review，确保正确性，没有调试和静态校验

## 目前方案

加载时会类似C宏一样做一些字符串替换，然后按lua加载字符串，拼出VS和PS代码

平时编辑时，文件是glsl，便于VSCode高亮

目前的规则：
1. //注释的代码是lua代码，加载时会取消注释，整个文件变成lua代码  // 所以glsl的注释只允许/**/
2. // common: 替换标签，用common_code替代
3. varying，在VS里替换成out，PS里替换成out
