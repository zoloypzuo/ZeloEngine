// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using System;
using System.Globalization;
using UnityEngine;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine.Scripting;
using UnityEngine.Experimental.Networking.PlayerConnection;
using UnityEditor.Experimental.Networking.PlayerConnection;
using ConnectionGUILayout = UnityEditor.Experimental.Networking.PlayerConnection.EditorGUILayout;

namespace UnityEditor
{
    [EditorWindowTitle(title = "Console", useTypeNameAsIconName = true)]
    internal class ConsoleWindow : EditorWindow, IHasCustomMenu
    {
        internal delegate void EntryDoubleClickedDelegate(LogEntry entry);

        //TODO: move this out of here
        internal class Constants
        {
            private static bool ms_Loaded;
            private static int ms_logStyleLineCount;
            public static GUIStyle Box;
            public static GUIStyle MiniButton;
            public static GUIStyle LogStyle;
            public static GUIStyle WarningStyle;
            public static GUIStyle ErrorStyle;
            public static GUIStyle IconLogStyle;
            public static GUIStyle IconWarningStyle;
            public static GUIStyle IconErrorStyle;
            public static GUIStyle EvenBackground;
            public static GUIStyle OddBackground;
            public static GUIStyle MessageStyle;
            public static GUIStyle StatusError;
            public static GUIStyle StatusWarn;
            public static GUIStyle StatusLog;
            public static GUIStyle Toolbar;
            public static GUIStyle CountBadge;
            public static GUIStyle LogSmallStyle;
            public static GUIStyle WarningSmallStyle;
            public static GUIStyle ErrorSmallStyle;
            public static GUIStyle IconLogSmallStyle;
            public static GUIStyle IconWarningSmallStyle;
            public static GUIStyle IconErrorSmallStyle;
            public static readonly string ClearLabel = L10n.Tr("Clear");
            public static readonly string ClearOnPlayLabel = L10n.Tr("Clear on Play");
            public static readonly string ErrorPauseLabel = L10n.Tr("Error Pause");
            public static readonly string CollapseLabel = L10n.Tr("Collapse");
            public static readonly string StopForAssertLabel = L10n.Tr("Stop for Assert");
            public static readonly string StopForErrorLabel = L10n.Tr("Stop for Error");

            public static int LogStyleLineCount
            {
                get { return ms_logStyleLineCount; }
                set
                {
                    ms_logStyleLineCount = value;

                    // If Constants hasn't been initialized yet we just skip this for now
                    // and let Init() call this for us in a bit.
                    if (!ms_Loaded)
                        return;
                    UpdateLogStyleFixedHeights();
                }
            }

            public static void Init()
            {
                if (ms_Loaded)
                    return;
                ms_Loaded = true;
                Box = "CN Box";


                MiniButton = "ToolbarButton";
                Toolbar = "Toolbar";
                LogStyle = "CN EntryInfo";
                LogSmallStyle = "CN EntryInfoSmall";
                WarningStyle = "CN EntryWarn";
                WarningSmallStyle = "CN EntryWarnSmall";
                ErrorStyle = "CN EntryError";
                ErrorSmallStyle = "CN EntryErrorSmall";
                IconLogStyle = "CN EntryInfoIcon";
                IconLogSmallStyle = "CN EntryInfoIconSmall";
                IconWarningStyle = "CN EntryWarnIcon";
                IconWarningSmallStyle = "CN EntryWarnIconSmall";
                IconErrorStyle = "CN EntryErrorIcon";
                IconErrorSmallStyle = "CN EntryErrorIconSmall";
                EvenBackground = "CN EntryBackEven";
                OddBackground = "CN EntryBackodd";
                MessageStyle = "CN Message";
                StatusError = "CN StatusError";
                StatusWarn = "CN StatusWarn";
                StatusLog = "CN StatusInfo";
                CountBadge = "CN CountBadge";

                // If the console window isn't open OnEnable() won't trigger so it will end up with 0 lines,
                // so we always make sure we read it up when we initialize here.
                LogStyleLineCount = EditorPrefs.GetInt("ConsoleWindowLogLineCount", 2);
            }

