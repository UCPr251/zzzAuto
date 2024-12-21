/** 配置 */
Class Config {

  fightModeArr := ['通用·普通攻击', '艾莲', '星见雅']

  /** 默认配置 */
  oriSetting := {
    /** 业绩或丁尼 'YeJi' or 'Denny' */
    mode: 'YeJi',
    /** 炸弹使用：长按1，点击2 */
    bombMode: 1,
    /** 快捷手册 */
    handbook: 'F2',
    /** 休眠系数，加载动画等待时长在原基础上的倍率，可通过修改该值延长/缩短全局等待时长 */
    sleepCoefficient: 1.0,
    /** 允许总的异常时重试的次数 */
    retryTimes: 3,
    /** 颜色搜索允许的RGB值容差 */
    variation: 60,
    /** 战斗模式 */
    fightMode: 3,
    /** 刷取模式：0：全都要；1：只要业绩；2：只存银行 */
    gainMode: 0,
    /** 循环模式：0：业绩上限；-1：无限循环；正整数：刷取指定次数 */
    loopMode: 0,
    /** 异常处理 */
    errHandler: true,
    /** 是否开启步骤信息弹窗 */
    isStepLog: false,
    /** 刷完后是否自动关闭游戏 */
    isAutoClose: false,
    /** 战斗时是否自动识别红光闪避 */
    isAutoDodge: false,
    /** 循环模式：0：丁尼上限；-1：无限循环；正整数：刷取指定次数 */
    loopModeDenny: 0,
    /** 拿命验收破坏箱子前视角向右转动的坐标，调整该值以确保视角对齐NPC */
    rotateCoords: 200,
    GamePath: ''
  }

  __New() {
    /** 配置文件路径 */
    this.iniFile := A_MyDocuments "\autoZZZ.ini"
    this.section1 := "Settings"
    this.section2 := "Statistics"
    this.section3 := "StatisticsDenny"
    /** 业绩刷取统计数据 */
    this.statistics := []
    /** 丁尼刷取统计数据 */
    this.statisticsDenny := []
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
    this.LoadStatisticsDenny()
  }

  Save(*) {
    this.SaveSetting()
    this.SaveStatistics()
    this.SaveStatisticsDenny()
    try {
      IniWrite(Version, this.iniFile, 'Version', 'Version')
    }
  }

  isFirst(key) {
    static lastVer := IniRead(this.iniFile, 'Version', 'Version', 'v1.0.0')
    static set := {}
    result := true
    if (lastVer != Version && !set.HasProp(key)) {
      set.%key% := true
    } else {
      result := +IniRead(this.iniFile, 'isFirst', key, true)
    }
    if (result) {
      try {
        IniWrite(false, this.iniFile, 'isFirst', key)
      }
    }
    return result
  }

  LoadSetting(*) {
    if (FileExist(this.iniFile)) {
      try {
        for (key, value in this.setting.OwnProps()) {
          value := IniRead(this.iniFile, this.section1, key, value)
          if (IsInteger(this.setting.%key%)) {
            value := Integer(value)
          } else if (IsFloat(this.setting.%key%)) {
            value := Round(value, 2)
          }
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
          fightDuration := IniRead(this.iniFile, this.section2, "fightDuration" A_Index, 0)
          duration := IniRead(this.iniFile, this.section2, "duration" A_Index, 0)
          if (time = "" && duration = 0 && fightDuration = 0) {
            break
          }
          if (time && duration) {
            this.statistics.Push({ time: time, fightDuration: Integer(fightDuration), duration: Integer(duration) })
          }
        }
      }
    }
  }

  LoadStatisticsDenny(*) {
    if (FileExist(this.iniFile)) {
      try {
        Loop {
          time := IniRead(this.iniFile, this.section3, "time" A_Index, "")
          duration := IniRead(this.iniFile, this.section3, "duration" A_Index, 0)
          if (time = "" && duration = 0) {
            break
          }
          if (time && duration) {
            this.statisticsDenny.Push({ time: time, duration: Integer(duration) })
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
        IniWrite(item.fightDuration, this.iniFile, this.section2, "fightDuration" A_Index)
        IniWrite(item.duration, this.iniFile, this.section2, "duration" A_Index)
      }
    }
  }

  SaveStatisticsDenny(*) {
    try {
      IniDelete(this.iniFile, this.section3) ; 清空
      Loop (this.statisticsDenny.Length) {
        item := this.statisticsDenny[A_Index]
        IniWrite(item.time, this.iniFile, this.section3, "time" A_Index)
        IniWrite(item.duration, this.iniFile, this.section3, "duration" A_Index)
      }
    }
  }

  newStatistics(time, fightDuration, duration) {
    this.statistics.Push({ time: time, fightDuration: fightDuration, duration: duration })
    this.SaveStatistics()
    p.newDetail(time, fightDuration, duration)
  }

  newStatisticsDenny(time, duration) {
    this.statisticsDenny.Push({ time: time, duration: duration })
    this.SaveStatisticsDenny()
    p.newDetailDenny(time, duration)
  }

  watch() {
    OnExit(this.Save.Bind(this))
  }

}