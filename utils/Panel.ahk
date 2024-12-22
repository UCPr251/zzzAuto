/** 面板 */
class Panel {

  __New() {
    this.CP := 0
    this.SP := 0
    this.UP := 0
    this.sum := 0
    this.detail := []
    this.fightSum := 0
    this.sumDenny := 0
    this.detailDenny := []
    this.general := ""
    this.paused := false
    this.CPLastPos := 0
    this.SPLastPos := 0
    this.init()
  }

  /** 控制面板 */
  ControlPanel(*) {
    if (this.CP) {
      return destroyGui()
    }
    if (Ctrl.ing) {
      this.paused := A_IsPaused
      Pause(1)
    } else {
      this.paused := false
    }
    A_TrayMenu.Check('控制面板')
    isYeJi := setting.mode = 'YeJi'

    this.CP := Gui('AlwaysOnTop -MinimizeBox', '零号业绩控制面板 ' Version)
    this.CP.destroyGui := destroyGui
    this.CP.SetFont('s9', '微软雅黑')
    this.CP.MarginX := 15
    this.CP.AddText('X62 w251', '分辨率：' c.width "x" c.height "   模式：" c.mode (c.compatible ? (c.windowed ? " (窗口兼容)" : " (全屏兼容)") : (c.windowed ? " (窗口)" : " (全屏)")))
    this.CP.SetFont('s13')

    this.CP.AddText('X30 Y40', '休眠系数：')
    EG := this.CP.AddEdit('X+10 w60 h25 Limit4', setting.sleepCoefficient)
    EG.OnEvent('Change', changeSleepCoefficient)
    this.CP.AddUpDown('-2', setting.sleepCoefficient).OnEvent('Change', UpDownChange)

    this.CP.AddText('X30', '异常重试次数：').OnEvent('DoubleClick', (*) => MsgBox(retry(), '历史异常', '0x40000'))
    this.CP.AddEdit('X+10 w48 h25 Limit2 Number').OnEvent('Change', changeRetryTimes)
    this.CP.AddUpDown('Range0-99', setting.retryTimes).OnEvent('Change', changeRetryTimes)

    this.CP.AddText('X30', '颜色搜索允许RGB容差：')
    this.CP.AddEdit('X+10 w60 h25 Limit3 Number').OnEvent('Change', changeVariation)
    this.CP.AddUpDown('Range0-255', setting.variation).OnEvent('Change', changeVariation)

    this.CP.AddButton('X15 w320 h30', '切换至' (isYeJi ? '丁尼' : '业绩') '模式').OnEvent('Click', switchMode)

    if (isYeJi) {
      this.CP.AddText('X30', '使用炸弹：')
      this.CP.AddRadio('X+5 Checked' (setting.bombMode = 1), '长按').OnEvent('Click', (*) => setting.bombMode := 1)
      this.CP.AddRadio('X+5 Checked' (setting.bombMode = 2), '点击').OnEvent('Click', (*) => setting.bombMode := 2)

      this.CP.AddText('X30', '快捷手册：')
      this.CP.AddHotkey('X+10 w60 h25 Limit14', setting.handbook).OnEvent('Change', changeHandbook)

      ; this.CP.AddText('X30 Y+10 w286 h1 BackgroundGray')

      this.CP.AddText('X30', '战斗模式：')
      this.CP.AddDropDownList("X+10 W80 Choose" setting.fightMode, setting.fightModeArr).OnEvent("Change", (g, *) => setting.fightMode := Integer(g.Value))

      this.CP.AddText('X30', '刷取模式：')
      this.CP.SetFont('s10')
      this.CP.AddRadio('X50 Y+10 vgain0 Checked' (setting.gainMode = 0), '我全都要').OnEvent('Click', gainModeSelected)
      this.CP.AddRadio('X+2 vgain1 Checked' (setting.gainMode = 1), '只要业绩').OnEvent('Click', gainModeSelected)
      this.CP.AddRadio('X+2 vgain2 Checked' (setting.gainMode = 2), '只存银行').OnEvent('Click', gainModeSelected)
    } else {
      this.CP.AddText('X30', '二号位角色：')
      this.CP.AddDropDownList("X+10 W80 Choose" setting.fightModeDenny, setting.fightModeArr).OnEvent("Change", (g, *) => setting.fightModeDenny := Integer(g.Value))

      this.CP.AddText('X30', '视角转动值：')
      this.CP.AddEdit('X+10 w80 h25 Limit3 Number').OnEvent('Change', changeRotateCoords)
      this.CP.AddUpDown('Range0-9999', setting.rotateCoords).OnEvent('Change', changeRotateCoords)
    }

    this.CP.SetFont('s13')
    this.CP.AddText('X30', '循环模式：')
    this.CP.SetFont('s10')
    nowLoopMode := isYeJi ? setting.loopMode : setting.loopModeDenny
    this.CP.AddRadio('X50 Y+10 vloop0 Checked' (nowLoopMode = 0), (isYeJi ? '业绩' : '丁尼') '上限').OnEvent('Click', loopModeSelected)
    this.CP.AddRadio('X+2 vloop-1 Checked' (nowLoopMode = -1), '无限循环').OnEvent('Click', loopModeSelected)
    this.CP.AddRadio('X+2 vloopN Checked' (nowLoopMode > 0), '指定次数').OnEvent('Click', loopModeSelected)
    this.loopEditGui := this.CP.AddEdit('X+0 w45 h20 Number Limit3 Hidden' (nowLoopMode <= 0), nowLoopMode > 0 ? nowLoopMode : isYeJi ? 50 : 99)
    this.loopEditGui.OnEvent('Change', changeLoopMode)
    this.loopUpDownGui := this.CP.AddUpDown('Range1-999 Hidden' (nowLoopMode <= 0), nowLoopMode > 0 ? nowLoopMode : isYeJi ? 50 : 99)
    this.loopUpDownGui.OnEvent('Change', changeLoopMode)

    ; this.CP.AddText('X30 Y+10 w286 h1 BackgroundGray')

    this.CP.SetFont('s13')
    this.CP.AddCheckBox('verrHandler X30 Checked' setting.errHandler, '异常处理').OnEvent('Click', switchSetting)
    this.CP.AddCheckBox('visStepLog Checked' setting.isStepLog, '步骤信息弹窗').OnEvent('Click', switchSetting)
    this.CP.AddCheckBox('visAutoClose Checked' setting.isAutoClose, '刷完关闭游戏').OnEvent('Click', switchSetting)
    if (isYeJi)
      this.CP.AddCheckBox('visAutoDodge Checked' setting.isAutoDodge, '战斗红光自动闪避').OnEvent('Click', switchSetting)

    this.CP.SetFont('s12')
    this.CP.AddButton('X15 Y+15 w75', '&Q 退出').OnEvent('Click', (*) => ExitApp())
    this.CP.AddButton('X+5 w75', '&R 重启').OnEvent('Click', (*) => Reload())
    this.CP.pauseButton := this.CP.AddButton('X+5 w75', '&P ' (this.paused ? '继续' : '暂停'))
    this.CP.pauseButton.OnEvent('Click', pauseS)
    this.CP.AddButton('X+5 Default w75', '&C 确定').OnEvent('Click', destroyGui)
    this.CP.AddButton('X15 Y+10 w100', '&U 检查更新').OnEvent('Click', this.checkUpdate.Bind(this))
    this.CP.AddButton('X+8 w100', '&T 刷取统计').OnEvent('Click', this.StatisticsPanel.Bind(this))
    this.CP.AddButton('X+8 w100', '&Z ' (Ctrl.ing ? (Ctrl.nextExit ? '取消结束' : '本轮结束') : '开始刷取')).OnEvent('Click', start)
    this.CP.AddStatusBar(, '`tAlt+字母 = 点击按钮')

    if (this.CPLastPos) {
      this.CP.Show('Hide')
      this.CP.Move(this.CPLastPos*)
      this.CP.Show()
      this.CPLastPos := 0
    } else {
      this.CP.Show()
    }

    this.CP.OnEvent('Close', destroyGui)
    this.CP.OnEvent('Escape', destroyGui)

    lastUpDownValue := 1
    UpDownChange(g, *) {
      if (g.value < lastUpDownValue || (g.value = lastUpDownValue && (g.value = -1 || g.value = 0))) {
        newValue := Round(EG.Value - 0.01, 2)
      } else {
        newValue := Round(EG.Value + 0.01, 2)
      }
      if (newValue < 0) {
        newValue := 1.00
      } else if (newValue > 10) {
        newValue := 10.00
      }
      setting.sleepCoefficient := EG.Value := newValue
      lastUpDownValue := g.value
    }

    static destroyGui(*) {
      A_TrayMenu.Uncheck('控制面板')
      if (!p.paused) {
        Pause(0)
      }
      if (p.CP) {
        if (!p.CPLastPos) {
          p.CP.GetPos(&x, &y)
          p.CPLastPos := [x * 96 / A_ScreenDPI, y * 96 / A_ScreenDPI]
        }
        p.CP.Destroy()
        p.CP := 0
      }
      if (p.SP) {
        p.SP.destroyGui()
      }
      if (p.UP) {
        p.UP.destroyGui()
      }
    }

    static switchSetting(g, *) {
      setting.%g.Name% := !setting.%g.Name%
    }

    static changeHandbook(g, *) {
      value := g.Value
      if (value) {
        if (Instr(value, '^!') || StrLen(value) > 2) {
          g.Value := setting.handbook
        } else {
          setting.handbook := value
        }
      } else {
        g.Value := setting.handbook
      }
    }

    static loopModeSelected(g, *) {
      name := StrReplace(g.Name, 'loop', '')
      key := setting.mode = 'YeJi' ? 'loopMode' : 'loopModeDenny'
      if (name = '0') {
        setting.%key% := 0
      } else if (name = '-1') {
        setting.%key% := -1
      }
      if (name = 'N') {
        value := setting.mode = 'YeJi' ? 30 : 650
        setting.%key% := value
        p.loopEditGui.Value := value
        p.loopEditGui.Visible := true
        p.loopUpDownGui.Visible := true
      } else {
        p.loopEditGui.Visible := false
        p.loopUpDownGui.Visible := false
      }
    }

    static gainModeSelected(g, *) {
      setting.gainMode := Integer(StrReplace(g.Name, 'gain', ''))
    }

    static changeLoopMode(g, *) {
      value := g.Value
      if (IsInteger(value) && value >= 1) {
        if (setting.mode = 'YeJi') {
          setting.loopMode := Integer(value)
        } else {
          setting.loopModeDenny := Integer(value)
        }
      }
    }

    static changeVariation(g, *) {
      value := g.Value
      if (IsInteger(value)) {
        if (value >= 0 && value <= 255) {
          setting.variation := Integer(value)
        } else {
          MsgBox('颜色搜索允许渐变值须介于0~255', '错误', 'Iconx 0x40000')
          g.Value := setting.variation
        }
      }
    }

    static changeRotateCoords(g, *) {
      value := g.Value
      if (IsInteger(value)) {
        setting.rotateCoords := Integer(value)
      }
    }

    static switchMode(*) {
      if (Ctrl.ing)
        return MsgBox("当前正在刷取中，请先结束刷取再切换模式", , "Icon! 0x40000 T3")
      setting.mode := setting.mode = 'YeJi' ? 'Denny' : 'YeJi'
      p.CP.GetPos(&x, &y)
      p.CPLastPos := [x * 96 / A_ScreenDPI, y * 96 / A_ScreenDPI]
      destroyGui()
      if (setting.mode = 'Denny' && setting.isFirst('Denny')) {
        MsgBox('首次使用丁尼模式，请注意：`n`n1、HDD关卡选择界面需提前切换至「间章第二章」`n2、编队首位必须为「比利」`n3、请在副本内调整「视角转动值」以确保对齐NPC`n4、转动效果受游戏帧率设置影响`n5、转动效果存在浮动系正常现象', '丁尼模式注意事项', 'Icon! 0x40000')
      }
      p.ControlPanel()
    }

    static changeRetryTimes(g, *) {
      value := g.Value
      if (IsInteger(value)) {
        if (value >= 0 && value <= 99) {
          setting.retryTimes := Integer(value)
        } else {
          g.Value := setting.retryTimes
        }
      }
    }

    static changeSleepCoefficient(g, *) {
      value := g.Value
      if (IsNumber(value)) {
        setting.sleepCoefficient := Round(value, 2)
      } else {
        MsgBox('休眠系数必须为数字类型', '错误', 'Iconx 0x40000')
        g.Value := setting.sleepCoefficient
      }
    }

    static pauseS(g, *) {
      if (!Ctrl.ing) {
        return MsgBox("当前未处于刷取期间", , "Icon! 0x40000 T3")
      }
      if (p.paused) {
        Pause(0)
        destroyGui()
      } else {
        Pause(1)
        g.Text := "&P 继续"
      }
      p.paused := !p.paused
    }

    static start(g, *) {
      global Ctrl
      if (Ctrl.ing) {
        Ctrl.nextExit := !Ctrl.nextExit
        if (Ctrl.nextExit) {
          g.Text := "&Z 取消结束"
        } else {
          g.Text := "&Z 本轮结束"
        }
      } else {
        if (!WinExist(ZZZ) && setting.GamePath && FileExist(setting.GamePath)) {
          MsgBox('未运行游戏，3s后将尝试自动启动游戏', , 'Icon! 0x40000 T3')
          destroyGui()
          Ctrl.ing := 1
          try {
            RestartGame()
          }
        } else {
          destroyGui()
        }
        activateZZZ()
        main()
      }
    }

  }

