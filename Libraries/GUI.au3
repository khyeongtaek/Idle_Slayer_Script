#include-once
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <TabConstants.au3>
#include <StaticConstants.au3>
#include <GuiTab.au3>
#include <EditConstants.au3>
#include <AutoItConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include <WinAPISysWin.au3>
#include "ResourcesEx.au3"
#include "Log.au3"
#include "AutoThreadV3.au3"
#include <Inet.au3>

; ===============================================================================================================================
; 화면 테마 상수
; 원본은 글자 하나하나가 전부 jpg 이미지였기 때문에 한글을 넣을 수 없었다.
; 그래서 글자 이미지를 전부 라벨(텍스트)로 바꾸고, 색만 원본과 같게 맞췄다.
; ===============================================================================================================================
Global Const $COLOR_WINDOW_BG = 0x202225 ; 창 바깥 배경
Global Const $COLOR_PANEL_BG = 0x36393F ; 탭 내용 배경
Global Const $COLOR_BUTTON_BG = 0x2F3136 ; 버튼 배경
Global Const $COLOR_TEXT = 0xFFFFFF ; 기본 글자색
Global Const $COLOR_RUNNING = 0x4CFF00 ; 실행 중 표시색 (초록)
Global Const $COLOR_PAUSED = 0xFFBB00 ; 일시정지 표시색 (주황)
Global Const $FONT_NAME = "Malgun Gothic" ; 맑은 고딕 - 윈도우 기본 한글 폰트

Global $bAutoBuyUpgradeState = False, _
		$bCraftSoulBonusState = False, _
		$bSkipBonusStageState = False, _
		$bCraftRagePillState = False, _
		$bCirclePortalsState = False, _
		$bNoLockpickingState = True, _
		$bNoReinforcedCrystalSaverState = False, _
		$bBiDimensionalState = False, _
		$bDimensionalState = False, _
		$bDisableRageState = False, _
		$bAutoAscendState = False, _
		$bPerfectChestHuntState = False, _
		$bMinionState = True, _
		$bNoLeadershipMasterState = False, _
		$bTogglePause = False

Global $sVersion = "3.5.8"
Global $iJumpSliderValue = 150, _
		$iCirclePortalsCount = 7, _
		$iAutoAscendTimer = 10, _
		$iAutoBuyTimer = 10, _
		$iAutoBuyTempTimer = 10, _
		$iAutoBuyLoopAmount = 0, _
		$iTimerAutoBuy = TimerInit(), _
		$iTimerAutoAscend = TimerInit(), _
		$iTimerFocusGame = TimerInit(), _
		$iTimerRemainRefresh = TimerInit(), _
		$iLastCheckTimeLoop = TimerInit()

; 설정 파일(IdleRunnerLogs\Settings.txt)에 저장되는 값 목록
Global $aSettingGlobalVariables[18] = ["iAutoBuyTimer", "iAutoAscendTimer", "bAutoAscendState", "bAutoBuyUpgradeState", "bCraftSoulBonusState", "bSkipBonusStageState", "bCraftRagePillState", "bCirclePortalsState", "iJumpSliderValue", "bNoLockpickingState", "iCirclePortalsCount", "bDimensionalState", "bBiDimensionalState", "bDisableRageState", "bNoReinforcedCrystalSaverState", "bPerfectChestHuntState", "bMinionState", "bNoLeadershipMasterState"]
; 체크박스로 조작하는 값 목록 (변수명 앞에 iCheckBox 를 붙인 컨트롤과 짝을 이룬다)
Global $aSettingCheckBoxes[14] = ["bAutoAscendState", "bAutoBuyUpgradeState", "bCraftSoulBonusState", "bSkipBonusStageState", "bCraftRagePillState", "bCirclePortalsState", "bNoLockpickingState", "bBiDimensionalState", "bDimensionalState", "bDisableRageState", "bNoReinforcedCrystalSaverState", "bPerfectChestHuntState", "bMinionState", "bNoLeadershipMasterState"]

; 설명 라벨을 눌렀을 때 어느 체크박스를 토글할지 기억해 두는 표 [라벨 ID][체크박스 ID]
Global $aLabelToCheckBox[0][2]

