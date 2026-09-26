extends Node

const SAVE_PATH = "user://rust_and_ruin_save.json"

func save_game(player, inventory, day_night) -> bool:
    var save_data = {
        "version": "1.0",
        "timestamp": Time.get_datetime_string_from_system(),
        "player": player.get_save_data(),
        "inventory": inventory.get_save_data(),
        "world": day_night.get_save_data()
    }
    
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        print("❌ Failed to open save file for writing")
        return false
    
    var json_string = JSON.stringify(save_data, "\t")
    file.store_string(json_string)
    file.close()
    print("✅ Game saved successfully!")
    return true

func load_game(player, inventory, day_night) -> bool:
    if not FileAccess.file_exists(SAVE_PATH):
        print("⚠️ No save file found")
        return false
    
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    var json_string = file.get_as_text()
    file.close()
    
    var json = JSON.new()
    var error = json.parse(json_string)
    if error != OK:
        print("❌ Failed to parse save file")
        return false
    
    var save_data = json.data
    player.load_save_data(save_data["player"])
    inventory.load_save_data(save_data["inventory"])
    day_night.load_save_data(save_data["world"])
    print("✅ Game loaded successfully!")
    return true

func delete_save():
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(SAVE_PATH)
        print("🗑️ Save file deleted")
