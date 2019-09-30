// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security;
using System.Security.Cryptography;
using System.Xml;
using System.Text;
using System.Text.RegularExpressions;

using UnityEditor.Scripting;
using UnityEditor.Scripting.ScriptCompilation;
using UnityEditor.Utils;
using UnityEditorInternal;
using UnityEditor.Scripting.Compilers;

using UnityEditor.Compilation;
using UnityEditor.Modules;

namespace UnityEditor.VisualStudioIntegration
{
    enum ScriptingLanguage
    {
        None,
        Boo,
        CSharp,
        UnityScript,
    }

    class SolutionSynchronizer
    {
        enum Mode
        {
            UnityScriptAsUnityProj,
            UnityScriptAsPrecompiledAssembly
        }

        public static readonly ISolutionSynchronizationSettings DefaultSynchronizationSettings =
            new DefaultSolutionSynchronizationSettings();

        static readonly string WindowsNewline = "\r\n";

        /// <summary>
        /// Map source extensions to ScriptingLanguages
        /// </summary>
        static internal readonly Dictionary<string, ScriptingLanguage> BuiltinSupportedExtensions = new Dictionary<string, ScriptingLanguage>
        {
            {"cs", ScriptingLanguage.CSharp},
            {"uxml", ScriptingLanguage.None},
            {"uss", ScriptingLanguage.None},
            {"shader", ScriptingLanguage.None},
            {"compute", ScriptingLanguage.None},
            {"cginc", ScriptingLanguage.None},
            {"hlsl", ScriptingLanguage.None},
            {"glslinc", ScriptingLanguage.None},
            {"template", ScriptingLanguage.None},
        };

        private static readonly string[] reimportSyncExtensions = new[] { ".dll", ".asmdef" };

        string[] ProjectSupportedExtensions = new string[0];

        /// <summary>
        /// Map ScriptingLanguages to project extensions
        /// </summary>
        static readonly Dictionary<ScriptingLanguage, string> ProjectExtensions = new Dictionary<ScriptingLanguage, string>
        {
            { ScriptingLanguage.Boo, ".booproj" },
            { ScriptingLanguage.CSharp, ".csproj" },
            { ScriptingLanguage.UnityScript, ".unityproj" },
            { ScriptingLanguage.None, ".csproj" },
        };

        static readonly Regex _MonoDevelopPropertyHeader = new Regex(@"^\s*GlobalSection\(MonoDevelopProperties.*\)");
        public static readonly string MSBuildNamespaceUri = "http://schemas.microsoft.com/developer/msbuild/2003";

        private readonly string _projectDirectory;
        private readonly ISolutionSynchronizationSettings _settings;
        private readonly string _projectName;


        private static readonly string DefaultMonoDevelopSolutionProperties = string.Join("\r\n", new[]
        {
            "    GlobalSection(MonoDevelopProperties) = preSolution",
            "        StartupItem = Assembly-CSharp.csproj",
            "    EndGlobalSection",
        }).Replace("    ", "\t");

        public SolutionSynchronizer(string projectDirectory, ISolutionSynchronizationSettings settings)
        {
            _projectDirectory = projectDirectory.ConvertSeparatorsToUnity();
            _settings = settings;
            _projectName = Path.GetFileName(_projectDirectory);
        }

        public SolutionSynchronizer(string projectDirectory) : this(projectDirectory, DefaultSynchronizationSettings)
        {
        }

        private void SetupProjectSupportedExtensions()
        {
            ProjectSupportedExtensions = EditorSettings.projectGenerationUserExtensions;
        }

        public bool ShouldFileBePartOfSolution(string file)
        {
            string extension = Path.GetExtension(file);

            // Exclude files coming from packages except if they are internalized.
            if (IsNonInternalizedPackagePath(file))
            {
                return false;
            }

            // Dll's are not scripts but still need to be included..
            if (extension == ".dll")
                return true;

            if (file.ToLower().EndsWith(".asmdef"))
                return true;

            return IsSupportedExtension(extension);
        }

        private bool IsSupportedExtension(string extension)
        {
            extension = extension.TrimStart('.');
            if (BuiltinSupportedExtensions.ContainsKey(extension))
                return true;
            if (ProjectSupportedExtensions.Contains(extension))
                return true;
            return false;
        }

