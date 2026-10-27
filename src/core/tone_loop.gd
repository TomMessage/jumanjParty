class_name ToneLoop
extends RefCounted

const RATE := 22050


static func rustle() -> AudioStreamWAV:
	return _noise(0.08, 1.0, 11)


static func drone() -> AudioStreamWAV:
	return _tone(92.0, 0.12, 1.0)


static func layer() -> AudioStreamWAV:
	return _tone(138.0, 0.08, 1.0)


static func _tone(freq: float, gain: float, seconds: float) -> AudioStreamWAV:
	var frames := int(float(RATE) * seconds)
	var data := PackedByteArray()
	data.resize(frames * 2)
	var index := 0
	while index < frames:
		var time := float(index) / float(RATE)
		var sample := sin(TAU * freq * time) * gain
		sample += sin(TAU * freq * 2.0 * time) * gain * 0.25
		data.encode_s16(index * 2, int(clampf(sample, -1.0, 1.0) * 30000.0))
		index += 1
	return _wav(data, frames)


static func _noise(gain: float, seconds: float, salt: int) -> AudioStreamWAV:
	var frames := int(float(RATE) * seconds)
	var rng := RandomNumberGenerator.new()
	rng.seed = 9087 + salt
	var data := PackedByteArray()
	data.resize(frames * 2)
	var index := 0
	while index < frames:
		var sample := rng.randf_range(-1.0, 1.0) * gain
		data.encode_s16(index * 2, int(clampf(sample, -1.0, 1.0) * 30000.0))
		index += 1
	return _wav(data, frames)


static func _wav(data: PackedByteArray, frames: int) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = frames
	stream.data = data
	return stream