            private static void UpdateLogStyleFixedHeights()
            {
                // Whenever we change the line height count or the styles are set we need to update the fixed height
                // of the following GuiStyles so the entries do not get cropped incorrectly.
                ErrorStyle.fixedHeight = (LogStyleLineCount * ErrorStyle.lineHeight) + ErrorStyle.border.top;
                WarningStyle.fixedHeight = (LogStyleLineCount * WarningStyle.lineHeight) + WarningStyle.border.top;
                LogStyle.fixedHeight = (LogStyleLineCount * LogStyle.lineHeight) + LogStyle.border.top;
            }
        }

        int m_LineHeight;
        int m_BorderHeight;

        bool m_HasUpdatedGuiStyles;

        ListViewState m_ListView;
        string m_ActiveText = "";
        private int m_ActiveInstanceID = 0;
        bool m_DevBuild;

        Vector2 m_TextScroll = Vector2.zero;

        SplitterState spl = new SplitterState(new float[] {70, 30}, new int[] {32, 32}, null);

        static bool ms_LoadedIcons = false;
        static internal Texture2D iconInfo, iconWarn, iconError;
        static internal Texture2D iconInfoSmall, iconWarnSmall, iconErrorSmall;
        static internal Texture2D iconInfoMono, iconWarnMono, iconErrorMono;

        int ms_LVHeight = 0;

        class ConsoleAttachToPlayerState : GeneralConnectionState
        {
            static class Content
            {
                public static GUIContent PlayerLogging = EditorGUIUtility.TrTextContent("Player Logging");
                public static GUIContent FullLog = EditorGUIUtility.TrTextContent("Full Log (Developer Mode Only)");
            }

            public ConsoleAttachToPlayerState(EditorWindow parentWindow, Action<string> connectedCallback = null) : base(parentWindow, connectedCallback)
            {
            }

            bool IsConnected()
            {
                return PlayerConnectionLogReceiver.instance.State != PlayerConnectionLogReceiver.ConnectionState.Disconnected;
            }

            void PlayerLoggingOptionSelected()
            {
                PlayerConnectionLogReceiver.instance.State = IsConnected() ? PlayerConnectionLogReceiver.ConnectionState.Disconnected : PlayerConnectionLogReceiver.ConnectionState.CleanLog;
            }

            bool IsLoggingFullLog()
            {
                return PlayerConnectionLogReceiver.instance.State == PlayerConnectionLogReceiver.ConnectionState.FullLog;
            }

            void FullLogOptionSelected()
            {
                PlayerConnectionLogReceiver.instance.State = IsLoggingFullLog() ? PlayerConnectionLogReceiver.ConnectionState.CleanLog : PlayerConnectionLogReceiver.ConnectionState.FullLog;
            }

            public override void AddItemsToMenu(GenericMenu menu, Rect position)
            {
                // option to turn logging and the connection on or of
                menu.AddItem(Content.PlayerLogging, IsConnected(), PlayerLoggingOptionSelected);
                if (IsConnected())
                {
                    // All other options but the first are only available if logging is enabled
                    menu.AddItem(Content.FullLog, IsLoggingFullLog(), FullLogOptionSelected);
                    menu.AddSeparator("");
                    base.AddItemsToMenu(menu, position);
                }
            }
        }

        IConnectionState m_ConsoleAttachToPlayerState;

        [Flags]
        internal enum Mode
        {
            Error = 1 << 0,
            Assert = 1 << 1,
            Log = 1 << 2,
            Fatal = 1 << 4,
            DontPreprocessCondition = 1 << 5,
            AssetImportError = 1 << 6,
            AssetImportWarning = 1 << 7,
            ScriptingError = 1 << 8,
            ScriptingWarning = 1 << 9,
            ScriptingLog = 1 << 10,
            ScriptCompileError = 1 << 11,
            ScriptCompileWarning = 1 << 12,
            StickyError = 1 << 13,
            MayIgnoreLineNumber = 1 << 14,
            ReportBug = 1 << 15,
            DisplayPreviousErrorInStatusBar = 1 << 16,
            ScriptingException = 1 << 17,
            DontExtractStacktrace = 1 << 18,
            ShouldClearOnPlay = 1 << 19,
            GraphCompileError = 1 << 20,
            ScriptingAssertion = 1 << 21,
            VisualScriptingError = 1 << 22
        };

