# nvim.config

My neovim config for working with R, quarto and Rmarkdown files.  Originally forked and then detached from
['kickstart.nvim'](https://github.com/nvim-lua/kickstart.nvim) which is a starting point for developing your own confiuration.

Note - this configuration is under active development and likely to change substantially.  Beware if you fork this repo.  I would suggest forking then instantly detaching if you are likely to customise this.

For the quarto support this config has borrowed some pieces from ['jmburh/quarto-nvim-kickstarter'](https://github.com/jmbuhr/quarto-nvim-kickstarter/blob/main/init.lua). 
I recommend the youtube channel [youtube.com/@jmbuhr](https://www.youtube.com/@jmbuhr) for more information on his configuration.  
The main difference with this configuration is I have added more support for working with `.R` files and I have written my own interface to the plugins that send code to terminal buffers. 

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
- Inserting an R code chunk in a quarto document
- Running an R code chunk in a quarto document
- Previewing math equations in a quarto document

To learn the configuration keymaps you can explore the ['which-key'](https://github.com/folke/which-key.nvim) menus that appear at the bottom when you press keys in normal mode.  In general, commands to do with R all begin with `<leader>r` and commands to do with quarto documents begin with `<leader>q`.  Pressing these will open a which-key menu that you can peruse.  Note, `<leader>` is spacebar in this configuration, you can change this to something else in `lua/config.global.lua`.

You can also run nvim in your config location and do `<leader>sg`  ('search with grep') and look for `vim.set.keymap` to find all the places keymaps are defined in the confiuration lua files.

## Should I try this configuration?

This is a very minimal set up for working with R code in neovim.  There are more extensive options out there like the ['nvim-r'](https://github.com/jalvesaq/Nvim-R) plugin.  
If you want a more IDE-like experience with more documentation and a bigger user-base then ['nvim-r'](https://github.com/jalvesaq/Nvim-R) is probably the better choice. 
The main benefit of this configuration is that it is fully written in lua and so is easily customisable and extendible using the modern `neovim` ecosystem.
It does not have almost all of the features of  ['nvim-r'](https://github.com/jalvesaq/Nvim-R) 

This configuration is suitable for somebody comfortable exploring `nvim` configurations to learn how things work and making tweaks if it doesn't match up with your intended workflow.  
It is not intended to be a beginner-friendly neovim experience.  
If you are new, I recommend starting with ['kickstart.nvim'](https://github.com/nvim-lua/kickstart.nvim) and returning here at a later date.

This configuration works well if all you want to do is open a single R terminal buffer and then send code to that single terminal from other buffers. 
Other situations like mulitple buffers open running different languages (e.g. R and python) are likely to dramatically fail. 

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

## FAQ

* I don't want to install the whole configuration, can you point me to the relevant parts about working with R, quarto and Rmarkdown?
  * The files `lua/config/R.lua` and `lua/plugins/quarto.lua` contain most of it.
  * The LSP set up is in `lua/plugins/lsp.lua` and `lua/plugings/cmp.lua`.  
  * I haven't tested this but I think those 4 files have the things required and in theory can be incorporated piecemeal to other configurations.  

Some kickstart FAQs that might be useful to you:

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
  * See [lazy.nvim uninstall](https://lazy.folke.io/usage#-uninstalling)

## Feedback

This is my first custom neovim configuration so I am sure there are many ways to improve it.  Please feel free to submit any issues or questions.
