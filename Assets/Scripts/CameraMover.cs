using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMover : MonoBehaviour
{
    public float minSpawnHeight = 15f;
    public float spawnOffset = 7.5f;
    public float cameraOffset = 2.5f;
    [Range(0f, 1f)]
    public float movementSpeed = 0.333f;

    private float minCameraHeight;
    private float cameraHeight;
    private List<Transform> m_spawns = new List<Transform>();

    private void OnValidate()
    {
        minCameraHeight = (minSpawnHeight - spawnOffset) + cameraOffset;
    }

    private void Start()
    {
        minCameraHeight = (minSpawnHeight - spawnOffset) + cameraOffset;

        GameManager.onJoin += OnJoin;

        cameraHeight = GameManager.worldCamera.transform.position.y;

        foreach (var spawn in FindObjectsOfType<BirdSpawn>())
            m_spawns.Add(spawn.transform);
    }

    private void OnJoin(Player player)
    {
        m_spawns.Add(player.birdSpawn);
    }

    void Update()
    {
        if (!Bird.highestBird)
            return;

        float height = Bird.highestBird.transform.position.y;

        Vector3 cameraPosition = GameManager.worldCamera.transform.position;

        float newCameraHeight = height + cameraOffset;
        if (newCameraHeight > minCameraHeight)
        {
            cameraHeight = newCameraHeight;
        }

        float newSpawnHeight = (cameraHeight - cameraOffset) + spawnOffset;

        if (cameraHeight < (cameraPosition.y - 0.01f) || cameraHeight > (cameraPosition.y + 0.01f))
        {
            cameraPosition.y = Mathf.Lerp(cameraPosition.y, cameraHeight, movementSpeed * Time.deltaTime);

            if (m_spawns.Count > 0)
            {
                float spawnHeight = m_spawns[0].position.y;
                spawnHeight = Mathf.Lerp(spawnHeight, newSpawnHeight, movementSpeed * Time.deltaTime);

                foreach (var spawn in m_spawns)
                {
                    Vector3 pos = spawn.position;
                    pos.y = spawnHeight;
                    spawn.position = pos;
                }
            }
        }
        else
        {
            cameraPosition.y = cameraHeight;
            foreach (var spawn in m_spawns)
            {
                Vector3 pos = spawn.position;
                pos.y = newSpawnHeight;
                spawn.position = pos;
            }
        }

        GameManager.worldCamera.transform.position = cameraPosition;
    }
}
