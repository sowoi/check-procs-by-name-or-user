function Invoke-IcingaCheckProcsbyNameorUser()
{
    # Create our arguments we can use to parse thresholds
    # Example: Invoke-IcingaCheckTutorial -Warning 10 -Critical 30
    param (
        $Warning            = $null,
        $Critical           = $null,
        [switch]$NoPerfData = $FALSE,
        # Ensure only 0-2 values are allowed for Verbosity
        [ValidateSet(0, 1, 2)]
        [int]$Verbosity     = 0,
        $UserMonProcess = $null,
	$UserMonDesired = '*',
	[int]$MaxProcsAllowed = 1
    );

    # Create a new object we can check on. This will include
    # comparing values and checking if they are between a
    # range is Unknown
    $Check  = New-IcingaCheck `
                -Name 'Count desired process' `
                -Value (
                    $countProcs = (Get-Process -Name $UserMonProcess -IncludeUserName -ErrorAction SilentlyContinue| Measure-Object | Select -Expand count)
                );
    # Add another check objects with a different name for identifying
    # which check is holding which value
    $Check2 = New-IcingaCheck `
                -Name 'Count non desired user' `
                -Value (
                        $userProcs = Get-Process -Name $UserMonProcess -IncludeUserName -ErrorAction SilentlyContinue| Where-Object UserName -Notlike *$UserMonDesired* |  Measure-Object | Select -Expand count
                );
    # Each compare function within our check object will return the
    # object itself, allowing us to write a nested call like below
    # to compare multiple values at once.
    # IMPORTANT: We have to output the last call either to Out-Null
    #            or store the result inside a variable, as the check
    #            object is otherwise written into our plugin output
   $Check.CritIfLowerEqualThan(1)  | Out-Null;
   $Check.WarnIfLowerThan($MaxProcsAllowed)  | Out-Null;
   $Check.CritIfGreaterThan($MaxProcsAllowed) | Out-Null;
   $Check2.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
 
   $CheckPackage = New-IcingaCheckPackage `
                        -Name 'Tutorial Package' `
                        -Checks @(
                            $Check,
                            $Check2
                        ) `
                        -OperatorAnd `
                        -Verbose $Verbosity;

    # Alternatively we can also call the method AddCheck
    # $CheckPackage.AddCheck($Check);
    # $CheckPackage.AddCheck($Check2);

    # Return our checkresult for the provided check and compile it
    # This function will take care to write the plugin output and
    # with return we will return the exit code to determine if our
    # check is Ok, Warning, Critical or Unknown
    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile)
}
