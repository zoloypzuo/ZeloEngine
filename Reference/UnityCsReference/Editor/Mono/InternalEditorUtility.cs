// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using UnityEngine;
using UnityEditor;

using System.IO;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.Scripting.ScriptCompilation;
using UnityEngine.Experimental.UIElements;
using UnityEngine.StyleSheets;
using UnityEngine.Video;

namespace UnityEditorInternal
{
    partial class InternalEditorUtility
    {
        public static Texture2D FindIconForFile(string fileName)
        {
            int i = fileName.LastIndexOf('.');
            string extension = i == -1 ? "" : fileName.Substring(i + 1).ToLower();

            switch (extension)
            {
                // Most .asset files use their scriptable object defined icon instead of a default one.
                case "asset": return AssetDatabase.GetCachedIcon(fileName) as Texture2D ?? EditorGUIUtility.FindTexture("GameManager Icon");

                case "cginc": return EditorGUIUtility.FindTexture("CGProgram Icon");
                case "cs": return EditorGUIUtility.FindTexture("cs Script Icon");
                case "guiskin": return EditorGUIUtility.FindTexture(typeof(GUISkin));
                case "dll": return EditorGUIUtility.FindTexture("Assembly Icon");
                case "asmdef": return EditorGUIUtility.FindTexture(typeof(AssemblyDefinitionAsset));
                case "mat": return EditorGUIUtility.FindTexture(typeof(Material));
                case "physicmaterial": return EditorGUIUtility.FindTexture(typeof(PhysicMaterial));
                case "prefab": return EditorGUIUtility.FindTexture("Prefab Icon");
                case "shader": return EditorGUIUtility.FindTexture(typeof(Shader));
                case "txt": return EditorGUIUtility.FindTexture(typeof(TextAsset));
                case "unity": return EditorGUIUtility.FindTexture(typeof(SceneAsset));
                case "prefs": return EditorGUIUtility.FindTexture(typeof(EditorSettings));
                case "anim": return EditorGUIUtility.FindTexture(typeof(Animation));
                case "meta": return EditorGUIUtility.FindTexture("MetaFile Icon");
                case "mixer": return EditorGUIUtility.FindTexture(typeof(UnityEditor.Audio.AudioMixerController));
                case "uxml": return EditorGUIUtility.FindTexture(typeof(VisualTreeAsset));
                case "uss": return EditorGUIUtility.FindTexture(typeof(StyleSheet));

                case "ttf": case "otf": case "fon": case "fnt":
                    return EditorGUIUtility.FindTexture(typeof(Font));

                case "aac": case "aif": case "aiff": case "au": case "mid": case "midi": case "mp3": case "mpa":
                case "ra": case "ram": case "wma": case "wav": case "wave": case "ogg":
                    return EditorGUIUtility.FindTexture(typeof(AudioClip));

                case "ai": case "apng": case "png": case "bmp": case "cdr": case "dib": case "eps": case "exif":
                case "gif": case "ico": case "icon": case "j": case "j2c": case "j2k": case "jas":
                case "jiff": case "jng": case "jp2": case "jpc": case "jpe": case "jpeg": case "jpf": case "jpg":
                case "jpw": case "jpx": case "jtf": case "mac": case "omf": case "qif": case "qti": case "qtif":
                case "tex": case "tfw": case "tga": case "tif": case "tiff": case "wmf": case "psd": case "exr":
                case "hdr":
                    return EditorGUIUtility.FindTexture(typeof(Texture));

                case "3df": case "3dm": case "3dmf": case "3ds": case "3dv": case "3dx": case "blend": case "c4d":
                case "lwo": case "lws": case "ma": case "max": case "mb": case "mesh": case "obj": case "vrl":
                case "wrl": case "wrz": case "fbx":
                    return EditorGUIUtility.FindTexture(typeof(Mesh));

                case "dv": case "mp4": case "mpg": case "mpeg": case "m4v": case "ogv": case "vp8": case "webm":
                case "asf": case "asx": case "avi": case "dat": case "divx": case "dvx": case "mlv": case "m2l":
                case "m2t": case "m2ts": case "m2v": case "m4e": case "mjp": case "mov": case "movie":
                case "mp21": case "mpe": case "mpv2": case "ogm": case "qt": case "rm": case "rmvb": case "wmw": case "xvid":
                    return AssetDatabase.GetCachedIcon(fileName) as Texture2D ?? EditorGUIUtility.FindTexture(typeof(VideoClip));

                case "colors": case "gradients":
                case "curves": case "curvesnormalized": case "particlecurves": case "particlecurvessigned": case "particledoublecurves": case "particledoublecurvessigned":
                    return EditorGUIUtility.FindTexture(typeof(ScriptableObject));

                default: return null;
            }
        }

