/************************************************************************
 * @description 绝区零零号空洞零号业绩自动刷取、自动银行存款脚本
 * @file 零号业绩.ahk
 * @author UCPr
 * @date 2024/11/04
 * @version v1.8.5
 * @link https://github.com/UCPr251/zzzAuto
 * @warning 请勿用于任何商业用途，仅供学习交流使用
 ***********************************************************************/
#Requires AutoHotkey v2
#SingleInstance Force
#WinActivateForce
SetWorkingDir(A_ScriptDir)
CoordMode("Mouse", "Window")
CoordMode("Pixel", "Window")
SendMode("Input")
ListLines(0)
SetCapsLockState(0)
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

global Version := "v1.8.5"

init()

/** Alt+P 暂停/恢复线程 */
!p:: {
  if (!Ctrl.ing) {
    return MsgBox("当前未处于刷取期间", , "Icon! 0x40000 T3")
  }
  if (p.CP) {
    if (!p.paused) {
      if (p.CP.pauseButton) {
        Pause(1)
        p.CP.pauseButton.Text := "&P 继续"
        p.paused := !p.paused
      }
      return
    }
    p.CP.destroyGui()
  } else {
    MsgBox("已" (A_IsPaused ? "恢复" : "暂停") "脚本，再次Alt+P可切换状态", , "T1")
  }
  Pause(-1)
}

/** Alt+C 控制面板 */
!c:: p.ControlPanel()

!t:: {
  if (p.CP) {
    p.StatisticsPanel()
  }
}

/** 初始化 */
init() {
  if (!A_IsAdmin) {
    cmd := DllCall("GetCommandLine", "str")
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
  A_TrayMenu.Delete()
  A_TrayMenu.Add("控制面板", p.ControlPanel.Bind(p))
  A_TrayMenu.Default := "控制面板"
  A_TrayMenu.Add("刷取统计", p.StatisticsPanel.Bind(p))
  A_TrayMenu.Add()
  A_TrayMenu.Add("前往仓库", (*) => Run('https://gitee.com/UCPr251/zzzAuto') || (p.CP ? p.CP.destroyGui() : 0))
  A_TrayMenu.Add("检查更新", p.checkUpdate.Bind(p))
  A_TrayMenu.Add()
  A_TrayMenu.Add("重启", (*) => Reload())
  A_TrayMenu.Add("退出", (*) => ExitApp())
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
    stepLog("【开始】模式：角色操作界面")
  } else {
    stepLog("【开始】模式：零号空洞主页")
  }
  RandomSleep()
  if (mode = 1) {
    if (!charOperation()) {
      Ctrl.ing := false
      return MsgBox("进入零号空洞主页失败，请手动进入后重试", "错误", "Iconx 0x40000")
    }
  }
  runAutoZZZ()
}

