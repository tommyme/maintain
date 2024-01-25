# how to create your ahk script

## concepts

- hotkey
  it looks like: `^j::` `Esc::`

- hotstr
  it looks like: `::bty::` it indicates `by the way`

- functions
  
  > functions need a comma after the function name
  
  - Send,
  - Msgbox, 
  - Run,
  - ...

- symbols

| symbols | indicates |
| ------- | --------- |
| #       | win       |
| !       | alt       |
| ^       | ctrl      |
| +       | shift     |
| &       |           |

- list of keys
[list of keys](https://www.autohotkey.com/docs/KeyList.htm) 

## some examples

```ahk
^j::
Send, My First Script
return

::ftw::Free the whales

::btw::
MsgBox, You typed btw.
return

Numpad0 & Numpad1::
MsgBox, You pressed Numpad1 while holding down Numpad0.
return
```

solution 
[ctrl-tab <-> alt-tab](https://www.autohotkey.com/boards/viewtopic.php?t=70379) 
