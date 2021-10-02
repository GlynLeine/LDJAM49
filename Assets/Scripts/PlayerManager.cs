using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class PlayerManager : MonoBehaviour
{
    public GameObject playerPrefab;

    private static PlayerManager m_instance;
    public static PlayerManager instance
    {
        get
        {
            if (m_instance)
                return m_instance;

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
            SceneManager.LoadScene(1);
        }
    }

    void Update()
    {
    }
}
