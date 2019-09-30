'''class in UnityEngine/Inherits from:Component/Implemented in:UnityEngine.CoreModule
Description
Behaviours are Components that can be enabled or disabled.

See Also: MonoBehaviour and Component.'''
from project.src.ZeptUnityEngine.CoreModule.Component import Component


class Behaviour(Component):
    # region Properties
    @property
    def enabled(self):
        '''Enabled Behaviours are Updated, disabled Behaviours are not.'''
        pass

    @property
    def isActiveAndEnabled(self):
        '''Has the Behaviour had active and enabled called?'''
        pass
    # endregion
