using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UAVPAPI;
using System.IO;
using System.Linq;

namespace UAVPAPI
{
    [CustomEditor(typeof(UAVP))]
    public class UAVPEditor : Editor
    {
        SerializedProperty _autoPlay;
        SerializedProperty _loop;
        SerializedProperty _mute;
        SerializedProperty _videoMat;
        SerializedProperty _videoRawImage;
        SerializedProperty _elapsedTime;
        SerializedProperty _totalTime;
        SerializedProperty _seekbar;
        SerializedProperty _mediaURI;
        SerializedProperty _logLevel;
        SerializedProperty _mediaPlayType;

        private string[] _playType;

        private void OnEnable()
        {
            _autoPlay       = serializedObject.FindProperty("autoPlay");
            _loop           = serializedObject.FindProperty("loop");
            _mute           = serializedObject.FindProperty("mute");
            _videoMat       = serializedObject.FindProperty("videoMat");
            _videoRawImage  = serializedObject.FindProperty("videoRawImage");
            _elapsedTime    = serializedObject.FindProperty("elapsedTime");
            _totalTime      = serializedObject.FindProperty("totalTime");
            _seekbar        = serializedObject.FindProperty("seekbar");
            _mediaURI       = serializedObject.FindProperty("mediaURI");
            _logLevel       = serializedObject.FindProperty("logLevel");
            _mediaPlayType  = serializedObject.FindProperty("mediaPlayType");
        }

        public override void OnInspectorGUI()
        {
            UAVP uavpEditor = (UAVP)target;

            EditorGUI.BeginChangeCheck();

            // Additional Fields
            EditorGUILayout.Space();
            EditorStyles.label.fontStyle = FontStyle.Bold;
            EditorGUILayout.LabelField("Additional Properties:");

            GUILayout.BeginVertical("Box");

            GUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("Auto Play:", GUILayout.MinWidth(10));
            _autoPlay.boolValue = EditorGUILayout.Toggle(_autoPlay.boolValue, EditorStyles.radioButton);
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("Loop:", GUILayout.MinWidth(10));
            _loop.boolValue = EditorGUILayout.Toggle(_loop.boolValue, EditorStyles.radioButton);
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("Mute:", GUILayout.MinWidth(10));
            _mute.boolValue = EditorGUILayout.Toggle(_mute.boolValue, EditorStyles.radioButton);
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            int[] logOptions = {0, 1, 2, 3};
            string[] logOptionsText = { "Debug", "Source", "Porting", "System" };
            _logLevel.intValue = EditorGUILayout.IntPopup("LogLevel", _logLevel.intValue, logOptionsText, logOptions);
            GUILayout.EndHorizontal();

            GUILayout.EndVertical();

            _playType = new string[] { "Media Streaming", "Local", "Asset" };
            _mediaPlayType.intValue = GUILayout.SelectionGrid(_mediaPlayType.intValue, _playType, _playType.Length, EditorStyles.miniButton);
            _mediaPlayType.intValue = Mathf.Clamp(_mediaPlayType.intValue, 0, _playType.Length);

            // Streaming Video Field
            if (_mediaPlayType.intValue == 0)
            {
                EditorGUILayout.Space();
                EditorGUILayout.LabelField("URL : ");
                EditorStyles.textField.wordWrap = true;

                _mediaURI.stringValue = EditorGUILayout.TextField(_mediaURI.stringValue, GUILayout.Height(30));
                EditorStyles.textField.wordWrap = false;
            }

            // Local Video Field
            if (_mediaPlayType.intValue == 1)
            {
                
            }

            // Asset Video Path Field
            if (_mediaPlayType.intValue == 2)
            {
                
            }

            // Rendering Field
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Objects for which video will be Rendered");
            GUILayout.BeginVertical("Box");
            EditorGUILayout.PropertyField(_videoMat, new GUIContent("Material"), true);
            EditorGUILayout.PropertyField(_videoRawImage, new GUIContent("RawImage"), true);
            GUILayout.EndVertical();

            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Media Control UI");
            GUILayout.BeginVertical("Box");
            EditorGUILayout.PropertyField(_elapsedTime, new GUIContent("Current Time"), true);
            EditorGUILayout.PropertyField(_totalTime, new GUIContent("Media TotalTime"), true);
            EditorGUILayout.PropertyField(_seekbar, new GUIContent("Media SeekBar"), true);
            GUILayout.EndVertical();

            if (EditorGUI.EndChangeCheck())
            {
                serializedObject.ApplyModifiedProperties();
            }
        }
    }
}