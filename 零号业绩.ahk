﻿/************************************************************************
 * @description 绝区零零号空洞零号业绩自动刷取、自动银行存款脚本
 * @file 零号业绩.ahk
 * @author UCPr
 * @date 2024/08/15
 * @version v1.4.1
 * @link https://github.com/UCPr251/zzzAuto
 * @warning 请勿用于任何商业用途，仅供学习交流使用
 ***********************************************************************/
#Requires AutoHotkey v2
SetWorkingDir(A_ScriptDir)
CoordMode("Mouse", "Window")
CoordMode("Pixel", "Window")
SendMode("Input")
#SingleInstance Force
#WinActivateForce
SetControlDelay(1)
SetWinDelay(0)
SetKeyDelay(-1)
SetMouseDelay(-1)
#Include ./components
#Include coordsData.ahk
#Include charOperation.ahk
#Include choose.ahk
#Include common.ahk
#Include enterFuben.ahk
#Include exitFuben.ahk
#Include fight.ahk
#Include getMoney.ahk
#Include isLimited.ahk
#Include reachEnd.ahk
#Include recogLocation.ahk
#Include refuse.ahk
#Include saveBank.ahk

/** 休眠系数，加载动画等待时长在原基础上的倍率，可通过修改该值延长/缩短全局等待时长 */
global sleepCoefficient := 1
/** RGB颜色搜索允许的渐变值 */
global variation := 60
/** 是否开启调试日志信息输出 */
global isDebugLog := true
/** 是否开启银行模式 */
global bank := false
/** 是否存银行 */
global save := true

/** 刷取统计数据 */
global statistics := []

/** Alt+q 退出程序 */
!q:: {
  result := MsgBox("确定关闭零号业绩自动刷取脚本？Y/N", , "0x1")
  if (result = "OK") {
    ExitApp()
  }
}

; /** Ctrl+s 保存并重载程序 */
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

/** Alt+s 开启/关闭银行存款 */
!s:: {
  global save
  save := !save
  MsgBox("已" (save ? "开启" : "关闭") "银行存款，再次Alt+S可切换状态", , "T1")
}

/** Alt+L 开启/关闭日志弹窗 */
!l:: {
  global isDebugLog
  isDebugLog := !isDebugLog
  MsgBox("已" (isDebugLog ? "开启" : "关闭") "调试日志弹窗，再次Alt+L可切换状态", , "T1")
}

/** Alt+p 暂停/恢复线程 */
!p:: {
  MsgBox("已" (A_IsPaused ? "恢复" : "暂停") "脚本，再次Alt+P可切换状态", , "T1")
  Pause(-1)
}

/** Alt+z 运行程序 */
!z:: {
  MsgBox("【开始运行】绝区零零号空洞自动刷取脚本", , "T1")
  main()
}