        public static Texture2D GetIconForFile(string fileName)
        {
            return FindIconForFile(fileName) ?? EditorGUIUtility.FindTexture(typeof(DefaultAsset));
        }

        public static string[] GetEditorSettingsList(string prefix, int count)
        {
            ArrayList aList = new ArrayList();

            for (int i = 1; i <= count; i++)
            {
                string str = EditorPrefs.GetString(prefix + i, "defaultValue");

                if (str == "defaultValue")
                    break;

                aList.Add(str);
            }

            return aList.ToArray(typeof(string)) as string[];
        }

        public static void SaveEditorSettingsList(string prefix, string[] aList, int count)
        {
            int i;

            for (i = 0; i < aList.Length; i++)
                EditorPrefs.SetString(prefix + (i + 1), (string)aList[i]);

            for (i = aList.Length + 1; i <= count; i++)
                EditorPrefs.DeleteKey(prefix + i);
        }

        public static string TextAreaForDocBrowser(Rect position, string text, GUIStyle style)
        {
            int id = EditorGUIUtility.GetControlID("TextAreaWithTabHandling".GetHashCode(), FocusType.Keyboard, position);
            var editor = EditorGUI.s_RecycledEditor;
            var evt = Event.current;
            if (editor.IsEditingControl(id) && evt.type == EventType.KeyDown)
            {
                if (evt.character == '\t')
                {
                    editor.Insert('\t');
                    evt.Use();
                    GUI.changed = true;
                    text = editor.text;
                }
                if (evt.character == '\n')
                {
                    editor.Insert('\n');
                    evt.Use();
                    GUI.changed = true;
                    text = editor.text;
                }
            }
            bool dummy;
            text = EditorGUI.DoTextField(editor, id, EditorGUI.IndentedRect(position), text, style, null, out dummy, false, true, false);
            return text;
        }

        public static Camera[] GetSceneViewCameras()
        {
            return SceneView.GetAllSceneCameras();
        }

        public static void ShowGameView()
        {
            WindowLayout.ShowAppropriateViewOnEnterExitPlaymode(true);
        }

