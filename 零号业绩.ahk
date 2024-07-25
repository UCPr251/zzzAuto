﻿/************************************************************************
 * @description 绝区零零号空洞零号业绩自动刷取、自动银行存款脚本
 * @file 零号业绩.ahk
 * @author UCPr
 * @date 2024/07/26
 * @version v1.1.5
 * @link https://github.com/UCPr251/zzzAuto
 * @warning 请勿用于任何商业用途，仅供学习交流使用
 ***********************************************************************/
#Requires AutoHotkey v2
SetWorkingDir(A_ScriptDir)
CoordMode("Mouse", "Window")
CoordMode("Pixel", "Window")
SendMode("Input")
#SingleInstance Force
SetTitleMatchMode(2)
#WinActivateForce
SetControlDelay(1)
SetWinDelay(0)
SetKeyDelay(-1)
SetMouseDelay(-1)
#Include ./components
#Include charOperation.ahk
#Include common.ahk
#Include enterFuben.ahk
#Include exitFuben.ahk
#Include fight.ahk
#Include getMoney.ahk
#Include isLimited.ahk
#Include choose.ahk
#Include refuse.ahk
#Include reachEnd.ahk
#Include saveBank.ahk

/** Alt+q 退出程序 */
!q:: {
  ExitApp()
}

/** Ctrl+s 保存并重载程序 */
; ~^s:: {
;   if (InStr(WinGetTitle("A"), "Visual Studio Code") && InStr(WinGetTitle("A"), A_ScriptName)) {
;     Send("^s")
;     MsgBox("已自动重载脚本" A_ScriptName, , "T1")
;     Reload()
;   }
; }

/** Alt+r 重启程序 */
!r:: {
  MsgBox("重启脚本" A_ScriptName, , "T1")
  Reload()
}

/** Alt+p 暂停线程 */
!p:: {
  MsgBox("脚本已" (A_IsPaused ? "恢复" : "暂停") "，再次Alt+P可切换状态", , "T2")
  Pause(-1)
}

/** Alt+z 运行程序 */
!z:: {
  MsgBox("【开始运行】绝区零零号空洞自动刷取脚本", , "T2")
  main()
}

global bank := 0

/** Alt+b 银行模式，无限循环 */
!b:: {
  global bank
  bank := !bank
  MsgBox("已" (bank ? "开启" : "关闭") "银行模式（无限循环刷取银行存款）", , "T2")
}

MsgBox("`t`t绝区零零号空洞自动刷取脚本`n`n注意：此脚本必须在管理员模式下运行才能使用`n`n使用方法：`n    Alt+Z ：启动脚本（默认情况下会循环刷取直至零号业绩达到周上限）`n    Alt+P ：暂停脚本`n    Alt+Q ：退出脚本`n    Alt+R ：重启脚本`n    Alt+B ：银行模式（开启此模式后，无论是否达到上限都会一直刷取）`n`n仓库地址：https://gitee.com/UCPr251/zzzAuto")

/** 是否输出步骤调试日志 */
global isDebugLog := 1

/** 开始，检测所在页面 */
main() {
  activateZZZ()
  /** 通过三个特殊定位点判断所处界面 */
  patterns1 := [
    [1171, 889, 1784, 901, 0xffffff, 30], ; M
    [1770, 1027, 1784, 1042, 0xffffff, 30], ; Q
    [1805, 121, 1797, 911, 0xffffff, 30]  ; Tab
  ]
  patterns2 := [
    [249, 733, 257, 742, 0x78cc00, 30], ; 资质考核
    [594, 832, 602, 841, 0x78cc00, 30], ; 旧都列车
    [688, 419, 696, 428, 0x78cc00, 30] ; 施工废墟
  ]
  mode := 0
  /** 判断是否位于对应界面 */
  judge(patterns) {
    for (index, pattern in patterns) {
      if (!PixelSearchPre(&FoundX, &FoundY, pattern*)) {
        return false
      }
    }
    return true
  }
  loop (20) {
    if (judge(patterns1)) {
      mode := 1
      break
    }
    if (judge(patterns2)) {
      mode := 2
      break
    }
  }
  if (!mode) {
    return MsgBox("请位于 <零号空洞关卡选择界面> 或 <角色操作界面> 重试")
  } else if (mode = 1) {
    MsgBox("【开始】模式：角色操作界面", , "T2")
  } else {
    MsgBox("【开始】模式：零号空洞关卡选择界面", , "T2")
  }
  RandomSleep()
  run(mode)
}

/** 运行刷取脚本，1：角色操作界面，2：关卡选择界面 */
run(mode) {
  ; 刷取次数
  static count := 0
  if (mode = 1) {
    charOperation()
  }
  status := 0
  ; 进入副本
  enterFuben()
  ; 拒绝好意，结束对话
  refuse()
  ; 前往终点
  status := reachEnd()
  if (status = 0) {
    return MsgBox("【识别地图类型】地图类型识别失败", "错误")
  }
  ; 战斗
  status := fight()
  if (status = 0) {
    return MsgBox("【战斗】战斗超时或检测异常，请重新启动", "错误")
  }
  ; 选择增益
  choose()
  ; 获得零号业绩
  getMoney()
  ; 存银行
  saveBank()
  ; 退出副本
  exitFuben()
  count++
  if (bank) {
    MsgBox("银行模式，无限循环。已刷取" count "次", , "T2")
  } else {
    ; 判断是否达到上限
    if (isLimited()) {
      return MsgBox("已达到上限，脚本结束。共刷取" count "次")
    }
    MsgBox("未达到上限，继续刷取。已刷取" count "次", , "T2")
  }
  RandomSleep()
  ; 点击完成
  pixelSearchAndClick(1676, 1018, 1724, 1038, 1699, 1027, 0xffffff)
  RandomSleep(3800, 4000)
  ; 继续循环
  run(2)
}