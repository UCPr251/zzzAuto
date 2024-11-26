#Include ../utils/ScreenBitmap.ahk

global FoundDennyFuben := false
/**
 * HDD关卡选择界面查找副本并进入
 */
enterDennyFuben(step := 2) {
  activateZZZ()
  stepLog("【step" step "】进入丁尼副本")

  static x := 251
  static y := Floor(c.height * 0.9)
  static ymin := c.height // 10
  static maxO := Ceil(c.height / 2160 * 24)
  static GetPixel := PixelGetColor
  static isPageDown := false
  static calY(x0, y0, r, x) {
    ySqPart := sqrt(Abs(r ** 2 - (x - x0) ** 2))
    y1 := Floor(y0 + ySqPart)
    y2 := Ceil(y0 - ySqPart)
    return [y1, y2]
  }
  static pagedown() {
    MouseMove(c.width // 4 * 3, c.height // 2)
    loop (10) {
      Click('WD 1')
    }
    Sleep(1000)
  }
  static getLen(direction := 'x', bl := 1) {
    len := 0
    if (direction = 'x') {
      s := () => GetPixel(x + bl * len, y)
    } else {
      s := () => GetPixel(x, y + bl * len)
    }
    loop {
      len++
      if (len > maxO) {
        break
      }
      color := s()
      if (color = '0x000000') {
        break
      }
    }
    return len
  }
  static choose() {
    pixelSearchAndClick(c.旧都列车.下一步*)
    RandomSleep(251, 300)
    SimulateClick(, , 6)
  }
  global FoundDennyFuben
  if (FoundDennyFuben) {
    if (isPageDown) {
      pagedown()
    }
    SimulateClick(x, y, 2)
    choose()
    return
  }
  xmin := Floor(c.拿命验收.xmin * c.width / 1920)
  xmax := Ceil(c.拿命验收.xmax * c.width / 1920)
  pToken := LoadLibrary()
  start := A_TickCount
  ; 不用OCR的痛苦 :)
  loop (2) {
    if (A_Index = 2) {
      isPageDown := true
      pagedown()
    }
    if (c.windowed) {
      WinGetClientPos(&zzzX, &zzzY, &zzzW, &zzzH, ZZZ)
      BitMap := ScreenBitmap(zzzX, zzzY, zzzX + zzzW, zzzY + zzzH)
    } else {
      BitMap := ScreenBitmap()
    }
    GetPixel := GetBitMapPixel.Bind(BitMap)
    loop (xmax - xmin + 1) {
      x := xmin + A_Index - 1
      y := Floor(c.height * 0.9)
      loop {
        y--
        if (y < ymin) {
          break
        }
        color := GetPixel(x, y)
        if (color = '0xFFFFFF') {
          ; 确定圆心X
          xLen1 := getLen('x', 1)
          if (xLen1 > maxO) {
            continue
          }
          xLen2 := getLen('x', -1)
          if (xLen2 > maxO) {
            continue
          }
          xTotal := xLen1 + xLen2
          if (xTotal > maxO) {
            continue
          }
          oldX := x
          oldY := y
          reset() {
            x := oldX
            y := oldY
          }
          x := x - xLen2 + Floor(xTotal / 2)
          ; 确定圆心Y
          yLen1 := getLen('y', 1)
          if (yLen1 > maxO) {
            reset()
            continue
          }
          yLen2 := getLen('y', -1)
          if (yLen2 > maxO) {
            reset()
            continue
          }
          yTotal := yLen1 + yLen2
          if (yTotal > maxO) {
            reset()
            continue
          }
          y := y - yLen2 + Floor(yTotal / 2)
          ; 重新获取X方向的圆直径
          xLen1 := getLen('x', 1)
          if (xLen1 > maxO) {
            reset()
            continue
          }
          xLen2 := getLen('x', -1)
          if (xLen2 > maxO) {
            reset()
            continue
          }
          xTotal := xLen1 + xLen2
          if (xTotal > maxO) {
            reset()
            continue
          }
          if (Abs(xTotal - yTotal) > 4) {
            reset()
            continue
          }
          offSet := 0 ; 同心圆半径偏移量
          loop {
            offSet++
            if (GetPixel(x - offSet, y) = '0x000000') {
              offSet++
              break
            }
          }
          radius := (xTotal + yTotal) // 4 + offSet ; 大同心圆半径
          check := (x, y) => GetPixel(x, y) = '0x000000'
          flag := true
          loop (radius * 2 + 1) {
            _x := x - radius + A_Index - 1
            Ys := calY(x, y, radius, _x)
            if (!check(_x, Ys[1]) || !check(_x, Ys[2])) {
              flag := false
              break
            }
          }
          if (!flag) {
            reset()
            continue
          }
          DisposeImage(BitMap)
          FreeLibrary(pToken)
          FoundDennyFuben := true
          SimulateClick(x, y)
          choose()
          ; MsgBox(Format("X: {}, Y: {}, xTotal: {}, yTotal: {}, seconds: {}, offSet: {}", x, y, xTotal, yTotal, Round((A_TickCount - start) / 1000, 3), offSet))
          return
        }
      }
    }
    DisposeImage(BitMap)
  }
  FreeLibrary(pToken)
  MsgBox("自动搜索失败，采用手动方案：`n请在关闭该弹窗后3s内将鼠标移动至「真 · 拿命验收」副本位置", "警告", "Icon! 0x40000")
  ; MsgBox(Format("自动搜索失败，X: {}, Y: {}, xTotal: {}, yTotal: {}, seconds: {}", x, y, IsSet(xTotal) ? xTotal : -1, IsSet(yTotal) ? yTotal : -1, Round((A_TickCount - start) / 1000, 3)), "警告", "Icon! 0x40000")
  Sleep(3000)
  MouseGetPos(&x, &y)
  FoundDennyFuben := true
  MsgBox(Format("后续选择丁尼副本位置将取当前鼠标位置：({}，{})`n重启脚本后重置", x, y), , "0x40000 T3")
  SimulateClick(x, y)
  choose()
  return
}