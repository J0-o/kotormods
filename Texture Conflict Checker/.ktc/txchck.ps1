$folder = $args[0]

# Generate lists
Get-ChildItem -Path $folder -Filter *.tga | Select-Object -ExpandProperty Name | Out-File -Encoding UTF8 ".ktc\tga.txt"
Get-ChildItem -Path $folder -Filter *.tpc | Select-Object -ExpandProperty Name | Out-File -Encoding UTF8 ".ktc\tpc.txt"
Get-ChildItem -Path $folder -Filter *.txi | Select-Object -ExpandProperty Name | Out-File -Encoding UTF8 ".ktc\txi.txt"
Get-ChildItem -Path $folder -Filter *.dds | Select-Object -ExpandProperty Name | Out-File -Encoding UTF8 ".ktc\dds.txt"

Add-Type -AssemblyName System.Windows.Forms

# functions
function Update-RestoreButtonState {
    $srcFolder = "texture_duplicates"
    if ((Test-Path $srcFolder) -and (Get-ChildItem -Path $srcFolder -File | Measure-Object).Count -gt 0) {
        $restoreButton.Enabled = $true
    } else {
        $restoreButton.Enabled = $false
    }
}

function Update-ProcessButtonState {
    if ($grid.Rows.Count -gt 0) {
        $button.Enabled = $true
    } else {
        $button.Enabled = $false
    }
}

# Load lists
$tga = Get-Content ".ktc\tga.txt" | Where-Object { $_ -ne "" }
$tpc = Get-Content ".ktc\tpc.txt" | Where-Object { $_ -ne "" }
$txi = Get-Content ".ktc\txi.txt" | Where-Object { $_ -ne "" }
$dds = Get-Content ".ktc\dds.txt" | Where-Object { $_ -ne "" }

# Base names
$tgaSet = $tga | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) }
$tpcSet = $tpc | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) }
$txiSet = $txi | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) }
$ddsSet = $dds | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) }

# Find conflicts (now includes DDS+TXI)
$allNames = ($tgaSet + $tpcSet + $txiSet + $ddsSet | Select-Object -Unique)
$conflicts = @()

foreach ($name in $allNames) {
    $hasTGA = $tgaSet -contains $name
    $hasTPC = $tpcSet -contains $name
    $hasTXI = $txiSet -contains $name
    $hasDDS = $ddsSet -contains $name

    $modes = @()
    if ($hasTPC) { $modes += "TPC" }
    if ($hasTGA -and $hasTXI) { $modes += "TGA+TXI" }
    if ($hasDDS -and $hasTXI) { $modes += "DDS+TXI" }

    # Only a conflict if two or more modes are present for this name
    if ($modes.Count -gt 1) {
        $conflicts += $name
    }
}

$conflicts = $conflicts | Sort-Object -Unique

# Data for grid
$data = foreach ($name in $conflicts) {
    $exts = @()
    if ($tgaSet -contains $name) { $exts += "TGA" }
    if ($txiSet -contains $name) { $exts += "TXI" }
    if ($tpcSet -contains $name) { $exts += "TPC" }
    if ($ddsSet -contains $name) { $exts += "DDS" }

    # Find the available modes for the dropdown
    $dropdownModes = @()
    if ($tpcSet -contains $name) { $dropdownModes += "TPC" }
    if (($tgaSet -contains $name) -and ($txiSet -contains $name)) { $dropdownModes += "TGA+TXI" }
    if (($ddsSet -contains $name) -and ($txiSet -contains $name)) { $dropdownModes += "DDS+TXI" }

    [PSCustomObject]@{
        Name = $name
        Extensions = ($exts -join ", ")
        DropdownModes = $dropdownModes
        DefaultChoice = $dropdownModes[0]
    }
}


# Build Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "KOTOR Texture Conflict Checker"
$form.Width = 700
$form.Height = 630
$iconPath = Join-Path (Split-Path $MyInvocation.MyCommand.Path) "icon.ico"
$form.Icon = New-Object System.Drawing.Icon($iconPath)

$grid = New-Object System.Windows.Forms.DataGridView
$grid.Width = 660
$grid.Height = 500
$grid.ColumnCount = 3
$grid.Columns[0].Name = "Base Name"
$grid.Columns[1].Name = "Extensions"
$grid.Columns[2].Name = "Choice"
$grid.AutoSizeColumnsMode = "Fill"
$grid.AllowUserToAddRows = $false
$grid.Columns[0].ReadOnly = $true  # Base Name
$grid.Columns[1].ReadOnly = $true  # Extensions