        private static ScriptingLanguage ScriptingLanguageFor(MonoIsland island)
        {
            return ScriptingLanguageFor(island.GetExtensionOfSourceFiles());
        }

        private static ScriptingLanguage ScriptingLanguageFor(string extension)
        {
            ScriptingLanguage result;
            if (BuiltinSupportedExtensions.TryGetValue(extension.TrimStart('.'), out result))
                return result;

            return ScriptingLanguage.None;
        }

        public bool ProjectExists(MonoIsland island)
        {
            return File.Exists(ProjectFile(island));
        }

        public bool SolutionExists()
        {
            return File.Exists(SolutionFile());
        }

        private static void DumpIsland(MonoIsland island)
        {
            Console.WriteLine("{0} ({1})", island._output, island._api_compatibility_level);
            Console.WriteLine("Files: ");
            Console.WriteLine(string.Join("\n", island._files));
            Console.WriteLine("References: ");
            Console.WriteLine(string.Join("\n", island._references));
            Console.WriteLine("");
        }

        /// <summary>
        /// Syncs the scripting solution if any affected files are relevant.
        /// </summary>
        /// <returns>
        /// Whether the solution was synced.
        /// </returns>
        /// <param name='affectedFiles'>
        /// A set of files whose status has changed
        /// </param>
        /// <param name="reimportedFiles">
        /// A set of files that got reimported
        /// </param>
        public bool SyncIfNeeded(IEnumerable<string> affectedFiles, IEnumerable<string> reimportedFiles)
        {
            SetupProjectSupportedExtensions();

            // Don't sync if we haven't synced before
            if (SolutionExists() && (affectedFiles.Any(ShouldFileBePartOfSolution) || reimportedFiles.Any(ShouldSyncOnReimportedAsset)))
            {
                Sync();
                return true;
            }

            return false;
        }

        private bool ShouldSyncOnReimportedAsset(string asset)
        {
            return reimportSyncExtensions.Contains(new FileInfo(asset).Extension);
        }

        public void Sync()
        {
            // Do not sync solution until all Unity extensions are registered and initialized.
            // Otherwise Unity might emit errors when VSTU tries to generate the solution and
            // get all managed extensions, which not yet initialized.
            if (!InternalEditorUtility.IsUnityExtensionsInitialized())
                return;

            SetupProjectSupportedExtensions();

            bool externalCodeAlreadyGeneratedProjects = AssetPostprocessingInternal.OnPreGeneratingCSProjectFiles();

            if (!externalCodeAlreadyGeneratedProjects)
            {
                var scriptEditor = ScriptEditorUtility.GetScriptEditorFromPreferences();
                GenerateAndWriteSolutionAndProjects(scriptEditor);
            }

            AssetPostprocessingInternal.CallOnGeneratedCSProjectFiles();
        }

        internal void GenerateAndWriteSolutionAndProjects(ScriptEditorUtility.ScriptEditor scriptEditor)
        {
            // Only synchronize islands that have associated source files and ones that we actually want in the project.
            // This also filters out DLLs coming from .asmdef files in packages.
            IEnumerable<MonoIsland> islands = EditorCompilationInterface.Instance.GetAllScriptAssemblies(EditorScriptCompilationOptions.BuildingForEditor | EditorCompilationInterface.GetAdditionalEditorScriptCompilationOptions())
                .Where(i => 0 < i.Files.Length && i.Files.Any(ShouldFileBePartOfSolution))
                .Select(x => x.ToMonoIsland(EditorScriptCompilationOptions.BuildingForEditor, string.Empty, _projectDirectory)).ToList();

            var allAssetProjectParts = GenerateAllAssetProjectParts();

            var monoIslands = islands.ToList();

            SyncSolution(monoIslands);
            var allProjectIslands = RelevantIslandsForMode(monoIslands, ModeForCurrentExternalEditor()).ToList();

            foreach (MonoIsland island in allProjectIslands)
            {
                SyncProject(island, allAssetProjectParts, ParseResponseFileData(island), allProjectIslands);
            }

            if (scriptEditor == ScriptEditorUtility.ScriptEditor.VisualStudioCode)
                WriteVSCodeSettingsFiles();
        }

