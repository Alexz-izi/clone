# =====================================================
# Multi-Tool GUI (Windows Forms)
# Launched by multitool.bat
# =====================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# ---------- Main window ----------
$form              = New-Object System.Windows.Forms.Form
$form.Text         = "Multi-Tool"
$form.Size         = New-Object System.Drawing.Size(820, 560)
$form.StartPosition = "CenterScreen"
$form.MinimumSize  = New-Object System.Drawing.Size(700, 480)
$form.BackColor    = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.ForeColor    = [System.Drawing.Color]::White
$form.Font         = New-Object System.Drawing.Font("Segoe UI", 9)

# ---------- Title bar ----------
$title           = New-Object System.Windows.Forms.Label
$title.Text      = "Multi-Tool"
$title.Font      = New-Object System.Drawing.Font("Segoe UI Semibold", 16)
$title.ForeColor = [System.Drawing.Color]::FromArgb(100, 200, 255)
$title.Location  = New-Object System.Drawing.Point(15, 10)
$title.Size      = New-Object System.Drawing.Size(400, 30)
$form.Controls.Add($title)

$subtitle           = New-Object System.Windows.Forms.Label
$subtitle.Text      = "Pick a tool from the left, results show on the right."
$subtitle.ForeColor = [System.Drawing.Color]::Silver
$subtitle.Location  = New-Object System.Drawing.Point(17, 40)
$subtitle.Size      = New-Object System.Drawing.Size(500, 20)
$form.Controls.Add($subtitle)

# ---------- Output box (right side) ----------
$output                 = New-Object System.Windows.Forms.TextBox
$output.Multiline       = $true
$output.ScrollBars      = "Both"
$output.WordWrap        = $false
$output.ReadOnly        = $true
$output.BackColor       = [System.Drawing.Color]::FromArgb(20, 20, 20)
$output.ForeColor       = [System.Drawing.Color]::FromArgb(220, 220, 220)
$output.Font            = New-Object System.Drawing.Font("Consolas", 9)
$output.Location        = New-Object System.Drawing.Point(230, 70)
$output.Size            = New-Object System.Drawing.Size(560, 410)
$output.Anchor          = "Top,Bottom,Left,Right"
$form.Controls.Add($output)

# ---------- Status bar ----------
$status            = New-Object System.Windows.Forms.Label
$status.Text       = "Ready."
$status.ForeColor  = [System.Drawing.Color]::LightGreen
$status.Location   = New-Object System.Drawing.Point(15, 490)
$status.Size       = New-Object System.Drawing.Size(780, 20)
$status.Anchor     = "Bottom,Left,Right"
$form.Controls.Add($status)

# ---------- Helpers ----------
function Set-Status($text, $color = "LightGreen") {
    $status.Text      = $text
    $status.ForeColor = [System.Drawing.Color]::$color
    [System.Windows.Forms.Application]::DoEvents()
}

function Write-Output-Box($text) {
    $output.Text = $text
    $output.SelectionStart  = 0
    $output.SelectionLength = 0
    $output.ScrollToCaret()
}

function Run-Cmd($cmd) {
    Set-Status "Running: $cmd ..." "Khaki"
    $output.Text = ""
    [System.Windows.Forms.Application]::DoEvents()
    try {
        $result = cmd.exe /c $cmd 2>&1 | Out-String
        Write-Output-Box $result
        Set-Status "Done." "LightGreen"
    } catch {
        Write-Output-Box ("ERROR: " + $_.Exception.Message)
        Set-Status "Error." "Salmon"
    }
}

function Ask-Input($prompt, $default = "") {
    Add-Type -AssemblyName Microsoft.VisualBasic
    return [Microsoft.VisualBasic.Interaction]::InputBox($prompt, "Multi-Tool", $default)
}

# ---------- Button factory ----------
$buttonY = 70
$buttons = @()

function Add-ToolButton($label, $action) {
    $b           = New-Object System.Windows.Forms.Button
    $b.Text      = $label
    $b.Location  = New-Object System.Drawing.Point(15, $script:buttonY)
    $b.Size      = New-Object System.Drawing.Size(200, 28)
    $b.FlatStyle = "Flat"
    $b.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 55)
    $b.ForeColor = [System.Drawing.Color]::White
    $b.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(80, 80, 90)
    $b.TextAlign = "MiddleLeft"
    $b.Padding   = New-Object System.Windows.Forms.Padding(8, 0, 0, 0)
    $b.Add_Click($action)
    $form.Controls.Add($b)
    $script:buttonY += 32
    $script:buttons += $b
}