# Dropdown for last column
$col = New-Object System.Windows.Forms.DataGridViewComboBoxColumn
$col.HeaderText = "Keep"
$col.Name = "Choice"
$col.Width = 150
$col.Items.AddRange(@("TPC", "TGA+TXI", "DDS+TXI"))
$grid.Columns.RemoveAt(2)
$grid.Columns.Add($col)

# Fill Grid
foreach ($row in $data) {
    $rowIdx = $grid.Rows.Add($row.Name, $row.Extensions)
    $cb = $grid.Rows[$rowIdx].Cells[2]
    $cb.Items.Clear()
    foreach ($opt in $row.DropdownModes) { $cb.Items.Add($opt) }
    $cb.Value = $row.DefaultChoice
}

$form.Controls.Add($grid)

# Button to process selection
$button = New-Object System.Windows.Forms.Button
$button.Text = "Process"
$button.Width = 120
$button.Height = 70
$button.Top = $grid.Bottom + 10
$button.Left = 10
$form.Controls.Add($button)

$button.Add_Click({
    $results = @()
    $srcFolder = "override"
    $destFolder = "texture_duplicates"
    if (-not (Test-Path $destFolder)) {
        New-Item -ItemType Directory -Path $destFolder | Out-Null
    }

    foreach ($r in $grid.Rows) {
        $name = $r.Cells[0].Value
        $exts = $r.Cells[1].Value -split ",\s*"
        $choice = $r.Cells[2].Value

        if ($choice -eq "TPC") {
            foreach ($ext in @("TGA", "TXI", "DDS")) {
                if ($exts -contains $ext) {
                    $src = Join-Path $srcFolder "$name.$($ext.ToLower())"
                    if (Test-Path $src) {
                        Move-Item $src -Destination $destFolder -Force
                    }
                }
            }
        } elseif ($choice -eq "TGA+TXI") {
            foreach ($ext in @("TPC", "DDS")) {
                if ($exts -contains $ext) {
                    $src = Join-Path $srcFolder "$name.$($ext.ToLower())"
                    if (Test-Path $src) {
                        Move-Item $src -Destination $destFolder -Force
                    }
                }
            }
        } elseif ($choice -eq "DDS+TXI") {
            foreach ($ext in @("TPC", "TGA")) {
                if ($exts -contains $ext) {
                    $src = Join-Path $srcFolder "$name.$($ext.ToLower())"
                    if (Test-Path $src) {
                        Move-Item $src -Destination $destFolder -Force
                    }
                }
            }
        }
    }
    [System.Windows.Forms.MessageBox]::Show("Textures Moved")
    $form.Close()
})
Update-ProcessButtonState

# Restore button to move everything from texture_duplicates back to override
$restoreButton = New-Object System.Windows.Forms.Button
$restoreButton.Text = "Restore"
$restoreButton.Width = 140
$restoreButton.Height = 30
$restoreButton.Top = $button.Top
$restoreButton.Left = $button.Left + $button.Width + 20
$form.Controls.Add($restoreButton)

$restoreButton.Add_Click({
    $srcFolder = "texture_duplicates"
    $destFolder = "override"
    if (-not (Test-Path $srcFolder)) {
        [System.Windows.Forms.MessageBox]::Show("No texture_duplicates folder found.")
        return
    }
    $files = Get-ChildItem -Path $srcFolder -File
    if ($files.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No files to restore.")
        return
    }
    foreach ($file in $files) {
        $dest = Join-Path $destFolder $file.Name
        Move-Item $file.FullName -Destination $dest -Force
    }
    [System.Windows.Forms.MessageBox]::Show("Restore complete")
	$form.Close()
})
Update-RestoreButtonState

# Set All to TPC button
$setAllTpcButton = New-Object System.Windows.Forms.Button
$setAllTpcButton.Text = "Set All to TPC"
$setAllTpcButton.Width = 120
$setAllTpcButton.Height = 30
$setAllTpcButton.Top = $button.Top
$setAllTpcButton.Left = $restoreButton.Left + $setAllTpcButton.Width + 120
$form.Controls.Add($setAllTpcButton)

