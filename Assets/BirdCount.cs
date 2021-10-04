using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class BirdCount : MonoBehaviour
{
    private TMP_Text text;
    public int player;
    void Start()
    {
        text = GetComponent<TMP_Text>();
        text.color = GameManager.instance.playerColors[player].mainColor;
    }

    // Update is called once per frame
    void Update()
    {
        if(GameManager.players.Length > player)
        {
            text.gameObject.SetActive(true);
            text.text = GameManager.players[player].birdCount.ToString();
        }
        else
            text.gameObject.SetActive(false);
    }
}
