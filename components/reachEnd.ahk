/**
 * - step3
 * - 抵达终点
 */
reachEnd() {

  /** 判断地图类型 */
  judgeMap() {
    mode := 0
    loop (10) {
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

  activateZZZ()
  ; 判断地图类型
  mode := judgeMap()
  if (!mode) {
    return false
  }

  /** 使用炸弹 */
  bomb() {
    Send("{r Down}")
    RandomSleep(800, 1000)
    Send("{r Up}")
    RandomSleep(1900, 2100)
  }

  /** 右上终点 */
  above() {
    ; 使用炸弹
    bomb()
    ; 向右移动
    Press("d")
    RandomSleep(2400, 2600)
    ; 选择铭徽
    MingHui()
    RandomSleep(1200, 1500)
    ; 进入终点
    Press("d")
    Press("w", 2)
  }

  /** 右下终点 */
  below() {
    ; 代理人接应窗口
    Press('s')
    RandomSleep(1000, 1200)
    Press("Space", 4)
    RandomSleep(800, 1000)
    ; 接应
    Press('1')
    RandomSleep(800, 1000)
    Press('1')
    RandomSleep(800, 1000)
    Press('Escape')
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

  debugLog("【step3】前往终点")
  if (mode = 1) {
    above()
  } else {
    below()
  }
  ; 加载动画
  RandomSleep(2000, 2200)
  return true
}