  /** 检查更新 */
  checkUpdate(*) {
    if (this.UP) {
      return destroyGui()
    }
    A_TrayMenu.Check('检查更新')

    static urls := ["https://github.com/UCPr251/zzzAuto/releases/latest", "https://gitee.com/UCPr251/zzzAuto/releases/latest"]
    err := 0
    for (url in urls) {
      try {
        hObject := ComObject("WinHttp.WinHttpRequest.5.1")
        hObject.SetTimeouts(1000, 1000, 5000, 5000)
        hObject.Open("GET", url)
        hObject.Send()
        hObject.WaitForResponse()
        text := hObject.responseText
        RegExMatch(text, "v\d+\.\d+\.\d+", &OutputVar)
      } catch Error as e {
        err := e
      }
      if (IsSet(OutputVar) && OutputVar[0]) {
        latestVersion := OutputVar[0]
        if (Version = latestVersion) {
          this.UP := Gui('AlwaysOnTop -MinimizeBox' (this.CP ? ' +Owner' this.CP.Hwnd : ''), '检查更新')
          this.UP.destroyGui := destroyGui
          this.UP.SetFont('s12', '微软雅黑')
          this.UP.AddLink('x60 h25 w251', '当前已是最新版本：<a href="' url '"> ' latestVersion ' </a>').OnEvent('Click', (Ctrl, ID, HREF) => Run(HREF) || destroyGui() || (this.CP ? this.CP.destroyGui() : 0))
          this.UP.Show()
          this.UP.OnEvent('Close', destroyGui)
          this.UP.OnEvent('Escape', destroyGui)
          return
        } else {
          if (this.CP)
            this.CP.destroyGui()
          destroyGui()
          return Run(url)
        }
      }
    }
    if (err) {
      throw err
    } else {
      MsgBox('检查更新失败，请稍后重试', '错误', 'Iconx 0x40000')
    }

    destroyGui(*) {
      A_TrayMenu.Uncheck('检查更新')
      if (this.UP) {
        this.UP.Destroy()
        this.UP := 0
      }
      if (this.SP) {
        this.SP.destroyGui()
      }
    }
  }

