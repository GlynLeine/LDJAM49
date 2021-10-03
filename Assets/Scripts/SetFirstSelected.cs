using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class SetFirstSelected : MonoBehaviour
{
    public static GameObject uiRoot;
    public static GameObject firstSelected;

    private void Awake()
    {
        firstSelected = gameObject;
        uiRoot = GetComponentInParent<Canvas>().gameObject;
        GameManager.UpdateFirstSelected();
    }
}
