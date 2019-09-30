'''class in UnityEngine/Implemented in:UnityEngine.CoreModule
Description
Base class for all objects Unity can reference.

Any public variable you make that derives from Object gets shown in the inspector as a drop target, allowing you to set the value from the GUI.
UnityEngine.Object is the base class of all built-in Unity objects.

Although Object is a class it is not intended to be used widely in script.
However as an example Object is used in the Resources class.
See Resources.LoadAll which has [[Object[]]] as a return.

This class doesn't support the null-conditional operator (?.) and the null-coalescing operator (??).'''


class Object():
    # region Properties
    @property
    def hideFlags(self):
        '''Should the object be hidden, saved with the Scene or modifiable by the user?'''
        pass

    @property
    def name(self):
        '''The name of the object.'''
        pass

    # endregion
    # region Public Methods
    def GetInstanceID(self):
        '''Returns the instance id of the object.'''
        pass

    def ToString(self):
        '''Returns the name of the GameObject.'''
        pass

    def __str__(self):
        ''''''
        return self.ToString()

    def __repr__(self):
        ''''''
        return self.ToString()

    # endregion
    # region Static Methods
    @staticmethod
    def Destroy():
        '''Removes a gameobject, component or asset.'''
        pass

    @staticmethod
    def DestroyImmediate():
        '''Destroys the object obj immediately. You are strongly recommended to use Destroy instead.'''
        pass

    @staticmethod
    def DontDestroyOnLoad():
        '''Do not destroy the target Object when loading a new Scene.'''
        pass

    @staticmethod
    def FindObjectOfType():
        '''Returns the first active loaded object of Type type.'''
        pass

    @staticmethod
    def FindObjectsOfType():
        '''Returns a list of all active loaded objects of Type type.'''
        pass

    @staticmethod
    def Instantiate():
        '''Clones the object original and returns the clone.'''
        pass

    # endregion
    # region Operators
    def __bool__(self, other):
        '''Does the object exist?'''
        pass

    def __ne__(self, other):
        '''Compares if two objects refer to a different object.'''
        return not self.Equals(other)

    def __eq__(self, other):
        '''Compares two object references to see if they refer to the same object.'''
        return self.Equals(other)
    # endregion
