$bytes = [System.IO.File]::ReadAllBytes("C:\temp\oosuconfig.cfg")
[Convert]::ToBase64String($bytes) | Set-Clipboard
