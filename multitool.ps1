# =====================================================
# Multi-Tool GUI - Premium Modern Theme
# Launched by multitool.bat
# =====================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

# ---------- Win32 (rounded corners on Win11) ----------
$dwmSrc = @"
using System;
using System.Runtime.InteropServices;
public static class Dwm {
    [DllImport("dwmapi.dll")]
    public static extern int DwmSetWindowAttribute(IntPtr h, int attr, ref int v, int s);
}
"@
try { Add-Type -TypeDefinition $dwmSrc -ErrorAction SilentlyContinue } catch {}

# ---------- Theme ----------
$theme = @{
    Bg          = [System.Drawing.Color]::FromArgb(15, 15, 20)
    Sidebar     = [System.Drawing.Color]::FromArgb(20, 20, 26)
    Panel       = [System.Drawing.Color]::FromArgb(24, 24, 30)
    PanelDeep   = [System.Drawing.Color]::FromArgb(12, 12, 16)
    Border      = [System.Drawing.Color]::FromArgb(38, 38, 46)
    BtnIdle     = [System.Drawing.Color]::FromArgb(20, 20, 26)
    BtnHover    = [System.Drawing.Color]::FromArgb(40, 40, 52)
    BtnActive   = [System.Drawing.Color]::FromArgb(55, 55, 72)
    Accent      = [System.Drawing.Color]::FromArgb(120, 160, 255)
    AccentEnd   = [System.Drawing.Color]::FromArgb(180, 130, 255)
    AccentSoft  = [System.Drawing.Color]::FromArgb(60, 80, 140)
    Text        = [System.Drawing.Color]::FromArgb(232, 232, 240)
    TextDim     = [System.Drawing.Color]::FromArgb(140, 140, 155)
    TextMute    = [System.Drawing.Color]::FromArgb(95, 95, 110)
    Ok          = [System.Drawing.Color]::FromArgb(120, 220, 150)
    Warn        = [System.Drawing.Color]::FromArgb(240, 200, 110)
    Err         = [System.Drawing.Color]::FromArgb(240, 120, 120)
    ScrollTrack = [System.Drawing.Color]::FromArgb(18, 18, 24)
    ScrollThumb = [System.Drawing.Color]::FromArgb(70, 70, 88)
    ScrollHover = [System.Drawing.Color]::FromArgb(120, 120, 150)
}

$fontUI    = New-Object System.Drawing.Font("Segoe UI", 9.5)
$fontTitle = New-Object System.Drawing.Font("Segoe UI Semibold", 17)
$fontSmall = New-Object System.Drawing.Font("Segoe UI", 8.5)
$fontTiny  = New-Object System.Drawing.Font("Segoe UI Semibold", 7.5)
$fontMono  = New-Object System.Drawing.Font("Cascadia Mono", 9.5)
if (-not $fontMono) { $fontMono = New-Object System.Drawing.Font("Consolas", 9.5) }

function Lerp([double]$a, [double]$b, [double]$t) {
    if ($t -lt 0) { $t = 0 }; if ($t -gt 1) { $t = 1 }
    return $a + ($b - $a) * $t
}
function Lerp-Color([System.Drawing.Color]$a, [System.Drawing.Color]$b, [double]$t) {
    if ($t -lt 0) { $t = 0 }; if ($t -gt 1) { $t = 1 }
    $r = [int]($a.R + ($b.R - $a.R) * $t)
    $g = [int]($a.G + ($b.G - $a.G) * $t)
    $bl= [int]($a.B + ($b.B - $a.B) * $t)
    return [System.Drawing.Color]::FromArgb($r, $g, $bl)
}
# Ease-out cubic
function Ease([double]$t) {
    if ($t -lt 0) { $t = 0 }; if ($t -gt 1) { $t = 1 }
    return 1 - [Math]::Pow(1 - $t, 3)
}

# ---------- Form ----------
$form               = New-Object System.Windows.Forms.Form
$form.Text          = "Multi-Tool"
$form.Size          = New-Object System.Drawing.Size(1000, 640)
$form.StartPosition = "CenterScreen"
$form.MinimumSize   = New-Object System.Drawing.Size(860, 540)
$form.BackColor     = $theme.Bg
$form.ForeColor     = $theme.Text
$form.Font          = $fontUI
$form.FormBorderStyle = "None"
$form.DoubleBuffered  = $true
$form.Opacity         = 0.0

# Rounded corners (Win11) + drop shadow attribute
$form.Add_HandleCreated({
    try {
        $pref = 2
        [Dwm]::DwmSetWindowAttribute($form.Handle, 33, [ref]$pref, 4) | Out-Null
    } catch {}
})

# ---------- Title bar ----------
$titleBar           = New-Object System.Windows.Forms.Panel
$titleBar.Dock      = "Top"
$titleBar.Height    = 42
$titleBar.BackColor = $theme.Sidebar
$titleBar.DoubleBuffered = $true
$form.Controls.Add($titleBar)

