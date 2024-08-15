/************************************************************************
 * @description 绝区零零号空洞零号业绩自动刷取、自动银行存款脚本
 * @file 零号业绩.ahk
 * @author UCPr
 * @date 2024/08/16
 * @version v1.5.0
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

/** 设置项 */
global setting := {
  /** 休眠系数，加载动画等待时长在原基础上的倍率，可通过修改该值延长/缩短全局等待时长 */
  sleepCoefficient: 1.0,
  /** RGB颜色搜索允许的渐变值 */
  variation: 60,
  /** 是否开启调试日志信息输出 */
  isDebugLog: true,
  /** 刷完业绩后是否自动关闭游戏 */
  autoClose: false,
  /** 是否开启银行模式 */
  bank: false,
  /** 是否存银行 */
  save: true,
  exit: false
}

/** 刷取统计数据 */
global statistics := []

; /** Ctrl+s 保存并重载程序 */
; ~^s:: {
;   if (InStr(WinGetTitle("A"), "Visual Studio Code") && InStr(WinGetTitle("A"), A_ScriptName)) {
;     Send("^s")
;     MsgBox("已自动重载脚本" A_ScriptName, , "T1")
;     Reload()
;   }
; }

/** Alt+Z 运行程序 */
!z:: {
  MsgBox("【开始运行】绝区零零号空洞自动刷取脚本", , "T1")
  main()
}

/** Alt+p 暂停/恢复线程 */
!p:: {
  MsgBox("已" (A_IsPaused ? "恢复" : "暂停") "脚本，再次Alt+P可切换状态", , "T1")
  Pause(-1)
}

/** Alt+C 控制面板 */
!c:: ControlPanel()

/** Alt+T 刷取统计 */
!t:: StatisticsPanel()

/** 控制面板 */
ControlPanel() {
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
  g := Gui('AlwaysOnTop', '零号业绩刷取脚本控制面板Alt+C')
  g.SetFont('s9', '微软雅黑')
  setRatio()
  g.AddText('X72', '分辨率：' A_ScreenWidth "x" A_ScreenHeight "`t模式：" c.mode)
  g.SetFont('s13')
  g.AddText('X30 Y40', '休眠系数：')
  g.AddEdit('X+10 w60 Limit4', setting.sleepCoefficient).OnEvent('Change', changeSleepCoefficient)
  g.AddText('X30 Y80', '颜色搜索允许渐变值：')
  g.AddEdit('X+10 w60 Limit3 Number').OnEvent('Change', changeVariation)
  g.AddUpDown('H30 Range0-255', setting.variation).OnEvent('Change', changeVariation)
  g.AddCheckBox('visDebugLog X30 Checked' setting.isDebugLog, '调试日志弹窗').OnEvent('Click', switchSetting)
  g.AddCheckBox('vautoClose Checked' setting.autoClose, '刷完业绩自动关闭游戏').OnEvent('Click', switchSetting)
  g.AddCheckBox('vbank Checked' setting.bank, '银行模式（无限循环刷取）').OnEvent('Click', switchSetting)
  g.AddCheckBox('vsave Checked' setting.save, '银行存款（关闭后不再存银行）').OnEvent('Click', switchSetting)
  g.SetFont('s9')
  g.AddText('X20 Y+10', '其他：Alt+Z: 开始刷取 Alt+P: 暂停/恢复 Alt+T: 刷取统计')
  g.SetFont('s12')
  g.AddButton('X15 Y+15', '退出').OnEvent('Click', quit)
  g.AddButton('X+5', '重启').OnEvent('Click', (*) => Reload())
  g.AddButton('X+5', paused ? '取消暂停' : '暂停刷取').OnEvent('Click', pauseS)
  g.AddButton('X+5', setting.exit ? '取消结束' : '结束刷取').OnEvent('Click', end)
  g.AddButton('X+5 Default', '确定').OnEvent('Click', destroyGui)
  g.Show()
  g.OnEvent('Close', destroyGui)
  g.OnEvent('Escape', destroyGui)

  destroyGui(*) {
    g.Destroy()
    if (!paused)
      Pause(0)
    g := 0
  }

  switchSetting(g, *) {
    global setting
    setting.%g.Name% := !setting.%g.Name%
  }

  changeVariation(g, *) {
    value := g.Value
    if (value >= 0 && value <= 255) {
      setting.variation := value
    } else {
      MsgBox('颜色搜索允许渐变值须介于0-255', '错误', 'Iconx 0x40000')
    }
  }

  changeSleepCoefficient(g, *) {
    value := g.Value
    if (IsNumber(value)) {
      setting.sleepCoefficient := Round(value, 2)
    } else {
      MsgBox('休眠系数必须为数字类型', '错误', 'Iconx 0x40000')
    }
  }

  quit(*) {
    result := MsgBox("确认关闭零号业绩自动刷取脚本？Y/N", , "0x1 0x40000")
    if (result = "OK") {
      ExitApp()
    }
  }

  pauseS(g, *) {
    if (!ing) {
      return MsgBox("当前未处于刷取期间", , "Icon! 0x40000")
    }
    if (paused) {
      Pause(0)
      g.Text := "暂停刷取"
    } else {
      Pause(1)
      g.Text := "取消暂停"
    }
    paused := !paused
  }

  end(g, *) {
    if (!ing) {
      return MsgBox("当前未处于刷取期间", , "Icon! 0x40000")
    }
    global setting
    setting.exit := !setting.exit
    if (setting.exit) {
      MsgBox("将在当前执行的步骤完成后结束本次刷取`n再次启动：Alt+Z", , "0x40000")
      g.Text := "取消结束"
    } else {
      g.Text := "结束刷取"
    }
  }

}

