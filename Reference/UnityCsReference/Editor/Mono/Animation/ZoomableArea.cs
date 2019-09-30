// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using UnityEngine;
using UnityEditor;
using System.Collections;

namespace UnityEditor
{
    // NOTE: do _not_ use GUILayout to get the rectangle for zoomable area,
    // will not work and will start failing miserably (mouse events not hitting it, etc.).
    // That's because ZoomableArea is using GUILayout itself, and needs an actual
    // physical rectangle.

    [System.Serializable]
    internal class ZoomableArea
    {
        // Global state
        private static Vector2 m_MouseDownPosition = new Vector2(-1000000, -1000000); // in transformed space
        private static int zoomableAreaHash = "ZoomableArea".GetHashCode();

        // Range lock settings
        [SerializeField] private bool m_HRangeLocked;
        [SerializeField] private bool m_VRangeLocked;
        public bool hRangeLocked { get { return m_HRangeLocked; } set { m_HRangeLocked = value; } }
        public bool vRangeLocked { get { return m_VRangeLocked; } set { m_VRangeLocked = value; } }

        // Zoom lock settings
        public bool hZoomLockedByDefault = false;
        public bool vZoomLockedByDefault = false;

        [SerializeField] private float m_HBaseRangeMin = 0;
        [SerializeField] private float m_HBaseRangeMax = 1;
        [SerializeField] private float m_VBaseRangeMin = 0;
        [SerializeField] private float m_VBaseRangeMax = 1;
        public float hBaseRangeMin { get { return m_HBaseRangeMin; } set { m_HBaseRangeMin = value; } }
        public float hBaseRangeMax { get { return m_HBaseRangeMax; } set { m_HBaseRangeMax = value; } }
        public float vBaseRangeMin { get { return m_VBaseRangeMin; } set { m_VBaseRangeMin = value; } }
        public float vBaseRangeMax { get { return m_VBaseRangeMax; } set { m_VBaseRangeMax = value; } }
        [SerializeField] private bool m_HAllowExceedBaseRangeMin = true;
        [SerializeField] private bool m_HAllowExceedBaseRangeMax = true;
        [SerializeField] private bool m_VAllowExceedBaseRangeMin = true;
        [SerializeField] private bool m_VAllowExceedBaseRangeMax = true;
        public bool hAllowExceedBaseRangeMin { get { return m_HAllowExceedBaseRangeMin; } set { m_HAllowExceedBaseRangeMin = value; } }
        public bool hAllowExceedBaseRangeMax { get { return m_HAllowExceedBaseRangeMax; } set { m_HAllowExceedBaseRangeMax = value; } }
        public bool vAllowExceedBaseRangeMin { get { return m_VAllowExceedBaseRangeMin; } set { m_VAllowExceedBaseRangeMin = value; } }
        public bool vAllowExceedBaseRangeMax { get { return m_VAllowExceedBaseRangeMax; } set { m_VAllowExceedBaseRangeMax = value; } }
        public float hRangeMin
        {
            get { return (hAllowExceedBaseRangeMin ? Mathf.NegativeInfinity : hBaseRangeMin); }
            set { SetAllowExceed(ref m_HBaseRangeMin, ref m_HAllowExceedBaseRangeMin, value); }
        }
        public float hRangeMax
        {
            get { return (hAllowExceedBaseRangeMax ? Mathf.Infinity : hBaseRangeMax); }
            set { SetAllowExceed(ref m_HBaseRangeMax, ref m_HAllowExceedBaseRangeMax, value); }
        }
        public float vRangeMin
        {
            get { return (vAllowExceedBaseRangeMin ? Mathf.NegativeInfinity : vBaseRangeMin); }
            set { SetAllowExceed(ref m_VBaseRangeMin, ref m_VAllowExceedBaseRangeMin, value); }
        }
        public float vRangeMax
        {
            get { return (vAllowExceedBaseRangeMax ? Mathf.Infinity : vBaseRangeMax); }
            set { SetAllowExceed(ref m_VBaseRangeMax, ref m_VAllowExceedBaseRangeMax, value); }
        }
        private void SetAllowExceed(ref float rangeEnd, ref bool allowExceed, float value)
        {
            if (value == Mathf.NegativeInfinity || value == Mathf.Infinity)
            {
                rangeEnd = (value == Mathf.NegativeInfinity ? 0 : 1);
                allowExceed = true;
            }
            else
            {
                rangeEnd = value;
                allowExceed = false;
            }
        }

        private const float kMinScale = 0.00001f;
        private const float kMaxScale = 100000.0f;
        private float m_HScaleMin = kMinScale;
        private float m_HScaleMax = kMaxScale;
        private float m_VScaleMin = kMinScale;
        private float m_VScaleMax = kMaxScale;

        private const float kMinWidth = 0.05f;
        private const float kMinHeight = 0.05f;

