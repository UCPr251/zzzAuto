/**
 * - 抵达终点
 */
reachEnd(step := 3) {
  activateZZZ()
  stepLog("【step" step "】前往终点")

  ; 判断地图类型
  mode := judgeMap()
  if (!mode) {
    return false
  }

  if (mode = 1) {
    above()
  } else {
    below()
  }
  ; 加载动画
  RandomSleep(1000, 1200)
  return true

  /** 判断地图类型 */
  static judgeMap() {
    mode := 0
    loop (60) {
      ; 对指定区域进行RGB检测
      if (PixelSearchPre(&FoundX, &FoundY, c.空洞.1.右上终点*)) {
        mode := 1
        break
      }
      ; 对指定区域进行RGB检测
      if (PixelSearchPre(&FoundX, &FoundY, c.空洞.1.右下终点*)) {
        mode := 2
        break
      }
      Sleep(100)
    }
    return mode
  }

  /** 使用炸弹 */
  static bomb() {
    if (setting.bombMode = 1) {
      Send("{r Down}")
      RandomSleep(800, 1000)
      Send("{r Up}")
    } else if (setting.bombMode = 2) {
      Press("r")
    }
    RandomSleep(2200, 2400)
  }

  /** 右上终点 */
  static above() {
    ; 使用炸弹
    bomb()
    ; 向右移动
    Press("d")
    RandomSleep(1300, 1500)
    ; 选择铭徽
    MingHui()
    RandomSleep(1000, 1200)
    ; 进入终点
    Press("d")
    Press("w", 2)
  }

  /** 右下终点 */
  static below() {
    ; 代理人接应窗口
    Press('s')
    RandomSleep(1000, 1200)
    Press("Space", 4)
    RandomSleep(800, 1000)
    ; 开启战斗自动躲避红光后，选择取消接应
    if (setting.isAutoDodge) {
      Press('2', 2)
      RandomSleep(800, 900)
      Press('3', 3)
      RandomSleep(800, 900)
      ; 通过Esc确认
      Press('Escape')
    } else {
      ; 接应
      Press('1', 2)
      RandomSleep(800, 900)
      Press('1', 2)
      pixelSearchAndClick(c.空洞.确认*)
    }
    RandomSleep(1800, 2000)
    ; 使用炸弹
    bomb()
    Press('s')
    RandomSleep(1800, 2000)
    ; 选择铭徽
    MingHui()
    RandomSleep(800, 1200)
    ; 进入终点
    Press('d', 2)
  }

}