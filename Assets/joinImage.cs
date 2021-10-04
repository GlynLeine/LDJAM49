using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class joinImage : MonoBehaviour
{
    private Image m_img;
    void Start()
    {
        m_img = Player.joinImage = GetComponent<Image>();
    }

    private void Update()
    {
        if(m_img.fillAmount >= 1f)
        {
            SceneManager.LoadScene(2);
        }
    }
}
