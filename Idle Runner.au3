#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\Icon.ico
#AutoIt3Wrapper_Outfile=Idle Runner_x64.exe
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Compile_Both=n
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_requestedExecutionLevel=None
#AutoIt3Wrapper_Res_Description=Idle Slayer 매크로 (한글판)
#AutoIt3Wrapper_Res_Fileversion=3.5.8.0
#AutoIt3Wrapper_Res_File_Add=Resources\Icon.jpg, RT_RCDATA, ICON,0
#AutoIt3Wrapper_Res_File_Add=Resources\CheckboxUnchecked.jpg, RT_RCDATA, UNCHECKED,0
#AutoIt3Wrapper_Res_File_Add=Resources\CheckboxChecked.jpg, RT_RCDATA, CHECKED,0
#AutoIt3Wrapper_Run_Stop_OnError=y
#AutoIt3Wrapper_Run_Au3Stripper=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#comments-start
 AutoIt 버전: 3.3.16.0
 원작자: Devil4ngle, Djahnz
 한글판: 화면 글자를 전부 한글 라벨로 바꾸고 아래 기능을 덧붙였다.
   - 미니언 자동 수집 켜기/끄기, 리더십 마스터가 없을 때 쓰는 개별 수집 방식
   - 승천 포인트가 0이라 승천에 실패했을 때 승천 화면을 다시 닫기
#comments-end
#include-once
#include "Libraries\ResourcesEx.au3"
#include "Libraries\GUI.au3"
#include "Libraries\BonusStage.au3"
#include "Libraries\BossFightVictor.au3"
#include "Libraries\BossFightKnight.au3"
#include "Libraries\Common.au3"
#include "Libraries\AscendingHeights.au3"
#include "Libraries\Chesthunt.au3"
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>
#include <GuiTab.au3>
#include <WinAPI.au3>
#include <WinAPISysWin.au3>
#include <EditConstants.au3>
#include <AutoItConstants.au3>
#include <Array.au3>

; ===============================================================================================================================
; 분노(Rage) 오인식 방지
;
; 분노를 쓸지 말지는 화면의 픽셀 색으로만 판단한다. 그런데 판정 조건이 너무 헐거웠다.
;   - 메가 호드   : (385, 280) 픽셀 한 점, 색 오차 허용 없음
;   - 소울 보너스 : (625,143)~(629,214) 좁은 세로줄
; 메인 반복문은 40ms 마다 이 색을 보는데, 보너스 스테이지가 끝나고 화면이 어두워졌다 밝아지는
; 것처럼 화면이 바뀌는 도중에는 그 자리의 색이 여러 단계를 거쳐 변한다. 그러다 우연히 딱 한 프레임만
; 판정 색과 같아지면, 메가 호드가 아닌데도 분노를 써 버린다.
;
; 진짜 메가 호드나 소울 보너스는 몇 초 동안 이어진다. 그래서 색을 처음 본 뒤 아래 시간 동안
; 끊기지 않고 계속 보일 때만 진짜로 인정한다. 중간에 한 번이라도 색이 사라지면 처음부터 다시 센다.
;
; 숫자를 키우면 더 확실해지지만 진짜 메가 호드에서 분노를 쓰는 시점도 그만큼 늦어진다.
; ===============================================================================================================================
Global Const $iRageConfirmDelay = 250 ; 밀리초

Global $iTimerMegaHordeSeen = 0 ; 메가 호드 색을 처음 본 시각 (0 = 안 보이는 중)
Global $iTimerSoulBonusSeen = 0 ; 소울 보너스 색을 처음 본 시각 (0 = 안 보이는 중)
Global $bSoulBonusRaging = False ; 소울 보너스 분노를 이미 시작했는지 (기록을 한 번만 남기기 위함)

setSetting()
_AuThread_Startup()
Main()

