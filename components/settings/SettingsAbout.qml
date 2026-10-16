import QtQuick 6.11
import qs.Commons
import qs.Ui

import Quickshell
import "../../Locale.js" as I18n

// Settings page: version, update channel, supporters and contributors.
// Instantiated by SettingsPanel, which injects root (the Dock, for
// values and setters) and panel (page/edit state).

Column {
  property var root: null
  property var panel: null
  width: parent.width


  SectionLabel { text: "omadock" }

  SettingRow {
    label: I18n.t("Version")
    hint: I18n.t("Free and open-source application dock for Omarchy · MIT license")
    Text {
      text: (root && root.manifest && root.manifest.version) ? "v" + root.manifest.version : "unknown"
      textFormat: Text.PlainText
      color: Color.menu.text
      font.family: Style.font.family
      font.pixelSize: Style.font.subtitle
    }
  }
  SettingRow {
    label: I18n.t("Project & feedback")
    hint: I18n.t("Report bugs, follow development, or contribute.")
    Button {
      text: I18n.t("GitHub")
      foreground: Color.menu.text
      bordered: true
      onClicked: Util.execDetached("uwsm-app -- xdg-open " + Util.shellQuote("https://github.com/thepathless/omadock"))
    }
  }

  SectionLabel { text: I18n.t("Updates") }
  ChoiceRow {
    key: "updateChannel"
    label: I18n.t("Update channel")
    hint: I18n.t("Stable receives verified releases; Experimental gets features early. Switching reloads the shell immediately.")
    options: [{ value: "stable", label: I18n.t("Stable") }, { value: "experiment", label: I18n.t("Experimental") }]
    value: panel.channel !== "" ? panel.channel : "stable"
    onPicked: function(v) {
      if (panel.channel === "" || v === panel.channel) return
      Quickshell.execDetached(["omadock-switch", v === "stable" ? "stable" : "experiment"])
    }
  }

  SectionLabel { text: I18n.t("Supporters & acknowledgments") }

  Text {
    width: parent.width
    topPadding: Style.spacing.lg
    bottomPadding: Style.spacing.lg
    text: I18n.t("omadock is built with love by thepathless — a medical student, between classes and clinics. It is free, and it always will be.\n\nIf it earns a place on your desktop, you can give some love back to its maker. No tiers, no perks — just support returned.")
    textFormat: Text.PlainText
    color: Color.menu.text
    wrapMode: Text.WordWrap
    font.family: Style.font.family
    font.pixelSize: Style.font.body
  }

  SettingRow {
    label: I18n.t("Supporter #1 — thepathless")
    hint: I18n.t("The maker. Its first and forever supporter.")

    Button {
      text: I18n.t("Support ❤")
      foreground: Color.menu.text
      bordered: true
      onClicked: Util.execDetached("uwsm-app -- xdg-open " + Util.shellQuote("https://github.com/sponsors/thepathless"))
    }
  }

  SettingRow {
    label: I18n.t("Supporters wall")
    hint: I18n.t("Everyone who has supported omadock, honored in the repository.")

    Button {
      text: I18n.t("View wall")
      foreground: Color.menu.text
      bordered: true
      onClicked: Util.execDetached("uwsm-app -- xdg-open " + Util.shellQuote("https://github.com/thepathless/omadock/blob/main/SPONSORS.md"))
    }
  }

  SectionLabel { text: I18n.t("Code Contributors") }

  SettingRow {
    label: "@priard (Lukasz)"
    hint: I18n.t("macOS folder stacks, icon shaders, gradients, grain, drop-to-open")

    Button {
      text: I18n.t("GitHub ↗")
      foreground: Color.menu.text
      bordered: true
      onClicked: Util.execDetached("uwsm-app -- xdg-open " + Util.shellQuote("https://github.com/priard"))
    }
  }

  SettingRow {
    label: "@G-Pappas (George P.)"
    hint: I18n.t("Multi-monitor docks & per-output instance management")

    Button {
      text: I18n.t("GitHub ↗")
      foreground: Color.menu.text
      bordered: true
      onClicked: Util.execDetached("uwsm-app -- xdg-open " + Util.shellQuote("https://github.com/G-Pappas"))
    }
  }

  SettingRow {
    label: "@NothingManTR (Taha Can)"
    hint: I18n.t("Removable media drives & safe eject, smart app matching, jump lists")

    Button {
      text: I18n.t("GitHub ↗")
      foreground: Color.menu.text
      bordered: true
      onClicked: Util.execDetached("uwsm-app -- xdg-open " + Util.shellQuote("https://github.com/NothingManTR"))
    }
  }

  SettingRow {
    label: "@assada"
    hint: I18n.t("Window focus dispatch & Hyprland layout awareness")

    Button {
      text: I18n.t("GitHub ↗")
      foreground: Color.menu.text
      bordered: true
      onClicked: Util.execDetached("uwsm-app -- xdg-open " + Util.shellQuote("https://github.com/assada"))
    }
  }

  SettingRow {
    label: "@tdslot"
    hint: I18n.t("Desktop entry launch suffix validation fix for pinned apps")

    Button {
      text: I18n.t("GitHub ↗")
      foreground: Color.menu.text
      bordered: true
      onClicked: Util.execDetached("uwsm-app -- xdg-open " + Util.shellQuote("https://github.com/tdslot"))
    }
  }

  SettingRow {
    label: "@Tech0001"
    hint: I18n.t("Application matching restoration")

    Button {
      text: I18n.t("GitHub ↗")
      foreground: Color.menu.text
      bordered: true
      onClicked: Util.execDetached("uwsm-app -- xdg-open " + Util.shellQuote("https://github.com/Tech0001"))
    }
  }

  SectionLabel { text: I18n.t("Bug Hunters & Diagnostics") }

  SettingRow {
    label: "@justinlharter"
    hint: I18n.t("Suspend/resume screen null recovery diagnostics")

    Button {
      text: I18n.t("GitHub ↗")
      foreground: Color.menu.text
      bordered: true
      onClicked: Util.execDetached("uwsm-app -- xdg-open " + Util.shellQuote("https://github.com/justinlharter"))
    }
  }

  SettingRow {
    label: "@maugustoldo (Marcos Augusto)"
    hint: I18n.t("GTK icon resolving, launcher matching, and theme accent")

    Button {
      text: I18n.t("GitHub ↗")
      foreground: Color.menu.text
      bordered: true
      onClicked: Util.execDetached("uwsm-app -- xdg-open " + Util.shellQuote("https://github.com/maugustoldo"))
    }
  }

  SettingRow {
    label: "@m-bowden (Michael Bowden)"
    hint: I18n.t("Webapp Exec-URL .execString desktop entry investigation")

    Button {
      text: I18n.t("GitHub ↗")
      foreground: Color.menu.text
      bordered: true
      onClicked: Util.execDetached("uwsm-app -- xdg-open " + Util.shellQuote("https://github.com/m-bowden"))
    }
  }

  SettingRow {
    label: "@herman6888"
    hint: I18n.t("Omarchy 4.x overlay plugin appLibrary diagnostic")

    Button {
      text: I18n.t("GitHub ↗")
      foreground: Color.menu.text
      bordered: true
      onClicked: Util.execDetached("uwsm-app -- xdg-open " + Util.shellQuote("https://github.com/herman6888"))
    }
  }
}
