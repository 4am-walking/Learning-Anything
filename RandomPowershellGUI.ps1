# Nothing of this GUI is of real substance, I just wanted to learn Powershell.
# Created by Chandler Matheny

# Create form new form and set the length and the width
Add-Type -assembly System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Text ='PowerShell Tools'
$form.Width = 600
$form.Height = 400
$form.AutoSize = $true
$form.BackColor = "42,43,47"
$form.StartPosition = 'CenterScreen'


function createButton {
    param($Var,$locationX,$locationY,$sizeX,$sizeY,[string]$text)
    $Var.Location = New-Object System.Drawing.Size($locationX,$locationY)
    $Var.Size = New-Object System.Drawing.Size($sizeX,$sizeY)
    $Var.Text = $text
    $Var.BackColor = "Black"
    $Var.ForeColor = "ControlLight"
    $Var.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $Var.FlatAppearance.BorderSize = 1

    $Var.Add_MouseEnter({
        $sender = $this
        $sender.BackColor = 'Gray'
    })

    $Var.Add_MouseLeave({
        $sender = $this
        if($form.BackColor -eq '42,43,47'){
            $sender.BackColor = 'Black'
        } else {
            $sender.BackColor = 'White'
        }
    })
}

function createLabel {
    param($Var,[string]$text,$locationX,$locationY)
    $Var.Text = $text
    $Var.Location = New-Object System.Drawing.Point($locationX,$locationY)
    $Var.AutoSize = $true
    $Var.ForeColor = "ControlLight"
    $Var.FlatStyle = "Flat"
}

function createTextBox {
    param($Var,$locationX,$locationY,$sizeX,$sizeY)
    $Var.Location = New-Object System.Drawing.Point($locationX,$locationY)
    $Var.Size = New-Object System.Drawing.Size($sizeX,$sizeY)
    $Var.BackColor = "Black"
    $Var.ForeColor = "ControlLight"
}

function Set-Theme {
    param($controls)
    foreach ($control in $controls) {
        $control.BackColor = $theme.BackgroundColor
        $control.ForeColor = $theme.ForegroundColor

        if ($control.Controls.Count -gt 0) {
            Set-Theme $control.Controls
        }
    }
}

$darkTheme = @{
    BackgroundColor = 'Black'
    ForegroundColor = 'ControlLight'
}

$lightTheme = @{
    BackgroundColor = 'White'
    ForegroundColor = '42,43,47'
}

<# -----------------------------------------------------------------------------------------------------------------#>
# Create the Menu
$menuStrip = New-Object System.Windows.Forms.MenuStrip
$menuStrip.BackColor = 'Black'

# Create the Tab
$settingsMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$settingsMenu.Text = 'Appearance'
$settingsMenu.BackColor = 'Gray'

# Create the Tab Items
$menuItem1 = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem1.Text = 'Light Mode'
$menuItem1.BackColor = 'Gray'
$menuItem2 = New-Object System.Windows.Forms.ToolStripMenuItem
$menuItem2.Text = 'Dark Mode'
$menuItem2.BackColor = 'Gray'
$settingsMenu.DropDownItems.AddRange(@($menuItem1, $menuItem2))
$menuStrip.Items.Add($settingsMenu)
$form.Controls.Add($menuStrip)


$menuItem1.Add_Click({
    $theme = $lightTheme
    Set-Theme $form.Controls
    $form.BackColor = 'White'
})

$menuItem2.Add_Click({
    $theme = $darkTheme
    Set-Theme $form.Controls
    $form.BackColor = '42,43,47'
})


# Create a new button for the Sort Downloads tool
$sortToolButton = New-Object System.Windows.Forms.Button
createButton -Var $sortToolButton -locationX 10 -locationY 35 -sizeX 175 -sizeY 23 -text "Sort the Downloads Folder"
$form.Controls.Add($sortToolButton)

<# 
    When the tool is clicked run the script
