# Generates the source images Android needs for a proper app icon, into ./assets:
#   icon-only.png        full icon (amber bg + smiling pint) — legacy + web/iOS
#   icon-background.png  amber gradient only — the adaptive-icon background layer
#   icon-foreground.png  pint only on transparent, inset to the adaptive "safe zone"
# @capacitor/assets then slices these into every screen density + the adaptive XML.
Add-Type -AssemblyName System.Drawing

function Draw-Pint($g, [double]$s) {
  function P([double]$x, [double]$y) { New-Object System.Drawing.PointF(($x*$s), ($y*$s)) }

  # handle (behind glass)
  $handle = New-Object System.Drawing.Drawing2D.GraphicsPath
  $handle.AddBezier((P 340 215), (P 430 225), (P 430 320), (P 340 330))
  $penHandle = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255,202,162,74), (34*$s))
  $penHandle.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $penHandle.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
  $g.DrawPath($penHandle, $handle)

  # glass body
  $glass = New-Object System.Drawing.Drawing2D.GraphicsPath
  $pts = @((P 168 175), (P 344 175), (P 318 360), (P 300 410), (P 212 410), (P 194 360))
  $glass.AddPolygon([System.Drawing.PointF[]]$pts)
  $brew = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Rectangle(0, [int](160*$s), [int](512*$s), [int](260*$s))),
        [System.Drawing.Color]::FromArgb(255,255,207,92),
        [System.Drawing.Color]::FromArgb(255,224,134,0),
        [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
  $g.FillPath($brew, $glass)

  $shine = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(110,255,255,255))
  $g.FillRectangle($shine, (200*$s), (210*$s), (22*$s), (170*$s))
  $bub = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(150,255,255,255))
  $g.FillEllipse($bub, (250*$s), (255*$s), (16*$s), (16*$s))
  $g.FillEllipse($bub, (278*$s), (300*$s), (12*$s), (12*$s))
  $g.FillEllipse($bub, (232*$s), (320*$s), (10*$s), (10*$s))
  $penGlass = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255,185,128,28), (10*$s))
  $penGlass.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
  $g.DrawPath($penGlass, $glass)

  # foam
  $foam = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,255,248,232))
  $g.FillEllipse($foam, (158*$s), (140*$s), (96*$s), (70*$s))
  $g.FillEllipse($foam, (210*$s), (128*$s), (96*$s), (74*$s))
  $g.FillEllipse($foam, (262*$s), (146*$s), (86*$s), (64*$s))
  $g.FillRectangle($foam, (168*$s), (172*$s), (176*$s), (24*$s))

  # smiley
  $ink = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,90,46,12))
  $g.FillEllipse($ink, (224*$s), (250*$s), (16*$s), (16*$s))
  $g.FillEllipse($ink, (276*$s), (250*$s), (16*$s), (16*$s))
  $blush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(140,255,155,107))
  $g.FillEllipse($blush, (206*$s), (276*$s), (20*$s), (20*$s))
  $g.FillEllipse($blush, (290*$s), (276*$s), (20*$s), (20*$s))
  $penSmile = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255,90,46,12), (10*$s))
  $penSmile.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $penSmile.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
  $smile = New-Object System.Drawing.Drawing2D.GraphicsPath
  $smile.AddBezier((P 230 286), (P 245 304), (P 271 304), (P 286 286))
  $g.DrawPath($penSmile, $smile)
}

function Draw-Background($g, [int]$size) {
  $rect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
  $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $rect,
        [System.Drawing.Color]::FromArgb(255,244,163,0),
        [System.Drawing.Color]::FromArgb(255,217,126,0),
        [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
  $g.FillRectangle($bg, $rect)
}

function New-Canvas([int]$size) {
  $bmp = New-Object System.Drawing.Bitmap($size, $size)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  return @($bmp, $g)
}

$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$assets = Join-Path $dir 'assets'
New-Item -ItemType Directory -Force -Path $assets | Out-Null
$N = 1024

# --- icon-only.png: full composed icon (bg + pint at native 512 grid) ---
$c = New-Canvas $N; $bmp = $c[0]; $g = $c[1]
Draw-Background $g $N
Draw-Pint $g ($N/512.0)
$g.Dispose(); $bmp.Save((Join-Path $assets 'icon-only.png'), [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
Write-Host "wrote icon-only.png"

# --- icon-background.png: amber gradient only ---
$c = New-Canvas $N; $bmp = $c[0]; $g = $c[1]
Draw-Background $g $N
$g.Dispose(); $bmp.Save((Join-Path $assets 'icon-background.png'), [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
Write-Host "wrote icon-background.png"

# --- icon-foreground.png: pint only, transparent, centred in the safe zone ---
# Map the pint's bounding box (centre ~294,269 in the 512 grid) to the canvas
# centre at a scale that keeps it inside the adaptive-icon safe zone.
$c = New-Canvas $N; $bmp = $c[0]; $g = $c[1]
$sFg = 2.2
$g.TranslateTransform([single](512 - 294*$sFg), [single](512 - 269*$sFg))
Draw-Pint $g $sFg
$g.Dispose(); $bmp.Save((Join-Path $assets 'icon-foreground.png'), [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
Write-Host "wrote icon-foreground.png"