; #FUNCTION# ====================================================================================================================
; 반환값 ........: 성공 - 창 핸들
;                  실패 - 창을 만들지 못하면 0 을 반환하고 @error 를 1 로 설정한다.
; ===============================================================================================================================
Func CreateGUI()
	; 창 만들기
	Global $hGUIForm = GUICreate("Idle Runner", 898, 200, @DesktopWidth / 2 - 500, @DesktopHeight - 290, $WS_BORDER + $WS_POPUP)
	GUISetBkColor($COLOR_WINDOW_BG)
	; 이후 만들어지는 모든 컨트롤의 기본 폰트를 한글 폰트로 지정한다
	GUISetFont(9, 400, 0, $FONT_NAME)

	; 제목 표시줄 (드래그해서 창을 옮길 수 있는 영역)
	GUICtrlCreateLabel("", -1, -1, 898, 22, -1, $GUI_WS_EX_PARENTDRAG)
	GUICtrlSetBkColor(-1, $COLOR_WINDOW_BG)
	GUICtrlCreateLabel("        Idle Runner v" & $sVersion & " 한글판", -1, -1, 900, 22, $SS_CENTERIMAGE, $GUI_WS_EX_PARENTDRAG)
	GUICtrlSetColor(-1, $COLOR_TEXT)
	GUICtrlSetBkColor(-1, $COLOR_WINDOW_BG)
	Local $iIcon = GUICtrlCreatePicCustom('Resources\Icon.jpg', 2, 2, 16, 16, $SS_BITMAP + $SS_NOTIFY)
	_Resource_SetToCtrlID($iIcon, 'ICON')

	; 탭 컨트롤 만들기
	Global $iTabControl = GUICtrlCreateTab(159, -4, 745, 209, BitOR($TCS_FORCELABELLEFT, $TCS_FIXEDWIDTH, $TCS_BUTTONS))
	GUICtrlSetBkColor(-1, $COLOR_BUTTON_BG)
	GUISetOnEvent(-1, "EventTabFocus")
	Global $hTabHandle = GUICtrlGetHandle($iTabControl)

	; 탭 만들기
	Global $iTabHome = CreateWelcomeSheet($hGUIForm, $iTabControl)
	Global $iTabGeneral = CreateGeneralSheet($hGUIForm, $iTabControl)
	Global $iTabMinigames = CreateMinigamesSheet($hGUIForm, $iTabControl)
	Global $iTabCrafting = CreateCraftingSheet($hGUIForm, $iTabControl)
	Global $iTabLog = CreateLogSheet($hGUIForm, $iTabControl)

	; 처음에는 홈 탭을 보여준다
	GUICtrlSetState($iTabHome, $GUI_SHOW)
	GUICtrlCreateTabItem("")

	; 왼쪽 메뉴 버튼들
	CreateButtonLabel("홈", 1, 20, 160, 24, "EventButtonHomeClick")
	CreateButtonLabel("일반", 1, 44, 160, 24, "EventButtonGeneralClick")
	CreateButtonLabel("미니게임", 1, 68, 160, 24, "EventButtonMinigamesClick")
	CreateButtonLabel("제작", 1, 92, 160, 24, "EventButtonCraftingClick")
	Local $iButtonLog = CreateButtonLabel("로그", 1, 116, 160, 24, "EventButtonLogClick")

	; 로그 버튼 우클릭 메뉴
	Local $iLogContextMenu = GUICtrlCreateContextMenu($iButtonLog)
	GUICtrlCreateMenuItem("로그 지우기", $iLogContextMenu)
	GUICtrlSetOnEvent(-1, "EventMenuClearLogsClick")

	; 현재 동작 상태 표시
	Global $iLabelStatus = GUICtrlCreateLabel("● 실행 중", 1, 144, 160, 24, BitOR($SS_CENTER, $SS_CENTERIMAGE))
	GUICtrlSetBkColor(-1, $COLOR_WINDOW_BG)
	GUICtrlSetColor(-1, $COLOR_RUNNING)
	GUICtrlSetFont(-1, 9, 600, 0, $FONT_NAME)

	; 시작 / 정지 버튼 (처음에는 동작 중이므로 "정지" 로 표시)
	Global $iButtonStartStop = CreateButtonLabel("정지", 1, 172, 80, 24, "Pause")
	GUICtrlSetColor(-1, 0xFF7B7B)
	GUICtrlSetTip(-1, "매크로를 멈추거나 다시 시작합니다. 단축키: Home")

	; 종료 버튼
	CreateButtonLabel("종료", 81, 172, 80, 24, "IdleClose")
	GUICtrlSetTip(-1, "매크로를 종료합니다. 단축키: Shift + Esc")

	Return $hGUIForm
EndFunc   ;==>CreateGUI

