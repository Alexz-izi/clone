# =====================================================
# Multi-Tool GUI - Modern Dark Theme + Animations
# Launched by multitool.bat
# =====================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic
[System.Windows.Forms.Application]::EnableVisualStyles()

# ---------- Theme palette ----------
$theme = @{
    Bg          = [System.Drawing.Color]::FromArgb(18, 18, 22)
    Sidebar     = [System.Drawing.Color]::FromArgb(24, 24, 30)
    Panel       = [System.Drawing.Color]::FromArgb(28, 28, 34)
    PanelDeep   = [System.Drawing.Color]::FromArgb(14, 14, 18)
    Border      = [System.Drawing.Color]::FromArgb(40, 40, 48)
    BtnIdle     = [System.Drawing.Color]::FromArgb(24, 24, 30)
    BtnHover    = [System.Drawing.Color]::FromArgb(45, 45, 56)
    BtnActive   = [System.Drawing.Color]::FromArgb(60, 60, 75)
    Accent      = [System.Drawing.Color]::FromArgb(110, 168, 254)
    AccentHover = [System.Drawing.Color]::FromArgb(140, 188, 255)
    Text        = [System.Drawing.Color]::FromArgb(230, 230, 235)
    TextDim     = [System.Drawing.Color]::FromArgb(150, 150, 160)
    Ok          = [System.Drawing.Color]::FromArgb(120, 220, 150)
    Warn        = [System.Drawing.Color]::FromArgb(240, 200, 110)
    Err         = [System.Drawing.Color]::FromArgb(240, 120, 120)
    ScrollTrack = [System.Drawing.Color]::FromArgb(20, 20, 26)
    ScrollThumb = [System.Drawing.Color]::FromArgb(60, 60, 72)
    ScrollHover = [System.Drawing.Color]::FromArgb(95, 95, 110)
}

$fontUI    = New-Object System.Drawing.Font("Segoe UI", 9.5)
$fontTitle = New-Object System.Drawing.Font("Segoe UI Semibold", 16)
$fontSmall = New-Object System.Drawing.Font("Segoe UI", 8.5)
$fontMono  = New-Object System.Drawing.Font("Cascadia Mono", 9.5)
if (-not $fontMono) { $fontMono = New-Object System.Drawing.Font("Consolas", 9.5) }

# ---------- Color helpers ----------
function Lerp-Color([System.Drawing.Color]$a, [System.Drawing.Color]$b, [double]$t) {
    if ($t -lt 0) { $t = 0 }
    if ($t -gt 1) { $t = 1 }
    $r = [int]($a.R + ($b.R - $a.R) * $t)
    $g = [int]($a.G + ($b.G - $a.G) * $t)
    $bl = [int]($a.B + ($b.B - $a.B) * $t)
    return [System.Drawing.Color]::FromArgb($r, $g, $bl)
}

# ---------- Main window (borderless) ----------
$form               = New-Object System.Windows.Forms.Form
$form.Text          = "Multi-Tool"
$form.Size          = New-Object System.Drawing.Size(960, 600)
$form.StartPosition = "CenterScreen"
$form.MinimumSize   = New-Object System.Drawing.Size(820, 520)
$form.BackColor     = $theme.Bg
$form.ForeColor     = $theme.Text
$form.Font          = $fontUI
$form.FormBorderStyle = "None"
$form.DoubleBuffered  = $true
$form.Opacity         = 0.0   # fade in on launch

# ---------- Title bar ----------
$titleBar           = New-Object System.Windows.Forms.Panel
$titleBar.Dock      = "Top"
$titleBar.Height    = 38
$titleBar.BackColor = $theme.Sidebar
$form.Controls.Add($titleBar)

$appTitle           = New-Object System.Windows.Forms.Label
$appTitle.Text      = "  Multi-Tool"
$appTitle.ForeColor = $theme.Text
$appTitle.Font      = New-Object System.Drawing.Font("Segoe UI Semibold", 10.5)
$appTitle.Dock      = "Left"
$appTitle.Width     = 220
$appTitle.TextAlign = "MiddleLeft"
$titleBar.Controls.Add($appTitle)