        public float hScaleMin
        {
            get { return m_HScaleMin; }
            set
            {
                m_HScaleMin = Mathf.Clamp(value, kMinScale, kMaxScale);
                styles.enableSliderZoomHorizontal = allowSliderZoomHorizontal;
            }
        }
        public float hScaleMax
        {
            get { return m_HScaleMax; }
            set
            {
                m_HScaleMax = Mathf.Clamp(value, kMinScale, kMaxScale);
                styles.enableSliderZoomHorizontal = allowSliderZoomHorizontal;
            }
        }
        public float vScaleMin
        {
            get { return m_VScaleMin; }
            set
            {
                m_VScaleMin = Mathf.Clamp(value, kMinScale, kMaxScale);
                styles.enableSliderZoomVertical = allowSliderZoomVertical;
            }
        }
        public float vScaleMax
        {
            get { return m_VScaleMax; }
            set
            {
                m_VScaleMax = Mathf.Clamp(value, kMinScale, kMaxScale);
                styles.enableSliderZoomVertical = allowSliderZoomVertical;
            }
        }


        // Window resize settings
        [SerializeField] private bool m_ScaleWithWindow = false;
        public bool scaleWithWindow { get { return m_ScaleWithWindow; } set { m_ScaleWithWindow = value; } }

        // Slider settings
        [SerializeField] private bool m_HSlider = true;
        [SerializeField] private bool m_VSlider = true;
        public bool hSlider { get { return m_HSlider; } set { Rect r = rect; m_HSlider = value; rect = r; } }
        public bool vSlider { get { return m_VSlider; } set { Rect r = rect; m_VSlider = value; rect = r; } }

        [SerializeField] private bool m_IgnoreScrollWheelUntilClicked = false;
        public bool ignoreScrollWheelUntilClicked { get { return m_IgnoreScrollWheelUntilClicked; } set { m_IgnoreScrollWheelUntilClicked = value; } }

        [SerializeField] private bool m_EnableMouseInput = true;
        public bool enableMouseInput { get { return m_EnableMouseInput; } set { m_EnableMouseInput = value; } }

        [SerializeField] private bool m_EnableSliderZoomHorizontal = true;
        [SerializeField] private bool m_EnableSliderZoomVertical = true;

        // if the min and max scaling does not allow for actual zooming, there is no point in allowing it
        protected bool allowSliderZoomHorizontal { get { return m_EnableSliderZoomHorizontal && m_HScaleMin < m_HScaleMax; } }
        protected bool allowSliderZoomVertical { get { return m_EnableSliderZoomVertical && m_VScaleMin < m_VScaleMax; } }

        public bool m_UniformScale;
        public bool uniformScale { get { return m_UniformScale; } set { m_UniformScale = value; } }

        // This is optional now, but used to be default behaviour because ZoomableAreas are mostly graphs with +Y being up
        public enum YDirection
        {
            Positive,
            Negative
        }
        [SerializeField] private YDirection m_UpDirection = YDirection.Positive;
        public YDirection upDirection
        {
            get
            {
                return m_UpDirection;
            }
            set
            {
                if (m_UpDirection != value)
                {
                    m_UpDirection = value;
                    m_Scale.y = -m_Scale.y;
                }
            }
        }

        // View and drawing settings
        [SerializeField] private Rect m_DrawArea = new Rect(0, 0, 100, 100);
        internal void SetDrawRectHack(Rect r) { m_DrawArea = r; }
        [SerializeField] internal Vector2 m_Scale = new Vector2(1, -1);
        [SerializeField] internal Vector2 m_Translation = new Vector2(0, 0);
        [SerializeField] private float m_MarginLeft, m_MarginRight, m_MarginTop, m_MarginBottom;
        [SerializeField] private Rect m_LastShownAreaInsideMargins = new Rect(0, 0, 100, 100);

        public Vector2 scale { get { return m_Scale; } }
        public Vector2 translation { get { return m_Translation; } }
        public float margin { set { m_MarginLeft = m_MarginRight = m_MarginTop = m_MarginBottom = value; } }
        public float leftmargin { get { return m_MarginLeft; } set { m_MarginLeft = value; } }
        public float rightmargin { get { return m_MarginRight; } set { m_MarginRight = value; } }
        public float topmargin { get { return m_MarginTop; } set { m_MarginTop = value; } }
        public float bottommargin { get { return m_MarginBottom; } set { m_MarginBottom = value; } }
        public float vSliderWidth { get { return vSlider ? styles.sliderWidth : 0f; } }
        public float hSliderHeight { get { return hSlider ? styles.sliderWidth : 0f; } }

        // IDs for scrollbars
        int verticalScrollbarID, horizontalScrollbarID;

        [SerializeField] bool m_MinimalGUI;

        public class Styles
        {
            public GUIStyle horizontalScrollbar;
            public GUIStyle horizontalMinMaxScrollbarThumb
            {
                get
                {
                    return GetSliderAxisStyle(enableSliderZoomHorizontal).horizontal;
                }
            }
            public GUIStyle horizontalScrollbarLeftButton;
            public GUIStyle horizontalScrollbarRightButton;
            public GUIStyle verticalScrollbar;
            public GUIStyle verticalMinMaxScrollbarThumb
            {
                get
                {
                    return GetSliderAxisStyle(enableSliderZoomVertical).vertical;
                }
            }
            public GUIStyle verticalScrollbarUpButton;
            public GUIStyle verticalScrollbarDownButton;