; #FUNCTION# ====================================================================================================================
; 설명 ..........: 버튼처럼 보이는 라벨을 만든다.
;                  AutoIt 기본 버튼은 배경색을 지정할 수 없어서 어두운 테마와 맞지 않기 때문에 라벨로 대신한다.
; ===============================================================================================================================
Func CreateButtonLabel($sText, $iLeft, $iTop, $iWidth, $iHeight, $sOnEvent = "", $iFontSize = 9)
	Local $iCtrl = GUICtrlCreateLabel($sText, $iLeft, $iTop, $iWidth, $iHeight, BitOR($SS_CENTER, $SS_CENTERIMAGE, $SS_NOTIFY))
	GUICtrlSetBkColor(-1, $COLOR_BUTTON_BG)
	GUICtrlSetColor(-1, $COLOR_TEXT)
	GUICtrlSetFont(-1, $iFontSize, 600, 0, $FONT_NAME)
	If $sOnEvent <> "" Then GUICtrlSetOnEvent(-1, $sOnEvent)
	Return $iCtrl
EndFunc   ;==>CreateButtonLabel

; #FUNCTION# ====================================================================================================================
; 설명 ..........: 탭 안에 쓰는 일반 설명 라벨을 만든다.
; ===============================================================================================================================
Func CreateTextLabel($sText, $iLeft, $iTop, $iWidth, $iHeight, $sTip = "")
	Local $iCtrl = GUICtrlCreateLabel($sText, $iLeft, $iTop, $iWidth, $iHeight, $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, $COLOR_PANEL_BG)
	GUICtrlSetColor(-1, $COLOR_TEXT)
	GUICtrlSetFont(-1, 9, 400, 0, $FONT_NAME)
	If $sTip <> "" Then GUICtrlSetTip(-1, $sTip)
	Return $iCtrl
EndFunc   ;==>CreateTextLabel

; #FUNCTION# ====================================================================================================================
; 설명 ..........: 체크박스 + 설명 글자를 한 묶음으로 만든다. 글자를 눌러도 체크가 켜지고 꺼진다.
; 매개변수 ......: $iLeft, $iTop  - 체크박스 위치
;                  $sText         - 설명 글자
;                  $iLabelWidth   - 설명 글자 영역의 너비
;                  $sTip          - 마우스를 올렸을 때 나오는 설명
; 반환값 ........: 체크박스 컨트롤 ID
; ===============================================================================================================================
Func CreateOption($iLeft, $iTop, $sText, $iLabelWidth, $sTip)
	Local $iCheckBox = GUICtrlCreatePicCustom('Resources\CheckboxUnchecked.jpg', $iLeft, $iTop, 16, 16, $SS_BITMAP + $SS_NOTIFY)
	_Resource_SetToCtrlID($iCheckBox, 'UNCHECKED')
	GUICtrlSetOnEvent(-1, "EventGlobalCheckBox")
	GUICtrlSetTip(-1, $sTip)

	Local $iLabel = GUICtrlCreateLabel($sText, $iLeft + 23, $iTop - 2, $iLabelWidth, 20, BitOR($SS_CENTERIMAGE, $SS_NOTIFY))
	GUICtrlSetBkColor(-1, $COLOR_PANEL_BG)
	GUICtrlSetColor(-1, $COLOR_TEXT)
	GUICtrlSetFont(-1, 9, 400, 0, $FONT_NAME)
	GUICtrlSetTip(-1, $sTip)
	GUICtrlSetOnEvent(-1, "EventGlobalLabel")

	; 라벨 ID 와 체크박스 ID 를 짝지어 둔다
	Local $iIndex = UBound($aLabelToCheckBox)
	ReDim $aLabelToCheckBox[$iIndex + 1][2]
	$aLabelToCheckBox[$iIndex][0] = $iLabel
	$aLabelToCheckBox[$iIndex][1] = $iCheckBox

	Return $iCheckBox
EndFunc   ;==>CreateOption

Func CreateWelcomeSheet($hGUIForm, $iTabControl)
	Local $iTabHome = GUICtrlCreateTabItem("홈")
	EventTabSetBkColor($hGUIForm, $iTabControl, $COLOR_PANEL_BG)

	GUICtrlCreateLabel("Idle Runner 한글판에 오신 것을 환영합니다", 175, 42, 715, 28, BitOR($SS_CENTER, $SS_CENTERIMAGE))
	GUICtrlSetFont(-1, 14, 700, 0, $FONT_NAME)
	GUICtrlSetColor(-1, $COLOR_TEXT)
	GUICtrlSetBkColor(-1, $COLOR_PANEL_BG)

	CreateTextLabel("설정 방법은 [로그] 탭 오른쪽 칸에서 확인하세요. 각 옵션에 마우스를 올리면 설명이 나옵니다.", 175, 74, 715, 20)
	GUICtrlSetColor(-1, 0xB9BBBE)

	CreateButtonLabel("GitHub 원본", 190, 112, 160, 44, "EventButtonGithubClick", 10)
	GUICtrlSetTip(-1, "원본 스크립트의 GitHub 배포 페이지를 엽니다")

	CreateButtonLabel("디스코드 (사용법)", 370, 112, 214, 44, "EventButtonInstructionsClick", 10)
	GUICtrlSetTip(-1, "Idle Slayer 스크립트 디스코드 커뮤니티를 엽니다")

	CreateButtonLabel("업데이트 확인", 604, 112, 160, 44, "EventButtonUpdateClick", 10)
	GUICtrlSetTip(-1, "원본 저장소에 새 버전이 있는지 확인합니다")

	Return $iTabHome
