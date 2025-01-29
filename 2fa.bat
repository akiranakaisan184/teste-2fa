@echo off
powershell -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -Command "& {
$innosetup = 'tacticalagent-v2.8.0-windows-amd64.exe';
$api = '\"https://api.atendepj.com\"';
$clientid = '1';
$siteid = '1';
$agenttype = '\"server\"';
$auth = '\"93dac48f2f2c4399bf9ad6c33cff2407062a5b5c6568ced9d57239dca1c1a6d1\"';
$downloadlink = 'https://github.com/amidaware/rmmagent/releases/download/v2.8.0/tacticalagent-v2.8.0-windows-amd64.exe';
$apilink = $downloadlink -split '/';

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;

$OutPath = $env:TMP;
$output = $innosetup;

$installArgs = @('-m install --api ', $api, '--client-id', $clientid, '--site-id', $siteid, '--agent-type', $agenttype, '--auth', $auth);

Try {
    $DefenderStatus = Get-MpComputerStatus | Select-Object AntivirusEnabled;
    if ($DefenderStatus.AntivirusEnabled -eq $true) {
        Add-MpPreference -ExclusionPath 'C:\Program Files\TacticalAgent\*';
        Add-MpPreference -ExclusionPath 'C:\ProgramData\TacticalRMM\*';
    }
} Catch {}

$X = 0;
do {
    Start-Sleep -s 5;
    $X += 1;
} until(($connectresult = Test-NetConnection $apilink[2] -Port 443 | Where-Object { $_.TcpTestSucceeded }) -or $X -eq 3);

if ($connectresult.TcpTestSucceeded -eq $true){
    Try {
        Invoke-WebRequest -Uri $downloadlink -OutFile $OutPath\$output;
        Start-Process -FilePath $OutPath\$output -ArgumentList ('/VERYSILENT /SUPPRESSMSGBOXES') -Wait;
        Start-Sleep -s 5;
        Start-Process -FilePath 'C:\Program Files\TacticalAgent\tacticalrmm.exe' -ArgumentList $installArgs -Wait;
        exit 0;
    } Catch {
        exit 1;
    } Finally {
        Remove-Item -Path $OutPath\$output;
    }
} else {
    exit 1;
} }"
exit