            public bool enableSliderZoomHorizontal;
            public bool enableSliderZoomVertical;

            public float sliderWidth;
            public float visualSliderWidth;

            private bool minimalGUI;

            private SliderTypeStyles.SliderAxisStyles GetSliderAxisStyle(bool enableSliderZoom)
            {
                if (minimalGUI)
                    return enableSliderZoom ? minimalSliderStyles.minMaxSliders : minimalSliderStyles.scrollbar;
                else
                    return enableSliderZoom ? normalSliderStyles.minMaxSliders : normalSliderStyles.scrollbar;
            }

            private static SliderTypeStyles minimalSliderStyles;
            private static SliderTypeStyles normalSliderStyles;

            private class SliderTypeStyles
            {
                public SliderAxisStyles scrollbar;
                public SliderAxisStyles minMaxSliders;
                public class SliderAxisStyles
                {
                    public GUIStyle horizontal;
                    public GUIStyle vertical;
                }
            }

            public Styles(bool minimalGUI)
            {
                if (minimalGUI)
                {
                    visualSliderWidth = 0;
                    sliderWidth = 15;
                }
                else
                {
                    visualSliderWidth = 15;
                    sliderWidth = 15;
                }
            }

            public void InitGUIStyles(bool minimalGUI, bool enableSliderZoom)
            {
                InitGUIStyles(minimalGUI, enableSliderZoom, enableSliderZoom);
            }

            public void InitGUIStyles(bool minimalGUI, bool enableSliderZoomHorizontal, bool enableSliderZoomVertical)
            {
                this.minimalGUI = minimalGUI;
                this.enableSliderZoomHorizontal = enableSliderZoomHorizontal;
                this.enableSliderZoomVertical = enableSliderZoomVertical;

                if (minimalGUI)
                {
                    if (minimalSliderStyles == null)
                    {
                        minimalSliderStyles = new SliderTypeStyles()
                        {
                            scrollbar = new SliderTypeStyles.SliderAxisStyles() { horizontal = "MiniSliderhorizontal", vertical = "MiniSliderVertical" },
                            minMaxSliders = new SliderTypeStyles.SliderAxisStyles() { horizontal = "MiniMinMaxSliderHorizontal", vertical = "MiniMinMaxSlidervertical" },
                        };
                    }
                    horizontalScrollbarLeftButton = GUIStyle.none;
                    horizontalScrollbarRightButton = GUIStyle.none;
                    horizontalScrollbar = GUIStyle.none;
                    verticalScrollbarUpButton = GUIStyle.none;
                    verticalScrollbarDownButton = GUIStyle.none;
                    verticalScrollbar = GUIStyle.none;
                }
                else
                {
                    if (normalSliderStyles == null)
                    {
                        normalSliderStyles = new SliderTypeStyles()
                        {
                            scrollbar = new SliderTypeStyles.SliderAxisStyles() { horizontal = "horizontalscrollbarthumb", vertical = "verticalscrollbarthumb" },
                            minMaxSliders = new SliderTypeStyles.SliderAxisStyles() { horizontal = "horizontalMinMaxScrollbarThumb", vertical = "verticalMinMaxScrollbarThumb" },
                        };
                    }
                    horizontalScrollbarLeftButton = "horizontalScrollbarLeftbutton";
                    horizontalScrollbarRightButton = "horizontalScrollbarRightbutton";
                    horizontalScrollbar = GUI.skin.horizontalScrollbar;
                    verticalScrollbarUpButton = "verticalScrollbarUpbutton";
                    verticalScrollbarDownButton = "verticalScrollbarDownbutton";
                    verticalScrollbar = GUI.skin.verticalScrollbar;
                }
            }
        }

        private Styles m_Styles;
        protected Styles styles
        {
            get
            {
                if (m_Styles == null)
                    m_Styles = new Styles(m_MinimalGUI);
                return m_Styles;
            }
        }

        public Rect rect
        {
            get { return new Rect(drawRect.x, drawRect.y, drawRect.width + (m_VSlider ? styles.visualSliderWidth : 0), drawRect.height + (m_HSlider ? styles.visualSliderWidth : 0)); }
            set
            {
                Rect newDrawArea = new Rect(value.x, value.y, value.width - (m_VSlider ? styles.visualSliderWidth : 0), value.height - (m_HSlider ? styles.visualSliderWidth : 0));
                if (newDrawArea != m_DrawArea)
                {
                    if (m_ScaleWithWindow)
                    {
                        m_DrawArea = newDrawArea;
                        shownAreaInsideMargins = m_LastShownAreaInsideMargins;
                    }
                    else
                    {
                        m_Translation += new Vector2((newDrawArea.width - m_DrawArea.width) / 2, (newDrawArea.height - m_DrawArea.height) / 2);
                        m_DrawArea = newDrawArea;
                    }
                }
                EnforceScaleAndRange();
            }
        }
        public Rect drawRect { get { return m_DrawArea; } }

