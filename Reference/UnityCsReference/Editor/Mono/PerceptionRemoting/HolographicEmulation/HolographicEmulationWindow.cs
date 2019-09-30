// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.InteropServices;
using UnityEditor;
using UnityEditorInternal.VR;
using UnityEngine;
using UnityEngine.XR;
using UnityEngine.XR.WSA;

namespace UnityEngine.XR.WSA
{
    internal class HolographicEmulationWindow : EditorWindow
    {
        private bool m_InPlayMode = false;
        private bool m_OperatingSystemChecked = false;
        private bool m_OperatingSystemValid = false;
        private HolographicStreamerConnectionState m_LastConnectionState = HolographicStreamerConnectionState.Disconnected;

        [SerializeField]
        private EmulationMode m_Mode = EmulationMode.None;
        [SerializeField]
        private int m_RoomIndex = 0;
        [SerializeField]
        private GestureHand m_Hand = GestureHand.Right;
        [SerializeField]
        private string m_RemoteMachineAddress = "";
        [SerializeField]
        private bool m_EnableVideo = true;
        [SerializeField]
        private bool m_EnableAudio = true;
        [SerializeField]
        private int m_MaxBitrateKbps = 99999;

        // history is saved in editor prefs so it is usable across projects
        private string[] m_RemoteMachineHistory;
        private static int s_MaxHistoryLength = 4;

        private static GUIContent s_ConnectionStatusText = EditorGUIUtility.TrTextContent("Connection Status");
        private static GUIContent s_EmulationModeText = EditorGUIUtility.TrTextContent("Emulation Mode");
        private static GUIContent s_RoomText = EditorGUIUtility.TrTextContent("Room");
        private static GUIContent s_HandText = EditorGUIUtility.TrTextContent("Gesture Hand");
        private static GUIContent s_RemoteMachineText = EditorGUIUtility.TrTextContent("Remote Machine");
        private static GUIContent s_EnableVideoText = EditorGUIUtility.TrTextContent("Enable Video");
        private static GUIContent s_EnableAudioText = EditorGUIUtility.TrTextContent("Enable Audio");
        private static GUIContent s_MaxBitrateText = EditorGUIUtility.TrTextContent("Max Bitrate (kbps)");
        private static GUIContent s_ConnectionButtonConnectText = EditorGUIUtility.TrTextContent("Connect");
        private static GUIContent s_ConnectionButtonDisconnectText = EditorGUIUtility.TrTextContent("Disconnect");
        private static GUIContent s_ConnectionStateDisconnectedText = EditorGUIUtility.TrTextContent("Disconnected");
        private static GUIContent s_ConnectionStateConnectingText = EditorGUIUtility.TrTextContent("Connecting");
        private static GUIContent s_ConnectionStateConnectedText = EditorGUIUtility.TrTextContent("Connected");
        private static Texture2D s_ConnectedTexture = null;
        private static Texture2D s_ConnectingTexture = null;
        private static Texture2D s_DisconnectedTexture = null;
        private static GUIContent[] s_ModeStrings = new GUIContent[]
        {
            EditorGUIUtility.TrTextContent("None"),
            EditorGUIUtility.TrTextContent("Remote to Device"),
            EditorGUIUtility.TrTextContent("Simulate in Editor")
        };

        private static GUIContent[] s_RoomStrings = new GUIContent[]
        {
            EditorGUIUtility.TrTextContent("None"),
            EditorGUIUtility.TrTextContent("DefaultRoom"),
            EditorGUIUtility.TrTextContent("Bedroom1"),
            EditorGUIUtility.TrTextContent("Bedroom2"),
            EditorGUIUtility.TrTextContent("GreatRoom"),
            EditorGUIUtility.TrTextContent("LivingRoom")
        };

        private static GUIContent[] s_HandStrings = new GUIContent[]
        {
            EditorGUIUtility.TrTextContent("Left Hand"),
            EditorGUIUtility.TrTextContent("Right Hand"),
        };