# Drag-to-move
$drag = @{ active = $false; offset = $null }
$titleBar.Add_MouseDown({
    if ($_.Button -eq "Left") {
        $drag.active = $true
        $drag.offset = New-Object System.Drawing.Point($_.X, $_.Y)
    }
})
$titleBar.Add_MouseMove({
    if ($drag.active) {
        $p = [System.Windows.Forms.Cursor]::Position
        $form.Location = New-Object System.Drawing.Point(($p.X - $drag.offset.X), ($p.Y - $drag.offset.Y))
    }
})
$titleBar.Add_MouseUp({ $drag.active = $false })

# ----- Window control buttons (animated) -----
function New-WinBtn([string]$text, [System.Drawing.Color]$hoverColor) {
    $b           = New-Object System.Windows.Forms.Button
    $b.Text      = $text
    $b.Width     = 46
    $b.Height    = 38
    $b.Dock      = "Right"
    $b.FlatStyle = "Flat"
    $b.BackColor = $theme.Sidebar
    $b.ForeColor = $theme.TextDim
    $b.Font      = New-Object System.Drawing.Font("Segoe UI", 11)
    $b.FlatAppearance.BorderSize = 0
    $b.TabStop   = $false
    $b.Cursor    = "Hand"

    # Animation state stored in Tag
    $b.Tag = @{
        target  = 0.0   # 0 idle, 1 hover
        current = 0.0
        from    = $theme.Sidebar
        to      = $hoverColor
        timer   = $null
    }

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 16
    $btnRef = $b
    $timer.Add_Tick({
        $s = $btnRef.Tag
        $diff = $s.target - $s.current
        if ([Math]::Abs($diff) -lt 0.02) {
            $s.current = $s.target
            $timer.Stop()
        } else {
            $s.current += $diff * 0.25  # easing
        }
        $btnRef.BackColor = Lerp-Color $s.from $s.to $s.current
        $btnRef.ForeColor = Lerp-Color $theme.TextDim $theme.Text $s.current
    }.GetNewClosure())
    $b.Tag.timer = $timer

    $b.Add_MouseEnter({ $this.Tag.target = 1.0; $this.Tag.timer.Start() }.GetNewClosure())
    $b.Add_MouseLeave({ $this.Tag.target = 0.0; $this.Tag.timer.Start() }.GetNewClosure())
    return $b
}

$btnClose = New-WinBtn "X" ([System.Drawing.Color]::FromArgb(200, 60, 60))
$btnClose.Add_Click({ $form.Close() })

$btnMin   = New-WinBtn "_" $theme.BtnHover
$btnMin.Add_Click({ $form.WindowState = "Minimized" })

$titleBar.Controls.Add($btnClose)
$titleBar.Controls.Add($btnMin)

# ---------- Sidebar ----------
$sidebar           = New-Object System.Windows.Forms.Panel
$sidebar.Dock      = "Left"
$sidebar.Width     = 240
$sidebar.BackColor = $theme.Sidebar
$sidebar.AutoScroll = $false  # we'll wrap our own
$form.Controls.Add($sidebar)

# Inner scroll container for sidebar (we'll add custom scrollbar later)
$sidebarInner            = New-Object System.Windows.Forms.Panel
$sidebarInner.Dock       = "Fill"
$sidebarInner.BackColor  = $theme.Sidebar
$sidebarInner.AutoScroll = $true
$sidebar.Controls.Add($sidebarInner)

$brand           = New-Object System.Windows.Forms.Label
$brand.Text      = "MULTI-TOOL"
$brand.ForeColor = $theme.Accent
$brand.Font      = New-Object System.Drawing.Font("Segoe UI Semibold", 13)
$brand.Location  = New-Object System.Drawing.Point(20, 18)
$brand.AutoSize  = $true
$sidebarInner.Controls.Add($brand)

$brandSub           = New-Object System.Windows.Forms.Label
$brandSub.Text      = "Windows utilities"
$brandSub.ForeColor = $theme.TextDim
$brandSub.Font      = $fontSmall
$brandSub.Location  = New-Object System.Drawing.Point(21, 44)
$brandSub.AutoSize  = $true
$sidebarInner.Controls.Add($brandSub)