        IEnumerable<ScriptCompilerBase.ResponseFileData> ParseResponseFileData(MonoIsland island)
        {
            var scriptAssembly = new ScriptAssembly
            {
                Filename = "Assembly-CSharp.dll",
                Language = ScriptCompilers.CSharpSupportedLanguage,
                Flags = Scripting.ScriptCompilation.AssemblyFlags.None
            };

            var systemReferenceDirectories = CSharpLanguage.GetCSharpCompiler(island._target, true, scriptAssembly) == CSharpCompiler.Microsoft
                && PlayerSettings.GetScriptingBackend(BuildPipeline.GetBuildTargetGroup(island._target)) == ScriptingImplementation.WinRTDotNET && !island._editor
                ? MicrosoftCSharpCompiler.GetClassLibraries(island._target, island._editor)
                : MonoLibraryHelpers.GetSystemReferenceDirectories(island._api_compatibility_level);

            Dictionary<string, ScriptCompilerBase.ResponseFileData> responseFilesData = island._responseFiles.ToDictionary(x => x, x => ScriptCompilerBase.ParseResponseFileFromFile(
                x,
                _projectDirectory,
                systemReferenceDirectories
            ));

            Dictionary<string, ScriptCompilerBase.ResponseFileData> responseFilesWithErrors = responseFilesData.Where(x => x.Value.Errors.Any())
                .ToDictionary(x => x.Key, x => x.Value);

            if (responseFilesWithErrors.Any())
            {
                foreach (var error in responseFilesWithErrors)
                    foreach (var valueError in error.Value.Errors)
                    {
                        UnityEngine.Debug.LogErrorFormat("{0} Parse Error : {1}", error.Key, valueError);
                    }
            }

            return responseFilesData.Select(x => x.Value);
        }

        Dictionary<string, string> GenerateAllAssetProjectParts()
        {
            Dictionary<string, StringBuilder> stringBuilders = new Dictionary<string, StringBuilder>();

            foreach (string asset in AssetDatabase.GetAllAssetPaths())
            {
                // Exclude files coming from packages except if they are internalized.
                if (IsNonInternalizedPackagePath(asset))
                {
                    continue;
                }
                string extension = Path.GetExtension(asset);
                if (IsSupportedExtension(extension) && ScriptingLanguage.None == ScriptingLanguageFor(extension))
                {
                    // Find assembly the asset belongs to by adding script extension and using compilation pipeline.
                    var assemblyName = CompilationPipeline.GetAssemblyNameFromScriptPath(asset + ".cs");
                    assemblyName = assemblyName ?? CompilationPipeline.GetAssemblyNameFromScriptPath(asset + ".js");
                    assemblyName = assemblyName ?? CompilationPipeline.GetAssemblyNameFromScriptPath(asset + ".boo");

                    assemblyName = Path.GetFileNameWithoutExtension(assemblyName);

                    StringBuilder projectBuilder = null;

                    if (!stringBuilders.TryGetValue(assemblyName, out projectBuilder))
                    {
                        projectBuilder = new StringBuilder();
                        stringBuilders[assemblyName] = projectBuilder;
                    }

                    projectBuilder.AppendFormat("     <None Include=\"{0}\" />{1}", EscapedRelativePathFor(asset), WindowsNewline);
                }
            }

            var result = new Dictionary<string, string>();

            foreach (var entry in stringBuilders)
                result[entry.Key] = entry.Value.ToString();

            return result;
        }

        bool IsNonInternalizedPackagePath(string file)
        {
            if (UnityEditor.PackageManager.Folders.IsPackagedAssetPath(file))
            {
                bool rootFolder, readOnly;
                bool validPath = AssetDatabase.GetAssetFolderInfo(file, out rootFolder, out readOnly);
                return (!validPath || readOnly);
            }
            return false;
        }

        void SyncProject(MonoIsland island,
            Dictionary<string, string> allAssetsProjectParts,
            IEnumerable<ScriptCompilerBase.ResponseFileData> responseFilesData,
            List<MonoIsland> allProjectIslands)
        {
            SyncProjectFileIfNotChanged(ProjectFile(island), ProjectText(island, ModeForCurrentExternalEditor(), allAssetsProjectParts, responseFilesData, allProjectIslands));
        }

        static void SyncProjectFileIfNotChanged(string path, string newContents)
        {
            if (Path.GetExtension(path) == ".csproj")
            {
                newContents = AssetPostprocessingInternal.CallOnGeneratedCSProject(path, newContents);
            }

            SyncFileIfNotChanged(path, newContents);
        }

