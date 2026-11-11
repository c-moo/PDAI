extends Node

# Variables in the global scene.
var playerBody: CharacterBody2D
var characterAlive: bool = true

var playerDamageZone: Area2D
var playerDamageAmount: int = 25
var playerHitbox: Area2D

var enemyDamageArea: Area2D
var enemyDamageAmount: int = 25

var enemyHitbox: Area2D
