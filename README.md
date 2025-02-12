# nvim.config

My neovim config, originally forked and then detached from
['kickstart.nvim'](https://github.com/nvim-lua/kickstart.nvim) which is a starting point for developing your own confiuration.

## Description

This builds on top of the minimal kickstart configuration to add support for working with R, quarto and RMarkdown documents.  The main building blocks of the configuration are:

- LSP support through ['mason'](https://github.com/williamboman/mason.nvim) and ['mason-lspconfig'](https://github.com/williamboman/mason-lspconfig.nvim)
- Code completion through ['nvim-cmp'](https://github.com/hrsh7th/nvim-cmp)
- ['telescope'](https://github.com/nvim-telescope/telescope.nvim) file finder
- ['oil'](https://github.com/stevearc/oil.nvim) file system manager
- ['slime'](https://github.com/jpalardy/vim-slime) to send R code to a terminal buffer running R
- ['quarto-nvim'](https://github.com/quarto-dev/quarto-nvim) to support quarto documents

On top of these ingredients this configuration contains helper keymaps to custom functions for things like
- Starting and closing an R terminal buffer
- Sending a line/paragraph/entire file to the R terminal buffer
- Previewing a quarto document
- Rendering a quarto document

To learn the configuration keymaps you can explore the ['which-key'](https://github.com/folke/which-key.nvim) menus that appear.  In general, commands to do with R all begin with '<leader>r' and commands to do with quarto documents begin with `<leader>q`.  Pressing these will open a which-key menu that you can peruse.  Note, '<leader>' is spacebar in this configuration, you can change this in `lua/config.global.lua`.

You can also run nvim in your config location and do `<leader>sg`  ('search with grep') and look for `vim.set.keymap` to find all the places keymaps are defined in the confiuration lua files.

## Installation

External Requirements:
- Basic utils: `git`, `make`, `unzip`, C Compiler (`gcc`)
- [ripgrep](https://github.com/BurntSushi/ripgrep#installation)
- Clipboard tool (xclip/xsel/win32yank or other depending on the platform)
- A [Nerd Font](https://www.nerdfonts.com/): optional, provides various icons
  - if you have it set `vim.g.have_nerd_font` in `init.lua` to true
- [R](https://cran.r-project.org/) and [quarto](https://quarto.org/) installed.  Note - if you have Rstudio I think this installs quarto by default.

Neovim's configurations are located under the following paths, depending on your OS:

| OS | PATH |
| :- | :--- |
| Linux, MacOS | `$XDG_CONFIG_HOME/nvim`, `~/.config/nvim` |
| Windows (cmd)| `%localappdata%\nvim\` |
| Windows (powershell)| `$env:LOCALAPPDATA\nvim\` |

#### Recommended Step

[Fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) this repo
so that you have your own copy that you can modify, then install by cloning the
fork to your machine using one of the commands below, depending on your OS.

#### Clone kickstart.nvim

> **NOTE**
> If following the recommended step above (i.e., forking the repo), replace
> `ASeatonSpatial` with `<your_github_username>` in the commands below

<details><summary> Linux and Mac </summary>

```sh
git clone https://github.com/ASeatonSpatial/nvim.config "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
```

</details>

<details><summary> Windows </summary>

If you're using `cmd.exe`:

```
git clone https://github.com/ASeatonSpatial/nvim.config "%localappdata%\nvim"
```

If you're using `powershell.exe`

```
git clone https://github.com/ASeatonSpatial/nvim.config "${env:LOCALAPPDATA}\nvim"
```

</details>

### Post Installation

Start Neovim

```sh
nvim
```

That's it! Lazy will install all the plugins you have. Use `:Lazy` to view
the current plugin status. Hit `q` to close the window.

## Usage

All my custom keymaps will appear in the ['which-key'](https://github.com/folke/which-key.nvim) buffer at the bottom when you press keys in normal mode.


## FAQ

* What should I do if I already have a pre-existing Neovim configuration?
  * You should back it up and then delete all associated files.
  * This includes your existing init.lua and the Neovim files in `~/.local`
    which can be deleted with `rm -rf ~/.local/share/nvim/`
* Can I keep my existing configuration in parallel to kickstart?
  * Yes! You can use [NVIM_APPNAME](https://neovim.io/doc/user/starting.html#%24NVIM_APPNAME)`=nvim-NAME`
    to maintain multiple configurations. For example, you can install the kickstart
    configuration in `~/.config/nvim-kickstart` and create an alias:
    ```
    alias nvim-kickstart='NVIM_APPNAME="nvim-kickstart" nvim'
    ```
    When you run Neovim using `nvim-kickstart` alias it will use the alternative
    config directory and the matching local directory
    `~/.local/share/nvim-kickstart`. You can apply this approach to any Neovim
    distribution that you would like to try out.
* What if I want to "uninstall" this configuration:
  * See [lazy.nvim uninstall](https://lazy.folke.io/usage#-uninstalling) information
