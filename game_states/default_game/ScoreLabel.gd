class_name Score extends Label


@export var score: int = 0:
	set(value):
		score = value * 100000
		
		var raw: String = str(score)
		var result: String = ""
		var buffer: String = ""
		for i in range(raw.length() - 1, -1, -1):
			buffer += raw[i]
			if buffer.length() == 3:
				result += str(buffer, ",")
				buffer = ""
		result += buffer
		text = result.reverse()
