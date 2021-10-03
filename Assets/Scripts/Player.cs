using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.UI;

public class Player : MonoBehaviour
{
    private PlayerInput m_input;
    public GameObject eventSystemPrefab;

    private void Awake()
    {
        var eventSystemObject = Instantiate(eventSystemPrefab);

        m_input = GetComponent<PlayerInput>();
        m_input.camera = GameManager.worldCamera;
        m_input.uiInputModule = eventSystemObject.GetComponent<InputSystemUIInputModule>();

        GameManager.AddUIInput(eventSystemObject.GetComponent<MultiplayerEventSystem>());
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
