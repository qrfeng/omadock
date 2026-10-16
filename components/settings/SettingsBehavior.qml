import QtQuick
import qs.Commons
import qs.Ui
import "../../Locale.js" as I18n

// Settings page: visibility, click behaviour, attention and tooltip rows.
// Instantiated by SettingsPanel, which injects root (the Dock, for
// values and setters) and panel (page/edit state).

Column {
  property var root: null
  property var panel: null
  width: parent.width


  SectionLabel { text: I18n.t("Language") }

  ChoiceRow {
    key: "language"
    label: I18n.t("Language")
    hint: I18n.t("Follow system uses the shell locale (LANG). Changing it reloads the shell immediately.")
    options: [
      { value: "auto", label: I18n.t("Follow system") },
      // Language names in their own language, as every picker does.
      { value: "en", label: "English" },
      { value: "zh", label: "中文" }
    ]
    value: root ? root.language : "auto"
    onPicked: function(v) {
      if (!root || v === root.language) return
      root.setOption("language", v)
      // Labels are resolved once when a surface is built, so the whole shell
      // has to come back for the change to read everywhere - the same thing
      // switching the update channel does. The setting is already saved, so
      // nothing is lost if the reload is refused (a locked session).
      Quickshell.execDetached(["omarchy-restart-shell"])
    }
  }

  SectionLabel { text: I18n.t("Visibility") }

  ChoiceRow {
    key: "autohide"
    label: I18n.t("Autohide")
    hint: I18n.t("Intelligent hides only when a window overlaps the dock.")
    options: [
      { value: "always", label: I18n.t("Always show") },
      { value: "intelligent", label: I18n.t("Intelligent") },
      { value: "autohide", label: I18n.t("Autohide") }
    ]
    value: root ? (!root.autohide ? "always" : (root.intelligentAutohide ? "intelligent" : "autohide")) : "always"
    onPicked: function(v) { root.setAutohideMode(v) }
  }
  SliderRow {
    key: "revealDelay"
    label: I18n.t("Reveal delay")
    hint: I18n.t("How long the pointer rests on the edge before the dock slides in.")
    enabled: root ? root.autohide : false
    opacity: enabled ? 1 : 0.45
    minimum: 0
    maximum: 1000
    step: 10
    suffix: " ms"
    value: root ? root.revealDelay : 160
    onCommitted: function(v) { root.setOption("revealDelay", Math.round(v)) }
  }

  SectionLabel { text: I18n.t("Clicking an app") }

  ChoiceRow {
    key: "minimizeMode"
    label: I18n.t("Minimize on click")
    hint: I18n.t("Clicking the focused app's icon parks its windows.")
    options: [
      { value: "off", label: I18n.t("Off") },
      { value: "active", label: I18n.t("Active window") },
      { value: "all", label: I18n.t("All windows") }
    ]
    value: root ? root.minimizeMode : "active"
    onPicked: function(v) { root.setOption("minimizeMode", v) }
  }
  SwitchRow {
    key: "keepPointer"
    label: I18n.t("Keep pointer in place")
    hint: I18n.t("Don't move the mouse pointer onto the window a click brings up.")
    checked: root ? root.keepPointer : true
    onToggled: root.setOption("keepPointer", !root.keepPointer)
  }
  ChoiceRow {
    key: "restoreWorkspace"
    label: I18n.t("Restore on")
    hint: I18n.t("Where a minimized window comes back to. Windows restores it to the workspace it was minimized from.")
    options: [
      { value: "current", label: I18n.t("Current workspace") },
      { value: "origin", label: I18n.t("Original workspace") }
    ]
    value: root ? root.restoreWorkspace : "current"
    onPicked: function(v) { root.setOption("restoreWorkspace", v) }
  }
  SwitchRow {
    key: "restoreSlot"
    label: I18n.t("Restore original slot")
    hint: I18n.t("Put the window back in the place it held in the tiling layout, not at the end. Only when the layout has not changed in the meantime.")
    checked: root ? root.restoreSlot : false
    onToggled: root.setOption("restoreSlot", !root.restoreSlot)
  }
  SliderRow {
    key: "wheelStepDelay"
    label: I18n.t("Wheel step delay")
    hint: I18n.t("Scrolling over an app flips through its windows; this paces the steps.")
    minimum: 0
    maximum: 500
    step: 10
    suffix: " ms"
    value: root ? root.wheelStepDelay : 150
    onCommitted: function(v) { root.setOption("wheelStepDelay", Math.round(v)) }
  }

  SectionLabel { text: I18n.t("Attention") }

  SwitchRow {
    key: "badges"
    label: I18n.t("Notification badges")
    hint: I18n.t("Count active notification popups on pinned apps; clears on dismissal or expiry.")
    checked: root ? root.showNotificationBadges : true
    onToggled: root.setOption("showNotificationBadges", !root.showNotificationBadges)
  }
  ChoiceRow {
    key: "badgeStyle"
    label: I18n.t("Badge style")
    hint: I18n.t("A count pill or a plain dot on the icon.")
    options: [
      { value: "count", label: I18n.t("Count") },
      { value: "dot", label: I18n.t("Dot") }
    ]
    value: root ? root.badgeStyle : "count"
    enabled: root ? root.showNotificationBadges : false
    opacity: enabled ? 1 : 0.45
    onPicked: function(v) { root.setOption("badgeStyle", v) }
  }
  ChoiceRow {
    key: "badgePosition"
    label: I18n.t("Badge position")
    hint: I18n.t("The corner of the icon the badge sits on.")
    options: [
      { value: "top-right", label: I18n.t("Top right") },
      { value: "top-left", label: I18n.t("Top left") },
      { value: "bottom-right", label: I18n.t("Bottom right") },
      { value: "bottom-left", label: I18n.t("Bottom left") }
    ]
    value: root ? root.badgePosition : "top-right"
    enabled: root ? root.showNotificationBadges : false
    opacity: enabled ? 1 : 0.45
    onPicked: function(v) { root.setOption("badgePosition", v) }
  }
  ChoiceRow {
    key: "badgeColor"
    label: I18n.t("Badge color")
    hint: I18n.t("Accent, urgent red, or a neutral pill.")
    options: [
      { value: "accent", label: I18n.t("Accent") },
      { value: "urgent", label: I18n.t("Urgent") },
      { value: "neutral", label: I18n.t("Neutral") }
    ]
    value: root ? root.badgeColor : "accent"
    enabled: root ? root.showNotificationBadges : false
    opacity: enabled ? 1 : 0.45
    onPicked: function(v) { root.setOption("badgeColor", v) }
  }
  SwitchRow {
    key: "urgentHint"
    label: I18n.t("Urgent highlights")
    hint: I18n.t("Mark apps whose windows ask for attention.")
    checked: root ? root.showUrgentHint : true
    onToggled: root.setOption("showUrgentHint", !root.showUrgentHint)
  }
  SwitchRow {
    key: "urgentOnNotification"
    label: I18n.t("Urgent on notification")
    hint: I18n.t("A notification from an app marks its icon.")
    checked: root ? root.urgentOnNotification : true
    onToggled: root.setOption("urgentOnNotification", !root.urgentOnNotification)
  }
  SettingRow {
    key: "urgentSound"
    label: I18n.t("Urgent sound")

    Dropdown {
      width: Style.space(200)
      showLabel: false
      options: [
        { value: "bell", label: I18n.t("Bell") },
        { value: "message-new-instant", label: I18n.t("Message chime") },
        { value: "complete", label: I18n.t("Complete ding") },
        { value: "dialog-information", label: I18n.t("Information pop") },
        { value: "dialog-warning", label: I18n.t("Warning alert") },
        { value: "phone-incoming-call", label: I18n.t("Phone ring") },
        { value: "alarm-clock-elapsed", label: I18n.t("Alarm beeps") },
        { value: "none", label: I18n.t("Mute") }
      ]
      value: root ? (root.urgentSound ? root.urgentSoundName : "none") : "bell"
      onChanged: function(v) { root.setUrgentSoundName(v) }
    }
  }

  SectionLabel { text: I18n.t("Previews & Tooltips") }

  SwitchRow {
    key: "tooltips"
    label: I18n.t("Tooltips")
    checked: root ? root.showTooltips : true
    onToggled: root.setOption("showTooltips", !root.showTooltips)
  }
  SliderRow {
    key: "tooltipDelay"
    label: I18n.t("Tooltip delay")
    enabled: root ? root.showTooltips : true
    opacity: enabled ? 1 : 0.45
    minimum: 0
    maximum: 2000
    step: 50
    suffix: " ms"
    value: root ? root.tooltipDelay : 450
    onCommitted: function(v) { root.setOption("tooltipDelay", Math.round(v)) }
  }
  SwitchRow {
    key: "windowPreviews"
    label: I18n.t("Window previews")
    hint: I18n.t("Thumbnails of an app's windows in its tooltip; scroll over the icon to flip through them.")
    checked: root ? root.advancedTooltips : true
    onToggled: root.setOption("advancedTooltips", !root.advancedTooltips)
  }
  SwitchRow {
    key: "minimizedTiles"
    label: I18n.t("Minimized window tiles")
    hint: I18n.t("Show parked windows as preview tiles in the dock.")
    checked: root ? root.showMinimizedTiles : true
    onToggled: root.setOption("showMinimizedTiles", !root.showMinimizedTiles)
  }
}
