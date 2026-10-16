import QtQuick
import qs.Commons
import qs.Ui
import "../../Locale.js" as I18n

// Settings page: icon style, tint, grid, contrast and icon size/spacing rows.
// Instantiated by SettingsPanel, which injects root (the Dock, for
// values and setters) and panel (page/edit state).

Column {
  property var root: null
  property var panel: null
  width: parent.width


  SectionLabel { text: I18n.t("Icons") }

  ChoiceRow {
    key: "iconStyle"
    label: I18n.t("Icon style")
    hint: I18n.t("Monochrome and dot matrix take one colour from the theme.")
    options: [
      { value: "original", label: I18n.t("Original") },
      { value: "mono", label: I18n.t("Monochrome") },
      { value: "pixel", label: I18n.t("Pixel") },
      { value: "dots", label: I18n.t("Dot matrix") }
    ]
    value: root ? root.iconStyle : "original"
    onPicked: function(v) { root.setOption("iconStyle", v) }
  }
  ChoiceRow {
    key: "iconTint"
    label: I18n.t("Icon colour")
    visible: root ? (root.iconStyle === "mono" || root.iconStyle === "dots") : false
    options: [
      { value: "text", label: I18n.t("Text") },
      { value: "accent", label: I18n.t("Accent") },
      { value: "bw", label: I18n.t("B/W") }
    ]
    value: root ? root.iconTint : "text"
    onPicked: function(v) { root.setOption("iconTint", v) }
  }
  SliderRow {
    key: "iconGrid"
    label: root && root.iconStyle === "dots" ? I18n.t("Dots across") : I18n.t("Pixels across")
    hint: I18n.t("Fewer is chunkier.")
    visible: root ? (root.iconStyle === "pixel" || root.iconStyle === "dots") : false
    minimum: 8
    maximum: 32
    step: 1
    value: root ? root.iconGrid : 16
    onCommitted: function(v) { root.setOption("iconGrid", Math.round(v)) }
  }
  SliderRow {
    key: "iconContrast"
    label: I18n.t("Contrast")
    hint: I18n.t("Separates the symbol from its backdrop; high values flatten icons to a simple, poster-like shape.")
    visible: root ? (root.iconStyle === "mono" || root.iconStyle === "dots") : false
    minimum: 0
    maximum: 1
    step: 0.05
    displayScale: 100
    suffix: "%"
    value: root ? root.iconContrast : 0
    onCommitted: function(v) { root.setOption("iconContrast", Math.round(v * 100) / 100) }
  }
  SliderRow {
    key: "iconStrength"
    label: I18n.t("Strength")
    hint: I18n.t("How much of the effect covers the original icon.")
    visible: root ? (root.iconStyle === "mono" || root.iconStyle === "dots") : false
    minimum: 0
    maximum: 1
    step: 0.05
    displayScale: 100
    suffix: "%"
    value: root ? root.iconStrength : 1
    onCommitted: function(v) { root.setOption("iconStrength", Math.round(v * 100) / 100) }
  }
  SwitchRow {
    key: "iconHoverOriginal"
    label: I18n.t("Show original on hover")
    hint: I18n.t("The icon under the pointer drops the style and shows as shipped. Icons in an opened group follow this too.")
    visible: root ? root.iconStyle !== "original" : false
    checked: root ? root.iconHoverOriginal : false
    onToggled: root.setOption("iconHoverOriginal", !root.iconHoverOriginal)
  }
  SwitchRow {
    key: "iconHoverReveal"
    label: I18n.t("Dithered reveal")
    hint: I18n.t("The original icon appears cell by cell, rising from the bottom, instead of all at once.")
    visible: root ? (root.iconHoverOriginal && (root.iconStyle === "mono" || root.iconStyle === "dots")) : false
    checked: root ? root.iconHoverReveal : false
    onToggled: root.setOption("iconHoverReveal", !root.iconHoverReveal)
  }

  SectionLabel { text: I18n.t("Size & Spacing") }

  SliderRow {
    key: "iconSize"
    label: I18n.t("Icon size")
    minimum: 24
    maximum: 64
    step: 2
    suffix: " px"
    value: root ? root.iconSize : 36
    onCommitted: function(v) { root.setIconSize(Math.round(v)) }
  }
  SliderRow {
    key: "itemSpacing"
    label: I18n.t("Spacing")
    hint: (root && root.labelPlates) ? I18n.t("Gap between icons. Label plates keep it between 4 and 12 px.") : I18n.t("Gap between icons.")
    minimum: 0
    maximum: 16
    step: 1
    suffix: " px"
    value: root ? root.itemSpacing : 4
    onCommitted: function(v) { root.setItemSpacing(Math.round(v)) }
  }
}