        public void SetShownHRangeInsideMargins(float min, float max)
        {
            float widthInsideMargins = drawRect.width - leftmargin - rightmargin;
            if (widthInsideMargins < kMinWidth) widthInsideMargins = kMinWidth;

            float denum = max - min;
            if (denum < kMinWidth) denum = kMinWidth;

            m_Scale.x = widthInsideMargins / denum;

            m_Translation.x = -min * m_Scale.x + leftmargin;
            EnforceScaleAndRange();
        }

        public void SetShownHRange(float min, float max)
        {
            float denum = max - min;
            if (denum < kMinWidth) denum = kMinWidth;

            m_Scale.x = drawRect.width / denum;

            m_Translation.x = -min * m_Scale.x;
            EnforceScaleAndRange();
        }

        public void SetShownVRangeInsideMargins(float min, float max)
        {
            float heightInsideMargins = drawRect.height - topmargin - bottommargin;
            if (heightInsideMargins < kMinHeight) heightInsideMargins = kMinHeight;

            float denum = max - min;
            if (denum < kMinHeight) denum = kMinHeight;

            if (m_UpDirection == YDirection.Positive)
            {
                m_Scale.y = -heightInsideMargins / denum;
                m_Translation.y = drawRect.height - min * m_Scale.y - topmargin;
            }
            else
            {
                m_Scale.y = heightInsideMargins / denum;
                m_Translation.y = -min * m_Scale.y - bottommargin;
            }
            EnforceScaleAndRange();
        }

        public void SetShownVRange(float min, float max)
        {
            float denum = max - min;
            if (denum < kMinHeight) denum = kMinHeight;

            if (m_UpDirection == YDirection.Positive)
            {
                m_Scale.y = -drawRect.height / denum;
                m_Translation.y = drawRect.height - min * m_Scale.y;
            }
            else
            {
                m_Scale.y = drawRect.height / denum;
                m_Translation.y = -min * m_Scale.y;
            }
            EnforceScaleAndRange();
        }

        // ShownArea is in curve space
        public Rect shownArea
        {
            set
            {
                float width = (value.width < kMinWidth) ? kMinWidth : value.width;
                float height = (value.height < kMinHeight) ? kMinHeight : value.height;

                if (m_UpDirection == YDirection.Positive)
                {
                    m_Scale.x = drawRect.width / width;
                    m_Scale.y = -drawRect.height / height;
                    m_Translation.x = -value.x * m_Scale.x;
                    m_Translation.y = drawRect.height - value.y * m_Scale.y;
                }
                else
                {
                    m_Scale.x = drawRect.width / width;
                    m_Scale.y = drawRect.height / height;
                    m_Translation.x = -value.x * m_Scale.x;
                    m_Translation.y = -value.y * m_Scale.y;
                }
                EnforceScaleAndRange();
            }
            get
            {
                if (m_UpDirection == YDirection.Positive)
                {
                    return new Rect(
                        -m_Translation.x / m_Scale.x,
                        -(m_Translation.y - drawRect.height) / m_Scale.y,
                        drawRect.width / m_Scale.x,
                        drawRect.height / -m_Scale.y
                    );
                }
                else
                {
                    return new Rect(
                        -m_Translation.x / m_Scale.x,
                        -m_Translation.y / m_Scale.y,
                        drawRect.width / m_Scale.x,
                        drawRect.height / m_Scale.y
                    );
                }
            }
        }

        public Rect shownAreaInsideMargins
        {
            set
            {
                shownAreaInsideMarginsInternal = value;
                EnforceScaleAndRange();
            }
            get
            {
                return shownAreaInsideMarginsInternal;
            }
        }

        private Rect shownAreaInsideMarginsInternal
        {
            set
            {
                float width = (value.width < kMinWidth) ? kMinWidth : value.width;
                float height = (value.height < kMinHeight) ? kMinHeight : value.height;

                float widthInsideMargins = drawRect.width - leftmargin - rightmargin;
                if (widthInsideMargins < kMinWidth) widthInsideMargins = kMinWidth;

                float heightInsideMargins = drawRect.height - topmargin - bottommargin;
                if (heightInsideMargins < kMinHeight) heightInsideMargins = kMinHeight;

                if (m_UpDirection == YDirection.Positive)
                {
                    m_Scale.x = widthInsideMargins / width;
                    m_Scale.y = -heightInsideMargins / height;
                    m_Translation.x = -value.x * m_Scale.x + leftmargin;
                    m_Translation.y = drawRect.height - value.y * m_Scale.y - topmargin;
                }
                else
                {
                    m_Scale.x = widthInsideMargins / width;
                    m_Scale.y = heightInsideMargins / height;
                    m_Translation.x = -value.x * m_Scale.x + leftmargin;
                    m_Translation.y = -value.y * m_Scale.y + topmargin;
                }
            }
            get
            {
                float leftmarginRel = leftmargin / m_Scale.x;
                float rightmarginRel = rightmargin / m_Scale.x;
                float topmarginRel = topmargin / m_Scale.y;
                float bottommarginRel = bottommargin / m_Scale.y;

                Rect area = shownArea;
                area.x += leftmarginRel;
                area.y -= topmarginRel;
                area.width -= leftmarginRel + rightmarginRel;
                area.height += topmarginRel + bottommarginRel;
                return area;
            }
        }