$script:sidebarY = 80
function Add-Section([string]$label) {
    $l           = New-Object System.Windows.Forms.Label
    $l.Text      = $label.ToUpper()
    $l.ForeColor = $theme.TextDim
    $l.Font      = New-Object System.Drawing.Font("Segoe UI Semibold", 8)
    $l.Location  = New-Object System.Drawing.Point(20, $script:sidebarY)
    $l.AutoSize  = $true
    $sidebarInner.Controls.Add($l)
    $script:sidebarY += 22
}

# ---------- Content panel ----------
$content           = New-Object System.Windows.Forms.Panel
$content.Dock      = "Fill"
$content.BackColor = $theme.Bg
$content.Padding   = New-Object System.Windows.Forms.Padding(20, 14, 20, 14)
$form.Controls.Add($content)
$content.BringToFront()

$header           = New-Object System.Windows.Forms.Panel
$header.Dock      = "Top"
$header.Height    = 60
$header.BackColor = $theme.Bg
$content.Controls.Add($header)

$pageTitle           = New-Object System.Windows.Forms.Label
$pageTitle.Text      = "Welcome"
$pageTitle.Font      = $fontTitle
$pageTitle.ForeColor = $theme.Text
$pageTitle.Location  = New-Object System.Drawing.Point(0, 6)
$pageTitle.AutoSize  = $true
$header.Controls.Add($pageTitle)

$pageHint           = New-Object System.Windows.Forms.Label
$pageHint.Text      = "Pick a tool from the sidebar."
$pageHint.ForeColor = $theme.TextDim
$pageHint.Font      = $fontUI
$pageHint.Location  = New-Object System.Drawing.Point(2, 36)
$pageHint.AutoSize  = $true
$header.Controls.Add($pageHint)

# ---------- Output card (with custom scrollbar) ----------
$card             = New-Object System.Windows.Forms.Panel
$card.Dock        = "Fill"
$card.BackColor   = $theme.Panel
$card.Padding     = New-Object System.Windows.Forms.Padding(0)
$content.Controls.Add($card)
$card.BringToFront()

# Scrollbar lives on the right inside $card
$vScroll             = New-Object System.Windows.Forms.Panel
$vScroll.Dock        = "Right"
$vScroll.Width       = 10
$vScroll.BackColor   = $theme.ScrollTrack
$card.Controls.Add($vScroll)

# Output uses default vertical scroll under the hood, hidden behind the custom one
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

# Push real text away from the custom scrollbar visually
$output.Padding = New-Object System.Windows.Forms.Padding(8, 8, 16, 8)

# Custom thumb (drawn as a thin rounded rectangle)
$thumb = @{
    Size      = 40
    Pos       = 0
    Hover     = $false
    Dragging  = $false
    DragStartY= 0
    DragStartPos = 0
}

function Update-ScrollThumb {
    # Approximate: use line count as proxy for content height
    $totalLines  = [Math]::Max(1, ($output.Lines.Count))
    $visibleLines = [Math]::Max(1, [int]($output.ClientSize.Height / $output.Font.Height))
    if ($totalLines -le $visibleLines) {
        $vScroll.Visible = $false
        return
    }
    $vScroll.Visible = $true

    $trackH = $vScroll.ClientSize.Height
    $thumbH = [Math]::Max(24, [int]($trackH * ($visibleLines / $totalLines)))
    $thumb.Size = $thumbH

    # First visible line
    $firstChar  = $output.GetCharIndexFromPosition((New-Object System.Drawing.Point(2, 2)))
    $firstLine  = $output.GetLineFromCharIndex($firstChar)
    $maxFirst   = [Math]::Max(1, $totalLines - $visibleLines)
    $ratio      = [Math]::Min(1.0, $firstLine / $maxFirst)
    $thumb.Pos  = [int](($trackH - $thumbH) * $ratio)
    $vScroll.Invalidate()
}

