function Start-Race {
	<#
	.SYNOPSIS
        
    
	.DESCRIPTION
        
    
    .Notes
        Written by Jason Dillman on 7-24-2019
        Rev. 1.0
    
    .EXAMPLE
	    
    
    .INPUTS
        
        
	.OUTPUTS

	#>
	Param (
		[Parameter(Mandatory,ValueFromPipeline=$true)]
        [Alias("Heat")]
        $currentHeat,
        [Parameter(Mandatory,ValueFromPipeline=$true)]
        [Alias("Pilots")]
        $pilotsThisHeat
    )
    begin {
        $pilotsInThisHeat = $pilotsThisHeat | Where-Object -Property 'Heat Number' -eq $currentHeat
        $maxDelay = $pilotsInThisHeat | 
                        Sort-Object -Property 'Start Delay' -Descending | 
                            Select-Object -ExpandProperty 'Start Delay' | 
                                Select-Object -First 1
        $i = 20
        Clear-Host
    }
    process {
        while ($i -le $maxDelay) {
            $pilotsToArm    = $pilotsInThisHeat | Where-Object {$_.'Start Delay' -eq $i + 5} | Select-Object -ExpandProperty 'Pilot Name'
            $pilotsToLaunch = $pilotsInThisHeat | Where-Object {$_.'Start Delay' -eq $i}
            Write-Output "`r"
            Write-Output "Race progress: $i"            
            if ($pilotsToLaunch){
                Write-Output "`r"
                Foreach ($pilotCurrentlyLaunching in $pilotsToLaunch) {
                    
                    Write-Host "$($pilotCurrentlyLaunching.'Pilot Name'), Go!" -ForegroundColor DarkGreen
                    #Write-Output "`r"
                }
                Foreach ($pilotCurrentlyLaunching in $pilotsToLaunch) {
                    Write-Host "$($pilotCurrentlyLaunching.'Pilot Name') is doing $($pilotCurrentlyLaunching.'Required Laps') laps." -ForegroundColor DarkGray
                }
                Write-Output "`r"
            }
            if ($pilotsToArm){
                if (-not $pilotsToLaunch) {
                    Write-Output "`r"
                }
                $pilotsToArm | Foreach-Object {
                    Write-Host "$_, arm your quad." -ForegroundColor Yellow
                    #Write-Output "`r"
                }
            }
            $i++
            #Start-Sleep -Milliseconds 500
            Start-Sleep -Seconds 1
        }
        #Start-Sleep -Seconds 60
    }
    end {Clear-Host}
}

$pilotHandicaps = Import-Csv -Path 'C:\Scripts\Handicaps.csv'
$raceStatus = $null
$currentHeat = 0
$numberOfPilotsInThisHeat = 0

while ($true) {    
    if ($numberOfPilotsInThisHeat -gt 0) {
        $raceStatus = Read-Host "Press `"Enter`" to continue racing, or type done to complete"
    }
    if ($raceStatus -like "done") {
        break
    }
    $currentHeat = 0
    $numberOfPilotsInThisHeat = 0
    while ($numberOfPilotsInThisHeat -eq 0) {
        [int]$currentHeat = Read-Host "Current heat number"
        $numberOfPilotsInThisHeat = ($pilotHandicaps | Where-Object -Property 'Heat Number' -eq $currentHeat).count
        if ($numberOfPilotsInThisHeat -eq 0) {
            Write-Output "No pilots found in heat $currentHeat!"
            $currentHeat = $null
            continue
        }
        Write-Output "$numberOfPilotsInThisHeat pilots on the line for heat $currentHeat"
        Write-Output $pilotHandicaps | Where-Object -Property 'Heat Number' -eq $currentHeat | Select-Object -ExpandProperty 'Pilot Name'

    }
Read-Host "Press `"Enter`" to start"
Start-Race -Heat $currentHeat -Pilots $pilotHandicaps
}