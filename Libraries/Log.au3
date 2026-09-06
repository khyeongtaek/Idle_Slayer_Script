#include-once
#include <File.au3>
#Region LogEx.au3 - #FUNCTION#

; #FUNCTION# ====================================================================================================================
; 설명 ..........: 이전에 쌓아 둔 기록 파일을 읽어서 통계를 보여준다.
;                  기록 파일(IdleRunnerLogs\Logs.txt)에 적히는 문구 자체는 영어 그대로 둔다.
;                  아래 Switch 문이 그 문구를 그대로 비교해서 개수를 세기 때문이고, 화면에는 한글로만 보여준다.
; 매개변수 ......: $iLog                 - 글자를 표시할 Edit 컨트롤
; ===============================================================================================================================
Func LoadLog($iLog)
	Sleep(100)
	Local $iBS2Section1 = 0, $iBS2Section2 = 0, $iBS2Section3 = 0, $iBS2Section4 = 0, $iBS2Failed = 0, _
			$iBS2Section1SB = 0, $iBS2Section2SB = 0, $iBS2Section3SB = 0, $iBS2Section4SB = 0, $iBonusStage2 = 0, $iBonusStage2SB = 0, _
			$iBS3Section1 = 0, $iBS3Section2 = 0, $iBS3Section3 = 0, $iBS3Section4 = 0, $iBS3Failed = 0, $iBS3FailedSB = 0, $iBS3Retried = 0, $iBS3RetriedSB = 0, _
			$iBS3Section1SB = 0, $iBS3Section2SB = 0, $iBS3Section3SB = 0, $iBS3Section4SB = 0, $iBonusStage3 = 0, $iBonusStage3SB = 0, _
			$iMinionsClaimed = 0, $iQuestClaimed = 0, $iSilverboxColl = 0, $iMegaHordeRage = 0, $iMegaHordeRageSoul = 0, $iChesthunt = 0, $iPerfectChestHunt = 0, _
			$iBossFightVictorWon = 0, $iBossFightVictor = 0, $iBossFightKnightWon = 0, $iBossFightKnight = 0, $iAscendingHeights = 0, $iAscendingHeightsFailed = 0, _
			$iAutoAscendDone = 0, $iAutoAscendSkipped = 0, $iMinionsNotFound = 0
	Local $hFile = FileOpen("IdleRunnerLogs\Logs.txt", $FO_READ)
	If $hFile <> -1 Then
		While 1
			Local $sLine = FileReadLine($hFile)
			If @error = -1 Then ExitLoop
			$sLine = StringTrimLeft($sLine, 22)
			Switch $sLine
				Case "Silver Box Collected"
					$iSilverboxColl += 1
				Case "Minions Collect"
					$iMinionsClaimed += 1
				Case "Minions Collect with Daily Bonus"
					$iMinionsClaimed += 1
				Case "Minions Collect Nothing Found"
					$iMinionsNotFound += 1
				Case "Chesthunt"
					$iChesthunt += 1
				Case "Perfect ChestHunt Completed"
					$iPerfectChestHunt += 1
				Case "Claiming quest"
					$iQuestClaimed += 1
				Case "MegaHorde Rage"
					$iMegaHordeRage += 1
				Case "MegaHorde Rage with SoulBonus"
					$iMegaHordeRageSoul += 1
				Case "Auto Ascend Done"
					$iAutoAscendDone += 1
				Case "Auto Ascend Skipped - No Ascension Points"
					$iAutoAscendSkipped += 1
				Case "BonusStage2SB Section 1 Complete"
					$iBS2Section1SB += 1
				Case "BonusStage2SB Section 2 Complete"
					$iBS2Section2SB += 1
				Case "BonusStage2SB Section 3 Complete"
					$iBS2Section3SB += 1
				Case "BonusStage2SB Section 4 Complete"
					$iBS2Section4SB += 1
				Case "BonusStage2 Section 1 Complete"
					$iBS2Section1 += 1
				Case "BonusStage2 Section 2 Complete"
					$iBS2Section2 += 1
				Case "BonusStage2 Section 3 Complete"
					$iBS2Section3 += 1
				Case "BonusStage2 Section 4 Complete"
					$iBS2Section4 += 1
				Case "BonusStage2 Failed"
					$iBS2Failed += 1
				Case "BonusStage2"
					$iBonusStage2 += 1
				Case "BonusStage2SB"
					$iBonusStage2SB += 1
				Case "BonusStage3SB Section 1 Complete"
					$iBS3Section1SB += 1
				Case "BonusStage3SB Section 2 Complete"
					$iBS3Section2SB += 1
				Case "BonusStage3SB Section 3 Complete"
					$iBS3Section3SB += 1
				Case "BonusStage3SB Section 4 Complete"
					$iBS3Section4SB += 1
				Case "BonusStage3 Section 1 Complete"
					$iBS3Section1 += 1
				Case "BonusStage3 Section 2 Complete"
					$iBS3Section2 += 1
				Case "BonusStage3 Section 3 Complete"
					$iBS3Section3 += 1
				Case "BonusStage3 Section 4 Complete"
					$iBS3Section4 += 1
				Case "BonusStage3 Failed"
					$iBS3Failed += 1
				Case "BonusStage3SB Failed"
					$iBS3FailedSB += 1
				Case "BonusStage3 Retry"
					$iBS3Retried += 1
				Case "BonusStage3SB Retry"
					$iBS3RetriedSB += 1
				Case "BonusStage3"
					$iBonusStage3 += 1
				Case "BonusStage3SB"
					$iBonusStage3SB += 1
				Case "Start of Ascending Heights"
					$iAscendingHeights += 1
				Case "Ascending Height Failed"
					$iAscendingHeightsFailed += 1
				Case "Start of BossFight Victor"
					$iBossFightVictor += 1
				Case "Victor Won"
					$iBossFightVictorWon += 1
				Case "Start of BossFight Knight"
					$iBossFightKnight += 1
				Case "Knight Won"
					$iBossFightKnightWon += 1
			EndSwitch
		WEnd
		FileClose($hFile)
	EndIf

	Local $iBS2TotalAttempts = $iBonusStage2 + $iBonusStage2SB
	Local $iBS2TotalCompletes = $iBS2Section4 + $iBS2Section4SB
	Local $iBS2SuccessPerc = $iBS2TotalAttempts == 0 ? 0 : Round($iBS2TotalCompletes / $iBS2TotalAttempts * 100, 2)

	Local $iBS3TotalAttempts = $iBonusStage3 + $iBonusStage3SB
	Local $iBS3TotalCompletes = $iBS3Section4 + $iBS3Section4SB
	Local $iBS3SuccessPerc = $iBS3TotalAttempts == 0 ? 0 : Round($iBS3TotalCompletes / $iBS3TotalAttempts * 100, 2)

	Local $iBS3TotalFails = $iBS3Failed + $iBS3FailedSB
	Local $iBS3TotalRetried = $iBS3Retried + $iBS3RetriedSB

	GUICtrlSetData($iLog, "")
	CustomConsole($iLog, "메가 호드만으로 분노: " & $iMegaHordeRage - $iMegaHordeRageSoul)
	CustomConsole($iLog, "메가 호드 + 소울 보너스로 분노: " & $iMegaHordeRageSoul)
	CustomConsole($iLog, "받은 퀘스트 보상: " & $iQuestClaimed)
	CustomConsole($iLog, "수집한 미니언: " & $iMinionsClaimed)
	CustomConsole($iLog, "상자 사냥: " & $iChesthunt)
	CustomConsole($iLog, "퍼펙트 상자 사냥: " & $iPerfectChestHunt)
	CustomConsole($iLog, "주운 은상자: " & $iSilverboxColl)
	CustomConsole($iLog, "-----------------------승천-----------------------")
	CustomConsole($iLog, "자동 승천 성공: " & $iAutoAscendDone)
	CustomConsole($iLog, "포인트 부족으로 건너뜀: " & $iAutoAscendSkipped)
	CustomConsole($iLog, "미니언 버튼 못 찾음: " & $iMinionsNotFound)
	CustomConsole($iLog, "------------------보너스 스테이지 2------------------")
	CustomConsole($iLog, "총 시도: " & $iBS2TotalAttempts)
	CustomConsole($iLog, "총 완료: " & $iBS2TotalCompletes)
	CustomConsole($iLog, "실패: " & $iBS2Failed)
	CustomConsole($iLog, "성공률: " & $iBS2SuccessPerc & "%")
	CustomConsole($iLog, "BS2: 시도 (영혼 부스트 없음): " & $iBonusStage2)
	CustomConsole($iLog, "BS2: 시도 (영혼 부스트 있음): " & $iBonusStage2SB)
	CustomConsole($iLog, "BS2: 완료 (영혼 부스트 없음): " & $iBS2Section4)
	CustomConsole($iLog, "BS2: 완료 (영혼 부스트 있음): " & $iBS2Section4SB)
	CustomConsole($iLog, "BS2: 1구간 완료 (부스트 없음): " & $iBS2Section1)
	CustomConsole($iLog, "BS2: 2구간 완료 (부스트 없음): " & $iBS2Section2)
	CustomConsole($iLog, "BS2: 3구간 완료 (부스트 없음): " & $iBS2Section3)
	CustomConsole($iLog, "BS2: 4구간 완료 (부스트 없음): " & $iBS2Section4)
	CustomConsole($iLog, "BS2: 1구간 완료 (부스트 있음): " & $iBS2Section1SB)
	CustomConsole($iLog, "BS2: 2구간 완료 (부스트 있음): " & $iBS2Section2SB)
	CustomConsole($iLog, "BS2: 3구간 완료 (부스트 있음): " & $iBS2Section3SB)
	CustomConsole($iLog, "BS2: 4구간 완료 (부스트 있음): " & $iBS2Section4SB)
	CustomConsole($iLog, "------------------보너스 스테이지 3------------------")
	CustomConsole($iLog, "총 시도: " & $iBS3TotalAttempts)
	CustomConsole($iLog, "총 완료: " & $iBS3TotalCompletes)
	CustomConsole($iLog, "재시도: " & $iBS3TotalRetried)
	CustomConsole($iLog, "실패: " & $iBS3TotalFails)
	CustomConsole($iLog, "성공률: " & $iBS3SuccessPerc & "%")
	CustomConsole($iLog, "BS3: 시도 (영혼 부스트 없음): " & $iBonusStage3)
	CustomConsole($iLog, "BS3: 시도 (영혼 부스트 있음): " & $iBonusStage3SB)
	CustomConsole($iLog, "BS3: 완료 (영혼 부스트 없음): " & $iBS3Section4)
	CustomConsole($iLog, "BS3: 완료 (영혼 부스트 있음): " & $iBS3Section4SB)
	CustomConsole($iLog, "BS3: 1구간 완료 (부스트 없음): " & $iBS3Section1)
	CustomConsole($iLog, "BS3: 2구간 완료 (부스트 없음): " & $iBS3Section2)
	CustomConsole($iLog, "BS3: 3구간 완료 (부스트 없음): " & $iBS3Section3)
	CustomConsole($iLog, "BS3: 4구간 완료 (부스트 없음): " & $iBS3Section4)
	CustomConsole($iLog, "BS3: 1구간 완료 (부스트 있음): " & $iBS3Section1SB)
	CustomConsole($iLog, "BS3: 2구간 완료 (부스트 있음): " & $iBS3Section2SB)
	CustomConsole($iLog, "BS3: 3구간 완료 (부스트 있음): " & $iBS3Section3SB)
	CustomConsole($iLog, "BS3: 4구간 완료 (부스트 있음): " & $iBS3Section4SB)
	CustomConsole($iLog, "--------------------승천 고지--------------------")
	CustomConsole($iLog, "승천 고지 성공: " & $iAscendingHeights - $iAscendingHeightsFailed)
	CustomConsole($iLog, "승천 고지 실패: " & $iAscendingHeightsFailed)
	CustomConsole($iLog, "---------------------보스전---------------------")
	CustomConsole($iLog, "빅터 전투 진행: " & $iBossFightVictor)
	CustomConsole($iLog, "빅터 전투 승리: " & $iBossFightVictorWon)
	CustomConsole($iLog, "빅터 전투 패배: " & $iBossFightVictor - $iBossFightVictorWon)
	CustomConsole($iLog, "기사 전투 진행: " & $iBossFightKnight)
	CustomConsole($iLog, "기사 전투 승리: " & $iBossFightKnightWon)
	CustomConsole($iLog, "기사 전투 패배: " & $iBossFightKnight - $iBossFightKnightWon, True)