Func Main()
	; 단축키 등록
	HotKeySet("{Home}", "Pause")
	HotKeySet("+{Esc}", "IdleClose")
	HotKeySet("^+b", "AutoUpgrade")
	; 기록 저장 폴더 만들기
	DirCreate("IdleRunnerLogs")
	; 화면 만들기
	CreateGUI()
	LoadSettings()
	GUISetState(@SW_SHOW)
	; 창 아래 오른쪽 칸(통계 및 도움말)을 채우고, 왼쪽 실시간 로그 칸에 첫 줄을 남긴다
	RefreshLogInfo()
	AddLiveLog("Macro Started")
	; 전역 변수와 함수 상당수는 Libraries\GUI.au3 에 선언되어 있다
	_AuThread_StartThread("ShootAndBoost", @AutoItPID)
	SyncProcess()

	; 메인 반복문
	While 1
		Sleep(40)
		; 남은 시간 표시는 정지 중에도 갱신한다 (타이머가 정지와 무관하게 흐르기 때문)
		UpdateRemainingLabels()
		If $bTogglePause Then ContinueLoop

		If (1800000 < TimerDiff($iTimerFocusGame)) Then
			$iTimerFocusGame = TimerInit()
			WinActive("Idle Slayer")
			ControlFocus("Idle Slayer", "", "")
		EndIf

		; 은상자 줍기
		PixelSearch(650, 36, 650, 36, 0xCA9700)
		If Not @error Then
			WriteInLogs("Silver Box Collected")
			MouseClick("left", 644, 49, 1, 0)
		EndIf

		; 메가 호드에서 분노 쓰기
		; 색이 잠깐 스쳐 지나간 것인지 확인한 뒤에 쓴다 (파일 위쪽 설명 참고)
		PixelSearch(385, 280, 385, 280, 0x140C1C)
		Local $bMegaHordeColor = Not @error
		If ConfirmPixel($iTimerMegaHordeSeen, $bMegaHordeColor, "MegaHorde Rage Skipped - Screen Changed") Then
			SyncProcess(False)
			RageWhenHorde()
			SyncProcess(True)
		EndIf

		; 퀘스트 보상 받기
		PixelSearch(1130, 610, 1130, 610, 0xCBCB4C)
		If Not @error Then
			SyncProcess(False)
			ClaimQuests()
			SyncProcess(True)
		EndIf

		; 소울 보너스에서 분노 쓰기
		; 여기도 같은 방식으로 확인한다 (파일 위쪽 설명 참고)
		PixelSearch(625, 143, 629, 214, 0xA86D0A)
		Local $bSoulBonusColor = Not @error
		If ConfirmPixel($iTimerSoulBonusSeen, $bSoulBonusColor, "SoulBonus Rage Skipped - Screen Changed") Then
			; 소울 보너스가 이어지는 동안 계속 눌러서, 분노가 차는 즉시 쓰이게 한다. (원래 동작)
			; 다만 기록은 소울 보너스가 시작될 때 한 번만 남긴다.
			If Not $bSoulBonusRaging Then
				$bSoulBonusRaging = True
				WriteInLogs("SoulBonus Rage")
			EndIf
			ControlSend("Idle Slayer", "", "", "{r}")
		Else
			$bSoulBonusRaging = False
		EndIf

		; 미니언 수집 ([일반] 탭에서 끄면 이 부분은 아예 건너뛴다)
		If $bMinionState Then
			PixelSearch(99, 113, 99, 113, 0xFFFF7A)
			If Not @error Then
				SyncProcess(False)
				CollectMinion()
				SyncProcess(True)
			EndIf
		EndIf


		; 상자 사냥
		PixelSearch(187, 296, 187, 296, 0xFFBB31)
		If Not @error Then
			PixelSearch(187, 303, 187, 303, 0xF68F37)
			If Not @error Then
				SyncProcess(False)
				Chesthunt($bNoLockpickingState, $bPerfectChestHuntState, $bNoReinforcedCrystalSaverState)
				SyncProcess(True)
			EndIf

		EndIf

		If TimerDiff($iLastCheckTimeLoop) >= 5000 Then
			$iLastCheckTimeLoop = TimerInit()

			CloseAll()

			; 보너스 스테이지
			PixelSearch(660, 254, 660, 254, 0xFFE737)
			If Not @error Then
				PixelSearch(638, 236, 638, 236, 0xFFBB31)
				If Not @error Then
						SyncProcess(False)
						BonusStage($bSkipBonusStageState)
						SyncProcess(True)
				EndIf
			EndIf

			; 보스전
			PixelSearch(639, 224, 639, 224, 0xFF878A)
			If Not @error Then
				PixelSearch(634, 224, 634, 224, 0xF263BD)
				If Not @error Then
					PixelSearch(644, 224, 644, 224, 0xFFF38F)
					If Not @error Then
						SyncProcess(False)
						PixelSearch(30, 690, 30, 690, 0x0B0303)
						If Not @error Then
							BossFightKnight()
						Else
							BossFightVictor()
						EndIf
						SyncProcess(True)
					EndIf
				EndIf
			EndIf

			; 승천 고지 (Ascending Heights)
			PixelSearch(671, 213, 671, 213, 0xC2F4F9)
			If Not @error Then
				PixelSearch(640, 240, 634, 640, 0xFFCC66)
				If Not @error Then
					SyncProcess(False)
					AscendingHeights()
					SyncProcess(True)
				EndIf
			EndIf

			; 포탈 순환
			If $bCirclePortalsState Then
				CirclePortals()
			EndIf

			; 업그레이드 자동 구매
			If $bAutoBuyUpgradeState Then
				If (($iAutoBuyTempTimer * 60000) < TimerDiff($iTimerAutoBuy)) Then
					$iTimerAutoBuy = TimerInit()
					$iAutoBuyTempTimer = $iAutoBuyTimer
					WinActivate("Idle Slayer")
					If WinGetTitle("[ACTIVE]") == "Idle Slayer" Then
						SyncProcess(False)
						$iAutoBuyLoopAmount = 0
						AutoUpgrade()
						SyncProcess(True)
					EndIf
				EndIf
			EndIf

			; 자동 승천
			If $bAutoAscendState Then
				If (($iAutoAscendTimer * 60000) < TimerDiff($iTimerAutoAscend)) Then
					$iTimerAutoAscend = TimerInit()
					WinActivate("Idle Slayer")
					If WinGetTitle("[ACTIVE]") == "Idle Slayer" Then
						SyncProcess(False)
						AutoAscend()
						SyncProcess(True)
					EndIf
				EndIf
			EndIf
		EndIf
	WEnd
