# godot-magnetic-pointer
一个带有缓动效果和目标锁定功能的自定义光标实现，适用于 Godot 4.3 项目。

## 功能特性

- ✅ 光标平滑跟随效果
- ✅ 目标锁定功能（悬停在任意节点上时）
- ✅ 四角跟随目标节点边缘
- ✅ 非目标状态时光标旋转动画
- ✅ 视觉反馈（悬停时颜色变化）
- ✅ 高度可配置的属性

## 演示视频


https://github.com/user-attachments/assets/53aa3d6a-bdab-45f2-893e-5cc8b4d69991
https://github.com/paopao688/godot-magnetic-pointer/issues/1#issue-4316951491

## 快速开始

### 环境要求

- Godot 4.3+

### 安装方法

1. 克隆本仓库或下载本仓库的 ZIP 文件
2. 打开Godot项目所在文件夹，导入`test_cursor.tscn`场景
3. 通过Godot编辑器打开`test_cursor.tscn`场景，将`cursor_effect.gd`脚本设置为根节点`Cursor`的脚本
4. 在其他场景中导入`test_cursor.tscn`场景，运行查看效果

## 配置选项

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `spin_duration` | float | 2.0 | 旋转一周所需时间（秒） |
| `hide_default_cursor` | bool | true | 是否隐藏默认光标 |
| `lerp_factor` | float | 0.15 | 位置插值系数（0-1，越小越平滑） |
| `corner_offset` | float | 25.0 | 四角相对中心偏移距离 |
| `corner_size` | int | 8 | 四角大小（正方形边长） |
| `corner_main_size` | int | 20 | 主光标大小（正方形边长） |
| `corner_extra_distance` | int | 0 | 四角中心到主光标中心的额外距离 |
| `detect_range` | float | 30.0 | Node2D无碰撞形状时的检测半径 |
| `detect_rect_size` | Vector2 | Vector2(100, 100) | Node2D无碰撞形状时的默认检测矩形大小 |
| `default_main_color` | Color | Color(1, 1, 1, 0.8) | 默认主光标颜色 |
| `active_main_color` | Color | Color(1, 0.5, 0.5, 1) | 激活状态主光标颜色 |
| `default_corner_color` | Color | Color(1, 1, 1, 0.6) | 默认四角颜色 |
| `active_corner_color` | Color | Color(1, 0.5, 0.5, 0.8) | 激活状态四角颜色 |

## 项目结构

```
├── cursor_effect.gd      # 光标效果脚本
├── LICENSE.txt            # 许可证文件
├── test_cursor.tscn     # 测试场景
└── README.md            # 项目说明
```

## 使用方法

1. 将 `cursor_effect.gd` 脚本添加到你的项目中
2. 创建一个 Node2D 节点作为光标根节点
3. 在光标节点下创建以下子节点：
   - `cursor_main` (ColorRect) - 主光标
   - `cursor_corner_tl` (ColorRect) - 左上角
   - `cursor_corner_tr` (ColorRect) - 右上角
   - `cursor_corner_bl` (ColorRect) - 左下角
   - `cursor_corner_br` (ColorRect) - 右下角
4. 将 `cursor_effect.gd` 脚本附加到光标根节点
5. 在 Inspector 面板中调整配置选项

## 技术实现

- 使用 `_process` 函数实现光标平滑跟随
- 使用 `lerp` 函数实现缓动效果
- 使用 `find_children` 函数检测鼠标悬停的节点
- 根据节点类型使用不同的检测方法
- 悬停时四角跟随目标节点边缘
- 非悬停时光标旋转动画

## 注意事项

- 确保光标节点的子节点命名正确
- 对于复杂场景，可能需要优化检测逻辑以提高性能
- 可以根据需要调整配置选项以获得不同的视觉效果

## 许可证

本项目采用 MIT 许可证。

## 贡献

欢迎提交 issue 和 pull request 来改进这个项目！

## 相关资源

- [演示视频](https://github.com/user-attachments/assets/53aa3d6a-bdab-45f2-893e-5cc8b4d69991)
- [Godot 官方文档](https://docs.godotengine.org/)