  /** 初始化刷取统计数据 */
  init() {
    for (value in setting.statistics) {
      this.newDetail(value.time, value.fightDuration, value.duration)
    }
    for (value in setting.statisticsDenny) {
      this.newDetailDenny(value.time, value.duration)
    }
  }

  newDetail(time, fightDuration, duration) {
    this.sum += duration
    this.fightSum += fightDuration
    this.detail.Push([time, fightDuration = 0 ? '无' : (fightDuration '秒'), (duration // 60) "分" SubStr("0" Mod(duration, 60), -2) "秒"])
  }

  newDetailDenny(time, duration) {
    this.sumDenny += duration
    this.detailDenny.Push([time, (duration // 60) "分" SubStr("0" Mod(duration, 60), -2) "秒"])
  }

  refreshGeneral() {
    isYeJi := setting.mode = 'YeJi'
    if (isYeJi) {
      count := this.detail.Length
      sum := this.sum
    } else {
      count := this.detailDenny.Length
      sum := this.sumDenny
    }
    this.general := "已刷取" count "次"
    this.general .= "`n总计耗时：" (sum // 3600) "小时" Round(Mod(sum, 3600) / 60) "分钟"
    if (count > 0) {
      if (isYeJi) {
        this.general .= "`n平均战斗耗时：" Round(this.fightSum // count) "秒"
      }
      this.general .= "`n平均刷取耗时：" (sum // count // 60) "分" Mod(sum // count, 60) "秒"
    }
  }

  /** 刷取统计 */
  StatisticsPanel(*) {
    if (this.SP) {
      return destroyGui()
    }
    A_TrayMenu.Check('刷取统计')

    isYeJi := setting.mode = 'YeJi'
    if (isYeJi) {
      detail := this.detail
    } else {
      detail := this.detailDenny
    }
    this.SP := Gui("AlwaysOnTop -MinimizeBox" (this.CP ? ' +Owner' this.CP.Hwnd : ''), (isYeJi ? '零号业绩' : '拿命验收') "刷取统计")
    this.SP.destroyGui := destroyGui
    this.SP.changed := 0
    this.SP.SetFont('s13', '微软雅黑')
    this.refreshGeneral()
    this.SP.AddText(, this.general)
    TC := this.SP.AddText('w251', '已选中0项')
    LV := this.SP.AddListView('w' (isYeJi ? '375' : '320') ' Checked Count' detail.Length ' LV0x1 r' Min(16, detail.Length) ' ReadOnly', isYeji ? ["序号", "开始时间", "战斗", "耗时"] : ["序号", "开始时间", "耗时"])
    LV.ModifyCol(1, '55 Integer Center')
    LV.ModifyCol(2, '150 Center')
    if (isYeJi) {
      LV.ModifyCol(3, '60 Center')
      LV.ModifyCol(4, '90 Center')
    } else {
      LV.ModifyCol(3, '90 Center')
    }
    for (item in detail) {
      LV.Add(, A_Index, item*)
    }
    LV.OnEvent('Click', Select)
    width := isYeJi ? 84 : 70
    this.SP.AddButton('w' width, '复位').OnEvent('Click', Reset)
    this.SP.AddButton('x+6 w' width, '反选').OnEvent('Click', InvertSelect)
    this.SP.AddButton('x+6 w' (width + 20), '删除选中').OnEvent('Click', Delete)
    this.SP.AddButton('x+6 w' width ' Default', '确定').OnEvent('Click', destroyGui)
    if (this.SPLastPos) {
      this.SP.Show('Hide')
      this.SP.Move(this.SPLastPos*)
      this.SP.Show()
      this.SPLastPos := 0
    } else {
      this.SP.Show()
    }

    this.SP.OnEvent("Close", destroyGui)
    this.SP.OnEvent("Escape", destroyGui)

    destroyGui(*) {
      A_TrayMenu.Uncheck('刷取统计')
      if (this.SP) {
        if (this.SP.changed) {
          ; 处理稀疏数组
          newStatistics := []
          statisticsKey := isYeJi ? 'statistics' : 'statisticsDenny'
          for (item in setting.%statisticsKey%) {
            if (IsSet(item) && item.time && item.duration) {
              newStatistics.Push(item)
            }
          }
          setting.%statisticsKey% := newStatistics
          if (isYeJi) {
            setting.SaveStatistics()
          } else {
            setting.SaveStatisticsDenny()
          }
          newDetail := []
          detailKey := isYeJi ? 'detail' : 'detailDenny'
          for (item in this.%detailKey%) {
            if (IsSet(item) && item[1] && item[2]) {
              newDetail.Push(item)
            }
          }
          this.%detailKey% := newDetail
        }
        this.SP.Destroy()
        this.SP := 0
      }
    }

    Select(g, item, *) {
      if (!item) {
        return
      }
      ItemState := SendMessage(0x102C, item - 1, 0xF000, LV)
      IsChecked := (ItemState >> 12) - 1
      LV.Modify(item, (IsChecked ? '-' : '') "Check")
      RefreshCheckedNumber()
    }

    Reset(*) {
      loop (detail.Length) {
        LV.Modify(A_Index, "-Check")
      }
      RefreshCheckedNumber()
    }

    InvertSelect(*) {
      loop (detail.Length) {
        item := A_Index
        ItemState := SendMessage(0x102C, item - 1, 0xF000, LV)
        IsChecked := (ItemState >> 12) - 1
        LV.Modify(item, (IsChecked ? '-' : '') "Check")
      }
      RefreshCheckedNumber()
    }

    RefreshCheckedNumber(*) {
      TC.Text := '已选中' CountChecked() '项'
    }

    CountChecked(*) {
      count := 0
      loop (detail.Length) {
        item := A_Index
        ItemState := SendMessage(0x102C, item - 1, 0xF000, LV)
        count += (ItemState >> 12) - 1
      }
      return count
    }

    Delete(*) {
      item := 0
      sign := 0
      Loop {
        item := LV.GetNext(item, 'Checked')
        if (!item) {
          break
        }
        index := LV.GetText(item, 1)
        if (isYeJi) {
          this.sum -= setting.statistics[index].duration
          this.fightSum -= setting.statistics[index].fightDuration
          setting.statistics.Delete(index)
          this.detail.Delete(index)
        } else {
          this.sumDenny -= setting.statisticsDenny[index].duration
          setting.statisticsDenny.Delete(index)
          this.detailDenny.Delete(index)
        }
        sign := 1
      }
      if (!sign) {
        return
      }
      this.SP.changed := 1
      this.SP.GetPos(&x, &y)
      this.SPLastPos := [x * 96 / A_ScreenDPI, y * 96 / A_ScreenDPI]
      destroyGui()
      this.StatisticsPanel()
    }

  }

}