        enum ConsoleFlags
        {
            Collapse = 1 << 0,
            ClearOnPlay = 1 << 1,
            ErrorPause = 1 << 2,
            Verbose = 1 << 3,
            StopForAssert = 1 << 4,
            StopForError = 1 << 5,
            Autoscroll = 1 << 6,
            LogLevelLog = 1 << 7,
            LogLevelWarning = 1 << 8,
            LogLevelError = 1 << 9,
            ShowTimestamp = 1 << 10,
        };

        static ConsoleWindow ms_ConsoleWindow = null;

        static void ShowConsoleWindowImmediate()
        {
            ShowConsoleWindow(true);
        }

        public static void ShowConsoleWindow(bool immediate)
        {
            if (ms_ConsoleWindow == null)
            {
                ms_ConsoleWindow = ScriptableObject.CreateInstance<ConsoleWindow>();
                ms_ConsoleWindow.Show(immediate);
                ms_ConsoleWindow.Focus();
            }
            else
            {
                ms_ConsoleWindow.Show(immediate);
                ms_ConsoleWindow.Focus();
            }
        }

        static internal void LoadIcons()
        {
            if (ms_LoadedIcons)
                return;

            ms_LoadedIcons = true;
            iconInfo = EditorGUIUtility.LoadIcon("console.infoicon");
            iconWarn = EditorGUIUtility.LoadIcon("console.warnicon");
            iconError = EditorGUIUtility.LoadIcon("console.erroricon");
            iconInfoSmall = EditorGUIUtility.LoadIcon("console.infoicon.sml");
            iconWarnSmall = EditorGUIUtility.LoadIcon("console.warnicon.sml");
            iconErrorSmall = EditorGUIUtility.LoadIcon("console.erroricon.sml");

            // TODO: Once we get the proper monochrome images put them here.
            /*iconInfoMono = EditorGUIUtility.LoadIcon("console.infoicon.mono");
            iconWarnMono = EditorGUIUtility.LoadIcon("console.warnicon.mono");
            iconErrorMono = EditorGUIUtility.LoadIcon("console.erroricon.mono");*/
            iconInfoMono = EditorGUIUtility.LoadIcon("console.infoicon.sml");
            iconWarnMono = EditorGUIUtility.LoadIcon("console.warnicon.inactive.sml");
            iconErrorMono = EditorGUIUtility.LoadIcon("console.erroricon.inactive.sml");
            Constants.Init();
        }

        [RequiredByNativeCode]
        public static void LogChanged()
        {
            if (ms_ConsoleWindow == null)
                return;

            ms_ConsoleWindow.DoLogChanged();
        }

        public void DoLogChanged()
        {
            ms_ConsoleWindow.Repaint();
        }

        public ConsoleWindow()
        {
            position = new Rect(200, 200, 800, 400);
            m_ListView = new ListViewState(0, 0);
        }

        void OnEnable()
        {
            if (m_ConsoleAttachToPlayerState == null)
                m_ConsoleAttachToPlayerState = new ConsoleAttachToPlayerState(this);

            MakeSureConsoleAlwaysOnlyOne();

            titleContent = GetLocalizedTitleContent();
            ms_ConsoleWindow = this;
            m_DevBuild = Unsupported.IsDeveloperMode();

            Constants.LogStyleLineCount = EditorPrefs.GetInt("ConsoleWindowLogLineCount", 2);
        }

        void MakeSureConsoleAlwaysOnlyOne()
        {
            // make sure that console window is always open as only one.
            if (ms_ConsoleWindow != null)
            {
                // get the container window of this console window.
                ContainerWindow cw = ms_ConsoleWindow.m_Parent.window;

                // the container window must not be main view(prevent from quitting editor).
                if (cw.rootView.GetType() != typeof(MainView))
                    cw.Close();
            }
        }

        void OnDisable()
        {
            m_ConsoleAttachToPlayerState?.Dispose();
            m_ConsoleAttachToPlayerState = null;

            if (ms_ConsoleWindow == this)
                ms_ConsoleWindow = null;
        }