        public virtual Bounds drawingBounds
        {
            get
            {
                return new Bounds(
                    new Vector3((hBaseRangeMin + hBaseRangeMax) * 0.5f, (vBaseRangeMin + vBaseRangeMax) * 0.5f, 0),
                    new Vector3(hBaseRangeMax - hBaseRangeMin, vBaseRangeMax - vBaseRangeMin, 1)
                );
            }
        }


        // Utility transform functions

        public Matrix4x4 drawingToViewMatrix
        {
            get
            {
                return Matrix4x4.TRS(m_Translation, Quaternion.identity, new Vector3(m_Scale.x, m_Scale.y, 1));
            }
        }

        public Vector2 DrawingToViewTransformPoint(Vector2 lhs)
        { return new Vector2(lhs.x * m_Scale.x + m_Translation.x, lhs.y * m_Scale.y + m_Translation.y); }
        public Vector3 DrawingToViewTransformPoint(Vector3 lhs)
        { return new Vector3(lhs.x * m_Scale.x + m_Translation.x, lhs.y * m_Scale.y + m_Translation.y, 0); }

        public Vector2 ViewToDrawingTransformPoint(Vector2 lhs)
        { return new Vector2((lhs.x - m_Translation.x) / m_Scale.x , (lhs.y - m_Translation.y) / m_Scale.y); }
        public Vector3 ViewToDrawingTransformPoint(Vector3 lhs)
        { return new Vector3((lhs.x - m_Translation.x) / m_Scale.x , (lhs.y - m_Translation.y) / m_Scale.y, 0); }

        public Vector2 DrawingToViewTransformVector(Vector2 lhs)
        { return new Vector2(lhs.x * m_Scale.x, lhs.y * m_Scale.y); }
        public Vector3 DrawingToViewTransformVector(Vector3 lhs)
        { return new Vector3(lhs.x * m_Scale.x, lhs.y * m_Scale.y, 0); }

        public Vector2 ViewToDrawingTransformVector(Vector2 lhs)
        { return new Vector2(lhs.x / m_Scale.x, lhs.y / m_Scale.y); }
        public Vector3 ViewToDrawingTransformVector(Vector3 lhs)
        { return new Vector3(lhs.x / m_Scale.x, lhs.y / m_Scale.y, 0); }

        public Vector2 mousePositionInDrawing
        {
            get { return ViewToDrawingTransformPoint(Event.current.mousePosition); }
        }

        public Vector2 NormalizeInViewSpace(Vector2 vec)
        {
            vec = Vector2.Scale(vec, m_Scale);
            vec /= vec.magnitude;
            return Vector2.Scale(vec, new Vector2(1 / m_Scale.x, 1 / m_Scale.y));
        }

        // Utility mouse event functions

        private bool IsZoomEvent()
        {
            return (
                (Event.current.button == 1 && Event.current.alt) // right+alt drag
                //|| (Event.current.button == 0 && Event.current.command) // left+commend drag
                //|| (Event.current.button == 2 && Event.current.command) // middle+command drag

            );
        }

        private bool IsPanEvent()
        {
            return (
                (Event.current.button == 0 && Event.current.alt) // left+alt drag
                || (Event.current.button == 2 && !Event.current.command) // middle drag
            );
        }

        public ZoomableArea()
        {
            m_MinimalGUI = false;
        }

        public ZoomableArea(bool minimalGUI)
        {
            m_MinimalGUI = minimalGUI;
        }

        public ZoomableArea(bool minimalGUI, bool enableSliderZoom) : this(minimalGUI, enableSliderZoom, enableSliderZoom) {}

        public ZoomableArea(bool minimalGUI, bool enableSliderZoomHorizontal, bool enableSliderZoomVertical)
        {
            m_MinimalGUI = minimalGUI;
            m_EnableSliderZoomHorizontal = enableSliderZoomHorizontal;
            m_EnableSliderZoomVertical = enableSliderZoomVertical;
        }

        public void BeginViewGUI()
        {
            if (styles.horizontalScrollbar == null)
                styles.InitGUIStyles(m_MinimalGUI, allowSliderZoomHorizontal, allowSliderZoomVertical);

            if (enableMouseInput)
                HandleZoomAndPanEvents(m_DrawArea);

            horizontalScrollbarID = GUIUtility.GetControlID(EditorGUIExt.s_MinMaxSliderHash, FocusType.Passive);
            verticalScrollbarID = GUIUtility.GetControlID(EditorGUIExt.s_MinMaxSliderHash, FocusType.Passive);

            if (!m_MinimalGUI || Event.current.type != EventType.Repaint)
                SliderGUI();
        }

