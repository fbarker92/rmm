Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$downloadUri = 'https://raw.githubusercontent.com/fbarker92/rmm/refs/heads/main/spiringwest/lab/trmm-springwest-lab-server-amd64.exe'
$apiUri = $downloadUri.split('/')
$outPath = $env:TMP
$outFile = $downloadUri.Split('/')[-1]

Try
    {
        $DefenderStatus = Get-MpComputerStatus | Select-Object  AntivirusEnabled
        if ($DefenderStatus -match "True") {
           Add-MpPreference -ExclusionPath 'C:\Program Files\TacticalAgent\*'
           Add-MpPreference -ExclusionPath 'C:\Program Files\Mesh Agent\*'
           Add-MpPreference -ExclusionPath 'C:\ProgramData\TacticalRMM\*'
        }
    }
    Catch {
        # pass
    }

 $X = 0
    do {
      Write-Output "Waiting for network"
      Start-Sleep -s 5
      $X += 1      
    } until(($connectresult = Test-NetConnection $apiUri[2] -Port 443 | Where-Object { $_.TcpTestSucceeded }) -or $X -eq 3)
    
    if ($connectresult.TcpTestSucceeded -eq $true){
        Try
        {  
            Invoke-WebRequest -Uri $downloadUri -OutFile "$outPath\$outFile"
            Start-Process -FilePath $outPath\$outFile -ArgumentList ('/VERYSILENT /SUPPRESSMSGBOXES') -Wait
            exit 0
        }
        Catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Error -Message "$ErrorMessage $FailedItem"
            exit 1
        }
        Finally
        {
            Remove-Item -Path "$outPath\$outFile"
        }
    } else {
        Write-Output "Unable to connect to server"
    }
