#!/usr/bin/env python3
"""Native installer and TJS regressions; fixtures contain no game data."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import struct
import subprocess
import sys
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]
MACOS = sys.platform == "darwin"
SUPPORTED = MACOS or sys.platform.startswith("linux")
PLATFORM = "macos" if MACOS else "linux"
INSTALLER = REPO / ("install-mac.sh" if MACOS else "install-linux.sh")
RUNTIME = REPO / "Port" / ("runtime-macos" if MACOS else "runtime")


def write_icon(path):
    frames = []
    for size in (16, 32, 48, 64):
        pixels = b"\x80\x60\x40\xff" * size * size
        mask = bytes(((size + 31) // 32) * 4 * size)
        header = struct.pack("<IiiHHIIiiII", 40, size, size * 2, 1, 32,
                             0, len(pixels), 0, 0, 0, 0)
        frames.append((size, header + pixels + mask))
    offset = 6 + 16 * len(frames)
    directory = bytearray(struct.pack("<HHH", 0, 1, len(frames)))
    for size, frame in frames:
        directory.extend(struct.pack("<BBBBHHII", size, size, 0, 0, 1, 32,
                                     len(frame), offset))
        offset += len(frame)
    path.write_bytes(directory + b"".join(frame for _, frame in frames))


def snapshot(directory):
    return {str(path.relative_to(directory)): hashlib.sha256(path.read_bytes()).digest()
            for path in directory.rglob("*") if path.is_file()}


@unittest.skipUnless(SUPPORTED, "requires native Linux or macOS tools")
class InstallerTests(unittest.TestCase):
    def setUp(self):
        for command in (("sips", "iconutil") if MACOS else ("magick",)):
            if not shutil.which(command):
                self.skipTest(f"missing installer prerequisite: {command}")
        self.temp = tempfile.TemporaryDirectory(prefix="fate-port-test-")
        self.addCleanup(self.temp.cleanup)
        self.parent = Path(self.temp.name)
        self.game = self.parent / "Game with spaces"
        self.game.mkdir()
        for name in ("patch.xp3", "data.xp3", "etc.xp3", "rule.xp3", "Fate.exe", "config.ksc"):
            (self.game / name).write_text("original " + name)
        (self.game / "faterealtanua_savedata").mkdir()
        (self.game / "faterealtanua_savedata/save.ksd").write_text("original save")
        for route in ("FATE", "UBW", "HF"):
            write_icon(self.game / f"icon_{route}.ico")

    def install(self, relative=False, env=None):
        return subprocess.run([str(INSTALLER), self.game.name if relative else str(self.game)],
                              cwd=self.parent, env=env, text=True, capture_output=True, timeout=60)

    def test_reinstall_preserves_game_and_unowned_files(self):
        native = self.game / PLATFORM
        native.mkdir()
        (native / "keep.txt").write_text("unowned runtime neighbor")
        if MACOS:
            bundle = self.game / "FateMac.app/Contents/Resources"
            bundle.mkdir(parents=True)
            (bundle / "keep.txt").write_text("unowned bundle content")
        original = snapshot(self.game)
        first = self.install()
        self.assertEqual(first.returncode, 0, first.stderr)
        installed = snapshot(self.game)
        second = self.install()
        self.assertEqual(second.returncode, 0, second.stderr)
        reinstalled = snapshot(self.game)
        self.assertEqual({name: reinstalled[name] for name in original}, original)
        self.assertEqual({name: installed[name] for name in original}, original)

    def test_cdpath_does_not_redirect_relative_install(self):
        result = self.install(relative=True, env={**os.environ, "CDPATH": str(self.parent)})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(os.access(self.game / PLATFORM / "krkrsdl2", os.X_OK))

    def test_symlinked_runtime_directory_is_rejected(self):
        saves = self.game / "faterealtanua_savedata"
        (self.game / PLATFORM).symlink_to(saves, target_is_directory=True)
        before = snapshot(saves)
        result = self.install()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(snapshot(saves), before)

    def test_symlinked_output_cannot_overwrite_configuration(self):
        native = self.game / PLATFORM
        native.mkdir()
        output = native / ("settings.tjs" if MACOS else "icon_FATE.bmp")
        config = self.game / "config.ksc"
        output.symlink_to(config)
        original = config.read_bytes()
        result = self.install()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(config.read_bytes(), original)

    def test_directory_at_file_destination_is_rejected(self):
        collision = self.game / PLATFORM / "plugin/extrans.so"
        collision.mkdir(parents=True)
        (collision / "keep.txt").write_text("unowned directory")
        before = snapshot(self.game)
        self.assertNotEqual(self.install().returncode, 0)
        self.assertEqual(snapshot(self.game), before)

    def test_invalid_icon_does_not_partially_replace_runtime(self):
        native = self.game / PLATFORM
        native.mkdir()
        (native / "krkrsdl2").write_text("previous runtime")
        route = "FATE" if MACOS else "HF"
        (self.game / f"icon_{route}.ico").write_bytes(b"invalid icon")
        before = snapshot(self.game)
        self.assertNotEqual(self.install().returncode, 0)
        self.assertEqual(snapshot(self.game), before)


@unittest.skipUnless(SUPPORTED, "requires the bundled native engine")
class OverlayTests(unittest.TestCase):
    def run_script(self, script, plugins=True):
        with tempfile.TemporaryDirectory(prefix="fate-tjs-test-") as temporary:
            directory = Path(temporary)
            settings = json.dumps(str(REPO / "Port/settings.tjs"))
            source = script.replace("SETTINGS", settings)
            (directory / "startup.tjs").write_text(source)
            result = subprocess.run(
                [str(RUNTIME / "krkrsdl2"), "-nosel", str(directory) + "/"],
                cwd=directory, env={**os.environ, "SDL_VIDEODRIVER": "dummy",
                                    "SDL_AUDIODRIVER": "dummy",
                                    "KRKRSDL2_PATH": str(RUNTIME / "plugin") if plugins else temporary},
                text=True, capture_output=True, timeout=20)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual((directory / "result.txt").read_text(encoding="utf-16").strip(), "PASS")

    def test_caption_accelerators_preserve_literal_ampersands(self):
        self.run_script('''
try {
    Scripts.execStorage(SETTINGS);
    var ok = global.portMenuCaption("Save && Exit(&X)") === "Save & Exit"
        && global.portMenuCaption("&&&Help") === "&Help"
        && global.portMenuCaption("  &Load   Game  ") === "Load Game";
    [ok ? "PASS" : "FAIL"].save("result.txt");
} catch(e) { [e.message].save("result.txt"); }
System.exit(0);
''')

    def test_missing_required_plugin_reports_failure(self):
        self.run_script('''
var failed = false;
try { Scripts.execStorage(SETTINGS); }
catch(e) { failed = true; }
[failed ? "PASS" : "FAIL"].save("result.txt");
System.exit(0);
''', plugins=False)


if __name__ == "__main__":
    unittest.main()