EndFunc   ;==>Main

; #FUNCTION# ====================================================================================================================
; 설명 ..........: 찾은 색이 화면 전환 중에 한순간만 스쳐 지나간 것인지 걸러 낸다.
;                  색을 처음 본 시각을 기억해 두고, 같은 색이 $iRageConfirmDelay 밀리초 동안
;                  끊기지 않고 계속 보일 때만 True 를 돌려준다.
;                  메인 반복문이 40ms 마다 돌기 때문에 그 사이 한 번이라도 색이 사라지면 처음부터 다시 센다.
;                  기다리는 동안 화면을 멈추지 않으므로 다른 감지(은상자, 퀘스트 등)는 그대로 돌아간다.
; 매개변수 ......: $iSeenTimer - 색을 처음 본 시각을 담아 두는 변수. 이 함수가 알아서 갱신한다.
;                  $bFound     - 이번 차례에 그 색을 찾았는지 여부
;                  $sSkipLog   - 인정되기 전에 색이 사라졌을 때 기록에 남길 문구. "" 이면 남기지 않는다.
; 반환값 ........: 충분히 오래 이어졌으면 True, 아니면 False
; ===============================================================================================================================
Func ConfirmPixel(ByRef $iSeenTimer, $bFound, $sSkipLog = "")
	If Not $bFound Then
		; 인정되기 전에 사라졌다면 화면이 바뀌는 도중에 한순간만 같은 색이었던 것이다
		If $iSeenTimer <> 0 And TimerDiff($iSeenTimer) < $iRageConfirmDelay And $sSkipLog <> "" Then
			WriteInLogs($sSkipLog)
		EndIf
		$iSeenTimer = 0
		Return False
	EndIf

	If $iSeenTimer = 0 Then $iSeenTimer = TimerInit()
	Return (TimerDiff($iSeenTimer) >= $iRageConfirmDelay)
EndFunc   ;==>ConfirmPixel

Func CloseAll()
	Sleep(2000)
	PixelSearch(680, 593, 680, 593, 0xAF0000)
	If Not @error Then
		MouseClick("left", 780, 600, 1, 0)
	EndIf
EndFunc   ;==>CloseAll

Func RageWhenHorde()
	Local $bSoulBonusActive = CheckForSoulBonus()
	If $bSoulBonusActive Then
		If $bCraftRagePillState Then
			BuyTempItem("0x871646")
		EndIf
		If $bCraftSoulBonusState Then
			BuyTempItem("0x7D55D8")
		EndIf
	EndIf
	If $bDisableRageState Then
		If $bSoulBonusActive Then
			Rage()
		EndIf
	Else
		Rage()
	EndIf

EndFunc   ;==>RageWhenHorde