        private int RowHeight
        {
            get
            {
                return (Constants.LogStyleLineCount * m_LineHeight) + m_BorderHeight;
            }
        }

        private static bool HasMode(int mode, Mode modeToCheck) { return (mode & (int)modeToCheck) != 0; }
        private static bool HasFlag(ConsoleFlags flags) { return (LogEntries.consoleFlags & (int)flags) != 0; }
        private static void SetFlag(ConsoleFlags flags, bool val) { LogEntries.SetConsoleFlag((int)flags, val); }

        static internal Texture2D GetIconForErrorMode(int mode, bool large)
        {
            // Errors
            if (HasMode(mode, Mode.Fatal | Mode.Assert |
                Mode.Error | Mode.ScriptingError |
                Mode.AssetImportError | Mode.ScriptCompileError |
                Mode.GraphCompileError | Mode.ScriptingAssertion))
                return large ? iconError : iconErrorSmall;
            // Warnings
            if (HasMode(mode, Mode.ScriptCompileWarning | Mode.ScriptingWarning | Mode.AssetImportWarning))
                return large ? iconWarn : iconWarnSmall;
            // Logs
            if (HasMode(mode, Mode.Log | Mode.ScriptingLog))
                return large ? iconInfo : iconInfoSmall;

            // Nothing
            return null;
        }

        static internal GUIStyle GetStyleForErrorMode(int mode, bool isIcon, bool isSmall)
        {
            // Errors
            if (HasMode(mode, Mode.Fatal | Mode.Assert |
                Mode.Error | Mode.ScriptingError |
                Mode.AssetImportError | Mode.ScriptCompileError |
                Mode.GraphCompileError | Mode.ScriptingAssertion))
            {
                if (isIcon)
                {
                    if (isSmall)
                    {
                        return Constants.IconErrorSmallStyle;
                    }
                    return Constants.IconErrorStyle;
                }

                if (isSmall)
                {
                    return Constants.ErrorSmallStyle;
                }
                return Constants.ErrorStyle;
            }
            // Warnings
            if (HasMode(mode, Mode.ScriptCompileWarning | Mode.ScriptingWarning | Mode.AssetImportWarning))
            {
                if (isIcon)
                {
                    if (isSmall)
                    {
                        return Constants.IconWarningSmallStyle;
                    }
                    return Constants.IconWarningStyle;
                }

                if (isSmall)
                {
                    return Constants.WarningSmallStyle;
                }
                return Constants.WarningStyle;
            }
            // Logs
            if (isIcon)
            {
                if (isSmall)
                {
                    return Constants.IconLogSmallStyle;
                }
                return Constants.IconLogStyle;
            }

            if (isSmall)
            {
                return Constants.LogSmallStyle;
            }
            return Constants.LogStyle;
        }

        static internal GUIStyle GetStatusStyleForErrorMode(int mode)
        {
            // Errors
            if (HasMode(mode, Mode.Fatal | Mode.Assert |
                Mode.Error | Mode.ScriptingError |
                Mode.AssetImportError | Mode.ScriptCompileError |
                Mode.GraphCompileError | Mode.ScriptingAssertion))
                return Constants.StatusError;
            // Warnings
            if (HasMode(mode, Mode.ScriptCompileWarning | Mode.ScriptingWarning | Mode.AssetImportWarning))
                return Constants.StatusWarn;
            // Logs
            return Constants.StatusLog;
        }

        static string ContextString(LogEntry entry)
        {
            StringBuilder context = new StringBuilder();

            if (HasMode(entry.mode, Mode.Error))
                context.Append("Error ");
            else if (HasMode(entry.mode, Mode.Log))
                context.Append("Log ");
            else
                context.Append("Assert ");

            context.Append("in file: ");
            context.Append(entry.file);
            context.Append(" at line: ");
            context.Append(entry.line);

            if (entry.errorNum != 0)
            {
                context.Append(" and errorNum: ");
                context.Append(entry.errorNum);
            }

            return context.ToString();
        }

        static string GetFirstLine(string s)
        {
            int i = s.IndexOf("\n");
            return (i != -1) ? s.Substring(0, i) : s;
        }

