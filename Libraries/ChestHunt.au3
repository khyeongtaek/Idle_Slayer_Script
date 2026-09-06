#include-once
#include "Common.au3"

Enum $eRewardChest = 0, $eMimicChest = 1, $e2xChest = 2, $eChestHuntEnd = 3, $eLifeSaverChest = 4
Enum $eStateNoMimic = 0, $eStateOneMimic = 1, $eStateTwoMimics = 2, $eStateOpenLifeSaver = 3, $eStateNormal = 4

Func Chesthunt($bNoLockpickingState, $bPerfectChestHuntState, $bNoReinforcedCrystalSaverState)
	WriteInLogs("Chesthunt Started")
	If $bNoLockpickingState Then
		Sleep(4000)
	Else
		Sleep(2000)
	EndIf

	Local $iSaverX = 0
	Local $iSaverY = 0
	Local $iPixelX = 185
	Local $iPixelY = 325
	; 라이프 세이버 위치 찾기
	For $iY = 1 To 3
		For $iX = 1 To 10
			PixelSearch($iPixelX, $iPixelY - 1, $iPixelX + 5, $iPixelY, 0xFFEB04)
			If Not @error Then
				$iSaverX = $iPixelX
				$iSaverY = $iPixelY
				ExitLoop (2)
			EndIf
			$iPixelX += 95
		Next
		$iPixelY += 95
		$iPixelX = 185
	Next

	; 실제 상자 사냥
	ProcessChestGrid($iSaverX, $iSaverY, $bNoLockpickingState, $bPerfectChestHuntState, $bNoReinforcedCrystalSaverState)

	; 닫기 버튼이나 퍼펙트 상자가 나올 때까지 찾는다
	Local $bPerfectChest = False
	Local $iEndScreenAttempts = 0
	While True
		Sleep(50)
		$iEndScreenAttempts += 1

		PixelSearch(550, 694, 550, 694, 0xAF0000)
		If Not @error Then
			ExitLoop
		EndIf
		; 퍼펙트 상자 찾기
		PixelSearch(457, 439, 457, 439, 0xF68F37)
		If Not @error Then
			$bPerfectChest = True
			MouseClick("left", 457, 439, 1, 0)
		EndIf

		If $iEndScreenAttempts > 200 Then
			WriteInLogs("Chsthunt  Blocked divinity  X, Start Again ")
			ProcessChestGrid($iSaverX, $iSaverY, $bNoLockpickingState, $bPerfectChestHuntState, $bNoReinforcedCrystalSaverState)
			$iEndScreenAttempts = 0
		EndIf
	WEnd

	If $bPerfectChest Then WriteInLogs("Perfect ChestHunt Completed")
	MouseClick("left", 643, 693, 1, 0)
EndFunc   ;==>Chesthunt

Func ProcessChestGrid($iSaverX, $iSaverY, $bNoLockpickingState, $bPerfectChestHuntState, $bNoReinforcedCrystalSaverState)
	Local $iPixelX = 185
	Local $iPixelY = 325
	Local $iCount = 0
	Local $iCurrentState = $eStateNoMimic

	For $iY = 1 To 3
		For $iX = 1 To 10
			; 어떤 경우에도 라이프 세이버는 건너뛴다
			If $iPixelY == $iSaverY And $iPixelX == $iSaverX Then
				; 라이프 세이버가 마지막 상자면 다음 줄로 간다
				If $iX == 10 Then
					ExitLoop (1)
				Else
					$iPixelX += 95
					ContinueLoop
				EndIf
			EndIf

			Local $iChestResult = OpenChest($iPixelX, $iPixelY, $bNoLockpickingState)

			If $iChestResult == $eChestHuntEnd Then
				Return
			EndIf

			$iCurrentState = GetUpdatedState($iCount, $iCurrentState, $iChestResult, $bPerfectChestHuntState, $bNoReinforcedCrystalSaverState)

			If $iCurrentState == $eStateOpenLifeSaver Then
				$iCurrentState = OpenLifeSaver($iSaverX, $iSaverY, $bNoLockpickingState)
			EndIf

			$iPixelX += 95
			$iCount += 1
		Next
		$iPixelY += 95
		$iPixelX = 185
	Next
EndFunc   ;==>ProcessChestGrid