        public void HandleZoomAndPanEvents(Rect area)
        {
            GUILayout.BeginArea(area);

            area.x = 0;
            area.y = 0;
            int id = GUIUtility.GetControlID(zoomableAreaHash, FocusType.Passive, area);

            switch (Event.current.GetTypeForControl(id))
            {
                case EventType.MouseDown:
                    if (area.Contains(Event.current.mousePosition))
                    {
                        // Catch keyboard control when clicked inside zoomable area
                        // (used to restrict scrollwheel)
                        GUIUtility.keyboardControl = id;

                        if (IsZoomEvent() || IsPanEvent())
                        {
                            GUIUtility.hotControl = id;
                            m_MouseDownPosition = mousePositionInDrawing;

                            Event.current.Use();
                        }
                    }
                    break;
                case EventType.MouseUp:
                    //Debug.Log("mouse-up!");
                    if (GUIUtility.hotControl == id)
                    {
                        GUIUtility.hotControl = 0;

                        // If we got the mousedown, the mouseup is ours as well
                        // (no matter if the click was in the area or not)
                        m_MouseDownPosition = new Vector2(-1000000, -1000000);
                        //Event.current.Use();
                    }
                    break;
                case EventType.MouseDrag:
                    if (GUIUtility.hotControl != id) break;

                    if (IsZoomEvent())
                    {
                        // Zoom in around mouse down position
                        HandleZoomEvent(m_MouseDownPosition, false);
                        Event.current.Use();
                    }
                    else if (IsPanEvent())
                    {
                        // Pan view
                        Pan();
                        Event.current.Use();
                    }
                    break;
                case EventType.ScrollWheel:
                    if (!area.Contains(Event.current.mousePosition))
                        break;
                    if (m_IgnoreScrollWheelUntilClicked && GUIUtility.keyboardControl != id)
                        break;

                    // Zoom in around cursor position
                    HandleZoomEvent(mousePositionInDrawing, true);
                    Event.current.Use();
                    break;
            }

            GUILayout.EndArea();
        }

        public void EndViewGUI()
        {
            if (m_MinimalGUI && Event.current.type == EventType.Repaint)
                SliderGUI();
        }

