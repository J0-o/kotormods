$folder = $args[0]

Get-ChildItem -Path $folder -Filter *.tga | Select-Object -ExpandProperty Name | Out-File -Encoding UTF8 "tga.txt"
Get-ChildItem -Path $folder -Filter *.tpc | Select-Object -ExpandProperty Name | Out-File -Encoding UTF8 "tpc.txt"
Get-ChildItem -Path $folder -Filter *.txi | Select-Object -ExpandProperty Name | Out-File -Encoding UTF8 "txi.txt"

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
$tga = Get-Content "tga.txt" | Where-Object { $_ -ne "" }
$tpc = Get-Content "tpc.txt" | Where-Object { $_ -ne "" }
$txi = Get-Content "txi.txt" | Where-Object { $_ -ne "" }

# Base names
$tgaSet = $tga | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) }
$tpcSet = $tpc | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) }
$txiSet = $txi | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) }

# Find conflicts: any base name with TPC and (TGA or TXI)
$conflicts = ($tpcSet | Where-Object { ($tgaSet -contains $_) -or ($txiSet -contains $_) } | Sort-Object)

# Data for grid
$data = foreach ($name in $conflicts) {
    $exts = @()
    if ($tgaSet -contains $name) { $exts += "TGA" }
    if ($txiSet -contains $name) { $exts += "TXI" }
    if ($tpcSet -contains $name) { $exts += "TPC" }
    [PSCustomObject]@{
        Name = $name
        Extensions = ($exts -join ", ")
        DefaultChoice = "TPC"   # Default to TPC
    }
}

# Build Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "KOTOR Texture Conflict Checker"
$form.Width = 700
$form.Height = 600

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
# $grid.Columns[2] (Choice) stays editable for dropdown


# Dropdown for last column
$col = New-Object System.Windows.Forms.DataGridViewComboBoxColumn
$col.HeaderText = "Keep"
$col.Name = "Choice"
$col.Width = 150
$col.Items.AddRange(@("TPC", "TGA+TXI"))
$grid.Columns.RemoveAt(2)
$grid.Columns.Add($col)

# Fill Grid
foreach ($row in $data) {
    $rowIdx = $grid.Rows.Add($row.Name, $row.Extensions)
    $cb = $grid.Rows[$rowIdx].Cells[2]
    $cb.Value = $row.DefaultChoice
}

$form.Controls.Add($grid)

# Button to process selection
$button = New-Object System.Windows.Forms.Button
$button.Text = "Process"
$button.Width = 120
$button.Height = 30
$button.Top = $grid.Bottom + 10
$button.Left = 10
$form.Controls.Add($button)

$button.Add_Click({
    $results = @()
    $srcFolder = "override"  # Or set this to your override folder path
    $destFolder = "texture_duplicates"
    if (-not (Test-Path $destFolder)) {
        New-Item -ItemType Directory -Path $destFolder | Out-Null
    }

    foreach ($r in $grid.Rows) {
        $name = $r.Cells[0].Value
        $exts = $r.Cells[1].Value -split ",\s*"
        $choice = $r.Cells[2].Value

        if ($choice -eq "TPC") {
            # Move TGA and TXI if they exist
            foreach ($ext in @("TGA", "TXI")) {
                if ($exts -contains $ext) {
                    $src = Join-Path $srcFolder "$name.$($ext.ToLower())"
                    if (Test-Path $src) {
                        Move-Item $src -Destination $destFolder -Force
                        #$results += "Moved: $name.$($ext.ToLower())"
                    }
                }
            }
        } elseif ($choice -eq "TGA+TXI") {
            # Move TPC if it exists
            if ($exts -contains "TPC") {
                $src = Join-Path $srcFolder "$name.tpc"
                if (Test-Path $src) {
                    Move-Item $src -Destination $destFolder -Force
                    #$results += "Moved: $name.tpc"
                }
            }
        }
    }
    [System.Windows.Forms.MessageBox]::Show("Textures Moved`n" + ($results -join "`n"))
    $form.Close()
})
Update-ProcessButtonState

# Restore button to move everything from texture_duplicates back to override
$restoreButton = New-Object System.Windows.Forms.Button
$restoreButton.Text = "Restore"
$restoreButton.Width = 120
$restoreButton.Height = 30
$restoreButton.Top = $button.Top
$restoreButton.Left = $button.Left + $button.Width + 20
$form.Controls.Add($restoreButton)

$restoreButton.Add_Click({
    $srcFolder = "texture_duplicates"
    $destFolder = "override"
    $results = @()
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
        #$results += "Restored: $($file.Name)"
    }
    [System.Windows.Forms.MessageBox]::Show("Restore complete`n" + ($results -join "`n"))
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


$form.Topmost = $true
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
