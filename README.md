# A complete BSPWM Window Manager Environment
<div align = center>

![bspwm-dotfiles](https://github.com/gh0stzk/dotfiles/assets/67278339/0340846a-74d4-4a43-9430-142b0832738d)




&ensp;[<kbd> <br> Install <br> </kbd>](#-installation)&ensp;
&ensp;[<kbd> <br> Features <br> </kbd>](#-features)&ensp;
&ensp;[<kbd> <br> Themes <br> </kbd>](#-the-themes)&ensp;
&ensp;[<kbd> <br> Keybindings <br> </kbd>](#very-useful-keybindigs-to-know)&ensp;
&ensp;[<kbd> <br> Wiki <br> </kbd>](https://github.com/gh0stzk/dotfiles/wiki)&ensp;
<br><br><br></div>

https://github.com/user-attachments/assets/3eaae1e2-04dc-4a9b-8c91-139f85f5fb9e

<br>

## 👻 Welcome (Message from the fork maintainer)

Welcome to this fork of the original dotfiles by **gh0stzk**. I'm chrisM (or YejiF), and I've created a port of these themes, originally designed for Arch Linux, adapting them for use in **Kali Linux**.

The main goal of this project is to preserve all the functionalities and features implemented by gh0stzk, such as the lightweight, efficient, and functional **bspwm** environment, while delivering an equally smooth experience on Kali Linux.

### What's Different in This Fork?

This fork includes several adaptations to make the dotfiles work seamlessly on Kali Linux:

- **Package Manager Migration**: All `pacman`/`paru` commands have been replaced with `apt` equivalents
- **Update System**: The Updates script syncs apt package lists into a private cache (no `sudo`), like `checkupdates` does on Arch
- **Clipboard Manager**: Replaced `clipcat` (AUR-only) with `copyq` (available in Kali repos)
- **Modular Installer**: Single entry point (`./KaliInstaller`) backed by 4 modules for easier troubleshooting
- **Systemd Services**: Renamed from ArchUpdates to KaliUpdates, enabled automatically by the installer
- **Native builds**: `st` is compiled from gh0stzk's source and `i3lock-color` comes from the Kali repos
- **Not included**: Ghostty and the Android MTP mounter (`simple-mtpfs`) are not packaged for Kali and were removed

I recommend reading the original README from gh0stzk before proceeding to install this fork. The new modular installation system is more reliable and allows you to install components step-by-step if needed.

You can find the instructions for installing these dotfiles on Kali Linux in the [Installation](#-installation) section. Read it carefully before install it.

To finish, if you want to collaborate with this fork, feel free to send pull requests with new features, bug fixes, or any improvements. You're also welcome to report issues if needed.
I might not always be able to respond to pull requests or issues right away, but I'll do my best to stay on top of things and keep this project maintained as regularly as I can. Thanks for your understanding and support!

## 👻 Welcome (Message from the owner and the goat gh0stzk)

Welcome to my dotfiles. I’m gh0stzk from Mexico.

These dotfiles are designed with the goal of providing a bspwm environment that is lightweight, efficient, and functional, tailored for any use—whether it’s gaming, web browsing, or a productive work setting.

You’ll have 18 unique themes to choose from, each with its own style, colors, and navigation bar options. With this variety, you’re sure to find one that suits your preferences and needs.

## :book: Wiki
I already started writing the [**Wiki**](https://github.com/gh0stzk/dotfiles/wiki), you should give it a read. If it is your first time with a WM, you may be interested in reading [First steps after installing the dotfiles](https://github.com/gh0stzk/dotfiles/wiki/Firsts-steps-after-installing) or maybe read [frequently asked questions and answers](https://github.com/gh0stzk/dotfiles/wiki/Questions---Answers) [Keybinds](https://github.com/gh0stzk/dotfiles/wiki/Keyboard-Shortcuts) [Firefox Theme](https://github.com/gh0stzk/dotfiles/wiki/Firefox-Theme).

## 🚀 Features
<img src="https://user-images.githubusercontent.com/67278339/221605474-21d65156-0cf7-485c-bd1a-40792c37817e.png" alt="Linux Fetch" align="right" width="450">

#### Change themes on the fly

You can switch themes instantly, with no need to restart your session or environment. With just one click, the change is applied immediately.

#### Consistency Across the Environment

Unlike Matugen, Pywal, and other wallpaper-based theming tools, colors are not extracted from images. Every theme includes a handcrafted color palette, carefully selected to maintain consistency, readability, and visual appeal.

A modular theming system propagates these colors across the entire desktop environment. Switching themes instantly updates:

- BSPWM
- GTK (3.x)
- Dunst
- Rofi
- Terminals
  - Alacritty
  - Kitty
  - St
  - Xfce-terminal
- Neovim
- Eww
- Firefox
- Jgmenu
- Geany
- ScreenLocker (i3lock-color)
- Mpv Player
- Cava
- Zathura
- Polybar
- Cli-Tools
  - Yazi
  - Fzf-Tab
  - Bat
  - Eza
  - Ncmpcpp

Not all modules are enabled.

If you want to know how it works and how to enable or disable modules, go to [Color Modules](https://github.com/gh0stzk/dotfiles/wiki/Color-Modules)

ToDo-List:

- Obsidian
- Telegram-desktop
- Steam
- Btop
- Qt (5/6)
- Rmpc

#### Performance optimized

BSPWM is not a desktop environment (DE), and that’s exactly what makes it stand out in terms of lightweight performance. On my systems, my BSPWM-dotfiles environment starts with under **600 MB of RAM usage**. While these numbers don't tell the whole story, they do highlight the minimalist approach that a window manager should embrace.

In addition, each theme can be configured independently — either by manually editing the theme’s configuration file or using my RiceEditor application. This ensures a high level of customization: if you want a minimalist setup for a specific theme, you can disable animations, shadows, rounded borders, or fading effects. On the other hand, if you prefer a more visually rich theme with all those features enabled, that’s fully supported as well. My dotfiles are built to provide that level of flexibility.

#### Multi-Monitor support

If you have multiple monitors, BSPWM will automatically detect and configure up to 4 displays when launching with my dotfiles.

If you connect an additional monitor while the session is already running, simply reload BSPWM using the `Super + Alt + r` key combination, and your monitors will be configured instantly.

You can check the Wiki [👉 Monitors Setup](https://github.com/gh0stzk/dotfiles/wiki/Monitors-setup) if you want to edit the default layouts.

#### RiceEditor

Is an application designed to simplify the customization of your current theme. It allows you to easily adjust various visual and configuration aspects, tailoring your environment to your preferences without the need to manually edit configuration files.

#### Wallpaper Engines

My dotfiles support **5 different methods** for setting your favorite wallpaper:

1. **Random**: Sets a random wallpaper from the theme’s Walls directory.
2. **CustomDir**: Sets a random wallpaper from a directory you specify.
3. **Default**: Sets a specific image as wallpaper. (Default)
4. **CustomAnimated**: Supports animated wallpapers (.mp4, .mkv, .gif).
5. **Slideshow**: Changes the wallpaper every 15 minutes with a random image from the theme’s Walls directory.

Each option is **theme-specific**, meaning you can have an animated wallpaper in one theme, a static image in another, or a custom directory in a third — And all your settings will be preserved per theme. By default, all themes load a default wallpaper from their Walls Rice folder.

Check the wiki for more details: [👉 Wallpapers Configuration](https://github.com/gh0stzk/dotfiles/wiki/Wallpapers-Configuration)

#### Scratchpad

A _scratchpad_ is a tool designed to provide quick, temporary access to applications or notes without disrupting the desktop workflow. When activated, the scratchpad appears over the current workspace, allowing the user to access applications like a terminal, text editor, or any configured tool. Minimizing it hides the scratchpad from view but keeps it running in the background, ready to be reopened with a simple keyboard shortcut.

It's ideal for quick note-taking, running commands, or accessing auxiliary tools without losing focus on the current task.

#### Rofi Applets

Rofi applets to simplify your workflow:

- Wallpaper Selector - See the wiki [WallpaperSelector](https://github.com/gh0stzk/dotfiles/wiki/WallpaperSelector)
- Network Manager
- Bluetooth Controller
- Clipboard Manager
- Screenshot Tool
- Power Menu
- Keyboard Layout
- Terminal Selector (Alacritty, Kitty and ST)
- Rofi app launcher style selector
- Tab app switcher
- Pass Manager (Using pass app)

#### Neovim Setup

Simple yet powerful neovim configuration with the following features:

- Treesitter
- Lsp servers
- Completions [blink.nvim](https://github.com/Saghen/blink.nvim)
- Formatting [conform.nvim](https://github.com/stevearc/conform.nvim)
- Picker [Snacks-picker](https://github.com/folke/snacks.nvim/blob/main/docs/picker.md)
- Explorer [Snacks-explorer](https://github.com/folke/snacks.nvim/blob/main/docs/picker.md)
- Tab Line [barbar.nvim](https://github.com/romgrk/barbar.nvim)
- Statusline [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
- Autopairs [mini-autopairs](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-pairs.md)
- Hipatterns [mini-hipatterns](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-hipatterns.md)
- Indent guides [Snacks-indent](https://github.com/folke/snacks.nvim/blob/main/docs/indent.md)
- Dashboard [Snacks-dashboard](https://github.com/folke/snacks.nvim/blob/main/docs/dashboard.md)
- WhichKey [which-key.nvim](https://github.com/folke/which-key.nvim)

#### Optimized ZSH Configuration

Optimized, native ZSH configuration. Not __Oh-My-Zsh__ or other bloated plugin managers. Some features:

- Fastest and optimized performance compinit function
- Autocompletion
- Syntax highlighting
- History substring search
- Fzf-tab completion with previews!!

---

### 🎨 Launchers

| :tshirt: Theme Selector |
|:-:|
|![Screenshot-11_12_2023-01-06-03](https://github.com/gh0stzk/dotfiles/assets/67278339/b11b5c58-b9ec-446b-8980-4f77bebb3432)|

| :traffic_light: Wallpaper Selector |
|:-:|
|![Shot-2024-11-08-134530](https://github.com/user-attachments/assets/dbac8c47-f12c-4242-97d6-38ad1193f76b)|

| :tshirt: Bar Selector |
|:-:|
|![Bspwm Bar Selector](https://github.com/user-attachments/assets/94c4d699-890c-47d4-85dc-8e9622f4c679)|

### 🎨 The themes

| Emilia |
|:-:|
|<img src="https://user-images.githubusercontent.com/67278339/280174054-8f56d12d-4efa-4024-99e1-4679591b45ca.gif" alt="Emilia Rice" align="center">|

| Jan |
|:-:|
| <img src="https://github.com/gh0stzk/dotfiles/assets/67278339/6e4959b7-6d07-42c6-8ede-2f3c16094ad2" alt="Jan Rice" align="center"> |

| Aline |
|:-:|
| <img src="https://github.com/gh0stzk/dotfiles/assets/67278339/5ae48d8d-ebcb-4fd5-9c80-78fc325a7a38" alt="Aline Rice" align="center"> |

| Andrea |
|:-:|
| <img src="https://github.com/gh0stzk/dotfiles/assets/67278339/1bfd302f-0e3f-4973-975b-56c78d6140ee" alt="Andrea Rice" align="center"> |

| Cynthia |
|:-:|
| <img src="https://github.com/gh0stzk/dotfiles/assets/67278339/5df45139-1d73-4f5f-8e8d-a417c86bfb96" alt="Cynthia Rice" align="center"> |

| Isabel |
|:-:|
| <img src="https://github.com/gh0stzk/dotfiles/assets/67278339/f2a0002f-3370-4361-9301-08abadcad600" alt="Isabel Rice" align="center"> |


| Silvia |
|:-:|
|<img src="https://github.com/gh0stzk/dotfiles/assets/67278339/616c2d93-fabf-41c2-9ab8-9c7b4d6a2e35" alt="Silvia Rice" align="center">|

| Melissa |
|:-:|
| <img src="https://github.com/gh0stzk/dotfiles/assets/67278339/a63e250d-c5d1-4360-afd7-cf64bf55a0fc" alt="Melissa Rice" align="center"> |

| Pamela |
|:-:|
| <img src="https://github.com/gh0stzk/dotfiles/assets/67278339/f9e85839-53c9-4e15-a800-8a2f7ca40691" alt="Pamela Rice" align="center"> |

| Cristina |
|:-:|
| <img src="https://github.com/gh0stzk/dotfiles/assets/67278339/e14c6777-25f6-4621-a88b-4fda71dbcc7f" alt="Cristina Rice" align="center"> |

| Karla |
|:-:|
| <img src="https://github.com/gh0stzk/dotfiles/assets/67278339/5455afdf-cc2f-4a8c-8fcd-526c59066d50" alt="Karla Rice" align="center"> |

| z0mbi3 |
|:-:|
| <img src="https://github.com/gh0stzk/dotfiles/assets/67278339/ff65caa8-6a15-4873-bf05-edf89ac0985d" alt="z0mbi3 Rice" align="center"> |

| Brenda |
|:-:|
| <img src="https://github.com/gh0stzk/dotfiles/assets/67278339/22e37944-5aad-46bf-8934-3a57d1718ed2" alt="Brenda Rice" align="center"> |

| Daniela |
|:-:|
| <img src="https://github.com/gh0stzk/dotfiles/assets/67278339/f296d6b4-9c8a-49ae-bf63-d82e5105f122" alt="Daniela Rice" align="center"> |

| Marisol |
|:-:|
| <img src="https://github.com/gh0stzk/dotfiles/assets/67278339/d11d20c5-1edc-44c8-901b-a4103a139617" alt="Daniela Rice" align="center"> |

| h4ck3r |
|:-:|
| <img src="https://github.com/gh0stzk/dotfiles/assets/67278339/2d55fcc6-1ea4-4d56-8c46-3a3fe10566fe" alt="Hacker Rice" align="center"> |

| Varinka |
|:-:|
| <img src="https://github.com/gh0stzk/dotfiles/assets/67278339/454d82b4-8f09-4768-bf51-6ce7818ad226" alt="Varinka Rice" align="center"> |

| Yael |
|:-:|
| <img src="https://github.com/gh0stzk/dotfiles/assets/67278339/cbb0a1cc-4e2d-46a2-a4f2-ee0be3d08b50" alt="Yael Rice" align="center"> |

---

### Rofi applets

| ![Shot-2024-11-09-131850](https://github.com/user-attachments/assets/05107f74-e137-41c0-9132-31d9c4fa0bb4) | ![Shot-2024-11-09-131918](https://github.com/user-attachments/assets/c5680b39-9aba-41e5-a781-7f23f7f8e336) |
| :--------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------: |
|                                                 Power Menu                                                 |                                                Screenshoter                                                |

| ![Shot-2024-11-09-132031](https://github.com/user-attachments/assets/0893b0b6-1211-43cb-9923-f4e42af70f4b) |
| :---: |
| Keyboard Layout |

| ![Shot-2024-11-09-150142](https://github.com/user-attachments/assets/f7d1c404-c2e8-43c0-ad5e-6b052e3918c3) | ![Shot-2024-11-09-155335](https://github.com/user-attachments/assets/889d2ccf-beff-402d-8804-6d82c5638860) |
| :--------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------: |
|                                              Network Manager                                               |                                             Clipboard Manager                                              |

| ![Shot-2024-11-09-153419](https://github.com/user-attachments/assets/4af56dfa-f61f-4b45-8350-d064fe67663a) | ![Shot-2024-11-09-153444](https://github.com/user-attachments/assets/fbd09603-8e8f-4cbb-a685-83a69a6d4c35) |
| :--------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------: |
|                                             Bluetooth Manager                                              |                                              Terminal Manager                                              |

| ![Shot-2025-04-08-084756](https://github.com/user-attachments/assets/835366c8-88c5-4daf-8260-5c822e27abc8) | ![Shot-2025-04-08-084924](https://github.com/user-attachments/assets/c32f3cdb-7a5a-4372-b6f2-3f4a09f50868) |
| :--------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------: |
|                                              Tab app switcher                                              |                                              Rofi style selector                                           |

| ![Shot-2025-04-08-084756](https://github.com/user-attachments/assets/59a84a0d-b471-444a-b4f9-091d4a0e51e2) |
| :--------------------------------------------------------------------------------------------------------: |
|                                              Rofi password manager                                         |

---

### Rofi app launcher styles
| ![Shot-2025-04-08-090012](https://github.com/user-attachments/assets/57ebcc98-73ea-4f76-bb2b-fe3f187be5e7) | ![Shot-2025-04-08-090041](https://github.com/user-attachments/assets/26361cd3-c3b4-48a2-a550-8df5cff120f5) | ![Shot-2025-04-08-090107](https://github.com/user-attachments/assets/16da6b0f-5a9e-4410-bb95-cb9fe696ce55) |
| :---: | :---: | :---: |
| Normal | Full | Minimal |

### Fzf tab terminal completions with previews!

| ![fzf tab](https://github.com/user-attachments/assets/2771e549-f7cc-44da-baf2-6c9fa299f0fb) |
| :---: |
| cd, ls, pacman, systemctl, kill, cat, commands with preview! |

### Eww widgets

| ![ProfilePane](https://github.com/user-attachments/assets/07827cff-63b9-40db-b0ef-8c214a5d8ec3) | ![MusicPlayer](https://github.com/user-attachments/assets/b96c49a1-57d1-43e5-bff0-cab2e6b4d101) |
| :---: | :---: |
| Profile Panel | Music Player |

---

### Rice Editor

| ![Shot-2024-11-09-155549](https://github.com/user-attachments/assets/2ac910c8-171f-47eb-8210-1469b6f75cc2) |
| :--------------------------------------------------------------------------------------------------------: |
|                                                Rice Editor                                                 |

### Lockscreen

| ![Lockscreen](https://github.com/user-attachments/assets/2f09b915-f426-49c3-b9b6-07be4e781f5a) |
| :--------------------------------------------------------------------------------------------: |
|                                           Lockscreen                                           |

### Jgmenu

| ![Jgmenu](https://github.com/user-attachments/assets/82daebec-66a6-4716-8e78-b02fcec7e77c) |
| :----------------------------------------------------------------------------------------: |
|                                           Jgmenu                                           |

## Yazi config

https://github.com/user-attachments/assets/8e15cc1a-88b8-4a7e-a4de-e7da76021406

## Scratchpad

https://github.com/user-attachments/assets/79764678-c519-4a41-a333-2a862a6d10f8

## Environment

| ![Gtk-Ranger-Music](https://github.com/user-attachments/assets/a7f7c082-5ffd-4a6c-babf-7361764cec80) |
| :--------------------------------------------------------------------------------------------------: |
|            The environment changes with each theme. In the gif: (Ranger, Thunar, Ncmpcpp)            |

### Firefox theme

| Firefox theme - z0mbi3 Fox |
|:-:|
| <img src="https://github.com/user-attachments/assets/877774da-1d27-4e9e-bd79-b084cf0c293e" alt="Firefox theme - z0mbi3-Fox" align="center"> |

### Neovim setup

| Neovim setup |
|:-:|
| ![Neovim setup](https://github.com/user-attachments/assets/deff5074-3d9b-4f00-8edd-82c83b6dccf4) |
| Plugins included [Neovim setup wiki](https://github.com/gh0stzk/dotfiles/wiki/Neovim-setup) |

## Very useful keybindigs to know...

| Keys | Action |
| :-------------------: | :---------------------------------------------------------------: |
| `super` + `x` | Close Windows |
| `super` + `Enter`<br>`super` + `alt` + `Enter` | Open a terminal<br>Open a floating terminal. |
| `alt` + `@space` | Display menu to select a theme. |
| `super` + `@space` | Apps Menu. |
| `super` + `alt` + `@space` | Bar Selector. |
| `super` + `alt` + `w`| Opens a menu to select a wallpaper. |
| `super` + `alt` + `h`<br>`super` + `alt` + `u` | Hides bar/s<br>unhide bar/s |
| `super` + `alt` + `s` | Takes screenshot. |
| `ctrl` + `alt` + `[plus,minus,t]` | Changes transparency on focused window. |
| `ctrl` + `super` + `alt` + `p`<br>`ctrl` + `super` + `alt` + `r`<br>`ctrl` + `super` + `alt` + `k` | Power off computer<br>Restart computer<br>Brute kill a window/process |
| `super` + `alt` + `r` | Restart bspwm. |
| `alt` + `F1` | Show keybinds cheatsheet |

And more.. You need to look sxhkdrc file for more, or press Alt + F1 for a cheatsheet.

---

> [!CAUTION]
> ⚠️⚠️⚠️ My dotfiles are designed for a **1600x900** resolution with **96 DPI** on a single monitor.
> Some elements may appear different on higher or lower resolutions. You may need to make adjustments to adapt them to your preferences and setup. ⚠️⚠️⚠️

> [!important]
> ✏️✏️✏️ The installer assumes you already have a **functional** Arch Linux installation, whether it’s a fresh install or an existing setup.
>
> A login manager of your choice is required; **lightdm** is recommended.
>
> The rofi connection manager applet, works with **NetworkManager**
>
> If using a virtual machine, be sure to change the Picom backend from **glx** to **xrender** before rebooting, and verify that hardware acceleration is correctly configured in your VM. ✏️✏️✏️

> [!warning]
> :wrench::wrench::wrench: I have tested the installation and functionality of these dotfiles on both high- and low-end machines.
>
> Some adjustments may still be needed, such as changing the Picom backend or VSync settings to ensure compatibility with your graphics card.
>
> If you encounter any issues, feel free to open an [issue](https://github.com/gh0stzk/dotfiles/issues). :wrench::wrench::wrench:

---

### 💾 Installation:

> [!NOTE]
> The installer only works for **Kali** Linux and Debian-based distros. On non-Kali systems some packages (like `i3lock-color`) may not be in the repos.

> [!IMPORTANT]
> **New Modular Installation System**: The installation has been completely redesigned with a modular approach. You can now:
> - Run a full automated installation
> - Install specific modules independently
> - Skip modules that fail and retry them later
> - See detailed progress and error messages

#### Quick Installation (Recommended)

Clone the repository and run the installer:

```sh
git clone --depth=1 https://github.com/chrism3th/gh0stzk-bspwm-kali.git
cd gh0stzk-bspwm-kali
./KaliInstaller
```

The installer installs the dotfiles from the clone you run it from (current branch and commit), so you can test a branch before merging it.

Options:

| Command | Description |
| --- | --- |
| `./KaliInstaller` | Interactive menu (full install, pick a module, system info) |
| `./KaliInstaller --full` | Full installation without the menu |
| `./KaliInstaller --info` | Show system information and installed tools |
| `./KaliInstaller --help` | Show help |

#### Installation Modules

The installation is divided into 4 modules, run in this order:

1. **Setup & Packages** (`01-setup-packages.sh`)
   - System verification (disk space, internet, not running as root)
   - APT packages (bspwm, polybar, picom, rofi, dunst, i3lock-color, copyq, etc.)

2. **Compile & Build** (`02-compile-build.sh`)
   - Rust/Cargo, yazi and xcolor (symlinked into `/usr/local/bin`)
   - eww (X11 build)
   - xwinwrap (animated wallpapers)
   - st (gh0stzk's fork, built from source)
   - Zsh plugins (fzf-tab, history-substring-search)

3. **Fonts & Themes** (`03-fonts-themes.sh`)
   - Nerd Fonts
   - gh0stzk GTK themes, icons and cursors

4. **Dotfiles & Configuration** (`04-dotfiles-config.sh`)
   - Backup of your current configs to `~/.RiceBackup/`
   - Dotfiles installation (optional Neovim config; Firefox theme if a profile exists)
   - Services: MPD (user), KaliUpdates timer, Zsh as default shell
   - Virtual machine tweaks for Picom

Every module can also be run on its own, e.g. `./install-kali-scripts/modules/02-compile-build.sh`.
A single log of the whole run is written to `~/RiceError-<date>.log`.

#### Troubleshooting

- If a module fails, check the error message and fix the issue
- You can re-run individual modules without affecting others
- Module 2 (Compile & Build) takes the longest due to Rust/eww compilation
- On virtual machines the installer switches Picom to the `xrender` backend automatically
- Check `~/RiceError-<date>.log` for the full output of every step

#### Post-Installation

After installation completes:
1. **Reboot** your system
2. Select **bspwm** from your login manager
3. Log in with your credentials
4. Press `Alt + @space` to open the theme selector
5. Press `Alt + F1` to see all keybindings