        static void SyncSolutionFileIfNotChanged(string path, string newContents)
        {
            newContents = AssetPostprocessingInternal.CallOnGeneratedSlnSolution(path, newContents);

            SyncFileIfNotChanged(path, newContents);
        }

        private static void SyncFileIfNotChanged(string filename, string newContents)
        {
            if (File.Exists(filename) &&
                newContents == File.ReadAllText(filename))
            {
                return;
            }
            File.WriteAllText(filename, newContents, Encoding.UTF8);
        }

        void WriteVSCodeSettingsFiles()
        {
            string vsCodeDirectory = Path.Combine(_projectDirectory, ".vscode");

            if (!Directory.Exists(vsCodeDirectory))
                Directory.CreateDirectory(vsCodeDirectory);

            string vsCodeSettingsJson = Path.Combine(vsCodeDirectory, "settings.json");

            if (!File.Exists(vsCodeSettingsJson))
                File.WriteAllText(vsCodeSettingsJson, VSCodeTemplates.SettingsJson);
        }

        public static readonly Regex scriptReferenceExpression = new Regex(
            @"^Library.ScriptAssemblies.(?<dllname>(?<project>.*)\.dll$)",
            RegexOptions.Compiled | RegexOptions.IgnoreCase);

        static bool IsAdditionalInternalAssemblyReference(bool isBuildingEditorProject, string reference)
        {
            if (isBuildingEditorProject)
                return Modules.ModuleUtils.GetAdditionalReferencesForEditorCsharpProject().Contains(reference);
            return false;
        }

        string ProjectText(MonoIsland island,
            Mode mode,
            Dictionary<string, string> allAssetsProjectParts,
            IEnumerable<ScriptCompilerBase.ResponseFileData> responseFilesData,
            List<MonoIsland> allProjectIslands)
        {
            var projectBuilder = new StringBuilder(ProjectHeader(island, responseFilesData));
            var references = new List<string>();
            var projectReferences = new List<Match>();
            Match match;
            bool isBuildingEditorProject = island._output.EndsWith("-Editor.dll");

            foreach (string file in island._files)
            {
                if (!ShouldFileBePartOfSolution(file))
                    continue;

                var extension = Path.GetExtension(file).ToLower();
                var fullFile = EscapedRelativePathFor(file);
                if (".dll" != extension)
                {
                    var tagName = "Compile";
                    projectBuilder.AppendFormat("     <{0} Include=\"{1}\" />{2}", tagName, fullFile, WindowsNewline);
                }
                else
                {
                    references.Add(fullFile);
                }
            }

            string additionalAssetsForProject;
            var assemblyName = Path.GetFileNameWithoutExtension(island._output);

            // Append additional non-script files that should be included in project generation.
            if (allAssetsProjectParts.TryGetValue(assemblyName, out additionalAssetsForProject))
                projectBuilder.Append(additionalAssetsForProject);

            var allAdditionalReferenceFilenames = new List<string>();
            var islandRefs = references.Union(island._references);

            foreach (string reference in islandRefs)
            {
                if (reference.EndsWith("/UnityEditor.dll") || reference.EndsWith("/UnityEngine.dll") || reference.EndsWith("\\UnityEditor.dll") || reference.EndsWith("\\UnityEngine.dll"))
                    continue;

                match = scriptReferenceExpression.Match(reference);
                if (match.Success)
                {
                    var language = ScriptCompilers.GetLanguageFromExtension(island.GetExtensionOfSourceFiles());
                    var targetLanguage = (ScriptingLanguage)Enum.Parse(typeof(ScriptingLanguage), language.GetLanguageName(), true);
                    if (mode == Mode.UnityScriptAsUnityProj || ScriptingLanguage.CSharp == targetLanguage)
                    {
                        // Add a reference to a project except if it's a reference to a script assembly
                        // that we are not generating a project for. This will be the case for assemblies
                        // coming from .assembly.json files in non-internalized packages.
                        var dllName = match.Groups["dllname"].Value;
                        if (allProjectIslands.Any(i => Path.GetFileName(i._output) == dllName))
                        {
                            projectReferences.Add(match);
                            continue;
                        }
                    }
                }

                string fullReference = Path.IsPathRooted(reference) ? reference : Path.Combine(_projectDirectory, reference);
                if (!AssemblyHelper.IsManagedAssembly(fullReference))
                    continue;
                if (AssemblyHelper.IsInternalAssembly(fullReference))
                {
                    if (!IsAdditionalInternalAssemblyReference(isBuildingEditorProject, fullReference))
                        continue;
                    var referenceName = Path.GetFileName(fullReference);
                    if (allAdditionalReferenceFilenames.Contains(referenceName))
                        continue;
                    allAdditionalReferenceFilenames.Add(referenceName);
                }

                AppendReference(fullReference, projectBuilder);
            }

            var responseRefs = responseFilesData.SelectMany(x => x.FullPathReferences);
            foreach (var reference in responseRefs)
            {
                AppendReference(reference, projectBuilder);
            }

            if (0 < projectReferences.Count)
            {
                string referencedProject;
                projectBuilder.AppendLine("  </ItemGroup>");
                projectBuilder.AppendLine("  <ItemGroup>");
                foreach (Match reference in projectReferences)
                {
                    var targetAssembly = EditorCompilationInterface.Instance.GetTargetAssemblyDetails(reference.Groups["dllname"].Value);
                    ScriptingLanguage targetLanguage = ScriptingLanguage.None;
                    if (targetAssembly != null)
                        targetLanguage = (ScriptingLanguage)Enum.Parse(typeof(ScriptingLanguage), targetAssembly.Language.GetLanguageName(), true);
                    referencedProject = reference.Groups["project"].Value;
                    projectBuilder.AppendFormat("    <ProjectReference Include=\"{0}{1}\">{2}", referencedProject,
                        GetProjectExtension(targetLanguage), WindowsNewline);
                    projectBuilder.AppendFormat("      <Project>{{{0}}}</Project>", ProjectGuid(Path.Combine("Temp", reference.Groups["project"].Value + ".dll")), WindowsNewline);
                    projectBuilder.AppendFormat("      <Name>{0}</Name>", referencedProject, WindowsNewline);
                    projectBuilder.AppendLine("    </ProjectReference>");
                }
            }

            projectBuilder.Append(ProjectFooter(island));
            return projectBuilder.ToString();
        }

