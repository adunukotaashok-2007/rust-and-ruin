extends CanvasModulate

@export var day_duration: float = 120.0  # seconds for a full day
@export var night_color: Color = Color(0.15, 0.1, 0.25, 1.0)
@export var day_color: Color = Color(1.0, 0.95, 0.85, 1.0)
@export var sunset_color: Color = Color(0.9, 0.5, 0.3, 1.0)

var time_of_day: float = 0.0  # 0.0 = dawn, 0.25 = noon, 0.5 = dusk, 0.75 = midnight
var day_count: int = 1
var is_night: bool = false

signal day_started(day_number)
signal night_started(day_number)
signal time_changed(time)

func _process(delta):
    time_of_day += delta / day_duration
    
    if time_of_day >= 1.0:
        time_of_day -= 1.0
        day_count += 1
        emit_signal("day_started", day_count)
    
    update_lighting()
    check_night_transition()
    emit_signal("time_changed", time_of_day)

func update_lighting():
    if time_of_day < 0.2:
        # Dawn → Morning
        color = night_color.lerp(day_color, time_of_day / 0.2)
    elif time_of_day < 0.4:
        # Daytime
        color = day_color
    elif time_of_day < 0.5:
        # Sunset
        color = day_color.lerp(sunset_color, (time_of_day - 0.4) / 0.1)
    elif time_of_day < 0.6:
        # Dusk → Night
        color = sunset_color.lerp(night_color, (time_of_day - 0.5) / 0.1)
    else:
        # Night
        color = night_color

func check_night_transition():
    var was_night = is_night
    is_night = time_of_day > 0.55 or time_of_day < 0.15
    
    if is_night and not was_night:
        emit_signal("night_started", day_count)
        spawn_night_enemies()

func spawn_night_enemies():
    # TODO: Spawn dangerous creatures at night
    print("⚠️ Night %d — Enemies are approaching!" % day_count)

func get_save_data() -> Dictionary:
    return {"time_of_day": time_of_day, "day_count": day_count}

func load_save_data(data: Dictionary):
    time_of_day = data["time_of_day"]
    day_count = data["day_count"]
