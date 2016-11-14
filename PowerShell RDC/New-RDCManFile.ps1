function New-RDCManFile () {
    param (
        # AD Group Names
        [Parameter(Mandatory=$true)]
        [string[]]
        $OrganizationalUnit,

        # Output File
        [Parameter(Mandatory=$false)]
        [string]
        $OutputFile = '.\MyRDCFile.rdg'
    )

    Begin {
        # Get XML template
        $RdcXmlTemplatePath = Join-Path -Path $PSScriptRoot -ChildPath 'RDCTemplate.xml'
        [xml]$RdcXml = Get-Content $RdcXmlTemplatePath
        $FileElement = $RdcXml.RDCMan.file
        $FileProperties = $FileElement.properties
        $GroupTemplate = $RdcXml.RDCMan.file.group
        $ServerTemplate = $RdcXml.RDCMan.file.group.server

        # Update file properties
        $FileProperties.name = $env:userdomain
        $FileProperties.logonCredentials.Username = $env:username 
        $FileProperties.logonCredentials.Domain = $env:userdomain
    } Process {
        foreach ($OU in $OrganizationalUnit) {
            # Add Group
            $NewGroup = $GroupTemplate.Clone()
            $NewGroup.properties.name = $OU
            Write-Verbose "Adding Group: $OU"
            $null = $FileElement.AppendChild($NewGroup)

            # Add Servers
            Get-ADComputer -LDAPFilter "(operatingsystem=*server*)" |
            Where-Object {
                $_.DistinguishedName -Match "$OU"
            } |
            ForEach-Object {
                $NewServer = $ServerTemplate.Clone()
                $NewServer.DisplayName = $_.Name     
                $NewServer.Name = $_.DNSHostName
                Write-Verbose "Adding Server: $($_.Name)"
                $null = $NewGroup.AppendChild($NewServer)
            }
        }
    } End {
        $null = $FileElement.RemoveChild($GroupTemplate)
        $RdcXml.Save($OutputFile)
    }
}