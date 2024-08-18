/** 控制器 */
class Controller {
  __New() {
    /** 正在刷取 */
    this.ing := false
    /** 下次退出 */
    this.nextExit := false
    this.startTime := 0
    this.finishTime := 0
  }

  /** 开始刷取 */
  start() {
    this.ing := true
    ; 时长统计
    this.startTime := A_Now
  }

  /** 刷取终止 */
  stop() {
    this.nextExit := false
    this.ing := false
    this.startTime := 0
    this.finishTime := 0
  }

  /** 完成刷取 */
  finish() {
    this.finishTime := A_Now
    duration := DateDiff(this.finishTime, this.startTime, "Seconds")
    setting.newStatistics(FormatTime(this.startTime, "M-dd HH:mm:ss"), duration)
    this.startTime := 0
    this.finishTime := 0
  }

}