#include-once
#include "Common.au3"

; ===============================================================================================================================
; 보너스 스테이지 시작 대기 시간 (밀리초)
;
; 입장 조작(Slider)이 끝난 뒤부터 실제 발판이 나올 때까지 기다리는 시간이다.
; 이 시간이 맞지 않으면 첫 구간의 동기화 지점을 놓쳐서 스테이지를 통째로 실패한다.
; 스테이지 2 와 3 은 시작 연출 길이가 서로 달라서 값을 따로 둔다.
;
;   $iBonusStage2StartDelay - 보너스 스테이지 2 에서 쓰는 값
;   $iBonusStage3StartDelay - 보너스 스테이지 3 에서 쓰는 값
;
; 스테이지가 자꾸 실패하면 해당 숫자만 100 단위로 조금씩 바꿔 가며 맞춘다.
; 숫자를 키우면 더 늦게 시작하고, 줄이면 더 일찍 시작한다.
; ===============================================================================================================================
Global Const $iBonusStage2StartDelay = 2900
Global Const $iBonusStage3StartDelay = 3900

Func BonusStage($bSkipBonusStageState)
	WriteInLogs("Start of BonusStage")
	Sleep(200)
	PixelSearch(160, 498, 200, 498, 0x16171F)
	If Not @error Then
		$bBonusStage3 = True
	Else
		$bBonusStage3 = False
	EndIf

	Do
		Slider()
		Sleep(500)
		PixelSearch(775, 448, 775, 448, 0xFFFFFF)
	Until @error

	If $bSkipBonusStageState Then
		BonusStageDoNothing($bBonusStage3 ? 3 : 2)
		Return
	EndIf

	; 스테이지 종류에 따라 시작 대기 시간을 다르게 준다
	Sleep($bBonusStage3 ? $iBonusStage3StartDelay : $iBonusStage2StartDelay)
	PixelSearch(454, 91, 454, 91, 0xE1E0E2)
	If Not @error Then
		If $bBonusStage3 Then
			BonusStage3SB()
		Else
			BonusStage2SB()
		EndIf
	Else
		If $bBonusStage3 Then
			BonusStage3()
		Else
			BonusStage2()
		EndIf
	EndIf
EndFunc   ;==>BonusStage

Func BonusStageDoNothing($iNumber)
	WriteInLogs("Do nothing BonusStage Active")
	Do
		Sleep(200)
	Until BonusStageFail($iNumber)
EndFunc   ;==>BonusStageDoNothing

Func BonusStageFail($iNumber)
	Local $sLogMsg = "BonusStage" & $iNumber & " Failed"

	PixelSearch(716, 600, 716, 600, 0xAF0000)
	If Not @error Then
		MouseClick("left", 716, 600, 1, 0)
		WriteInLogs($sLogMsg)
		Return True
	EndIf
	Return False
EndFunc   ;==>BonusStageFail

Func BonusStageRetry($iNumber, $bSpiritBoost)
	Local $sLogMsg = "BonusStage" & $iNumber & ($bSpiritBoost ? "SB" : "")

	PixelSearch(615, 590, 615, 590, 0x00A400)
	If Not @error Then
		MouseClick("left", 560, 600, 1, 0)
		WriteInLogs($sLogMsg & " Retry")
		Sleep(1000)
		Return True
	EndIf

	Return False
EndFunc   ;==>BonusStageRetry

Func BonusStage2Fail()
	Return BonusStageFail(2)
EndFunc   ;==>BonusStage2Fail

Func BonusStage3Fail($bSpiritBoost)
	Local $sLogMsg = GetBS3LogText($bSpiritBoost)
	Local $bRetry = BonusStageRetry(3, $bSpiritBoost)

	If $bRetry Then
		Return True
	EndIf

	; 아이템 아이콘 찾기
	PixelSearch(1130, 604, 1130, 604, 0x989898)
	If Not @error Then
		WriteInLogs($sLogMsg & " Failed")
		Return True
	EndIf

	; 부스트 아이콘 찾기
	PixelSearch(115, 570, 125, 590, 0x09439b)
	If Not @error Then
		WriteInLogs($sLogMsg & " Failed")
		Return True
	EndIf

	; 윈드 러시 아이콘 찾기
	PixelSearch(115, 570, 125, 590, 0x099b66)
	If Not @error Then
		WriteInLogs($sLogMsg & " Failed")
		Return True
	EndIf

	Return False