# Bottom 2px gradient strip drawn on the title bar
$titleBar.Add_Paint({
    $g = $_.Graphics
    $rect = New-Object System.Drawing.Rectangle(0, $titleBar.Height - 2, $titleBar.Width, 2)
    $br = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $rect, $theme.Accent, $theme.AccentEnd, [System.Drawing.Drawing2D.LinearGradientMode]::Horizontal)
    $g.FillRectangle($br, $rect)
    $br.Dispose()
})

$appTitle           = New-Object System.Windows.Forms.Label
$appTitle.Text      = "  Multi-Tool"
$appTitle.ForeColor = $theme.Text
$appTitle.Font      = New-Object System.Drawing.Font("Segoe UI Semibold", 10.5)
$appTitle.Dock      = "Left"
$appTitle.Width     = 220
$appTitle.TextAlign = "MiddleLeft"
$appTitle.BackColor = [System.Drawing.Color]::Transparent
$titleBar.Controls.Add($appTitle)

# Drag-to-move
$drag = @{ active = $false; offset = $null }
$titleBar.Add_MouseDown({
    if ($_.Button -eq "Left") { $drag.active = $true; $drag.offset = New-Object System.Drawing.Point($_.X, $_.Y) }
})
$titleBar.Add_MouseMove({
    if ($drag.active) {
        $p = [System.Windows.Forms.Cursor]::Position
        $form.Location = New-Object System.Drawing.Point(($p.X - $drag.offset.X), ($p.Y - $drag.offset.Y))
    }
})
$titleBar.Add_MouseUp({ $drag.active = $false })

function New-WinBtn([string]$text, [System.Drawing.Color]$hoverColor) {
    $b           = New-Object System.Windows.Forms.Button
    $b.Text      = $text
    $b.Width     = 50
    $b.Height    = 42
    $b.Dock      = "Right"
    $b.FlatStyle = "Flat"
    $b.BackColor = $theme.Sidebar
    $b.ForeColor = $theme.TextDim
    $b.Font      = New-Object System.Drawing.Font("Segoe UI", 11)
    $b.FlatAppearance.BorderSize = 0
    $b.TabStop   = $false
    $b.Cursor    = "Hand"

    $b.Tag = @{ target = 0.0; current = 0.0; from = $theme.Sidebar; to = $hoverColor }
    $tm = New-Object System.Windows.Forms.Timer
    $tm.Interval = 16
    $btnRef = $b
    $tm.Add_Tick({
        $s = $btnRef.Tag
        $diff = $s.target - $s.current
        if ([Math]::Abs($diff) -lt 0.01) { $s.current = $s.target; $tm.Stop() }
        else { $s.current += $diff * 0.28 }
        $btnRef.BackColor = Lerp-Color $s.from $s.to $s.current
        $btnRef.ForeColor = Lerp-Color $theme.TextDim $theme.Text $s.current
    }.GetNewClosure())
    $b.Add_MouseEnter({ $this.Tag.target = 1.0; $tm.Start() }.GetNewClosure())
    $b.Add_MouseLeave({ $this.Tag.target = 0.0; $tm.Start() }.GetNewClosure())
    return $b
}

$btnClose = New-WinBtn ([string][char]0x2715) ([System.Drawing.Color]::FromArgb(220, 70, 70))
$btnClose.Add_Click({
    $closeT = New-Object System.Windows.Forms.Timer
    $closeT.Interval = 12
    $closeT.Add_Tick({
        if ($form.Opacity -le 0.05) { $closeT.Stop(); $form.Close() }
        else { $form.Opacity = [Math]::Max(0.0, $form.Opacity - 0.12) }
    })
    $closeT.Start()
})
$btnMin = New-WinBtn ([string][char]0x2013) $theme.BtnHover
$btnMin.Add_Click({ $form.WindowState = "Minimized" })
$titleBar.Controls.Add($btnClose)
$titleBar.Controls.Add($btnMin)

# ---------- Sidebar ----------
$sidebar           = New-Object System.Windows.Forms.Panel
$sidebar.Dock      = "Left"
$sidebar.Width     = 250
$sidebar.BackColor = $theme.Sidebar
$form.Controls.Add($sidebar)

# Brand
$brand           = New-Object System.Windows.Forms.Label
$brand.Text      = "MULTI-TOOL"
$brand.ForeColor = $theme.Accent
$brand.Font      = New-Object System.Drawing.Font("Segoe UI Semibold", 13)
$brand.Location  = New-Object System.Drawing.Point(20, 16)
$brand.AutoSize  = $true
$brand.BackColor = [System.Drawing.Color]::Transparent
$sidebar.Controls.Add($brand)

# Subtle breathing glow on brand color
$script:brandT = 0.0
$brandTimer = New-Object System.Windows.Forms.Timer
$brandTimer.Interval = 50
$brandTimer.Add_Tick({
    $script:brandT += 0.04
    $t = (([Math]::Sin($script:brandT) + 1) / 2)
    $brand.ForeColor = Lerp-Color $theme.Accent $theme.AccentEnd $t
})
$brandTimer.Start()