        // Multi selection handling. Returns new list of selected instanceIDs
        public static List<int> GetNewSelection(int clickedInstanceID, List<int> allInstanceIDs, List<int> selectedInstanceIDs, int lastClickedInstanceID, bool keepMultiSelection, bool useShiftAsActionKey, bool allowMultiSelection)
        {
            List<int> newSelection = new List<int>();

            bool useShift = Event.current.shift || (EditorGUI.actionKey && useShiftAsActionKey);
            bool useActionKey = EditorGUI.actionKey && !useShiftAsActionKey;
            if (!allowMultiSelection)
                useShift = useActionKey = false;

            // Toggle selected node from selection
            if (useActionKey)
            {
                newSelection.AddRange(selectedInstanceIDs);
                if (newSelection.Contains(clickedInstanceID))
                    newSelection.Remove(clickedInstanceID);
                else
                    newSelection.Add(clickedInstanceID);
            }
            // Select everything between the first selected object and the selected
            else if (useShift)
            {
                if (clickedInstanceID == lastClickedInstanceID)
                {
                    newSelection.AddRange(selectedInstanceIDs);
                    return newSelection;
                }

                int firstIndex;
                int lastIndex;
                if (!GetFirstAndLastSelected(allInstanceIDs, selectedInstanceIDs, out firstIndex, out lastIndex))
                {
                    // We had no selection
                    newSelection.Add(clickedInstanceID);
                    return newSelection;
                }

                int newIndex = -1;
                int prevIndex = -1;
                for (int i = 0; i < allInstanceIDs.Count; ++i)
                {
                    if (allInstanceIDs[i] == clickedInstanceID)
                        newIndex = i;
                    if (lastClickedInstanceID != 0)
                        if (allInstanceIDs[i] == lastClickedInstanceID)
                            prevIndex = i;
                }

                System.Diagnostics.Debug.Assert(newIndex != -1); // new item should be part of visible folder set
                int dir = 0;
                if (prevIndex != -1)
                    dir = (newIndex > prevIndex) ? 1 : -1;

                int from, to;
                if (newIndex > lastIndex)
                {
                    from = firstIndex;
                    to = newIndex;
                }
                else if (newIndex >= firstIndex && newIndex < lastIndex)
                {
                    if (dir > 0)
                    {
                        from = newIndex;
                        to = lastIndex;
                    }
                    else
                    {
                        from = firstIndex;
                        to = newIndex;
                    }
                }
                else
                {
                    from = newIndex;
                    to = lastIndex;
                }

                // Outcomment to debug
                //Debug.Log (clickedInstanceID + ",   firstIndex " + firstIndex + ", lastIndex " + lastIndex + ",    newIndex " + newIndex + " " + ", lastClickedIndex " + prevIndex + ",     from " + from + ", to " + to);

                for (int i = from; i <= to; ++i)
                    newSelection.Add(allInstanceIDs[i]);
            }
            // Just set the selection to the clicked object
            else
            {
                if (keepMultiSelection)
                {
                    // Don't change selection on mouse down when clicking on selected item.
                    // This is for dragging in case with multiple items selected or right click (mouse down should not unselect the rest).
                    if (selectedInstanceIDs.Contains(clickedInstanceID))
                    {
                        newSelection.AddRange(selectedInstanceIDs);
                        return newSelection;
                    }
                }

                newSelection.Add(clickedInstanceID);
            }

            return newSelection;
        }

        static bool GetFirstAndLastSelected(List<int> allInstanceIDs, List<int> selectedInstanceIDs, out int firstIndex, out int lastIndex)
        {
            firstIndex = -1;
            lastIndex = -1;
            for (int i = 0; i < allInstanceIDs.Count; ++i)
            {
                if (selectedInstanceIDs.Contains(allInstanceIDs[i]))
                {
                    if (firstIndex == -1)
                        firstIndex = i;
                    lastIndex = i; // just overwrite and we will have the last in the end...
                }
            }
            return firstIndex != -1 && lastIndex != -1;
        }

        internal static string GetApplicationExtensionForRuntimePlatform(RuntimePlatform platform)
        {
            switch (platform)
            {
                case RuntimePlatform.OSXEditor:
                    return "app";
                case RuntimePlatform.WindowsEditor:
                    return "exe";
                default:
                    break;
            }
            return string.Empty;
        }

        public static bool IsValidFileName(string filename)
        {
            string validFileName = RemoveInvalidCharsFromFileName(filename, false);
            if (validFileName != filename || string.IsNullOrEmpty(validFileName))
                return false;
            return true;
        }

        public static string RemoveInvalidCharsFromFileName(string filename, bool logIfInvalidChars)
        {
            if (string.IsNullOrEmpty(filename))
                return filename;

            filename = filename.Trim(); // remove leading and trailing white spaces
            if (string.IsNullOrEmpty(filename))
                return filename;

            string invalidChars = new string(System.IO.Path.GetInvalidFileNameChars());
            string legal = "";
            bool hasInvalidChar = false;
            foreach (char c in filename)
            {
                if (invalidChars.IndexOf(c) == -1)
                    legal += c;
                else
                    hasInvalidChar = true;
            }
            if (hasInvalidChar && logIfInvalidChars)
            {
                string invalid = GetDisplayStringOfInvalidCharsOfFileName(filename);
                if (invalid.Length > 0)
                    Debug.LogWarningFormat("A filename cannot contain the following character{0}:  {1}", invalid.Length > 1 ? "s" : "", invalid);
            }

            return legal;
        }

