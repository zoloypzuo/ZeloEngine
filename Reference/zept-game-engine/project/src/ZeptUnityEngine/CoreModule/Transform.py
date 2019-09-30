'''class in UnityEngine/Inherits from:Component/Implemented in:UnityEngine.CoreModule
Description
Position, rotation and scale of an object.

Every object in a Scene has a Transform.
It's used to store and manipulate the position, rotation and scale of the object.
Every Transform can have a parent, which allows you to apply position, rotation and scale hierarchically.
This is the hierarchy seen in the Hierarchy pane.
They also support enumerators so you can loop through children using:

using UnityEngine;

public class Example : MonoBehaviour
{
    // Moves all transform children 10 units upwards!
    void Start()
    {
        foreach (Transform child in transform)
        {
            child.position += Vector3.up * 10.0f;
        }
    }
}
See Also: The component reference, Physics class.'''
from project.src.ZeptUnityEngine.CoreModule.Component import Component


class Transform(Component):
    # region Properties
    @property
    def childCount(self):
        '''The number of children the parent Transform has.'''
        pass

    @property
    def eulerAngles(self):
        '''The rotation as Euler angles in degrees.'''
        pass

    @property
    def forward(self):
        '''The blue axis of the transform in world space.'''
        pass

    @property
    def hasChanged(self):
        '''Has the transform changed since the last time the flag was set to 'false'?'''
        pass

    @property
    def hierarchyCapacity(self):
        '''The transform capacity of the transform's hierarchy data structure.'''
        pass

    @property
    def hierarchyCount(self):
        '''The number of transforms in the transform's hierarchy data structure.'''
        pass

    @property
    def localEulerAngles(self):
        '''The rotation as Euler angles in degrees relative to the parent transform's rotation.'''
        pass

    @property
    def localPosition(self):
        '''Position of the transform relative to the parent transform.'''
        pass

    @property
    def localRotation(self):
        '''The rotation of the transform relative to the transform rotation of the parent.'''
        pass

    @property
    def localScale(self):
        '''The scale of the transform relative to the parent.'''
        pass

    @property
    def localToWorldMatrix(self):
        '''Matrix that transforms a point from local space into world space (Read Only).'''
        pass

    @property
    def lossyScale(self):
        '''The global scale of the object (Read Only).'''
        pass

    @property
    def parent(self):
        '''The parent of the transform.'''
        pass

    @property
    def position(self):
        '''The world space position of the Transform.'''
        pass

    @property
    def right(self):
        '''The red axis of the transform in world space.'''
        pass

    @property
    def root(self):
        '''Returns the topmost transform in the hierarchy.'''
        pass

    @property
    def rotation(self):
        '''The rotation of the transform in world space stored as a Quaternion.'''
        pass

    @property
    def up(self):
        '''The green axis of the transform in world space.'''
        pass

    @property
    def worldToLocalMatrix(self):
        '''Matrix that transforms a point from world space into local space (Read Only).'''
        pass

    # endregion
    # region Public Methods
    def DetachChildren(self):
        '''Unparents all children.'''
        pass

    def Find(self):
        '''Finds a child by n and returns it.'''
        pass

    def GetChild(self):
        '''Returns a transform child by index.'''
        pass

    def GetSiblingIndex(self):
        '''Gets the sibling index.'''
        pass

    def InverseTransformDirection(self):
        '''Transforms a direction from world space to local space. The opposite of Transform.TransformDirection.'''
        pass

    def InverseTransformPoint(self):
        '''Transforms position from world space to local space.'''
        pass

    def InverseTransformVector(self):
        '''Transforms a vector from world space to local space. The opposite of Transform.TransformVector.'''
        pass

    def IsChildOf(self):
        '''Is this transform a child of parent?'''
        pass

    def LookAt(self):
        '''Rotates the transform so the forward vector points at /target/'s current position.'''
        pass

    def Rotate(self):
        '''Applies a rotation of eulerAngles.z degrees around the z axis, eulerAngles.x degrees around the x axis, and eulerAngles.y degrees around the y axis (in that order).'''
        pass

    def RotateAround(self):
        '''Rotates the transform about axis passing through point in world coordinates by angle degrees.'''
        pass

    def SetAsFirstSibling(self):
        '''Move the transform to the start of the local transform list.'''
        pass

    def SetAsLastSibling(self):
        '''Move the transform to the end of the local transform list.'''
        pass

    def SetParent(self):
        '''Set the parent of the transform.'''
        pass

    def SetPositionAndRotation(self):
        '''Sets the world space position and rotation of the Transform component.'''
        pass

    def SetSiblingIndex(self):
        '''Sets the sibling index.'''
        pass

    def TransformDirection(self):
        '''Transforms direction from local space to world space.'''
        pass

    def TransformPoint(self):
        '''Transforms position from local space to world space.'''
        pass

    def TransformVector(self):
        '''Transforms vector from local space to world space.'''
        pass

    def Translate(self):
        '''Moves the transform in the direction and distance of translation.'''
        pass

    def __str__(self):
        ''''''
        return self.ToString()

    def __repr__(self):
        ''''''
        return self.ToString()
    # endregion
