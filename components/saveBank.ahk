/**
 * - step7
 * - 存银行
 */
saveBank() {
  debugLog("【step7】存银行")
  Press('s')
  Press('a', 3)
  Press('s')
  Press('a', 3)
  Press('w')
  ; 进门
  Press('a')
  RandomSleep(2400, 2500)
  ; 强行闯入
  Press("2")
  ; 对话
  Press('Space', 8)
  ; 侵蚀
  RandomSleep(1800, 2000)
  ; 确定侵蚀
  Press('Escape')
  RandomSleep(4200, 4400)
  Press('a', 3)
  RandomSleep(1000, 1200)
  ; 对话
  Press('Space', 18)
  ; 如果有礼包
  if (PixelSearchPre(&X, &Y, c.空洞.2.银行.礼包*)) {
    pixelSearchAndClick(c.空洞.2.银行.不要礼包*)
    Press('Space', 4)
  }
  ; 存款
  loop (6) {
    Press('1')
    Press('Space', 2)
    ; 如果有礼包
    if (PixelSearchPre(&X, &Y, c.空洞.2.银行.礼包*)) {
      pixelSearchAndClick(c.空洞.2.银行.不要礼包*)
      Press('Space', 2)
    }
    ; 如果弹出选择铭徽界面
    MingHui(true)
    Press('Space', 2)
  }
}