/************************************************************************
 * @description 绝区零零号空洞零号业绩自动刷取、自动银行存款脚本
 * @file 零号业绩.ahk
 * @author UCPr
 * @date 2025/3/23
 * @version v2.2.3
 * @link https://github.com/UCPr251/zzzAuto
 * @warning 请勿用于任何商业用途，仅供学习交流使用
 ***********************************************************************/
#Requires AutoHotkey v2
#SingleInstance Force
#WinActivateForce
SetWorkingDir(A_ScriptDir)
CoordMode("Mouse", "Client")
CoordMode("Pixel", "Client")
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
#Include choose.ahk
#Include enterHollowZero.ahk
#Include enterFuben.ahk
#Include exitFuben.ahk
#Include fight.ahk
#Include getMoney.ahk
#Include isLimited.ahk
#Include reachEnd.ahk
#Include recogLocation.ahk
#Include refuse.ahk
#Include saveBank.ahk
#Include enterDennyFuben.ahk
#Include getDenny.ahk
#Include enterHDD.ahk

global Version := "v2.2.3"
global ZZZ := "ahk_exe ZenlessZoneZero.exe"

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
  A_TrayMenu.Add("前往仓库", (*) => Run('https://github.com/UCPr251/zzzAuto') || (p.CP && p.CP.destroyGui()))
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
    MsgBox("警告：`n当前显示模式分辨率" c.width "x" c.height "无内置数据`n将使用" c.mode "的分辨率比例数据进行缩放兼容处理`n`n若无法正常运行，请更改游戏显示模式，如1920*1080", "警告", "Icon! 0x40000")
  }
  if (setting.isFirst('Start')) {
    MsgBox("`t`t绝区零自动刷取`n`n支持界面：窗口、全屏`n支持刷取：拿命验收、零号业绩、零号银行`n`n使用方法 ：`n`tAlt+P ：暂停/恢复脚本`n`tAlt+C ：打开/关闭控制面板`n`n当前版本 ：" Version "`n仓库地址 ：https://github.com/UCPr251/zzzAuto", "UCPr", "0x40000")
  }
  p.ControlPanel()
}

/** 开始，检测所在页面 */
main() {
  c.reset()
  Ctrl.stop() ; 重置
  Ctrl.ing := true
  isYeJi := setting.mode = 'YeJi'
  page := recogLocation()
  switch (page) {
    case 0: ; 未知界面
    {
      Ctrl.ing := false
      if (isYeJi) {
        return MsgBox("请位于 <零号空洞主页> 或 <角色操作界面> 重试", "错误", "Iconx 0x40000")
      } else {
        return MsgBox("请位于 <HDD第二章间章战斗委托关卡选择界面> 或 <角色操作界面> 重试", "错误", "Iconx 0x40000")
      }
    }
    case 1:
    {
      stepLog("【开始】界面：角色操作界面")
    }
    case 2:
    {
      stepLog("【开始】界面：零号空洞主页")
      if (!isYeJi) {
        loop (2) {
          Press('Escape')
          RandomSleep(1100, 1200)
        }
      }
    }
    case 3:
    {
      stepLog("【开始】界面：HDD关卡选择界面")
      if (isYeJi) {
        loop (2) {
          Press('Escape')
          RandomSleep(1100, 1200)
        }
      }
    }
  }
  runAutoZZZ()
}