/** 刷取统计 */
StatisticsPanel() {
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
  g.OnEvent("Close", destroyGui)
  g.OnEvent("Escape", destroyGui)
  destroyGui(*) {
    g.Destroy()
    if (!paused)
      Pause(0)
    g := 0
  }
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
  setRatio()
  MsgBox("`t`t绝区零零号空洞自动刷取脚本`n`n使用方法：`n`n    Alt+Z ：启动脚本（默认情况下会循环刷取直至零号业绩达到周上限）`n    Alt+T ：查看/关闭刷取统计`n    Alt+P ：暂停/恢复脚本`n    Alt+C ：打开/关闭控制面板`n`n仓库地址 ：https://github.com/UCPr251/zzzAuto", "UCPr", "0x40000")
  ControlPanel()
}

init()

/** 开始，检测所在页面 */
main() {
  setRatio()
  activateZZZ()
  WinGetClientPos(, , &w, &h, "ahk_exe ZenlessZoneZero.exe")
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
    global ing := false
    return MsgBox("【错误】异常次数过多，脚本结束" getErrorMsg(), "错误", "Iconx 0x40000")
  }
  MsgBox("【错误】连续刷取过程中出现异常：`n" reason "`n`n将在6s后重试", "错误", "Iconx T6")
  RandomSleep()
  ; 如果有确认框或选择框
  loop (3) {
    if (PixelSearchPre(&X, &Y, c.空洞.确定*)) {
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

global ing := false

/** 运行刷取脚本 */
runAutoZZZ() {
  global ing := true
  judgeExit()
  ; 时长统计
  start := A_Now
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
  if (setting.save) {
    saveBank()
    judgeExit()
  }
  ; 退出副本
  exitFuben()
  judgeExit()
  end := A_Now
  statistics.Push(DateDiff(end, start, "s"))
  if (setting.bank) {
    debugLog("银行模式，无限循环。已刷取" statistics.Length "次")
  } else {
    ; 判断是否达到上限
    if (isLimited()) {
      judgeExit()
      if (setting.autoClose) {
        WinClose("ahk_exe ZenlessZoneZero.exe")
      }
      global ing := false
      return MsgBox("已达到周上限，脚本结束。共刷取" statistics.Length "次")
    }
    debugLog("未达到周上限，继续刷取。已刷取" statistics.Length "次")
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
  if (setting.exit) {
    setting.exit := false
    global ing := false
    MsgBox("已结束当前刷取线程", , "0x40000")
    Exit()
  }
}