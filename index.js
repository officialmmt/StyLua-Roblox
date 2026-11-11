const express = require("express");
const StyLua = require("@johnnymorganz/stylua");
const app = express();
const Tray = require("trayicon");
const fs = require("fs");
const path = require("path");

let ConsoleWindow;
try {
  ConsoleWindow = require("node-hide-console-window");
} catch (e) {
  // Native addon could not be loaded (e.g. Node ABI mismatch inside standalone pkg)
}

// StyLua Roblox
// Version 1.3.0

const EnumList = {
  ["call_parentheses"]: StyLua.CallParenType,
  ["collapse_simple_statement"]: StyLua.CollapseSimpleStatement,
  ["indent_type"]: StyLua.IndentType,
  ["line_endings"]: StyLua.LineEndings,
  ["quote_style"]: StyLua.QuoteStyle,
  ["space_after_function_names"]: StyLua.SpaceAfterFunctionNames,
};

app.use(express.text({ limit: "10mb" }));
app.post("/stylua", (req, res) => {
  try {
    const input = req.body;
    if (typeof input !== "string") {
      res.status(400).setHeader("Content-Type", "text/plain");
      return res.send("Invalid request body: expected text/plain");
    }

    const Query = req.query.Config;
    var Configs = StyLua.Config.new();

    if (Query) {
      let Parsed;
      try {
        Parsed = JSON.parse(Query);
      } catch (jsonErr) {
        res.status(400).setHeader("Content-Type", "text/plain");
        return res.send(`Invalid JSON in Config query: ${jsonErr.message}`);
      }

      for (const [key, value] of Object.entries(Parsed)) {
        if (EnumList[key]) {
          Configs[key] = EnumList[key][value];
        } else if (key == "sort_requires") {
          Configs[key] = StyLua.SortRequiresConfig.new().set_enabled(value);
        } else {
          Configs[key] = value;
        }
      }
    }

    const output = StyLua.formatCode(
      input,
      Configs,
      StyLua.Range.from_values(),
      StyLua.OutputVerification.None
    );

    res.setHeader("Content-Type", "text/plain");
    res.send(output);
  } catch (err) {
    res.status(400).setHeader("Content-Type", "text/plain");
    res.send(`Formatting error: ${err.message || err}`);
  }
});

app.listen(18259, "127.0.0.1", () => {
  console.log("Server started on 127.0.0.1:18259");
});

process.on("uncaughtException", (err) => {
  // Prevent background tray or native errors from crashing the HTTP server
  console.error("Background error:", err && err.message ? err.message : err);
});

try {
  const iconPath = path.join(path.dirname(__filename), "assets/icon.ico");
  if (fs.existsSync(iconPath)) {
    Tray.create(
      {
        icon: fs.readFileSync(iconPath),
        title: "StyLua",
      },
      function (tray) {
        if (tray && typeof tray.on === "function") {
          tray.on("error", () => {});
        }
        tray.setMenu(tray.item("Quit", () => process.exit(0)));
      }
    )
      .then((tray) => {
        if (tray && typeof tray.on === "function") {
          tray.on("error", () => {});
        }
      })
      .catch(() => {});
  }
} catch (trayErr) {
  // Tray is optional, server continues running even if tray fails
}

function hideConsoleWindow() {
  if (ConsoleWindow && typeof ConsoleWindow.hideConsole === "function") {
    try {
      ConsoleWindow.hideConsole();
      return;
    } catch (e) {}
  }
}

hideConsoleWindow();



