.pragma library
// Localised UI strings for omadock (local patch, not upstream).
//
// Why a dictionary instead of editing the pages: every label upstream is a
// literal inside a .qml file, so a translated copy of each file would have to
// be re-translated on every upstream update. Here the English literal stays
// in place and the leaf widgets (SettingRow, SectionLabel, ContextRow,
// ChoiceRow, SettingsPanel) pass it through t() at display time, so an update
// only needs the *new* strings added to DICT.
//
// `.pragma library` shares `lang` per URL that resolves this file, *not* per
// shell: quickshell 0.3.2 loads the very same file under both `qs:` (the bar's
// import chain) and `file:` (surfaces built later), so a `setLang` from the
// config loader only reaches one of the two copies. Every other copy is pushed
// the language by components/LangMirror.qml, which reads `language` from
// ~/.config/omarchy/omadock.json through the dock. Text lives inside
// LazyLoaders (settings panel, context menu, popups), all built on open, so it
// is applied before any of it renders; `tr(text, code)` exists for bindings that
// must follow a switch without rebuilding.
//
// Keys are the exact upstream English text. Keep the key byte-identical to
// the literal it translates, including the ellipsis character and "›".

var lang = "en"

function setLang(code) {
  lang = (code === "zh") ? "zh" : "en"
}

function current() {
  return lang
}

function isZh() {
  return lang === "zh"
}

// "auto": follow $LANG / $LC_MESSAGES, otherwise English. `envLang` is passed
// in from QML (Quickshell.env) because a library script has no Qt globals.
function resolveLang(code, envLang) {
  if (code === "zh" || code === "en") return code
  var e = String(envLang || "").toLowerCase()
  return (e.indexOf("zh") === 0 || e.indexOf("zh_") > 0) ? "zh" : "en"
}

// One user-facing string. Unknown keys fall back to English, so a missing
// entry is a plain-English label, never an empty one.
function t(s) {
  if (lang !== "zh") return s
  if (typeof s !== "string" || s === "") return s
  var v = DICT[s]
  return v === undefined ? s : v
}

// Same, but with the language passed in. A binding that must follow a
// language change (rather than be correct only at creation time) has to read
// a QML-visible property, because this file is a shared library and its `lang`
// variable is invisible to the binding engine. Sites that draw before any
// surface is opened - the drive tiles, a pin's remove row - bind through this
// with the dock's `language` property as the argument.
function tr(s, code) {
  // Explicit "zh"/"en" wins; "auto" (or a not-yet-loaded config) falls back to
  // the flag resolved from the shell locale at config load.
  var want = (code === "zh" || code === "en") ? code : lang
  if (want !== "zh") return s
  if (typeof s !== "string" || s === "") return s
  var v = DICT[s]
  return v === undefined ? s : v
}

// A string with a number in it. The key holds "%1" where the number goes, so
// each language can put it where its word order wants ("+3 more" is
// "还有 3 个"), and the English text comes out exactly as upstream wrote it.
function fmt(s, value) {
  // fmt("…%1 of %2…", a, b): each %n takes the nth argument, so a language can
  // reorder the numbers (Chinese says "存满 %2 套了" without repeating %1).
  var out = String(t(s))
  for (var i = 1; i < arguments.length; i++)
    out = out.replace("%" + i, String(arguments[i]))
  return out
}

// ChoiceRow / ButtonGroup options: [{value,label}] or plain strings. Values
// (the part the logic uses) are untouched; only the label is translated.
function opts(list) {
  if (lang !== "zh" || !list || !list.length) return list
  var out = []
  for (var i = 0; i < list.length; i++) {
    var o = list[i]
    if (o && typeof o === "object") {
      var c = {}
      for (var k in o) c[k] = o[k]
      c.label = t(String(o.label))
      out.push(c)
    } else {
      out.push(t(String(o)))
    }
  }
  return out
}

// Chinese words people may type into the settings search box, so the search
// finds a row by its translated name too.
function zhKey(label) {
  return DICT[label] === undefined ? "" : DICT[label]
}

