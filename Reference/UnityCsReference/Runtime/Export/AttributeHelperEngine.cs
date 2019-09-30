// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using UnityEngine.Scripting;

namespace AOT
{
    // Mono AOT compiler detects this attribute by name and generates required wrappers for
    // native->managed callbacks. Works only for static methods.
    [System.AttributeUsage(System.AttributeTargets.Method)]
    public class MonoPInvokeCallbackAttribute : Attribute
    {
        public MonoPInvokeCallbackAttribute(Type type) {}
    }
}

namespace UnityEngine
{
    class AttributeHelperEngine
    {

        [RequiredByNativeCode]
        static Type GetParentTypeDisallowingMultipleInclusion(Type type)
        {
            Type result = null;
            while (type != null && type != typeof(MonoBehaviour))
            {
                if (Attribute.IsDefined(type, typeof(DisallowMultipleComponent)))
                    result = type;
                type = type.BaseType;
            }
            return result;
        }

        [RequiredByNativeCode]
        static Type[] GetRequiredComponents(Type klass)
        {
            // Generate an array for all required components
            // .NET doesnt give us multiple copies of the same attribute on derived classes
            // Thus we do it manually
            List<Type> required = null;
            while (klass != null && klass != typeof(MonoBehaviour))
            {
                RequireComponent[] attrs = (RequireComponent[])klass.GetCustomAttributes(typeof(RequireComponent), false);
                Type baseType = klass.BaseType;

                foreach (var attri in attrs)
                {
                    if (required == null && attrs.Length == 1 && baseType == typeof(MonoBehaviour))
                    {
                        Type[] types = { attri.m_Type0, attri.m_Type1, attri.m_Type2 };
                        return types;
                    }
                    else
                    {
                        if (required == null)
                            required = new List<Type>();
                        if (attri.m_Type0 != null)
                            required.Add(attri.m_Type0);
                        if (attri.m_Type1 != null)
                            required.Add(attri.m_Type1);
                        if (attri.m_Type2 != null)
                            required.Add(attri.m_Type2);
                    }
                }

                klass = baseType;
            }
            if (required == null)
                return null;
            else
                return required.ToArray();
        }

        static int GetExecuteMode(Type klass)
        {
            var customAttributes = klass.GetCustomAttributes(false);
            foreach (var attribute in customAttributes)
            {
                if (attribute is ExecuteAlways)
                    return 2;
                if (attribute is ExecuteInEditMode)
                    return 1;
            }

            return 0;
        }

        [RequiredByNativeCode]
        static int CheckIsEditorScript(Type klass)
        {
            while (klass != null && klass != typeof(MonoBehaviour))
            {
                int executeMode = GetExecuteMode(klass);
                if (executeMode > 0)
                    return executeMode;

                klass = klass
                        .BaseType;
            }
            return 0;
        }

        [RequiredByNativeCode]
        static int GetDefaultExecutionOrderFor(Type klass)
        {
            var attribute = GetCustomAttributeOfType<DefaultExecutionOrder>(klass);
            if (attribute == null)
                return 0;

            return attribute.order;
        }

        static T GetCustomAttributeOfType<T>(Type klass) where T : System.Attribute
        {
            var attributeType = typeof(T);

            var attrs = klass.GetCustomAttributes(attributeType, true);
            if (attrs != null && attrs.Length != 0)
                return (T)attrs[0];

            return null;
        }
    }
}
