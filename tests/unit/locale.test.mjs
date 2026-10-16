// Tests for Locale.js: the display-time translation layer behind the local
// Chinese patch. The dictionary is the risky part - a duplicated key silently
// overwrites the first one, and a key that does not match the upstream literal
// byte for byte never matches at runtime - so both are checked mechanically.
import { test } from "node:test"
import assert from "node:assert/strict"
import { readFileSync } from "node:fs"
import vm from "node:vm"

const file = process.env.LOCALEJS || new URL("../../Locale.js", import.meta.url)
const src = readFileSync(file, "utf8")
// `.pragma library` is a QML directive, not JavaScript: strip it for the vm.
const L = vm.createContext({})
vm.runInContext(src.replace(/^\.pragma library\s*\n/, ""), L)
const plain = (v) => JSON.parse(JSON.stringify(v))

test("resolveLang: explicit wins, auto follows the shell locale", () => {
  assert.equal(L.resolveLang("zh", "en_US.UTF-8"), "zh")
  assert.equal(L.resolveLang("en", "zh_CN.UTF-8"), "en")
  assert.equal(L.resolveLang("auto", "zh_CN.UTF-8"), "zh")
  assert.equal(L.resolveLang("auto", "zh_HK"), "zh")
  assert.equal(L.resolveLang("auto", "en_US.UTF-8"), "en")
  assert.equal(L.resolveLang("auto", ""), "en")
  assert.equal(L.resolveLang(undefined, ""), "en")
})

test("t(): English by default, Chinese once set, English for unknown keys", () => {
  L.setLang("en")
  assert.equal(L.t("Autohide"), "Autohide")
  L.setLang("zh")
  assert.equal(L.t("Autohide"), "自动隐藏")
  assert.equal(L.t("A string upstream just invented"), "A string upstream just invented")
  assert.equal(L.t(""), "")
  assert.equal(L.t(undefined), undefined)
})

test("t() is idempotent - leaf and call site may both translate", () => {
  L.setLang("zh")
  const once = L.t("Tooltip")
  assert.equal(L.t(once), once)
})

test("tr(): an explicit language beats the shared flag", () => {
  L.setLang("en")
  assert.equal(L.tr("Unpin", "zh"), "取消固定")
  assert.equal(L.tr("Unpin", "en"), "Unpin")
  L.setLang("zh")
  assert.equal(L.tr("Unpin", "en"), "Unpin")
  // "auto" falls back to the flag, which is what the shell locale resolved to.
  assert.equal(L.tr("Unpin", "auto"), "取消固定")
})

test("opts(): labels translate, values are untouched", () => {
  L.setLang("zh")
  // The vm builds its own Array, so compare through JSON (as the other suites do).
  const out = plain(L.opts([{ value: "off", label: "Off" }, { value: "badge", label: "Badge" }]))
  assert.deepEqual(out.map((o) => o.value), ["off", "badge"])
  assert.equal(out[0].label, "关闭")
  assert.equal(out[1].label, "Badge") // not in the dictionary: left alone
  L.setLang("en")
  assert.deepEqual(plain(L.opts(["Off", "Badge"])), ["Off", "Badge"])
})

test("searchEntries(): bilingual terms, input left alone", () => {
  const input = [{ key: "autohide", page: "behavior", label: "Autohide", terms: ["hide"] }]
  const out = L.searchEntries(input)
  assert.deepEqual(input[0].terms, ["hide"])
  assert.ok(out[0].terms.includes("hide"))
  assert.ok(out[0].terms.includes("自动隐藏"))
  assert.ok(out[0].terms.some((t) => t.includes("隐藏")))
})

test("fmt(): substitutes %1 %2 in order, so a language may reorder or drop one", () => {
  const key = "%1 of %2 — delete one to save a new look"
  L.setLang("en")
  assert.equal(L.fmt(key, 6, 6), "6 of 6 — delete one to save a new look")
  L.setLang("zh")
  assert.equal(L.fmt(key, 6, 6), "6 套已经存满了——先删掉一套才能存新的")
  assert.equal(L.fmt("Save current look", 1), "保存当前的外观")  // no placeholder: untouched
  assert.equal(L.fmt("no such key: %1", 7), "no such key: 7")    // untranslated is fine too
})

test("DICT: no duplicate keys, no empty values, English keys only", () => {
  const body = src.slice(src.indexOf("var DICT"))
  const keys = [...body.matchAll(/^\s*"((?:[^"\\]|\\.)+)":/gm)].map((m) => m[1])
  assert.ok(keys.length > 300, `dictionary looks truncated: ${keys.length} keys`)
  const seen = new Set()
  const dupes = keys.filter((k) => (seen.has(k) ? true : (seen.add(k), false)))
  assert.deepEqual(dupes, [], "duplicate DICT keys silently shadow the first entry")
  for (const k of keys) assert.ok(!/[\u3000-\u9fff]/.test(k), `key is not English: ${k}`)
  const values = [...body.matchAll(/:\s*"((?:[^"\\]|\\.)*)"/g)].map((m) => m[1])
  assert.equal(values.length, keys.length)
  for (const v of values) assert.ok(v.trim().length > 0, "empty translation")
})
