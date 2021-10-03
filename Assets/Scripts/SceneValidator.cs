using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneValidator : MonoBehaviour
{
    private void Awake()
    {
        GameManager.startingScene = SceneManager.GetActiveScene().buildIndex;

        var inst = GameManager.instance;
    }
}
