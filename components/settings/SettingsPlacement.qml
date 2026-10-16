import QtQuick
import qs.Commons
import qs.Ui
import "../../DockLayout.js" as DockLayout
import "../../Locale.js" as I18n

// Settings page: alignment and monitor rows.
// Instantiated by SettingsPanel, which injects root (the Dock, for
// values and setters) and panel (page/edit state).

Column {
  property var root: null
  property var panel: null
  width: parent.width


  SectionLabel { text: I18n.t("Position") }

  ChoiceRow {
    key: "layout"
    label: I18n.t("Layout")
    hint: I18n.t("Panel spans the screen's full width along the bottom edge.")
    options: [
      { value: "dock", label: I18n.t("Dock") },
      { value: "panel", label: I18n.t("Panel") }
    ]
    value: root ? root.layout : "dock"
    onPicked: function(v) { root.setDockLayout(v) }
  }
  ChoiceRow {
    key: "alignment"
    label: I18n.t("Alignment")
    // The Omarchy ButtonGroup has no disabled state: Both sides is left
    // out where it cannot apply, and the hint says why.
    readonly property bool spreadOk: root ? DockLayout.spreadAvailable(root.layout, root.splitSections) : false
    hint: !spreadOk
      ? (root && root.alignment === "spread"
        ? I18n.t("Both sides needs Split sections (Appearance); centred until then.")
        : I18n.t("Both sides needs Split sections (Appearance)."))
      : (root && root.alignment === "spread" ? I18n.t("Folders and drives go to the right edge.") : "")
    options: {
      var list = [
        { value: "left", label: I18n.t("Left") },
        { value: "center", label: I18n.t("Center") },
        { value: "right", label: I18n.t("Right") }
      ]
      if (spreadOk) list.push({ value: "spread", label: I18n.t("Both sides") })
      return list
    }
    // A stored Both sides that cannot apply marks what the dock draws.
    value: root ? (spreadOk ? (root.alignment || "center") : root.placement.align) : "center"
    onPicked: function(v) { root.setDockAlignment(v) }
  }

  SectionLabel { text: I18n.t("Monitors") }

  SwitchRow {
    key: "multiMonitor"
    label: I18n.t("Show on all monitors")
    hint: I18n.t("One dock per connected monitor.")
    checked: root ? root.multiMonitor : false
    onToggled: root.setOption("multiMonitor", !root.multiMonitor)
  }
  SwitchRow {
    key: "perMonitorApps"
    label: I18n.t("Only this monitor's apps")
    hint: I18n.t("Each dock lists the windows on its own monitor; pinned apps show everywhere.")
    visible: root ? root.multiMonitor : false
    checked: root ? root.perMonitorApps : true
    onToggled: root.setOption("perMonitorApps", !root.perMonitorApps)
  }
  SettingRow {
    key: "monitorSelect"
    label: root && root.multiMonitor ? I18n.t("Primary monitor") : I18n.t("Monitor")
    hint: root && root.multiMonitor
      ? I18n.t("The dock lives on this one when more than one monitor is connected.")
      : I18n.t("Automatic picks the first connected output.")

    Dropdown {
      width: Style.space(200)
      showLabel: false
      options: {
        var list = [{ value: "", label: I18n.t("Automatic") }]
        var screens = root ? root.realScreens : []
        for (var i = 0; i < screens.length; i++)
          list.push({ value: screens[i].name, label: screens[i].name + (screens[i].model ? " — " + screens[i].model : "") })
        if (root && root.screenName && !root.screenForName(root.screenName))
          list.push({ value: root.screenName, label: root.screenName + I18n.t(" (disconnected)") })
        return list
      }
      value: root ? root.screenName : ""
      onChanged: function(v) { root.setDockScreen(v) }
    }
  }
}