/** Alt+t 查看统计 */
!t:: {
  static g := 0
  static paused
  if (g) {
    g.Destroy()
    g := 0
    if (!paused) {
      Pause(0)
    }
    return
  }
  paused := A_IsPaused
  Pause(1)
  title := "已刷取" statistics.Length "次`n"
  msg := ""
  sum := 0
  for (index, value in statistics) {
    msg .= "`n第" index "次刷取耗时：" (value // 60) "分" Mod(value, 60) "秒"
    sum += value
  }
  title .= "总计耗时：" (sum // 3600) "小时" Round(Mod(sum, 3600) / 60) "分钟`n"
  if (statistics.Length > 0) {
    title .= "平均耗时：" (sum // statistics.Length // 60) "分" Mod(sum // statistics.Length, 60) "秒`n"
  }
  msg := title msg
  g := Gui("AlwaysOnTop", "零号业绩刷取统计")
  g.SetFont('s15', '微软雅黑')
  g.Add('Edit', 'w300 r' Min(20, statistics.Length + 4) ' ReadOnly', msg)
  g.Show()
  g.OnEvent("Close", (MyGui) => MyGui.Destroy() || (!paused && Pause(0)) || g := 0)
}

/** Alt+b 银行模式，无限循环 */
!b:: {
  global bank
  bank := !bank
  MsgBox("已" (bank ? "开启" : "关闭") "银行模式（无限循环刷取银行存款）", , "T2")
}

/** 初始化 */
init() {
  cmd := DllCall("GetCommandLine", "str")
  if (!A_IsAdmin) {
    if (!RegExMatch(cmd, " /restart(?!\S)")) {
      try {
        if (A_IsCompiled) {
          Run('*RunAs "' A_ScriptFullPath '" /restart')
        } else {
          Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"')
        }
      } catch {
        MsgBox("自动获取管理员权限失败，请右键脚本选择以管理员身份运行", "错误", "Iconx 0x40000")
      }
    } else {
      MsgBox("请右键脚本选择以管理员身份运行", "错误", "Iconx 0x40000")
    }
    ExitApp()
  }
  MsgBox("`t`t绝区零零号空洞自动刷取脚本`n`n使用方法：`n    Alt+Z ：启动脚本（默认情况下会循环刷取直至零号业绩达到周上限）`n    Alt+T ：查看/关闭刷取统计`n    Alt+S ：关闭/开启银行存款（关闭后不再存银行）`n    Alt+L ：关闭/开启日志弹窗`n    Alt+P ：暂停/恢复脚本`n    Alt+R ：重启脚本`n    Alt+Q ：退出脚本`n    Alt+B ：银行模式（开启此模式后，无论是否达到上限都会一直刷取）`n`n仓库地址：https://github.com/UCPr251/zzzAuto", "UCPr", "0x40000")
  setRatio()
}

init()

/** 开始，检测所在页面 */
main() {
  activateZZZ()
  WinGetClientPos(, , &w, &h, "ahk_exe ZenlessZoneZero.exe ahk_class UnityWndClass")
  if (w != A_ScreenWidth && h != A_ScreenHeight) {
    MsgBox("【错误】请全屏运行游戏", "错误", "Iconx 0x40000")
    Exit()
  }
  mode := recogLocation()
  if (!mode) {
    return MsgBox("请位于 <零号空洞关卡选择界面> 或 <角色操作界面> 重试", "错误", "Iconx 0x40000")
  } else if (mode = 1) {
    debugLog("【开始】模式：角色操作界面")
  } else {
    debugLog("【开始】模式：零号空洞关卡选择界面")
  }
  RandomSleep()
  if (mode = 1) {
    if (!charOperation()) {
      return MsgBox("进入零号空洞关卡选择界面失败，请手动进入后重试", "错误", "Iconx 0x40000")
    }
  }
  runAutoZZZ()
}

/** 出现异常后重试 */
retry(reason) {
  ; 如果连一次都没有刷取成功，直接退出
  if (statistics.Length = 0) {
    return MsgBox("【错误】" reason, "错误", "Iconx")
  }
  static errTimes := 0
  static errReasons := []
  errTimes++
  errReasons.Push(reason)
  getErrorMsg() {
    errMsg := ""
    loop (errReasons.Length) {
      errMsg .= "`n异常" A_Index "：" errReasons[A_Index]
    }
    ; 重置异常数据
    errTimes := 0
    errReasons := []
    return errMsg
  }
  if (errTimes > 3) {
    return MsgBox("【错误】异常次数过多，脚本结束" getErrorMsg(), "错误", "Iconx 0x40000")
  }
  MsgBox("【错误】连续刷取过程中出现异常：`n" reason "`n`n将在6s后重试", "错误", "Iconx T6")
  RandomSleep()
  ; 如果有确认框或选择框
  loop (3) {
    if (PixelSearchPre(&X, &Y, 650, 620, 1250, 820, 0xffffff, 0)) {
      SimulateClick(X, Y)
      Sleep(5000)
    }
    Sleep(200)
  }
  ; 先Esc偶数次，避免进入了什么奇怪的界面
  Press("Escape")
  RandomSleep(1000, 1200)
  Press("Escape")
  ; 退出副本
  exitFuben()
  ; 点击完成
  pixelSearchAndClick(c.空洞.结算.完成*)
  RandomSleep(4800, 5000)
  ; 重新识别所处界面
  mode := recogLocation()
  if (mode = 2) {
    return runAutoZZZ()
  } else if (mode = 1) {
    if (charOperation()) {
      return runAutoZZZ()
    }
  }
  return MsgBox("【重试失败】未找到零号空洞关卡选择界面，脚本结束`n重试原因：" reason "`n异常次数：" errTimes "`n历史异常：" getErrorMsg(), "错误", "Iconx 0x40000")
}

/** 运行刷取脚本 */
runAutoZZZ() {
  ; 时长统计
  start := A_Now
  status := 0
  ; 进入副本
  enterFuben()
  ; 拒绝好意
  refuse()
  ; 前往终点
  status := reachEnd()
  if (status = 0) {
    return retry("地图类型识别失败")
  }
  ; 战斗
  status := fight()
  if (status = 0) {
    return retry("战斗超时或检测异常")
  }
  ; 选择增益
  status := choose()
  if (status = 0) {
    return retry("未找到对应增益选项")
  }
  ; 获得零号业绩
  getMoney()
  ; 存银行
  if (save) {
    saveBank()
  }
  ; 退出副本
  exitFuben()
  end := A_Now
  statistics.Push(DateDiff(end, start, "s"))
  if (bank) {
    debugLog("银行模式，无限循环。已刷取" statistics.Length "次")
  } else {
    ; 判断是否达到上限
    if (isLimited()) {
      return MsgBox("已达到上限，脚本结束。共刷取" statistics.Length "次")
    }
    debugLog("未达到上限，继续刷取。已刷取" statistics.Length "次")
  }
  RandomSleep(800, 1000)
  ; 点击完成
  pixelSearchAndClick(c.空洞.结算.完成*)
  RandomSleep(4800, 5000)
  ; 继续循环
  runAutoZZZ()
}