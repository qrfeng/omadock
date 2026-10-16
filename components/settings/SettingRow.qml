import QtQuick 6.11
import qs.Commons
import qs.Ui
import "../../Locale.js" as I18n

// Base settings row: label + optional hint on the left, control slot on
// the right. A non-empty key makes the row a search target; SettingsPanel
// registers it and sets highlighted when its search hit is picked.

Item {
  id: settingRow
  property string label: ""
  property string hint: ""
  // Search key: the SETTINGS_SEARCH entry whose hit jumps here. Rows
  // without one are not reachable from the search box.
  property string key: ""
  // Set by SettingsPanel while this row is the picked search target.
  property bool highlighted: false
  default property alias control: slot.data

  Rectangle {
    anchors.fill: parent
    radius: Style.space(8)
    color: settingRow.highlighted ? Util.alpha(Color.accent, 0.14) : "transparent"
    Behavior on color {
      ColorAnimation { duration: 350 }
    }
  }

  width: parent ? parent.width : Style.space(420)
  implicitHeight: Math.max(Style.space(44), texts.implicitHeight + Style.spacing.lg * 2, slot.childrenRect.height + Style.spacing.md * 2)

  Column {
    id: texts
    anchors.left: parent.left
    anchors.right: slot.left
    anchors.rightMargin: Style.spacing.xxl
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.spacing.xxs

    // Folder names, group names and paths reach these two unwrapped: they
    // are always plain text, never markup.
    // The label is translated here as well as at the call site: call sites
    // carry the English literal (so an upstream diff stays readable and a
    // missing translation degrades to English), while this catches values a
    // page builds at run time, like a folder or group name looked up from a
    // model. Dictionary lookup is exact, so names pass through untouched.
    Text {
      width: parent.width
      text: I18n.t(settingRow.label)
      textFormat: Text.PlainText
      color: Color.menu.text
      font.family: Style.font.family
      font.pixelSize: Style.font.subtitle
      elide: Text.ElideRight
    }
    Text {
      width: parent.width
      visible: settingRow.hint !== ""
      text: I18n.t(settingRow.hint)
      textFormat: Text.PlainText
      color: Util.alpha(Color.menu.text, 0.55)
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      wrapMode: Text.WordWrap
    }
  }

  Item {
    id: slot
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    width: childrenRect.width
    height: childrenRect.height
  }

  Rectangle {
    anchors.bottom: parent.bottom
    width: parent.width
    height: 1
    color: Util.alpha(Color.menu.text, 0.10)
  }
}
