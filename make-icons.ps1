Add-Type -AssemblyName System.Drawing

function New-BeerIcon([int]$size, [string]$path) {
  $bmp = New-Object System.Drawing.Bitmap($size, $size)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

  $s = $size / 512.0   # everything below is designed in a 512 grid

  # ---- full-bleed amber background (good for Android maskable masking) ----
  $bgRect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
  $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $bgRect,
        [System.Drawing.Color]::FromArgb(255, 244, 163, 0),
        [System.Drawing.Color]::FromArgb(255, 217, 126, 0),
        [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
  $g.FillRectangle($bg, $bgRect)

  function P([double]$x, [double]$y) { New-Object System.Drawing.PointF(($x*$s), ($y*$s)) }

  # ---- handle (drawn first, behind glass) ----
  $handle = New-Object System.Drawing.Drawing2D.GraphicsPath
  $handle.AddBezier((P 340 215), (P 430 225), (P 430 320), (P 340 330))
  $penHandle = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 202, 162, 74), (34*$s))
  $penHandle.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $penHandle.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
  $g.DrawPath($penHandle, $handle)

  # ---- glass body (tapered tumbler) ----
  $glass = New-Object System.Drawing.Drawing2D.GraphicsPath
  $pts = @((P 168 175), (P 344 175), (P 318 360), (P 300 410), (P 212 410), (P 194 360))
  $glass.AddPolygon([System.Drawing.PointF[]]$pts)

  $brew = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Rectangle(0, [int](160*$s), $size, [int](260*$s))),
        [System.Drawing.Color]::FromArgb(255, 255, 207, 92),
        [System.Drawing.Color]::FromArgb(255, 224, 134, 0),
        [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
  $g.FillPath($brew, $glass)

  # shine stripe
  $shine = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(110, 255, 255, 255))
  $g.FillRectangle($shine, (200*$s), (210*$s), (22*$s), (170*$s))

  # bubbles
  $bub = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(150, 255, 255, 255))
  $g.FillEllipse($bub, (250*$s), (255*$s), (16*$s), (16*$s))
  $g.FillEllipse($bub, (278*$s), (300*$s), (12*$s), (12*$s))
  $g.FillEllipse($bub, (232*$s), (320*$s), (10*$s), (10*$s))

  # glass outline
  $penGlass = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 185, 128, 28), (10*$s))
  $penGlass.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
  $g.DrawPath($penGlass, $glass)

  # ---- foam (white blobby cap) ----
  $foam = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 248, 232))
  $g.FillEllipse($foam, (158*$s), (140*$s), (96*$s), (70*$s))
  $g.FillEllipse($foam, (210*$s), (128*$s), (96*$s), (74*$s))
  $g.FillEllipse($foam, (262*$s), (146*$s), (86*$s), (64*$s))
  $g.FillRectangle($foam, (168*$s), (172*$s), (176*$s), (24*$s))

  # ---- smiley face ----
  $ink = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 90, 46, 12))
  $g.FillEllipse($ink, (224*$s), (250*$s), (16*$s), (16*$s))
  $g.FillEllipse($ink, (276*$s), (250*$s), (16*$s), (16*$s))
  $blush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(140, 255, 155, 107))
  $g.FillEllipse($blush, (206*$s), (276*$s), (20*$s), (20*$s))
  $g.FillEllipse($blush, (290*$s), (276*$s), (20*$s), (20*$s))
  $penSmile = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 90, 46, 12), (10*$s))
  $penSmile.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $penSmile.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
  $smile = New-Object System.Drawing.Drawing2D.GraphicsPath
  $smile.AddBezier((P 230 286), (P 245 304), (P 271 304), (P 286 286))
  $g.DrawPath($penSmile, $smile)

  $g.Dispose()
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  Write-Host "wrote $path"
}

$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
New-BeerIcon 512 (Join-Path $dir 'icon-512.png')
New-BeerIcon 192 (Join-Path $dir 'icon-192.png')