EndFunc   ;==>BonusStage3Fail

Func BonusStage2SB()
	WriteInLogs("BonusStage2SB")
	; 1구간 동기화
	FindPixelUntilFound(220, 465, 220, 465, 0xCFBCB8)
	Sleep(200)
	;1구간 시작
	cSend(94, 1640) ;1
	cSend(47, 2072) ;2
	cSend(187, 688) ;3
	cSend(31, 672) ;4
	cSend(31, 1700) ;5
	cSend(94, 1640) ;1
	cSend(47, 2072) ;2
	cSend(187, 688) ;3
	cSend(31, 672) ;4
	cSend(31, 1700) ;5
	cSend(94, 5000) ;1
	If BonusStage2Fail() Then
		Return
	EndIf
	; 1구간 수집
	cSend(40, 2500)
	For $iX = 1 To 19
		Send("{Up}")
		Sleep(500)
	Next
	If BonusStage2Fail() Then
		Return
	EndIf
	WriteInLogs("BonusStage2SB Section 1 Complete")
	; 2구간 동기화
	FindPixelUntilFound(780, 513, 780, 513, 0xBB26DF)
	; 2구간 시작
	cSend(156, 719) ;1
	cSend(47, 687) ;2
	cSend(360, 1390) ;3
	cSend(485, 344) ;4
	cSend(406, 749) ;5
	cSend(78, 600) ;6
	cSend(94, 900) ;7
	cSend(109, 954) ;8
	cSend(31, 672) ;9
	cSend(515, 1344) ;10
	cSend(484, 297) ;11
	cSend(406, 749) ;12
	cSend(78, 600) ;13
	cSend(94, 900) ;14
	cSend(109, 954) ;15
	cSend(31, 672) ;16
	cSend(515, 1344) ;17
	cSend(469, 219) ;18
	cSend(297, 750) ;19
	cSend(156, 500) ;20
	cSend(110, 3000) ;21
	cSend(360, 2984) ;22
	cSend(531, 2313) ;23
	If BonusStage2Fail() Then
		Return
	EndIf
	; 2구간 수집
	cSend(350, 1000)
	For $iX = 1 To 20
		Send("{Up}")
		Sleep(500)
	Next
	If BonusStage2Fail() Then
		Return
	EndIf
	WriteInLogs("BonusStage2SB Section 2 Complete")
	;3구간 동기화
	FindPixelUntilFound(151, 465, 220, 465, 0xCFBCB8)
	; 3구간 시작
	cSend(109, 1203) ;1
	cSend(31, 641) ;2
	cSend(47, 1200) ;3
	cSend(1, 3100) ;4
	;반복
	cSend(109, 1203) ;5
	cSend(31, 641) ;6
	cSend(47, 1200) ;7
	cSend(1, 3100) ;8
	;반복
	cSend(109, 1203) ;9
	cSend(31, 641) ;10
	cSend(47, 1200) ;11
	cSend(1, 3100) ;12
	;반복
	cSend(109, 1203) ;13
	cSend(31, 641) ;14
	cSend(47, 5125) ;15
	If BonusStage2Fail() Then
		Return
	EndIf
	;3구간 수집
	cSend(900, 200)
	For $iX = 1 To 20
		Send("{Up}")
		Sleep(500)
	Next
	If BonusStage2Fail() Then
		Return
	EndIf
	WriteInLogs("BonusStage2SB Section 3 Complete")
	;4구간 동기화
	FindPixelUntilFound(250, 472, 100, 250, 0x0D2030)
	Sleep(200)
	;4구간 시작
	cSend(32, 2800) ;1
	cSend(31, 809) ;2
	cSend(41, 1200) ;3
	cSend(100, 900) ;4
	cSend(641, 500) ;5

	cSend(31, 850) ;6
	cSend(41, 770) ;7
	cSend(641, 400) ;8

	cSend(31, 850) ;9
	cSend(41, 870) ;10
	cSend(641, 300) ;11

	cSend(31, 850) ;12
	cSend(41, 790) ;13
	cSend(641, 400) ;14

	cSend(31, 850) ;15
	cSend(41, 840) ;16
	cSend(641, 300) ;17

	cSend(31, 850) ;18
	cSend(41, 840) ;19
	cSend(641, 300) ;20
	;4구간 수집
	For $iX = 1 To 23
		Send("{Up}")
		Sleep(500)
	Next
	If BonusStage2Fail() Then
		Return
	EndIf
	WriteInLogs("BonusStage2SB Section 4 Complete")