        static string GetFirstTwoLines(string s)
        {
            int i = s.IndexOf("\n");
            if (i != -1)
            {
                i = s.IndexOf("\n", i + 1);
                if (i != -1)
                    return s.Substring(0, i);
            }

            return s;
        }

        void SetActiveEntry(LogEntry entry)
        {
            if (entry != null)
            {
                m_ActiveText = entry.condition;
                // ping object referred by the log entry
                if (m_ActiveInstanceID != entry.instanceID)
                {
                    m_ActiveInstanceID = entry.instanceID;
                    if (entry.instanceID != 0)
                        EditorGUIUtility.PingObject(entry.instanceID);
                }
            }
            else
            {
                m_ActiveText = string.Empty;
                m_ActiveInstanceID = 0;
                m_ListView.row = -1;
            }
        }

        // Used implicitly with CallStaticMonoMethod("ConsoleWindow", "ShowConsoleRow", param);
        static void ShowConsoleRow(int row)
        {
            ShowConsoleWindow(false);

            if (ms_ConsoleWindow)
            {
                ms_ConsoleWindow.m_ListView.row = row;
                ms_ConsoleWindow.m_ListView.selectionChanged = true;
                ms_ConsoleWindow.Repaint();
            }
        }

        void UpdateListView()
        {
            m_HasUpdatedGuiStyles = true;
            int newRowHeight = RowHeight;

            // We reset the scroll list to auto scrolling whenever the log entry count is modified
            m_ListView.rowHeight = newRowHeight;
            m_ListView.row = -1;
            m_ListView.scrollPos.y = LogEntries.GetCount() * newRowHeight;
        }