EndFunc   ;==>CreateWelcomeSheet

Func CreateGeneralSheet($hGUIForm, $iTabControl)
	Local $iTabGeneral = GUICtrlCreateTabItem("일반")
	EventTabSetBkColor($hGUIForm, $iTabControl, $COLOR_PANEL_BG)

	; --- 1행 왼쪽 : 점프 간격 조절 ---
	CreateTextLabel("점프 간격(ms)", 181, 43, 90, 20, "점프 신호를 보내는 간격입니다. 숫자가 작을수록 자주 점프합니다. (0 ~ 300)")
	Global $iJumpNumber = GUICtrlCreateLabel($iJumpSliderValue, 277, 43, 44, 20, BitOR($SS_CENTER, $SS_CENTERIMAGE))
	GUICtrlSetBkColor(-1, $COLOR_BUTTON_BG)
	GUICtrlSetColor(-1, $COLOR_TEXT)
	GUICtrlSetFont(-1, 9, 600, 0, $FONT_NAME)
	GUICtrlSetTip(-1, "현재 점프 간격 (밀리초)")

	CreateButtonLabel("▲", 325, 43, 22, 10, "EventUpArrow", 6)
	GUICtrlSetTip(-1, "점프 간격 10 늘리기")
	CreateButtonLabel("▼", 325, 53, 22, 10, "EventDownArrow", 6)
	GUICtrlSetTip(-1, "점프 간격 10 줄이기")

	; --- 1행 오른쪽 : 자동 업그레이드 구매 ---
	Global $iCheckBoxbAutoBuyUpgradeState = CreateOption(520, 44, "자동 업그레이드 구매", 135, _
			"수직 자석과 전기 지렁이를 뺀 나머지 업그레이드를 자동으로 삽니다. 켜고 10초 뒤에 처음 실행되고, 그 뒤로는 오른쪽에 적은 분마다 실행됩니다.")
	Global $iAutoBuyNumber = GUICtrlCreateInput($iAutoBuyTimer, 683, 44, 45, 20, $ES_NUMBER)
	GUICtrlSetOnEvent(-1, "EventAutoBuyTimer")
	GUICtrlSetTip(-1, "업그레이드를 사는 주기 (분)")
	CreateTextLabel("분마다", 733, 44, 42, 20)
	Global $iLabelAutoBuyRemain = CreateTextLabel("", 779, 44, 113, 20, _
			"다음 자동 구매까지 남은 시간입니다. 정지 중에도 시간은 계속 흐릅니다.")
	GUICtrlSetFont(-1, 8, 400, 0, $FONT_NAME)
	GUICtrlSetColor(-1, 0xB9BBBE)

	; --- 2행 왼쪽 : 포탈 순환 ---
	Global $iCheckBoxbCirclePortalsState = CreateOption(181, 83, "포탈 순환", 200, _
			"포탈이 준비되는 대로 다음 지역으로 순서대로 이동합니다.")

	; --- 2행 오른쪽 : 자동 승천 (1행과 같은 열에 맞춘다) ---
	Global $iCheckBoxbAutoAscendState = CreateOption(520, 83, "자동 승천", 135, _
			"정해진 시간마다 자동으로 승천합니다. 승천 포인트가 0이면 승천하지 않고 승천 화면을 다시 닫습니다.")
	Global $iAutoAscendNumber = GUICtrlCreateInput($iAutoAscendTimer, 683, 83, 45, 20, $ES_NUMBER)
	GUICtrlSetOnEvent(-1, "EventAutoAscendTimer")
	GUICtrlSetTip(-1, "승천하는 주기 (분)")
	CreateTextLabel("분마다", 733, 83, 42, 20)
	Global $iLabelAutoAscendRemain = CreateTextLabel("", 779, 83, 113, 20, _
			"다음 자동 승천까지 남은 시간입니다. 정지 중에도 시간은 계속 흐릅니다.")
	GUICtrlSetFont(-1, 8, 400, 0, $FONT_NAME)
	GUICtrlSetColor(-1, 0xB9BBBE)

	; --- 3행 왼쪽 : 분노 제한 ---
	Global $iCheckBoxbDisableRageState = CreateOption(181, 122, "소울 보너스 없으면 분노 안 씀", 220, _
			"켜면 소울 보너스가 없는 메가 호드에서는 분노를 쓰지 않습니다.")

	; --- 3행 오른쪽 : 미니언 자동 수집 ---
	Global $iCheckBoxbMinionState = CreateOption(520, 122, "미니언 자동 수집", 200, _
			"미니언 보상을 자동으로 받고 다시 임무에 보냅니다. 끄면 미니언 관련 동작을 전부 건너뜁니다.")

	; --- 4행 오른쪽 : 리더십 마스터 없음 (위 항목과 짝이라 같은 열에 둔다) ---
	Global $iCheckBoxbNoLeadershipMasterState = CreateOption(520, 160, "리더십 마스터 없음 (개별 수집)", 250, _
			"승천 업그레이드 '리더십 마스터'가 없어서 [모두 보내기] 버튼이 안 보일 때 켜세요. 미니언을 한 마리씩 받고 다시 보냅니다. (실험적 기능)")

	Return $iTabGeneral
