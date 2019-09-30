// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using UnityEditor.Modules;
using UnityEditor.Build;
using UnityEngine;
using UnityEditorInternal;
using UnityEditor.Experimental;
using UnityEditor.Scripting.ScriptCompilation;
using System.Collections;
using System.IO;
using System;
using UnityEditor.Build.Reporting;
using UnityEditor.Connect;

namespace UnityEditor
{
    public partial class BuildPlayerWindow : EditorWindow
    {
        static Func<BuildPlayerOptions, BuildPlayerOptions> getBuildPlayerOptionsHandler;
        static Action<BuildPlayerOptions> buildPlayerHandler;
        static bool m_Building = false;
        internal static Action<BuildReport> buildCompletionHandler;

        /// <summary>
        /// Exception thrown when an abort or error condition is reached within a build method delegate.
        /// </summary>
        public class BuildMethodException : System.Exception
        {
            /// <summary>
            /// Constructor for aborting a method without displaying an error.
            /// </summary>
            public BuildMethodException() : base("") {}

            /// <summary>
            /// Constructor for aborting on error that will print the log the given message as an error.
            /// </summary>
            /// <param name="message"></param>
            public BuildMethodException(string message) : base(message) {}
        }

        /// <summary>
        /// Register a delegate method to calculate BuildPlayerOptions that are passed to the build process.
        /// </summary>
        /// <param name="func">Delegate method</param>
        public static void RegisterGetBuildPlayerOptionsHandler(Func<BuildPlayerOptions, BuildPlayerOptions> func)
        {
            // Display a warning if user scripts try to register this delegate multiple times
            if (func != null && getBuildPlayerOptionsHandler != null)
                Debug.LogWarning("The get build player options handler in BuildPlayerWindow is being reassigned!");

            getBuildPlayerOptionsHandler = func;
        }

        /// <summary>
        /// Register a delegate method to execute a player build process.
        /// </summary>
        /// <param name="func">Delegate method</param>
        public static void RegisterBuildPlayerHandler(Action<BuildPlayerOptions> func)
        {
            // Display a warning if user scripts try to register this delegate multiple times
            if (func != null && buildPlayerHandler != null)
                Debug.LogWarning("The build player handler in BuildPlayerWindow is being reassigned!");

            buildPlayerHandler = func;
        }

        /// <summary>
        /// Method called by the UI when the "Build" or "Build and Run" buttons are pressed.
        /// </summary>
        /// <param name="defaultBuildOptions"></param>
        static void CallBuildMethods(bool askForBuildLocation, BuildOptions defaultBuildOptions)
        {
            if (EditorCompilationInterface.IsCompiling())
            {
                Debug.LogWarning("Cannot build player while editor is compiling scripts.");
                return;
            }

            // One build at a time!
            if (m_Building)
                return;
            try
            {
                m_Building = true;
                BuildPlayerOptions options = new BuildPlayerOptions();
                options.options = defaultBuildOptions;

                if (getBuildPlayerOptionsHandler != null)
                    options = getBuildPlayerOptionsHandler(options);
                else
                    options = DefaultBuildMethods.GetBuildPlayerOptionsInternal(askForBuildLocation, options);

                if (buildPlayerHandler != null)
                    buildPlayerHandler(options);
                else
                    DefaultBuildMethods.BuildPlayer(options);
            }
            catch (BuildMethodException e)
            {
                if (!string.IsNullOrEmpty(e.Message))
                    Debug.LogError(e);
            }
            finally
            {
                m_Building = false;
            }
        }

