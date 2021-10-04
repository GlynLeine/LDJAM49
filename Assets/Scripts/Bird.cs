using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bird : MonoBehaviour
{
    [System.NonSerialized]
    public Player player;

    public static Bird highestBird;

    public bool trackheight;

    private void Start()
    {
        GetComponent<Rigidbody>().centerOfMass = Vector3.zero;
    }

    private void OnCollisionEnter(Collision collision)
    {
        player.HandleBirdCollision(this, collision);
    }

    private void Update()
    {
        float height = transform.position.y;
        float maxHeight = highestBird ? highestBird.transform.position.y : 0f;

        if (height <= -2f)
            player.HandleBirdDeath(this);
        else if (trackheight && height > maxHeight)
        {
            highestBird = this;
        }
    }
}
