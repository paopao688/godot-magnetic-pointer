extends Node2D

# 光标配置
@export var spin_duration: float = 2.0					# 旋转一周所需时间（秒）
@export var hide_default_cursor: bool = true			# 是否隐藏默认光标
@export var lerp_factor: float = 0.15					# 位置插值系数（0-1，越小越平滑）

# 四角配置
@export var corner_offset: float = 25.0					# 四角相对中心偏移距离
@export var corner_size: int = 8							# 四角大小（正方形边长）
@export var corner_main_size: int = 20					# 主光标大小（正方形边长）
@export var corner_extra_distance: int = 0				# 四角中心到主光标中心的额外距离

# 检测配置
@export var detect_range: float = 30.0					# Node2D无碰撞形状时的检测半径
@export var detect_rect_size: Vector2 = Vector2(100, 100)	# Node2D无碰撞形状时的默认检测矩形大小

# 颜色配置
@export var default_main_color: Color = Color(1, 1, 1, 0.8)			# 默认主光标颜色
@export var active_main_color: Color = Color(1, 0.5, 0.5, 1)			# 激活状态主光标颜色
@export var default_corner_color: Color = Color(1, 1, 1, 0.6)			# 默认四角颜色
@export var active_corner_color: Color = Color(1, 0.5, 0.5, 0.8)		# 激活状态四角颜色

# 内部变量
var cursor_position: Vector2
var target_position: Vector2
var is_targeting: bool = false
var spin_angle: float = 0.0
var current_target: Node = null

# 光标节点
@onready var cursor_main: ColorRect = $cursor_main
@onready var corner_top_left: ColorRect = $cursor_corner_tl
@onready var corner_top_right: ColorRect = $cursor_corner_tr
@onready var corner_bottom_left: ColorRect = $cursor_corner_bl
@onready var corner_bottom_right: ColorRect = $cursor_corner_br

func _ready():
	# 设置四角属性
	if corner_top_left:
		corner_top_left.size = Vector2(corner_size, corner_size)
	if corner_top_right:
		corner_top_right.size = Vector2(corner_size, corner_size)
	if corner_bottom_left:
		corner_bottom_left.size = Vector2(corner_size, corner_size)
	if corner_bottom_right:
		corner_bottom_right.size = Vector2(corner_size, corner_size)
	
	# 设置主光标大小
	if cursor_main:
		cursor_main.size = Vector2(corner_main_size, corner_main_size)
		cursor_main.pivot_offset = cursor_main.size / 2
	
	if hide_default_cursor:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# 初始化位置
	cursor_position = get_global_mouse_position()
	target_position = cursor_position

func _process(delta):
	# 更新鼠标位置
	target_position = get_global_mouse_position()

	# 平滑跟随
	cursor_position = cursor_position.lerp(target_position, lerp_factor)

	# 检测鼠标是否悬停在目标节点上
	check_target_hover()

	# 处理位置和状态
	if is_targeting and current_target != null:
		# 目标锁定状态
		update_corner_positions()
		if cursor_main:
			cursor_main.rotation_degrees = 0
	else:
		# 非目标状态：旋转光标并重置四角位置
		spin_angle += delta * (360.0 / spin_duration)
		if cursor_main:
			cursor_main.rotation_degrees = spin_angle
		reset_corner_positions()
		
	# 设置光标位置
	position = cursor_position

func check_target_hover():
	var mouse_pos = get_global_mouse_position()
	var was_targeting = is_targeting
	var found_target = false
	var new_target = null

	# 1. 检测 UI 节点（Control 类型）
	var root = get_tree().root
	if root != null:
		var all_controls = root.find_children("*", "Control", true, false)
		for control in all_controls:
			if control != null and control != self and not is_ancestor_of(control):
				print(control)
				if control.name == "Control":
					continue
				if is_mouse_over_node(control, mouse_pos):
					found_target = true
					new_target = control
					break
		
	# 2. 检测 Node2D 节点
	if not found_target and root != null:
		var all_nodes = root.find_children("*", "Node2D", true, false)
		for node in all_nodes:
			if node != null and node != self and not is_ancestor_of(node):
				if is_mouse_over_node(node, mouse_pos):
					found_target = true
					new_target = node
					break

	# 更新状态
	is_targeting = found_target
	current_target = new_target

	# 状态变化时更新视觉效果
	if is_targeting != was_targeting:
		on_target_state_changed(is_targeting)

func is_mouse_over_node(node: Node, mouse_pos: Vector2) -> bool:
	if node is Control:
		# Control 节点使用全局矩形检测
		var rect = node.get_global_rect()
		return rect.has_point(mouse_pos)
	elif node is Node2D:
		# Node2D 节点使用不同的检测方法
		if node.has_method("get_global_bounds"):
			# 有碰撞形状的节点
			var bounds = node.get_global_bounds()
			return bounds.has_point(mouse_pos)
		else:
			# 无碰撞形状的节点，使用距离检测
			var distance = node.global_position.distance_to(mouse_pos)
			return distance < detect_range
	return false

func update_corner_positions():
	if current_target == null:
		return

	var target_rect: Rect2

	if current_target is Control:
		# Control 节点使用其全局矩形
		target_rect = current_target.get_global_rect()
	elif current_target is Node2D:
		if current_target.has_method("get_global_bounds"):
			# 有碰撞形状的 Node2D
			target_rect = current_target.get_global_bounds()
		else:
			# 无碰撞形状的 Node2D，使用位置为中心的矩形
			var center = current_target.global_position
			target_rect = Rect2(center - detect_rect_size / 2, detect_rect_size)
	else:
		return

	# 计算四角的全局位置
	var top_left = target_rect.position + Vector2(-corner_offset, -corner_offset)
	var top_right = Vector2(target_rect.end.x, target_rect.position.y)
	var bottom_left = Vector2(target_rect.position.x, target_rect.end.y)
	var bottom_right = target_rect.end

	# 转换为局部坐标并设置四角位置
	if corner_top_left:
		corner_top_left.position = to_local(top_left)
	if corner_top_right:
		corner_top_right.position = to_local(top_right)
	if corner_bottom_left:
		corner_bottom_left.position = to_local(bottom_left)
	if corner_bottom_right:
		corner_bottom_right.position = to_local(bottom_right)

func reset_corner_positions():
	# 重置四角到默认位置（相对于光标中心）
	if corner_top_left:
		corner_top_left.position = Vector2(-corner_offset, -corner_offset)
	if corner_top_right:
		corner_top_right.position = Vector2(corner_offset, -corner_offset)
	if corner_bottom_left:
		corner_bottom_left.position = Vector2(-corner_offset, corner_offset)
	if corner_bottom_right:
		corner_bottom_right.position = Vector2(corner_offset, corner_offset)

func on_target_state_changed(targeting: bool):
	if targeting:
		# 目标锁定时的视觉反馈
		if cursor_main:
			cursor_main.color = active_main_color
		if corner_top_left:
			corner_top_left.color = active_corner_color
		if corner_top_right:
			corner_top_right.color = active_corner_color
		if corner_bottom_left:
			corner_bottom_left.color = active_corner_color
		if corner_bottom_right:
			corner_bottom_right.color = active_corner_color
	else:
		# 恢复默认颜色
		if cursor_main:
			cursor_main.color = default_main_color
		if corner_top_left:
			corner_top_left.color = default_corner_color
		if corner_top_right:
			corner_top_right.color = default_corner_color
		if corner_bottom_left:
			corner_bottom_left.color = default_corner_color
		if corner_bottom_right:
			corner_bottom_right.color = default_corner_color