        internal EmulationMode emulationMode
        {
            get { return m_Mode; }
            set { m_Mode = value; Repaint(); }
        }

        internal static void Init()
        {
            EditorWindow.GetWindow<HolographicEmulationWindow>(false);
        }

        private bool RemoteMachineNameSpecified { get { return !String.IsNullOrEmpty(m_RemoteMachineAddress); } }

        private void OnEnable()
        {
            titleContent = EditorGUIUtility.TrTextContent("Holographic");
            EditorApplication.playModeStateChanged += OnPlayModeStateChanged;
            m_InPlayMode = EditorApplication.isPlayingOrWillChangePlaymode;

            m_RemoteMachineHistory = EditorPrefs.GetString("HolographicRemoting.RemoteMachineHistory").Split(',');
        }

        private void OnDisable()
        {
            EditorApplication.playModeStateChanged -= OnPlayModeStateChanged;
        }

        private void LoadCurrentRoom()
        {
            if (m_RoomIndex == 0)
                return;

            string roomPath = System.IO.Path.GetFullPath("Packages/com.unity.xr.windowsmr.metro") + "/Plugins/HolographicSimulation/Rooms/";
            HolographicAutomation.LoadRoom(roomPath + s_RoomStrings[m_RoomIndex].text + ".xef");
        }

        private void InitializeSimulation()
        {
            Disconnect();

            HolographicAutomation.Initialize();

            LoadCurrentRoom();
        }

        private void OnPlayModeStateChanged(PlayModeStateChange state)
        {
            if (!IsWindowsMixedRealityCurrentTarget())
                return;

            bool wasPlaying = m_InPlayMode;
            m_InPlayMode = EditorApplication.isPlayingOrWillChangePlaymode;

            if (m_InPlayMode && !wasPlaying)
            {
                HolographicAutomation.SetEmulationMode(m_Mode);
                switch (m_Mode)
                {
                    case EmulationMode.Simulated:
                        InitializeSimulation();
                        break;
                    case EmulationMode.RemoteDevice:
                        break;
                }
            }
            else if (!m_InPlayMode && wasPlaying)
            {
                switch (m_Mode)
                {
                    case EmulationMode.Simulated:
                        HolographicAutomation.Shutdown();
                        break;

                    case EmulationMode.RemoteDevice:
                        break;
                }
            }
        }

        private void Connect()
        {
            PerceptionRemoting.SetVideoEncodingParameters(m_MaxBitrateKbps);
            PerceptionRemoting.SetEnableVideo(m_EnableVideo);
            PerceptionRemoting.SetEnableAudio(m_EnableAudio);
            PerceptionRemoting.Connect(m_RemoteMachineAddress);
        }

        private void Disconnect()
        {
            if (PerceptionRemoting.GetConnectionState() != HolographicStreamerConnectionState.Disconnected)
                PerceptionRemoting.Disconnect();
        }

        private bool IsConnectedToRemoteDevice()
        {
            return PerceptionRemoting.GetConnectionState() == HolographicStreamerConnectionState.Connected;
        }

        private void HandleButtonPress()
        {
            if (EditorApplication.isPlayingOrWillChangePlaymode)
            {
                Debug.LogError("Unable to connect / disconnect remoting while playing.");
                return;
            }

            HolographicStreamerConnectionState connectionState = PerceptionRemoting.GetConnectionState();
            if (connectionState == HolographicStreamerConnectionState.Connecting ||
                connectionState == HolographicStreamerConnectionState.Connected)
            {
                Disconnect();
            }
            else if (RemoteMachineNameSpecified)
            {
                Connect();
            }
            else
            {
                Debug.LogError("Cannot connect without a remote machine address specified");
            }
        }

