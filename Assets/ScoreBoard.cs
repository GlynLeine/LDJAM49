using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class ScoreBoard : MonoBehaviour
{
    public TMP_Text winner;
    public TMP_Text[] playerScores;    

    void Start()
    {
        winner.color = GameManager.instance.playerColors[GameManager.winner.index].mainColor;
        winner.text = "Player " + (GameManager.winner.index + 1) + " won!!!";

        for(int i = 0; i < GameManager.players.Length; i++)
        {
            playerScores[i].color = GameManager.instance.playerColors[i].mainColor;
            playerScores[i].text = GameManager.scores[i] + " Birds";
            playerScores[i].enabled = true;
        }
    }
}
