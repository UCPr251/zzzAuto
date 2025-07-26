/** 控制器 */
class Controller {
  __New() {
    /** 正在刷取 */
    this.ing := false
    /** 下次退出 */
    this.nextExit := false
    this.startTime := 0
    this.finishTime := 0
    this.startFightTime := 0
    this.fightDuration := 0
    this.continuous := 0
    this.timer := false
  }

  /** 开始刷取 */
  start() {
    this.ing := true
    ; 时长统计
    this.startTime := A_Now
  }

  /** 战斗开始 */
  startFight() {
    this.startFightTime := A_Now
  }

  /** 战斗完成 */
  finishFight() {
    this.fightDuration := DateDiff(A_Now, this.startFightTime, "Seconds")
    this.startFightTime := 0
  }

  /** 刷取终止 */
  stop() {
    this.nextExit := false
    this.ing := false
    this.startTime := 0
    this.finishTime := 0
    this.continuous := 0
    this.timer := false
  }

  /** 完成刷取 */
  finish() {
    this.finishTime := A_Now
    duration := DateDiff(this.finishTime, this.startTime, "Seconds")
    if (setting.mode = 'YeJi') {
      setting.newStatistics(FormatTime(this.startTime, "M-dd HH:mm:ss"), this.fightDuration, duration)
      this.fightDuration := 0
    } else {
      setting.newStatisticsDenny(FormatTime(this.startTime, "M-dd HH:mm:ss"), duration)
    }
    this.startTime := 0
    this.finishTime := 0
  }

}