Func Rage()
	WriteInLogs("MegaHorde Rage")
	If $bDimensionalState Then
		BuyTempItem("0xF37C55")
		$bDimensionalState = False
		If Not @Compiled Then
			GUICtrlSetImage($iCheckBoxbDimensionalState, 'Resources\CheckboxUnchecked.jpg')
		Else
			_Resource_SetToCtrlID($iCheckBoxbDimensionalState, 'UNCHECKED')
		EndIf
		SaveSettings()
	EndIf
	If $bBiDimensionalState Then
		BuyTempItem("0x526629")
		$bBiDimensionalState = False
		If Not @Compiled Then
			GUICtrlSetImage($iCheckBoxbBiDimensionalState, 'Resources\CheckboxUnchecked.jpg')
		Else
			_Resource_SetToCtrlID($iCheckBoxbBiDimensionalState, 'UNCHECKED')
		EndIf
		SaveSettings()
	EndIf
	ControlFocus("Idle Slayer", "", "")
	ControlSend("Idle Slayer", "", "", "{r}")
EndFunc   ;==>Rage

Func CheckForSoulBonus()
	PixelSearch(625, 143, 629, 214, 0xA86D0A)
	If Not @error Then
		WriteInLogs("MegaHorde Rage with SoulBonus")
		Return True
	EndIf
	Return False
EndFunc   ;==>CheckForSoulBonus

Func BuyTempItem($sHexColor)
	WriteInLogs("Trying to CraftingTemp Item")
	Local $aFoundPixel
	;메뉴 열기
	MouseClick("left", 160, 100, 1, 0)
	Sleep(150)
	;임시 아이템 탭
	MouseClick("left", 260, 690, 1, 0)
	Sleep(150)

	$aFoundPixel = PixelSearch(43, 330, 625, 630, $sHexColor)
	If Not @error Then
		MouseClick("left", $aFoundPixel[0], $aFoundPixel[1], 1, 0)
		Sleep(200)
		MouseClick("left", 420, 156, 1, 0)
		WriteInLogs("CraftingTemp Item Active")
	Else
		WriteInLogs("CraftingTemp Item Failed, not enough materials")
	EndIf
	; 닫기
	MouseClick("left", 440, 690, 1, 0)
	Sleep(100)
EndFunc   ;==>BuyTempItem

; #FUNCTION# ====================================================================================================================
; 설명 ..........: 자동 승천.
;                  승천 포인트가 0이면 승천 버튼이 나오지 않아 승천에 실패하는데, 원본은 이때 열어 둔
;                  승천 화면을 그대로 두고 끝나 버려서 이후 클릭이 전부 승천 화면에 막혔다.
;                  그래서 승천이 안 되는 경우에는 반드시 화면을 다시 닫도록 고쳤다.
; ===============================================================================================================================
Func AutoAscend()
	; 승천 화면이 이미 열려 있는 경우
	PixelSearch(260, 600, 260, 600, 0x58188D)
	If Not @error Then
		DoAscend()
		Return
	EndIf

	;승천 버튼 클릭
	MouseClick("left", 95, 90, 1, 0)
	Sleep(400)
	;승천 탭 클릭
	MouseClick("left", 93, 680, 1, 0)
	Sleep(400)

	PixelSearch(260, 480, 260, 480, 0x58188D)
	If Not @error Then
		DoAscend()
	Else
		; 승천 포인트가 0이라 승천할 수 없다 -> 방금 연 승천 화면을 닫는다
		WriteInLogs("Auto Ascend Skipped - No Ascension Points")
		CloseAscensionMenu()
	EndIf
EndFunc   ;==>AutoAscend

; 실제로 승천을 실행한다. 승천이 안 됐으면 화면을 닫고 끝낸다.
Func DoAscend()
	;승천 버튼
	MouseClick("left", 260, 600, 1, 0)
	Sleep(300)
	;확인 버튼
	MouseClick("left", 550, 580, 1, 0)
	Sleep(600)

	; 확인을 눌렀는데도 승천 버튼이 그대로 보이면 승천이 안 된 것이다
	PixelSearch(260, 480, 260, 600, 0x58188D)
	If Not @error Then
		WriteInLogs("Auto Ascend Failed - Closing Menu")
		CloseAscensionMenu()
		Return
	EndIf

	WriteInLogs("Auto Ascend Done")
	AutoUpgrade()
EndFunc   ;==>DoAscend