/** 出现异常后重试 */
retry(reason?) {
  static errReasons := []
  static getErrorMsg() {
    if (!errReasons.Length) {
      return "无历史异常"
    }
    errMsg := "历史异常："
    loop (errReasons.Length) {
      err := errReasons[A_Index]
      errMsg .= "`n异常" A_Index "：[" err.time "] " err.reason
    }
    return errMsg
  }
  if (!IsSet(reason) || !reason) {
    return getErrorMsg()
  }
  isYeJi := setting.mode = 'YeJi'
  if (!setting.errHandler || ((isYeJi ? setting.statistics : setting.statisticsDenny).Length = 0)) {
    throw Error(reason)
  }
  errReasons.Push({ time: FormatTime(A_Now, "HH:mm:ss"), reason: reason })
  setting.retryTimes--
  if (setting.retryTimes < 0) {
    Ctrl.stop()
    errReasons := []
    setting.retryTimes := setting.oriSetting.retryTimes
    return MsgBox("【错误】异常重试次数过多，脚本结束`n" getErrorMsg(), "错误", "Iconx 0x40000")
  }
  MsgBox("【错误】连续刷取过程中出现异常：`n" reason "`n`n将在3s后重试", "错误", "Iconx T3 0x40000")
  RandomSleep()
  page := 0
  ; 卡在空洞走格子、交互、确认界面，子界面
  UC:
  loop (6) {
    Press('Space', 2)
    if (PixelSearchPre(&X, &Y, c.空洞.确认*)) { ; 确认？
      SimulateClick(X, Y)
      RandomSleep(1800, 2000)
    }
    SimulateClick(1, 1) ; 点击？
    Press('Space', 3) ; 交互？
    if (isYeJi)
      MingHui(true, 5) ; 铭徽？
    Press(1, 3) ; 选项？
    Sleep(200)
    Press('Space', 3)
    page := recogLocation(5)
    if (page = 1) {
      break
    } else if (page = 2 || page = 3) {
      loop (2) {
        Press('Escape')
        RandomSleep(1100, 1200)
      }
      return runAutoZZZ()
    }
    Press('Escape')
    RandomSleep(1300, 1500)
    ; 副本内
    if (PixelSearchPre(&X, &Y, c.空洞.退出副本.放弃*)) {
      SimulateClick(X, Y)
      RandomSleep(700, 800)
      loop (5) {
        if (PixelSearchPre(&X, &Y, c.空洞.退出副本.确认*)) {
          SimulateClick(X, Y, 2)
          RandomSleep(6400, 6500)
          pixelSearchAndClick(c.空洞.结算.完成*)
          RandomSleep(5600, 5800)
          page := recogLocation()
          if (page)
            break UC
        }
        Sleep(100)
      }
    }
    ; 确认界面
    if (PixelSearchPre(&X, &Y, c.空洞.1.战斗.确定绿勾*)) {
      SimulateClick(X, Y, 2)
      RandomSleep(500, 600)
      if (isYeJi) {
        MingHui()
        RandomSleep(7500, 8000)
        exitFuben()
        RandomSleep(800, 1000)
        pixelSearchAndClick(c.空洞.结算.完成*)
        RandomSleep(5600, 5800)
      }
    }
    ; 副本结算界面
    if (PixelSearchPre(&X, &Y, c.空洞.结算.完成*)) {
      SimulateClick(X, Y, 2)
      RandomSleep(5600, 5800)
    }
  }
  Sleep(251)
  ; 重新识别所处界面
  page := recogLocation()
  if (page = 1) {
    return runAutoZZZ()
  } else if (page = 2 || page = 3) {
    loop (2) {
      Press('Escape')
      RandomSleep(1100, 1200)
    }
    return runAutoZZZ()
  }
  try {
    if (RestartGame()) {
      runAutoZZZ()
    } else {
      throw Error("重启游戏执行失败")
    }
  } catch Error as e {
    Ctrl.stop()
    errReasons := []
    MsgBox("【重启失败】异常重启游戏失败，脚本结束`n重启失败原因：" e.Message "`n重启原因：" reason "`n异常总次数：" errReasons.Length "`n`n" getErrorMsg(), "错误", "Iconx 0x40000")
  }
}