$brandSub           = New-Object System.Windows.Forms.Label
$brandSub.Text      = "Windows utilities"
$brandSub.ForeColor = $theme.TextMute
$brandSub.Font      = $fontSmall
$brandSub.Location  = New-Object System.Drawing.Point(21, 42)
$brandSub.AutoSize  = $true
$brandSub.BackColor = [System.Drawing.Color]::Transparent
$sidebar.Controls.Add($brandSub)

# Search box
$searchPanel             = New-Object System.Windows.Forms.Panel
$searchPanel.Location    = New-Object System.Drawing.Point(14, 70)
$searchPanel.Size        = New-Object System.Drawing.Size(222, 32)
$searchPanel.BackColor   = $theme.PanelDeep
$sidebar.Controls.Add($searchPanel)

$searchIcon            = New-Object System.Windows.Forms.Label
$searchIcon.Text       = [string][char]0x2315
$searchIcon.Font       = New-Object System.Drawing.Font("Segoe UI", 11)
$searchIcon.ForeColor  = $theme.TextMute
$searchIcon.Location   = New-Object System.Drawing.Point(8, 6)
$searchIcon.AutoSize   = $true
$searchIcon.BackColor  = [System.Drawing.Color]::Transparent
$searchPanel.Controls.Add($searchIcon)

$searchBox             = New-Object System.Windows.Forms.TextBox
$searchBox.BorderStyle = "None"
$searchBox.BackColor   = $theme.PanelDeep
$searchBox.ForeColor   = $theme.TextMute
$searchBox.Font        = $fontUI
$searchBox.Location    = New-Object System.Drawing.Point(30, 9)
$searchBox.Size        = New-Object System.Drawing.Size(186, 18)
$searchBox.Text        = "Search tools..."
$searchPanel.Controls.Add($searchBox)
$searchBox.Add_Enter({
    if ($searchBox.Text -eq "Search tools...") { $searchBox.Text = ""; $searchBox.ForeColor = $theme.Text }
})
$searchBox.Add_Leave({
    if ([string]::IsNullOrWhiteSpace($searchBox.Text)) { $searchBox.Text = "Search tools..."; $searchBox.ForeColor = $theme.TextMute }
})

# Sidebar inner scroll area for tool buttons
$sidebarInner            = New-Object System.Windows.Forms.Panel
$sidebarInner.Location   = New-Object System.Drawing.Point(0, 115)
$sidebarInner.BackColor  = $theme.Sidebar
$sidebarInner.AutoScroll = $true
$sidebar.Controls.Add($sidebarInner)
$sidebar.Add_Resize({
    $sidebarInner.Size = New-Object System.Drawing.Size($sidebar.Width, ($sidebar.Height - 115))
})
$sidebarInner.Size = New-Object System.Drawing.Size($sidebar.Width, ($sidebar.Height - 115))

# Active-tool indicator (animated pill)
$activeIndicator             = New-Object System.Windows.Forms.Panel
$activeIndicator.Size        = New-Object System.Drawing.Size(3, 0)
$activeIndicator.Location    = New-Object System.Drawing.Point(0, 0)
$activeIndicator.BackColor   = $theme.Accent
$activeIndicator.Visible     = $false
$sidebarInner.Controls.Add($activeIndicator)
$activeIndicator.BringToFront()

$indicState = @{
    targetY = 0; targetH = 0
    curY    = 0.0; curH    = 0.0
    visible = $false
}
$indicTimer = New-Object System.Windows.Forms.Timer
$indicTimer.Interval = 16
$indicTimer.Add_Tick({
    $dy = $indicState.targetY - $indicState.curY
    $dh = $indicState.targetH - $indicState.curH
    if ([Math]::Abs($dy) -lt 0.5 -and [Math]::Abs($dh) -lt 0.5) {
        $indicState.curY = $indicState.targetY
        $indicState.curH = $indicState.targetH
        $indicTimer.Stop()
    } else {
        $indicState.curY += $dy * 0.28
        $indicState.curH += $dh * 0.28
    }
    $activeIndicator.Location = New-Object System.Drawing.Point(0, [int]$indicState.curY)
    $activeIndicator.Size     = New-Object System.Drawing.Size(3, [int]$indicState.curH)
    if ($indicState.visible) { $activeIndicator.Visible = $true }
})

function Move-Indicator([System.Windows.Forms.Control]$btn) {
    $indicState.targetY = $btn.Top + 6
    $indicState.targetH = $btn.Height - 12
    $indicState.visible = $true
    $indicTimer.Start()
}

$script:sidebarY = 6
$script:allToolButtons = @()