        private void UpdateRemoteMachineHistory()
        {
            List<string> history = new List<string>(m_RemoteMachineHistory);

            // check for existing item in history
            for (int i = 0; i < m_RemoteMachineHistory.Length; ++i)
            {
                if (m_RemoteMachineHistory[i].Equals(m_RemoteMachineAddress, StringComparison.CurrentCultureIgnoreCase))
                {
                    if (i == 0)
                        return;

                    // remove it so it can be re-added as the first element
                    history.RemoveAt(i);
                    break;
                }
            }

            // add to history
            history.Insert(0, m_RemoteMachineAddress);

            // cull list down to MaxHistoryLength
            if (history.Count > s_MaxHistoryLength)
            {
                history.RemoveRange(s_MaxHistoryLength, history.Count - s_MaxHistoryLength);
            }

            m_RemoteMachineHistory = history.ToArray();
            EditorPrefs.SetString("HolographicRemoting.RemoteMachineHistory", String.Join(",", m_RemoteMachineHistory));
        }

        private void RemotingPreferencesOnGUI()
        {
            EditorGUI.BeginChangeCheck();
            m_RemoteMachineAddress = EditorGUILayout.DelayedTextFieldDropDown(s_RemoteMachineText, m_RemoteMachineAddress, m_RemoteMachineHistory);
            if (EditorGUI.EndChangeCheck())
            {
                UpdateRemoteMachineHistory();
            }
            m_EnableVideo = EditorGUILayout.Toggle(s_EnableVideoText, m_EnableVideo);
            m_EnableAudio = EditorGUILayout.Toggle(s_EnableAudioText, m_EnableAudio);
            m_MaxBitrateKbps = EditorGUILayout.IntSlider(s_MaxBitrateText, m_MaxBitrateKbps, 1024, 99999);
        }

        void ConnectionStateGUI()
        {
            if (s_ConnectedTexture == null)
            {
                s_ConnectedTexture = EditorGUIUtility.LoadIconRequired("sv_icon_dot3_sml");
                s_ConnectingTexture = EditorGUIUtility.LoadIconRequired("sv_icon_dot4_sml");
                s_DisconnectedTexture = EditorGUIUtility.LoadIconRequired("sv_icon_dot6_sml");
            }

            Texture2D iconTexture;
            GUIContent labelContent;
            GUIContent buttonContent;
            HolographicStreamerConnectionState connectionState = PerceptionRemoting.GetConnectionState();
            switch (connectionState)
            {
                case HolographicStreamerConnectionState.Disconnected:
                default:
                    iconTexture = s_DisconnectedTexture;
                    labelContent = s_ConnectionStateDisconnectedText;
                    buttonContent = s_ConnectionButtonConnectText;
                    break;

                case HolographicStreamerConnectionState.Connecting:
                    iconTexture = s_ConnectingTexture;
                    labelContent = s_ConnectionStateConnectingText;
                    buttonContent = s_ConnectionButtonDisconnectText;
                    break;

                case HolographicStreamerConnectionState.Connected:
                    iconTexture = s_ConnectedTexture;
                    labelContent = s_ConnectionStateConnectedText;
                    buttonContent = s_ConnectionButtonDisconnectText;
                    break;
            }

            EditorGUILayout.BeginHorizontal();

            EditorGUILayout.PrefixLabel(s_ConnectionStatusText, "Button");
            float iconSize = EditorGUIUtility.singleLineHeight;
            Rect iconRect = GUILayoutUtility.GetRect(iconSize, iconSize, GUILayout.ExpandWidth(false));
            GUI.DrawTexture(iconRect, iconTexture);
            EditorGUILayout.LabelField(labelContent);

            EditorGUILayout.EndHorizontal();

            EditorGUI.BeginDisabledGroup(m_InPlayMode);
            bool pressed = EditorGUILayout.DropdownButton(buttonContent, FocusType.Passive, EditorStyles.miniButton);
            EditorGUI.EndDisabledGroup();

            if (pressed)
            {
                if (EditorGUIUtility.editingTextField)
                {
                    EditorGUIUtility.editingTextField = false;
                    GUIUtility.keyboardControl = 0;
                }
                //we delay the call to let the RemoteMachineAddress control commit the value
                EditorApplication.CallDelayed(() =>
                {
                    HandleButtonPress();
                }, 0f);
            }
        }