; 승천 화면을 닫는다.
; ESC 로 먼저 닫아 보고, 그래도 승천 버튼이 보이면 화면 아래쪽 나가기 버튼을 누른다.
; 이 함수는 "승천 화면이 열려 있는 것이 확실할 때"만 부른다. 그래야 ESC 가 엉뚱한 메뉴를 열지 않는다.
Func CloseAscensionMenu()
	ControlFocus("Idle Slayer", "", "")
	ControlSend("Idle Slayer", "", "", "{ESC}")
	Sleep(400)

	; 아직 승천 버튼(보라색)이 보이면 나가기 버튼으로 한 번 더 닫는다
	PixelSearch(260, 480, 260, 600, 0x58188D)
	If Not @error Then
		;나가기 버튼 (미니언 화면에서 쓰는 위치와 같다)
		MouseClick("left", 570, 694, 1, 0)
		Sleep(300)
		ControlSend("Idle Slayer", "", "", "{ESC}")
		Sleep(300)
	EndIf
	WriteInLogs("Ascension Menu Closed")
EndFunc   ;==>CloseAscensionMenu

; #FUNCTION# ====================================================================================================================
; 설명 ..........: 미니언 화면을 열고 보상을 받은 뒤 다시 임무에 보낸다.
;                  [일반] 탭의 "리더십 마스터 없음" 설정에 따라 두 가지 방식 중 하나를 쓴다.
; ===============================================================================================================================
Func CollectMinion()
	;승천 버튼 클릭
	MouseClick("left", 95, 90, 1, 0)
	Sleep(400)
	;승천 탭 클릭
	MouseClick("left", 93, 680, 1, 0)
	Sleep(200)
	;승천 트리 탭 클릭
	MouseClick("left", 193, 680, 1, 0)
	Sleep(200)
	MouseClick("left", 691, 680, 1, 0)
	Sleep(200)
	;미니언 탭 클릭
	MouseClick("left", 332, 680, 1, 0)
	Sleep(200)

	If $bNoLeadershipMasterState Then
		CollectMinionOneByOne()
	Else
		CollectMinionWithLeadership()
	EndIf

	;나가기 클릭
	MouseClick("left", 570, 694, 1, 0)
EndFunc   ;==>CollectMinion

; 승천 업그레이드 '리더십 마스터'가 있을 때: [모두 받기] / [모두 보내기] 버튼 한 번씩이면 끝난다.
Func CollectMinionWithLeadership()
	;일일 보너스가 있는지 확인
	PixelSearch(370, 410, 910, 470, 0x11AA23, 9)
	If Not @error Then
		;모두 받기
		MouseClick("left", 320, 280, 5, 0)
		Sleep(200)
		;모두 보내기
		MouseClick("left", 320, 280, 5, 0)
		Sleep(200)
		;일일 보너스 받기
		MouseClick("left", 320, 180, 5, 0)
		Sleep(200)
		WriteInLogs("Minions Collect with Daily Bonus")
	Else
		;모두 받기
		MouseClick("left", 318, 182, 5, 0)
		Sleep(200)
		;모두 보내기
		MouseClick("left", 318, 182, 5, 0)
		Sleep(200)
		WriteInLogs("Minions Collect")
	EndIf
EndFunc   ;==>CollectMinionWithLeadership

; #FUNCTION# ====================================================================================================================
; 설명 ..........: 승천 업그레이드 '리더십 마스터'가 없을 때 쓰는 방식.
;                  이 업그레이드가 없으면 [Claim All] / [Send All] 버튼이 없고, 미니언마다 버튼이 하나씩 있다.
;                  그래서 퀘스트 수령(ClaimQuests)과 같은 방식으로 버튼 색을 찾아 찾은 자리를 누른다.
;
;                  실제 게임 화면에서 확인한 버튼 색 (클라이언트 x=420 기준, 글자가 없는 열이다):
;                    0x11A622  Claim Reward     - 보상 수령 가능
;                    0x541787  Send on Mission  - 임무 보내기 대기
;                    0x975DCA  On a Mission     - 임무 수행 중. 찾지 않으므로 눌리지 않는다.
;                  버튼 범위는 x 416~612, 첫 행이 y 120, 행 간격 150 이다.
;
;                  포인트가 모자라도 [Send on Mission] 색은 그대로라, 눌러도 안 바뀌는 경우가 있다.
;                  그래서 한 번 처리한 버튼 아래에서부터 다시 찾도록 해 같은 자리를 다시 누르지 않는다.
; ===============================================================================================================================
Func CollectMinionOneByOne()
	Local $iClaimed = 0
	Local $iSent = 0

	; 받을 수 있는 보상을 위에서부터 전부 받는다
	$iClaimed = ClickMinionButtons(0x11A622, "Minion Reward Claimed")

	; 그 다음 대기 중인 미니언을 임무로 보낸다.
	; 보상을 받으면 그 자리가 [Send on Mission] 으로 바뀌므로 반드시 수령 뒤에 해야 한다.
	$iSent = ClickMinionButtons(0x541787, "Minion Sent On Mission")

	If $iClaimed > 0 Or $iSent > 0 Then
		WriteInLogs("Minions Collect")
	Else
		WriteInLogs("Minions Collect Nothing Found")
	EndIf
