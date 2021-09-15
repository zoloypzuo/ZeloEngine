# Main

Main窗口的两个checkbox关联两个窗口

一个主要的DemoWindow

还有一个非常简单的窗口

![Snipaste_2021-09-15_23-27-11](https://raw.githubusercontent.com/zolo-mario/image-host/main/20210704/Snipaste_2021-09-15_23-27-11.5abxg8bukww0.png)

Main窗口

非常简单，略

![Snipaste_2021-09-15_23-28-13](https://raw.githubusercontent.com/zolo-mario/image-host/main/20210704/Snipaste_2021-09-15_23-28-13.5q45xsbykts0.png)

```cpp
// 2. Show a simple window that we create ourselves. We use a Begin/End pair to created a named window.
static float f = 0.0f;
static int counter = 0;

ImGui::Begin("Hello, world!");                          // Create a window called "Hello, world!" and append into it.

ImGui::Text("This is some useful text.");               // Display some text (you can use a format strings too)
ImGui::Checkbox("Demo Window", &show_demo_window);      // Edit bools storing our window open/close state
ImGui::Checkbox("Another Window", &show_another_window);

ImGui::SliderFloat("float", &f, 0.0f, 1.0f);            // Edit 1 float using a slider from 0.0f to 1.0f
ImGui::ColorEdit3("clear color", (float*)&clear_color); // Edit 3 floats representing a color

if (ImGui::Button("Button"))                            // Buttons return true when clicked (most widgets return true when edited/activated)
    counter++;
ImGui::SameLine();
ImGui::Text("counter = %d", counter);

ImGui::Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);
ImGui::End();
```