        static void AppendReference(string fullReference, StringBuilder projectBuilder)
        {
            //replace \ with / and \\ with /
            var escapedFullPath = SecurityElement.Escape(fullReference);
            escapedFullPath = escapedFullPath.Replace("\\", "/");
            escapedFullPath = escapedFullPath.Replace("\\\\", "/");
            projectBuilder.AppendFormat(" <Reference Include=\"{0}\">{1}", Path.GetFileNameWithoutExtension(escapedFullPath), WindowsNewline);
            projectBuilder.AppendFormat(" <HintPath>{0}</HintPath>{1}", escapedFullPath, WindowsNewline);
            projectBuilder.AppendFormat(" </Reference>{0}", WindowsNewline);
        }

        public string ProjectFile(MonoIsland island)
        {
            ScriptingLanguage language = ScriptingLanguageFor(island);
            return Path.Combine(_projectDirectory, string.Format("{0}{1}", Path.GetFileNameWithoutExtension(island._output), ProjectExtensions[language]));
        }

        internal string SolutionFile()
        {
            return Path.Combine(_projectDirectory, string.Format("{0}.sln", _projectName));
        }

        private string ProjectHeader(MonoIsland island,
            IEnumerable<ScriptCompilerBase.ResponseFileData> responseFilesData)
        {
            string targetframeworkversion = "v3.5";
            string targetLanguageVersion = "4";
            string toolsversion = "4.0";
            string productversion = "10.0.20506";
            string baseDirectory = ".";
            ScriptingLanguage language = ScriptingLanguageFor(island);

            if (PlayerSettingsEditor.IsLatestApiCompatibility(island._api_compatibility_level))
            {
                if (ScriptEditorUtility.GetScriptEditorFromPreferences() == ScriptEditorUtility.ScriptEditor.VisualStudioCode)
                {
                    targetframeworkversion = "v4.5";
                }
                else
                {
                    targetframeworkversion = "v4.7.1";
                }
                targetLanguageVersion = "latest";
            }
            else if (_settings.VisualStudioVersion == 9)
            {
                toolsversion = "3.5";
                productversion = "9.0.21022";
            }

            var arguments = new object[]
            {
                toolsversion, productversion, ProjectGuid(island._output),
                _settings.EngineAssemblyPath,
                _settings.EditorAssemblyPath,
                string.Join(";", new[] { "DEBUG", "TRACE"}.Concat(island._defines).Concat(responseFilesData.SelectMany(x => x.Defines)).Distinct().ToArray()),
                MSBuildNamespaceUri,
                Path.GetFileNameWithoutExtension(island._output),
                EditorSettings.projectGenerationRootNamespace,
                targetframeworkversion,
                targetLanguageVersion,
                baseDirectory,
                island._allowUnsafeCode | responseFilesData.Any(x => x.Unsafe)
            };

            try
            {
                return string.Format(_settings.GetProjectHeaderTemplate(language), arguments);
            }
            catch (Exception)
            {
                throw new System.NotSupportedException("Failed creating c# project because the c# project header did not have the correct amount of arguments, which is " + arguments.Length);
            }
        }

