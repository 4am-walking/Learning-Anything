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
    # Add more later...
    $extList = @('.png','.jpg')

    $path = ("$HOME\Downloads\")
    $dest = ([Environment]::GetFolderPath('MyPictures') + "\")

    $files = Get-ChildItem -Path $path -File

    # Moves every image file to the Pictures folder
    foreach ($file in $files) {
        $ext = [IO.Path]::GetExtension($file)
        if ($ext -in $extList) {
            Move-Item -Path ($path + $file) -Destination $dest
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
    if ($outlookBlockerButton.Text -eq "Start Blocker") {
        $scriptBlockJob = Start-Job -Name "Outlook" -ScriptBlock $outlookBlockerScript
        $outlookBlockerButton.Text = "Stop Blocker"
    } else {
        Stop-Job -Name "Outlook"
        Remove-Job -Name "Outlook"
        $outlookBlockerButton.Text = "Start Blocker"
    }
}
)

# Create Number/Letter Sequence Generator
$inputChar = New-Object System.Windows.Forms.Label
$inputChar.Text = "Inset Character:"
$inputChar.Location = New-Object System.Drawing.Point(10,100)
$inputChar.AutoSize = $true
$form.Controls.Add($inputChar)

# Create the user text box
$inputCharBox = New-Object System.Windows.Forms.TextBox
$inputCharBox.Location = New-Object System.Drawing.Point(95,100)
$inputCharBox.Size = New-Object System.Drawing.Size(30,30)
$form.Controls.Add($inputCharBox)

$inputNum = New-Object System.Windows.Forms.Label
$inputNum.Text = "Repeat how many times?"
$inputNum.Location = New-Object System.Drawing.Point(130,100)
$inputNum.AutoSize = $true
$form.Controls.Add($inputNum)

# Create the user count box
$inputNumBox = New-Object System.Windows.Forms.TextBox
$inputNumBox.Location = New-Object System.Drawing.Point(265,100)
$inputNumBox.Size = New-Object System.Drawing.Size(100,30)
$form.Controls.Add($inputNumBox)

# Create the Submit Button
$createFileButton = New-Object System.Windows.Forms.Button
$createFileButton.Location = New-Object System.Drawing.Size(375,100)
$createFileButton.Size = New-Object System.Drawing.Size(90,23)
$createFileButton.Text = "Generate TXT"
$form.Controls.Add($createFileButton)

# Create a label telling where the result is stored
$pathLabel = New-Object System.Windows.Forms.Label
$pathLabel.Text = ("The result is stored at " + $textLocation)
$pathLabel.Location = New-Object System.Drawing.Point(10,125)
$pathLabel.AutoSize = $true
$pathLabel.Visible = $false
$form.Controls.Add($pathLabel)

<#
    This function will create a text file called result.txt and store the multiple of the user input
#>
$createFileButton.Add_Click(
{
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
