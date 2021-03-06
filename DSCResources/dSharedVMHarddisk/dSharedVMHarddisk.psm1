function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Path,

		[parameter(Mandatory = $true)]
		[System.String]
		$VMName
	)

	#Write-Verbose "Use this cmdlet to deliver information about command processing."
    $VM = Get-VMHardDiskDrive -VMName $VMName -ErrorAction SilentlyContinue
    if ($VM.IsDeleted -eq $False ) { $Ensure = 'Present' } Else { $Ensure = 'Absent' }

	$returnValue = @{
		Path = [System.String] $Path
		Ensure = [System.String] $Ensure
		VMName = [System.String] $VMName
		ControllerNumber = [System.UInt32] $VM.ControllerNumber
		ControllerLocation = [System.UInt32] $VM.ControllerLocation
		SupportPersistentReservations = [System.Boolean] $VM.SupportPersistentReservations
	}

	$returnValue
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Path,

		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure,

		[parameter(Mandatory = $true)]
		[System.String]
		$VMName,

		[System.UInt32]
		$ControllerNumber,

		[System.UInt32]
		$ControllerLocation,

		[System.Boolean]
		$SupportPersistentReservations
	)

	Write-Verbose "Adding VM Hard Disk"

    Switch ($SupportPersistentReservations) {
        
        $true { 
            Write-Debug "Enabling virtual hard disk sharing on "
            Write-Verbose "   Virtual Machine: $VMName "
            Write-Verbose "   -- SCSI ControllerNumber: $ControllerNumber"
            Write-Verbose "   -- SCSI ControllerLocation: $ControllerLocation"

            Add-VMHardDiskDrive -VMName $VMName -Path $Path -ControllerNumber $ControllerNumber -ControllerLocation $ControllerLocation -SupportPersistentReservations
        }

        default {             
            Write-Verbose "Adding virtual hard disk on "
            Write-Verbose "       Virtual Machine: $VMName "
            Write-Verbose "       -- SCSI ControllerNumber: $ControllerNumber"
            Write-Verbose "       -- SCSI ControllerLocation: $ControllerLocation"

            Add-VMHardDiskDrive -VMName $VMName -Path $Path -ControllerNumber $ControllerNumber -ControllerLocation $ControllerLocation
        }
    }
}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Path,

		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure,

		[parameter(Mandatory = $true)]
		[System.String]
		$VMName,

		[System.UInt32]
		$ControllerNumber,

		[System.UInt32]
		$ControllerLocation,

		[System.Boolean]
		$SupportPersistentReservations
	)

            $Disk = Get-VMHardDiskDrive -VMName $VMName -ControllerNumber $ControllerNumber -ControllerLocation $ControllerLocation -ErrorAction SilentlyContinue
            
            If ( !($Disk.Path)) { return $False }
            ElseIf ( ( $Disk ) -and $Disk.SupportPersistentReservations -eq $SupportPersistentReservations ) { return $true  }
            Else {  return $false }
}

Export-ModuleMember -Function *-TargetResource
