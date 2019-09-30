// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using System;
using UnityEditor.Scripting.ScriptCompilation;
using UnityEngine;
using UnityEngine.Bindings;
using UnityEngine.SceneManagement;
using UnityEditor.SceneManagement;
using Object = UnityEngine.Object;

namespace UnityEditor
{
    // Main Application class.
    [NativeHeader("Editor/Mono/EditorApplication.bindings.h")]
    [NativeHeader("Editor/Src/ScriptCompilation/ScriptCompilationPipeline.h")]
    [NativeHeader("Runtime/BaseClasses/TagManager.h")]
    [NativeHeader("Runtime/Camera/RenderSettings.h")]
    [NativeHeader("Runtime/Input/TimeManager.h")]
    [StaticAccessor("EditorApplicationBindings", StaticAccessorType.DoubleColon)]
    public sealed partial class EditorApplication
    {
        // Load the level at /path/ in play mode.
        [Obsolete("Use EditorSceneManager.LoadSceneInPlayMode instead.")]
        public static void LoadLevelInPlayMode(string path)
        {
            LoadSceneParameters parameters = new LoadSceneParameters {loadSceneMode = LoadSceneMode.Single};
            EditorSceneManager.LoadSceneInPlayMode(path, parameters);
        }

        // Load the level at /path/ additively in play mode.
        [Obsolete("Use EditorSceneManager.LoadSceneInPlayMode instead.")]
        public static void LoadLevelAdditiveInPlayMode(string path)
        {
            LoadSceneParameters parameters = new LoadSceneParameters {loadSceneMode = LoadSceneMode.Additive};
            EditorSceneManager.LoadSceneInPlayMode(path, parameters);
        }

        // Load the level at /path/ in play mode asynchronously.
        [Obsolete("Use EditorSceneManager.LoadSceneAsyncInPlayMode instead.")]
        public static AsyncOperation LoadLevelAsyncInPlayMode(string path)
        {
            LoadSceneParameters parameters = new LoadSceneParameters {loadSceneMode = LoadSceneMode.Single};
            return EditorSceneManager.LoadSceneAsyncInPlayMode(path, parameters);
        }

        // Load the level at /path/ additively in play mode asynchronously.
        [Obsolete("Use EditorSceneManager.LoadSceneAsyncInPlayMode instead.")]
        public static AsyncOperation LoadLevelAdditiveAsyncInPlayMode(string path)
        {
            LoadSceneParameters parameters = new LoadSceneParameters {loadSceneMode = LoadSceneMode.Additive};
            return EditorSceneManager.LoadSceneAsyncInPlayMode(path, parameters);
        }

        // Open another project.
        public static void OpenProject(string projectPath, params string[] args)
        {
            OpenProjectInternal(projectPath, args);
        }

        private static extern void OpenProjectInternal(string projectPath, string[] args);

        // Saves all serializable assets that have not yet been written to disk (eg. Materials)
        [System.Obsolete("Use AssetDatabase.SaveAssets instead (UnityUpgradable) -> AssetDatabase.SaveAssets()", true)]
        public static extern  void SaveAssets();

        // Is editor currently in play mode?
        public static extern bool isPlaying
        {
            get;
            set;
        }

        // Is editor either currently in play mode, or about to switch to it? (RO)
        [StaticAccessor("GetApplication()", StaticAccessorType.Dot)]
        public static extern bool isPlayingOrWillChangePlaymode
        {
            [NativeMethod("IsPlayingOrWillEnterExitPlaymode")]
            get;
        }

        // Perform a single frame step.
        [StaticAccessor("GetApplication().GetPlayerLoopController()", StaticAccessorType.Dot)]
        public static extern void Step();

        // Is editor currently paused?
        [StaticAccessor("GetApplication().GetPlayerLoopController()", StaticAccessorType.Dot)]
        public static extern bool isPaused
        {
            [NativeMethod("IsPaused")]
            get;
            [NativeMethod("SetPaused")]
            set;
        }

        // Is editor currently compiling scripts? (RO)
        public static bool isCompiling
        {
            get
            {
                return EditorCompilationInterface.IsCompiling();
            }
        }

        // Is editor currently updating? (RO)
        public static extern bool isUpdating
        {
            get;
        }

        // Is remote connected to a client app?
        public static extern bool isRemoteConnected
        {
            get;
        }

        [StaticAccessor("ScriptingManager", StaticAccessorType.DoubleColon)]
        public static extern ScriptingRuntimeVersion scriptingRuntimeVersion
        {
            get;
        }

        [StaticAccessor("ScriptingManager", StaticAccessorType.DoubleColon)]
        internal static extern bool useLibmonoBackendForIl2cpp
        {
            [NativeName("UseLibmonoBackendForIl2cpp")]
            get;
        }

        // Prevents loading of assemblies when it is inconvenient.
        [StaticAccessor("GetApplication()", StaticAccessorType.Dot)]
        public static extern void LockReloadAssemblies();

        //  Must be called after LockReloadAssemblies, to reenable loading of assemblies.
        [StaticAccessor("GetApplication()", StaticAccessorType.Dot)]
        public static extern void UnlockReloadAssemblies();

        //  Check if assemblies are unlocked.
        [StaticAccessor("GetApplication()", StaticAccessorType.Dot)]
        internal static extern bool CanReloadAssemblies();

        // Invokes the menu item in the specified path.
        public static extern  bool ExecuteMenuItem(string menuItemPath);

        // Like ExecuteMenuItem, but applies action to specified GameObjects if the menu action supports it.
        internal static extern  bool ExecuteMenuItemOnGameObjects(string menuItemPath, GameObject[] objects);

        // Like ExecuteMenuItem, but applies action to specified GameObjects if the menu action supports it.
        internal static extern  bool ExecuteMenuItemWithTemporaryContext(string menuItemPath, Object[] objects);

        // Path to the Unity editor contents folder (RO)
        [ThreadAndSerializationSafe]
        public static extern string applicationContentsPath
        {
            [FreeFunction("GetApplicationContentsPath", IsThreadSafe = true)]
            get;
        }

        // Returns the path to the Unity editor application (RO)
        public static extern string applicationPath
        {
            [FreeFunction("GetApplicationPath")]
            get;
        }

        internal static extern string userJavascriptPackagesPath
        {
            get;
        }

        public static extern bool isTemporaryProject
        {
            [FreeFunction("IsTemporaryProject")]
            get;
        }

        [NativeThrows]
        public static extern void SetTemporaryProjectKeepPath(string path);

        // Exit the Unity editor application.
        public static extern void Exit(int returnValue);

        [StaticAccessor("GetApplication()", StaticAccessorType.Dot)]
        internal static extern void SetSceneRepaintDirty();

        public static void QueuePlayerLoopUpdate() { SetSceneRepaintDirty(); }

        internal static extern void UpdateSceneIfNeeded();

        // Plays system beep sound.
        [FreeFunction("UnityBeep")]
        public static extern void Beep();

        internal static extern Object tagManager
        {
            [FreeFunction]
            get;
        }

        internal static extern Object renderSettings
        {
            [FreeFunction]
            get;
        }

        // The time since the editor was started (RO)
        public static extern double timeSinceStartup
        {
            [FreeFunction]
            get;
        }

        internal static extern void CloseAndRelaunch(string[] arguments);
    }
}