EndFunc   ;==>BonusStage2SB

Func BonusStage2()
	WriteInLogs("BonusStage2")
	; 1구간 동기화
	FindPixelUntilFound(220, 465, 220, 465, 0xCFBCB8)
	Sleep(200)
	;1구간 시작
	cSend(94, 1640) ;1
	cSend(32, 1218) ;2
	cSend(94, 600) ;3
	cSend(109, 1828) ;4
	cSend(63, 640) ;5
	cSend(47, 688) ;6
	cSend(78, 1906) ;7
	cSend(141, 1625) ;8
	cSend(47, 3187) ;9
	cSend(47, 734) ;10
	cSend(47, 750) ;11
	cSend(78, 1203) ;12
	cSend(110, 5000) ;13
	If BonusStage2Fail() Then
		Return
	EndIf
	; 1구간 수집
	cSend(40, 5000)
	For $iX = 1 To 17
		Send("{Up}")
		Sleep(500)
	Next
	If BonusStage2Fail() Then
		Return
	EndIf
	WriteInLogs("BonusStage2 Section 1 Complete")
	; 2구간 동기화
	FindPixelUntilFound(780, 513, 780, 513, 0xBB26DF)
	; 2구간 시작
	cSend(156, 719) ;1
	cSend(47, 687) ;2
	cSend(360, 1390) ;3
	cSend(485, 344) ;4
	cSend(406, 749) ;5
	cSend(78, 600) ;6
	cSend(94, 900) ;7
	cSend(109, 954) ;8
	cSend(31, 672) ;9
	cSend(515, 1344) ;10
	cSend(484, 297) ;11
	cSend(406, 749) ;12
	cSend(78, 600) ;13
	cSend(94, 900) ;14
	cSend(109, 954) ;15
	cSend(31, 672) ;16
	cSend(515, 1344) ;17
	cSend(469, 219) ;18
	cSend(297, 750) ;19
	cSend(156, 500) ;20
	cSend(110, 3000) ;21
	cSend(360, 2984) ;22
	cSend(531, 2313) ;23
	If BonusStage2Fail() Then
		Return
	EndIf
	; 2구간 수집
	cSend(350, 1000)
	For $iX = 1 To 20
		Send("{Up}")
		Sleep(500)
	Next
	If BonusStage2Fail() Then
		Return
	EndIf
	WriteInLogs("BonusStage2 Section 2 Complete")
	;3구간 동기화
	FindPixelUntilFound(151, 465, 220, 465, 0xCFBCB8)
	; 3구간 시작
	cSend(109, 1203) ;1
	cSend(31, 641) ;2
	cSend(47, 1578) ;3
	cSend(47, 2437) ;4
	;반복
	cSend(109, 1203) ;5
	cSend(31, 641) ;6
	cSend(47, 1578) ;7
	cSend(47, 2437) ;8
	;반복
	cSend(109, 1203) ;9
	cSend(31, 641) ;10
	cSend(47, 1578) ;11
	cSend(47, 2437) ;12
	;반복
	cSend(109, 1203) ;13
	cSend(31, 641) ;14
	cSend(47, 5125) ;15
	If BonusStage2Fail() Then
		Return
	EndIf
	;3구간 수집
	cSend(900, 200)
	For $iX = 1 To 20
		Send("{Up}")
		Sleep(500)
	Next
	If BonusStage2Fail() Then
		Return
	EndIf
	WriteInLogs("BonusStage2 Section 3 Complete")
	;4구간 동기화
	FindPixelUntilFound(250, 472, 100, 250, 0x0D2030)
	Sleep(200)
	;4구간 시작
	cSend(32, 1375) ;1
	cSend(641, 690) ;2
	cSend(41, 1375) ;3
	cSend(41, 1374) ;4
	cSend(641, 690) ;5
	cSend(41, 1373) ;6
	cSend(41, 2500) ;7
	cSend(31, 809) ;8
	cSend(41, 1375) ;9
	cSend(41, 1374) ;10
	cSend(641, 690) ;11
	cSend(41, 1373) ;12
	cSend(41, 1372) ;13
	cSend(641, 690) ;14
	cSend(41, 1371) ;15
	; 혹시 몰라 한 번 더 점프
	cSend(41) ;16
	;4구간 수집
	For $iX = 1 To 23
		Send("{Up}")
		Sleep(500)
	Next
	If BonusStage2Fail() Then
		Return
	EndIf
	WriteInLogs("BonusStage2 Section 4 Complete")
