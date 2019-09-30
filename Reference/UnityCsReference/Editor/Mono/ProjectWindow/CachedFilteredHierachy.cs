// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using UnityEngine;
using System.Collections.Generic;
using UnityEditor.Experimental;
using UnityEngine.Assertions;

namespace UnityEditor
{
    internal partial class FilteredHierarchy
    {
        public class FilterResult
        {
            public int instanceID;
            public string name;
            public bool hasChildren;
            public int colorCode;
            public bool isMainRepresentation;
            public bool hasFullPreviewImage;
            public IconDrawStyle iconDrawStyle;
            public bool isFolder;
            public HierarchyType type;
            public Texture2D icon
            {
                get
                {
                    if (m_Icon == null)
                    {
                        if (type == HierarchyType.Assets)
                        {
                            // Note: Do not set m_Icon as GetCachedIcon uses its own cache that is cleared on reaching a max limit.
                            // This is because when having e.g very large projects (1000s of textures with unique icons) we do not want all icons loaded
                            // at the same time so don't keep a reference in m_Icon here
                            string path = AssetDatabase.GetAssetPath(instanceID);
                            if (path != null)
                                // Finding icon based on only file extension fails in several ways, and a different approach have to be found.
                                // Using InternalEditorUtility.FindIconForFile first in revision f25945218bb6 / 29b23dbe4b5c introduced several regressions.
                                //  - Doesn't support custom user-assigned icons for monoscripts.
                                //  - Doesn't support open/closed folder icon destinction.
                                //  - The change only affected Two-Column mode in Project View and not One-Column mode, adding inconsistency.
                                //  - Doesn't support showing different icons for different prefab types, such as prefab variants.
                                // Support for specific file types based on file extensiom have to be supported inside AssetDatabase.GetCachedIcon
                                // itself to work correctly and universally. for e.g. uxml files from within GetCachedIcon without relying on FindIconForFile.
                                return AssetDatabase.GetCachedIcon(path) as Texture2D;
                        }
                        else if (type == HierarchyType.GameObjects)
                        {
                            // GameObject thumbnail can be set to m_Icon since its an actual icon which means we have a limited set of them
                            Object go = EditorUtility.InstanceIDToObject(instanceID);
                            m_Icon = AssetPreview.GetMiniThumbnail(go);
                        }
                        else
                        {
                            Assert.IsTrue(false, "Unhandled HierarchyType");
                        }
                    }
                    return m_Icon;
                }
                set
                {
                    m_Icon = value;
                }
            }
            private Texture2D m_Icon;

            public string guid
            {
                get
                {
                    if (type == HierarchyType.Assets)
                    {
                        string path = AssetDatabase.GetAssetPath(instanceID);
                        if (path != null)
                            return AssetDatabase.AssetPathToGUID(path);
                    }
                    return null;
                }
            }
        }

        SearchFilter m_SearchFilter = new SearchFilter();
        FilterResult[] m_Results = new FilterResult[0];     // When filtering of folder we have all sub assets here
        FilterResult[] m_VisibleItems = new FilterResult[0]; // Subset of m_Results used for showing/hiding sub assets

        HierarchyType m_HierarchyType;

        public FilteredHierarchy(HierarchyType type)
        {
            m_HierarchyType = type;
        }

        public HierarchyType hierarchyType
        {
            get { return m_HierarchyType; }
        }

        public FilterResult[] results
        {
            get
            {
                if (m_VisibleItems.Length > 0)
                    return m_VisibleItems;
                return m_Results;
            }
        }
        public SearchFilter searchFilter
        {
            get { return m_SearchFilter; }
            set
            {
                if (m_SearchFilter.SetNewFilter(value))
                    ResultsChanged();
            }
        }

        public bool foldersFirst { get; set; }

        public void SetResults(int[] instanceIDs)
        {
            if (m_HierarchyType ==  HierarchyType.Assets)
            {
                string[] rootPaths = new string[instanceIDs.Length];
                for (int i = 0; i < instanceIDs.Length; ++i)
                {
                    var rootPath = "Assets";

                    var path = AssetDatabase.GetAssetPath(instanceIDs[i]);
                    var packageInfo = PackageManager.Packages.GetForAssetPath(path);
                    // Find the right rootPath if folderPath is part of a package
                    if (packageInfo != null)
                        rootPath = packageInfo.assetPath;

                    rootPaths[i] = rootPath;
                }

                System.Array.Resize(ref m_Results, instanceIDs.Length);
                for (int i = 0; i < instanceIDs.Length; ++i)
                {
                    HierarchyProperty property = new HierarchyProperty(rootPaths[i], false);
                    if (property.Find(instanceIDs[i], null))
                        CopyPropertyData(ref m_Results[i], property);
                }
            }
            else
            {
                HierarchyProperty property = new HierarchyProperty(m_HierarchyType, false);
                property.Reset();

                System.Array.Resize(ref m_Results, instanceIDs.Length);
                for (int i = 0; i < instanceIDs.Length; ++i)
                {
                    if (property.Find(instanceIDs[i], null))
                        CopyPropertyData(ref m_Results[i], property);
                }
            }
        }