EndFunc   ;==>CollectMinionOneByOne

; #FUNCTION# ====================================================================================================================
; 설명 ..........: 미니언 목록에서 지정한 색의 버튼을 위에서부터 하나씩 눌러 준다.
;                  한 번 누른 버튼 아래에서부터 다시 찾기 때문에 같은 자리를 두 번 누르지 않는다.
;                  (포인트 부족으로 눌러도 안 바뀌는 버튼이 있어도 무한 반복에 빠지지 않는다)
; 매개변수 ......: $iColor   - 찾을 버튼 색
;                  $sLogText - 한 번 누를 때마다 기록에 남길 문구
; 반환값 ........: 누른 횟수
; ===============================================================================================================================
Func ClickMinionButtons($iColor, $sLogText)
	Local $aLocation
	Local $iCount = 0
	Local $iTop = 115

	While 1
		; 버튼 왼쪽 여백(글자가 없는 열)을 세로로 훑어 버튼 위쪽 모서리를 찾는다
		$aLocation = PixelSearch(420, $iTop, 420, 625, $iColor, 10)
		If @error Then ExitLoop

		; 찾은 자리 기준으로 버튼 한가운데를 누른다 (버튼 높이 약 122)
		MouseClick("left", $aLocation[0] + 90, $aLocation[1] + 60, 1, 0)
		Sleep(500)

		; 눌러서 실제로 바뀌었는지 확인한다. 포인트가 모자라면 색이 그대로 남는다.
		PixelSearch(420, $aLocation[1], 420, $aLocation[1], $iColor, 10)
		If @error Then
			WriteInLogs($sLogText)
			$iCount += 1
		EndIf

		; 처리 여부와 상관없이 다음 미니언부터 찾는다
		$iTop = $aLocation[1] + 130
	WEnd

	Return $iCount
EndFunc   ;==>ClickMinionButtons

Func CirclePortals()
	;포탈 버튼이 보이는지 확인
	Local $iPortalVisible = 0
	PixelSearch(1180, 166, 1180, 166, 0x830399)
	If @error Then
		$iPortalVisible += 1
	EndIf
	PixelSearch(1180, 166, 1180, 166, 0x290130)
	If @error Then
		$iPortalVisible += 1
	EndIf

	If $iPortalVisible == 2 Then
		Return
	EndIf

	;대기 시간이 끝났는지 확인
	PixelSearch(1154, 144, 1210, 155, 0xFFFFFF, 9)
	If @error Then
		SyncProcess(False)
		;포탈 버튼 클릭
		MouseClick("left", 1180, 150, 1, 0)
		Sleep(300)

		;목적지 고르기
		;스크롤바 맨 위
		MouseMove(867, 300, 0)
		Sleep(200)
		Do
			MouseWheel($MOUSE_WHEEL_UP, 20)
			;검색창 맨 위
			PixelSearch(875, 250, 875, 250, 0xD6D6D6)
		Until @error
		Sleep(400)

		Local $sColor = 0x00CBF8
		Switch $iCirclePortalsCount
			Case 1
				;언덕
				$sColor = 0x00CBF8
			Case 2
				;사막
				$sColor = 0xBD4348
			Case 3
				;정글
				$sColor = 0x009D93
			Case 4
				;얼어붙은 평원
				$sColor = 0x6FF5F8
			Case 5
				;펑키
				$sColor = 0xB362C7
			Case 6
				;현대 도시
				$sColor = 0x000173
			Case 7
				;공장
				$sColor = 0x00F8B5
			Case 8
				;계곡
				$sColor = 0xE198BF
			Case 9
				;성
				$sColor = 0x4F0085
		EndSwitch
		Local $aLocation
		While 1
			$aLocation = PixelSearch(470, 230, 470, 540, $sColor, 10)
			If @error Then
				;회색 스크롤바가 아직 있는지 확인
				PixelSearch(875, 536, 875, 536, 0xD6D6D6)
				If @error Then
					MouseClick("left", 600, 600, 1, 0)
					ExitLoop
				EndIf
				Sleep(100)
				;마우스를 스크롤바 위로 옮긴다
				MouseMove(867, 300, 0)
				MouseWheel($MOUSE_WHEEL_DOWN, 1)
			Else
				Sleep(300)
				MouseWheel($MOUSE_WHEEL_DOWN, 1)
				MouseWheel($MOUSE_WHEEL_DOWN, 1)
				;포탈 클릭
				MouseClick("left", $aLocation[0] + 300, $aLocation[1], 1, 0)
				ExitLoop
			EndIf
		WEnd

		$iCirclePortalsCount += 1
		If $iCirclePortalsCount > 9 Then
			$iCirclePortalsCount = 1
		EndIf
		SaveSettings()
		WriteInLogs("CirclePortals")
		Sleep(10000)
		SyncProcess(True)
	EndIf