$vScroll.Add_Paint({
    $g = $_.Graphics
    $g.SmoothingMode = "AntiAlias"
    $color = if ($thumb.Hover -or $thumb.Dragging) { $theme.ScrollHover } else { $theme.ScrollThumb }
    $brush = New-Object System.Drawing.SolidBrush($color)
    $rect  = New-Object System.Drawing.Rectangle(2, $thumb.Pos, $vScroll.Width - 4, $thumb.Size)
    # Rounded thumb
    $path  = New-Object System.Drawing.Drawing2D.GraphicsPath
    $r     = 4
    $path.AddArc($rect.X, $rect.Y, $r*2, $r*2, 180, 90)
    $path.AddArc($rect.Right - $r*2, $rect.Y, $r*2, $r*2, 270, 90)
    $path.AddArc($rect.Right - $r*2, $rect.Bottom - $r*2, $r*2, $r*2, 0, 90)
    $path.AddArc($rect.X, $rect.Bottom - $r*2, $r*2, $r*2, 90, 90)
    $path.CloseFigure()
    $g.FillPath($brush, $path)
    $brush.Dispose()
    $path.Dispose()
})

$vScroll.Add_MouseEnter({ $thumb.Hover = $true; $vScroll.Invalidate() })
$vScroll.Add_MouseLeave({ if (-not $thumb.Dragging) { $thumb.Hover = $false; $vScroll.Invalidate() } })