EndFunc   ;==>CreateGeneralSheet

Func CreateMinigamesSheet($hGUIForm, $iTabControl)
	Local $iTabMinigames = GUICtrlCreateTabItem("미니게임")
	EventTabSetBkColor($hGUIForm, $iTabControl, $COLOR_PANEL_BG)

	Global $iCheckBoxbSkipBonusStageState = CreateOption(181, 44, "보너스 스테이지 건너뛰기", 250, _
			"아무것도 하지 않고 시간을 흘려보내서 보너스 스테이지를 넘깁니다.")

	Global $iCheckBoxbNoLockpickingState = CreateOption(181, 83, "자물쇠 따기 100 없음", 250, _
			"신성 능력 '자물쇠 따기 100'을 아직 못 찍었으면 켜 두세요.")

	Global $iCheckBoxbNoReinforcedCrystalSaverState = CreateOption(181, 122, "강화 크리스탈 세이버 없음", 250, _
			"영구 아이템 '강화 크리스탈 세이버'를 아직 못 얻었으면 켜 두세요.")

	Global $iCheckBoxbPerfectChestHuntState = CreateOption(520, 44, "퍼펙트 상자 사냥 우선", 250, _
			"자원보다 퍼펙트 상자 사냥을 우선하는, 조금 더 위험한 방식을 씁니다. 2배를 찾을 때까지 라이프 세이버를 무시하므로 '2x2x 다크 디비니티'는 꺼 두어야 합니다.")

	Return $iTabMinigames
EndFunc   ;==>CreateMinigamesSheet

Func CreateCraftingSheet($hGUIForm, $iTabControl)
	Local $iTabCrafting = GUICtrlCreateTabItem("제작")
	EventTabSetBkColor($hGUIForm, $iTabControl, $COLOR_PANEL_BG)

	Global $iCheckBoxbCraftSoulBonusState = CreateOption(181, 44, "소울 나침반 제작", 250, _
			"호드 또는 메가 호드 + 소울 보너스가 겹칠 때 소울 나침반을 만듭니다.")

	Global $iCheckBoxbBiDimensionalState = CreateOption(181, 83, "이차원 지팡이 제작", 250, _
			"메가 호드에서 이차원 지팡이를 만듭니다. 한 번 쓰면 이 옵션은 자동으로 꺼집니다.")

	Global $iCheckBoxbDimensionalState = CreateOption(181, 122, "차원 지팡이 제작", 250, _
			"메가 호드에서 차원 지팡이를 만듭니다. 한 번 쓰면 이 옵션은 자동으로 꺼집니다.")

	Global $iCheckBoxbCraftRagePillState = CreateOption(520, 44, "분노 알약 제작", 250, _
			"호드 또는 메가 호드 + 소울 보너스가 겹칠 때 분노 알약을 만듭니다.")

	Return $iTabCrafting
EndFunc   ;==>CreateCraftingSheet

Func CreateLogSheet($hGUIForm, $iTabControl)
	Local $iTabLog = GUICtrlCreateTabItem("로그")
	EventTabSetBkColor($hGUIForm, $iTabControl, $COLOR_PANEL_BG)

	; 왼쪽 : 누적 기록 통계
	Global $iLog = GUICtrlCreateEdit("", 172, 34, 350, 158, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_WANTRETURN, $WS_VSCROLL, $ES_READONLY))
	GUICtrlSetBkColor($iLog, 0x000000)
	GUICtrlSetColor($iLog, $COLOR_RUNNING)
	GUICtrlSetFont($iLog, 9, 400, 0, $FONT_NAME)

	; 오른쪽 : 현재 상태와 설정 안내
	Global $iLogData = GUICtrlCreateEdit("", 532, 34, 356, 158, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_WANTRETURN, $WS_VSCROLL, $ES_READONLY))
	GUICtrlSetBkColor($iLogData, 0x000000)
	GUICtrlSetColor($iLogData, 0xFFBB00)
	GUICtrlSetFont($iLogData, 9, 400, 0, $FONT_NAME)

	Return $iTabLog
