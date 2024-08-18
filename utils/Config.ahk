/** 配置 */
Class Config {

  /** 默认配置 */
  oriSetting := {
    /** 快捷手册 */
    handbook: 'F2',
    /** 炸弹使用：长按1，点击2 */
    bombMode: 1,
    /** 休眠系数，加载动画等待时长在原基础上的倍率，可通过修改该值延长/缩短全局等待时长 */
    sleepCoefficient: 1.0,
    /** RGB颜色搜索允许的渐变值 */
    variation: 60,
    /** 异常处理 */
    errHandler: true,
    /** 是否开启步骤信息弹窗 */
    isStepLog: true,
    /** 刷完业绩后是否自动关闭游戏 */
    isAutoClose: false,
    /** 是否开启银行模式 */
    bankMode: false,
    /** 是否存银行 */
    isSaveBank: true,
  }

  __New() {
    /** 配置文件路径 */
    this.iniFile := A_MyDocuments "\autoZZZ.ini"
    this.section1 := "Settings"
    this.section2 := "Statistics"
    /** 刷取统计数据 */
    this.statistics := []
    /** 设置项 */
    this.setting := this.oriSetting.Clone()
    this.Load()
    this.watch()
    this.__Set := this.__Set__.Bind(this)
  }

  __Get(Key, *) {
    return this.setting.%Key%
  }

  __Set__(thisObj, Key, Param, Value?) {
    if (IsSet(Value)) {
      if (this.setting.HasProp(Key)) {
        this.setting.%Key% := Value
        try {
          IniWrite(Value, this.iniFile, this.section1, Key)
        }
      }
    }
  }

  Load(*) {
    this.LoadSetting()
    this.LoadStatistics()
  }

  Save(*) {
    this.SaveSetting()
    this.SaveStatistics()
  }

  LoadSetting(*) {
    if (FileExist(this.iniFile)) {
      try {
        for (key, value in this.setting.OwnProps()) {
          value := IniRead(this.iniFile, this.section1, key, value)
          this.setting.%key% := value
        }
      }
    }
  }

  LoadStatistics(*) {
    if (FileExist(this.iniFile)) {
      try {
        Loop {
          time := IniRead(this.iniFile, this.section2, "time" A_Index, "")
          duration := IniRead(this.iniFile, this.section2, "duration" A_Index, "")
          if (time = "" && duration = "")
            break
          if (time && duration) {
            this.statistics.Push({ time: time, duration: duration })
          }
        }
      }
    }
  }

  SaveSetting(*) {
    try {
      for (key, value in this.setting.OwnProps()) {
        IniWrite(value, this.iniFile, this.section1, key)
      }
    }
  }

  SaveStatistics(*) {
    try {
      IniDelete(this.iniFile, this.section2) ; 清空
      Loop (this.statistics.Length) {
        item := this.statistics[A_Index]
        IniWrite(item.time, this.iniFile, this.section2, "time" A_Index)
        IniWrite(item.duration, this.iniFile, this.section2, "duration" A_Index)
      }
    }
  }

  newStatistics(time, duration) {
    this.statistics.Push({ time: time, duration: duration })
    this.SaveStatistics()
    p.newDetail(time, duration)
  }

  watch() {
    OnExit(this.Save.Bind(this))
  }

}