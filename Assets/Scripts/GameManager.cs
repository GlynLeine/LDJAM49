using System.Collections;
using System.Linq;
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

    public PlayerColor[] playerColors;

    private Dictionary<PlayerInput, Player> m_playerMap = new Dictionary<PlayerInput, Player>();
    private static Player m_winner;
    public static Player winner { get => m_winner; }

    private static int[] m_scores;
    public static int[] scores { get => m_scores; }

    private PlayerInputManager m_inputManager;
    private bool m_WASDFirst;
    private bool m_KeyboardAdded = false;

    private bool m_gameStarted = false;
    private Transform[] m_slots;

    public static event System.Action<Player> onJoin;

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

    public static Player[] players { get => instance.m_playerMap.Values.ToArray(); }

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
            return m_instance;
        }
    }

    public static void Validate()
    {
        if (!m_instance)
            SceneManager.LoadScene(0);
    }

    public void StartGame(Transform[] slots)
    {
        m_gameStarted = true;
        m_slots = slots;

        int i = 0;
        foreach (var player in m_playerMap.Values)
            player.StartGame(slots[i++]);
    }

    public void EndGame()
    {
        m_gameStarted = false;

        m_winner = Player.mostBirds;

        var plyrs = players;

        m_scores = new int[plyrs.Length];

        for (int i = 0; i < plyrs.Length; i++)
        {
            m_scores[i] = plyrs[i].birdCount;
            plyrs[i].EndGame();
        }

        SceneManager.LoadScene(3);
    }

    private void Awake()
    {
        onJoin = null;

        if (!m_instance)
        {
            DontDestroyOnLoad(gameObject);
            m_inputManager = GetComponent<PlayerInputManager>();

            InputUser.onUnpairedDeviceUsed += OnUnpairedDeviceUsed;
            InputUser.listenForUnpairedDeviceActivity++;
            joinAction.action.performed += OnJoin;
            joinAction.action.Enable();

            m_instance = this;

            SceneManager.LoadScene(startingScene);
        }
    }

    private void Update()
    {
        if (m_gameStarted && Bird.highestBird)
        {
            Debug.Log("Player " + Bird.highestBird.player.index + " Height: " + Bird.highestBird.transform.position.y);
            Debug.Log("Player " + Player.mostBirds.index + " Birds: " + Player.mostBirds.birdCount);
        }
    }

    private void OnDestroy()
    {
        InputUser.onUnpairedDeviceUsed -= OnUnpairedDeviceUsed;
        InputUser.listenForUnpairedDeviceActivity--;
    }

    private string PathDestination(string input)
    {
        var offset = input.LastIndexOf('/');
        return input.Substring(offset);
    }

    private void JoinPlayer(string scheme, InputDevice device)
    {
        var input = m_inputManager.JoinPlayer(playerIndex: m_playerMap.Count, controlScheme: scheme, pairWithDevice: device);
        input.transform.parent = transform;

        var player = input.GetComponent<Player>();
        player.playerColor = playerColors[input.playerIndex];
        player.index = input.playerIndex;

        if (m_gameStarted)
            player.StartGame(m_slots[input.playerIndex]);

        m_playerMap.Add(input, player);

        onJoin(player);
    }

    private void OnUnpairedDeviceUsed(InputControl control, InputEventPtr eventPtr)
    {
        if (m_gameStarted)
            return;

        var device = control.device;

        InputBinding validBinding = new InputBinding();
        bool found = false;

        var controlName = PathDestination(control.path);

        foreach (var binding in joinAction.action.bindings)
        {
            if (PathDestination(binding.path) == controlName)
            {
                validBinding = binding;
                found = true;
                break;
            }
        }

        if (!found)
            return;

        foreach (var scheme in joinAction.asset.controlSchemes)
        {
            if (scheme.bindingGroup == validBinding.groups)
            {
                if (device is Keyboard)
                {
                    m_WASDFirst = scheme.name == "WASD";
                    m_KeyboardAdded = true;
                    JoinPlayer(m_WASDFirst ? "Arrows" : "WASD", device);
                }
                else
                    JoinPlayer(scheme.name, device);
                return;
            }
        }
    }

    void OnJoin(InputAction.CallbackContext ctx)
    {
        if (m_gameStarted)
            return;

        if (!m_KeyboardAdded)
            return;

        var device = ctx.control.device;

        if (device is Keyboard)
        {
            InputBinding validBinding = new InputBinding();
            bool found = false;

            var controlName = PathDestination(ctx.control.path);

            foreach (var binding in joinAction.action.bindings)
            {
                if (PathDestination(binding.path) == controlName)
                {
                    validBinding = binding;
                    found = true;
                    break;
                }
            }

            if (!found)
                return;

            if (validBinding.groups == (m_WASDFirst ? "Arrows" : "WASD"))
            {
                joinAction.action.performed -= OnJoin;
                JoinPlayer(m_WASDFirst ? "WASD" : "Arrows", device);
            }
        }
    }
}