$setAllTpcButton.Add_Click({
    foreach ($row in $grid.Rows) {
        $row.Cells[2].Value = "TPC"
    }
})

# Set All to TGA+TXI button
$setAllTgaTxiButton = New-Object System.Windows.Forms.Button
$setAllTgaTxiButton.Text = "Set All to TGA+TXI"
$setAllTgaTxiButton.Width = 120
$setAllTgaTxiButton.Height = 30
$setAllTgaTxiButton.Top = $button.Top
$setAllTgaTxiButton.Left = $setAllTpcButton.Left + $setAllTgaTxiButton.Width + 20
$form.Controls.Add($setAllTgaTxiButton)

$setAllTgaTxiButton.Add_Click({
    foreach ($row in $grid.Rows) {
        $row.Cells[2].Value = "TGA+TXI"
    }
})

# Set All to DDS+TXI button
$setAllDdsTxiButton = New-Object System.Windows.Forms.Button
$setAllDdsTxiButton.Text = "Set All to DDS+TXI"
$setAllDdsTxiButton.Width = 120
$setAllDdsTxiButton.Height = 30
$setAllDdsTxiButton.Top = $button.Top + $setAllDdsTxiButton.Height + 10
$setAllDdsTxiButton.Left = $setAllTgaTxiButton.Left
$form.Controls.Add($setAllDdsTxiButton)

$setAllDdsTxiButton.Add_Click({
    foreach ($row in $grid.Rows) {
        # Only set if DDS+TXI is a valid choice for this row
        $cb = $row.Cells[2]
        if ($cb.Items.Contains("DDS+TXI")) {
            $cb.Value = "DDS+TXI"
        }
    }
})

# Export preferences button
$exportButton = New-Object System.Windows.Forms.Button
$exportButton.Text = "Export"
$exportButton.Width = 60
$exportButton.Height = 30
$exportButton.Top = $restoreButton.Top + $restoreButton.Height + 10
$exportButton.Left = $restoreButton.Left
$form.Controls.Add($exportButton)

$exportButton.Add_Click({
    $saveDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveDialog.Title = "Export Preferences"
    $saveDialog.Filter = "KOTOR Texture List (*.ktl)|*.ktl"
    $saveDialog.FileName = "texture_preferences.ktl"
    $saveDialog.InitialDirectory = ..\Get-Location

    if ($saveDialog.ShowDialog() -eq "OK") {
        $exportPath = $saveDialog.FileName
        $prefs = @()
        foreach ($r in $grid.Rows) {
            $name = $r.Cells[0].Value
            $choice = $r.Cells[2].Value
            if ($name -and $choice) {
                $prefs += "$name $choice"
            }
        }
        if ($prefs.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("No conflicts to export.")
            return
        }
        $prefs | Set-Content $exportPath -Encoding UTF8
        [System.Windows.Forms.MessageBox]::Show("Preferences exported to $exportPath")
    }
})

# Import preferences button
$importButton = New-Object System.Windows.Forms.Button
$importButton.Text = "Import"
$importButton.Width = 60
$importButton.Height = 30
$importButton.Top = $exportButton.Top
$importButton.Left = $exportButton.Left + $exportButton.Width + 20
$form.Controls.Add($importButton)

$importButton.Add_Click({
    $openDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openDialog.Title = "Import Preferences"
    $openDialog.Filter = "KOTOR Texture List (*.ktl)|*.ktl"
    $openDialog.InitialDirectory = ..\Get-Location

    if ($openDialog.ShowDialog() -eq "OK") {
        $importPath = $openDialog.FileName
        $prefs = Get-Content $importPath | Where-Object { $_ -match "\S+\s+\S+" }
        $prefDict = @{}
        foreach ($line in $prefs) {
            $parts = $line -split '\s+', 2
            if ($parts.Count -eq 2) {
                $prefDict[$parts[0]] = $parts[1]
            }
        }
        $imported = 0
        foreach ($r in $grid.Rows) {
            $name = $r.Cells[0].Value
            if ($prefDict.ContainsKey($name)) {
                $choice = $prefDict[$name]
                # Only set if it's a valid option for this row
                $cb = $r.Cells[2]
                if ($cb.Items.Contains($choice)) {
                    $cb.Value = $choice
                    $imported++
                }
            }
        }
        [System.Windows.Forms.MessageBox]::Show("Imported $imported preferences from $importPath")
    }
})

$form.Topmost = $true
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
