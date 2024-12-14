extends Node
class_name FireEvent

signal event

func fire_event():
	event.emit()
