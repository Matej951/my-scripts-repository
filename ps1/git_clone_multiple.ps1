# Define the root directory
$rootDir = "C:\Develop\Git"

# Define repositories grouped by subdirectory
$repositories = @{
    "client" = @(
		"repo",
		"repo"
		)
	"client" = @(
        "repo",
		"repo"
		)
	"client" = @(
        "repo",
		"repo"
		)
	"client" = @(
        "repo",
		"repo"
		)
}

# Loop through each group and clone repositories into corresponding subdirectories
foreach ($group in $repositories.Keys) {
    $groupDir = Join-Path -Path $rootDir -ChildPath $group
    if (-not (Test-Path -Path $groupDir -PathType Container)) {
        New-Item -Path $groupDir -ItemType Directory | Out-Null
    }
    
    foreach ($repoUrl in $repositories[$group]) {
        $repoName = [System.IO.Path]::GetFileNameWithoutExtension($repoUrl)
        $repoDir = Join-Path -Path $groupDir -ChildPath $repoName
        git clone $repoUrl $repoDir
    }
}