EndFunc   ;==>CreateLogSheet

#Region GUI.au3 - #EVENTS#
Func EventButtonHomeClick()
	GUICtrlSetState($iTabHome, $GUI_SHOW)
EndFunc   ;==>EventButtonHomeClick

Func EventButtonGeneralClick()
	GUICtrlSetState($iTabGeneral, $GUI_SHOW)
EndFunc   ;==>EventButtonGeneralClick

Func EventButtonMinigamesClick()
	GUICtrlSetState($iTabMinigames, $GUI_SHOW)
EndFunc   ;==>EventButtonMinigamesClick

Func EventButtonCraftingClick()
	GUICtrlSetState($iTabCrafting, $GUI_SHOW)
EndFunc   ;==>EventButtonCraftingClick

Func EventButtonLogClick()
	GUICtrlSetState($iTabLog, $GUI_SHOW)
	LoadLog($iLog)
	LoadDataLog($iLogData)
EndFunc   ;==>EventButtonLogClick

Func EventMenuClearLogsClick()
	If FileExists("IdleRunnerLogs\Logs.txt") Then FileDelete("IdleRunnerLogs\Logs.txt")
	LoadLog($iLog)
EndFunc   ;==>EventMenuClearLogsClick

Func EventTabFocus()
	Local $iTabIndex = GUICtrlRead($iTabControl)
	_GUICtrlTab_SetCurFocus($hTabHandle, $iTabIndex)
EndFunc   ;==>EventTabFocus

Func EventButtonGithubClick()
	ShellExecute("https://github.com/Devil4ngle/Idle_Slayer_Script/releases")
EndFunc   ;==>EventButtonGithubClick

Func EventButtonInstructionsClick()
	ShellExecute("https://discord.gg/aEaBr77UDn")
EndFunc   ;==>EventButtonInstructionsClick

Func EventTabSetBkColor($hWnd, $hSysTab32, $sBkColor)
	; 탭 위치를 가져온다
	Local $aTabPos = ControlGetPos($hWnd, "", $hSysTab32)
	; 탭 안쪽 영역 크기를 가져온다
	Local $aTabRect = _GUICtrlTab_GetItemRect($hSysTab32, -1)
	; 배경용 라벨을 만든다
	GUICtrlCreateLabel("", $aTabPos[0], $aTabPos[1] + $aTabRect[3] + 4, $aTabPos[2] - 6, $aTabPos[3] - $aTabRect[3] - 7)
	; 배경색을 칠한다
	GUICtrlSetBkColor(-1, $sBkColor)
	; 클릭이 먹지 않게 비활성화한다
	GUICtrlSetState(-1, $GUI_DISABLE)
EndFunc   ;==>EventTabSetBkColor

Func EventAutoAscendTimer()
	$iAutoAscendTimer = GUICtrlRead($iAutoAscendNumber)
	If $iAutoAscendTimer == 0 Or $iAutoAscendTimer == "" Then
		$iAutoAscendTimer = 1
		GUICtrlSetData($iAutoAscendNumber, 1)
	EndIf
	SaveSettings()
EndFunc   ;==>EventAutoAscendTimer

Func EventAutoBuyTimer()
	$iAutoBuyTimer = GUICtrlRead($iAutoBuyNumber)
	If $iAutoBuyTimer == 0 Or $iAutoBuyTimer == "" Then
		$iAutoBuyTimer = 1
		GUICtrlSetData($iAutoBuyNumber, 1)
	EndIf
	$iAutoBuyTempTimer = $iAutoBuyTimer
	SaveSettings()
EndFunc   ;==>EventAutoBuyTimer

Func EventUpArrow()
	If ($iJumpSliderValue + 10) <= 300 Then
		$iJumpSliderValue += 10
		GUICtrlSetData($iJumpNumber, $iJumpSliderValue)
	EndIf
	SaveSettings()
	SyncProcess()
EndFunc   ;==>EventUpArrow

Func EventDownArrow()
	If ($iJumpSliderValue - 10) >= 0 Then
		$iJumpSliderValue -= 10
		GUICtrlSetData($iJumpNumber, $iJumpSliderValue)
	EndIf
	SaveSettings()
	SyncProcess()
