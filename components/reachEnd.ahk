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
      if (PixelSearchPre(&FoundX, &FoundY, 1300, 220, 1380, 270, 0xf63d49)) {
        mode := 1
        break
      }
      ; 对指定区域进行RGB检测
      if (PixelSearchPre(&FoundX, &FoundY, 1300, 840, 1400, 900, 0xeb2a2c)) {
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

  /** 右上角终点 */
  above() {
    ; 使用炸弹
    bomb()
    ; 向右移动
    Press("d")
    RandomSleep(1800, 2000)
    ; 选择铭徽
    MingHui()
    RandomSleep(1200, 1500)
    ; 进入终点
    Press("d")
    Press("w", 2)
  }

  /** 右下角终点 */
  below() {
    ; 代理人接应窗口
    Press('s')
    RandomSleep(800, 1200)
    Press("Space", 6)
    RandomSleep(2800, 3000)
    ; 取消接应
    pixelSearchAndClick(1400, 650, 1620, 685, 1545, 672, 0xffffff)
    Press("Space", 6)
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
  RandomSleep()
  if (mode = 1) {
    above()
  } else {
    below()
  }
  ; 加载动画
  Sleep(2000)
  return true
}