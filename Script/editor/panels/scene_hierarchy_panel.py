# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# scene_hierarchy_panel.py
# created on 2020/12/28
# usage: scene_hierarchy_panel
import glm
import imgui

from common.zlogger import logger


def menu_item_clicked(*args, **kwargs):
    clicked, selected = imgui.menu_item(*args, **kwargs)
    return clicked


class ValueEdit(object):
    def __init__(self, data_source, name, widget_name, label):
        self.data_source = data_source
        self.name = name
        self.widget_name = widget_name
        self.label = label
        self.is_list = isinstance(self.value, self.list_type)
        self.is_str = isinstance(self.value, (str, unicode))
        self.widget_fn = getattr(imgui, self.widget_name)

    # TOO SLOW
    # @property
    # def is_list(self):
    #     return isinstance(self.value, list_type())

    @property
    def list_type(self):
        import glm
        return (
            list,
            tuple,
            glm.vec3,
            glm.vec4
        )

    @property
    def value(self):
        return getattr(self.data_source, self.name)

    @value.setter
    def value(self, val):
        setattr(self.data_source, self.name, val)

    def __call__(self, **kwargs):
        if self.is_list:
            changed, value = self.widget_fn(self.label, *self.value, **kwargs)
        elif self.is_str:
            changed, value = self.widget_fn(self.label, self.value, 256, **kwargs)
        else:
            changed, value = self.widget_fn(self.label, self.value, **kwargs)
        if changed:
            self.value = value


class ValueEditConvert(ValueEdit):
    def __init__(self, data_source, name, widget_name, label,
                 value_internal2display_fn=None,
                 value_display2internal_fn=None):
        self.value_internal2display_fn = value_internal2display_fn
        self.value_display2internal_fn = value_display2internal_fn
        super(ValueEditConvert, self).__init__(data_source, name, widget_name, label)

    @property
    def value(self):
        internal_value = getattr(self.data_source, self.name)
        return self.value_internal2display_fn(internal_value) if self.value_display2internal_fn else internal_value

    @value.setter
    def value(self, val):
        internal_value = self.value_display2internal_fn(val) if self.value_display2internal_fn else val
        setattr(self.data_source, self.name, internal_value)


class ValueEditCombo(ValueEdit):
    def __init__(self, data_source, name, label, enum_map):
        super(ValueEditCombo, self).__init__(data_source, name, "", label)
        self.enum_map = enum_map
        self.enum_map_invert = {v: k for k, v in enum_map.iteritems()}
        self.enum_values = enum_map.values()

    def __call__(self, *args, **kwargs):
        clicked, value = imgui.combo(self.label, self.enum_map[self.value], self.enum_values)
        if clicked:
            self.value = self.enum_map_invert[value]