EndFunc   ;==>LoadLog

; #FUNCTION# ====================================================================================================================
; 설명 ..........: 현재 상태와 게임 설정 안내를 보여준다.
; 매개변수 ......: $iLogData                 - 글자를 표시할 Edit 컨트롤
; ===============================================================================================================================
Func LoadDataLog($iLogData)
	Sleep(100)
	GUICtrlSetData($iLogData, "")

	If WinExists("Idle Slayer") == 1 Then
		Local $aArray = WinGetClientSize('Idle Slayer')
		If $aArray[0] == "1280" And $aArray[1] == "720" Then
			CustomConsole($iLogData, "게임 창 크기 정상 : " & $aArray[0] & "x" & $aArray[1])
		Else
			CustomConsole($iLogData, "게임 창 크기가 잘못됐습니다. 1280x720 이어야 합니다.")
			CustomConsole($iLogData, "지금 크기: " & $aArray[0] & "x" & $aArray[1])
		EndIf
	Else
		CustomConsole($iLogData, "Idle Slayer 가 실행되어 있지 않습니다.")
	EndIf
	CustomConsole($iLogData, "------------------- 필수 설정 -------------------")
	CustomConsole($iLogData, "게임 언어는 영어로 두어야 합니다.")
	CustomConsole($iLogData, "게임 해상도 1280x720, 창 모드, 배율 100%.")
	CustomConsole($iLogData, "게임 창이 활성 상태여야 합니다. 아니면 점프만 합니다.")
	CustomConsole($iLogData, "조작키: 점프 = 위쪽 화살표, 부스트 = 오른쪽 화살표.")
	CustomConsole($iLogData, "설정에서 커스텀 커서를 끄세요.")
	CustomConsole($iLogData, "설정에서 포탈 대화창을 끄세요.")
	CustomConsole($iLogData, "설정에서 반올림 대량 구매를 켜세요.")
	CustomConsole($iLogData, "설정에서 잠긴 퀘스트 보상 숨기기를 켜세요.")
	CustomConsole($iLogData, "수직 자석은 사지 마세요.")
	CustomConsole($iLogData, "윈도우 11 이면 관리자 권한으로 실행하세요.")
	CustomConsole($iLogData, "------------------- 권장 사항 -------------------")
	CustomConsole($iLogData, "보너스 스테이지는 2, 3 만 됩니다. 나머지는 건너뛰세요.")
	CustomConsole($iLogData, "보너스 스테이지 2 는 하드 모드를 끄세요.")
	CustomConsole($iLogData, "승천 업그레이드 '보호'는 보너스 스테이지 2 에 필요합니다.")
	CustomConsole($iLogData, "승천 업그레이드 '판자 발판'은 보너스 스테이지 3 에 필요합니다.")
	CustomConsole($iLogData, "빅터 전투와 승천 고지는 안나 기본 스킨을 쓰세요.")
	CustomConsole($iLogData, "미니언은 승천 업그레이드 '리더십 마스터'가 있으면 가장 잘 됩니다.")
	CustomConsole($iLogData, "   없으면 [일반] 탭에서 '리더십 마스터 없음'을 켜거나,")
	CustomConsole($iLogData, "   '미니언 자동 수집'을 꺼 두세요.")
	CustomConsole($iLogData, "팁: 각 옵션에 마우스를 올리면 설명이 나옵니다!", True)
EndFunc   ;==>LoadDataLog

Func CustomConsole($iComponent, $sText, $bAppend = False)
	If $bAppend Then
		$sText = $sText & "	"
	Else
		$sText = $sText & @CRLF
	EndIf
	GUICtrlSetData($iComponent, $sText, 1)
EndFunc   ;==>CustomConsole