        /// <summary>
        /// Default (legacy) implementation of player window build methods.
        /// </summary>
        public static class DefaultBuildMethods
        {
            /// <summary>
            /// Default implementation of the build player method.
            /// </summary>
            /// <param name="options"></param>
            public static void BuildPlayer(BuildPlayerOptions options)
            {
                if (!UnityConnect.instance.canBuildWithUPID)
                {
                    if (!EditorUtility.DisplayDialog("Missing Project ID", "Because you are not a member of this project this build will not access Unity services.\nDo you want to continue?", "Yes", "No"))
                        throw new BuildMethodException();
                }

                if (!BuildPipeline.IsBuildTargetSupported(options.targetGroup, options.target))
                    throw new BuildMethodException("Build target is not supported.");

                string module = ModuleManager.GetTargetStringFrom(EditorUserBuildSettings.selectedBuildTargetGroup, options.target);
                IBuildWindowExtension buildWindowExtension = ModuleManager.GetBuildWindowExtension(module);
                if (buildWindowExtension != null && (options.options & BuildOptions.AutoRunPlayer) != 0 && !buildWindowExtension.EnabledBuildAndRunButton())
                    throw new BuildMethodException();

                if (Unsupported.IsBleedingEdgeBuild())
                {
                    var sb = new System.Text.StringBuilder();
                    sb.AppendLine("This version of Unity is a BleedingEdge build that has not seen any manual testing.");
                    sb.AppendLine("You should consider this build unstable.");
                    sb.AppendLine("We strongly recommend that you use a normal version of Unity instead.");

                    if (EditorUtility.DisplayDialog("BleedingEdge Build", sb.ToString(), "Cancel", "OK"))
                        throw new BuildMethodException();
                }

                // See if we need to switch platforms and delay the build.  We do this whenever
                // we're trying to build for a target different from the active one so as to ensure
                // that the compiled script code we have loaded is built for the same platform we
                // are building for.  As we can't reload while our editor stuff is still executing,
                // we need to defer to after the next script reload then.
                bool delayToAfterScriptReload = false;
                if (EditorUserBuildSettings.activeBuildTarget != options.target ||
                    EditorUserBuildSettings.activeBuildTargetGroup != options.targetGroup)
                {
                    if (!EditorUserBuildSettings.SwitchActiveBuildTargetAsync(options.targetGroup, options.target))
                    {
                        // Switching the build target failed.  No point in trying to continue
                        // with a build.
                        var errStr = string.Format("Could not switch to build target '{0}', '{1}'.",
                            BuildPipeline.GetBuildTargetGroupDisplayName(options.targetGroup),
                            BuildPlatforms.instance.GetBuildTargetDisplayName(options.targetGroup, options.target));
                        throw new BuildMethodException(errStr);
                    }

                    if (EditorApplication.isCompiling)
                        delayToAfterScriptReload = true;
                }

                // Trigger build.
                // Note: report will be null, if delayToAfterScriptReload = true
                var report = BuildPipeline.BuildPlayerInternalNoCheck(options.scenes, options.locationPathName, null, options.targetGroup, options.target, options.options, delayToAfterScriptReload);


                if (report != null)
                {
                    var resultStr = String.Format("Build completed with a result of '{0}'", report.summary.result.ToString("g"));

                    switch (report.summary.result)
                    {
                        case Build.Reporting.BuildResult.Unknown:
                            Debug.LogWarning(resultStr);
                            break;
                        case Build.Reporting.BuildResult.Failed:
                            DeleteBuildFolderIfEmpty(report.summary.outputPath);
                            Debug.LogError(resultStr);
                            throw new BuildMethodException(report.SummarizeErrors());
                        default:
                            Debug.Log(resultStr);
                            break;
                    }

                    buildCompletionHandler?.Invoke(report);
                }
            }

            /// <summary>
            /// Default implementation for calculating build options before building the player.
            /// </summary>
            /// <param name="defaultBuildPlayerOptions"></param>
            /// <returns></returns>
            public static BuildPlayerOptions GetBuildPlayerOptions(BuildPlayerOptions defaultBuildPlayerOptions)
            {
                return GetBuildPlayerOptionsInternal(true, defaultBuildPlayerOptions);
            }

            internal static bool IsInstallInBuildFolderOption()
            {
                BuildTarget buildTarget = EditorUserBuildSettingsUtils.CalculateSelectedBuildTarget();
                BuildTargetGroup buildTargetGroup = EditorUserBuildSettings.selectedBuildTargetGroup;

                return EditorUserBuildSettings.installInBuildFolder &&
                    PostprocessBuildPlayer.SupportsInstallInBuildFolder(buildTargetGroup, buildTarget) &&
                    (Unsupported.IsSourceBuild() || IsMetroPlayer(buildTarget));
            }

