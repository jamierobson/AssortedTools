function Append-LineWithSpacing {
Param(
    [Parameter(Mandatory=$true, Position=0)]
    [System.Text.StringBuilder] $stringBuilder, 
    [Parameter(Mandatory=$true, Position=1)]
    [string] $string
)
    $stringBuilder.AppendLine($string) | Out-Null
    $stringBuilder.AppendLine() | Out-Null
}

function Get-UserPromptText {

    $stringBuilder = [System.Text.StringBuilder]::new();
    
    Append-LineWithSpacing $stringBuilder "Enter your personal access token";
    Append-LineWithSpacing $stringBuilder "To generate your personal access token: ";
    Append-LineWithSpacing $stringBuilder "1. Open the user settings > tokens menu on devops";
    Append-LineWithSpacing $stringBuilder "2. Add a new token, with the scope PACKAGE READ only, and and appropriate expiry. The shorter this is, the more often you'll have to repeat this process";
    Append-LineWithSpacing $stringBuilder "3. Copy the token, and paste it below. If you navigate away from the page before copying it, you'll never be able to retrieve the secret again";
    Append-LineWithSpacing $stringBuilder "*** NOTE: If you navigate away from the page before copying it, you'll never be able to retrieve the secret again, and will have to regenerate the token ***";

    return $stringBuilder.ToString();
}

function Create-FunctionallyCompleteNugetConfigFile {

    New-Item -ItemType Directory -Force -Path $env:USERPROFILE/.nuget > $null;
    $userPropmptMessage = Get-UserPromptText;
    $personalAccessTokenSecure = Read-Host -Prompt $userPropmptMessage -AsSecureString ;
    $personalAccessToken = [System.Net.NetworkCredential]::new([string]::Empty, $personalAccessTokenSecure).Password;

    (Get-Content -Path .\template-nuget.config -raw) `
        -replace "#{pat}#", $personalAccessToken `
        | Set-Content .\nuget.config;
}

Create-FunctionallyCompleteNugetConfigFile;
Copy-Item -Path .\nuget.config "$env:USERPROFILE\.nuget"