EndFunc   ;==>EventDownArrow

Func EventGlobalCheckBox()
	SetChechBox(@GUI_CtrlId)
	If $iCheckBoxbAutoBuyUpgradeState == @GUI_CtrlId Then
		$iAutoBuyTempTimer = 0.15
		$iTimerAutoBuy = TimerInit()
	EndIf
EndFunc   ;==>EventGlobalCheckBox

; 설명 글자를 눌렀을 때도 짝지어진 체크박스를 토글한다
Func EventGlobalLabel()
	For $i = 0 To UBound($aLabelToCheckBox) - 1
		If $aLabelToCheckBox[$i][0] == @GUI_CtrlId Then
			Local $iCheckBox = $aLabelToCheckBox[$i][1]
			SetChechBox($iCheckBox)
			If $iCheckBoxbAutoBuyUpgradeState == $iCheckBox Then
				$iAutoBuyTempTimer = 0.15
				$iTimerAutoBuy = TimerInit()
			EndIf
			ExitLoop
		EndIf
	Next
EndFunc   ;==>EventGlobalLabel

Func IdleClose()
	Exit
EndFunc   ;==>IdleClose

Func Pause()
	$bTogglePause = Not $bTogglePause
	ControlFocus("Idle Slayer", "", "")
	If $bTogglePause Then
		GUICtrlSetData($iButtonStartStop, "시작")
		GUICtrlSetColor($iButtonStartStop, $COLOR_RUNNING)
		GUICtrlSetData($iLabelStatus, "● 일시정지")
		GUICtrlSetColor($iLabelStatus, $COLOR_PAUSED)
		SyncProcess(False)
	Else
		GUICtrlSetData($iButtonStartStop, "정지")
		GUICtrlSetColor($iButtonStartStop, 0xFF7B7B)
		GUICtrlSetData($iLabelStatus, "● 실행 중")
		GUICtrlSetColor($iLabelStatus, $COLOR_RUNNING)
		SyncProcess()
	EndIf
EndFunc   ;==>Pause

#EndRegion GUI.au3 - #EVENTS#

Func SetChechBox($iId)
	Local $sName
	For $sElement In $aSettingCheckBoxes
		If Eval("iCheckBox" & $sElement) == $iId Then
			$sName = $sElement
			ExitLoop
		EndIf
	Next
	If Eval($sName) Then
		Assign($sName, False, 4)
		If Not @Compiled Then
			GUICtrlSetImage($iId, 'Resources\CheckboxUnchecked.jpg')
		Else
			_Resource_SetToCtrlID($iId, 'UNCHECKED')
		EndIf
	Else
		Assign($sName, True, 4)
		If Not @Compiled Then
			GUICtrlSetImage($iId, 'Resources\CheckboxChecked.jpg')
		Else
			_Resource_SetToCtrlID($iId, 'CHECKED')
		EndIf
	EndIf
	SaveSettings()
EndFunc   ;==>SetChechBox

Func SaveSettings()
	For $sElement In $aSettingGlobalVariables ; 설정 값들을 하나씩 파일에 적는다
		IniWrite("IdleRunnerLogs\Settings.txt", "Settings", $sElement, Eval($sElement))
	Next
EndFunc   ;==>SaveSettings

Func LoadSettings()
	For $sElement In $aSettingGlobalVariables ; 저장된 설정 값들을 하나씩 읽어 온다
		Local $sRead = IniRead("IdleRunnerLogs\Settings.txt", "Settings", $sElement, Eval($sElement))
		If IsInt(Eval($sElement)) Then
			$sRead = Number($sRead)
		EndIf
		If $sRead == "True" Then
			$sRead = True
		EndIf
		If $sRead == "False" Then
			$sRead = False
		EndIf
		Assign($sElement, $sRead, 4)
	Next

	; 읽어 온 값에 맞춰 체크 표시를 다시 그린다
	For $sElement In $aSettingCheckBoxes
		If Eval($sElement) == True Then
			If Not @Compiled Then
				GUICtrlSetImage(Eval("iCheckBox" & $sElement), 'Resources\CheckboxChecked.jpg')
			Else
				_Resource_SetToCtrlID(Eval("iCheckBox" & $sElement), 'CHECKED')
			EndIf
		Else
			If Not @Compiled Then
				GUICtrlSetImage(Eval("iCheckBox" & $sElement), 'Resources\CheckboxUnchecked.jpg')
			Else
				_Resource_SetToCtrlID(Eval("iCheckBox" & $sElement), 'UNCHECKED')
			EndIf
		EndIf
	Next

	GUICtrlSetData($iJumpNumber, $iJumpSliderValue)
	GUICtrlSetData($iAutoAscendNumber, $iAutoAscendTimer)
	GUICtrlSetData($iAutoBuyNumber, $iAutoBuyTimer)
	$iAutoBuyTempTimer = $iAutoBuyTimer
