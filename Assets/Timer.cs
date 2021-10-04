using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class Timer : MonoBehaviour
{
    private TMP_Text text;

    public float time = 180;

    void Start()
    {
        text = GetComponent<TMP_Text>();
    }

    // Update is called once per frame
    void Update()
    {
        time -= Time.deltaTime;

        if(time <= 0)
        {
            GameManager.instance.EndGame();
            return;
        }

        int floored = Mathf.FloorToInt(time);
        int minutes = floored / 60;
        text.text = minutes + ":" + (floored - (minutes * 60));
    }
}
