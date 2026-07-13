[CmdletBinding()]
param(
    [Parameter()]
    [string]$OutputPath = "logiflow-code.txt"
)

$ErrorActionPreference = "Stop"

# Ustal katalog repozytorium niezaleznie od biezacego katalogu pracy.
# Resolve the repository root independently of the current working directory.
$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

if ([IO.Path]::IsPathRooted($OutputPath)) {
    $outputFullPath = [IO.Path]::GetFullPath($OutputPath)
}
else {
    $outputFullPath = [IO.Path]::GetFullPath((Join-Path $repositoryRoot $OutputPath))
}

$outputDirectory = [IO.Path]::GetDirectoryName($outputFullPath)
if (-not [string]::IsNullOrWhiteSpace($outputDirectory)) {
    [IO.Directory]::CreateDirectory($outputDirectory) | Out-Null
}

# Git zapewnia respektowanie .gitignore i pominiecie lokalnych artefaktow.
# Git ensures that .gitignore and local artifact exclusions are respected.
$relativeFiles = @(& git -C $repositoryRoot ls-files --cached --others --exclude-standard)
if ($LASTEXITCODE -ne 0) {
    throw "Nie udalo sie pobrac listy plikow z Git. / Failed to obtain the file list from Git."
}

$textExtensions = @(
    ".cfg", ".config", ".cs", ".csproj", ".dart", ".gradle", ".http",
    ".ini", ".json", ".kt", ".kts", ".lock", ".md", ".properties",
    ".ps1", ".py", ".sh", ".sln", ".toml", ".txt", ".xml", ".yaml", ".yml"
)

$textFileNames = @(
    ".editorconfig", ".env.example", ".gitattributes", ".gitignore", ".metadata",
    "Dockerfile", "Makefile"
)

$excludedSecretExtensions = @(
    ".cer", ".crt", ".jks", ".key", ".keystore", ".p12", ".pem", ".pfx"
)

$builder = [Text.StringBuilder]::new()
$includedCount = 0
$skippedCount = 0

[void]$builder.AppendLine("LogiFlow 3PL - eksport kodu do przegladu / code review export")
[void]$builder.AppendLine("Utworzono / Generated: $([DateTimeOffset]::Now.ToString('yyyy-MM-dd HH:mm:ss zzz'))")
[void]$builder.AppendLine("Katalog / Repository: $repositoryRoot")
[void]$builder.AppendLine()

foreach ($relativePath in ($relativeFiles | Sort-Object -Unique)) {
    $normalizedPath = $relativePath.Replace("\", "/")
    $fullPath = [IO.Path]::GetFullPath((Join-Path $repositoryRoot $relativePath))
    $fileName = [IO.Path]::GetFileName($fullPath)
    $extension = [IO.Path]::GetExtension($fullPath).ToLowerInvariant()

    if ($fullPath -eq $outputFullPath) {
        continue
    }

    # Pomin typowe lokalizacje i formaty sekretow nawet przy blednym .gitignore.
    # Skip common secret locations and formats even when .gitignore is incomplete.
    $isEnvironmentSecret = $fileName -like ".env*" -and $fileName -ne ".env.example"
    $isSensitivePath = $normalizedPath -match "(^|/)(secrets?|credentials?)(/|$)"
    $isSensitiveName = $fileName -in @("local.properties", "key.properties")
    $isSensitiveExtension = $extension -in $excludedSecretExtensions

    if ($isEnvironmentSecret -or $isSensitivePath -or $isSensitiveName -or $isSensitiveExtension) {
        $skippedCount++
        continue
    }

    $isTextFile = ($extension -in $textExtensions) -or ($fileName -in $textFileNames)
    if (-not $isTextFile -or -not [IO.File]::Exists($fullPath)) {
        $skippedCount++
        continue
    }

    $content = [IO.File]::ReadAllText($fullPath)
    [void]$builder.AppendLine(("=" * 100))
    [void]$builder.AppendLine("PLIK / FILE: $normalizedPath")
    [void]$builder.AppendLine(("=" * 100))
    [void]$builder.AppendLine($content.TrimEnd())
    [void]$builder.AppendLine()
    [void]$builder.AppendLine()
    $includedCount++
}

[void]$builder.AppendLine(("=" * 100))
[void]$builder.AppendLine("PODSUMOWANIE / SUMMARY")
[void]$builder.AppendLine("Dolaczone pliki / Included files: $includedCount")
[void]$builder.AppendLine("Pominiete pliki / Skipped files: $skippedCount")

[IO.File]::WriteAllText($outputFullPath, $builder.ToString(), [Text.UTF8Encoding]::new($false))

Write-Host "Utworzono eksport / Export created: $outputFullPath"
Write-Host "Dolaczone pliki / Included files: $includedCount"
Write-Host "Pominiete pliki / Skipped files: $skippedCount"
Write-Warning "Przed udostepnieniem przejrzyj plik pod katem danych wrazliwych. / Review the file for sensitive data before sharing."
