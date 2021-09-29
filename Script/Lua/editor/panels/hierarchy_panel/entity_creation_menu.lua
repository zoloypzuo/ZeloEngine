-- entity_creation_menu
-- created on 2021/8/25
-- author @zoloypzuo
local _M = {}

function _M.GenerateEntityCreationMenu(menuList, parentEntity, onItemClicked)
    -- TODO
    --GenerateActorCreationMenu(MenuList& p_menuList, Actor* p_parent, std::optional<std::function<void()>> p_onItemClicked)
end

--p_menuList.CreateWidget<MenuItem>("Create Empty").ClickedEvent += Combine(EDITOR_BIND(CreateEmptyActor, true, p_parent, ""), p_onItemClicked);
--
--auto& primitives = p_menuList.CreateWidget<MenuList>("Primitives");
--auto& physicals = p_menuList.CreateWidget<MenuList>("Physicals");
--auto& lights = p_menuList.CreateWidget<MenuList>("Lights");
--auto& audio = p_menuList.CreateWidget<MenuList>("Audio");
--auto& others = p_menuList.CreateWidget<MenuList>("Others");
--
--primitives.CreateWidget<MenuItem>("Cube").ClickedEvent              += ActorWithModelComponentCreationHandler(p_parent, "Cube", p_onItemClicked);
--primitives.CreateWidget<MenuItem>("Sphere").ClickedEvent            += ActorWithModelComponentCreationHandler(p_parent, "Sphere", p_onItemClicked);
--primitives.CreateWidget<MenuItem>("Cone").ClickedEvent              += ActorWithModelComponentCreationHandler(p_parent, "Cone", p_onItemClicked);
--primitives.CreateWidget<MenuItem>("Cylinder").ClickedEvent          += ActorWithModelComponentCreationHandler(p_parent, "Cylinder", p_onItemClicked);
--primitives.CreateWidget<MenuItem>("Plane").ClickedEvent             += ActorWithModelComponentCreationHandler(p_parent, "Plane", p_onItemClicked);
--primitives.CreateWidget<MenuItem>("Gear").ClickedEvent              += ActorWithModelComponentCreationHandler(p_parent, "Gear", p_onItemClicked);
--primitives.CreateWidget<MenuItem>("Helix").ClickedEvent             += ActorWithModelComponentCreationHandler(p_parent, "Helix", p_onItemClicked);
--primitives.CreateWidget<MenuItem>("Pipe").ClickedEvent              += ActorWithModelComponentCreationHandler(p_parent, "Pipe", p_onItemClicked);
--primitives.CreateWidget<MenuItem>("Pyramid").ClickedEvent           += ActorWithModelComponentCreationHandler(p_parent, "Pyramid", p_onItemClicked);
--primitives.CreateWidget<MenuItem>("Torus").ClickedEvent             += ActorWithModelComponentCreationHandler(p_parent, "Torus", p_onItemClicked);
--physicals.CreateWidget<MenuItem>("Physical Box").ClickedEvent       += ActorWithComponentCreationHandler<CPhysicalBox>(p_parent, p_onItemClicked);
--physicals.CreateWidget<MenuItem>("Physical Sphere").ClickedEvent    += ActorWithComponentCreationHandler<CPhysicalSphere>(p_parent, p_onItemClicked);
--physicals.CreateWidget<MenuItem>("Physical Capsule").ClickedEvent   += ActorWithComponentCreationHandler<CPhysicalCapsule>(p_parent, p_onItemClicked);
--lights.CreateWidget<MenuItem>("Point").ClickedEvent                 += ActorWithComponentCreationHandler<CPointLight>(p_parent, p_onItemClicked);
--lights.CreateWidget<MenuItem>("Directional").ClickedEvent           += ActorWithComponentCreationHandler<CDirectionalLight>(p_parent, p_onItemClicked);
--lights.CreateWidget<MenuItem>("Spot").ClickedEvent                  += ActorWithComponentCreationHandler<CSpotLight>(p_parent, p_onItemClicked);
--lights.CreateWidget<MenuItem>("Ambient Box").ClickedEvent           += ActorWithComponentCreationHandler<CAmbientBoxLight>(p_parent, p_onItemClicked);
--lights.CreateWidget<MenuItem>("Ambient Sphere").ClickedEvent        += ActorWithComponentCreationHandler<CAmbientSphereLight>(p_parent, p_onItemClicked);
--audio.CreateWidget<MenuItem>("Audio Source").ClickedEvent           += ActorWithComponentCreationHandler<CAudioSource>(p_parent, p_onItemClicked);
--audio.CreateWidget<MenuItem>("Audio Listener").ClickedEvent         += ActorWithComponentCreationHandler<CAudioListener>(p_parent, p_onItemClicked);
--others.CreateWidget<MenuItem>("Camera").ClickedEvent                += ActorWithComponentCreationHandler<CCamera>(p_parent, p_onItemClicked);
return _M