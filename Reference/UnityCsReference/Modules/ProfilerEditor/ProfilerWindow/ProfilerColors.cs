// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using System;
using UnityEditor;
using UnityEditor.Accessibility;
using UnityEditorInternal.Profiling;
using UnityEngine;
using UnityEngine.Accessibility;

namespace UnityEditorInternal
{
    internal class ProfilerColors
    {
        static ProfilerColors()
        {
            // Areas are defined by stats in ProfilerStats.cpp file.
            // Color are driven by CPU profiler chart area colors and must be consistent with CPU timeline sample colors.
            // Sample color is defined by ProfilerGroup (category) and defined in s_ProfilerGroupInfos table.
            s_DefaultColors = new Color[]
            {
                FrameDataView.GetMarkerCategoryColor(0),                            // "Rendering"
                FrameDataView.GetMarkerCategoryColor(1),                            // "Scripts"
                FrameDataView.GetMarkerCategoryColor(5),                            // "Physics"
                FrameDataView.GetMarkerCategoryColor(6),                            // "Animation"
                FrameDataView.GetMarkerCategoryColor(15),                           // "GarbageCollector"
                FrameDataView.GetMarkerCategoryColor(16),                           // "VSync"
                FrameDataView.GetMarkerCategoryColor(11),                           // "Global Illumination"
                FrameDataView.GetMarkerCategoryColor(24),                           // "UI"
                new Color(122.0f / 255.0f, 123.0f / 255.0f,  30.0f / 255.0f, 1.0f), // "Others"

                new Color(240.0f / 255.0f, 128.0f / 255.0f, 128.0f / 255.0f, 1.0f),  // light-coral
                new Color(169.0f / 255.0f, 169.0f / 255.0f, 169.0f / 255.0f, 1.0f),  // dark-gray
                new Color(139.0f / 255.0f, 0.0f, 139.0f / 255.0f, 1.0f),  // dark-magenta
                new Color(255.0f / 255.0f, 228.0f / 255.0f, 181.0f / 255.0f, 1.0f),  // moccasin
                new Color(32.0f / 255.0f, 178.0f / 255.0f, 170.0f / 255.0f, 1.0f),  // light-sea-green
                new Color(0.4831376f, 0.6211768f, 0.0219608f, 1.0f),
                new Color(0.3827448f, 0.2886272f, 0.5239216f, 1.0f),
                new Color(0.8f, 0.4423528f, 0.0f, 1.0f),
                new Color(0.4486272f, 0.4078432f, 0.050196f, 1.0f),
                new Color(0.4831376f, 0.6211768f, 0.0219608f, 1.0f),
            };
            s_ColorBlindSafeColors = new Color[s_DefaultColors.Length];
            VisionUtility.GetColorBlindSafePalette(s_ColorBlindSafeColors, 0.3f, 1f);
        }

        public static Color[] chartAreaColors
        {
            get { return UserAccessiblitySettings.colorBlindCondition == ColorBlindCondition.Default ? s_DefaultColors : s_ColorBlindSafeColors; }
        }

        private static readonly Color[] s_DefaultColors;
        private static readonly Color[] s_ColorBlindSafeColors;
    }
}