class SceneHierarchyPanel(object):
    def __init__(self, scene):
        self.scene = None
        self.selected_entity = None
        self.initialize(scene)

    def initialize(self, scene):
        self.scene = scene
        self.selected_entity = None

    def on_gui(self):
        # ---------------------------------------------------
        # Scene Hierarchy
        # ---------------------------------------------------
        imgui.begin("Scene Hierarchy")
        # draw all entities
        for entity in self.scene:
            self._draw_entity_node(entity)

        # clear selection
        if imgui.is_mouse_down(0) and imgui.is_window_hovered():
            self.selected_entity = None

        # create new entity
        if imgui.begin_popup_context_window():
            if menu_item_clicked("Create Empty Entity"):
                self.scene.create_entity("Empty Entity")
            imgui.end_popup()
        imgui.end()

        # ---------------------------------------------------
        # Properties
        # ---------------------------------------------------
        imgui.begin("Properties")
        if self.selected_entity:
            self._draw_entity_components(self.selected_entity)
        imgui.end()

    # @logger
    def _draw_entity_node(self, entity):
        tag = entity.tag
        flags = imgui.TREE_NODE_SELECTED if self.selected_entity == entity else 0
        opened = imgui.tree_node(tag, flags)
        if imgui.is_item_clicked():
            self.selected_entity = entity
        entityDeleted = False

        # get delete entity
        if imgui.begin_popup_context_item():
            if menu_item_clicked("Delete Entity"):
                entityDeleted = True
            imgui.end_popup()

        # handle opened
        if opened:
            # flags = imgui.TREE_NODE_OPEN_ON_ARROW
            # pass # TODO draw sub object HERE
            # if imgui.tree_node(tag, flags):
            #     imgui.tree_pop()
            imgui.tree_pop()

        # handle delete entity
        if entityDeleted:
            self.scene.destroy_entity(entity)
            if self.selected_entity == entity:
                self.selected_entity = None

    def _draw_entity_components(self, entity):
        ValueEdit(entity, "tag", "input_text", "Tag")()

        # ---------------------------------------------------
        # add component
        # ---------------------------------------------------
        imgui.same_line()
        imgui.push_item_width(-1)

        if imgui.button("Add Component"):
            imgui.open_popup("AddComponent")

        if imgui.begin_popup("AddComponent"):
            if menu_item_clicked("Transform"):
                entity.add_component("transform")
                imgui.close_current_popup()
            if menu_item_clicked("Camera"):
                print "add component camera"
                imgui.close_current_popup()
            if menu_item_clicked("Sprite Renderer"):
                print "add component sprite renderer"
                imgui.close_current_popup()
            if menu_item_clicked("Physics"):
                entity.add_component("physics")
                imgui.close_current_popup()
            imgui.end_popup()

        imgui.pop_item_width()

        # ---------------------------------------------------
        # draw components
        # ---------------------------------------------------
        self._draw_component(entity, "transform", "Transform")
        self._draw_component(entity, "camera", "Camera")
        self._draw_component(entity, "sprite_renderer", "Sprite Renderer")
        self._draw_component(entity, "physics", "Physics")

    def _draw_component(self, entity, component_name, component_name_display):
        if not entity.has_component(component_name):
            return
        treeNodeFlags = imgui.TREE_NODE_DEFAULT_OPEN | imgui.TREE_NODE_FRAMED | imgui.TREE_NODE_ALLOW_ITEM_OVERLAP | imgui.TREE_NODE_FRAME_PADDING
        component = entity.get_component(component_name)
        # contentRegionAvailable = imgui.get_content_region_available()
        # lineHeight =
        imgui.push_style_var(imgui.STYLE_FRAME_PADDING, (4, 4))
        imgui.separator()
        open = imgui.tree_node(component_name_display, treeNodeFlags)
        imgui.pop_style_var()
        # TODO imgui.same_line(contentRegionAvailable.x - lin)
        imgui.same_line()
        if imgui.button("+"):
            imgui.open_popup("ComponentSettings")
        removeComponent = False
        if imgui.begin_popup("ComponentSettings"):
            if menu_item_clicked("Remove component"):
                removeComponent = True
            imgui.end_popup()
        if open:
            getattr(self, "_draw_component_%s" % component_name)(component)
            imgui.tree_pop()

        if removeComponent:
            entity.remove_component(component_name)

    def _draw_vec3_control(self, label, data_source, name):
        # TODO , reset_value=0., column_width=100.
        ValueEdit(data_source, name, "slider_float3", label)(min_value=0., max_value=100.)

    def _draw_vec3_control_convert(self, label, data_source, name, **kwargs):
        # TODO , reset_value=0., column_width=100.
        ValueEditConvert(data_source, name, "slider_float3", label, **kwargs)(min_value=0., max_value=100.)

    def _draw_component_transform(self, component):
        self._draw_vec3_control("Translation", component, "position")
        self._draw_vec3_control_convert("Rotation", component, "rotation",
                                        value_display2internal_fn=glm.radians, value_internal2display_fn=glm.degrees)
        self._draw_vec3_control("Scale", component, "scale")  # TODO reset value to 1

    def _draw_component_sprite_renderer(self, component):
        ValueEdit(component, "color", "color_edit4", "Color")

    def _draw_component_camera(self, component):
        ValueEdit(component, "is_main_camera", "check_box", "Is Main Camera")
        ValueEditCombo(component, "projection_type", "Projection Type", {0: "Perspective", 1: "Orthographic"})
        if component.projection_type == 0:
            # 根据相机类型显示不同的参数面板
            # ValueEdit新需求，指定setter
            pass
        else:
            pass

    def _draw_component_physics(self, component):
        pass

    # ---------------------------------------------------
    # debug
    # ---------------------------------------------------
    def dump_transform(self, entity):
        print entity.components.transform.position
        print entity.components.transform.rotation
        print entity.components.transform.scale

    def __repr__(self):
        return self.__class__.__name__
