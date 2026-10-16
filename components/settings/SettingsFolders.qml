import QtQuick 6.11
import qs.Commons
import qs.Ui
import "../../Locale.js" as I18n

// Settings page: pinned folder rows and the folder colour picker.
// Instantiated by SettingsPanel, which injects root (the Dock, for
// values and setters) and panel (page/edit state).

Column {
  property var root: null
  property var panel: null
  width: parent.width


  SectionLabel { text: I18n.t("Pinned folders") }

  Repeater {
    model: [
      { path: "~/Downloads", name: "Downloads", icon: "folder-download" },
      { path: "~/Documents", name: "Documents", icon: "folder-documents" },
      { path: "~/Pictures", name: "Pictures", icon: "folder-pictures" },
      { path: "~/Projects", name: "Projects", icon: "folder-development" },
      { path: "~/Music", name: "Music", icon: "folder-music" },
      { path: "~/Videos", name: "Videos", icon: "folder-videos" },
      { path: "~", name: "Home", icon: "user-home" }
    ]
    delegate: SwitchRow {
      required property var modelData
      label: modelData.name
      hint: modelData.path
      checked: root ? (root.pinnedFolders, root.isFolderPinned(modelData.path)) : false
      onToggled: root.toggleFolderPin(modelData.path, modelData.name, modelData.icon)
    }
  }

  Repeater {
    model: {
      if (!root) return []
      var presets = ["~/Downloads", "~/Documents", "~/Pictures", "~/Projects", "~/Music", "~/Videos", "~"]
      var out = []
      for (var i = 0; i < root.pinnedFolders.length; i++)
        if (presets.indexOf(root.pinnedFolders[i].path) < 0) out.push(root.pinnedFolders[i])
      return out
    }
    delegate: SettingRow {
      required property var modelData
      label: modelData.name || I18n.t("Folder")
      hint: modelData.path

      Button {
        text: I18n.t("Remove")
        foreground: Color.menu.text
        bordered: true
        onClicked: root.toggleFolderPin(modelData.path, modelData.name, modelData.icon)
      }
    }
  }

  SettingRow {
    key: "customFolder"
    label: I18n.t("Custom folder")
    hint: I18n.t("Pick any directory to pin as a stack.")

    Button {
      text: I18n.t("Add folder…")
      foreground: Color.menu.text
      bordered: true
      onClicked: {
        panel.close()
        root.pickCustomFolder()
      }
    }
  }

  SectionLabel {
    key: "folderColor"
    text: I18n.t("Folder color")
  }

  Flow {
    width: parent.width
    spacing: Style.spacing.md
    bottomPadding: Style.spacing.lg

    Button {
      text: I18n.t("Theme")
      foreground: Color.menu.text
      bordered: true
      selected: root ? (root.folderColor === "theme" || !root.folderColor) : true
      onClicked: root.setFolderColor("theme")
    }

    // Monochrome outlines in black or white, whichever reads
    // better on what is behind them: the dock, or a stack popup.
    Button {
      text: I18n.t("Auto B/W")
      foreground: Color.menu.text
      bordered: true
      selected: root ? root.folderColor === "bw" : false
      onClicked: root.setFolderColor("bw")
    }

    Repeater {
      model: [
        { id: "white", color: "#ffffff" },
        { id: "black", color: "#111111" },
        { id: "Yaru-sage", color: "#61895a" },
        { id: "Yaru-olive", color: "#878846" },
        { id: "Yaru-blue", color: "#3d7ab8" },
        { id: "Yaru-purple", color: "#775aa6" },
        { id: "Yaru-magenta", color: "#b3497d" },
        { id: "Yaru-red", color: "#c73838" },
        { id: "Yaru-yellow", color: "#d9a13b" },
        { id: "Yaru-wartybrown", color: "#8a583e" },
        { id: "Yaru-prussiangreen", color: "#2d7f7b" },
        { id: "Yaru-dark", color: "#3c3b37" }
      ]
      delegate: Swatch {
        required property var modelData
        color: modelData.color
        selected: root ? root.folderColor === modelData.id : false
        onPicked: root.setFolderColor(modelData.id)
      }
    }
  }
}
