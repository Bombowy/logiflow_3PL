[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

# Ustal sciezki niezaleznie od biezacego katalogu pracy.
# Resolve paths independently of the current working directory.
$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$djangoRoot = Join-Path $repositoryRoot "backend\django-platform"
$python = Join-Path $djangoRoot ".venv\Scripts\python.exe"
$managePy = Join-Path $djangoRoot "manage.py"
$pytestConfig = Join-Path $djangoRoot "pytest.ini"

if (-not (Test-Path -LiteralPath $python -PathType Leaf)) {
    throw "Brak interpretera .venv / Missing .venv interpreter: $python"
}

function Invoke-Validation {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string[]]$Arguments
    )

    Write-Host "`n=== $Name ==="
    & $python @Arguments
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Walidacja nie powiodla sie / Validation failed: $Name"
        exit $LASTEXITCODE
    }
}

# Uruchom pytest z katalogu zawierajacego testpaths i zawsze przywroc lokalizacje.
# Run pytest from the testpaths directory and always restore the location.
Push-Location $djangoRoot
try {
    Invoke-Validation -Name "Django system check" -Arguments @($managePy, "check")
    Invoke-Validation -Name "Python tests" -Arguments @("-m", "pytest", "-c", $pytestConfig)
    Invoke-Validation -Name "Ruff" -Arguments @("-m", "ruff", "check", $djangoRoot)

    Write-Host "`nWszystkie kontrole Python przeszly / All Python checks passed."
}
finally {
    Pop-Location
}