        private bool IsWindowsMixedRealityCurrentTarget()
        {
            if (!VREditor.GetVREnabledOnTargetGroup(BuildTargetGroup.WSA))
                return false;

            if (Array.IndexOf(XRSettings.supportedDevices, "WindowsMR") < 0)
                return false;

            return true;
        }

        private void DrawRemotingMode()
        {
            EditorGUI.BeginChangeCheck();
            m_Mode = (EmulationMode)EditorGUILayout.Popup(s_EmulationModeText, (int)m_Mode, s_ModeStrings);
            if (EditorGUI.EndChangeCheck() && m_Mode != EmulationMode.RemoteDevice)
            {
                Disconnect();
            }
        }

        private bool CheckOperatingSystem()
        {
            if (!m_OperatingSystemChecked)
            {
                m_OperatingSystemValid = System.Environment.OSVersion.Version.Build >= 14318;
                m_OperatingSystemChecked = true;
            }
            return m_OperatingSystemValid;
        }

        void OnGUI()
        {
            if (!CheckOperatingSystem())
            {
                EditorGUILayout.HelpBox("You must be running Windows build 14318 or later to use Holographic Simulation or Remoting.", MessageType.Warning);
                return;
            }

            if (!IsWindowsMixedRealityCurrentTarget())
            {
                EditorGUILayout.HelpBox("You must enable Virtual Reality support in settings and add Windows Mixed Reality to the devices to use Holographic Emulation.", MessageType.Warning);
                return;
            }

            EditorGUILayout.Space();

            EditorGUI.BeginDisabledGroup(m_InPlayMode);
            DrawRemotingMode();
            EditorGUI.EndDisabledGroup();

            switch (m_Mode)
            {
                case EmulationMode.RemoteDevice:
                    EditorGUI.BeginDisabledGroup(IsConnectedToRemoteDevice());
                    RemotingPreferencesOnGUI();
                    EditorGUI.EndDisabledGroup();
                    ConnectionStateGUI();
                    break;

                case EmulationMode.Simulated:
                    EditorGUI.BeginChangeCheck();
                    m_RoomIndex = EditorGUILayout.Popup(s_RoomText, m_RoomIndex, s_RoomStrings);
                    if (EditorGUI.EndChangeCheck() && m_InPlayMode)
                        LoadCurrentRoom();


                    EditorGUI.BeginChangeCheck();
                    m_Hand = (GestureHand)EditorGUILayout.Popup(s_HandText, (int)m_Hand, s_HandStrings);
                    if (EditorGUI.EndChangeCheck())
                        HolographicAutomation.SetGestureHand(m_Hand);

                    break;
            }
        }

        void Update()
        {
            switch (m_Mode)
            {
                case EmulationMode.Simulated:
                    UnityEngine.XR.WSA.HolographicAutomation.SetGestureHand(m_Hand);
                    break;

                case EmulationMode.RemoteDevice:
                    HolographicStreamerConnectionState connectionState = PerceptionRemoting.GetConnectionState();
                    if (connectionState != m_LastConnectionState)
                    {
                        Repaint();
                    }
                    var lastConnectionFailureReason = PerceptionRemoting.CheckForDisconnect();
                    if (lastConnectionFailureReason == HolographicStreamerConnectionFailureReason.Unreachable
                        || lastConnectionFailureReason == HolographicStreamerConnectionFailureReason.ConnectionLost)
                    {
                        Debug.LogWarning("Disconnected with failure reason " + lastConnectionFailureReason + ", attempting to reconnect.");
                        Connect();
                    }
                    else if (lastConnectionFailureReason != HolographicStreamerConnectionFailureReason.None)
                    {
                        Debug.LogError("Disconnected with error " + lastConnectionFailureReason);
                    }
                    m_LastConnectionState = connectionState;
                    break;
            }
        }
    }
}
