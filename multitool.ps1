# =====================================================
# Multi-Tool GUI - Modern Dark Theme
# Launched by multitool.bat
# =====================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic
[System.Windows.Forms.Application]::EnableVisualStyles()

# ---------- Theme palette ----------
$theme = @{
    Bg          = [System.Drawing.Color]::FromArgb(18, 18, 22)     # main background
    Sidebar     = [System.Drawing.Color]::FromArgb(24, 24, 30)     # left rail
    Panel       = [System.Drawing.Color]::FromArgb(28, 28, 34)     # content panel
    PanelDeep   = [System.Drawing.Color]::FromArgb(14, 14, 18)     # output / inset
    Border      = [System.Drawing.Color]::FromArgb(40, 40, 48)
    BtnIdle     = [System.Drawing.Color]::FromArgb(32, 32, 40)
    BtnHover    = [System.Drawing.Color]::FromArgb(45, 45, 56)
    BtnActive   = [System.Drawing.Color]::FromArgb(60, 60, 75)
    Accent      = [System.Drawing.Color]::FromArgb(110, 168, 254)  # soft blue
    AccentHover = [System.Drawing.Color]::FromArgb(140, 188, 255)
    Text        = [System.Drawing.Color]::FromArgb(230, 230, 235)
    TextDim     = [System.Drawing.Color]::FromArgb(150, 150, 160)
    Ok          = [System.Drawing.Color]::FromArgb(120, 220, 150)
    Warn        = [System.Drawing.Color]::FromArgb(240, 200, 110)
    Err         = [System.Drawing.Color]::FromArgb(240, 120, 120)
}

$fontUI    = New-Object System.Drawing.Font("Segoe UI", 9.5)
$fontTitle = New-Object System.Drawing.Font("Segoe UI Semibold", 16)
$fontSmall = New-Object System.Drawing.Font("Segoe UI", 8.5)
$fontMono  = New-Object System.Drawing.Font("Cascadia Mono", 9.5)
if (-not $fontMono) { $fontMono = New-Object System.Drawing.Font("Consolas", 9.5) }

# ---------- Main window (borderless, draggable) ----------
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

# ----- Custom title bar (drag + min/close) -----
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

# Drag-to-move on the title bar
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