            internal static BuildPlayerOptions GetBuildPlayerOptionsInternal(bool askForBuildLocation, BuildPlayerOptions defaultBuildPlayerOptions)
            {
                var options = defaultBuildPlayerOptions;

                bool updateExistingBuild = false;

                BuildTarget buildTarget = EditorUserBuildSettingsUtils.CalculateSelectedBuildTarget();
                BuildTargetGroup buildTargetGroup = EditorUserBuildSettings.selectedBuildTargetGroup;

                // Pick location for the build
                string newLocation = "";

                //Check if Lz4 is supported for the current buildtargetgroup and enable it if need be
                if (PostprocessBuildPlayer.SupportsLz4Compression(buildTargetGroup, buildTarget))
                {
                    if (EditorUserBuildSettings.GetCompressionType(buildTargetGroup) == Compression.Lz4)
                        options.options |= BuildOptions.CompressWithLz4;
                    else if (EditorUserBuildSettings.GetCompressionType(buildTargetGroup) == Compression.Lz4HC)
                        options.options |= BuildOptions.CompressWithLz4HC;
                }

                bool developmentBuild = EditorUserBuildSettings.development;
                if (developmentBuild)
                    options.options |= BuildOptions.Development;
                if (EditorUserBuildSettings.datalessPlayer && developmentBuild)
                    options.options |= BuildOptionsExperimental.DatalessPlayer;
                if (EditorUserBuildSettings.allowDebugging && developmentBuild)
                    options.options |= BuildOptions.AllowDebugging;
                if (EditorUserBuildSettings.symlinkLibraries)
                    options.options |= BuildOptions.SymlinkLibraries;
                if (EditorUserBuildSettings.enableHeadlessMode)
                    options.options |= BuildOptions.EnableHeadlessMode;
                if (EditorUserBuildSettings.connectProfiler && (developmentBuild || buildTarget == BuildTarget.WSAPlayer))
                    options.options |= BuildOptions.ConnectWithProfiler;
                if (EditorUserBuildSettings.buildScriptsOnly)
                    options.options |= BuildOptions.BuildScriptsOnly;

                if (IsInstallInBuildFolderOption())
                {
                    options.options |= BuildOptions.InstallInBuildFolder;
                }
                else
                {
                    if (askForBuildLocation && !PickBuildLocation(buildTargetGroup, buildTarget, options.options, out updateExistingBuild))
                        throw new BuildMethodException();

                    newLocation = EditorUserBuildSettings.GetBuildLocation(buildTarget);

                    if (newLocation.Length == 0)
                    {
                        throw new BuildMethodException("Build location for buildTarget " + buildTarget.ToString() + "is not valid.");
                    }

                    if (!askForBuildLocation)
                    {
                        switch (UnityEditorInternal.InternalEditorUtility.BuildCanBeAppended(buildTarget, newLocation))
                        {
                            case CanAppendBuild.Unsupported:
                                break;
                            case CanAppendBuild.Yes:
                                updateExistingBuild = true;
                                break;
                            case CanAppendBuild.No:
                                if (!PickBuildLocation(buildTargetGroup, buildTarget, options.options, out updateExistingBuild))
                                    throw new BuildMethodException();

                                newLocation = EditorUserBuildSettings.GetBuildLocation(buildTarget);
                                if (!BuildLocationIsValid(newLocation))
                                    throw new BuildMethodException("Build location for buildTarget " + buildTarget.ToString() + "is not valid.");

                                break;
                        }
                    }
                }

                if (updateExistingBuild)
                    options.options |= BuildOptions.AcceptExternalModificationsToPlayer;

                options.target = buildTarget;
                options.targetGroup = buildTargetGroup;
                options.locationPathName = EditorUserBuildSettings.GetBuildLocation(buildTarget);
                options.assetBundleManifestPath = null;

                // Build a list of scenes that are enabled
                ArrayList scenesList = new ArrayList();
                EditorBuildSettingsScene[] editorScenes = EditorBuildSettings.scenes;
                foreach (EditorBuildSettingsScene scene in editorScenes)
                {
                    if (scene.enabled)
                        scenesList.Add(scene.path);
                }

                options.scenes = scenesList.ToArray(typeof(string)) as string[];

                return options;
            }