// Search vocabulary in both languages. SETTINGS_SEARCH is English, so without
// this a query typed in Chinese would match nothing: every entry also scores
// its translated label, plus hand-picked words for the settings people look up
// by a synonym rather than by the label's own wording.
var SEARCH_ZH = {
  language: ["语言", "中文", "英文", "汉化", "翻译"],
  autohide: ["隐藏", "藏起来", "不显示"],
  screen: ["屏幕", "显示器"],
  multiMonitor: ["多显示器", "副屏", "每个屏幕"],
  iconSize: ["大小", "尺寸", "大一点", "小一点"],
  hoverEffect: ["放大", "波浪", "发光", " hover"],
  blur: ["模糊", "毛玻璃", "透明"],
  grain: ["颗粒", "噪点", "质感"],
  shape: ["圆角", "直角", "形状"],
  bgColor: ["背景", "颜色", "底色"],
  borderColor: ["边框", "描边"],
  dividerStyle: ["分隔线", "分隔符"],
  indicatorShape: ["指示器", "运行标志", "小点"],
  labelMode: ["名称", "文字", "标签", "显示名字"],
  tooltips: ["提示", "鼠标提示", "悬浮"],
  presets: ["预设", "配色", "风格", "主题"],
  updateChannel: ["更新", "频道", "版本"],
  pinned: ["固定", "钉住"],
  folders: ["文件夹", "目录"],
  appGroups: ["应用组", "分组"],
  clickBehavior: ["点击", "单击", "行为"],
  urgent: ["提醒", "闪", "需要注意"],
  drives: ["磁盘", "U 盘", "移动硬盘"],
  minimize: ["最小化"],
  showAppsButton: ["启动器", "应用列表", "九宫格"]
}

// SETTINGS_SEARCH-shaped list with bilingual terms (see SettingsPanel).
function searchEntries(entries) {
  if (!entries) return []
  var out = []
  for (var i = 0; i < entries.length; i++) {
    var e = entries[i]
    var terms = (e.terms || []).slice()
    var zh = zhKey(e.label)
    if (zh !== "") terms.push(zh)
    var extra = SEARCH_ZH[e.key]
    if (extra) terms = terms.concat(extra)
    out.push({ key: e.key, page: e.page, label: e.label, terms: terms })
  }
  return out
}

