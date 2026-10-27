class_name ImageGuard
extends RefCounted


static func assess(image: Image) -> String:
	if image == null or image.is_empty():
		return "empty image"
	if image.get_width() < 32 or image.get_height() < 32:
		return "image too small"
	return _measure(image)


static func _measure(image: Image) -> String:
	var stats := _sample(image)
	if int(stats["count"]) == 0:
		return "no samples"
	if float(stats["mean"]) < 0.03:
		return "too dark mean %.3f" % float(stats["mean"])
	if float(stats["range"]) < 0.08:
		return "too flat range %.3f" % float(stats["range"])
	if float(stats["lit_ratio"]) < 0.08:
		return "not enough lit pixels"
	return ""


static func _sample(image: Image) -> Dictionary:
	var min_l := 1.0
	var max_l := 0.0
	var sum := 0.0
	var count := 0
	var lit := 0
	var y := 0
	while y < image.get_height():
		var x := 0
		while x < image.get_width():
			var color := image.get_pixel(x, y)
			var luma := color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
			sum += luma
			min_l = minf(min_l, luma)
			max_l = maxf(max_l, luma)
			if luma > 0.08:
				lit += 1
			count += 1
			x += 4
		y += 4
	var mean := 0.0
	var lit_ratio := 0.0
	if count > 0:
		mean = sum / float(count)
		lit_ratio = float(lit) / float(count)
	return {
		"count": count,
		"mean": mean,
		"range": max_l - min_l,
		"lit_ratio": lit_ratio,
	}
