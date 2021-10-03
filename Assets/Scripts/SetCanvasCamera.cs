using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SetCanvasCamera : MonoBehaviour
{
    private void Start()
    {
        GetComponent<Canvas>().worldCamera = GameManager.worldCamera;
    }
}
