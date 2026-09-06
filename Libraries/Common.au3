#include-once
#include <File.au3>
#include <WinAPISys.au3>

Func setSetting()
	; GUI 이벤트 모드를 켠다
	Opt("GUIOnEventMode", 1)
	; 배경 입력이 잘 먹도록 Caps Lock 자동 처리를 끈다
	Opt("SendCapslockMode", 0)
	; PixelSearch 좌표를 활성 창의 클라이언트 영역 기준으로 맞춘다
	Opt("PixelCoordMode", 0)
	; MouseClick 좌표를 활성 창의 클라이언트 영역 기준으로 맞춘다
	Opt("MouseCoordMode", 0)
	_WinAPI_SetKeyboardLayout("Idle Slayer", 0x0409)
EndFunc   ;==>setSetting

Func WriteInLogs($sMessage)
	_FileWriteLog("IdleRunnerLogs\Logs.txt", $sMessage)
EndFunc   ;==>WriteInLogs

Func cSend($iPressDelay, $iPostPressDelay = 0, $sKey = "Up")
	Send("{" & $sKey & " Down}")
	Sleep($iPressDelay)
	Send("{" & $sKey & " Up}")
	Sleep($iPostPressDelay)
	Return
EndFunc   ;==>cSend

Func FindPixelUntilFound($iX1, $iY1, $iX2, $iY2, $sHex, $iTimer = 15000)
	Local $hTimer = TimerInit()
	Local $aPos
	Do
		$aPos = PixelSearch($iX1, $iY1, $iX2, $iY2, $sHex)
	Until Not @error Or $iTimer < TimerDiff($hTimer)
	If $iTimer < TimerDiff($hTimer) Then
		Return False
	Else
		Return $aPos
	EndIf
EndFunc   ;==>FindPixelUntilFound


Func Slider()
	;왼쪽 위
	PixelSearch(441, 560, 443, 560, 0x007E00)
	If Not @error Then
		MouseMove(840, 560, 0)
		MouseClickDrag("left", 840, 560, 450, 560)
		Return
	EndIf

	;왼쪽 아래
	PixelSearch(441, 620, 443, 620, 0x007E00)
	If Not @error Then
		MouseMove(840, 620, 0)
		MouseClickDrag("left", 840, 620, 450, 620)
		Return
	EndIf

	;오른쪽 위
	PixelSearch(847, 560, 850, 560, 0x007E00)
	If Not @error Then
		MouseMove(450, 560, 0)
		MouseClickDrag("left", 450, 560, 840, 560)
		Return
	EndIf

	;오른쪽 아래
	PixelSearch(847, 620, 850, 620, 0x007E00)
	If Not @error Then
		MouseMove(450, 620, 0)
		MouseClickDrag("left", 450, 620, 840, 620)
		Return
	EndIf
EndFunc   ;==>Slider