EndFunc   ;==>BonusStage2

Func BonusStage3($iCurrentSection = 0)
	Local $iTotalSections = 4

	If $iCurrentSection == 0 Then
		WriteInLogs("BonusStage3")
	ElseIf $iCurrentSection >= 2 * $iTotalSections Then
		Return
	EndIf

	Local $iSection = Mod($iCurrentSection, $iTotalSections)

	If $iSection == 0 Then
		If Not BonusStage3Section1() Then
			BonusStage3($iCurrentSection + $iTotalSections)
			Return
		EndIf
		$iCurrentSection += 1
		$iSection = 1
	EndIf
	If $iSection == 1 Then
		If Not BonusStage3Section2() Then
			BonusStage3($iCurrentSection + $iTotalSections)
			Return
		EndIf
		$iCurrentSection += 1
		$iSection = 2
	EndIf
	If $iSection == 2 Then
		If Not BonusStage3Section3() Then
			BonusStage3($iCurrentSection + $iTotalSections)
			Return
		EndIf
		$iCurrentSection += 1
		$iSection = 3
	EndIf
	If $iSection == 3 Then
		If Not BonusStage3Section4() Then
			BonusStage3($iCurrentSection + $iTotalSections)
			Return
		EndIf
	EndIf

EndFunc   ;==>BonusStage3

Func BonusStage3SB($iCurrentSection = 0)
	Local $iTotalSections = 4

	If $iCurrentSection == 0 Then
		WriteInLogs("BonusStage3SB")
	ElseIf $iCurrentSection >= 2 * $iTotalSections Then
		Return
	EndIf

	Local $iSection = Mod($iCurrentSection, $iTotalSections)

	If $iSection == 0 Then
		If Not BonusStage3Section1(True) Then
			BonusStage3SB($iCurrentSection + $iTotalSections)
			Return
		EndIf
		$iCurrentSection += 1
		$iSection = 1
	EndIf
	If $iSection == 1 Then
		If Not BonusStage3Section2(True) Then
			BonusStage3SB($iCurrentSection + $iTotalSections)
			Return
		EndIf
		$iCurrentSection += 1
		$iSection = 2
	EndIf
	If $iSection == 2 Then
		If Not BonusStage3Section3(True) Then
			BonusStage3SB($iCurrentSection + $iTotalSections)
			Return
		EndIf
		$iCurrentSection += 1
		$iSection = 3
	EndIf
	If $iSection == 3 Then
		If Not BonusStage3Section4(True) Then
			BonusStage3SB($iCurrentSection + $iTotalSections)
			Return
		EndIf
	EndIf

EndFunc   ;==>BonusStage3SB