EndFunc   ;==>CirclePortals

Func AutoUpgrade()
	WriteInLogs("AutoUpgrade Active")
	;상점 창이 열려 있으면 닫는다
	MouseClick("left", 1244, 712, 1, 0)
	Sleep(150)
	;상점 창 열기
	MouseClick("left", 1163, 655, 1, 0)
	Sleep(150)
	; 모서리 색으로 창이 열렸는지 확인
	PixelSearch(807, 140, 807, 155, 0xFFFFFF)
	If Not @error Then
		BuyUpgrade()
	EndIf
EndFunc   ;==>AutoUpgrade

Func BuyEquipment()
	;장비 탭 클릭
	MouseClick("left", 850, 690, 1, 0)
	Sleep(50)
	;최대 구매 클릭
	MouseClick("left", 1180, 636, 4, 0)
	;스크롤바가 있으면 마지막 항목부터, 없으면 첫 항목을 최대 구매한다
	PixelSearch(1257, 340, 1257, 340, 0x11AA23)
	If Not @error Then
		;검 구매
		MouseClick("left", 1200, 200, 5, 0)
	Else
		;스크롤바 맨 아래 클릭
		MouseClick("left", 1253, 592, 5, 0)
		Sleep(200)
	EndIf
	Local $aLocation
	While 1
		;초록색 구매 버튼이 남아 있는지 확인
		$aLocation = PixelSearch(1160, 590, 1160, 170, 0x11AA23, 10)
		If @error Then
			;마우스를 스크롤바 위로 옮긴다
			MouseMove(1260, 170, 0)
			MouseWheel($MOUSE_WHEEL_UP, 1)
			PixelSearch(1260, 168, 1260, 168, 0xD6D6D6)
			If @error Then
				ExitLoop
			EndIf
			Sleep(10)
		Else
			;장비 탭 클릭
			MouseClick("left", 850, 690, 1, 0)
			;초록색 구매 버튼 클릭
			MouseClick("left", $aLocation[0], $aLocation[1], 5, 0)
		EndIf
	WEnd
	BuyUpgrade()
EndFunc   ;==>BuyEquipment

Func BuyUpgrade()
	; 업그레이드 탭으로 가서 맨 위로 올린다
	MouseClick("left", 927, 683, 1, 0)
	Sleep(150)
	; 스크롤바 맨 위
	MouseMove(1254, 172, 0)
	Do
		MouseWheel($MOUSE_WHEEL_UP, 20)
		;검색창 맨 위
		PixelSearch(1254, 167, 1254, 167, 0xD6D6D6)
	Until @error
	Sleep(400)
	Local $bSomethingBought = False
	Local $iY = 170
	While 1
		; 다음 업그레이드가 랜덤 상자 자석이면 건너뛴다
		PixelSearch(882, $iY, 909, $iY + 72, 0xF4B41B)
		If Not @error Then
			$iY += 96
		EndIf
		; 다음 업그레이드가 랜덤 상자 자석이면 건너뛴다
		PixelSearch(882, $iY, 909, $iY + 72, 0xE478FF)
		If Not @error Then
			$iY += 96
		EndIf
		PixelSearch(1180, $iY + 10, 1180, $iY + 10, 0x11A622)
		If @error Then
			PixelSearch(1180, $iY + 10, 1180, $iY + 10, 0x0C7418)
			If @error Then
				ExitLoop
			EndIf
		EndIf
		$bSomethingBought = True
		; 초록색 구매 버튼 클릭
		MouseClick("left", 1180, $iY, 1, 0)
		Sleep(50)
	WEnd
	If $bSomethingBought And $iAutoBuyLoopAmount < 6 Then
		$iAutoBuyLoopAmount += 1
		BuyEquipment()
	Else
		MouseClick("left", 1222, 677, 1, 0)
	EndIf