        void SliderGUI()
        {
            if (!m_HSlider && !m_VSlider)
                return;

            using (new EditorGUI.DisabledScope(!enableMouseInput))
            {
                Bounds editorBounds = drawingBounds;
                Rect area = shownAreaInsideMargins;
                float min, max;
                float inset = styles.sliderWidth - styles.visualSliderWidth;
                float otherInset = (vSlider && hSlider) ? inset : 0;

                Vector2 scaleDelta = m_Scale;
                // Horizontal range slider
                if (m_HSlider)
                {
                    Rect hRangeSliderRect = new Rect(drawRect.x + 1, drawRect.yMax - inset, drawRect.width - otherInset, styles.sliderWidth);
                    float shownXRange = area.width;
                    float shownXMin = area.xMin;
                    if (allowSliderZoomHorizontal)
                    {
                        EditorGUIExt.MinMaxScroller(hRangeSliderRect, horizontalScrollbarID,
                            ref shownXMin, ref shownXRange,
                            editorBounds.min.x, editorBounds.max.x,
                            Mathf.NegativeInfinity, Mathf.Infinity,
                            styles.horizontalScrollbar, styles.horizontalMinMaxScrollbarThumb,
                            styles.horizontalScrollbarLeftButton, styles.horizontalScrollbarRightButton, true);
                    }
                    else
                    {
                        shownXMin = GUI.Scroller(hRangeSliderRect,
                            shownXMin, shownXRange, editorBounds.min.x, editorBounds.max.x,
                            styles.horizontalScrollbar, styles.horizontalMinMaxScrollbarThumb,
                            styles.horizontalScrollbarLeftButton, styles.horizontalScrollbarRightButton, true);
                    }
                    min = shownXMin;
                    max = shownXMin + shownXRange;
                    if (min > area.xMin)
                        min = Mathf.Min(min, max - rect.width / m_HScaleMax);
                    if (max < area.xMax)
                        max = Mathf.Max(max, min + rect.width / m_HScaleMax);
                    SetShownHRangeInsideMargins(min, max);
                }

                // Vertical range slider
                // Reverse y values since y increses upwards for the draw area but downwards for the slider
                if (m_VSlider)
                {
                    if (m_UpDirection == YDirection.Positive)
                    {
                        Rect vRangeSliderRect = new Rect(drawRect.xMax - inset, drawRect.y, styles.sliderWidth, drawRect.height - otherInset);
                        float shownYRange = area.height;
                        float shownYMin = -area.yMax;
                        if (allowSliderZoomVertical)
                        {
                            EditorGUIExt.MinMaxScroller(vRangeSliderRect, verticalScrollbarID,
                                ref shownYMin, ref shownYRange,
                                -editorBounds.max.y, -editorBounds.min.y,
                                Mathf.NegativeInfinity, Mathf.Infinity,
                                styles.verticalScrollbar, styles.verticalMinMaxScrollbarThumb,
                                styles.verticalScrollbarUpButton, styles.verticalScrollbarDownButton, false);
                        }
                        else
                        {
                            shownYMin = GUI.Scroller(vRangeSliderRect,
                                shownYMin, shownYRange, -editorBounds.max.y, -editorBounds.min.y,
                                styles.verticalScrollbar, styles.verticalMinMaxScrollbarThumb,
                                styles.verticalScrollbarUpButton, styles.verticalScrollbarDownButton, false);
                        }
                        min = -(shownYMin + shownYRange);
                        max = -shownYMin;
                        if (min > area.yMin)
                            min = Mathf.Min(min, max - rect.height / m_VScaleMax);
                        if (max < area.yMax)
                            max = Mathf.Max(max, min + rect.height / m_VScaleMax);
                        SetShownVRangeInsideMargins(min, max);
                    }
                    else
                    {
                        Rect vRangeSliderRect = new Rect(drawRect.xMax - inset, drawRect.y, styles.sliderWidth, drawRect.height - otherInset);
                        float shownYRange = area.height;
                        float shownYMin = area.yMin;
                        if (allowSliderZoomVertical)
                        {
                            EditorGUIExt.MinMaxScroller(vRangeSliderRect, verticalScrollbarID,
                                ref shownYMin, ref shownYRange,
                                editorBounds.min.y, editorBounds.max.y,
                                Mathf.NegativeInfinity, Mathf.Infinity,
                                styles.verticalScrollbar, styles.verticalMinMaxScrollbarThumb,
                                styles.verticalScrollbarUpButton, styles.verticalScrollbarDownButton, false);
                        }
                        else
                        {
                            shownYMin = GUI.Scroller(vRangeSliderRect,
                                shownYMin, shownYRange, editorBounds.min.y, editorBounds.max.y,
                                styles.verticalScrollbar, styles.verticalMinMaxScrollbarThumb,
                                styles.verticalScrollbarUpButton, styles.verticalScrollbarDownButton, false);
                        }
                        min = shownYMin;
                        max = shownYMin + shownYRange;
                        if (min > area.yMin)
                            min = Mathf.Min(min, max - rect.height / m_VScaleMax);
                        if (max < area.yMax)
                            max = Mathf.Max(max, min + rect.height / m_VScaleMax);
                        SetShownVRangeInsideMargins(min, max);
                    }
                }

                if (uniformScale)
                {
                    float aspect = drawRect.width / drawRect.height;
                    scaleDelta -= m_Scale;
                    var delta = new Vector2(-scaleDelta.y * aspect, -scaleDelta.x / aspect);

                    m_Scale -= delta;
                    m_Translation.x -= scaleDelta.y / 2;
                    m_Translation.y -= scaleDelta.x / 2;
                    EnforceScaleAndRange();
                }
            }
        }

        private void Pan()
        {
            if (!m_HRangeLocked)
                m_Translation.x += Event.current.delta.x;
            if (!m_VRangeLocked)
                m_Translation.y += Event.current.delta.y;

            EnforceScaleAndRange();
        }

        private void HandleZoomEvent(Vector2 zoomAround, bool scrollwhell)
        {
            // Get delta (from scroll wheel or mouse pad)
            // Add x and y delta to cover all cases
            // (scrool view has only y or only x when shift is pressed,
            // while mouse pad has both x and y at all times)
            float delta = Event.current.delta.x + Event.current.delta.y;

            if (scrollwhell)
                delta = -delta;

            // Scale multiplier. Don't allow scale of zero or below!
            float scale = Mathf.Max(0.01F, 1 + delta * 0.01F);

            // Cap scale when at min width to not "glide" away when zooming closer
            float width = shownAreaInsideMargins.width;
            if (width / scale <= kMinWidth)
                return;

            SetScaleFocused(zoomAround, scale * m_Scale, Event.current.shift, EditorGUI.actionKey);
        }

        // Sets a new scale, keeping focalPoint in the same relative position
        public void SetScaleFocused(Vector2 focalPoint, Vector2 newScale)
        {
            SetScaleFocused(focalPoint, newScale, false, false);
        }