        public static string GetDisplayStringOfInvalidCharsOfFileName(string filename)
        {
            if (string.IsNullOrEmpty(filename))
                return "";

            string invalid = new string(System.IO.Path.GetInvalidFileNameChars());

            string illegal = "";
            foreach (char c in filename)
            {
                if (invalid.IndexOf(c) >= 0)
                {
                    if (illegal.IndexOf(c) == -1)
                    {
                        if (illegal.Length > 0)
                            illegal += " ";
                        illegal += c;
                    }
                }
            }
            return illegal;
        }

        internal static bool IsScriptOrAssembly(string filename)
        {
            if (string.IsNullOrEmpty(filename))
                return false;

            switch (System.IO.Path.GetExtension(filename).ToLower())
            {
                case ".cs":
                case ".js":
                case ".boo":
                    return true;
                case ".dll":
                case ".exe":
                    return AssemblyHelper.IsManagedAssembly(filename);
                default:
                    return false;
            }
        }

        internal static T ParentHasComponent<T>(Transform trans) where T : Component
        {
            if (trans != null)
            {
                T comp = trans.GetComponent<T>();
                if (comp)
                    return comp;

                return ParentHasComponent<T>(trans.parent);
            }
            return null;
        }

        internal static IEnumerable<string> GetAllScriptGUIDs()
        {
            return AssetDatabase.GetAllAssetPaths()
                .Where(asset => (IsScriptOrAssembly(asset) && !UnityEditor.PackageManager.Folders.IsPackagedAssetPath(asset)))
                .Select(asset => AssetDatabase.AssetPathToGUID(asset));
        }

        // Do not remove. Called through reflection by Visual Studio Tools for Unity.
        internal static UnityEditor.Scripting.MonoIsland[] GetMonoIslandsForPlayer()
        {
            var group = EditorUserBuildSettings.activeBuildTargetGroup;
            var target = EditorUserBuildSettings.activeBuildTarget;

            PrecompiledAssembly[] unityAssemblies = GetUnityAssemblies(false, group, target);

            PrecompiledAssembly[] allPrecompiledAssemblies = GetPrecompiledAssemblies(false, @group, target);
            return EditorCompilationInterface.Instance.GetAllMonoIslands(unityAssemblies, allPrecompiledAssemblies, EditorScriptCompilationOptions.BuildingEmpty | EditorScriptCompilationOptions.BuildingIncludingTestAssemblies);
        }

        // Do not remove. Called through reflection by Visual Studio Tools for Unity.
        // Use EditorCompilationInterface.GetAllMonoIslands internally instead of this method.
        internal static UnityEditor.Scripting.MonoIsland[] GetMonoIslands()
        {
            return EditorCompilationInterface.GetAllMonoIslands();
        }

        internal static string[] GetCompilationDefinesForPlayer()
        {
            var group = EditorUserBuildSettings.activeBuildTargetGroup;
            var target = EditorUserBuildSettings.activeBuildTarget;
            return GetCompilationDefines(EditorScriptCompilationOptions.BuildingEmpty, group, target);
        }

        internal static string GetMonolithicEngineAssemblyPath()
        {
            // We still build a monolithic UnityEngine.dll as a compilation target for user projects.
            // It lives next to the editor dll.
            var dir = Path.GetDirectoryName(GetEditorAssemblyPath());
            return Path.Combine(dir, "UnityEngine.dll");
        }

        internal static string[] GetCompilationDefines(EditorScriptCompilationOptions options, BuildTargetGroup targetGroup, BuildTarget target)
        {
            return GetCompilationDefines(options, targetGroup, target, PlayerSettings.GetApiCompatibilityLevel(targetGroup));
        }
    }
}
