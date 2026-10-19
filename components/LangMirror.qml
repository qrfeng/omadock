import QtQuick 6.11
import Quickshell
import "../Locale.js" as I18n

// Invisible language mirror (local patch, not upstream).
//
// `Locale.js` is a `.pragma library` module, so its `lang` is shared per URL
// that resolves it — and quickshell 0.3.2 hands out two URLs for the same
// file: the bar's import chain reads `qs:///…/Locale.js` (the copy
// DockConfigLogic calls `setLang` on), while surfaces built later read
// `file:///…/Locale.js`. Measured in one shell process:
//
//   [omadock-i18n] setLang -> zh instance 0.195 url = qs:///…/Locale.js
//   [omadock-i18n] first t() instance 0.224 lang = en url = file:///…/Locale.js
//
// so the second copy never hears about the saved language and every label it
// renders stays English. Which copy a file gets follows the URL the surface was
// loaded under, so a surface cannot assume it shares one with the dock.
//
// The fix has to be pushed in from QML: a library script has no Qt/Quickshell
// globals, Qt6 QML refuses synchronous XMLHttpRequest, and `Qt.getenv` is gone
// in Qt6, so `Locale.js` cannot read `omadock.json` or `$LANG` itself. Drop one
// of these inside a surface whose chain may be the other copy — its own import
// chain decides which copy it mirrors into — and because `dock.language` is a
// property, flipping the language in settings re-fires the binding and both
// copies follow.
Item {
  id: mirror

  required property var dock

  readonly property string code: I18n.resolveLang(
    mirror.dock && mirror.dock.language ? String(mirror.dock.language) : "auto",
    Quickshell.env("LANG") || "")

  visible: false
  width: 0
  height: 0

  Component.onCompleted: I18n.setLang(mirror.code)
  onCodeChanged: I18n.setLang(mirror.code)
}
