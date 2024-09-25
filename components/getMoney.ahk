/**
 * - 获得零号业绩
 */
getMoney(step := 6) {
  activateZZZ()
  stepLog("【step" step "】获得零号业绩")

  ; 进入零号业绩格子
  Press('d')
  Press('w', 2)
  Press('d', 1)
  RandomSleep(400, 500)
  Press('1', 3)
  RandomSleep(2200, 2300)
  Press('d', 2)
  ; 获得零号业绩（如果有）
  Press('w')
  ; 加载动画
  RandomSleep(1600, 1800)
  X := 1800, Y := 888
  preprocess(&X, &Y)
  ; 点击确定（如果有）
  SimulateClick(X, Y, 2)
  RandomSleep(700, 800)
}