# ---------- Tool actions ----------
Add-ToolButton "System Info"          { Run-Cmd "systeminfo" }
Add-ToolButton "Network (ipconfig)"   { Run-Cmd "ipconfig /all" }
Add-ToolButton "Ping..."              {
    $h = Ask-Input "Host or IP to ping:" "8.8.8.8"
    if ($h) { Run-Cmd "ping $h" }
}
Add-ToolButton "Traceroute..."        {
    $h = Ask-Input "Host or IP for traceroute:" "8.8.8.8"
    if ($h) { Run-Cmd "tracert $h" }
}
Add-ToolButton "DNS Lookup..."        {
    $h = Ask-Input "Domain to look up:" "google.com"
    if ($h) { Run-Cmd "nslookup $h" }
}
Add-ToolButton "Running Processes"    { Run-Cmd "tasklist" }
Add-ToolButton "Kill Process..."      {
    $p = Ask-Input "Process name (e.g. notepad.exe):"
    if ($p) { Run-Cmd "taskkill /F /IM `"$p`"" }
}
Add-ToolButton "Drives / Disk Usage"  { Run-Cmd "wmic logicaldisk get deviceid,volumename,size,freespace" }
Add-ToolButton "Search File..."       {
    $name = Ask-Input "Filename or pattern (e.g. *.txt):"
    if (-not $name) { return }
    $path = Ask-Input "Path to search:" "C:\"
    if (-not $path) { return }
    Run-Cmd "dir /s /b `"$path\$name`""
}
Add-ToolButton "SHA256 File Hash..."  {
    $dlg                  = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title            = "Pick a file to hash"
    if ($dlg.ShowDialog() -eq "OK") {
        Run-Cmd "certutil -hashfile `"$($dlg.FileName)`" SHA256"
    }
}
Add-ToolButton "Flush DNS Cache"      { Run-Cmd "ipconfig /flushdns" }
Add-ToolButton "Open Connections"     { Run-Cmd "netstat -ano" }
Add-ToolButton "Installed Hotfixes"   { Run-Cmd "wmic qfe list brief" }
Add-ToolButton "Wi-Fi Passwords"      {
    Set-Status "Reading Wi-Fi profiles..." "Khaki"
    $output.Text = ""
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("Saved Wi-Fi profiles (run as Administrator to see passwords)")
    [void]$sb.AppendLine("------------------------------------------------------------")
    $profiles = (netsh wlan show profiles) |
        Select-String "All User Profile" |
        ForEach-Object { ($_ -split ":")[1].Trim() }
    foreach ($p in $profiles) {
        [void]$sb.AppendLine("Profile: $p")
        $key = (netsh wlan show profile name="$p" key=clear) |
               Select-String "Key Content"
        if ($key) {
            [void]$sb.AppendLine("  $($key.ToString().Trim())")
        } else {
            [void]$sb.AppendLine("  (no password / not admin)")
        }
        [void]$sb.AppendLine("")
    }
    Write-Output-Box $sb.ToString()
    Set-Status "Done." "LightGreen"
}
Add-ToolButton "Backup Folder to Zip..." {
    $src = New-Object System.Windows.Forms.FolderBrowserDialog
    $src.Description = "Folder to back up"
    if ($src.ShowDialog() -ne "OK") { return }
    $dst = New-Object System.Windows.Forms.SaveFileDialog
    $dst.Filter   = "Zip files (*.zip)|*.zip"
    $dst.FileName = "backup.zip"
    if ($dst.ShowDialog() -ne "OK") { return }
    Set-Status "Compressing..." "Khaki"
    try {
        Compress-Archive -Path $src.SelectedPath -DestinationPath $dst.FileName -Force
        Write-Output-Box "Backup created:`r`n$($dst.FileName)"
        Set-Status "Done." "LightGreen"
    } catch {
        Write-Output-Box ("ERROR: " + $_.Exception.Message)
        Set-Status "Error." "Salmon"
    }
}
Add-ToolButton "Random Password" {
    $lenStr = Ask-Input "Password length:" "16"
    [int]$len = 16
    if (-not [int]::TryParse($lenStr, [ref]$len)) { $len = 16 }
    $chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*'
    $pw = -join ((1..$len) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    Write-Output-Box "Generated password:`r`n`r`n$pw"
    Set-Status "Password generated." "LightGreen"
}
Add-ToolButton "Show Public IP" {
    Set-Status "Fetching public IP..." "Khaki"
    try {
        $ip = (Invoke-WebRequest -UseBasicParsing 'https://api.ipify.org').Content
        Write-Output-Box "Public IP: $ip"
        Set-Status "Done." "LightGreen"
    } catch {
        Write-Output-Box ("ERROR: " + $_.Exception.Message)
        Set-Status "Error." "Salmon"
    }
}
Add-ToolButton "Clear Output" {
    $output.Text = ""
    Set-Status "Cleared." "LightGreen"
}
Add-ToolButton "Exit" { $form.Close() }

# ---------- Show ----------
[void]$form.ShowDialog()
