const exe = require("@angablue/exe");
const fs = require("fs");
const { execSync } = require("child_process");

// 1. Kill any existing instance of StyLua-Roblox.exe so the file is not locked
try {
  execSync("taskkill /F /IM StyLua-Roblox.exe", { stdio: "ignore" });
} catch (e) {
  // Process is not running, ignore
}

const build = exe({
  entry: "package.json",
  out: "StyLua-Roblox.exe",
  version: "1.3.0",
  target: "node20-win-x64",
  icon: "./assets/icon.ico",
  pkg: ["-C", "Brotli"],
  executionLevel: "asInvoker",
  properties: {
    FileDescription: "StyLua Roblox",
    ProductName: "StyLua Roblox",
    LegalCopyright: "https://github.com/Barocena/StyLua-Roblox",
    OriginalFilename: "StyLua-Roblox.exe",
  },
});

build
  .then(async () => {
    const filePath = "StyLua-Roblox.exe";
    let patched = false;

    // Retry loop with delay to allow Windows Defender / file locks to release
    for (let attempt = 0; attempt < 10; attempt++) {
      try {
        await new Promise((resolve) => setTimeout(resolve, 500));
        if (fs.existsSync(filePath)) {
          const buffer = fs.readFileSync(filePath);
          const peOffset = buffer.readInt32LE(0x3C);
          const subsystemOffset = peOffset + 24 + 68;
          buffer.writeUInt16LE(2, subsystemOffset); // 2 = IMAGE_SUBSYSTEM_WINDOWS_GUI
          fs.writeFileSync(filePath, buffer);
          patched = true;
          break;
        }
      } catch (err) {
        if (err.code === "EBUSY" && attempt < 9) {
          continue;
        }
        throw err;
      }
    }

    if (patched) {
      console.log(
        "Build completed! (Configured as silent GUI application - no terminal window)"
      );
    } else {
      console.log("Build completed!");
    }
  })
  .catch((err) => {
    console.error("Build failed:", err);
    process.exit(1);
  });