EndFunc   ;==>LoadSettings

Func EventButtonUpdateClick()
	Local $dData = InetRead("https://api.github.com/repos/Devil4ngle/Idle_Slayer_Script/releases/latest", 1)
	$sJsonData = BinaryToString($dData)
	If @error Then
		MsgBox($MB_OK, "오류", "버전 정보를 가져오지 못했습니다.")
		Return False
	EndIf

	Local $iTagIndex = StringInStr($sJsonData, '"tag_name"') + StringLen('"tag_name"') + 2
	Local $sLatestTag = StringMid($sJsonData, $iTagIndex, 5)

	If $sLatestTag = $sVersion Then
		MsgBox($MB_OK, "최신 버전", "이미 최신 버전입니다.")
	Else
		$iRes = MsgBox($MB_OKCANCEL, "업데이트 있음", "새 버전(" & $sLatestTag & ")이 있습니다." & @CRLF & "GitHub 페이지를 열까요?" & @CRLF & @CRLF & "참고: 원본을 새로 받으면 한글판이 아닙니다.")
		If $iRes == $IDOK Then
			ShellExecute("https://github.com/Devil4ngle/Idle_Slayer_Script/releases")
		EndIf
	EndIf
EndFunc   ;==>EventButtonUpdateClick

; #FUNCTION# ====================================================================================================================
; 설명 ..........: 자동 구매 / 자동 승천이 다음에 실행되기까지 남은 시간을 [일반] 탭 오른쪽에 표시한다.
;                  타이머는 TimerInit / TimerDiff 기반이라 [정지] 중에도 계속 흐른다. 그래서 정지 상태에서도
;                  똑같이 갱신해 준다. 실제 실행은 [시작] 이후에 이뤄지므로 0 이 되면 "곧 실행"으로 표시한다.
; ===============================================================================================================================
Func UpdateRemainingLabels()
	; 1초에 한 번만 다시 그린다 (메인 반복문은 40ms 마다 돌기 때문)
	If TimerDiff($iTimerRemainRefresh) < 1000 Then Return
	$iTimerRemainRefresh = TimerInit()

	GUICtrlSetData($iLabelAutoBuyRemain, RemainingText($bAutoBuyUpgradeState, $iAutoBuyTempTimer, $iTimerAutoBuy))
	GUICtrlSetData($iLabelAutoAscendRemain, RemainingText($bAutoAscendState, $iAutoAscendTimer, $iTimerAutoAscend))
EndFunc   ;==>UpdateRemainingLabels

; 남은 시간을 "N시간 NN분 NN초" 형태의 글자로 만든다
Func RemainingText($bEnabled, $iMinutes, $iTimer)
	If Not $bEnabled Then Return ""

	Local $iLeft = Int(($iMinutes * 60000 - TimerDiff($iTimer)) / 1000)
	If $iLeft <= 0 Then Return "곧 실행"

	Local $iHour = Int($iLeft / 3600)
	Local $iMin = Int(Mod($iLeft, 3600) / 60)
	Local $iSec = Mod($iLeft, 60)

	If $iHour > 0 Then Return StringFormat("%d시간 %02d분 %02d초", $iHour, $iMin, $iSec)
	If $iMin > 0 Then Return StringFormat("%d분 %02d초", $iMin, $iSec)
	Return StringFormat("%d초", $iSec)
EndFunc   ;==>RemainingText

Func SyncProcess($bJumpState = True)
	If $bTogglePause == True Then
		$bJumpState = False
	EndIf
	; 값을 문자열로 바꾼다
	$sJumpSliderValue = String($iJumpSliderValue)
	$sJumpState = String($bJumpState)
	; 점프 담당 스레드에 값을 보낸다
	_AuThread_SendMsg("JumpSliderValue:" & $sJumpSliderValue & ";JumpState:" & $sJumpState)
EndFunc   ;==>SyncProcess

Func GUICtrlCreatePicCustom($sFileName, $iLeft, $iTop, $iWidth, $iHeight, $hStyle)
	If Not @Compiled Then
		Return GUICtrlCreatePic($sFileName, $iLeft, $iTop, $iWidth, $iHeight, $hStyle)
	Else
		Return GUICtrlCreatePic('', $iLeft, $iTop, $iWidth, $iHeight, $hStyle)
	EndIf
EndFunc   ;==>GUICtrlCreatePicCustom