        public void SetScaleFocused(Vector2 focalPoint, Vector2 newScale, bool lockHorizontal, bool lockVertical)
        {
            if (uniformScale)
                lockHorizontal = lockVertical = false;
            else
            {
                // if an axis is locked by default, it is as if that modifier key is permanently held down
                // actually pressing the key then lifts the lock. In other words, LockedByDefault acts like an inversion.
                if (hZoomLockedByDefault)
                    lockHorizontal = !lockHorizontal;

                if (hZoomLockedByDefault)
                    lockVertical = !lockVertical;
            }

            if (!m_HRangeLocked && !lockHorizontal)
            {
                // Offset to make zoom centered around cursor position
                m_Translation.x -= focalPoint.x * (newScale.x - m_Scale.x);

                // Apply zooming
                m_Scale.x = newScale.x;
            }
            if (!m_VRangeLocked && !lockVertical)
            {
                // Offset to make zoom centered around cursor position
                m_Translation.y -= focalPoint.y * (newScale.y - m_Scale.y);

                // Apply zooming
                m_Scale.y = newScale.y;
            }

            EnforceScaleAndRange();
        }

        public void SetTransform(Vector2 newTranslation, Vector2 newScale)
        {
            m_Scale = newScale;
            m_Translation = newTranslation;
            EnforceScaleAndRange();
        }

        public void EnforceScaleAndRange()
        {
            // Minimum scale might also be constrained by maximum range
            float constrainedHScaleMin = rect.width / m_HScaleMin;
            float constrainedVScaleMin = rect.height / m_VScaleMin;
            if (hRangeMax != Mathf.Infinity && hRangeMin != Mathf.NegativeInfinity)
                constrainedHScaleMin = Mathf.Min(constrainedHScaleMin, hRangeMax - hRangeMin);
            if (vRangeMax != Mathf.Infinity && vRangeMin != Mathf.NegativeInfinity)
                constrainedVScaleMin = Mathf.Min(constrainedVScaleMin, vRangeMax - vRangeMin);

            Rect oldArea = m_LastShownAreaInsideMargins;
            Rect newArea = shownAreaInsideMargins;
            if (newArea == oldArea)
                return;

            float epsilon = 0.00001f;

            if (newArea.width < oldArea.width - epsilon)
            {
                float xLerp = Mathf.InverseLerp(oldArea.width, newArea.width, rect.width / m_HScaleMax);
                newArea = new Rect(
                    Mathf.Lerp(oldArea.x, newArea.x, xLerp),
                    newArea.y,
                    Mathf.Lerp(oldArea.width, newArea.width, xLerp),
                    newArea.height
                );
            }
            if (newArea.height < oldArea.height - epsilon)
            {
                float yLerp = Mathf.InverseLerp(oldArea.height, newArea.height, rect.height / m_VScaleMax);
                newArea = new Rect(
                    newArea.x,
                    Mathf.Lerp(oldArea.y, newArea.y, yLerp),
                    newArea.width,
                    Mathf.Lerp(oldArea.height, newArea.height, yLerp)
                );
            }
            if (newArea.width > oldArea.width + epsilon)
            {
                float xLerp = Mathf.InverseLerp(oldArea.width, newArea.width, constrainedHScaleMin);
                newArea = new Rect(
                    Mathf.Lerp(oldArea.x, newArea.x, xLerp),
                    newArea.y,
                    Mathf.Lerp(oldArea.width, newArea.width, xLerp),
                    newArea.height
                );
            }
            if (newArea.height > oldArea.height + epsilon)
            {
                float yLerp = Mathf.InverseLerp(oldArea.height, newArea.height, constrainedVScaleMin);
                newArea = new Rect(
                    newArea.x,
                    Mathf.Lerp(oldArea.y, newArea.y, yLerp),
                    newArea.width,
                    Mathf.Lerp(oldArea.height, newArea.height, yLerp)
                );
            }

            // Enforce ranges
            if (newArea.xMin < hRangeMin)
                newArea.x = hRangeMin;
            if (newArea.xMax > hRangeMax)
                newArea.x = hRangeMax - newArea.width;
            if (newArea.yMin < vRangeMin)
                newArea.y = vRangeMin;
            if (newArea.yMax > vRangeMax)
                newArea.y = vRangeMax - newArea.height;

            shownAreaInsideMarginsInternal = newArea;
            m_LastShownAreaInsideMargins = newArea;
        }

        public float PixelToTime(float pixelX, Rect rect)
        {
            Rect area = shownArea;
            return ((pixelX - rect.x) * area.width / rect.width + area.x);
        }

        public float TimeToPixel(float time, Rect rect)
        {
            Rect area = shownArea;
            return (time - area.x) / area.width * rect.width + rect.x;
        }

        public float PixelDeltaToTime(Rect rect)
        {
            return shownArea.width / rect.width;
        }

        public void UpdateZoomScale(float fMaxScaleValue, float fMinScaleValue)
        {
            // Update/reset the values of the scale to new zoom range, if the current values do not fall in the range of the new resolution

            if (m_Scale.y > fMaxScaleValue || m_Scale.y < fMinScaleValue)
            {
                m_Scale.y = m_Scale.y > fMaxScaleValue ? fMaxScaleValue : fMinScaleValue;
            }

            if (m_Scale.x > fMaxScaleValue || m_Scale.x < fMinScaleValue)
            {
                m_Scale.x = m_Scale.x > fMaxScaleValue ? fMaxScaleValue : fMinScaleValue;
            }
        }
    }
} // namespace
