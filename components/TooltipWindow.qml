import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons

// 本机改动：悬停气泡从 PopupWindow 改成独立图层（PanelWindow）。
//
// 为什么要改：PopupWindow 在 wlroots 上是 xdg-popup（父窗口的子表面），
// Hyprland 只给 layer surface 算背景模糊，子表面永远拿不到 backdrop blur ——
// 实测证据：hover 时 `hyprctl layers` 里不会多出任何图层。想要真毛玻璃，
// 气泡必须是自己的 layer surface，命名空间 `omadock-tooltip`，由 layerrule
// （写在 ~/./.config/hypr/looknfeel.lua 的 omadock-tooltip-glass）开 blur。
//
// 原版（PopupWindow + anchor 机制）备份在同目录 TooltipWindow.qml.upstream。
//
// 摆位：dock 窗口是 bottom+left 锚定、左右贴屏、下边距 0，所以图标在 dock
// 窗口里的坐标就等于"距屏幕左边 x、距屏幕底 (dockWindow.height - y)"，
// 屏幕高度在算 bottom 边距时正好抵消：margins.bottom = hostWindow.height - p.y + gap - riseRoom。
//
// `level`（0..1，来自 TooltipLife）负责淡入淡出，`rises` 时顺便向上抬一点。
PanelWindow {
  id: tip

  property Item target: null
  property bool shown: false
  property Item body: null
  property real gap: Style.space(6)
  property real level: 1
  property bool rises: true

  readonly property var hostWindow: target ? target.QsWindow.window : null
  // 上抬动画需要的余量（放在气泡下方，免得动画期间被窗口裁掉底边）
  readonly property real riseRoom: tip.rises ? Style.space(6) : 0

  screen: tip.hostWindow ? tip.hostWindow.screen : null
  color: "transparent"
  visible: shown && tip.hostWindow !== null && tip.body !== null

  // 图层属性：Overlay 层、不吃键盘、不占排他区、输入区域为空（点击穿透，
  // 和原来 PopupWindow 的 mask: Region {} 行为一致）。
  WlrLayershell.namespace: "omadock-tooltip"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
  exclusionMode: ExclusionMode.Ignore
  exclusiveZone: 0
  mask: Region {}

  anchors {
    bottom: true
    left: true
  }

  implicitWidth: tip.body ? Math.ceil(tip.body.width) : 0
  implicitHeight: tip.body ? Math.ceil(tip.body.height + 2 * tip.riseRoom) : 0

  margins {
    left: {
      if (!tip.hostWindow || !tip.body || !tip.target) return 0
      var win = tip.hostWindow.contentItem
      var p = win.mapFromItem(tip.target, tip.target.width / 2, 0)
      var half = tip.implicitWidth / 2
      var maxX = (tip.screen ? tip.screen.width : win.width) - half - Style.gapsOut
      return Math.round(Math.max(half + Style.gapsOut, Math.min(maxX, p.x)) - half)
    }
    bottom: {
      if (!tip.hostWindow || !tip.body || !tip.target) return 0
      var p = tip.hostWindow.contentItem.mapFromItem(tip.target, tip.target.width / 2, 0)
      return Math.round(tip.hostWindow.height - p.y + tip.gap - tip.riseRoom)
    }
  }

  // body 贴在窗口底部居中；`rises` 时按 (1 - level) 向下位移，视觉上就是抬起来。
  Binding {
    target: tip.body
    property: "x"
    value: Math.round((tip.implicitWidth - (tip.body ? tip.body.width : 0)) / 2)
  }
  Binding {
    target: tip.body
    property: "y"
    value: Math.round(tip.riseRoom + (tip.rises ? (1 - tip.level) * tip.riseRoom : 0))
  }
  Binding {
    target: tip.body
    property: "opacity"
    value: tip.level
  }
}