RestartGame(GamePath := setting.GamePath) {
  if (!IsSet(GamePath) || !GamePath || !FileExist(GamePath)) {
    if (!WinExist(ZZZ))
      return false
    GamePath := WinGetProcessPath(ZZZ)
    setting.GamePath := GamePath
  }
  if (WinExist(ZZZ)) {
    WinClose(ZZZ)
    Sleep(1000)
    while (WinExist(ZZZ)) {
      Sleep(1000)
    }
    Sleep(6000)
  }
  Run(GamePath)
  Sleep(3000)
  while (!WinExist(ZZZ)) {
    if (A_Index > 100)
      throw Error("重启游戏失败：等待游戏启动超时")
    Sleep(251)
  }
  Sleep(8000)
  c.reset()
  loop (3) {
    while (recogLocation(10) != 1) {
      if (A_Index > 20)
        throw Error("重启游戏失败：等待进入角色操作界面超时")
      if (PixelSearchPre(&X, &Y, c.角色操作.取消正在处理*)) {
        SimulateClick(X, Y)
      } else {
        SimulateClick(c.width // 2, c.height // 2)
      }
      Sleep(1000)
    }
    Sleep(1000)
    if (recogLocation(10) = 1) {
      return true
    }
  }
  return false
}

/** 运行刷取脚本 */
runAutoZZZ() {
  switch (setting.mode) {
    case 'YeJi':
      YeJi()
    case 'Denny':
      Denny()
    default:
      YeJi()
  }
}

/** 业绩模式 */
YeJi() {
  static limited := 0
  page := recogLocation()
  if (page = 1) {
    if (!enterHollowZero()) {
      return retry("进入零号空洞主页失败")
    }
  } else if (page != 2) {
    return retry("未找到零号空洞主页")
  }
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
  ; 空洞丁尼模式打完第一层直接退出副本
  if (setting.subLoopMode != 1) {
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
  while (!PixelSearchPre(&X, &Y, c.空洞.结算.完成*)) {
    Sleep(251)
    if (A_Index > 50)
      return retry("等待结算完毕超时")
  }
  ; 业绩上限模式
  if (setting.loopMode = 0) {
    ; 判断是否达到上限
    if (isLimited()) { ; 达到上限
      limited++
      if (limited >= 2) { ; 连续两次判断为已达上限
        limited := 0
        if (setting.subLoopMode = 2) { ; 全部上限模式，业绩达上限时自动切换丁尼上限模式
          setting.subLoopMode := 1
        } else {
          Ctrl.stop()
          msg := (setting.subLoopMode = 1 ? "丁尼" : "业绩") "已达周上限，脚本结束。共刷取" setting.statistics.Length "次"
          if (setting.isAutoClose) {
            WinClose(ZZZ)
            if (setting.isAutoClose = 2) {
              return ShutdownPC(msg)
            }
          }
          return MsgBox(msg)
        }
      }
    } else {
      limited := 0
    }
    stepLog((setting.subLoopMode = 1 ? "丁尼" : "业绩") "未达周上限，继续刷取。已刷取" setting.statistics.Length "次")
    ; 无限循环模式
  } else if (setting.loopMode = -1) {
    stepLog("无限循环模式。已刷取" setting.statistics.Length "次")
    ; 指定次数模式
  } else {
    setting.loopMode--
    ; 刷取完毕
    if (setting.loopMode = 0) {
      if (setting.isAutoClose) {
        WinClose(ZZZ)
      }
      Ctrl.stop()
      return MsgBox("已刷完指定次数，脚本结束。共刷取" setting.statistics.Length "次")
      ; 未刷完
    } else {
      stepLog("指定次数剩余" setting.loopMode "次，继续刷取。已刷取" setting.statistics.Length "次")
    }
  }
  RandomSleep(888, 1000)
  pixelSearchAndClick(c.空洞.结算.完成*)
  SimulateClick(, , 3)
  while (recogLocation(10) != 2) {
    if (A_Index < 3) {
      if (PixelSearchPre(&X, &Y, c.空洞.结算.完成*)) {
        SimulateClick(X, Y)
      }
    }
    if (A_Index > 10)
      break
    Sleep(200)
  }
  Sleep(100)
  YeJi()
}

/** 丁尼模式 */
Denny() {
  static limited := 0
  status := 0
  step := 0
  page := recogLocation(40)
  if (page = 0) { ; 休息
    Press('Space', 2)
    while (not page := recogLocation(3)) {
      Press('Space', 2)
      if (A_Index > 20)
        return retry("确认休息进入角色操作界面超时")
    }
  }
  if (page = 1 || recogLocation() = 1) {
    RandomSleep(300, 320)
    status := enterHDD(++step)
    if (!status) {
      return retry("进入HDD界面失败")
    }
    SimulateClick(c.width // 2, c.height * 7 // 10, 3) ; 进入战斗委托
    RandomSleep(251, 300)
  }
  if (recogLocation() != 3) {
    return retry("未找到HDD关卡选择界面")
  }
  RandomSleep()
  Ctrl.start()
  enterDennyFuben(++step)
  status := getDenny(++step)
  if (!status) {
    return retry("丁尼副本刷取重试次数过多")
  }
  Ctrl.finish()
  RandomSleep(2000, 2200)
  ; 本轮结束
  if (Ctrl.nextExit) {
    if (setting.loopModeDenny > 0) {
      setting.loopModeDenny--
    }
    Ctrl.stop()
    return MsgBox("本次刷取已结束。共刷取" setting.statisticsDenny.Length "次")
  }
  while (!PixelSearchPre(&X, &Y, c.空洞.结算.完成*)) {
    Sleep(251)
    if (A_Index > 50)
      return retry("等待结算完毕超时")
  }
  ; 丁尼上限模式
  if (setting.loopModeDenny = 0) {
    if (isLimited()) { ; 已达到上限
      limited++
      if (limited >= 2) { ; 连续两次判断为已达上限
        limited := 0
        Ctrl.stop()
        msg := "丁尼已达日上限，脚本结束。共刷取" setting.statisticsDenny.Length "次"
        if (setting.isAutoClose) {
          WinClose(ZZZ)
          if (setting.isAutoClose = 2) {
            return ShutdownPC(msg)
          }
        }
        return MsgBox(msg)
      }
    } else {
      limited := 0
    }
    stepLog("丁尼未达日上限，继续刷取。已刷取" setting.statisticsDenny.Length "次")
    ; 无限循环模式
  } else if (setting.loopModeDenny = -1) {
    stepLog("无限循环模式。已刷取" setting.statisticsDenny.Length "次")
    ; 指定次数模式
  } else {
    setting.loopModeDenny--
    ; 刷取完毕
    if (setting.loopModeDenny = 0) {
      if (setting.isAutoClose) {
        WinClose(ZZZ)
      }
      Ctrl.stop()
      return MsgBox("已刷完指定次数，脚本结束。共刷取" setting.statisticsDenny.Length "次")
      ; 未刷完
    } else {
      stepLog("指定次数剩余" setting.loopModeDenny "次，继续刷取。已刷取" setting.statisticsDenny.Length "次")
    }
  }
  RandomSleep(500, 600)
  pixelSearchAndClick(c.空洞.结算.完成*)
  SimulateClick(, , 3)
  loop (3) {
    if (PixelSearchPre(&X, &Y, c.空洞.结算.完成*)) {
      SimulateClick(X, Y)
      Sleep(1000)
    }
  }
  Denny()
}

ShutdownPC(msg := '', Code := 1) {
  r := MsgBox(msg '`n`n将在12s后自动关机，点击取消可取消关机', '刷取完毕自动关机', 'Icon! T12 OC Default2')
  if (r != 'Cancel') {
    Shutdown(Code)
  }
}