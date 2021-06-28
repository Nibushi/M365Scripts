function Set-TISTeamArchiveState{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]$TeamDisplayName,

        [bool]$Archived = $true,

        [bool]$setSPOSiteReadOnly = $true
    )

    $team = Get-Team -DisplayName $TeamDisplayName

    $params = @{
        GroupId = $team.GroupId
        Archived = $Archived
    }

    if($Archived -eq $true){

    }

    Set-TeamArchivedState @params
    #-SetSpoSiteReadOnlyForMembers:$setSPOSiteReadOnly
}

