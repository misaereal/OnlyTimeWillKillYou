extends Node

const MUSIC_GAMEPLAY: String = "res://Assets/Sound/0920 gameplay final version.mp3"
const SFX_ATTACK: String = "res://Assets/Sound/Attacking one-shot.wav"
const SFX_GAME_OVER: String = "res://Assets/Sound/Game Over.wav"
const SFX_HURT: String = "res://Assets/Sound/Hurt_1.wav"
const SFX_JUMP: String = "res://Assets/Sound/Jump_1.wav"
const SFX_LEVEL_COMPLETE: String = "res://Assets/Sound/Level Complete.wav"

@export var sfx_volume_db: float = 0.0
@export var music_volume_db: float = -5.0

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE: int = 8

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	_music_player.volume_db = music_volume_db
	add_child(_music_player)

	for i in range(SFX_POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		p.volume_db = sfx_volume_db
		add_child(p)
		_sfx_players.append(p)

func play_sfx(path: String, volume_offset_db: float = 0.0) -> void:
	var stream: AudioStream = load(path)
	if not stream:
		push_warning("SFX introuvable : " + path)
		return

	for p in _sfx_players:
		if not p.playing:
			p.stream = stream
			p.volume_db = sfx_volume_db + volume_offset_db
			p.play()
			return

	# aucun player libre dans le pool, on prend le premier et on le coupe
	_sfx_players[0].stream = stream
	_sfx_players[0].volume_db = sfx_volume_db + volume_offset_db
	_sfx_players[0].play()

func play_music(path: String, loop: bool = true) -> void:
	var stream: AudioStream = load(path)
	if not stream:
		push_warning("Musique introuvable : " + path)
		return

	if _music_player.stream == stream and _music_player.playing:
		return  # déjà en train de jouer, on relance pas depuis le début

	if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.loop = loop

	_music_player.stream = stream
	_music_player.play()

func stop_music() -> void:
	_music_player.stop()

func set_sfx_volume(db: float) -> void:
	sfx_volume_db = db
	for p in _sfx_players:
		p.volume_db = db

func set_music_volume(db: float) -> void:
	music_volume_db = db
	_music_player.volume_db = db
