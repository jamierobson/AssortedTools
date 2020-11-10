#http://docwiki.embarcadero.com/RADStudio/Sydney/en/Language_Culture_Names,_Codes,_and_ISO_Values

$defaultLocate = 'da'
$desiredLocales = $($defaultLocate, 'en-GB', 'da')

$languageList = Get-WinUserLanguageList;
$languageList.Clear();
$desiredLocales | ForEach-Object {
    $languageList.Add($_);
}

Set-WinUserLanguageList $languageList

Get-WinUserLanguageList