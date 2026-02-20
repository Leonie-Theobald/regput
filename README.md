## regput - Neovim Plugin for Viewing and Pasting Register Content

### Benefit of regput
regput opens a floating window showing the register contents browsable with vim motions.
The selected register content is separately rendered and can be pasted on one key press.

This makes the interaction and usability of registers easy and convenient.
- no raw strings and control characters
- no forgetting the register name before pasting
- no manual typing of `"<reg-name>p`

### Default Key Bindings

| Key           | Action                        |
|---------------|-------------------------------|
| `<leader>"`   | Start regput                  |
| `j`, `k`, etc.| Browse registers              |
| `p`           | Paste after cursor and close  |
| `P`           | Paste before cursor and close |
| `q`           | Close regput                  |

### Install with `Packer`
Add this to `packer.lua`
``` lua
use {
    "leonie-theobald/regput",
    config = function()
        require("regput").setup{}
    end,
}
```

and run `:PackerSync`