function Add-Section([string]$label) {
    $l           = New-Object System.Windows.Forms.Label
    $l.Text      = $label.ToUpper()
    $l.ForeColor = $theme.TextMute
    $l.Font      = $fontTiny
    $l.Location  = New-Object System.Drawing.Point(20, $script:sidebarY)
    $l.AutoSize  = $true
    $l.BackColor = [System.Drawing.Color]::Transparent
    $sidebarInner.Controls.Add($l)
    $script:sidebarY += 22
    $l.Tag = @{ kind = "section"; label = $label }
}

# ---------- Content ----------
$content           = New-Object System.Windows.Forms.Panel
$content.Dock      = "Fill"
$content.BackColor = $theme.Bg
$content.Padding   = New-Object System.Windows.Forms.Padding(24, 16, 24, 16)
$form.Controls.Add($content)
$content.BringToFront()

# Header
$header           = New-Object System.Windows.Forms.Panel
$header.Dock      = "Top"
$header.Height    = 64
$header.BackColor = $theme.Bg
$content.Controls.Add($header)

$pageTitle           = New-Object System.Windows.Forms.Label
$pageTitle.Text      = "Welcome"
$pageTitle.Font      = $fontTitle
$pageTitle.ForeColor = $theme.Text
$pageTitle.Location  = New-Object System.Drawing.Point(0, 4)
$pageTitle.AutoSize  = $true
$pageTitle.BackColor = [System.Drawing.Color]::Transparent
$header.Controls.Add($pageTitle)

$pageHint           = New-Object System.Windows.Forms.Label
$pageHint.Text      = "Pick a tool from the sidebar."
$pageHint.ForeColor = $theme.TextDim
$pageHint.Font      = $fontUI
$pageHint.Location  = New-Object System.Drawing.Point(2, 38)
$pageHint.AutoSize  = $true
$pageHint.BackColor = [System.Drawing.Color]::Transparent
$header.Controls.Add($pageHint)

# Output card
$card             = New-Object System.Windows.Forms.Panel
$card.Dock        = "Fill"
$card.BackColor   = $theme.Panel
$card.Padding     = New-Object System.Windows.Forms.Padding(0)
$content.Controls.Add($card)
$card.BringToFront()

# Custom scrollbar (right side, auto-expands on hover)
$vScroll             = New-Object System.Windows.Forms.Panel
$vScroll.Dock        = "Right"
$vScroll.Width       = 8
$vScroll.BackColor   = $theme.Panel
$card.Controls.Add($vScroll)

$output                = New-Object System.Windows.Forms.RichTextBox
$output.Multiline      = $true
$output.ScrollBars     = "Vertical"
$output.WordWrap       = $false
$output.ReadOnly       = $true
$output.BorderStyle    = "None"
$output.BackColor      = $theme.PanelDeep
$output.ForeColor      = $theme.Text
$output.Font           = $fontMono
$output.Dock           = "Fill"
$output.Text           = "Ready. Click any tool on the left to begin."
$card.Controls.Add($output)
$output.BringToFront()

# ---------- Custom scrollbar engine ----------
$thumb = @{
    Pos       = 0
    Size      = 40
    Hover     = $false
    Dragging  = $false
    DragStartY= 0
    DragStartPos = 0
    Width     = 8.0
    WidthTarg = 8.0
    Alpha     = 0.0
    AlphaTarg = 0.0
}

# Smooth width and alpha animation
$scrollAnim = New-Object System.Windows.Forms.Timer
$scrollAnim.Interval = 16
$scrollAnim.Add_Tick({
    $changed = $false
    $dw = $thumb.WidthTarg - $thumb.Width
    if ([Math]::Abs($dw) -gt 0.1) { $thumb.Width += $dw * 0.25; $changed = $true }
    else { $thumb.Width = $thumb.WidthTarg }

    $da = $thumb.AlphaTarg - $thumb.Alpha
    if ([Math]::Abs($da) -gt 0.01) { $thumb.Alpha += $da * 0.18; $changed = $true }
    else { $thumb.Alpha = $thumb.AlphaTarg }

    if ($changed) {
        $vScroll.Width = [int]([Math]::Round($thumb.Width)) + 2
        $vScroll.Invalidate()
    } else {
        $scrollAnim.Stop()
    }
})

function Update-ScrollThumb {
    $totalLines  = [Math]::Max(1, $output.Lines.Count)
    $visibleLines = [Math]::Max(1, [int]($output.ClientSize.Height / [Math]::Max(1, $output.Font.Height)))
    if ($totalLines -le $visibleLines) {
        $thumb.AlphaTarg = 0.0
        $scrollAnim.Start()
        return
    }
    $thumb.AlphaTarg = 1.0
    $trackH = $vScroll.ClientSize.Height
    $thumbH = [Math]::Max(28, [int]($trackH * ($visibleLines / $totalLines)))
    $thumb.Size = $thumbH

    $firstChar  = $output.GetCharIndexFromPosition((New-Object System.Drawing.Point(2, 2)))
    $firstLine  = $output.GetLineFromCharIndex($firstChar)
    $maxFirst   = [Math]::Max(1, $totalLines - $visibleLines)
    $ratio      = [Math]::Min(1.0, $firstLine / $maxFirst)
    $thumb.Pos  = [int](($trackH - $thumbH) * $ratio)
    $vScroll.Invalidate()
    $scrollAnim.Start()
}

