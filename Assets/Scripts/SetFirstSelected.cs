using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class SetFirstSelected : MonoBehaviour
{
    private void Awake()
    {
        GameManager.eventSystem.firstSelectedGameObject = gameObject;
    }
}
