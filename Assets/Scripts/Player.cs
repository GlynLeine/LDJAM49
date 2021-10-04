using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.UI;
using UnityEngine.UI;

public class Player : MonoBehaviour
{
    private PlayerInput m_input;
    public PlayerInput input { get => m_input; }
    public GameObject eventSystemPrefab;
    public GameObject birdPrefab;
    public float movementSpeed = 10f;
    public float fallSpeed = 4f;
    public int index;
    public PlayerColor playerColor;

    public GameObject towerPrefab;

    private Material[] m_birdMaterials;

    private Transform m_slot;
    private GameObject m_tower;
    public GameObject tower { get => m_tower; }
    private Transform m_birdSpawn;
    public Transform birdSpawn { get => m_birdSpawn; }

    private Bird m_currentBird;
    public Bird currentBird { get => m_currentBird; }

    private float m_movement = 0;
    private bool m_speedUp = false;

    private List<Bird> m_birds = new List<Bird>();
    private static Player m_mostBirds;
    public static Player mostBirds { get => m_mostBirds; }
    public int birdCount { get => m_birds.Count; }

    public static Image joinImage;
    private bool m_joining = false;
    private static Player m_maxJoinTimePlayer;
    private float m_joinTime;

    private void Awake()
    {
        var eventSystemObject = Instantiate(eventSystemPrefab);

        m_input = GetComponent<PlayerInput>();
        m_input.camera = GameManager.worldCamera;
        m_input.uiInputModule = eventSystemObject.GetComponent<InputSystemUIInputModule>();

        GameManager.AddUIInput(eventSystemObject.GetComponent<MultiplayerEventSystem>());
    }

    public void StartGame(Transform slot)
    {
        m_slot = slot;
        m_tower = Instantiate(towerPrefab, m_slot, false);
        m_birdSpawn = m_tower.GetComponentInChildren<BirdSpawn>().transform;

        m_birdMaterials = new Material[10];

        Material srcMaterial = birdPrefab.GetComponentInChildren<SkinnedMeshRenderer>().sharedMaterial;

        for (int i = 0; i < 10; i++)
        {
            float rOffset = Random.Range(-playerColor.rRange, playerColor.rRange);
            float gOffset = Random.Range(-playerColor.gRange, playerColor.gRange);
            float bOffset = Random.Range(-playerColor.bRange, playerColor.bRange);
            Color color = new Color(
                playerColor.mainColor.r + rOffset,
                playerColor.mainColor.g + gOffset,
                playerColor.mainColor.b + bOffset,
                playerColor.mainColor.a);

            m_birdMaterials[i] = new Material(srcMaterial);
            m_birdMaterials[i].SetColor("_SecondaryColor", color);
        }

        SpawnBird();
    }

    public void EndGame()
    {
        foreach (var bird in m_birds)
            Destroy(bird);
    }

    public void HandleBirdCollision(Bird bird, Collision collision)
    {
        if (bird == m_currentBird)
            SpawnBird();
    }

    public void HandleBirdDeath(Bird bird)
    {
        if (bird == m_currentBird)
            SpawnBird();

        m_birds.Remove(bird);

        if (m_mostBirds == this)
        {
            foreach (var player in GameManager.players)
                if (player.m_birds.Count > m_birds.Count)
                    m_mostBirds = player;
        }

        Destroy(bird.gameObject);
    }

    private void SpawnBird()
    {
        if (m_currentBird)
        {
            m_currentBird.GetComponent<Rigidbody>().isKinematic = false;
            m_currentBird.trackheight = true;
        }

        var birdObject = Instantiate(birdPrefab, m_birdSpawn.position, Quaternion.identity, m_tower.transform);
        birdObject.GetComponentInChildren<SkinnedMeshRenderer>().material = m_birdMaterials[Random.Range(0, 10)];
        m_currentBird = birdObject.GetComponent<Bird>();
        m_currentBird.player = this;

        m_birds.Add(m_currentBird);

        if (m_mostBirds)
        {
            if (m_mostBirds.m_birds.Count < m_birds.Count)
                m_mostBirds = this;
        }
        else
            m_mostBirds = this;
    }

    private void OnHorizontal(InputValue value)
    {
        m_movement = value.Get<float>();
    }

    private void OnDrop(InputValue value)
    {
        if (joinImage)
            m_joining = value.isPressed;
        else
            m_speedUp = value.isPressed;
    }

    private void Update()
    {
        if (joinImage)
            if (m_joining)
            {
                m_joinTime += Time.deltaTime;

                if (m_maxJoinTimePlayer)
                {
                    if (m_joinTime > m_maxJoinTimePlayer.m_joinTime)
                        m_maxJoinTimePlayer = this;
                }
                else
                    m_maxJoinTimePlayer = this;

                joinImage.fillAmount = m_maxJoinTimePlayer.m_joinTime / 3f;
            }
            else
            {
                m_joinTime = 0f;
                joinImage.fillAmount = m_maxJoinTimePlayer.m_joinTime / 3f;
            }

        if (!m_currentBird)
            return;

        var pos = m_currentBird.transform.position;

        pos.x += m_movement * movementSpeed * Time.deltaTime;
        pos.y -= (m_speedUp ? 2f : 1f) * fallSpeed * Time.deltaTime;

        m_currentBird.transform.position = pos;
    }
}