Func GetUpdatedState($iCount, $iCurrentState, $iChest, $bPerfectChestHuntState, $bNoReinforcedCrystalSaverState)

	; 라이프 세이버를 연 뒤에는 그냥 순서대로 상자를 연다
	If $iCurrentState == $eStateNormal Or $iChest == $eLifeSaverChest Then
		Return $eStateNormal
	EndIf

	; 2배 상자를 찾았으면 항상 라이프 세이버를 연다
	If $iChest == $e2xChest Then
		Return $eStateOpenLifeSaver
	EndIf

	If $bPerfectChestHuntState Then
		Local $bPerfectState = PerfectChestHuntState($iChest, $iCurrentState, $iCount)
		If $bPerfectState <> -1 Then Return $bPerfectState
	EndIf

	; 첫 두 상자의 결과로 상태를 정한다
	If $iCount == 0 Then
		If $bNoReinforcedCrystalSaverState Then Return $eStateOpenLifeSaver

		Switch $iChest
			Case $eRewardChest
				Return $eStateNoMimic
			Case $eMimicChest
				Return $eStateOneMimic
		EndSwitch
	ElseIf $iCount == 1 Then
		; 일반 전략에서는 두 번째 상자 뒤에 항상 라이프 세이버를 연다
		If Not $bPerfectChestHuntState Then Return $eStateOpenLifeSaver

		Switch $iCurrentState
			Case $eStateNoMimic
				Switch $iChest
					Case $eRewardChest
						Return $eStateNoMimic
					Case $eMimicChest
						Return $eStateOneMimic
				EndSwitch
			Case $eStateOneMimic
				Switch $iChest
					Case $eRewardChest
						Return $eStateOneMimic
					Case $eMimicChest
						Return $eStateTwoMimics
				EndSwitch
		EndSwitch
	EndIf

	Return $iCurrentState
EndFunc   ;==>GetUpdatedState

Func PerfectChestHuntState($iChest, $iCurrentState, $iCount)
	; 요약: 퍼펙트 상자 사냥은 2배 상자를 찾을 때까지 라이프 세이버를 무시한다.
	; 상태 0 - 첫 상자 보상, 둘째 상자 보상: 2배 상자를 못 찾았으면 12개를 더 연 뒤 라이프 세이버로 간다.
	; 상태 1 - 첫 상자 미믹, 둘째 상자 보상: 2배 상자를 못 찾았으면 14개를 더 연 뒤 라이프 세이버로 간다.
	; 상태 2 - 첫 상자 미믹, 둘째 상자 미믹: 미믹이 또 나올 확률이 낮으므로 20개를 더 연다. 그 뒤에도 2배 상자가 없으면 라이프 세이버로 간다.
	; 상태 3 - 첫 상자 미믹, 둘째 상자 2배: 목숨 2개를 얻기 위해 라이프 세이버를 바로 연다.
	; 상태 4 - 첫 상자 2배: 목숨 2개를 얻기 위해 라이프 세이버를 바로 연다.

	Switch $iChest
		Case $eRewardChest
			If $iCurrentState == $eStateNoMimic And $iCount == 13 Then
				Return $eStateOpenLifeSaver
			EndIf

			If $iCurrentState == $eStateOneMimic And $iCount == 15 Then
				Return $eStateOpenLifeSaver
			EndIf

			If $iCurrentState == $eStateTwoMimics And $iCount == 21 Then
				Return $eStateOpenLifeSaver
			EndIf
	EndSwitch

	Return -1
EndFunc   ;==>PerfectChestHuntState

Func OpenLifeSaver($iSaverX, $iSaverY, $bNoLockpickingState)
	MouseClick("left", $iSaverX + 33, $iSaverY - 23, 1, 0)
	If $bNoLockpickingState Then
		Sleep(1500)
	Else
		Sleep(550)
	EndIf
	Return $eLifeSaverChest
EndFunc   ;==>OpenLifeSaver


Func OpenChest($iPixelX, $iPixelY, $bNoLockpickingState)
	; 상자 열기
	MouseClick("left", $iPixelX + 33, $iPixelY - 23, 1, 0)
	If $bNoLockpickingState Then
		Sleep(1500)
	Else
		Sleep(550)
	EndIf
	; 상자 사냥이 끝났는지 확인
	PixelSearch(550, 694, 550, 694, 0xAF0000)
	If Not @error Then
		Return $eChestHuntEnd
	EndIf

	; 2배 상자면 조금 더 기다린다
	PixelSearch(500, 210, 500, 210, 0x00FF00)
	If Not @error Then
		Sleep(1000)
		Return $e2xChest
	EndIf

	; 미믹이면 조금 더 기다린다
	PixelSearch(434, 211, 434, 211, 0xFF0000)
	If Not @error Then
		If $bNoLockpickingState Then
			Sleep(2500)
		Else
			Sleep(1500)
		EndIf

		Return $eMimicChest
	EndIf

	Return $eRewardChest
EndFunc   ;==>OpenChest
