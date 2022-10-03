## http://docwiki.embarcadero.com/RADStudio/Sydney/en/Language_Culture_Names,_Codes,_and_ISO_Values

class LanguageSetting
{
    [string] $Locale;
    [string] $GeoId;

    LanguageSetting([string]$locale, [string]$geoId)
    {
        $this.Locale = $locale;
        $this.GeoId = $geoId;
    }
}

$uk = [LanguageSetting]::new("en-GB", "0xf2");
$denmark = [LanguageSetting]::new("da", "0x3d");

$desiredLocales = $($uk, $denmark)


$languageList = Get-WinUserLanguageList;
$languageList.Clear();

$desiredLocales.Locale | ForEach-Object {
    $languageList.Add($_);
}

Set-WinHomeLocation -GeoId $denmark.GeoId;
Set-WinUILanguageOverride -Language $uk.Locale
Set-WinUserLanguageList $languageList
Get-WinUserLanguageList