        void CopyPropertyData(ref FilterResult result, HierarchyProperty property)
        {
            if (result == null)
                result = new FilterResult();

            result.instanceID = property.instanceID;
            result.name = property.name;
            result.hasChildren = property.hasChildren;
            result.colorCode = property.colorCode;
            result.isMainRepresentation = property.isMainRepresentation;
            result.hasFullPreviewImage = property.hasFullPreviewImage;
            result.iconDrawStyle = property.iconDrawStyle;
            result.isFolder = property.isFolder;
            result.type = hierarchyType;

            // If this is not the main representation, cache the icon, as we don't have an API to access it later.
            // Otherwise, don't - as this may cause Textures to load unintendedly (e.g if we have 3000 search results we do not want to load icons before needed when rendering)
            if (!property.isMainRepresentation)
                result.icon = property.icon;
            else if (property.isFolder && !property.hasChildren)
                result.icon = EditorGUIUtility.FindTexture(EditorResources.emptyFolderIconName);
            else
                result.icon = null;
        }

        void SearchAllAssets(SearchFilter.SearchArea area)
        {
            const int k_MaxAddCount = 3000;
            if (m_HierarchyType == HierarchyType.Assets)
            {
                List<FilterResult> list = new List<FilterResult>();
                list.AddRange(m_Results);

                var maxAddCount = k_MaxAddCount;
                m_SearchFilter.searchArea = area;
                var enumerator = AssetDatabase.EnumerateAllAssets(m_SearchFilter);
                while (enumerator.MoveNext() && --maxAddCount >= 0)
                {
                    var result = new FilterResult();
                    CopyPropertyData(ref result, enumerator.Current);
                    list.Add(result);
                }

                m_Results = list.ToArray();
            }
            else if (m_HierarchyType == HierarchyType.GameObjects)
            {
                HierarchyProperty property = new HierarchyProperty(m_HierarchyType, false);
                property.SetSearchFilter(m_SearchFilter);

                if (m_SearchFilter.sceneHandles != null &&
                    m_SearchFilter.sceneHandles.Length > 0)
                {
                    property.SetCustomScenes(m_SearchFilter.sceneHandles);
                }

                int elements = property.CountRemaining(null);
                elements = Mathf.Min(elements, k_MaxAddCount);
                property.Reset();

                int i = m_Results.Length;
                System.Array.Resize(ref m_Results, m_Results.Length + elements);
                while (property.Next(null) && i < m_Results.Length)
                {
                    CopyPropertyData(ref m_Results[i], property);
                    i++;
                }
            }
        }

        void SearchInFolders()
        {
            List<FilterResult> list = new List<FilterResult>();
            List<string> baseFolders = new List<string>();
            baseFolders.AddRange(ProjectWindowUtil.GetBaseFolders(m_SearchFilter.folders));
            if (baseFolders.Remove(PackageManager.Folders.GetPackagesMountPoint()))
            {
                var packages = PackageManagerUtilityInternal.GetAllVisiblePackages();
                foreach (var package in packages)
                {
                    if (!baseFolders.Contains(package.assetPath))
                        baseFolders.Add(package.assetPath);
                }
            }

            m_SearchFilter.searchArea = SearchFilter.SearchArea.SelectedFolders;
            foreach (string folderPath in baseFolders)
            {
                // Ensure we do not have a filter when finding folder
                HierarchyProperty property = new HierarchyProperty(folderPath);
                property.SetSearchFilter(m_SearchFilter);

                // Set filter after we found the folder
                int folderDepth = property.depth;
                int[] expanded = null; // enter all children of folder
                while (property.NextWithDepthCheck(expanded, folderDepth + 1))
                {
                    FilterResult result = new FilterResult();
                    CopyPropertyData(ref result, property);
                    list.Add(result);
                }
            }
            m_Results = list.ToArray();
        }