EndFunc   ;==>BuyUpgrade

Func ClaimQuests()
	WriteInLogs("Claiming quest")
	;상점 창이 열려 있으면 닫는다
	MouseClick("left", 1244, 712, 1, 0)
	Sleep(150)
	;상점 창 열기
	MouseClick("left", 1163, 655, 1, 0)
	Sleep(150)
	;장비 탭 클릭
	MouseClick("left", 850, 690, 1, 0)
	;업그레이드 탭 클릭
	MouseClick("left", 927, 683, 1, 0)
	Sleep(150)
	;퀘스트 탭 클릭
	MouseClick("left", 1000, 690, 1, 0)
	Sleep(50)

	; 스크롤바 맨 위
	MouseMove(1254, 272, 0)
	Do
		MouseWheel($MOUSE_WHEEL_UP, 20)
		;검색창 맨 위
		Sleep(20)
		PixelSearch(1254, 267, 1254, 267, 0xD6D6D6)
	Until @error
	Sleep(600)

	While 1
		;초록색 보상 버튼이 남아 있는지 확인
		$aLocation = PixelSearch(1160, 270, 1160, 590, 0x11A622, 10)
		If @error Then
			;마우스를 스크롤바 위로 옮긴다
			MouseMove(1267, 270, 0)
			MouseWheel($MOUSE_WHEEL_DOWN, 1)
			;회색 스크롤바가 아직 있는지 확인
			PixelSearch(1267, 658, 1267, 658, 0xA0A0A0)
			If @error Then
				ExitLoop
			EndIf
			PixelSearch(1267, 655, 1267, 655, 0xFFFFFF)
			If Not @error Then
				ExitLoop
			EndIf
			Sleep(100)
		Else
			;초록색 보상 버튼 클릭
			WriteInLogs("Quest Claimed")
			MouseClick("left", $aLocation[0], $aLocation[1], 1, 0)
		EndIf
	WEnd

	;상점 닫기
	MouseClick("left", 1244, 712, 1, 0)

EndFunc   ;==>ClaimQuests



Func ShootAndBoost()
	Local $bJumpState = True
	Local $iJumpSliderValue = 0
	Local $iReadMsg = 0

	While True

		If TimerDiff($iReadMsg) > 700 Then
			; 메시지 읽기
			$sPendingMsg = _AuThread_ReadNewMsg()
			; 메시지가 비어 있지 않은지 확인
			If UBound($sPendingMsg) > 0 Then
				; 메시지 해석
				For $i = 0 To UBound($sPendingMsg) - 1
					$msg = $sPendingMsg[$i]
					$msgArray = StringSplit($msg, ";")
					For $j = 1 To $msgArray[0]
						$msgItem = StringSplit($msgArray[$j], ":")
						If $msgItem[1] = "JumpSliderValue" Then
							$iJumpSliderValue = Int($msgItem[2])
						ElseIf $msgItem[1] = "JumpState" Then
							$bJumpState = ($msgItem[2] = "True")
						EndIf
					Next
				Next
			EndIf
			$iReadMsg = TimerInit()
		EndIf

		While $bJumpState == False
			Sleep(700)
			If WinGetState("Idle Runner") == 0 Then
				Exit
			EndIf
			$sPendingMsg = _AuThread_ReadNewMsg()
			; 메시지가 비어 있지 않은지 확인
			If UBound($sPendingMsg) > 0 Then
				; 메시지 해석
				For $i = 0 To UBound($sPendingMsg) - 1
					$msg = $sPendingMsg[$i]
					$msgArray = StringSplit($msg, ";")
					For $j = 1 To $msgArray[0]
						$msgItem = StringSplit($msgArray[$j], ":")
						If $msgItem[1] = "JumpSliderValue" Then
							$iJumpSliderValue = Int($msgItem[2])
						ElseIf $msgItem[1] = "JumpState" Then
							$bJumpState = ($msgItem[2] = "True")
						EndIf
					Next
				Next
			EndIf
		WEnd

		If WinGetState("Idle Runner") == 0 Then
			Exit
		EndIf

		Sleep($iJumpSliderValue)
		If WinGetTitle("[ACTIVE]") <> "Idle Runner" Then
			ControlFocus("Idle Slayer", "", "")
		EndIf
		ControlFocus("Idle Slayer", "", "")
		ControlSend("Idle Slayer", "", "", "{Up}{Right}")
	WEnd
EndFunc   ;==>ShootAndBoost