            static bool PickBuildLocation(BuildTargetGroup targetGroup, BuildTarget target, BuildOptions options, out bool updateExistingBuild)
            {
                updateExistingBuild = false;
                var previousPath = EditorUserBuildSettings.GetBuildLocation(target);

                string defaultFolder;
                string defaultName;
                if (previousPath == String.Empty)
                {
                    defaultFolder = FileUtil.DeleteLastPathNameComponent(Application.dataPath);
                    defaultName = "";
                }
                else
                {
                    defaultFolder = FileUtil.DeleteLastPathNameComponent(previousPath);
                    defaultName = FileUtil.GetLastPathNameComponent(previousPath);
                }

                string extension = PostprocessBuildPlayer.GetExtensionForBuildTarget(targetGroup, target, options);
                // Invalidate default name, if extension mismatches the default file (for ex., when switching between folder type export to file type export, see Android)
                if (extension != Path.GetExtension(defaultName).Replace(".", ""))
                    defaultName = string.Empty;

                // Hack: For Windows Standalone, we want the BuildPanel to choose a folder,
                // but we don't want BuildPlayer to take a folder path because historically it took an .exe path
                // and we would be breaking tons of projects!
                bool isWindowsStandalone = target == BuildTarget.StandaloneWindows || target == BuildTarget.StandaloneWindows64;
                string realExtension = extension;
                if (isWindowsStandalone)
                {
                    extension = string.Empty;
                    // Remove the filename.exe part from the path
                    if (!string.IsNullOrEmpty(defaultName))
                        defaultName = Path.GetDirectoryName(defaultName);
                }

                string title = "Build " + BuildPlatforms.instance.GetBuildTargetDisplayName(targetGroup, target);
                string path = EditorUtility.SaveBuildPanel(target, title, defaultFolder, defaultName, extension, out updateExistingBuild);

                if (path == string.Empty)
                    return false;

                if (isWindowsStandalone)
                {
                    extension = realExtension;
                    path = Path.Combine(path, PlayerSettings.productName + '.' + extension);
                }

                if (!IsBuildPathValid(path))
                    return false;

                // Enforce extension if needed
                if (extension != string.Empty && FileUtil.GetPathExtension(path).ToLower() != extension)
                    path += '.' + extension;

                // A path may not be empty initially, but it could contain, e.g., a drive letter (as in Windows),
                // so even appending an extention will work fine, but in reality the name will be, for example,
                // G:/
                //Debug.Log(path);

                string currentlyChosenName = FileUtil.GetLastPathNameComponent(path);
                if (currentlyChosenName == string.Empty)
                    return false; // No nameless projects, please

                // We don't want to re-create a directory that already exists, this may
                // result in access-denials that will make users unhappy.
                string check_dir = extension != string.Empty ? FileUtil.DeleteLastPathNameComponent(path) : path;
                if (!Directory.Exists(check_dir))
                    Directory.CreateDirectory(check_dir);

                // On OSX we've got replace/update dialog, for other platforms warn about deleting
                // files in target folder.
                if ((target == BuildTarget.iOS) && (Application.platform != RuntimePlatform.OSXEditor))
                    if (!FolderIsEmpty(path) && !UserWantsToDeleteFiles(path))
                        return false;

                EditorUserBuildSettings.SetBuildLocation(target, path);
                return true;
            }

            private static string NormalizePath(string path)
            {
                var fullPath = path;
                if (fullPath.Length > 1 && fullPath[fullPath.Length - 1] == '.' && fullPath[fullPath.Length - 2] != '.')
                    fullPath = fullPath.Remove(fullPath.Length - 1);

                if (fullPath.EndsWith("/") || fullPath.EndsWith("\\"))
                    fullPath = fullPath.Remove(fullPath.Length - 1);

                fullPath = string.IsNullOrEmpty(fullPath) ? string.Empty : Path.GetFullPath(fullPath);

                fullPath = fullPath.ToLower();
                if (Path.DirectorySeparatorChar == '/')
                    return fullPath;
                return fullPath.Replace(Path.DirectorySeparatorChar, '/');
            }

            internal static bool IsBuildPathValid(string path)
            {
                var cleanedPath = NormalizePath(path);
                if (cleanedPath.Equals(string.Empty) &&
                    IsInstallInBuildFolderOption())
                    return true;

                var basePath = NormalizePath(Application.dataPath + "/../");

                var assetsPath = NormalizePath(basePath + "/Assets");
                var settingsPath = NormalizePath(basePath + "/ProjectSettings");
                var tempPath = NormalizePath(basePath + "/Temp");
                var libraryPath = NormalizePath(basePath + "/Library");
                if (basePath.Contains(cleanedPath) || cleanedPath == assetsPath || cleanedPath == settingsPath || cleanedPath == tempPath || cleanedPath == libraryPath)
                {
                    Debug.LogError("Invalid build path: " + cleanedPath);
                    return false;
                }

                return true;
            }

            static void DeleteBuildFolderIfEmpty(string path)
            {
                if (Directory.Exists(path) && FolderIsEmpty(path))
                    Directory.Delete(path);
            }

            static bool FolderIsEmpty(string path)
            {
                if (!Directory.Exists(path))
                    return true;

                return (Directory.GetDirectories(path).Length == 0)
                    && (Directory.GetFiles(path).Length == 0);
            }

            static bool UserWantsToDeleteFiles(string path)
            {
                string text =
                    "WARNING: all files and folders located in target folder: '" + path + "' will be deleted by build process.";
                return EditorUtility.DisplayDialog("Deleting existing files", text, "OK", "Cancel");
            }

            static bool IsMetroPlayer(BuildTarget target)
            {
                return target == BuildTarget.WSAPlayer;
            }
        }
    }
}
