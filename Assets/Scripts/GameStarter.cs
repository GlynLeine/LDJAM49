using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameStarter : MonoBehaviour
{
    public Transform[] playerSlots;

    void Start()
    {
        var inst = GameManager.instance;
        if (inst)
            inst.StartGame(playerSlots);
    }

    private void OnDestroy()
    {
        var inst = GameManager.instance;
        if (inst)
            inst.EndGame();
    }
}