        void FolderBrowsing()
        {
            // We are not concerned with assets being added multiple times as we only show the contents
            // of each selected folder. This is an issue when searching recursively into child folders.
            List<FilterResult> list = new List<FilterResult>();
            HierarchyProperty property;
            foreach (string folderPath in m_SearchFilter.folders)
            {
                if (folderPath == PackageManager.Folders.GetPackagesMountPoint())
                {
                    var packages = PackageManagerUtilityInternal.GetAllVisiblePackages();
                    foreach (var package in packages)
                    {
                        var packageFolderInstanceId = AssetDatabase.GetMainAssetOrInProgressProxyInstanceID(package.assetPath);
                        property = new HierarchyProperty(package.assetPath);
                        if (property.Find(packageFolderInstanceId, null))
                        {
                            FilterResult result = new FilterResult();
                            CopyPropertyData(ref result, property);
                            result.name = !string.IsNullOrEmpty(package.displayName) ? package.displayName : package.name;
                            list.Add(result);
                        }
                    }
                    continue;
                }

                int folderInstanceID = AssetDatabase.GetMainAssetOrInProgressProxyInstanceID(folderPath);
                property = new HierarchyProperty(folderPath);
                property.SetSearchFilter(m_SearchFilter);

                int folderDepth = property.depth;
                int[] expanded = { folderInstanceID };
                while (property.Next(expanded))
                {
                    if (property.depth <= folderDepth)
                        break; // current property is outside folder

                    FilterResult result = new FilterResult();
                    CopyPropertyData(ref result, property);
                    list.Add(result);

                    // Fetch sub assets by expanding the main asset (ignore folders)
                    if (property.hasChildren && !property.isFolder)
                    {
                        System.Array.Resize(ref expanded, expanded.Length + 1);
                        expanded[expanded.Length - 1] = property.instanceID;
                    }
                }
            }
            m_Results = list.ToArray();
        }

        void AddResults()
        {
            switch (m_SearchFilter.GetState())
            {
                case SearchFilter.State.FolderBrowsing:          FolderBrowsing();  break;
                case SearchFilter.State.SearchingInAllAssets:    SearchAllAssets(SearchFilter.SearchArea.AllAssets); break;
                case SearchFilter.State.SearchingInAssetsOnly:   SearchAllAssets(SearchFilter.SearchArea.InAssetsOnly); break;
                case SearchFilter.State.SearchingInPackagesOnly: SearchAllAssets(SearchFilter.SearchArea.InPackagesOnly); break;
                case SearchFilter.State.SearchingInFolders:      SearchInFolders(); break;
                case SearchFilter.State.SearchingInAssetStore: /*do nothing*/ break;
                case SearchFilter.State.EmptySearchFilter: /*do nothing*/ break;
                default: Debug.LogError("Unhandled enum!"); break;
            }
        }

        public void ResultsChanged()
        {
            m_Results = new FilterResult[0];
            if (m_SearchFilter.GetState() != SearchFilter.State.EmptySearchFilter)
            {
                AddResults();

                // When filtering on folder we use the order we get from BaseHiearchyProperty.cpp (to keep indented children under parent) otherwise we sort
                if (m_SearchFilter.IsSearching())
                {
                    System.Array.Sort(m_Results, (result1, result2) => EditorUtility.NaturalCompare(result1.name, result2.name));
                }

                if (foldersFirst)
                {
                    for (int nonFolderPos = 0; nonFolderPos < m_Results.Length; ++nonFolderPos)
                    {
                        if (m_Results[nonFolderPos].isFolder)
                            continue;

                        for (int folderPos = nonFolderPos + 1; folderPos < m_Results.Length; ++folderPos)
                        {
                            if (!m_Results[folderPos].isFolder)
                                continue;

                            FilterResult folder = m_Results[folderPos];
                            int length = folderPos - nonFolderPos;
                            System.Array.Copy(m_Results, nonFolderPos, m_Results, nonFolderPos + 1, length);
                            m_Results[nonFolderPos] = folder;
                            break;
                        }
                    }
                }
            }
            else
            {
                // Reset visible flags if filter string is empty (see BaseHiearchyProperty::SetSearchFilter)
                if (m_HierarchyType == HierarchyType.GameObjects)
                {
                    HierarchyProperty gameObjects = new HierarchyProperty(HierarchyType.GameObjects, false);
                    gameObjects.SetSearchFilter(m_SearchFilter);
                }
            }
        }

        public void RefreshVisibleItems(List<int> expandedInstanceIDs)
        {
            bool isSearching = m_SearchFilter.IsSearching();
            List<FilterResult> visibleItems = new List<FilterResult>();
            for (int i = 0; i < m_Results.Length; ++i)
            {
                visibleItems.Add(m_Results[i]);
                if (m_Results[i].isMainRepresentation && m_Results[i].hasChildren && !m_Results[i].isFolder)
                {
                    bool isParentExpanded = expandedInstanceIDs.IndexOf(m_Results[i].instanceID) >= 0;
                    bool addSubItems = isParentExpanded || isSearching;
                    int numSubItems = AddSubItemsOfMainRepresentation(i, addSubItems ? visibleItems : null);
                    i += numSubItems;
                }
            }

            m_VisibleItems = visibleItems.ToArray();
        }

