function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Name,

		[parameter(Mandatory = $true)]
		[ValidateSet("Absent","Present")]
		[System.String]
		$Ensure
	)

	Write-Verbose "Gathering Module info"
    $return = @{
        Name = (Get-Module -Name $Name -ListAvailable).Name
        Ensure = $Ensure
      }
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Name,

		[parameter(Mandatory = $true)]
		[ValidateSet("Absent","Present")]
		[System.String]
		$Ensure
	)
    switch ($Ensure)
      {
        'Present' {
            Write-Verbose "adding module $Name"
            Write-Debug "Module to be loaded: $Name"
            Install-Module -Name $Name -Force
          }
        'Absent' {
            $path = (Get-Module -Name $Name -ListAvailable).ModuleBase
            Write-Verbose "Removing module: $Name"
            Write-Debug "Module path: $path"
            Remove-Item -Path $path -Force -Recurse
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
		$Name,

		[parameter(Mandatory = $true)]
		[ValidateSet("Absent","Present")]
		[System.String]
		$Ensure
	)
    if (Get-Module -Name $Name -ListAvailable) {$Exists = $true}
    Else {$Exists = $false}
    Switch ($Ensure)
      {
        'Present' {
            Switch ($Exists)
              {
                $true {
                    Write-Verbose "Module $Name is present on the system and ensure is set to $Ensure"
                    $true
                  }
                $false {
                    Write-Verbose "Module $Name is absent from the system and ensure is set to $Ensure"
                    $false
                  }
              }
          }
        'Absent' {
            Switch ($Exists)
              {
                $true {
                    Write-Verbose "Module $Name is present on the system and ensure is set to $Ensure"
                    $false
                  }
                $false {
                    Write-Verbose "Module $Name is absent from the system and ensure is set to $Ensure"
                    $true
                  }
              }
          }
      }

}


Export-ModuleMember -Function *-TargetResource

