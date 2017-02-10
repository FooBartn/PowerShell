function Get-EsxNicDriver () {
    [CmdletBinding()]
    param (
        # VMHost
        [Parameter(Mandatory)]
        [string]
        $Name
    )

    $VMHost = Get-VMHost @PSBoundParameters
    $EsxCli = $VMHost | Get-EsxCli
    
    $EnicRaw = ($EsxCli.System.Module.Get('enic') | Select-Object Version).Version
    $EnicVer = $EnicRaw.Split(',') | Select-Object -First 1
    $Enic = $EnicVer.Replace('Version ','')
    
    $FnicRaw = ($EsxCli.System.Module.Get('fnic') | Select-Object Version).Version
    $FnicVer = $FnicRaw.Split(',') | Select-Object -First 1
    $Fnic = $FnicVer.Replace('Version ','')

    [PsCustomObject]@{
        Host = $VMHost.Name
        Enic = $Enic
        Fnic = $Fnic
    }
}