        private void SyncSolution(IEnumerable<MonoIsland> islands)
        {
            SyncSolutionFileIfNotChanged(SolutionFile(), SolutionText(islands, ModeForCurrentExternalEditor()));
        }

        private static Mode ModeForCurrentExternalEditor()
        {
            var scriptEditor = ScriptEditorUtility.GetScriptEditorFromPreferences();

            if (scriptEditor == ScriptEditorUtility.ScriptEditor.VisualStudio ||
                scriptEditor == ScriptEditorUtility.ScriptEditor.VisualStudioExpress ||
                scriptEditor == ScriptEditorUtility.ScriptEditor.VisualStudioCode)
                return Mode.UnityScriptAsPrecompiledAssembly;

            return EditorPrefs.GetBool("kExternalEditorSupportsUnityProj", false) ? Mode.UnityScriptAsUnityProj : Mode.UnityScriptAsPrecompiledAssembly;
        }

        private string SolutionText(IEnumerable<MonoIsland> islands, Mode mode)
        {
            var fileversion = "11.00";
            var vsversion = "2010";
            if (_settings.VisualStudioVersion == 9)
            {
                fileversion = "10.00";
                vsversion = "2008";
            }
            var relevantIslands = RelevantIslandsForMode(islands, mode);
            string projectEntries = GetProjectEntries(relevantIslands);
            string projectConfigurations = string.Join(WindowsNewline, relevantIslands.Select(i => GetProjectActiveConfigurations(ProjectGuid(i._output))).ToArray());
            return string.Format(_settings.SolutionTemplate, fileversion, vsversion, projectEntries, projectConfigurations, ReadExistingMonoDevelopSolutionProperties());
        }

        private static IEnumerable<MonoIsland> RelevantIslandsForMode(IEnumerable<MonoIsland> islands, Mode mode)
        {
            IEnumerable<MonoIsland> relevantIslands = islands.Where(i => (mode == Mode.UnityScriptAsUnityProj || ScriptingLanguage.CSharp == ScriptingLanguageFor(i)));
            return relevantIslands;
        }

        /// <summary>
        /// Get a Project("{guid}") = "MyProject", "MyProject.unityproj", "{projectguid}"
        /// entry for each relevant language
        /// </summary>
        internal string GetProjectEntries(IEnumerable<MonoIsland> islands)
        {
            var projectEntries = islands.Select(i => string.Format(
                DefaultSynchronizationSettings.SolutionProjectEntryTemplate,
                SolutionGuid(i), Path.GetFileNameWithoutExtension(i._output), Path.GetFileName(ProjectFile(i)), ProjectGuid(i._output)
            ));

            return string.Join(WindowsNewline, projectEntries.ToArray());
        }

        /// <summary>
        /// Generate the active configuration string for a given project guid
        /// </summary>
        private string GetProjectActiveConfigurations(string projectGuid)
        {
            return string.Format(
                DefaultSynchronizationSettings.SolutionProjectConfigurationTemplate,
                projectGuid);
        }

        private string EscapedRelativePathFor(string file)
        {
            var projectDir = _projectDirectory.ConvertSeparatorsToWindows();
            file = file.ConvertSeparatorsToWindows();
            var path = Paths.SkipPathPrefix(file, projectDir);
            if (PackageManager.Folders.IsPackagedAssetPath(path.ConvertSeparatorsToUnity()))
            {
                // We have to normalize the path, because the PackageManagerRemapper assumes
                // dir seperators will be os specific.
                var absolutePath = Path.GetFullPath(path.NormalizePath()).ConvertSeparatorsToWindows();
                path = Paths.SkipPathPrefix(absolutePath, projectDir);
            }
            return SecurityElement.Escape(path);
        }

