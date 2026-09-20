extends Area2D

@export var speed: float = 900.0
@export var damage: int = 1
@export var lifetime: float = 2.0

var direction: float = 1.0  # 1 = droite, -1 = gauche

func _ready() -> void:
	body_entered.connect(_on_body_entered)

	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
