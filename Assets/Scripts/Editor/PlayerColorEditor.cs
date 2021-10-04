using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(PlayerColor))]
public class PlayerColorEditor : Editor
{
    PlayerColor playerColor;

    Color[] colors;

    private void RegenColors()
    {
        colors = new Color[10];

        for(int i = 0; i < 10; i++)
        {
            float rOffset = Random.Range(-playerColor.rRange, playerColor.rRange);
            float gOffset = Random.Range(-playerColor.gRange, playerColor.gRange);
            float bOffset = Random.Range(-playerColor.bRange, playerColor.bRange);
            colors[i] = new Color(
                playerColor.mainColor.r + rOffset,
                playerColor.mainColor.g + gOffset,
                playerColor.mainColor.b + bOffset,
                playerColor.mainColor.a);
        }
    }

    private void OnEnable()
    {
        playerColor = target as PlayerColor;

        RegenColors();
    }

    public override void OnInspectorGUI()
    {
        EditorGUI.BeginChangeCheck();
        base.OnInspectorGUI();

        if(EditorGUI.EndChangeCheck())
            RegenColors();

        EditorGUILayout.LabelField("Example Colors");
        
        bool wasEnabled = GUI.enabled;
        GUI.enabled = false;
        for(int i = 0; i < 10; i++)
        {
            EditorGUILayout.ColorField(colors[i]);
        }
        GUI.enabled = wasEnabled;
    }
}