// ---------------------------------------------------------------- dictionary
var DICT = {
  // ------------------------------------------------------- panel chrome
  "Dock settings": "程序坞设置",
  "Dock Settings": "程序坞设置",
  "Dock Settings…": "程序坞设置…",
  "Search settings": "搜索设置",
  "No matches": "没有匹配项",
  "Close (Esc)": "关闭（Esc）",
  "Appearance": "外观",
  "Labels": "名称",
  "Icons": "图标",
  "Motion & Effects": "动效",
  "Behavior": "行为",
  "Placement": "位置",
  "Folders": "文件夹",
  "App Groups": "应用组",
  "Presets": "预设",
  "About": "关于",
  "Language": "语言",
  "Follow system": "跟随系统",

  // ------------------------------------------------------- appearance
  "Background": "背景",
  "Fill behind the icons. Off leaves the icons floating.": "在图标后方填充底色；关闭后图标悬浮在桌面上。",
  "Fill": "填充",
  "A solid colour, or colours melting into each other like Zen / Arc themes.": "纯色，或像 Zen / Arc 主题那样让几种颜色相互晕开。",
  "Solid": "纯色",
  "Gradient": "渐变",
  "Color": "颜色",
  "Palette": "配色",
  "Theme, none, or a fixed preset.": "跟随主题、不填充，或使用固定预设。",
  "Theme": "主题",
  "None": "无",
  "Strength": "强度",
  "Theme builds one from the Omarchy theme's accent and palette.": "主题会用 Omarchy 主题的强调色与配色自动生成一套。",
  "How strongly the colours show over the theme background.": "这些颜色盖在主题背景上的明显程度。",
  "Opacity from theme": "不透明度跟随主题",
  "Follow the bar opacity of the current Omarchy theme.": "跟随当前 Omarchy 主题状态栏的不透明度。",
  "Opacity": "不透明度",
  "Border": "边框",
  "Thin rim around the dock.": "程序坞外圈的一细条描边。",
  "Border width": "边框宽度",
  "Border opacity from theme": "边框不透明度跟随主题",
  "Derive the rim opacity from the dock's opacity, as themes expect. Turn off to set it by hand.": "按主题的习惯由程序坞不透明度推算描边不透明度；关闭后可手动设置。",
  "Border opacity": "边框不透明度",
  "Divider length style": "分隔线长度",
  "Classic preserves the original icon-height lines. Long uses an adjustable share of the dock height.": "经典沿用原来的图标高度；长则取程序坞高度中可调的占比。",
  "Classic": "经典",
  "Long": "长",
  "Divider style": "分隔线样式",
  "Theme draws the lines like the border, in its colour, opacity and width. Custom sets the width and opacity by hand. Hidden drops the lines and the room around them, for docks whose plates already show the sections.": "主题按边框的颜色、不透明度与宽度画线；自定义可手动设定宽度与不透明度；隐藏则连线条和它占的间距一起去掉，适合底板已经能看出分区的程序坞。",
  "Simple": "简洁",
  "Custom": "自定义",
  "Hidden": "隐藏",
  "Divider width": "分隔线宽度",
  "Divider opacity": "分隔线不透明度",
  "Divider height": "分隔线高度",
  "Length of the lines between sections, as a share of the dock's height.": "分区之间线条的长度，按程序坞高度的百分比计算。",
  "Corners": "圆角",
  "Shape": "形状",
  "Rounded": "圆角",
  "Pill": "胶囊",
  "Square": "直角",
  "Corner radius": "圆角半径",
  "Split sections": "分区独立",
  "Each part between the dividers becomes its own panel, with a gap in place of the divider.": "分隔线之间的每一段变成独立面板，用间隙代替分隔线。",
  "Panel spacing": "面板间距",
  "Gap between the panels when sections are split.": "分区独立时，面板之间的间隙。",
  "Indicators": "运行指示",
  "The dots and bars under icons. Theme follows the corners above.": "图标下方的圆点与短条。主题会跟随上面的圆角设置。",
  "Omarchy button": "Omarchy 按钮",
  "Dock Items": "程序坞项目",
  "The launcher at the start of the dock. Without it, right-click the dock background to reach these settings.": "位于程序坞最前端的启动器。关掉后可以右键程序坞空白处进入这些设置。",
  "Removable drives": "可移动磁盘",
  "Show mounted USB drives at the end of the dock.": "在程序坞末尾显示已挂载的 USB 磁盘。",
  "Notify when a drive is pulled out while still mounted.": "磁盘还没弹出就被拔掉时给出提醒。",
  "Removable media drives & safe eject, smart app matching, jump lists": "可移动磁盘与安全弹出、智能应用匹配、跳转列表",

  // ------------------------------------------------------------- labels
  "Names": "名称",
  "Names beside the icons: always, or slid out while the pointer rests on an icon.": "图标旁的名称：一直显示，或指针停在图标上时滑出。",
  "Show on": "显示时机",
  "Always": "始终",
  "On hover": "悬停时",
  "All": "全部",
  "Apps": "应用",
  "App groups": "应用组",
  "When running shows a pinned app's name only while it has a window; a closed one keeps just its icon.": "仅在运行时：固定的应用有窗口时才显示名称，关掉后只留图标。",
  "When running": "仅在运行时",
  "Font": "字体",
  "Sans": "无衬线",
  "Size": "字号",
  "File Size": "文件大小",
  "Small": "小",
  "Medium": "中",
  "Large": "大",
  "Weight": "字重",
  "Regular": "常规",
  "Bold": "加粗",
  "Auto picks black or white for what is behind the icons; Theme uses the bar's text colour.": "自动根据图标后方选择黑或白；主题使用状态栏的文字颜色。",
  "Auto": "自动",
  "Plate puts icon and name on one surface, like a button.": "底板把图标和名称放在同一块表面上，像一个按钮。",
  "Plate": "底板",
  "Dock": "程序坞",
  "Dock follows the dock's own corners. Square meets between plates and rounds the outer ones along the dock's edge; Pill gives every plate round ends.": "程序坞跟随自身的圆角。直角在相邻底板之间保持方正、只把外侧沿程序坞边缘倒圆；胶囊让每块底板两端都变圆。",
  "Layout": "布局",
  "Dock stretches plates to the dock's top and bottom, the same gap away as from each other.": "程序坞把底板撑到程序坞的上下边缘，与左右间距保持一致。",
  "Window marks as a column at the plate's edge, so every plate lines up.": "窗口标记排在底板边缘的一列，让所有底板对齐。",
  "Before icon": "图标之前",
  "After name": "名称之后",
  "Under icon": "图标下方",
  "Reveal": "出现方式",
  "How a name appears when the pointer rests on an icon.": "指针停在图标上时，名称以什么方式出现。",
  "Slide": "滑出",
  "Typewriter": "逐字",
  "Scramble": "解码",
  "Effect": "特效",
  "Glow": "发光",
  "Outline": "描边",
  "Max width": "最大宽度",
  "Longer names drop subtitles, then trailing words, then end in an ellipsis.": "名称过长时先去掉副标题，再去掉末尾的词，最后以省略号收尾。",
  "Pinned apps": "固定应用",
  "Plate height": "底板高度",
  "Icon": "图标",

  // -------------------------------------------------------------- icons
  "Icon style": "图标风格",
  "Original": "原图",
  "Monochrome": "单色",
  "Dot matrix": "点阵",
  "Monochrome and dot matrix take one colour from the theme.": "单色与点阵会从主题里取一种颜色。",
  "Icon colour": "图标颜色",
  "Text": "文字色",
  "B/W": "黑白",
  "Auto B/W": "自动黑白",
  "Pixels across": "像素密度",
  "Fewer is chunkier.": "数值越小，颗粒越粗。",
  "Contrast": "对比度",
  "Separates the symbol from its backdrop; high values flatten icons to a simple, poster-like shape.": "把图形从背景里分离出来；数值越高，图标越接近平面海报的造型。",
  "How much of the effect covers the original icon.": "特效覆盖原图标的程度。",
  "Show original on hover": "悬停时显示原图",
  "The icon under the pointer drops the style and shows as shipped. Icons in an opened group follow this too.": "指针下方的图标会去掉风格、按原始样子显示。展开的应用组里的图标也一样。",
  "Dithered reveal": "抖动渐显",
  "The original icon appears cell by cell, rising from the bottom, instead of all at once.": "原图标从底部一格一格浮现，而不是一次全部出现。",
  "Size & Spacing": "尺寸与间距",
  "Icon size": "图标大小",
  "Spacing": "间距",
  "Gap between icons.": "图标之间的间隙。",
  "Gap between icons. Label plates keep it between 4 and 12 px.": "图标之间的间隙。带名称底板时会自动限制在 4–12 px。",

  // ------------------------------------------------------------- motion
  "Motion": "动效",
  "Animations": "动画",
  "Reduced keeps short fades and drops movement and bounces. Off changes everything at once.": "精简保留短短的淡入淡出、去掉位移与弹跳；关闭则所有变化一次到位。",
  "Full": "完整",
  "Reduced": "精简",
  "Hover effect": "悬停效果",
  "Zoom": "缩放",
  "Wave": "波浪",
  "Lift": "上浮",
  "Glitch": "故障",
  "Launch bounce": "启动弹跳",
  "Bounce the icon while an app is starting.": "应用启动时让图标弹跳一下。",
  "Shadow": "阴影",
  "Under the dock; with the background off, under each icon.": "位于程序坞下方；关掉背景后位于每个图标下方。",
  "Shadow strength": "阴影强度",
  "Blur & Grain": "模糊与颗粒",
  "Blur from system": "模糊交给系统",
  "Leave blur behind the dock to your Hyprland layer rules.": "把程序坞后方的模糊交给你的 Hyprland layerrule。",
  "Blur": "模糊",
  "Blur strength": "模糊强度",
  "Hyprland has one blur size for everything, so this also changes it for windows and other panels. Back to your own value when blur leaves this mode.": "Hyprland 全局只有一个模糊尺寸，所以这里也会改变窗口和其他面板的模糊。模糊退出该模式后恢复你自己的数值。",
  "Grain": "颗粒",
  "Film grain over the background. Works on solid, translucent and blurred backgrounds alike.": "在背景上叠一层胶片颗粒。纯色、半透明和模糊背景都能用。",

  // ----------------------------------------------------------- behavior
  "Visibility": "可见性",
  "Autohide": "自动隐藏",
  "Intelligent hides only when a window overlaps the dock.": "智能只在窗口盖到程序坞时才隐藏。",
  "Always show": "始终显示",
  "Intelligent": "智能",
  "Reveal delay": "唤出延迟",
  "How long the pointer rests on the edge before the dock slides in.": "指针停在屏幕边缘多久之后，程序坞才滑出。",
  "Clicking an app": "点击应用时",
  "Clicking the focused app's icon parks its windows.": "点击当前应用的图标，会把它的窗口停靠起来。",
  "Off": "关闭",
  "Minimize on click": "点击最小化",
  "Active window": "当前窗口",
  "All windows": "所有窗口",
  "Keep pointer in place": "指针保持原位",
  "Don't move the mouse pointer onto the window a click brings up.": "不把鼠标指针移到点击唤出的那个窗口上。",
  "Restore on": "恢复位置",
  "Where a minimized window comes back to. Windows restores it to the workspace it was minimized from.": "最小化的窗口回到哪里。选择工作区时，回到它被最小化时所在的工作区。",
  "Current workspace": "当前工作区",
  "Original workspace": "原工作区",
  "Restore original slot": "恢复原位置",
  "Put the window back in the place it held in the tiling layout, not at the end. Only when the layout has not changed in the meantime.": "把窗口放回平铺布局中原来的位置，而不是排在末尾。仅适用于这期间布局没有变化的情况。",
  "Wheel step delay": "滚轮切换间隔",
  "Scrolling over an app flips through its windows; this paces the steps.": "在应用上滚动可以翻阅它的窗口，这里控制翻页的节奏。",
  "Attention": "提醒",
  "Notification badges": "通知角标",
  "Count active notification popups on pinned apps; clears on dismissal or expiry.": "统计固定应用当前未消失的通知弹窗数量；通知被关闭或过期后清零。",
  "Badge style": "角标样式",
  "A count pill or a plain dot on the icon.": "图标上显示数字胶囊，或一个简单的圆点。",
  "Count": "数字",
  "Dot": "圆点",
  "Microphone active": "麦克风使用中",
  "Badge position": "角标位置",
  "The corner of the icon the badge sits on.": "角标出现在图标的哪个角。",
  "Top right": "右上",
  "Top left": "左上",
  "Bottom right": "右下",
  "Bottom left": "左下",
  "Badge color": "角标颜色",
  "Accent, urgent red, or a neutral pill.": "强调色、提醒红，或中性色胶囊。",
  "Accent": "强调色",
  "Urgent": "提醒",
  "Neutral": "中性",
  "Urgent highlights": "提醒高亮",
  "Mark apps whose windows ask for attention.": "标记那些窗口在请求关注的应用。",
  "Urgent on notification": "收到通知时提醒",
  "A notification from an app marks its icon.": "应用收到通知时标记它的图标。",
  "Urgent sound": "提醒声音",
  "Bell": "铃声",
  "Message chime": "消息提示音",
  "Complete ding": "完成提示音",
  "Information pop": "信息提示音",
  "Warning alert": "警告音",
  "Phone ring": "电话铃声",
  "Alarm beeps": "闹钟提示音",
  "Mute": "静音",
  "Previews & Tooltips": "预览与提示",
  "Tooltips": "悬浮提示",
  "Tooltip delay": "提示延迟",
  "Window previews": "窗口预览",
  "Thumbnails of an app's windows in its tooltip; scroll over the icon to flip through them.": "在悬浮提示里显示该应用窗口的缩略图；在图标上滚动即可翻阅。",
  "Minimized window tiles": "最小化窗口卡片",
  "Show parked windows as preview tiles in the dock.": "在程序坞里以预览卡片显示已停靠的窗口。",

  // ---------------------------------------------------------- placement
  "Position": "位置",
  "Panel spans the screen's full width along the bottom edge.": "面板沿屏幕底边横贯整个屏幕宽度。",
  "Panel": "面板",
  "Alignment": "对齐",
  "Left": "居左",
  "Center": "居中",
  "Right": "居右",
  "Both sides": "两侧",
  "Both sides needs Split sections (Appearance).": "两侧需要在「外观」里打开分区独立。",
  "Monitors": "显示器",
  "One dock per connected monitor.": "每个已连接的显示器各一个程序坞。",
  "Show on all monitors": "在所有显示器显示",
  "Each dock lists the windows on its own monitor; pinned apps show everywhere.": "每个程序坞只列出自己显示器上的窗口；固定的应用到处都显示。",
  "Only this monitor's apps": "仅本显示器的应用",
  "Monitor": "显示器",
  "Automatic": "自动",
  "Automatic picks the first connected output.": "自动选择第一个已连接的输出。",
  "Multi-monitor docks & per-output instance management": "多显示器程序坞与逐输出实例管理",

  // ------------------------------------------------------------ folders
  "Pinned folders": "固定的文件夹",
  "Documents": "文档",
  "Downloads": "下载",
  "Pictures": "图片",
  "Projects": "项目",
  "Music": "音乐",
  "Videos": "视频",
  "Home": "个人目录",
  "Remove": "移除",
  "Custom folder": "自定义文件夹",
  "Pick any directory to pin as a stack.": "任选一个目录，以堆叠形式固定到程序坞。",
  "Add folder…": "添加文件夹…",
  "Folder color": "文件夹颜色",
  "Tile style": "图块样式",
  "Warn on unsafe removal": "未安全弹出时提醒",
  "Auto (Theme)": "自动（主题）",
  "White": "白色",
  "Black": "黑色",
  "Black or white": "黑或白",
  "Sage Green": "鼠尾草绿",
  "Olive": "橄榄绿",
  "Blue": "蓝色",
  "Purple": "紫色",
  "Magenta": "洋红",
  "Red": "红色",
  "Yellow": "黄色",
  "Brown": "棕色",
  "Teal": "蓝绿",
  "Charcoal": "炭黑",
  "Name": "名称",
  "Kind": "类型",
  "Date Modified": "修改时间",
  "Date Added": "添加时间",

  // ------------------------------------------------------------- groups
  "Look": "外观",
  "Frame drawn around a group's icons in the dock.": "在程序坞里给应用组的图标画一个外框。",
  "Group": "组",
  "Theme applies the style from the Icons page to the icons of an opened group.": "主题会把「图标」页的风格套用到展开组里的图标上。",
  "Groups": "应用组",
  "No groups yet. Drag one dock icon onto another, or create one from the apps that are running now.": "还没有应用组。把一个图标拖到另一个图标上，或从正在运行的应用新建一个。",
  "Create group from running apps": "从正在运行的应用创建",
  "Group name": "组名称",
  "macOS folder stacks, icon shaders, gradients, grain, drop-to-open": "macOS 风格文件夹堆叠、图标着色器、渐变、颗粒、拖放打开",

  // ------------------------------------------------------------ presets
  "Apply": "应用",
  "shipped with the dock": "程序坞自带",
  "Update": "更新",
  "Delete": "删除",
  "Delete?": "删除？",
  "Keep": "保留",
  "Aurora": "极光",
  "Sunset": "日落",
  "Ocean": "海洋",
  "Forest": "森林",
  "Rose": "玫瑰",
  "Lavender": "薰衣草",
  "Ember": "余烬",
  "Citrus": "柑橘",
  "Mono": "单色",
  "Glass": "玻璃",
  "Pixel": "像素",
  "Panels": "分栏",
  "Nameplates": "名牌",
  "Silkscreen": "丝印",

  // -------------------------------------------------------------- about
  "Version": "版本",
  "Free and open-source application dock for Omarchy · MIT license": "为 Omarchy 打造的免费开源程序坞 · MIT 许可证",
  "Project & feedback": "项目与反馈",
  "Report bugs, follow development, or contribute.": "提交问题、跟进开发，或参与贡献。",
  "GitHub": "GitHub",
  "GitHub ↗": "GitHub ↗",
  "Updates": "更新",
  "Update channel": "更新渠道",
  "Stable receives verified releases; Experimental gets features early. Switching reloads the shell immediately.": "稳定版接收已验证的发布；实验版提前拿到新功能。切换会立刻重新加载桌面。",
  "Stable": "稳定版",
  "Experimental": "实验版",
  "Supporters & acknowledgments": "赞助与致谢",
  "omadock is built with love by thepathless — a medical student, between classes and clinics. It is free, and it always will be.\n\nIf it earns a place on your desktop, you can give some love back to its maker. No tiers, no perks — just support returned.": "omadock 由 thepathless 用心制作——他是一名医学生，在课堂与病房之间抽空写完的。它免费，而且会一直免费。\n\n如果它在你桌面上占了一席之地，你也可以把这份心意回报给作者。没有分级，没有特权——只是把支持传递下去。",
  "Supporter #1 — thepathless": "第 1 位赞助者 — thepathless",
  "The maker. Its first and forever supporter.": "作者本人，也是它第一位、永远的赞助者。",
  "Support ❤": "支持 ❤",
  "Supporters wall": "赞助者墙",
  "Everyone who has supported omadock, honored in the repository.": "所有支持过 omadock 的人，都会被记录在仓库里。",
  "View wall": "查看赞助墙",
  "Code Contributors": "代码贡献者",
  "Desktop entry launch suffix validation fix for pinned apps": "修复固定应用 .desktop 启动参数后缀的校验",
  "Application matching restoration": "恢复应用匹配逻辑",
  "Bug Hunters & Diagnostics": "捉虫与诊断",
  "Suspend/resume screen null recovery diagnostics": "挂起/恢复后屏幕为空的恢复诊断",
  "GTK icon resolving, launcher matching, and theme accent": "GTK 图标解析、启动器匹配与主题强调色",
  "Webapp Exec-URL .execString desktop entry investigation": "调查 Web 应用 Exec-URL 的 .execString desktop 条目",
  "Omarchy 4.x overlay plugin appLibrary diagnostic": "Omarchy 4.x 覆盖层插件 appLibrary 诊断",
  "Window focus dispatch & Hyprland layout awareness": "窗口焦点派发与 Hyprland 布局感知",

  // -------------------------------------------------------- context menu
  "Presets ›": "预设 ›",
  "Create Group from Running Apps": "从正在运行的应用创建组",
  "‹ Back": "‹ 返回",
  "Manage Presets…": "管理预设…",
  "View As: ": "查看方式：",
  "Sort By: ": "排序：",
  "View As": "查看方式",
  "Sort By": "排序",
  "Stack": "堆叠",
  "Folder": "文件夹",
  "Open in File Manager": "在文件管理器中打开",
  "Open in Terminal": "在终端中打开",
  "Unpin from Dock": "从程序坞取消固定",
  "Pin to Dock": "固定到程序坞",
  "Restore All Here": "全部移回此处",
  "Restore Here": "移回此处",
  "Restore All to Original": "全部恢复到原位置",
  "Restore to Original": "恢复到原位置",
  "Close All": "全部关闭",
  "Close": "关闭",
  "App Group": "应用组",
  "Open Group Grid": "打开组网格",
  "Ungroup": "解除分组",
  "Remove Group": "移除应用组",
  "Now Playing · in background": "正在播放 · 后台运行",
  "Now Playing": "正在播放",
  "Previous": "上一首",
  "Play / Pause": "播放 / 暂停",
  "Next": "下一首",
  "Windows (": "窗口（",
  "Active Window": "当前窗口",
  "New Window": "新建窗口",
  "Launch": "启动",
  "Minimize Window": "最小化窗口",
  "Remove from Group": "从组中移除",
  "Close All Windows": "关闭全部窗口",
  "Close Window": "关闭窗口",
  "Copy Mount Path": "复制挂载路径",
  "Safely Eject / Unmount": "安全弹出 / 卸载",
  "USB Drive": "USB 磁盘",
  "Drive": "磁盘",
  "Rename…": "重命名…",
  "Window": "窗口",
  "minimized": "已最小化",

  // -------------------------------------------------- popups & notices
  "Folder could not be read": "无法读取该文件夹",
  "Folder is empty": "文件夹是空的",
  " — open in File Manager": " — 在文件管理器中打开",
  "It cannot be launched — reinstall the app or unpin it from the dock.": "无法启动它——请重新安装这个应用，或把它从程序坞取消固定。",
  "A drive": "一个磁盘",
  "Drive removed without ejecting": "磁盘没有弹出就被移除",
  " was removed while still mounted. Recent changes may not have been written; eject it from the dock next time.": " 还在挂载状态就被拔掉了。最近的改动可能没有写入磁盘，下次请先从程序坞里弹出它。",
  "This app": "这个应用",
  "App no longer installed": "应用已不在本机",
  " is no longer installed. ": " 已经被卸载了。",
  "Reinstall the app or unpin it from the dock.": "请重新安装这个应用，或把它从程序坞取消固定。",
  "Preset": "预设",
  // Fragments of sentences built in the QML. Each one has to read correctly
  // when glued to a name or a number, so they carry their own spacing; the
  // "%1" ones go through fmt().
  " app)": " 个窗口)",
  " apps)": " 个窗口)",
  "%1 Apps": "%1 个应用",
  " (Folder)": "（文件夹）",
  " (USB Drive)": "（U 盘）",
  " (USB • ": "（U 盘 · ",
  " (disconnected)": "（已断开）",
  "Remove group": "移除这个组",
  "%1 more": "还有 %1 个",
  "+%1 more": "还有 %1 个",
  "+ %1 more windows": "还有 %1 个窗口",
  "%1 of 6 saved · the shipped looks come with the dock · A preset keeps the look: background, effects, border, dividers, icons, label style, size and spacing.": "已保存 %1 / 6 套 · 自带的几套外观随程序坞一起提供 · 一套外观会记住：背景、特效、边框、分隔线、图标、名称样式、大小和间距。",
  // Language picker (a local addition; "Language"/"Follow system" above).
  "Follow system uses the shell locale (LANG). Changing it reloads the shell immediately.": "跟随系统用的是 shell 的环境变量 LANG。改完会立刻重新加载 shell。",
  // Second pass: strings that live inside ternaries and concatenations, so
  // the mechanical wrap of plain assignments could not reach them.
  "Unpin": "取消固定",
  "Preset name": "预设名称",
  "Windows": "窗口",
  "Primary monitor": "主显示器",
  "Save current look": "保存当前的外观",
  "%1 of %2 — delete one to save a new look": "%2 套已经存满了——先删掉一套才能存新的",
  "Dots across": "横排圆点数",
  "Frosted glass behind the dock.": "程序坞后面铺一层毛玻璃。",
  "Hyprland blur is off (decoration:blur:enabled), so this has no visible effect.": "Hyprland 的模糊是关着的（decoration:blur:enabled），所以这里调了也看不出效果。",
  "Folders and drives go to the right edge.": "文件夹和磁盘会靠到最右边。",
  "The dock lives on this one when more than one monitor is connected.": "接了不止一台显示器时，程序坞就固定在这一台上。",
  "Both sides needs Split sections (Appearance); centred until then.": "「两侧」需要先在「外观」里打开分区，没打开之前居中显示。",
  "It cannot be pinned to the dock — reinstall the app first.": "它没法固定到程序坞——请先重新安装这个应用。"
}
