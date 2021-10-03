using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.UI;

public class Player : MonoBehaviour
{
    private PlayerInput m_input;

    private void Awake()
    {
        m_input = GetComponent<PlayerInput>();
        m_input.camera = GameManager.worldCamera;
        m_input.uiInputModule = GameManager.uiInputModule;
    }

    public Player Connect(PlayerInput input)
    {
        m_input.SwitchCurrentControlScheme(input.currentControlScheme, input.devices.ToArray());

        Debug.Log("Connected " + m_input.currentControlScheme);
        return this;
    }

    public void Disconnect()
    {
        Debug.Log("Disconnected");
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
