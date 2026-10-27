class_name GibberishVoice
extends RefCounted

const RATE := 22050
const SECONDS := 0.42


static func stream_for(line: String) -> AudioStreamWAV:
	var stream := _blank()
	if line == "":
		return stream
	stream.data = _samples(line, int(float(RATE) * SECONDS))
	return stream


static func _blank() -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.data = PackedByteArray()
	return stream


static func _samples(line: String, frames: int) -> PackedByteArray:
	var data := PackedByteArray()
	data.resize(frames * 2)
	var take := mini(line.length(), 4)
	var index := 0
	while index < frames:
		var time := float(index) / float(RATE)
		var sample := _tone(line, take, time) * _envelope(index, frames)
		data.encode_s16(index * 2, int(clampf(sample, -1.0, 1.0) * 30000.0))
		index += 1
	return data


static func _tone(line: String, take: int, time: float) -> float:
	if take <= 0:
		return 0.0
	var sample := 0.0
	var cursor := 0
	while cursor < take:
		var freq := 180.0 + float(line.unicode_at(cursor) % 40) * 9.0
		freq += float(cursor) * 30.0
		sample += sin(TAU * freq * time) * (0.18 / float(take))
		cursor += 1
	return sample


static func _envelope(index: int, frames: int) -> float:
	if index < 400:
		return float(index) / 400.0
	if index > frames - 800:
		return float(frames - index) / 800.0
	return 1.0
