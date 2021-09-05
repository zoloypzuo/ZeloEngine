# 控件ID

## 为什么控件交互没有反应？

https://github.com/ocornut/imgui/blob/master/docs/FAQ.md#q-why-is-my-widget-not-reacting-when-i-click-on-it

ImGui隐式维护ID，控件树中的控件路径被hash来标识一个控件

每个控件的接口一般都有label，是该控件的ID

所以传空串就会导致无法交互，解决是用##XXX来标识，这些在显示时被忽略

因为复杂的控件其实维护了状态，比如树节点，有开关状态，所以在帧之间需要标识，这个控件调用就是这个控件

## ID

* ID可以是字符串（label参数），索引，或者指针
* 索引指针用于标识列表控件中的item
* PushID/PopID用于手工构造作用域，来解决冲突
* 因为label还承担显示名字的作用，用##XXX来解决ID冲突


// ID堆栈/范围
//阅读 FAQ（docs/FAQ.md 或 http://dearimgui.org/faq）以了解有关如何在 Dear imgui 中处理 ID 的更多详细信息。
// - 通过对 ID 堆栈系统的理解来回答和影响这些问题：
//    - “问：为什么我的小部件在我点击时没有反应？”
//    - “问：我怎样才能拥有带有空标签的小部件？”
//    - “问：我怎样才能拥有多个具有相同标签的小部件？”
// - 简短版本：ID 是整个 ID 堆栈的哈希值。如果您在循环中创建小部件，您很可能
//   想要推送一个唯一标识符（例如对象指针、循环索引）来唯一区分它们。
// - 您还可以在小部件标签中使用“标签##foobar”语法来区分它们。
// - 在这个头文件中，我们使用“标签”/“名称”术语来表示将显示的字符串 + 用作 ID，
//   而 "str_id" 表示仅用作 ID 且不正常显示的字符串。
void           PushID ( const  char * str_id);                                     //将字符串推入 ID 堆栈（将哈希字符串）。
void           PushID ( const  char * str_id_begin, const  char * str_id_end);       //将字符串推入 ID 堆栈（将哈希字符串）。
void           PushID ( const  void * ptr_id);                                     //将指针推入 ID 堆栈（将散列指针）。
void           PushID ( int int_id);                                             //将整数推入 ID 堆栈（将散列整数）。
void           PopID ();                                                        //从 ID 堆栈中弹出。
ImGuiID        GetID ( const  char * str_id);                                      //计算唯一 ID（整个 ID 堆栈的哈希值 + 给定参数）。例如，如果您想自己查询 ImGuiStorage
ImGuiID        GetID ( const  char * str_id_begin, const  char * str_id_end);
ImGuiID        GetID ( const  void * ptr_id);