        void OnGUI()
        {
            Event e = Event.current;
            LoadIcons();

            if (!m_HasUpdatedGuiStyles)
            {
                m_LineHeight = Mathf.RoundToInt(Constants.ErrorStyle.lineHeight);
                m_BorderHeight = Constants.ErrorStyle.border.top + Constants.ErrorStyle.border.bottom;
                UpdateListView();
            }

            GUILayout.BeginHorizontal(Constants.Toolbar);

            if (GUILayout.Button(Constants.ClearLabel, Constants.MiniButton))
            {
                LogEntries.Clear();
                GUIUtility.keyboardControl = 0;
            }

            int currCount = LogEntries.GetCount();

            if (m_ListView.totalRows != currCount && m_ListView.totalRows > 0)
            {
                // scroll bar was at the bottom?
                if (m_ListView.scrollPos.y >= m_ListView.rowHeight * m_ListView.totalRows - ms_LVHeight)
                {
                    m_ListView.scrollPos.y = currCount * RowHeight - ms_LVHeight;
                }
            }

            EditorGUILayout.Space();

            bool wasCollapsed = HasFlag(ConsoleFlags.Collapse);
            SetFlag(ConsoleFlags.Collapse, GUILayout.Toggle(wasCollapsed, Constants.CollapseLabel, Constants.MiniButton));

            bool collapsedChanged = (wasCollapsed != HasFlag(ConsoleFlags.Collapse));
            if (collapsedChanged)
            {
                // unselect if collapsed flag changed
                m_ListView.row = -1;

                // scroll to bottom
                m_ListView.scrollPos.y = LogEntries.GetCount() * RowHeight;
            }

            SetFlag(ConsoleFlags.ClearOnPlay, GUILayout.Toggle(HasFlag(ConsoleFlags.ClearOnPlay), Constants.ClearOnPlayLabel, Constants.MiniButton));
            SetFlag(ConsoleFlags.ErrorPause, GUILayout.Toggle(HasFlag(ConsoleFlags.ErrorPause), Constants.ErrorPauseLabel, Constants.MiniButton));

            ConnectionGUILayout.AttachToPlayerDropdown(m_ConsoleAttachToPlayerState, EditorStyles.toolbarDropDown);

            EditorGUILayout.Space();

            if (m_DevBuild)
            {
                GUILayout.FlexibleSpace();
                SetFlag(ConsoleFlags.StopForAssert, GUILayout.Toggle(HasFlag(ConsoleFlags.StopForAssert), Constants.StopForAssertLabel, Constants.MiniButton));
                SetFlag(ConsoleFlags.StopForError, GUILayout.Toggle(HasFlag(ConsoleFlags.StopForError), Constants.StopForErrorLabel, Constants.MiniButton));
            }

            GUILayout.FlexibleSpace();

            int errorCount = 0, warningCount = 0, logCount = 0;
            LogEntries.GetCountsByType(ref errorCount, ref warningCount, ref logCount);
            EditorGUI.BeginChangeCheck();
            bool setLogFlag = GUILayout.Toggle(HasFlag(ConsoleFlags.LogLevelLog), new GUIContent((logCount <= 999 ? logCount.ToString() : "999+"), logCount > 0 ? iconInfoSmall : iconInfoMono), Constants.MiniButton);
            bool setWarningFlag = GUILayout.Toggle(HasFlag(ConsoleFlags.LogLevelWarning), new GUIContent((warningCount <= 999 ? warningCount.ToString() : "999+"), warningCount > 0 ? iconWarnSmall : iconWarnMono), Constants.MiniButton);
            bool setErrorFlag = GUILayout.Toggle(HasFlag(ConsoleFlags.LogLevelError), new GUIContent((errorCount <= 999 ? errorCount.ToString() : "999+"), errorCount > 0 ? iconErrorSmall : iconErrorMono), Constants.MiniButton);
            // Active entry index may no longer be valid
            if (EditorGUI.EndChangeCheck())
                SetActiveEntry(null);

            SetFlag(ConsoleFlags.LogLevelLog, setLogFlag);
            SetFlag(ConsoleFlags.LogLevelWarning, setWarningFlag);
            SetFlag(ConsoleFlags.LogLevelError, setErrorFlag);

            GUILayout.EndHorizontal();

            SplitterGUILayout.BeginVerticalSplit(spl);
            int rowHeight = RowHeight;
            EditorGUIUtility.SetIconSize(new Vector2(rowHeight, rowHeight));
            GUIContent tempContent = new GUIContent();
            int id = GUIUtility.GetControlID(0);
            int rowDoubleClicked = -1;

            /////@TODO: Make Frame selected work with ListViewState
            using (new GettingLogEntriesScope(m_ListView))
            {
                int selectedRow = -1;
                bool openSelectedItem = false;
                bool collapsed = HasFlag(ConsoleFlags.Collapse);
                foreach (ListViewElement el in ListViewGUI.ListView(m_ListView, Constants.Box))
                {
                    if (e.type == EventType.MouseDown && e.button == 0 && el.position.Contains(e.mousePosition))
                    {
                        selectedRow = m_ListView.row;
                        if (e.clickCount == 2)
                            openSelectedItem = true;
                    }
                    else if (e.type == EventType.Repaint)
                    {
                        int mode = 0;
                        string text = null;
                        LogEntries.GetLinesAndModeFromEntryInternal(el.row, Constants.LogStyleLineCount, ref mode, ref text);

                        // Draw the background
                        GUIStyle s = el.row % 2 == 0 ? Constants.OddBackground : Constants.EvenBackground;
                        s.Draw(el.position, false, false, m_ListView.row == el.row, false);

                        // Draw the icon
                        GUIStyle iconStyle = GetStyleForErrorMode(mode, true, Constants.LogStyleLineCount == 1);
                        iconStyle.Draw(el.position, false, false, m_ListView.row == el.row, false);

                        // Draw the text
                        tempContent.text = text;
                        GUIStyle errorModeStyle = GetStyleForErrorMode(mode, false, Constants.LogStyleLineCount == 1);
                        errorModeStyle.Draw(el.position, tempContent, id, m_ListView.row == el.row);

                        if (collapsed)
                        {
                            Rect badgeRect = el.position;
                            tempContent.text = LogEntries.GetEntryCount(el.row).ToString(CultureInfo.InvariantCulture);
                            Vector2 badgeSize = Constants.CountBadge.CalcSize(tempContent);
                            badgeRect.xMin = badgeRect.xMax - badgeSize.x;
                            badgeRect.yMin += ((badgeRect.yMax - badgeRect.yMin) - badgeSize.y) * 0.5f;
                            badgeRect.x -= 5f;
                            GUI.Label(badgeRect, tempContent, Constants.CountBadge);
                        }
                    }
                }

                if (selectedRow != -1)
                {
                    if (m_ListView.scrollPos.y >= m_ListView.rowHeight * m_ListView.totalRows - ms_LVHeight)
                        m_ListView.scrollPos.y = m_ListView.rowHeight * m_ListView.totalRows - ms_LVHeight - 1;
                }

                // Make sure the selected entry is up to date
                if (m_ListView.totalRows == 0 || m_ListView.row >= m_ListView.totalRows || m_ListView.row < 0)
                {
                    if (m_ActiveText.Length != 0)
                        SetActiveEntry(null);
                }
                else
                {
                    LogEntry entry = new LogEntry();
                    LogEntries.GetEntryInternal(m_ListView.row, entry);
                    SetActiveEntry(entry);

                    // see if selected entry changed. if so - clear additional info
                    LogEntries.GetEntryInternal(m_ListView.row, entry);
                    if (m_ListView.selectionChanged || !m_ActiveText.Equals(entry.condition))
                    {
                        SetActiveEntry(entry);
                    }
                }

                // Open entry using return key
                if ((GUIUtility.keyboardControl == m_ListView.ID) && (e.type == EventType.KeyDown) && (e.keyCode == KeyCode.Return) && (m_ListView.row != 0))
                {
                    selectedRow = m_ListView.row;
                    openSelectedItem = true;
                }

                if (e.type != EventType.Layout && ListViewGUI.ilvState.rectHeight != 1)
                    ms_LVHeight = ListViewGUI.ilvState.rectHeight;

                if (openSelectedItem)
                {
                    rowDoubleClicked = selectedRow;
                    e.Use();
                }
            }

            // Prevent dead locking in EditorMonoConsole by delaying callbacks (which can log to the console) until after LogEntries.EndGettingEntries() has been
            // called (this releases the mutex in EditorMonoConsole so logging again is allowed). Fix for case 1081060.
            if (rowDoubleClicked != -1)
                LogEntries.RowGotDoubleClicked(rowDoubleClicked);

            EditorGUIUtility.SetIconSize(Vector2.zero);

            // Display active text (We want word wrapped text with a vertical scrollbar)
            m_TextScroll = GUILayout.BeginScrollView(m_TextScroll, Constants.Box);
            float height = Constants.MessageStyle.CalcHeight(GUIContent.Temp(m_ActiveText), position.width);
            EditorGUILayout.SelectableLabel(m_ActiveText, Constants.MessageStyle, GUILayout.ExpandWidth(true), GUILayout.ExpandHeight(true), GUILayout.MinHeight(height));
            GUILayout.EndScrollView();

            SplitterGUILayout.EndVerticalSplit();

            // Copy & Paste selected item
            if ((e.type == EventType.ValidateCommand || e.type == EventType.ExecuteCommand) && e.commandName == EventCommandNames.Copy && m_ActiveText != string.Empty)
            {
                if (e.type == EventType.ExecuteCommand)
                    EditorGUIUtility.systemCopyBuffer = m_ActiveText;
                e.Use();
            }
        }