#>
$sortToolButton.Add_Click(
{
    # Extension list and folders to store them in
    $extListVideos = @('.avi', '.flv', '.mov', '.mp4', '.mpeg', '.mpg', '.swf', '.vob', '.wmv')
    $extListDocuments = @('.accdb', '.accde', '.accdr', '.accdt', '.aspx', '.bat', '.bin', '.cab', '.csv', '.dif', '.doc', '.docm', '.docx', '.dot', '.dotx', '.eml', '.eps', '.exe', '.ini', '.iso', '.jar', '.m4a', '.mdb', '.mid', '.midi', '.msi', '.mui', '.pdf', '.pot', '.potm', '.potx', '.ppam', '.pps', '.ppsm', '.ppsx', '.ppt', '.pptm', '.pptx', '.ps1', '.psd', '.pst', '.pub', '.rar', '.rtf', '.sldm', '.sldx', '.sys', '.tmp', '.txt', '.vsd', '.vsdm', '.vsdx', '.vss', '.vssm', '.vst', '.vstm', '.vstx', '.wbk', '.wks', '.wmd', '.wpd', '.wp5', '.xla', '.xlam', '.xll', '.xlm', '.xls', '.xlsm', '.xlsx', '.xlt', '.xltm', '.xltx', '.xps', '.zip')
    $extListMusic = @('.aac', '.adt', '.adts', '.aif', '.aifc', '.aiff', '.m4a', '.mid', '.midi', '.mp3')
    $extListPictures = @('.bmp', '.gif', '.jpg', '.jpeg', '.png', '.tif', '.tiff')

    $path = ("$HOME\Downloads\")

    # Get the path of the destination directories
    $pictureDest = ([Environment]::GetFolderPath('MyPictures') + "\")
    $musicDest = ([Environment]::GetFolderPath('MyMusic') + "\")
    $documentsDest = ([Environment]::GetFolderPath('MyDocuments') + "\")
    $videosDest = ([Environment]::GetFolderPath('MyVideos') + "\")

    $files = Get-ChildItem -Path $path -File

    # Moves every image file to the Pictures folder
    foreach ($file in $files) {
        $ext = [IO.Path]::GetExtension($file)
        if ($ext -in $extListVideos) {
            Move-Item -Path ($path + $file) -Destination $videosDest
        }
        if ($ext -in $extListDocuments) {
            Move-Item -Path ($path + $file) -Destination $documentsDest
        }
        if ($ext -in $extListMusic) {
            Move-Item -Path ($path + $file) -Destination $musicDest
        }
        if ($ext -in $extListPictures) {
            Move-Item -Path ($path + $file) -Destination $pictureDest
        }
    }
}
)

# Create a label for the Outlook blocker
$outlookBlockerLabel = New-Object System.Windows.Forms.Label
createLabel -Var $outlookBlockerLabel -text "Block Outlook:" -locationX 10 -locationY 75
$form.Controls.Add($outlookBlockerLabel)

# Create a button to start/stop Outlook blocker
$outlookBlockerButton = New-Object System.Windows.Forms.Button
createButton -Var $outlookBlockerButton -locationX 90 -locationY 70 -sizeX 80 -sizeY 23 -text "Start Blocker"
$form.Controls.Add($outlookBlockerButton)

$outlookBlockerScript = {
    $loopScript = 0
    # inf loop
    while ($loopScript -eq 0) {
    
        #Check if Outlook is open
        $outlook = Get-Process Outlook -ErrorAction SilentlyContinue
        if ($outlook) {

            #inc counter if Outlook is open
            $counter++

            #attempt to shut down Outlook peacefully
            Sleep 5
            $outlook.CloseMainWindow()
            Sleep 1
            #if it didn't shut down peacefully, kill it
            if (!$outlook.HasExited) {
                $outlook | Stop-Process -Force
            }

            #Print warning message
            powershell -WindowStyle hidden -Command "& {[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('Stay off of Outlook','WARNING')}"
            
        }
    }
}

<#
    Blocks Outlook from being used on the host computer
#>
$outlookBlockerButton.Add_Click(
{
    try {    
        if ($outlookBlockerButton.Text -eq "Start Blocker") {
            $scriptBlockJob = Start-Job -Name "Outlook" -ScriptBlock $outlookBlockerScript
            $outlookBlockerButton.Text = "Stop Blocker"
        } else {
            Stop-Job -Name "Outlook"
            Remove-Job -Name "Outlook"
            $outlookBlockerButton.Text = "Start Blocker"
        }
    
    } catch {
        # Error Message if an error occurs
        $logTextBox.ForeColor = 'Red'
        $logTextBox.Text = ("Unforseen Error. Please try again. " + "`r`nIf the error persists, contact chandler.matheny@gmail.com")
        $logTextBox.Focus() 
    }
}
)

<# 
    Create Number/Letter Sequence Generator
#>

# Create label for insert character
$inputChar = New-Object System.Windows.Forms.Label
createLabel -Var $inputChar -text "Insert Character:" -locationX 10 -locationY 105
$form.Controls.Add($inputChar)

# Create the user text box
$inputCharBox = New-Object System.Windows.Forms.TextBox
createTextBox -Var $inputCharBox -locationX 100 -locationY 105 -sizeX 30 -sizeY 30
$form.Controls.Add($inputCharBox)

# Create the label to repeat
$inputNum = New-Object System.Windows.Forms.Label
createLabel -Var $inputNum -text "Repeat how many times?" -locationX 130 -locationY 105
$form.Controls.Add($inputNum)

# Create the user count box
$inputNumBox = New-Object System.Windows.Forms.TextBox
createTextBox -Var $inputNumBox -locationX 265 -locationY 105 -sizeX 100 -sizeY 30
$form.Controls.Add($inputNumBox)

# Create the Submit Button
$createFileButton = New-Object System.Windows.Forms.Button
createButton -Var $createFileButton -locationX 375 -locationY 105 -sizeX 90 -sizeY 23 -text "Generate TXT"
$form.Controls.Add($createFileButton)

# Create a label telling where the result is stored
$pathLabel = New-Object System.Windows.Forms.Label
createLabel -Var $pathLabel -text ("The result is stored at " + ([Environment]::GetFolderPath('MyDocuments') + "\result.txt")) -locationX 10 -locationY 130
$pathLabel.Visible = $false
$form.Controls.Add($pathLabel)

<#
    This function will create a text file called result.txt and store the multiple of the user input
#>
$createFileButton.Add_Click(
{

    try {
        # Store the user input
        $inputCharButton = $inputCharBox.Text
        $inputNumButton = $inputNumBox.Text

        # Set the document path and multiply the user input
        $textLocation = ([Environment]::GetFolderPath('MyDocuments') + "\result.txt")
        $resultText = $inputCharButton * $inputNumButton

        # Create the text file and write the result of the multiplication
        New-Item -Path $textLocation -Force
        Set-Content -Path $textLocation -Value $resultText

        $pathLabel.Visible = $true

    } catch {
        # Error Message if an error occurs
        $logTextBox.ForeColor = 'Red'
        $logTextBox.Text = ("Invalid Input. " + "`r`nIf you're unsure why this error has appeared, contact chandler.matheny@gmail.com")
        $logTextBox.Focus()
    }
}
)

<#
    Create a performance monitor
#>

# Create performance label
$performanceLabel = New-Object System.Windows.Forms.Label
createLabel -Var $performanceLabel -text "Performance Checker:" -locationX 10 -locationY 155
$form.Controls.Add($performanceLabel)

# Create performance button
$performanceButton = New-Object System.Windows.Forms.Button
createButton -Var $performanceButton -locationX 127 -locationY 150 -sizeX 115 -sizeY 23 -text "Check Performance"
$form.Controls.Add($performanceButton)

# Create the box displaying the performance
$performanceBox = New-Object System.Windows.Forms.TextBox
$performanceBox.Multiline = $true
$performanceBox.ScrollBars = "Vertical"
$performanceBox.ReadOnly = $true
createTextBox -Var $performanceBox -locationX 10 -locationY 175 -sizeX 400 -sizeY 75
$form.Controls.Add($performanceBox)

<#
    Performance monitor logic
#>
$performanceButton.Add_Click(
{
    try {
            $totalRam = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).Sum
            $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $cpuTime = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
            $availMem = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
            $performance = $date + ' > CPU: ' + $cpuTime.ToString("#,0.000") + '%, Avail. Mem.: ' + $availMem.ToString("N0") + 'MB (' + (104857600 * $availMem / $totalRam).ToString("#,0.0") + "%)"
            $performanceBox.Text += $performance + "`r`n"
            $performanceBox.SelectionStart = $performanceBox.TextLength
            $performanceBox.ScrollToCaret()
    } catch {
        # Error Message if an error occurs
        $logTextBox.ForeColor = 'Red'
        $logTextBox.Text = "An error has occured. If you're unsure why this error has happened, please contact chandler.matheny@gmail.com"
        $logTextBox.Focus()
    }
}
)

<#
    Create a error console log
#>
$logLabel = New-Object System.Windows.Forms.Label
createLabel -Var $logLabel -text "Error Log:" -locationX 10 -locationY 260
$form.Controls.Add($logLabel)
$logTextBox = New-Object System.Windows.Forms.TextBox
$logTextBox.Multiline = $true
$logTextBox.ReadOnly = $true
createTextBox -Var $logTextBox -locationX 10 -locationY 280 -sizeX 400 -sizeY 75
$form.Controls.Add($logTextBox)

<# 
    Generate System Information in a pop-up
#>
$sysInfoButton = New-Object System.Windows.Forms.Button
createButton -Var $sysInfoButton -locationX 450 -locationY 35 -sizeX 120 -sizeY 23 -text "System Information"
$form.Controls.Add($sysInfoButton)

$sysInfoButton.Add_Click(
{
    $wshell = New-Object -ComObject Wscript.Shell
    $hostname = hostname
    $os = Get-CimInstance Win32_OperatingSystem | Select-Object Caption -ExpandProperty Caption
    $ip = (Test-Connection -ComputerName $hostname -Count 1).IPV4Address.IPAddressToString
    $wshell.Popup(("Current User: " + $env:UserName + "`r`nComputerName: " + $hostname + "`r`nOperating System: `r`n" + $os + "`r`nIP Address: " + $ip),0,"System Information",0x1) 
}
)


# Create a button to exit the GUI
$exitButton = New-Object System.Windows.Forms.Button
createButton -Var $exitButton -locationX 500 -locationY 325 -sizeX 60 -sizeY 23 -text "Exit"
$form.Controls.Add($exitButton)

<# 
    Exits the form when clicked
#>
$exitButton.Add_Click(
{
    $form.Close()
}
)

# Generate the Form
$form.ShowDialog()
