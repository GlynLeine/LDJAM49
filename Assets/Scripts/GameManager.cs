using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.UI;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem.Users;
using UnityEngine.InputSystem.LowLevel;

public class GameManager : MonoBehaviour
{
    public static int startingScene = 1;

    public InputActionReference joinAction;

    private Dictionary<PlayerInput, Player> m_playerMap = new Dictionary<PlayerInput, Player>();
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

    private static List<MultiplayerEventSystem> m_eventSystems = new List<MultiplayerEventSystem>();
    public static MultiplayerEventSystem[] eventSystems
    {
        get
        {
            if (m_eventSystems.Count == 0)
                m_eventSystems.AddRange(FindObjectsOfType<MultiplayerEventSystem>());

            return m_eventSystems.ToArray();
        }
    }

    private static List<InputSystemUIInputModule> m_uiInputModules = new List<InputSystemUIInputModule>();
    public static InputSystemUIInputModule[] uiInputModules
    {
        get
        {
            if (m_uiInputModules.Count == 0)
                foreach (var es in eventSystems)
                    m_uiInputModules.Add(es.GetComponent<InputSystemUIInputModule>());

            return m_uiInputModules.ToArray();
        }
    }

    public static void AddUIInput(MultiplayerEventSystem eventSystem)
    {
        eventSystem.playerRoot = SetFirstSelected.uiRoot;
        eventSystem.firstSelectedGameObject = SetFirstSelected.firstSelected;
        m_eventSystems.Add(eventSystem);
        m_uiInputModules.Add(eventSystem.GetComponent<InputSystemUIInputModule>());
    }

    public static void UpdateFirstSelected()
    {
        foreach (var es in eventSystems)
        {
            es.playerRoot = SetFirstSelected.uiRoot;
            es.firstSelectedGameObject = SetFirstSelected.firstSelected;
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
            m_inputManager = GetComponent<PlayerInputManager>();
            joinAction.action.Enable();

            InputUser.onUnpairedDeviceUsed += OnUnpairedDeviceUsed;
            ++InputUser.listenForUnpairedDeviceActivity;

            m_instance = this;

            SceneManager.LoadScene(startingScene);
        }
    }

    private void OnUnpairedDeviceUsed(InputControl control, InputEventPtr eventPtr)
    {
        if(!joinAction.action.triggered)
            return;

        var device = control.device;

        if (PlayerInput.FindFirstPairedToDevice(device) != null)
            return;

        foreach (var scheme in joinAction.asset.controlSchemes)
        {
            if (scheme.SupportsDevice(device))
            {
                var input = m_inputManager.JoinPlayer(playerIndex: m_playerMap.Count, controlScheme: scheme.name, pairWithDevice: device);
                m_playerMap.Add(input, input.GetComponent<Player>());
            }
        }
    }

}