; #FUNCTION# ====================================================================================================================
; 설명 ..........: 구간을 시작하기 전에 화면과 박자를 맞춘다. 지금은 4구간에서만 쓴다.
;                  각 구간은 화면을 보지 않고 미리 짜 둔 점프 순서를 그대로 재생하기 때문에,
;                  시작 지점을 못 잡으면 그 뒤는 전부 어긋난다.
;
;                  원래는 FindPixelUntilFound() 가 시간 안에 못 찾아도 그 사실을 확인하지 않고
;                  그대로 점프를 시작했다. 그래서 15초를 기다린 뒤 20초 넘게 허공에 점프를 하고 나서야
;                  실패를 알아차렸다. 이제는 못 찾으면 바로 실패로 보고 재시도로 넘긴다.
;
;                  1~3구간은 원래대로(못 찾아도 그대로 진행) 두고 4구간에만 적용해서,
;                  이 방식이 실제로 도움이 되는지 먼저 확인한다.
;
;                  박자를 맞추는 데 걸린 시간도 기록에 남긴다. 몇백 ms 면 제대로 잡은 것이고,
;                  15000 에 가까우면 거의 놓칠 뻔한 것이라 구간이 실패했을 때 원인을 가리는 데 쓴다.
; 매개변수 ......: $iX1, $iY1, $iX2, $iY2 - 동기화 지점을 찾을 범위
;                  $iSection     - 구간 번호 (기록에 남길 용도)
;                  $bSpiritBoost - 영혼 부스트 여부
; 반환값 ........: 박자를 맞췄으면 True, 못 맞췄으면 False
; ===============================================================================================================================
Func BonusStage3Sync($iX1, $iY1, $iX2, $iY2, $iSection, $bSpiritBoost)
	Local $hTimer = TimerInit()
	Local $vFound = FindPixelUntilFound($iX1, $iY1, $iX2, $iY2, 0xFFFFFF)
	Local $iElapsed = Round(TimerDiff($hTimer))

	If IsArray($vFound) Then
		WriteInLogs(GetBS3LogText($bSpiritBoost) & " Section " & $iSection & " Sync " & $iElapsed & "ms")
		Return True
	EndIf

	WriteInLogs(GetBS3LogText($bSpiritBoost) & " Section " & $iSection & " Sync Failed")
	; 이미 실패 화면이 떠 있으면 여기서 재시도 버튼을 눌러 둔다
	BonusStage3Fail($bSpiritBoost)
	Return False
EndFunc   ;==>BonusStage3Sync

Func BonusStage3Section1($bSpiritBoost = False)
	; 1구간 동기화
	FindPixelUntilFound(520, 200, 580, 250, 0xFFFFFF)
	Sleep(360)
	;1구간 시작
	cSend(140, 530) ;1
	cSend(70, 640) ;2
	cSend(80, 740) ;3
	cSend(150, 765) ;4
	cSend(65, 625) ;5
	cSend(65, 500) ; 6

	FindPixelUntilFound(540, 335, 555, 360, 0xFFFFFF, 700)
	cSend(150, 750) ;7
	cSend(200, 200) ;8

	FindPixelUntilFound(390, 230, 410, 250, 0xFFFFFF, 3500)
	cSend(130, 545) ;9
	cSend(70, 620) ;10
	cSend(80, 400) ;11
	FindPixelUntilFound(500, 200, 515, 250, 0xFFFFFF, 1500)

	cSend(150, 755) ;12
	cSend(65, 625) ;13
	cSend(65, 500) ;14

	FindPixelUntilFound(540, 335, 555, 360, 0xFFFFFF, 700)
	cSend(150, 740) ;15
	cSend(200, 1490) ;16

	cSend(110, 580) ;17
	cSend(65, 640) ;18
	cSend(80, 740) ;19
	cSend(150, 765) ;20

	cSend(130, 560) ;21
	cSend(70, 650) ;22

	Sleep(800)

	If CollectLootBS3($bSpiritBoost, 21) == False Then Return False
	WriteInLogs(GetBS3LogText($bSpiritBoost) & " Section 1 Complete")

	Return True
EndFunc   ;==>BonusStage3Section1

Func BonusStage3Section2($bSpiritBoost = False)
	; 2구간 동기화
	FindPixelUntilFound(306, 200, 309, 275, 0xFFFFFF)
	; 2구간 시작

	For $iX = 1 To 2
		cSend(80, 440) ;1
		cSend(95, 660) ;2
		cSend(105, 500) ;3

		FindPixelUntilFound(475, 445, 482, 475, 0xFFFFFF, 1000)

		cSend(79, 601) ;4
		cSend(63, 980) ;5
		cSend(82, 440) ;6
		cSend(95, 660) ;7

		cSend(48, 750) ;8
		FindPixelUntilFound(515, 265, 522, 285, 0xFFFFFF, 1200)

		cSend(63, 500) ;9
		BonusStage3WallJump(1) ; 10
		Sleep(80)
		BonusStage3WallJump(1) ; 11
		Sleep(300)
		BonusStage3WallJump(4) ; 12

		FindPixelUntilFound(306, 200, 309, 275, 0xFFFFFF, 1000)

	Next

	cSend(80, 440)
	cSend(95, 660)

	If CollectLootBS3($bSpiritBoost) == False Then Return False
	WriteInLogs(GetBS3LogText($bSpiritBoost) & " Section 2 Complete")
	Return True
