<div align="center">
  <div style="display:inline-block; background:#f4f4f4; padding:18px 28px 16px; width:min(100%, 980px); box-sizing:border-box;">
    <h1 style="margin:0; font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; font-size:clamp(4rem,9vw,15rem); font-weight:900; line-height:0.82; letter-spacing:-0.08em; color:#1f1f1f; text-transform:uppercase; text-shadow: 0 0 0 #1f1f1f, 6px 6px 0 rgba(0,0,0,0.08);">
      <span style="display:inline-block; transform:skewX(-8deg);">StyLua</span>
      <span style="display:inline-block; margin-left:0.12em; transform:skewX(-8deg);">Roblox</span>
    </h1>
  </div>

  <div style="display:flex; justify-content:center; align-items:center; flex-wrap:wrap; gap:10px; margin-top:18px;">
    <span style="display:inline-block; padding:6px 12px; border-radius:999px; background:#3f7fbf; color:#fff; font-weight:700; font-size:0.9rem; letter-spacing:0.02em;">release v2.3.0</span>
    <span style="display:inline-block; padding:6px 12px; border-radius:999px; background:#d87a27; color:#fff; font-weight:700; font-size:0.9rem;">downloads 0</span>
    <span style="display:inline-block; padding:6px 12px; border-radius:999px; background:#e26d32; color:#fff; font-weight:700; font-size:0.9rem;">license GPL-3.0</span>
  </div>

  <div style="display:flex; justify-content:center; flex-wrap:wrap; gap:8px; margin-top:12px;">
    <span style="display:inline-flex; align-items:center; gap:8px; padding:6px 12px; border-radius:6px; background:#dfe3e9; color:#1e2329; font-weight:600; font-size:0.9rem; border:1px solid rgba(28,33,38,0.18);">🪟 Windows</span>
    <span style="display:inline-flex; align-items:center; gap:8px; padding:6px 12px; border-radius:6px; background:#dfe3e9; color:#1e2329; font-weight:600; font-size:0.9rem; border:1px solid rgba(28,33,38,0.18);">🍎 macOS</span>
    <span style="display:inline-flex; align-items:center; gap:8px; padding:6px 12px; border-radius:6px; background:#dfe3e9; color:#1e2329; font-weight:600; font-size:0.9rem; border:1px solid rgba(28,33,38,0.18);">🐧 Linux x64</span>
    <span style="display:inline-flex; align-items:center; gap:8px; padding:6px 12px; border-radius:6px; background:#dfe3e9; color:#1e2329; font-weight:600; font-size:0.9rem; border:1px solid rgba(28,33,38,0.18);">🧩 LinuxArm64</span>
    <span style="display:inline-flex; align-items:center; gap:8px; padding:6px 12px; border-radius:6px; background:#dfe3e9; color:#1e2329; font-weight:600; font-size:0.9rem; border:1px solid rgba(28,33,38,0.18);">📦 Package</span>
  </div>
</div>

[StyLua](https://github.com/JohnnyMorganz/StyLua) roblox plugin is a formatter made for roblox studio.

## Installation

### With GitHub Releases & Roblox Marketplace

- Download the `StyLua-Roblox` from [GitHub Releases Page](https://github.com/Barocena/StyLua-Roblox/releases).
- Install the [plugin](https://create.roblox.com/marketplace/asset/15035645978/StyLua-Plugin)

### Manual Installation
###### Installing with GitHub releases and roblox marketplace is recommended

#### Requirements
- [git](https://git-scm.com/downloads)
- [npm](https://nodejs.org/en)
- [Rojo](https://rojo.space)

#### Program
- `git clone` the Project
- run `npm install`
- run `node index.js` to start the web server

#### Plugin
- `git clone` the Project
- cd to the `plugin` folder
- run `rojo build --plugin -o stylua.rbxmx`
- reboot the studio, plugin will be installed

## Usage

Once installed, you can run the program and use the plugin on Studio, Program needs to run while you using the plugin.

To Format, click the StyLua button or bind a shortcut from shortcut settings.<br>
Formatting with a script editor open will format the current script.<br>
To format multiple scripts, you can close the script editor and select the scripts you want to format from Explorer and format.

To Change the Configuration of StyLua, Click the Open Settings Button.<br>
more info about options and what it does can be found [here](https://github.com/JohnnyMorganz/StyLua?tab=readme-ov-file#options)

To Create Place-only Settings, Add a module named `StyLua` (case-sensitive) to ServerStorage.<br>
Copy the Settings from Open Settings menu and paste it in, plugin will use these settings
