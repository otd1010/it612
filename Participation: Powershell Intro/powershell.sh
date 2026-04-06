Get-Command *Process* | Select-Object -First 5
Get-Command *Item* | Select-Object -First 5

Get-Process | Get-Member | Select-Object -First 15

Get-Process | 
    Sort-Object WorkingSet64 -Descending | 
    Select-Object -First 5 Name, @{N='MB';E={[math]::Round($_.WorkingSet64/1MB,1)}} |
    Format-Table

Get-ChildItem -Path . -File | 
    Group-Object Extension | 
    Sort-Object Count -Descending | 
    Select-Object Count, Name

Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Length -gt 1KB -and $_.LastWriteTime -gt (Get-Date).AddHours(-24) } |
    Sort-Object Length -Descending |
    Select-Object Name, @{N='KB';E={[math]::Round($_.Length/1KB,1)}}, LastWriteTime |
    Select-Object -First 3

$jsonContent = @'
[
  {"name": "Alice", "course": "CS101", "grade": 92, "semester": "Fall"},
  {"name": "Bob", "course": "CS101", "grade": 78, "semester": "Fall"},
  {"name": "Charlie", "course": "CS201", "grade": 88, "semester": "Fall"},
  {"name": "Alice", "course": "CS201", "grade": 95, "semester": "Fall"},
  {"name": "Diana", "course": "CS101", "grade": 65, "semester": "Spring"},
  {"name": "Bob", "course": "CS201", "grade": 82, "semester": "Spring"},
  {"name": "Eve", "course": "CS101", "grade": 91, "semester": "Spring"},
  {"name": "Charlie", "course": "CS101", "grade": 73, "semester": "Spring"},
  {"name": "Alice", "course": "CS301", "grade": 97, "semester": "Spring"},
  {"name": "Diana", "course": "CS201", "grade": 71, "semester": "Spring"},
  {"name": "Frank", "course": "CS101", "grade": 84, "semester": "Fall"},
  {"name": "Eve", "course": "CS201", "grade": 89, "semester": "Fall"}
]
'@ 
$jsonContent | Set-Content students.json

$students = Get-Content students.json | ConvertFrom-Json

$students | Where-Object { $_.grade -gt 90 } | Select-Object name, course, grade

$students | Group-Object name | ForEach-Object {
    [PSCustomObject]@{
        Student = $_.Name
        GPA     = [math]::Round(($_.Group | Measure-Object grade -Average).Average, 1)
        Courses = $_.Count
    }
} | Sort-Object GPA -Descending | Format-Table

$students |
    Select-Object name, course, grade, @{N='letter';E={
        if ($_.grade -ge 90) {'A'} elseif ($_.grade -ge 80) {'B'}
        elseif ($_.grade -ge 70) {'C'} else {'F'}
    }} |
    Export-Csv grades-report.csv -NoTypeInformation

Import-Csv grades-report.csv | Select-Object -First 5

try {
    $repo = Invoke-RestMethod "https://api.github.com/repos/PowerShell/PowerShell"
    $repo.full_name
    $repo.stargazers_count
} catch {}

[System.Environment]::OSVersion
[System.Environment]::ProcessorCount
$PSVersionTable.PSVersion