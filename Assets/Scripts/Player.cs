using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.UI;

public class Player : MonoBehaviour
{
    private PlayerInput m_input;

    public GameObject eventSystemPrefab;
    public GameObject birdPrefab;
    public float movementSpeed = 10f;
    public float fallSpeed = 4f;

    public GameObject towerPrefab;

    private Transform m_slot;
    private GameObject m_tower;
    private Transform m_birdSpawn;
    private Bird m_currentBird;
    private float m_movement = 0;
    private bool m_speedUp = false;

    private List<Bird> m_birds;

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
        SpawnBird();
    }

    public void EndGame()
    {
        foreach(var bird in m_birds)
            Destroy(bird);
    }

    public void HandleBirdCollision(Bird bird, Collision collision)
    {
        if (bird == m_currentBird)
            SpawnBird();
    }

    public void HandleBirdDeath(Bird bird)
    {
        if(bird == m_currentBird)
            SpawnBird();

        Destroy(bird.gameObject);
    }

    private void SpawnBird()
    {
        if (m_currentBird)
            m_currentBird.GetComponent<Rigidbody>().isKinematic = false;

        var birdObject = Instantiate(birdPrefab, m_birdSpawn.position, Quaternion.identity, m_tower.transform);
        m_currentBird = birdObject.GetComponent<Bird>();
        m_currentBird.player = this;
    }

    private void OnHorizontal(InputValue value)
    {
        m_movement = value.Get<float>();
    }

    private void OnDrop(InputValue value)
    {
        m_speedUp = !m_speedUp;
    }

    private void Update()
    {
        if(!m_currentBird)
            return;

        var pos = m_currentBird.transform.position;

        pos.x += m_movement * movementSpeed * Time.deltaTime;
        pos.y -= (m_speedUp? 2f : 1f) * fallSpeed * Time.deltaTime;

        m_currentBird.transform.position = pos;
    }
}
