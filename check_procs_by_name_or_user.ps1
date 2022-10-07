# Developer: Massoud Ahmed
# this powershell script checks the number of background processes of a given application. 
# optionally, it is possible to specify a user who owns the processes.

# name of process
$param1=$args[0]
# critical processcount
$param2=$args[1]
# desired user
$param3=$args[2]


$returnStateOK = 0
$returnStateWarning = 1
$returnStateCritical = 2
$returnStateUnknown = 3


$countProcs = Get-Process -Name $param1 -IncludeUserName -ErrorAction SilentlyContinue| Measure-Object | Select -Expand count

if($param3){
$overallProcs = Get-Process -Name $param1 -ErrorAction SilentlyContinue| Measure-Object | Select -Expand count
$userProcs = Get-Process -Name $param1 -IncludeUserName -ErrorAction SilentlyContinue| Where-Object UserName -Like $param3* |  Measure-Object | Select -Expand count
$userProcsFalse = Get-Process -Name $param1 -IncludeUserName -ErrorAction SilentlyContinue| Where-Object UserName -Notlike $param3* | Select-Object -Expand UserName
$countingFalse = $userProcsFalse | Measure-Object | Select -Expand count


if ($countProcs -eq 0){
    Write-Host "CRITICAL: Could not find any process named $param1"
	exit 2}
elseif ($countingFalse -ge 0 ) {
Write-Host "CRITICAL: Found $overallProcs $param1 process running. $countingFalse User which shouldn't run this program: $userProcsFalse"
exit 2
}
elseif ($countProcs -gt $param2){
 	Write-Host "CRITICAL: Found more than $param2 process of $param1"
	exit 2
}
else{
 Write-Host "OK: Found $param2 process running of $param1 .  All procs are run by user $param3"
 exit 0

}

}

else{
if ($countProcs -le $param2){
   if ($countProcs -eq 0){
    Write-Host "CRITICAL: Could not find any process named $param1"
	exit 2}
   else{

    Write-Host $countProcs
	Write-Host "OK: Found $param2 process running of $param1"
	exit 0}
}
else{ 
Write-Host "CRITICAL: Found more than $param2 process of $param1"
exit 2
}
}
