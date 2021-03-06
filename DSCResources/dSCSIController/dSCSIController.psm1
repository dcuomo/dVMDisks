function Get-TargetResource {
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$VMName
	)

	Write-Verbose "Number of SCSI Controllers on $VMName"
    $CurrentNumber = (Get-VMScsiController -VMName $VMName).Count

	$returnValue = @{
		VMName = [System.String] $VMName
		Number = [System.UInt32] $CurrentNumber
	}

	$returnValue
}


function Set-TargetResource {
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$VMName,

		[System.UInt32]
		$Number
	)

    $CurrentNumber = (Get-VMScsiController -VMName $VMName).Count
	
    Write-Debug "Adding VM SCSI Controller"
    
    While ( $CurrentNumber -lt $Number ) { Add-VMScsiController $VMName; $CurrentNumber = (Get-VMScsiController -VMName $VMName).Count }
    
    Write-Verbose "Done adding VM SCSI Controller - Total Controllers: $CurrentNumber"
}


function Test-TargetResource {
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$VMName,

		[System.UInt32]
		$Number
	)

	Write-Verbose "Looking for SCSI Controllers"
    
    $CurrentNumber = (Get-VMScsiController -VMName $VMName).Count
    
    If ( $CurrentNumber -eq $Number ) { $result = $true } Else { $result = $false }
	
	$result
}

Export-ModuleMember -Function *-TargetResource
