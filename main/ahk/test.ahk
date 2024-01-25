SetCapsLockState, AlwaysOff
;Caps lock to esc if pressed once, ctrl if held
; *CapsLock::
;     Send {Blind}{Ctrl Down}
;     cDown := A_TickCount
; Return

; *CapsLock up::
;     ; Modify the threshold time (in milliseconds) as necessary
;     If ((A_TickCount-cDown) < 150){
;         Send {Blind}{Ctrl Up}{Esc}
;     }
;     Else {
;         Send {Blind}{Ctrl Up}
;     }
; Return
CapsLock::RCtrl


>^[::Send, {Esc}
>^i::Send, {Home}
>^o::Send, {End}
>^h::Send, {Left}
>^j::Send, {Down}
>^k::Send, {Up}
>^l::Send, {Right}

>^+o::Send, +{End} 
>^+i::Send, +{Home} 
>^+h::Send, +{Left} 
>^+j::Send, +{Down}
>^+k::Send, +{Up}
>^+l::Send, +{Right}

NumLock::Suspend
#CapsLock::CapsLock
