'''class in UnityEngine/Inherits from:Object/Implemented in:UnityEngine.CoreModule
Description
Base class for everything attached to GameObjects.

Note that your code will never directly create a Component.
Instead, you write script code, and attach the script to a GameObject.
See Also: ScriptableObject as a way to create scripts that do not attach to any GameObject.'''
from project.src.ZeptUnityEngine.CoreModule.Object import Object


class Component(Object):
    # region Properties
    @property
    def gameObject(self):
        '''The game object this component is attached to. A component is always attached to a game object.'''
        pass

    @property
    def tag(self):
        '''The tag of this game object.'''
        pass

    @property
    def transform(self):
        '''The Transform attached to this GameObject.'''
        pass

    # endregion
    # region Public Methods
    def BroadcastMessage(self):
        '''Calls the method named methodName on every MonoBehaviour in this game object or any of its children.'''
        pass

    def CompareTag(self):
        '''Is this game object tagged with tag ?'''
        pass

    def GetComponent(self):
        '''Returns the component of Type type if the game object has one attached, null if it doesn't.'''
        pass

    def GetComponentInChildren(self):
        '''Returns the component of Type type in the GameObject or any of its children using depth first search.'''
        pass

    def GetComponentInParent(self):
        '''Returns the component of Type type in the GameObject or any of its parents.'''
        pass

    def GetComponents(self):
        '''Returns all components of Type type in the GameObject.'''
        pass

    def GetComponentsInChildren(self):
        '''Returns all components of Type type in the GameObject or any of its children.'''
        pass

    def GetComponentsInParent(self):
        '''Returns all components of Type type in the GameObject or any of its parents.'''
        pass

    # def SendMessage(self):
    # 	'''Calls the method named methodName on every MonoBehaviour in this game object.'''
    # 	pass
    # def SendMessageUpwards(self):
    # 	'''Calls the method named methodName on every MonoBehaviour in this game object and on every ancestor of the behaviour.'''
    # 	pass
    def __str__(self):
        ''''''
        return self.ToString()

    def __repr__(self):
        ''''''
        return self.ToString()
    # endregion