$vScroll.Add_Paint({
    $g = $_.Graphics
    $g.SmoothingMode = "AntiAlias"
    if ($thumb.Alpha -le 0.01) { return }

    $w  = [int]$thumb.Width
    $x  = $vScroll.Width - $w - 2
    $h  = $thumb.Size

    # Subtle track
    $trackAlpha = [int](40 * $thumb.Alpha)
    $trackCol = [System.Drawing.Color]::FromArgb($trackAlpha, $theme.ScrollTrack)
    $trackBrush = New-Object System.Drawing.SolidBrush($trackCol)
    $g.FillRectangle($trackBrush, $x, 0, $w, $vScroll.Height)
    $trackBrush.Dispose()

    # Gradient thumb
    $base = if ($thumb.Hover -or $thumb.Dragging) { $theme.ScrollHover } else { $theme.ScrollThumb }
    $a = [int](255 * $thumb.Alpha)
    $top = [System.Drawing.Color]::FromArgb($a, $base.R, $base.G, $base.B)
    $bot = [System.Drawing.Color]::FromArgb($a, [Math]::Min(255, $base.R + 25), [Math]::Min(255, $base.G + 25), [Math]::Min(255, $base.B + 30))

    $rect = New-Object System.Drawing.Rectangle($x, $thumb.Pos, $w, $h)
    $r = [Math]::Min(6, [int]($w / 2))
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc($rect.X, $rect.Y, $r*2, $r*2, 180, 90)
    $path.AddArc($rect.Right - $r*2, $rect.Y, $r*2, $r*2, 270, 90)
    $path.AddArc($rect.Right - $r*2, $rect.Bottom - $r*2, $r*2, $r*2, 0, 90)
    $path.AddArc($rect.X, $rect.Bottom - $r*2, $r*2, $r*2, 90, 90)
    $path.CloseFigure()

    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $top, $bot, [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
    $g.FillPath($brush, $path)
    $brush.Dispose()
    $path.Dispose()
})

$vScroll.Add_MouseEnter({
    $thumb.Hover = $true
    $thumb.WidthTarg = 12.0
    $scrollAnim.Start()
    $vScroll.Invalidate()
})
$vScroll.Add_MouseLeave({
    if (-not $thumb.Dragging) {
        $thumb.Hover = $false
        $thumb.WidthTarg = 8.0
        $scrollAnim.Start()
        $vScroll.Invalidate()
    }
})
$vScroll.Add_MouseDown({
    if ($_.Y -ge $thumb.Pos -and $_.Y -le ($thumb.Pos + $thumb.Size)) {
        $thumb.Dragging = $true
        $thumb.DragStartY = $_.Y
        $thumb.DragStartPos = $thumb.Pos
    } else {
        $thumb.Pos = [Math]::Max(0, $_.Y - [int]($thumb.Size / 2))
        Apply-ScrollFromThumb
    }
})
$vScroll.Add_MouseMove({
    if ($thumb.Dragging) {
        $delta = $_.Y - $thumb.DragStartY
        $newPos = $thumb.DragStartPos + $delta
        $maxPos = $vScroll.ClientSize.Height - $thumb.Size
        if ($newPos -lt 0) { $newPos = 0 }
        if ($newPos -gt $maxPos) { $newPos = $maxPos }
        $thumb.Pos = $newPos
        Apply-ScrollFromThumb
    }
})
$vScroll.Add_MouseUp({ $thumb.Dragging = $false; $vScroll.Invalidate() })

function Apply-ScrollFromThumb {
    $maxPos = [Math]::Max(1, $vScroll.ClientSize.Height - $thumb.Size)
    $ratio  = $thumb.Pos / $maxPos
    $totalLines = [Math]::Max(1, $output.Lines.Count)
    $visibleLines = [Math]::Max(1, [int]($output.ClientSize.Height / [Math]::Max(1, $output.Font.Height)))
    $maxFirst = [Math]::Max(1, $totalLines - $visibleLines)
    $targetLine = [int]($maxFirst * $ratio)
    if ($targetLine -lt 0) { $targetLine = 0 }
    if ($targetLine -ge $totalLines) { $targetLine = $totalLines - 1 }
    $charIdx = $output.GetFirstCharIndexFromLine($targetLine)
    if ($charIdx -ge 0) { $output.SelectionStart = $charIdx; $output.ScrollToCaret() }
    $vScroll.Invalidate()
}

$output.Add_TextChanged({ Update-ScrollThumb })
$output.Add_VScroll({ Update-ScrollThumb })
$output.Add_Resize({ Update-ScrollThumb })
$output.Add_MouseWheel({ Update-ScrollThumb })
$card.Add_Resize({ Update-ScrollThumb })

# ---------- Status strip ----------
$statusBar           = New-Object System.Windows.Forms.Panel
$statusBar.Dock      = "Bottom"
$statusBar.Height    = 28
$statusBar.BackColor = $theme.Sidebar
$form.Controls.Add($statusBar)

$statusDot           = New-Object System.Windows.Forms.Label
$statusDot.Text      = [string][char]0x25CF
$statusDot.Font      = New-Object System.Drawing.Font("Segoe UI", 10)
$statusDot.ForeColor = $theme.Ok
$statusDot.Location  = New-Object System.Drawing.Point(14, 6)
$statusDot.AutoSize  = $true
$statusDot.BackColor = [System.Drawing.Color]::Transparent
$statusBar.Controls.Add($statusDot)

$statusText           = New-Object System.Windows.Forms.Label
$statusText.Text      = "Ready"
$statusText.ForeColor = $theme.TextDim
$statusText.Font      = $fontSmall
$statusText.Location  = New-Object System.Drawing.Point(32, 7)
$statusText.AutoSize  = $true
$statusText.BackColor = [System.Drawing.Color]::Transparent
$statusBar.Controls.Add($statusText)

# Pulse on dot
$pulse = @{ active = $false; phase = 0.0; base = $theme.Accent }
$pulseTimer = New-Object System.Windows.Forms.Timer
$pulseTimer.Interval = 40
$pulseTimer.Add_Tick({
    if (-not $pulse.active) { return }
    $pulse.phase += 0.18
    $t = (([Math]::Sin($pulse.phase) + 1) / 2)
    $statusDot.ForeColor = Lerp-Color $theme.Sidebar $pulse.base $t
})
$pulseTimer.Start()

function Start-Pulse([System.Drawing.Color]$c) { $pulse.active = $true; $pulse.base = $c }
function Stop-Pulse([System.Drawing.Color]$final) { $pulse.active = $false; $statusDot.ForeColor = $final }

# ---------- Page transition (slide + fade) ----------
$pageAnim = @{
    step = 0
    max  = 14
    active = $false
}
$pageTimer = New-Object System.Windows.Forms.Timer
$pageTimer.Interval = 16
$pageTimer.Add_Tick({
    $pageAnim.step += 1
    $t = Ease ($pageAnim.step / $pageAnim.max)
    $offset = [int]((1 - $t) * 12)
    $card.Padding = New-Object System.Windows.Forms.Padding(0, $offset, 0, 0)
    $output.ForeColor = Lerp-Color $theme.PanelDeep $theme.Text $t
    $pageTitle.ForeColor = Lerp-Color $theme.TextMute $theme.Text $t
    if ($pageAnim.step -ge $pageAnim.max) {
        $pageTimer.Stop()
        $card.Padding = New-Object System.Windows.Forms.Padding(0)
        $output.ForeColor = $theme.Text
        $pageTitle.ForeColor = $theme.Text
        $pageAnim.active = $false
    }
})

function Animate-Page {
    $pageAnim.step = 0
    $pageAnim.active = $true
    $pageTimer.Start()
}

function Write-Out([string]$text) {
    $output.Text = $text
    $output.SelectionStart = 0
    $output.SelectionLength = 0
    $output.ScrollToCaret()
    Update-ScrollThumb
    Animate-Page
}

# ---------- Helpers ----------
function Set-Status([string]$text, [string]$state = "ok") {
    $statusText.Text = $text
    switch ($state) {
        "ok"   { Stop-Pulse $theme.Ok }
        "warn" { Stop-Pulse $theme.Warn }
        "err"  { Stop-Pulse $theme.Err }
        "busy" { Start-Pulse $theme.Accent }
    }
    [System.Windows.Forms.Application]::DoEvents()
}
function Set-Page([string]$title, [string]$hint) { $pageTitle.Text = $title; $pageHint.Text = $hint }
function Run-Cmd([string]$cmd, [string]$pageTitleText) {
    Set-Page $pageTitleText "Running: $cmd"
    Set-Status "Running..." "busy"
    $output.Text = "..."
    [System.Windows.Forms.Application]::DoEvents()
    try {
        $result = cmd.exe /c $cmd 2>&1 | Out-String
        if ([string]::IsNullOrWhiteSpace($result)) { $result = "(no output)" }
        Write-Out $result
        Set-Status "Done" "ok"
    } catch {
        Write-Out ("ERROR: " + $_.Exception.Message)
        Set-Status "Error" "err"
    }
}
function Ask-Input([string]$prompt, [string]$default = "") {
    return [Microsoft.VisualBasic.Interaction]::InputBox($prompt, "Multi-Tool", $default)
}

# ---------- Sidebar buttons (animated + click ripple) ----------
function Add-ToolButton([string]$label, [scriptblock]$action) {
    $b           = New-Object System.Windows.Forms.Button
    $b.Text      = "  " + $label
    $b.Location  = New-Object System.Drawing.Point(8, $script:sidebarY)
    $b.Size      = New-Object System.Drawing.Size(228, 34)
    $b.FlatStyle = "Flat"
    $b.BackColor = $theme.BtnIdle
    $b.ForeColor = $theme.TextDim
    $b.Font      = $fontUI
    $b.TextAlign = "MiddleLeft"
    $b.Cursor    = "Hand"
    $b.TabStop   = $false
    $b.FlatAppearance.BorderSize         = 0
    $b.FlatAppearance.MouseOverBackColor = $theme.BtnIdle
    $b.FlatAppearance.MouseDownBackColor = $theme.BtnIdle

    $b.Tag = @{
        kind = "tool"; label = $label
        target = 0.0; current = 0.0
        rippleT = 0.0; rippleActive = $false
    }

    $tm = New-Object System.Windows.Forms.Timer
    $tm.Interval = 16
    $btnRef = $b
    $tm.Add_Tick({
        $s = $btnRef.Tag
        $diff = $s.target - $s.current
        if ([Math]::Abs($diff) -lt 0.01) { $s.current = $s.target }
        else { $s.current += $diff * 0.25 }

        $btnRef.BackColor = Lerp-Color $theme.BtnIdle $theme.BtnHover $s.current
        $btnRef.ForeColor = Lerp-Color $theme.TextDim $theme.Text $s.current

        $still = ([Math]::Abs($diff) -gt 0.01) -or $s.rippleActive
        if (-not $still) { $tm.Stop() }
    }.GetNewClosure())

    $b.Add_MouseEnter({ $this.Tag.target = 1.0; $tm.Start() }.GetNewClosure())
    $b.Add_MouseLeave({ $this.Tag.target = 0.0; $tm.Start() }.GetNewClosure())

    $b.Add_MouseDown({
        $this.Tag.rippleT = 0.0
        $this.Tag.rippleActive = $true
        $this.Invalidate()
    }.GetNewClosure())

    $b.Add_Paint({
        param($s, $e)
        $btn = $s
        if ($btn.Tag.rippleActive) {
            $btn.Tag.rippleT += 0.08
            if ($btn.Tag.rippleT -ge 1.0) {
                $btn.Tag.rippleActive = $false
                $btn.Tag.rippleT = 0.0
            }
            $alpha = [int](110 * (1 - $btn.Tag.rippleT))
            $col = [System.Drawing.Color]::FromArgb($alpha, $theme.Accent.R, $theme.Accent.G, $theme.Accent.B)
            $br = New-Object System.Drawing.SolidBrush($col)
            $e.Graphics.FillRectangle($br, $btn.ClientRectangle)
            $br.Dispose()
            $btn.Invalidate()
        }
    }.GetNewClosure())

    $b.Add_Click({
        Move-Indicator $this
        & $action
    }.GetNewClosure())

    $sidebarInner.Controls.Add($b)
    $script:sidebarY += 36
    $script:allToolButtons += $b
    return $b
}

# ---------- Tool definitions ----------
Add-Section "System"
Add-ToolButton "System Info"        { Run-Cmd "systeminfo" "System Info" }
Add-ToolButton "Running Processes"  { Run-Cmd "tasklist" "Running Processes" }
Add-ToolButton "Kill Process..."    {
    $p = Ask-Input "Process name (e.g. notepad.exe):"
    if ($p) { Run-Cmd "taskkill /F /IM `"$p`"" "Kill Process" }
}
Add-ToolButton "Drives / Disks"     { Run-Cmd "wmic logicaldisk get deviceid,volumename,size,freespace" "Drives" }
Add-ToolButton "Installed Hotfixes" { Run-Cmd "wmic qfe list brief" "Hotfixes" }

Add-Section "Network"
Add-ToolButton "ipconfig /all"      { Run-Cmd "ipconfig /all" "Network Configuration" }
Add-ToolButton "Ping..."            {
    $h = Ask-Input "Host or IP to ping:" "8.8.8.8"
    if ($h) { Run-Cmd "ping $h" "Ping $h" }
}
Add-ToolButton "Traceroute..."      {
    $h = Ask-Input "Host or IP for traceroute:" "8.8.8.8"
    if ($h) { Run-Cmd "tracert $h" "Traceroute $h" }
}
Add-ToolButton "DNS Lookup..."      {
    $h = Ask-Input "Domain to look up:" "google.com"
    if ($h) { Run-Cmd "nslookup $h" "DNS Lookup $h" }
}
Add-ToolButton "Flush DNS Cache"    { Run-Cmd "ipconfig /flushdns" "Flush DNS" }
Add-ToolButton "Open Connections"   { Run-Cmd "netstat -ano" "Open Connections" }
Add-ToolButton "Public IP"          {
    Set-Page "Public IP" "Querying api.ipify.org"
    Set-Status "Fetching..." "busy"
    try {
        $ip = (Invoke-WebRequest -UseBasicParsing 'https://api.ipify.org').Content
        Write-Out "Your public IP:`r`n`r`n  $ip"
        Set-Status "Done" "ok"
    } catch {
        Write-Out ("ERROR: " + $_.Exception.Message)
        Set-Status "Error" "err"
    }
}
Add-ToolButton "Wi-Fi Passwords"    {
    Set-Page "Wi-Fi Passwords" "Reading saved profiles (admin needed for keys)"
    Set-Status "Reading..." "busy"
    $output.Text = "..."
    $sb = New-Object System.Text.StringBuilder
    $profiles = (netsh wlan show profiles) |
        Select-String "All User Profile" |
        ForEach-Object { ($_ -split ":")[1].Trim() }
    foreach ($p in $profiles) {
        [void]$sb.AppendLine("Profile: $p")
        $key = (netsh wlan show profile name="$p" key=clear) | Select-String "Key Content"
        if ($key) { [void]$sb.AppendLine("  $($key.ToString().Trim())") }
        else      { [void]$sb.AppendLine("  (no password / not admin)") }
        [void]$sb.AppendLine("")
    }
    Write-Out $sb.ToString()
    Set-Status "Done" "ok"
}

Add-Section "Files"
Add-ToolButton "Search File..."     {
    $name = Ask-Input "Filename or pattern (e.g. *.txt):"
    if (-not $name) { return }
    $path = Ask-Input "Path to search:" "C:\"
    if (-not $path) { return }
    Run-Cmd "dir /s /b `"$path\$name`"" "Search Results"
}
Add-ToolButton "SHA256 Hash..."     {
    $dlg       = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title = "Pick a file to hash"
    if ($dlg.ShowDialog() -eq "OK") {
        Run-Cmd "certutil -hashfile `"$($dlg.FileName)`" SHA256" "SHA256 Hash"
    }
}
Add-ToolButton "Backup -> Zip..."   {
    $src = New-Object System.Windows.Forms.FolderBrowserDialog
    $src.Description = "Folder to back up"
    if ($src.ShowDialog() -ne "OK") { return }
    $dst = New-Object System.Windows.Forms.SaveFileDialog
    $dst.Filter   = "Zip files (*.zip)|*.zip"
    $dst.FileName = "backup.zip"
    if ($dst.ShowDialog() -ne "OK") { return }
    Set-Page "Backup -> Zip" "Compressing..."
    Set-Status "Compressing..." "busy"
    try {
        Compress-Archive -Path $src.SelectedPath -DestinationPath $dst.FileName -Force
        Write-Out "Backup created:`r`n`r`n  $($dst.FileName)"
        Set-Status "Done" "ok"
    } catch {
        Write-Out ("ERROR: " + $_.Exception.Message)
        Set-Status "Error" "err"
    }
}

Add-Section "Utilities"
Add-ToolButton "Random Password"    {
    $lenStr = Ask-Input "Password length:" "16"
    [int]$len = 16
    if (-not [int]::TryParse($lenStr, [ref]$len)) { $len = 16 }
    $chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*'
    $pw = -join ((1..$len) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    Set-Page "Random Password" "Generated $len characters"
    Write-Out "Your password:`r`n`r`n  $pw"
    Set-Status "Generated" "ok"
}
Add-ToolButton "Clear Output"       {
    $output.Text = ""
    Set-Page "Welcome" "Pick a tool from the sidebar."
    Set-Status "Cleared" "ok"
    Update-ScrollThumb
}
Add-ToolButton "Exit" {
    $closeT = New-Object System.Windows.Forms.Timer
    $closeT.Interval = 12
    $closeT.Add_Tick({
        if ($form.Opacity -le 0.05) { $closeT.Stop(); $form.Close() }
        else { $form.Opacity = [Math]::Max(0.0, $form.Opacity - 0.12) }
    })
    $closeT.Start()
}

# ---------- Search filter ----------
$searchBox.Add_TextChanged({
    $q = $searchBox.Text
    if ($q -eq "Search tools..." -or [string]::IsNullOrWhiteSpace($q)) {
        foreach ($c in $sidebarInner.Controls) { if ($c -ne $activeIndicator) { $c.Visible = $true } }
        return
    }
    $q = $q.ToLower()
    foreach ($c in $sidebarInner.Controls) {
        if ($c -eq $activeIndicator) { continue }
        if ($c.Tag -and $c.Tag.kind -eq "tool") {
            $c.Visible = $c.Tag.label.ToLower().Contains($q)
        } elseif ($c.Tag -and $c.Tag.kind -eq "section") {
            $c.Visible = $false
        }
    }
})

# ---------- Window fade-in ----------
$fadeIn = New-Object System.Windows.Forms.Timer
$fadeIn.Interval = 16
$fadeIn.Add_Tick({
    if ($form.Opacity -lt 1.0) { $form.Opacity = [Math]::Min(1.0, $form.Opacity + 0.09) }
    else { $fadeIn.Stop() }
})
$form.Add_Shown({
    Update-ScrollThumb
    $fadeIn.Start()
    Animate-Page
})

[void]$form.ShowDialog()
