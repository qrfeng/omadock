import QtQuick 6.11
import qs.Commons
import qs.Ui
import "../../Locale.js" as I18n

// SettingRow with a button-group choice.

SettingRow {
  id: choiceRow
  property var options: []
  property string value: ""
  signal picked(string value)

  ButtonGroup {
    // Labels only: ButtonGroup compares and emits `value`, never the label.
    options: I18n.opts(choiceRow.options)
    value: choiceRow.value
    foreground: Color.menu.text
    background: Color.menu.background
    focusable: false
    onChanged: function(v) { choiceRow.picked(v) }
  }
}
