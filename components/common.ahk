/** 激活绝区零窗口 */
activateZZZ() {
  try {
    WinActivate("绝区零 ahk_class UnityWndClass")
    RandomSleep()
  } catch {
    MsgBox("【错误】未找到绝区零窗口，请进入游戏后重试", "错误")
    Exit()
  }
}

debugLog(str) {
  if (IsSet(isDebugLog) && !isDebugLog) {
    return
  }
  MsgBox(str, "调试日志", "T1")
}

/** 随机休眠，默认50~100ms */
RandomSleep(ms1 := 50, ms2 := 100) => Sleep(Random(ms1, ms2))

/**
 * 点按按键
 * @param {"Space"|"Escape"|"Shift"|"w"|"s"|"a"|"d"|"e"} key 需要点按的键位
 * @param {Integer} times 点按次数
 */
Press(key, times := 1) {
  loop (times) {
    Send("{" key " Down}")
    RandomSleep()
    Send("{" key " Up}")
    RandomSleep(150, 200)
  }
}

/** 对坐标进行缩放处理，使设计坐标与实际坐标匹配 */
preprocess(&X, &Y) {
  if (A_ScreenWidth = 1920 && A_ScreenHeight = 1080) { ; 无需缩放
    return
  }
  if (X > 1920 || Y > 1080) { ; 认为已是真实坐标
    return
  }
  scaleX := A_ScreenWidth / 1920
  scaleY := A_ScreenHeight / 1080
  X := Round(X * scaleX)
  Y := Round(Y * scaleY)
}

/** 鼠标随机移动至指定坐标 */
RandomMouseMove(TargetX, TargetY, isPreprocess := true) {
  if (isPreprocess) {
    preprocess(&TargetX, &TargetY)
  }
  MouseGetPos(&StartX, &StartY)
  Distance := Sqrt((TargetX - StartX) ** 2 + (TargetY - StartY) ** 2)
  MinSpeed := 25
  MaxSpeed := 35
  Speed := MinSpeed + Random() * (MaxSpeed - MinSpeed)
  ; 生成随机控制点用于贝塞尔曲线
  ControlPoint1X := StartX + Random() * (TargetX - StartX) / 2
  ControlPoint1Y := StartY + Random() * (TargetY - StartY) / 2
  ControlPoint2X := StartX + (TargetX - StartX) / 2 + Random() * (TargetX - StartX) / 2
  ControlPoint2Y := StartY + (TargetY - StartY) / 2 + Random() * (TargetY - StartY) / 2
  ; 使用贝塞尔曲线计算移动路径
  Steps := Ceil(Distance / Speed)
  Loop (Steps) {
    t := A_Index / Steps
    x := (1 - t) ** 3 * StartX + 3 * (1 - t) ** 2 * t * ControlPoint1X + 3 * (1 - t) * t ** 2 * ControlPoint2X + t ** 3 * TargetX
    y := (1 - t) ** 3 * StartY + 3 * (1 - t) ** 2 * t * ControlPoint1Y + 3 * (1 - t) * t ** 2 * ControlPoint2Y + t ** 3 * TargetY
    MouseMove(x, y, 0)
    RandomSleep(5, 10)
  }
}

/** 模拟点击行为，移动至指定坐标点击n次 */
SimulateClick(x?, y?, clickCount := 1, isPreprocess := true) {
  if (IsSet(x) && IsSet(y)) {
    RandomMouseMove(x + Random(-2, 2), y + Random(-2, 2), isPreprocess)
  }
  Loop (clickCount) {
    Click("Left Down")
    RandomSleep()
    Click("Left Up")
    RandomSleep(200, 220)
  }
}

/** 对坐标进行缩放预处理的像素搜索 */
PixelSearchPre(&X, &Y, X1, Y1, X2, Y2, Color, Tolerance := 0) {
  preprocess(&X1, &Y1)
  preprocess(&X2, &Y2)
  return PixelSearch(&X, &Y, X1, Y1, X2, Y2, Color, Tolerance)
}

/**
 * 搜索并点击像素点，返回真实X Y坐标数组
 * @param X1 搜索起点
 * @param Y1 搜索起点
 * @param X2 搜索终点
 * @param Y2 搜索终点
 * @param defaultX 默认X
 * @param defaultY 默认Y
 * @param Color 搜索颜色
 */
pixelSearchAndClick(X1, Y1, X2, Y2, defaultX, defaultY, Color) {
  X := 0, Y := 0
  loop (10) {
    if (PixelSearchPre(&X, &Y, X1, Y1, X2, Y2, Color, 50)) {
      break
    }
  }
  if (!X || !Y) {
    MsgBox("未找到像素点" Color "，将使用默认位置", "警告", "T1")
    X := defaultX, Y := defaultY
    preprocess(&X, &Y) ; 缩放处理默认坐标
  }
  RandomSleep()
  SimulateClick(X, Y, 1, false)
  return [X, Y]
}

; /**
;  * 获取图片中心绝对坐标
;  * @param File 文件路径
;  * @param CoordX X坐标内存地址
;  * @param CoordY Y坐标内存地址
;  * @returns {Integer} 是否成功
;  */
; CenterImgSrchCoords(File, &CoordsX, &CoordsY) {
;   try {
;     g := Gui()
;     g.Opt("-DPIScale")
;     LoadedPic := g.Add("Picture", "", File)
;     LoadedPic.GetPos(, , &Width, &Height)
;     g.Destroy()
;     CoordsX += Width // 2
;     CoordsY += Height // 2
;   } catch {
;     return false
;   } else {
;     return true
;   }
; }

; /** 对坐标进行缩放预处理的图片搜索 */
; ImageSearchPre(&X, &Y, X1, Y1, X2, Y2, File) {
;   preprocess(&X1, &Y1)
;   preprocess(&X2, &Y2)
;   return ImageSearch(&X, &Y, X1, Y1, X2, Y2, File)
; }

; /** 获取图片坐标并返回是否成功获取 */
; getImageXY(&X, &Y, params*) {
;   loop (20) {
;     if (ImageSearchPre(&X, &Y, params*)) {
;       return true
;     }
;   }
;   return false
; }

; /**
;  * 搜索并点击图片
;  * @param File 文件名
;  * @param defaultX 默认X
;  * @param defaultY 默认Y
;  * @param params 图片搜索参数
;  */
; imageSearchAndClick(File, defaultX, defaultY, params*) {
;   X := 0, Y := 0
;   preprocess(&X, &Y) ; 预处理默认坐标
;   if (!getImageXY(&X, &Y, params*)) {
;     MsgBox("未找到" File "，将使用默认位置", "警告", "T1")
;   } else {
;     CenterImgSrchCoords(File, &X, &Y)
;     X := defaultX, Y := defaultY
;     preprocess(&X, &Y) ; 缩放处理默认坐标
;   }
;   RandomSleep()
;   SimulateClick(X, Y, 1, false)
;   return [X, Y]
; }