/** 出现异常后重试 */
retry(reason) {
  if (!setting.errHandler) {
    throw Error(reason)
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
  if (errTimes > setting.retryTimes) {
    Ctrl.stop()
    return MsgBox("【错误】异常重试次数过多，脚本结束" getErrorMsg(), "错误", "Iconx 0x40000")
  }
  MsgBox("【错误】连续刷取过程中出现异常：`n" reason "`n`n将在6s后重试", "错误", "Iconx T6 0x40000")
  RandomSleep()
  mode := 0
  ; 卡在空洞走格子界面
  uc:
  loop (5) {
    Press('Space', 2)
    if (PixelSearchPre(&X, &Y, c.空洞.确认*)) { ; 确认？
      SimulateClick(X, Y)
      RandomSleep(1800, 2000)
    }
    Press('Space', 2)
    MingHui(true, 5) ; 铭徽？
    Sleep(200)
    Press('Space', 2)
    Press('Escape') ; 尝试退出或退出页面
    RandomSleep(700, 800)
    if (PixelSearchPre(&X, &Y, c.空洞.退出副本.放弃*)) {
      SimulateClick(X, Y)
      RandomSleep(700, 800)
      loop (5) {
        if (PixelSearchPre(&X, &Y, c.空洞.退出副本.确认*)) {
          SimulateClick(X, Y, 2)
          RandomSleep(6400, 6500)
          pixelSearchAndClick(c.空洞.结算.完成*)
          RandomSleep(5600, 5800)
          mode := recogLocation()
          if (mode)
            break uc
        }
        Sleep(100)
      }
    }
  }
  ; 卡在战斗结算界面
  if (!mode) {
    if (PixelSearchPre(&X, &Y, c.空洞.1.战斗.确定绿勾*)) {
      SimulateClick(X, Y, 2)
      RandomSleep(500, 600)
      MingHui()
      RandomSleep(7500, 8000)
      exitFuben()
      RandomSleep(800, 1000)
      pixelSearchAndClick(c.空洞.结算.完成*)
      RandomSleep(5600, 5800)
      mode := recogLocation()
    }
  }
  ; 卡在副本结算界面
  if (!mode) {
    if (PixelSearchPre(&X, &Y, c.空洞.结算.完成*)) {
      SimulateClick(X, Y, 2)
      RandomSleep(5600, 5800)
    }
  }
  Sleep(251)
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
  Ctrl.start()
  status := 0
  step := 0
  ; 进入副本
  enterFuben(++step)
  ; 拒绝好意
  refuse(++step)
  ; 前往终点
  status := reachEnd(++step)
  if (status = 0) {
    return retry("地图类型识别失败")
  }
  ; 战斗
  status := fight(++step)
  if (status = 0) {
    return retry("战斗超时或检测异常")
  }
  ; 选择增益
  status := choose(++step)
  if (status = 0) {
    return retry("未找到对应增益选项")
  }
  gainMode := setting.gainMode
  ; 全都要
  if (gainMode = 0) {
    getMoney(++step)
    saveBank(++step, gainMode)
    ; 只要业绩
  } else if (gainMode = 1) {
    getMoney(++step)
    ; 只存银行
  } else if (gainMode = 2) {
    saveBank(++step, gainMode)
  }
  ; 退出副本
  exitFuben(++step)
  Ctrl.finish()
  ; 本轮结束
  if (Ctrl.nextExit) {
    if (setting.loopMode > 0) {
      setting.loopMode--
    }
    Ctrl.stop()
    return MsgBox("本次刷取已结束。共刷取" setting.statistics.Length "次")
  }
  ; 业绩上限模式
  if (setting.loopMode = 0) {
    ; 判断是否达到上限
    if (isLimited()) { ; 达到上限
      if (setting.isAutoClose) {
        WinClose("ahk_exe ZenlessZoneZero.exe")
      }
      Ctrl.stop()
      return MsgBox("业绩已达周上限，脚本结束。共刷取" setting.statistics.Length "次")
    }
    stepLog("业绩未达周上限，继续刷取。已刷取" setting.statistics.Length "次")
    ; 无限循环模式
  } else if (setting.loopMode = -1) {
    stepLog("无限循环模式。已刷取" setting.statistics.Length "次")
    ; 指定次数模式
  } else {
    setting.loopMode--
    ; 刷取完毕
    if (setting.loopMode = 0) {
      if (setting.isAutoClose) {
        WinClose("ahk_exe ZenlessZoneZero.exe")
      }
      Ctrl.stop()
      return MsgBox("已刷完指定次数，脚本结束。共刷取" setting.statistics.Length "次")
      ; 未刷完
    } else {
      stepLog("指定次数剩余" setting.loopMode "次，继续刷取。已刷取" setting.statistics.Length "次")
    }
  }
  RandomSleep(800, 1000)
  pixelSearchAndClick(c.空洞.结算.完成*)
  while (recogLocation() != 2) {
    Sleep(100)
  }
  ; 继续循环
  runAutoZZZ()
}