EndFunc   ;==>BonusStage3Section2

Func BonusStage3Section3($bSpiritBoost = False)
	Local $bUpperWay = False
	;3구간 동기화
	FindPixelUntilFound(280, 385, 330, 435, 0xFFFFFF)
	Sleep(600)

	For $iX = 1 To 2
		If $bUpperWay Then
			BonusStage3WallJump()
			$bUpperWay = False
		Else
			cSend(120, 100) ;1

			FindPixelUntilFound(205, 395, 215, 410, 0xFFFFFF, 780)

			cSend(95, 225) ;2
			BonusStage3WallJump() ;3
		EndIf

		Sleep(2000) ;4

		cSend(300, 500) ;5
		BonusStage3WallJump() ;6
		FindPixelUntilFound(205, 395, 215, 410, 0xFFFFFF, 900)

		If $iX < 3 Then
			cSend(95, 250) ;7
			BonusStage3WallJump(1, 715) ;8
			BonusStage3WallJump(6) ;9

			Local $bFound = FindPixelUntilFound(300, 415, 330, 435, 0xFFFFFF, $bSpiritBoost ? 1000 : 2500)
			If $bFound == False Then
				$bUpperWay = True
			Else
				Sleep(2500)
			EndIf

			Sleep(150)
		EndIf
	Next

	If CollectLootBS3($bSpiritBoost) == False Then Return False
	WriteInLogs(GetBS3LogText($bSpiritBoost) & " Section 3 Complete")
	Return True
EndFunc   ;==>BonusStage3Section3

Func BonusStage3WallJump($iCount = 5, $iSleep = 50)
	For $iX = 1 To $iCount
		cSend(30, $iSleep) ;2
	Next
EndFunc   ;==>BonusStage3WallJump

Func BonusStage3Section4($bSpiritBoost = False)
	;4구간 동기화
	If Not BonusStage3Sync(330, 170, 380, 195, 4, $bSpiritBoost) Then Return False
	;4구간 시작
	If Not $bSpiritBoost Then
		For $iX = 1 To 5
			cSend(300, 600) ;1

			cSend(300, 420) ;2

			cSend(35, 748) ;3
			cSend(35, 540) ;4
			cSend(35, 1160) ;5s
		Next
	Else
		For $iX = 1 To 14
			cSend(110, 1180) ;1
		Next

		cSend(300, 300)
	EndIf

	If CollectLootBS3($bSpiritBoost, 25, False) == False Then Return False
	WriteInLogs(GetBS3LogText($bSpiritBoost) & " Section 4 Complete")
	Return True
EndFunc   ;==>BonusStage3Section4

Func GetBS3LogText($bSpiritBoost)
	Return "BonusStage3" & ($bSpiritBoost ? "SB" : "")
EndFunc   ;==>GetBS3LogText

Func CollectLootBS3($bSpiritBoost, $iCount = 25, $bStopEarly = True)
	If BonusStage3Fail($bSpiritBoost) Then
		Return False
	EndIf
	;3구간 수집
	For $iX = 1 To $iCount
		; 다음 구간이 이미 시작됐으면 일찍 끝낸다
		If $bStopEarly = True And $iX > 8 Then
			$aPos = FindPixelUntilFound(1100, 240, 1100, 440, 0x8D87A2, 480)
			If IsArray($aPos) Then ExitLoop
		Else
			Sleep(500)
		EndIf

		cSend(0, 0)
	Next
	If BonusStage3Fail($bSpiritBoost) Then
		Return False
	EndIf

	Return True
EndFunc
