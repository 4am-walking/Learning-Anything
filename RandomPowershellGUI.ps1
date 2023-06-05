# Nothing of this GUI is of real substance, I just wanted to learn Powershell.
# Created by Chandler Matheny

# Create form new form and set the length and the width
Add-Type -assembly System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Text ='Script GUI'
$form.Width = 600
$form.Height = 400
$form.AutoSize = $true

# Create a new label for the Sort Downloads tool
$sortToolButton = New-Object System.Windows.Forms.Button
$sortToolButton.Location = New-Object System.Drawing.Size(10,10)
$sortToolButton.Size = New-Object System.Drawing.Size(120,23)
$sortToolButton.Text = "Sort the Downloads Folder"
$form.Controls.Add($sortToolButton)

<# 
    When the tool is clicked run the script
#>
$sortToolButton.Add_Click(
{
    # Extension list and folders to store them in
    $extListVideos = @('.avi', '.flv', '.mov', '.mp4', '.mpeg', '.mpg', '.swf', '.vob', '.wmv')
    $extListDocuments = @('.accdb', '.accde', '.accdr', '.accdt', '.aspx', '.bat', '.bin', '.cab', '.csv', '.dif', '.doc', '.docm', '.docx', '.dot', '.dotx', '.eml', '.eps', '.exe', '.ini', '.iso', '.jar', '.m4a', '.mdb', '.mid', '.midi', '.msi', '.mui', '.pdf', '.pot', '.potm', '.potx', '.ppam', '.pps', '.ppsm', '.ppsx', '.ppt', '.pptm', '.pptx', '.psd', '.pst', '.pub', '.rar', '.rtf', '.sldm', '.sldx', '.sys', '.tmp', '.txt', '.vsd', '.vsdm', '.vsdx', '.vss', '.vssm', '.vst', '.vstm', '.vstx', '.wbk', '.wks', '.wmd', '.wpd', '.wp5', '.xla', '.xlam', '.xll', '.xlm', '.xls', '.xlsm', '.xlsx', '.xlt', '.xltm', '.xltx', '.xps', '.zip')
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
$outlookBlockerLabel.Text = "Block Outlook:"
$outlookBlockerLabel.Location = New-Object System.Drawing.Point(10,50)
$outlookBlockerLabel.AutoSize = $true
$form.Controls.Add($outlookBlockerLabel)

# Create a button to start/stop Outlook blocker
$outlookBlockerButton = New-Object System.Windows.Forms.Button
$outlookBlockerButton.Location = New-Object System.Drawing.Size(90,45)
$outlookBlockerButton.Size = New-Object System.Drawing.Size(80,23)
$outlookBlockerButton.Text = "Start Blocker"
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
$inputChar.Text = "Insert Character:"
$inputChar.Location = New-Object System.Drawing.Point(10,80)
$inputChar.AutoSize = $true
$form.Controls.Add($inputChar)

# Create the user text box
$inputCharBox = New-Object System.Windows.Forms.TextBox
$inputCharBox.Location = New-Object System.Drawing.Point(100,80)
$inputCharBox.Size = New-Object System.Drawing.Size(30,30)
$form.Controls.Add($inputCharBox)

# Create the label to repeat
$inputNum = New-Object System.Windows.Forms.Label
$inputNum.Text = "Repeat how many times?"
$inputNum.Location = New-Object System.Drawing.Point(130,80)
$inputNum.AutoSize = $true
$form.Controls.Add($inputNum)

# Create the user count box
$inputNumBox = New-Object System.Windows.Forms.TextBox
$inputNumBox.Location = New-Object System.Drawing.Point(265,80)
$inputNumBox.Size = New-Object System.Drawing.Size(100,30)
$form.Controls.Add($inputNumBox)

# Create the Submit Button
$createFileButton = New-Object System.Windows.Forms.Button
$createFileButton.Location = New-Object System.Drawing.Size(375,80)
$createFileButton.Size = New-Object System.Drawing.Size(90,23)
$createFileButton.Text = "Generate TXT"
$form.Controls.Add($createFileButton)

# Create a label telling where the result is stored
$pathLabel = New-Object System.Windows.Forms.Label
$pathLabel.Text = ("The result is stored at " + ([Environment]::GetFolderPath('MyDocuments') + "\result.txt"))
$pathLabel.Location = New-Object System.Drawing.Point(10,105)
$pathLabel.AutoSize = $true
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
$performanceLabel.Text = "Performance Checker:"
$performanceLabel.Location = New-Object System.Drawing.Point(10,130)
$performanceLabel.AutoSize = $true
$form.Controls.Add($performanceLabel)

# Create performance button
$performanceButton = New-Object System.Windows.Forms.Button
$performanceButton.Location = New-Object System.Drawing.Size(127,125)
$performanceButton.Size = New-Object System.Drawing.Size(115,23)
$performanceButton.Text = "Check Performance"
$form.Controls.Add($performanceButton)

# Create the box displaying the performance
$performanceBox = New-Object System.Windows.Forms.TextBox
$performanceBox.Multiline = $true
$performanceBox.ScrollBars = "Vertical"
$performanceBox.Location = New-Object System.Drawing.Size(10,150)
$performanceBox.Size = New-Object System.Drawing.Size(400,75)
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
$logLabel.Text = "Error Log:"
$logLabel.Location = New-Object System.Drawing.Point(10,260)
$logLabel.AutoSize = $true
$form.Controls.Add($logLabel)

$logTextBox = New-Object System.Windows.Forms.TextBox
$logTextBox.Multiline = $true
$logTextBox.ScrollBars = "Vertical"
$logTextBox.Location = New-Object System.Drawing.Size(10,280)
$logTextBox.Size = New-Object System.Drawing.Size(400,75)
$form.Controls.Add($logTextBox)

<# 
    Generate System Information in a pop-up
#>
$sysInfoButton = New-Object System.Windows.Forms.Button
$sysInfoButton.Location = New-Object System.Drawing.Size(450,10)
$sysInfoButton.Size = New-Object System.Drawing.Size(110,23)
$sysInfoButton.Text = "System Information"
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
$exitButton.Location = New-Object System.Drawing.Size(500,325)
$exitButton.Size = New-Object System.Drawing.Size(60,23)
$exitButton.Text = "Exit"
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
