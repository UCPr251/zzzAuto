/************************************************************************
 * @description 绝区零零号空洞零号业绩自动刷取、自动银行存款脚本
 * @file 零号业绩.ahk
 * @author UCPr
 * @date 2024/08/19
 * @version v1.6.0
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
#Include ./utils
#Include common.ahk
#Include Config.ahk
#Include Controller.ahk
#Include CoordsData.ahk
#Include Panel.ahk
#Include ../components
#Include charOperation.ahk
#Include choose.ahk
#Include enterFuben.ahk
#Include exitFuben.ahk
#Include fight.ahk
#Include getMoney.ahk
#Include isLimited.ahk
#Include reachEnd.ahk
#Include recogLocation.ahk
#Include refuse.ahk
#Include saveBank.ahk

global Version := "v1.6.0"

init()

/** Alt+P 暂停/恢复线程 */
!p:: {
  if (!Ctrl.ing) {
    return MsgBox("当前未处于刷取期间", , "Icon! 0x40000 T3")
  }
  MsgBox("已" (A_IsPaused ? "恢复" : "暂停") "脚本，再次Alt+P可切换状态", , "T1")
  Pause(-1)
}

/** Alt+C 控制面板 */
!c:: p.ControlPanel()

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
      MsgBox("自动获取管理员权限失败，请右键脚本选择以管理员身份运行", "错误", "Iconx 0x40000")
    }
    ExitApp()
  }
  global setting := Config()
  global c := CoordsData()
  global p := Panel()
  global Ctrl := Controller()
  OnError(errHandler)
  errHandler(err, *) {
    Ctrl.stop()
    throw err
  }
  if (c.compatible) {
    MsgBox("警告：`n当前显示器分辨率" A_ScreenWidth "x" A_ScreenHeight "无内置数据`n将使用" c.mode "的分辨率比例数据进行缩放兼容处理`n`n若无法正常运行，请更改分辨率比例为16:9，如1920*1080", "警告", "Icon! 0x40000")
  }
  MsgBox("`t   绝区零零号空洞自动刷取脚本`n`n使用方法 ：`n`n    Alt+P ：暂停/恢复脚本`n    Alt+C ：打开/关闭控制面板`n`n当前版本 ：" Version "`n仓库地址 ：https://github.com/UCPr251/zzzAuto", "UCPr", "0x40000")
  p.ControlPanel()
}

/** 开始，检测所在页面 */
main() {
  c.reset()
  WinGetClientPos(, , &w, &h, "ahk_exe ZenlessZoneZero.exe")
  if (w != A_ScreenWidth && h != A_ScreenHeight) {
    MsgBox("请全屏运行游戏", "错误", "Iconx 0x40000")
    Exit()
  }
  Ctrl.stop() ; 重置
  Ctrl.ing := true
  mode := recogLocation()
  if (!mode) {
    Ctrl.ing := false
    return MsgBox("请位于 <零号空洞主页> 或 <角色操作界面> 重试", "错误", "Iconx 0x40000")
  } else if (mode = 1) {
    debugLog("【开始】模式：角色操作界面")
  } else {
    debugLog("【开始】模式：零号空洞主页")
  }
  judgeExit()
  RandomSleep()
  if (mode = 1) {
    if (!charOperation()) {
      Ctrl.ing := false
      return MsgBox("进入零号空洞主页失败，请手动进入后重试", "错误", "Iconx 0x40000")
    }
  }
  judgeExit()
  runAutoZZZ()
}

/** 出现异常后重试 */
retry(reason) {
  if (!setting.errHandler) {
    throw Error(reason)
  }
  ; 如果连一次都没有刷取成功，直接退出
  if (setting.statistics.Length = 0) {
    return MsgBox("【错误】" reason, "错误", "Iconx 0x40000")
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
    errTimes := 0
    errReasons := []
    return errMsg
  }
  if (errTimes > 3) {
    Ctrl.stop()
    return MsgBox("【错误】异常次数过多，脚本结束" getErrorMsg(), "错误", "Iconx 0x40000")
  }
  MsgBox("【错误】连续刷取过程中出现异常：`n" reason "`n`n将在6s后重试", "错误", "Iconx T6 0x40000")
  RandomSleep()
  judgeExit()
  ; 如果有确认框或选择框
  loop (3) {
    if (PixelSearchPre(&X, &Y, c.空洞.确定*)) {
      SimulateClick(X, Y)
      Sleep(5000)
    }
    Sleep(200)
  }
  judgeExit()
  ; 先Esc偶数次，避免进入了什么奇怪的界面
  Press("Escape")
  RandomSleep(1000, 1200)
  Press("Escape")
  RandomSleep(1000, 1200)
  exitFuben()
  judgeExit()
  pixelSearchAndClick(c.空洞.结算.完成*)
  RandomSleep(4800, 5000)
  judgeExit()
  ; 重新识别所处界面
  mode := recogLocation()
  judgeExit()
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
  judgeExit()
  Ctrl.start()
  status := 0
  ; 进入副本
  enterFuben()
  judgeExit()
  ; 拒绝好意
  refuse()
  judgeExit()
  ; 前往终点
  status := reachEnd()
  judgeExit()
  if (status = 0) {
    return retry("地图类型识别失败")
  }
  ; 战斗
  status := fight()
  judgeExit()
  if (status = 0) {
    return retry("战斗超时或检测异常")
  }
  ; 选择增益
  status := choose()
  judgeExit()
  if (status = 0) {
    return retry("未找到对应增益选项")
  }
  ; 获得零号业绩
  getMoney()
  judgeExit()
  ; 存银行
  if (setting.isSaveBank) {
    saveBank()
    judgeExit()
  }
  ; 退出副本
  exitFuben()
  Ctrl.finish()
  judgeExit()
  if (setting.bankMode) {
    debugLog("银行模式，无限循环。已刷取" setting.statistics.Length "次")
  } else {
    ; 判断是否达到上限
    if (isLimited()) {
      judgeExit()
      if (setting.isAutoClose) {
        WinClose("ahk_exe ZenlessZoneZero.exe")
      }
      Ctrl.stop()
      return MsgBox("已达到周上限，脚本结束。共刷取" setting.statistics.Length "次")
    }
    debugLog("未达到周上限，继续刷取。已刷取" setting.statistics.Length "次")
  }
  judgeExit()
  RandomSleep(800, 1000)
  ; 点击完成
  pixelSearchAndClick(c.空洞.结算.完成*)
  judgeExit()
  while (recogLocation() != 2) {
    Sleep(100)
  }
  judgeExit()
  ; 继续循环
  runAutoZZZ()
}

judgeExit() {
  if (Ctrl.nextExit) {
    Ctrl.stop()
    MsgBox("已结束当前刷取线程", , "0x40000 T3")
    Exit()
  }
}