        string ProjectGuid(string assembly)
        {
            return SolutionGuidGenerator.GuidForProject(_projectName + Path.GetFileNameWithoutExtension(assembly));
        }

        string SolutionGuid(MonoIsland island)
        {
            return SolutionGuidGenerator.GuidForSolution(_projectName, island.GetExtensionOfSourceFiles());
        }

        string ProjectFooter(MonoIsland island)
        {
            return string.Format(_settings.GetProjectFooterTemplate(ScriptingLanguageFor(island)), ReadExistingMonoDevelopProjectProperties(island));
        }

        string ReadExistingMonoDevelopSolutionProperties()
        {
            if (!SolutionExists()) return DefaultMonoDevelopSolutionProperties;
            string[] lines;
            try
            {
                lines = File.ReadAllLines(SolutionFile());
            }
            catch (IOException)
            {
                return DefaultMonoDevelopSolutionProperties;
            }

            StringBuilder existingOptions = new StringBuilder();
            bool collecting = false;

            foreach (string line in lines)
            {
                if (_MonoDevelopPropertyHeader.IsMatch(line))
                {
                    collecting = true;
                }
                if (collecting)
                {
                    if (line.Contains("EndGlobalSection"))
                    {
                        existingOptions.Append(line);
                        collecting = false;
                    }
                    else
                        existingOptions.AppendFormat("{0}{1}", line, WindowsNewline);
                }
            }

            if (0 < existingOptions.Length)
            {
                return existingOptions.ToString();
            }

            return DefaultMonoDevelopSolutionProperties;
        }

        string ReadExistingMonoDevelopProjectProperties(MonoIsland island)
        {
            if (!ProjectExists(island)) return string.Empty;
            XmlDocument doc = new XmlDocument();
            XmlNamespaceManager manager;
            try
            {
                doc.Load(ProjectFile(island));
                manager = new XmlNamespaceManager(doc.NameTable);
                manager.AddNamespace("msb", MSBuildNamespaceUri);
            }
            catch (Exception ex)
            {
                if (ex is IOException ||
                    ex is XmlException)
                    return string.Empty;
                throw;
            }

            XmlNodeList nodes = doc.SelectNodes("/msb:Project/msb:ProjectExtensions", manager);
            if (0 == nodes.Count) return string.Empty;

            StringBuilder sb = new StringBuilder();
            foreach (XmlNode node in nodes)
            {
                sb.AppendLine(node.OuterXml);
            }
            return sb.ToString();
        }

        [Obsolete("Use AssemblyHelper.IsManagedAssembly")]
        public static bool IsManagedAssembly(string file)
        {
            return AssemblyHelper.IsManagedAssembly(file);
        }

        public static string GetProjectExtension(ScriptingLanguage language)
        {
            if (!ProjectExtensions.ContainsKey(language))
                throw new ArgumentException("Unsupported language", "language");

            return ProjectExtensions[language];
        }
    }

    public static class SolutionGuidGenerator
    {
        public static string GuidForProject(string projectName)
        {
            return ComputeGuidHashFor(projectName + "salt");
        }

        public static string GuidForSolution(string projectName, string sourceFileExtension)
        {
            if (sourceFileExtension.ToLower() == "cs")
                // GUID for a C# class library: http://www.codeproject.com/Reference/720512/List-of-Visual-Studio-Project-Type-GUIDs
                return "FAE04EC0-301F-11D3-BF4B-00C04F79EFBC";

            return ComputeGuidHashFor(projectName);
        }

        private static string ComputeGuidHashFor(string input)
        {
            var hash = MD5.Create().ComputeHash(Encoding.Default.GetBytes(input));
            return HashAsGuid(HashToString(hash));
        }

        private static string HashAsGuid(string hash)
        {
            var guid = hash.Substring(0, 8) + "-" + hash.Substring(8, 4) + "-" + hash.Substring(12, 4) + "-" + hash.Substring(16, 4) + "-" + hash.Substring(20, 12);
            return guid.ToUpper();
        }

        private static string HashToString(byte[] bs)
        {
            var sb = new StringBuilder();
            foreach (byte b in bs)
                sb.Append(b.ToString("x2"));
            return sb.ToString();
        }
    }
}
