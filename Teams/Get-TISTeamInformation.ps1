[CmdletBinding()]
param(
    # Use the GUID of the group as multiple groups can have the same name
    [Parameter(Mandatory)]
    [string]$groupId
)

$team = Get-Team -GroupId $groupId

$ChannelInfo = Get-TeamChannel -GroupId $team.GroupId

$users = Get-TeamUser -GroupId $team.GroupId

if($null -eq $team.Classification){
    $classification = "None Applied"
} else {
    $classification = $team.Classification
}

$generalSettings = [PSCustomObject]@{
    "Display Name" = $team.DisplayName
    Description = $team.Description
    "Group id" = $team.GroupId
    Visibility = $team.Visibility
    "Email Nickname" = $team.MailNickName
    "Classification" = $classification
    "Site is Archived" = $team.Archived
}

$memberSettings = [PSCustomObject]@{
    "Allow members to create and update channels" = $team.AllowCreateUpdateChannels
    "Allow members to create private channels" = $team.AllowCreatePrivateChannels
    "Allow members to delete and restore channels" = $team.AllowDeleteChannels
    "Allow members to add and remove apps" = $team.AllowAddRemoveApps
    "Allow members to create, update, and remove tabs" = $team.AllowCreateUpdateRemoveTabs
    "Allow members to create, update, and remove connectors" = $team.AllowCreateUpdateRemoveConnectors
    "Give members the option to delete their messages" = $team.AllowUserDeleteMessages
    "Give members the option to edit their messages" = $team.AllowUserEditMessages
}

$guestSettings = [PSCustomObject]@{
    "Allow guests to create and update channels" = $team.AllowGuestCreateUpdateChannels
    "Allow guests to delete channels" = $team.AllowGuestDeleteChannels
}

$mentionSettings = [PSCustomObject]@{
    "Show members the option to @team name" = $team.AllowTeamMentions
    "Give members the option to @channel name" = $team.AllowChannelMentions
}

$funSettings = [PSCustomObject]@{
    "Enable Giphy for this team" = $team.AllowGiphy
    "Giphy Content Rating" = $team.GiphyContentRating
    "Enable Stickers and Memes" = $team.AllowStickersAndMemes
    "Allow memes to be uploaded" = $team.AllowCustomMemes
}

$currFolder = $PSScriptRoot
$styleSheetPath =  Join-Path $currFolder "styles.css"
$styleInfo = Get-Content -Path $styleSheetPath -Raw
$css = "<style>$styleInfo</style>"

$TeamName = "<h1>$($team.DisplayName) - Detailed Information</h1>"
$generalInfo = $generalSettings | ConvertTo-Html -As List -Fragment -PreContent "<h2>General Team Info</h2>"
$generalInfo = $generalInfo -replace "<table>","<table class='AsList'>"

$Members = $users | ConvertTo-Html -As Table -Property User, Name, Role -PreContent "<h2>Team Members</h2>"
$Channels = $ChannelInfo | ConvertTo-Html -As Table -Property DisplayName, Description, MembershipType -PreContent "<h2>Channels</h2>"

$memberPermissions = $memberSettings | ConvertTo-Html -As List -Fragment -PreContent "<h2>Member Permissions</h2>"
$memberPermissions = $memberPermissions -replace "<table>","<table class='AsList'>"

$guestPermissions = $guestSettings | ConvertTo-Html -As List -Fragment -PreContent "<h2>Guest Permissions</h2>"
$guestPermissions = $guestPermissions -replace "<table>","<table class='AsList'>"

$mentions = $mentionSettings | ConvertTo-Html -As List -Fragment -PreContent "<h2>@Mentions</h2>"
$mentions = $mentions -replace "<table>","<table class='AsList'>"

$funstuff = $funSettings | ConvertTo-Html -As List -Fragment -PreContent "<h2>Fun Stuff</h2>"
$funstuff = $funstuff -replace "<table>","<table class='AsList'>"

$Report = ConvertTo-Html -Body "$TeamName $generalInfo $Members $channels $memberPermissions $guestPermissions $mentions $funstuff" -Head $css -Title "$($team.DisplayName) Information Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)<p>"
$Report = $Report -replace "<td>True</td>", "<td class='valueIsTrue'>True</td>"
$Report = $Report -replace "<td>False</td>", "<td class='valueIsFalse'>False</td>"

$Report | Out-File -FilePath (Join-Path $currFolder "Basic-Information-Report.html")

Explorer .\Basic-Information-Report.html
