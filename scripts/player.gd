extends CharacterBody2D

# --- Player Stats ---
@export var speed: float = 200.0
@export var max_health: int = 100
@export var max_hunger: int = 100
@export var max_stamina: int = 100

var health: int = max_health
var hunger: float = max_hunger
var stamina: float = max_stamina
var is_running: bool = false

# --- Hunger drain over time ---
var hunger_drain_rate: float = 0.5  # per second
var health_drain_rate: float = 2.0  # when starving

# --- Signals for UI ---
signal health_changed(new_health)
signal hunger_changed(new_hunger)
signal stamina_changed(new_stamina)
signal player_died

func _ready():
    emit_all_stats()

func _physics_process(delta):
    handle_movement(delta)
    handle_survival(delta)
    move_and_slide()

func handle_movement(delta):
    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    
    is_running = Input.is_action_pressed("sprint") and stamina > 0
    var current_speed = speed * 1.6 if is_running else speed
    
    velocity = input_dir * current_speed
    
    # Stamina drain while running
    if is_running and input_dir != Vector2.ZERO:
        stamina -= 15.0 * delta
        stamina = max(stamina, 0)
    else:
        stamina += 8.0 * delta
        stamina = min(stamina, max_stamina)
    
    emit_signal("stamina_changed", stamina)

func handle_survival(delta):
    # Hunger decreases over time
    hunger -= hunger_drain_rate * delta
    hunger = max(hunger, 0)
    emit_signal("hunger_changed", hunger)
    
    # If starving, lose health
    if hunger <= 0:
        take_damage(health_drain_rate * delta)

func take_damage(amount: float):
    health -= int(amount)
    health = max(health, 0)
    emit_signal("health_changed", health)
    
    if health <= 0:
        emit_signal("player_died")
        die()

func heal(amount: int):
    health = min(health + amount, max_health)
    emit_signal("health_changed", health)

func eat(food_value: float):
    hunger = min(hunger + food_value, max_hunger)
    emit_signal("hunger_changed", hunger)

func die():
    # TODO: Death animation, respawn, or game over screen
    print("Player died!")
    get_tree().reload_current_scene()

func emit_all_stats():
    emit_signal("health_changed", health)
    emit_signal("hunger_changed", hunger)
    emit_signal("stamina_changed", stamina)

func get_save_data() -> Dictionary:
    return {
        "position": {"x": position.x, "y": position.y},
        "health": health,
        "hunger": hunger,
        "stamina": stamina
    }

func load_save_data(data: Dictionary):
    position = Vector2(data["position"]["x"], data["position"]["y"])
    health = data["health"]
    hunger = data["hunger"]
    stamina = data["stamina"]
    emit_all_stats()
