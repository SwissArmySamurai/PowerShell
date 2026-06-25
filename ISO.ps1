# ========== CONFIG ==========
$VHDXPath = "C:\VMs\MyVM.vhdx"
$MountPath = "E:\"
$WorkingDir = "C:\CustomISO"
$ISOOutput = "C:\CustomWin11.iso"
$OscdimgPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
$BootSectorPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\etfsboot.com"

# ========== STEP 1: Mount VHD ==========
Write-Host "📦 Mounting VHD..." -ForegroundColor Cyan
Mount-DiskImage -ImagePath $VHDXPath -StorageType VHDX -PassThru | Out-Null
Start-Sleep -Seconds 3

# Get the drive letter
$driveLetter = (Get-Volume | Where-Object { $_.FileSystemLabel -eq "Windows" -or $_.DriveType -eq 'Fixed' } | Select-Object -First 1).DriveLetter + ":"

# ========== STEP 2: Copy OS Files ==========
Write-Host "📁 Copying OS files to $WorkingDir..." -ForegroundColor Cyan
Remove-Item -Path $WorkingDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $WorkingDir | Out-Null
robocopy "$driveLetter\" "$WorkingDir" /E /XJ /COPYALL

# ========== STEP 3: Capture WIM ==========
$WimOutput = "$WorkingDir\sources\install.wim"
New-Item -ItemType Directory -Path "$WorkingDir\sources" -Force | Out-Null

Write-Host "📸 Capturing image to WIM..." -ForegroundColor Cyan
dism /Capture-Image /ImageFile:$WimOutput /CaptureDir:$driveLetter\ /Name:"CustomWin11" /Compress:Max

# ========== STEP 4: Add Boot Files ==========
Write-Host "🧱 Copying boot files..." -ForegroundColor Cyan
# Assuming you have a stock WinPE or setup ISO mounted at D:
$WindowsISOMount = "D:"  # Change if needed
Copy-Item "$WindowsISOMount\boot" -Destination $WorkingDir -Recurse
Copy-Item "$WindowsISOMount\efi" -Destination $WorkingDir -Recurse
Copy-Item "$WindowsISOMount\sources\boot.wim" "$WorkingDir\sources" -Force
Copy-Item "$WindowsISOMount\bootmgr" "$WorkingDir"
Copy-Item "$WindowsISOMount\bootmgr.efi" "$WorkingDir"

# ========== STEP 5: Create ISO ==========
Write-Host "💿 Creating bootable ISO..." -ForegroundColor Cyan
& "$OscdimgPath" -b"$BootSectorPath" -u2 -h -m -lCUSTOM_WIN11 "$WorkingDir" "$ISOOutput"

Write-Host "✅ ISO created: $ISOOutput" -ForegroundColor Green

# ========== Cleanup ==========
Write-Host "🧹 Cleaning up..." -ForegroundColor Cyan
Dismount-DiskImage -ImagePath $VHDXPath