        public static bool GetConsoleErrorPause()
        {
            return HasFlag(ConsoleFlags.ErrorPause);
        }

        public static void SetConsoleErrorPause(bool enabled)
        {
            SetFlag(ConsoleFlags.ErrorPause, enabled);
        }

        public struct StackTraceLogTypeData
        {
            public LogType logType;
            public StackTraceLogType stackTraceLogType;
        }

        public void ToggleLogStackTraces(object userData)
        {
            StackTraceLogTypeData data = (StackTraceLogTypeData)userData;
            PlayerSettings.SetStackTraceLogType(data.logType, data.stackTraceLogType);
        }

        public void ToggleLogStackTracesForAll(object userData)
        {
            foreach (LogType logType in Enum.GetValues(typeof(LogType)))
                PlayerSettings.SetStackTraceLogType(logType, (StackTraceLogType)userData);
        }

        public void AddItemsToMenu(GenericMenu menu)
        {
            if (Application.platform == RuntimePlatform.OSXEditor)
                menu.AddItem(EditorGUIUtility.TrTextContent("Open Player Log"), false, UnityEditorInternal.InternalEditorUtility.OpenPlayerConsole);
            menu.AddItem(EditorGUIUtility.TrTextContent("Open Editor Log"), false, UnityEditorInternal.InternalEditorUtility.OpenEditorConsole);

            menu.AddItem(EditorGUIUtility.TrTextContent("Show Timestamp"), HasFlag(ConsoleFlags.ShowTimestamp), SetTimestamp);

            for (int i = 1; i <= 10; ++i)
            {
                var lineString = i == 1 ? "Line" : "Lines";
                menu.AddItem(new GUIContent(string.Format("Log Entry/{0} {1}", i, lineString)), i == Constants.LogStyleLineCount, SetLogLineCount, i);
            }

            AddStackTraceLoggingMenu(menu);
        }