$vScroll.Add_MouseDown({
    if ($_.Y -ge $thumb.Pos -and $_.Y -le ($thumb.Pos + $thumb.Size)) {
        $thumb.Dragging  = $true
        $thumb.DragStartY = $_.Y
        $thumb.DragStartPos = $thumb.Pos
    } else {
        # Click outside thumb -> jump
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
    $visibleLines = [Math]::Max(1, [int]($output.ClientSize.Height / $output.Font.Height))
    $maxFirst = [Math]::Max(1, $totalLines - $visibleLines)
    $targetLine = [int]($maxFirst * $ratio)
    if ($targetLine -lt 0) { $targetLine = 0 }
    if ($targetLine -ge $totalLines) { $targetLine = $totalLines - 1 }
    $charIdx = $output.GetFirstCharIndexFromLine($targetLine)
    if ($charIdx -ge 0) {
        $output.SelectionStart = $charIdx
        $output.ScrollToCaret()
    }
    $vScroll.Invalidate()
}

# Hide the native vertical scrollbar by overlaying ours on top of it.
# (Native still works with mouse wheel; ours just visually replaces it.)

# Update thumb on text/resize/scroll
$output.Add_TextChanged({ Update-ScrollThumb })
$output.Add_VScroll({ Update-ScrollThumb })
$output.Add_Resize({ Update-ScrollThumb })
$output.Add_MouseWheel({ Update-ScrollThumb })
$card.Add_Resize({ Update-ScrollThumb })

# ---------- Status strip ----------
$statusBar           = New-Object System.Windows.Forms.Panel
$statusBar.Dock      = "Bottom"
$statusBar.Height    = 26
$statusBar.BackColor = $theme.Sidebar
$form.Controls.Add($statusBar)

$statusDot           = New-Object System.Windows.Forms.Label
$statusDot.Text      = "*"
$statusDot.Font      = New-Object System.Drawing.Font("Segoe UI", 13)
$statusDot.ForeColor = $theme.Ok
$statusDot.Location  = New-Object System.Drawing.Point(12, 0)
$statusDot.AutoSize  = $true
$statusBar.Controls.Add($statusDot)

$statusText           = New-Object System.Windows.Forms.Label
$statusText.Text      = "Ready"
$statusText.ForeColor = $theme.TextDim
$statusText.Font      = $fontSmall
$statusText.Location  = New-Object System.Drawing.Point(28, 6)
$statusText.AutoSize  = $true
$statusBar.Controls.Add($statusText)

# ---------- Pulse animation for status dot ----------
$pulse = @{
    active = $false
    phase  = 0.0
    base   = $theme.Accent
}
$pulseTimer = New-Object System.Windows.Forms.Timer
$pulseTimer.Interval = 40
$pulseTimer.Add_Tick({
    if (-not $pulse.active) { return }
    $pulse.phase += 0.18
    $t = (([Math]::Sin($pulse.phase) + 1) / 2)  # 0..1
    $statusDot.ForeColor = Lerp-Color $theme.Sidebar $pulse.base $t
})
$pulseTimer.Start()

function Start-Pulse([System.Drawing.Color]$color) {
    $pulse.active = $true
    $pulse.base   = $color
}
function Stop-Pulse([System.Drawing.Color]$finalColor) {
    $pulse.active = $false
    $statusDot.ForeColor = $finalColor
}

# ---------- Output fade animation ----------
$fade = @{
    timer = $null
    step  = 0
    text  = ""
}
$fadeTimer = New-Object System.Windows.Forms.Timer
$fadeTimer.Interval = 25
$fadeTimer.Add_Tick({
    $fade.step += 1
    $t = $fade.step / 8.0
    if ($t -ge 1) {
        $output.ForeColor = $theme.Text
        $fadeTimer.Stop()
        return
    }
    $output.ForeColor = Lerp-Color $theme.PanelDeep $theme.Text $t
})

function Write-Out([string]$text) {
    $output.Text = $text
    $output.SelectionStart  = 0
    $output.SelectionLength = 0
    $output.ScrollToCaret()
    Update-ScrollThumb
    # Fade text from background to foreground
    $fade.step = 0
    $output.ForeColor = $theme.PanelDeep
    $fadeTimer.Start()
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

function Set-Page([string]$title, [string]$hint) {
    $pageTitle.Text = $title
    $pageHint.Text  = $hint
}

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

# ---------- Animated sidebar buttons ----------
function Add-ToolButton([string]$label, [scriptblock]$action) {
    $b           = New-Object System.Windows.Forms.Button
    $b.Text      = "  " + $label
    $b.Location  = New-Object System.Drawing.Point(12, $script:sidebarY)
    $b.Size      = New-Object System.Drawing.Size(216, 32)
    $b.FlatStyle = "Flat"
    $b.BackColor = $theme.BtnIdle
    $b.ForeColor = $theme.Text
    $b.Font      = $fontUI
    $b.TextAlign = "MiddleLeft"
    $b.Cursor    = "Hand"
    $b.TabStop   = $false
    $b.FlatAppearance.BorderSize         = 0
    $b.FlatAppearance.MouseOverBackColor = $theme.BtnIdle  # we override
    $b.FlatAppearance.MouseDownBackColor = $theme.BtnActive

    # Animation state
    $b.Tag = @{
        target  = 0.0
        current = 0.0
        from    = $theme.BtnIdle
        to      = $theme.BtnHover
    }

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 16
    $btnRef = $b
    $timer.Add_Tick({
        $s = $btnRef.Tag
        $diff = $s.target - $s.current
        if ([Math]::Abs($diff) -lt 0.02) {
            $s.current = $s.target
            $timer.Stop()
        } else {
            $s.current += $diff * 0.22
        }
        $btnRef.BackColor = Lerp-Color $s.from $s.to $s.current
    }.GetNewClosure())

    $b.Add_MouseEnter({
        $this.Tag.target = 1.0
        $timer.Start()
    }.GetNewClosure())
    $b.Add_MouseLeave({
        $this.Tag.target = 0.0
        $timer.Start()
    }.GetNewClosure())
    $b.Add_Click($action)

    $sidebarInner.Controls.Add($b)
    $script:sidebarY += 34
    return $b
}

# ---------- Sections ----------
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
        if ($key) {
            [void]$sb.AppendLine("  $($key.ToString().Trim())")
        } else {
            [void]$sb.AppendLine("  (no password / not admin)")
        }
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
Add-ToolButton "Exit"               { $form.Close() }

# ---------- Window fade-in on show ----------
$fadeIn = New-Object System.Windows.Forms.Timer
$fadeIn.Interval = 16
$fadeIn.Add_Tick({
    if ($form.Opacity -lt 1.0) {
        $form.Opacity = [Math]::Min(1.0, $form.Opacity + 0.08)
    } else {
        $fadeIn.Stop()
    }
})
$form.Add_Shown({
    Update-ScrollThumb
    $fadeIn.Start()
})

# ---------- Show ----------
[void]$form.ShowDialog()