        public List<int> GetSubAssetInstanceIDs(int mainAssetInstanceID)
        {
            for (int i = 0; i < m_Results.Length; ++i)
            {
                if (m_Results[i].instanceID == mainAssetInstanceID)
                {
                    List<int> subAssetInstanceIDs = new List<int>();
                    int index = i + 1; // Start after the main representation
                    while (index < m_Results.Length && !m_Results[index].isMainRepresentation)
                    {
                        subAssetInstanceIDs.Add(m_Results[index].instanceID);
                        index++;
                    }
                    return subAssetInstanceIDs;
                }
            }
            Debug.LogError("Not main rep " + mainAssetInstanceID);
            return new List<int>();
        }

        public int AddSubItemsOfMainRepresentation(int mainRepresentionIndex, List<FilterResult> visibleItems)
        {
            int count = 0;
            int index = mainRepresentionIndex + 1; // Start after the main representation
            while (index < m_Results.Length && !m_Results[index].isMainRepresentation)
            {
                if (visibleItems != null)
                    visibleItems.Add(m_Results[index]);
                index++;
                count++;
            }
            return count;
        }
    }

    internal class FilteredHierarchyProperty : IHierarchyProperty
    {
        FilteredHierarchy m_Hierarchy;
        int m_Position = -1;

        public static IHierarchyProperty CreateHierarchyPropertyForFilter(FilteredHierarchy filteredHierarchy)
        {
            if (filteredHierarchy.searchFilter.GetState() != SearchFilter.State.EmptySearchFilter)
                return new FilteredHierarchyProperty(filteredHierarchy);
            else
                return new HierarchyProperty(filteredHierarchy.hierarchyType, false);
        }

        public FilteredHierarchyProperty(FilteredHierarchy filter)
        {
            m_Hierarchy = filter;
        }

        public void Reset()
        {
            m_Position = -1;
        }

        public int instanceID
        {
            get { return m_Hierarchy.results[m_Position].instanceID; }
        }

        public Object pptrValue
        {
            get { return EditorUtility.InstanceIDToObject(instanceID); }
        }

        public string name
        {
            get { return m_Hierarchy.results[m_Position].name; }
        }

        public bool hasChildren
        {
            get { return m_Hierarchy.results[m_Position].hasChildren; }
        }

        public bool isMainRepresentation
        {
            get { return m_Hierarchy.results[m_Position].isMainRepresentation; }
        }

        public bool hasFullPreviewImage
        {
            get { return m_Hierarchy.results[m_Position].hasFullPreviewImage; }
        }

        public IconDrawStyle iconDrawStyle
        {
            get { return m_Hierarchy.results[m_Position].iconDrawStyle; }
        }

        public bool isFolder
        {
            get { return m_Hierarchy.results[m_Position].isFolder; }
        }

        public GUID[] dynamicDependencies
        {
            get { return new GUID[] {}; }
        }

        public int depth
        {
            get { return 0; }
        }

        public int row
        {
            get { return m_Position; }
        }

        public int colorCode
        {
            get { return m_Hierarchy.results[m_Position].colorCode; }
        }

        public bool IsExpanded(int[] expanded)
        {
            return false;
        }

        public string guid
        {
            get { return m_Hierarchy.results[m_Position].guid; }
        }

        public bool isValid
        {
            get { return m_Hierarchy.results != null && m_Position < m_Hierarchy.results.Length && m_Position >= 0; }
        }

        public Texture2D icon
        {
            get { return m_Hierarchy.results[m_Position].icon; }
        }

        public bool Next(int[] expanded)
        {
            m_Position++;
            return m_Position < m_Hierarchy.results.Length;
        }

        public bool NextWithDepthCheck(int[] expanded, int minDepth)
        {
            // Depth check does not make sense for filtered properties as tree info is lost
            return Next(expanded);
        }

        public bool Previous(int[] expanded)
        {
            m_Position--;
            return m_Position >= 0;
        }

        public bool Parent()
        {
            return false;
        }

        public int[] ancestors
        {
            get
            {
                return new int[0];
            }
        }

        public bool Find(int _instanceID, int[] expanded)
        {
            Reset();
            while (Next(expanded))
            {
                if (instanceID == _instanceID)
                    return true;
            }
            return false;
        }

        public int[] FindAllAncestors(int[] instanceIDs)
        {
            return new int[0];
        }

        public bool Skip(int count, int[] expanded)
        {
            m_Position += count;
            return m_Position < m_Hierarchy.results.Length;
        }

        public int CountRemaining(int[] expanded)
        {
            return m_Hierarchy.results.Length - m_Position - 1;
        }
    }
}