        private void SetTimestamp()
        {
            SetFlag(ConsoleFlags.ShowTimestamp, !HasFlag(ConsoleFlags.ShowTimestamp));
        }

        private void SetLogLineCount(object obj)
        {
            int count = (int)obj;
            EditorPrefs.SetInt("ConsoleWindowLogLineCount", count);
            Constants.LogStyleLineCount = count;

            UpdateListView();
        }

        private void AddStackTraceLoggingMenu(GenericMenu menu)
        {
            // TODO: Maybe remove this, because it basically duplicates UI in PlayerSettings
            foreach (LogType logType in Enum.GetValues(typeof(LogType)))
            {
                foreach (StackTraceLogType stackTraceLogType in Enum.GetValues(typeof(StackTraceLogType)))
                {
                    StackTraceLogTypeData data;
                    data.logType = logType;
                    data.stackTraceLogType = stackTraceLogType;

                    menu.AddItem(EditorGUIUtility.TrTextContent("Stack Trace Logging/" + logType + "/" + stackTraceLogType), PlayerSettings.GetStackTraceLogType(logType) == stackTraceLogType,
                        ToggleLogStackTraces, data);
                }
            }

            int stackTraceLogTypeForAll = (int)PlayerSettings.GetStackTraceLogType(LogType.Log);
            foreach (LogType logType in Enum.GetValues(typeof(LogType)))
            {
                if (PlayerSettings.GetStackTraceLogType(logType) != (StackTraceLogType)stackTraceLogTypeForAll)
                {
                    stackTraceLogTypeForAll = -1;
                    break;
                }
            }

            foreach (StackTraceLogType stackTraceLogType in Enum.GetValues(typeof(StackTraceLogType)))
            {
                menu.AddItem(EditorGUIUtility.TrTextContent("Stack Trace Logging/All/" + stackTraceLogType), (StackTraceLogType)stackTraceLogTypeForAll == stackTraceLogType,
                    ToggleLogStackTracesForAll, stackTraceLogType);
            }
        }

        private static event EntryDoubleClickedDelegate entryWithManagedCallbackDoubleClicked;

        [RequiredByNativeCode]
        private static void SendEntryDoubleClicked(LogEntry entry)
        {
            if (ConsoleWindow.entryWithManagedCallbackDoubleClicked != null)
                ConsoleWindow.entryWithManagedCallbackDoubleClicked(entry);
        }

        // This method is used by the Visual Scripting project. Please do not delete. Contact @husseink for more information.
        internal void AddMessageWithDoubleClickCallback(string condition, string file, int mode, int instanceID)
        {
            var outputEntry = new LogEntry {condition = condition, file = file, mode = mode, instanceID = instanceID};
            LogEntries.AddMessageWithDoubleClickCallback(outputEntry);
        }
    }

    internal class GettingLogEntriesScope : IDisposable
    {
        private bool m_Disposed;

        public GettingLogEntriesScope(ListViewState listView)
        {
            listView.totalRows = LogEntries.StartGettingEntries();
        }

        public void Dispose()
        {
            if (m_Disposed)
                return;
            LogEntries.EndGettingEntries();
            m_Disposed = true;
        }

        ~GettingLogEntriesScope()
        {
            if (!m_Disposed)
                Debug.LogError("Scope was not disposed! You should use the 'using' keyword or manually call Dispose.");
        }
    }
}
