extends Node

# --- Item Database ---
enum ItemType { RESOURCE, FOOD, TOOL, WEAPON, MATERIAL }

var inventory: Dictionary = {}
var max_slots: int = 20

signal inventory_updated
signal item_added(item_name)
signal item_removed(item_name)

# Predefined items
var item_database: Dictionary = {
    "wood": {"type": ItemType.RESOURCE, "stackable": true, "max_stack": 99, "icon": "wood_icon"},
    "stone": {"type": ItemType.RESOURCE, "stackable": true, "max_stack": 99, "icon": "stone_icon"},
    "berry": {"type": ItemType.FOOD, "stackable": true, "max_stack": 20, "food_value": 15.0, "icon": "berry_icon"},
    "cooked_meat": {"type": ItemType.FOOD, "stackable": true, "max_stack": 10, "food_value": 40.0, "icon": "meat_icon"},
    "wooden_axe": {"type": ItemType.TOOL, "stackable": false, "max_stack": 1, "damage": 10, "icon": "axe_icon"},
    "stone_sword": {"type": ItemType.WEAPON, "stackable": false, "max_stack": 1, "damage": 25, "icon": "sword_icon"},
    "campfire": {"type": ItemType.MATERIAL, "stackable": true, "max_stack": 5, "icon": "campfire_icon"},
}

# Crafting recipes: { result: { ingredient: amount } }
var recipes: Dictionary = {
    "wooden_axe": {"wood": 5, "stone": 2},
    "stone_sword": {"wood": 3, "stone": 8},
    "campfire": {"wood": 10, "stone": 5},
    "cooked_meat": {"berry": 2},  # placeholder recipe
}

func add_item(item_name: String, amount: int = 1) -> bool:
    if not item_database.has(item_name):
        return false
    
    var item_data = item_database[item_name]
    
    if inventory.has(item_name):
        if item_data["stackable"]:
            var current = inventory[item_name]
            var new_amount = min(current + amount, item_data["max_stack"])
            inventory[item_name] = new_amount
        else:
            return false  # Can't stack non-stackable items
    else:
        if inventory.size() >= max_slots:
            return false  # Inventory full
        inventory[item_name] = amount
    
    emit_signal("inventory_updated")
    emit_signal("item_added", item_name)
    return true

func remove_item(item_name: String, amount: int = 1) -> bool:
    if not inventory.has(item_name):
        return false
    
    inventory[item_name] -= amount
    if inventory[item_name] <= 0:
        inventory.erase(item_name)
    
    emit_signal("inventory_updated")
    emit_signal("item_removed", item_name)
    return true

func has_item(item_name: String, amount: int = 1) -> bool:
    return inventory.has(item_name) and inventory[item_name] >= amount

func can_craft(recipe_name: String) -> bool:
    if not recipes.has(recipe_name):
        return false
    for ingredient in recipes[recipe_name]:
        if not has_item(ingredient, recipes[recipe_name][ingredient]):
            return false
    return true

func craft(recipe_name: String) -> bool:
    if not can_craft(recipe_name):
        return false
    
    # Remove ingredients
    for ingredient in recipes[recipe_name]:
        remove_item(ingredient, recipes[recipe_name][ingredient])
    
    # Add crafted item
    add_item(recipe_name)
    return true

func get_save_data() -> Dictionary:
    return {"inventory": inventory.duplicate()}

func load_save_data(data: Dictionary):
    inventory = data["inventory"].duplicate()
    emit_signal("inventory_updated")
