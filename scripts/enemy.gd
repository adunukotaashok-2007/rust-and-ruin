extends CharacterBody2D

@export var speed: float = 80.0
@export var damage: int = 10
@export var max_health: int = 50
@export var detection_range: float = 300.0
@export var attack_range: float = 40.0

var health: int = max_health
var target: Node2D = null
var attack_cooldown: float = 0.0

signal enemy_died(position)

func _ready():
    health = max_health

func _physics_process(delta):
    if target == null:
        find_target()
        return
    
    var distance = position.distance_to(target.position)
    
    if distance > detection_range:
        target = null
        return
    
    if distance > attack_range:
        var direction = (target.position - position).normalized()
        velocity = direction * speed
    else:
        velocity = Vector2.ZERO
        attack_cooldown -= delta
        if attack_cooldown <= 0:
            attack()
            attack_cooldown = 1.5
    
    move_and_slide()

func find_target():
    var players = get_tree().get_nodes_in_group("player")
    if players.size() > 0:
        target = players[0]

func attack():
    if target and target.has_method("take_damage"):
        target.take_damage(damage)

func take_damage(amount: int):
    health -= amount
    if health <= 0:
        emit_signal("enemy_died", position)
        queue_free()
