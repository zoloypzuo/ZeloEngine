# 控件ID

https://github.com/ocornut/imgui/blob/master/docs/FAQ.md#q-why-is-my-widget-not-reacting-when-i-click-on-it

为什么控件交互没有反应？

ImGui隐式维护ID，控件树中的控件路径被hash来标识一个控件

每个控件的接口一般都有label，是该控件的ID

所以传空串就会导致无法交互，解决是用##XXX来标识，这些在显示时被忽略

