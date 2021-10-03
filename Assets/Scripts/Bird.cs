using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bird : MonoBehaviour
{
    [System.NonSerialized]
    public Player player;

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
        if (transform.position.y <= -2f)
            player.HandleBirdDeath(this);
    }
}
