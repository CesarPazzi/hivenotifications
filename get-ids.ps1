$uri = 'https://api.hive.blog'
$jsonBody = @{
jsonrpc = "2.0";
method = "bridge.account_notifications";
params = @{
account = "t0xicgh0st";
limit = 100
};
id = 1
} | ConvertTo-Json
$account = (ConvertFrom-Json $jsonBody).params.account
$response = Invoke-WebRequest -Uri $uri -Method Post -Body $jsonBody -UseBasicParsing | ConvertFrom-Json | Select-Object -ExpandProperty result

if (!(Test-Path -Path "$account.txt")) {
    New-Item -ItemType File -Path "$account.txt" -Force
}


for ($i = 0; $i -lt $response.Count; $i++){
    if ($response.msg[$i].Contains("replied to your post") -or $response.msg[$i].Contains("replied to your comment") -or $response.msg[$i].Contains("mentioned you"))
    {
        $id = $response.id[$i]
        $id | Add-Content -Path "$account.txt" -Force
    }
}