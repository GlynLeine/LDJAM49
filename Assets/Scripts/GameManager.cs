using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.UI;
using UnityEngine.EventSystems;

public class GameManager : MonoBehaviour
{
    public static int startingScene = 1;

    private Dictionary<PlayerInput, Player> m_playerMap;
    private PlayerInputManager m_inputManager;

    private static Camera m_worldCamera;
    public static Camera worldCamera
    {
        get
        {
            if (!m_worldCamera)
                m_worldCamera = GameObject.FindGameObjectWithTag("WorldCamera").GetComponent<Camera>();

            return m_worldCamera;
        }
    }

    private static EventSystem m_eventSystem;
    public static EventSystem eventSystem
    {
        get
        {
            if (!m_eventSystem)
                m_eventSystem = FindObjectOfType<EventSystem>();

            return m_eventSystem;
        }
    }

    private static InputSystemUIInputModule m_uiInputModule;
    public static InputSystemUIInputModule uiInputModule
    {
        get
        {
            if (!m_uiInputModule)
                m_uiInputModule = eventSystem.GetComponent<InputSystemUIInputModule>();

            return m_uiInputModule;
        }
    }

    private static GameManager m_instance;
    public static GameManager instance
    {
        get
        {
            if (!m_instance)
                SceneManager.LoadScene(0);

            return m_instance;
        }
    }

    private void Awake()
    {
        if (!m_instance)
        {
            DontDestroyOnLoad(gameObject);
            m_instance = this;
            SceneManager.LoadScene(startingScene);
        }
    }

    void OnPlayerJoined(PlayerInput playerInput)
    {
        if (!m_playerMap.ContainsKey(playerInput))
        {
            m_playerMap.Add(playerInput, Instantiate(m_inputManager.playerPrefab, transform).GetComponent<Player>().Connect(playerInput));
        }
    }

    void OnPlayerLeft(PlayerInput playerInput)
    {
        if (m_playerMap.ContainsKey(playerInput))
        {
            m_playerMap[playerInput].Disconnect();
            m_playerMap.Remove(playerInput);
        }
    }
}