# Window control buttons
function New-WinBtn($text, $hoverColor) {
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
    $b.Add_MouseEnter({ $this.BackColor = $hoverColor; $this.ForeColor = $theme.Text }.GetNewClosure())
    $b.Add_MouseLeave({ $this.BackColor = $theme.Sidebar; $this.ForeColor = $theme.TextDim }.GetNewClosure())
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
$sidebar.AutoScroll = $true
$form.Controls.Add($sidebar)

# Brand block in sidebar
$brand           = New-Object System.Windows.Forms.Label
$brand.Text      = "MULTI-TOOL"
$brand.ForeColor = $theme.Accent
$brand.Font      = New-Object System.Drawing.Font("Segoe UI Semibold", 13)
$brand.Location  = New-Object System.Drawing.Point(20, 18)
$brand.AutoSize  = $true
$sidebar.Controls.Add($brand)

$brandSub           = New-Object System.Windows.Forms.Label
$brandSub.Text      = "Windows utilities"
$brandSub.ForeColor = $theme.TextDim
$brandSub.Font      = $fontSmall
$brandSub.Location  = New-Object System.Drawing.Point(21, 44)
$brandSub.AutoSize  = $true
$sidebar.Controls.Add($brandSub)

# Section header helper
$script:sidebarY = 80
function Add-Section($label) {
    $l           = New-Object System.Windows.Forms.Label
    $l.Text      = $label.ToUpper()
    $l.ForeColor = $theme.TextDim
    $l.Font      = New-Object System.Drawing.Font("Segoe UI Semibold", 8)
    $l.Location  = New-Object System.Drawing.Point(20, $script:sidebarY)
    $l.AutoSize  = $true
    $sidebar.Controls.Add($l)
    $script:sidebarY += 22
}

# ---------- Content panel ----------
$content           = New-Object System.Windows.Forms.Panel
$content.Dock      = "Fill"
$content.BackColor = $theme.Bg
$content.Padding   = New-Object System.Windows.Forms.Padding(20, 14, 20, 14)
$form.Controls.Add($content)
$content.BringToFront()

# Header row inside content
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

# Output card
$card             = New-Object System.Windows.Forms.Panel
$card.Dock        = "Fill"
$card.BackColor   = $theme.Panel
$card.Padding     = New-Object System.Windows.Forms.Padding(1)
$content.Controls.Add($card)
$card.BringToFront()

$output                = New-Object System.Windows.Forms.TextBox
$output.Multiline      = $true
$output.ScrollBars     = "Both"
$output.WordWrap       = $false
$output.ReadOnly       = $true
$output.BorderStyle    = "None"
$output.BackColor      = $theme.PanelDeep
$output.ForeColor      = $theme.Text
$output.Font           = $fontMono
$output.Dock           = "Fill"
$output.Text           = "Ready. Click any tool on the left to begin."
$card.Controls.Add($output)

# Status strip
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

# ---------- Helpers ----------
function Set-Status([string]$text, [string]$state = "ok") {
    $statusText.Text = $text
    switch ($state) {
        "ok"   { $statusDot.ForeColor = $theme.Ok }
        "warn" { $statusDot.ForeColor = $theme.Warn }
        "err"  { $statusDot.ForeColor = $theme.Err }
        "busy" { $statusDot.ForeColor = $theme.Accent }
    }
    [System.Windows.Forms.Application]::DoEvents()
}

function Set-Page([string]$title, [string]$hint) {
    $pageTitle.Text = $title
    $pageHint.Text  = $hint
}

function Write-Out([string]$text) {
    $output.Text = $text
    $output.SelectionStart  = 0
    $output.SelectionLength = 0
    $output.ScrollToCaret()
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

# ---------- Sidebar buttons ----------
function Add-ToolButton([string]$label, [scriptblock]$action) {
    $b           = New-Object System.Windows.Forms.Button
    $b.Text      = "  " + $label
    $b.Location  = New-Object System.Drawing.Point(12, $script:sidebarY)
    $b.Size      = New-Object System.Drawing.Size(216, 32)
    $b.FlatStyle = "Flat"
    $b.BackColor = $theme.Sidebar
    $b.ForeColor = $theme.Text
    $b.Font      = $fontUI
    $b.TextAlign = "MiddleLeft"
    $b.Cursor    = "Hand"
    $b.TabStop   = $false
    $b.FlatAppearance.BorderSize         = 0
    $b.FlatAppearance.MouseOverBackColor = $theme.BtnHover
    $b.FlatAppearance.MouseDownBackColor = $theme.BtnActive
    $b.Add_Click($action)
    $sidebar.Controls.Add($b)
    $script:sidebarY += 34
    return $b
}

# ---------- SYSTEM section ----------
Add-Section "System"
Add-ToolButton "System Info"        { Run-Cmd "systeminfo" "System Info" }
Add-ToolButton "Running Processes"  { Run-Cmd "tasklist" "Running Processes" }
Add-ToolButton "Kill Process..."    {
    $p = Ask-Input "Process name (e.g. notepad.exe):"
    if ($p) { Run-Cmd "taskkill /F /IM `"$p`"" "Kill Process" }
}
Add-ToolButton "Drives / Disks"     { Run-Cmd "wmic logicaldisk get deviceid,volumename,size,freespace" "Drives" }
Add-ToolButton "Installed Hotfixes" { Run-Cmd "wmic qfe list brief" "Hotfixes" }

# ---------- NETWORK section ----------
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

# ---------- FILES section ----------
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

# ---------- UTILS section ----------
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
}
Add-ToolButton "Exit"               { $form.Close() }

# ---------- Show ----------
[void]$form.ShowDialog()
