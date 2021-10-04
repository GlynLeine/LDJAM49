using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "New Player Color", menuName = "Custom/Player Color", order = 1)]
public class PlayerColor : ScriptableObject
{
    public Color mainColor;
    [Range(0, 1)]
    public float rRange;
    [Range(0, 1)]
    public float gRange;
    [Range(0, 1)]
    public float bRange;
}
