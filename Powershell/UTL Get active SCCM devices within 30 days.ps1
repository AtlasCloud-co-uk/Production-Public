Import-Module SqlServer # C:\Windows\System32\WindowsPowerShell\v1.0\Modules\SqlServer

$ServerInstance = "PUL-SQL03\MECM"
$Database = "CM_PUL"

$Queries = @(
# [0] - return the count
@"
SELECT
    COUNT(*) AS [Total Count]
FROM
    v_R_System SYS
INNER JOIN
    CH_ClientSummary ClientSummary ON SYS.ResourceID = ClientSummary.MachineID
WHERE
    DATEDIFF(dd, ClientSummary.LastPolicyRequest, GETDATE()) <= 30
"@,
# [1] - return the list
@"
SELECT
    SYS.Name0 AS [Computer Name],
    ClientSummary.LastPolicyRequest AS [Last Policy Request]
FROM
    v_R_System SYS
INNER JOIN
    CH_ClientSummary ClientSummary ON SYS.ResourceID = ClientSummary.MachineID
WHERE
    DATEDIFF(dd, ClientSummary.LastPolicyRequest, GETDATE()) <= 30
ORDER BY
    [Computer Name]
"@
)

for ($i = 0; $i -lt 2; $i++) {
    switch ($i) {
        0 { Write-Output "`nThis is the count of SCCM devices that have checked in within the last 30 days:`n`n" }
    }
    $result = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $Queries[$i] -TrustServerCertificate

    switch ($i) {
        0 { $result | Format-Table -AutoSize; Read-Host -Prompt "`nPress Enter for server list" }
        1 { $result | Out-GridView -Title "This is the full list of the reported devices" }
    }
}

