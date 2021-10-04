using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class ArrowsJoin : MonoBehaviour
{
    public Image image;
    public GameObject textPrefab;
    public Transform playersText;

    private void Start()
    {
        GameManager.onJoin += OnJoin;
    }

    private void OnJoin(Player player)
    {
        if (player.input.currentControlScheme == "Arrows")
        {
            TMP_Text text = Instantiate(textPrefab, playersText).GetComponent<TMP_Text>();
            text.text = "P" + (player.index + 1);
            text.color = GameManager.instance.playerColors[player.index].mainColor;

            Color col = image.color;
            col.a = 0.5f;
            image.color = col;
        }
    }
}
