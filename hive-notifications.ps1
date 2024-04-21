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

$response = Invoke-WebRequest -Uri $uri -Method Post -Body $jsonBody -UseBasicParsing | ConvertFrom-Json | Select-Object -ExpandProperty result

for ($i = 0; $i -lt $response.Count; $i++){
    # reads $response.msg[$i] and checks if contains the words "replied to your post"
    if ($response.msg[$i].Contains("replied to your post"))
    {
        Write-Host $($response.id[$i])
        Write-Host $($response.msg[$i])
        Write-Host $($response.url[$i])
        #from $response.url[$i] split text, simbol "/" is the braekpoint
        $url = $response.url[$i].Split("/")
        $username = $url[0].Split("@")

        $get_reply = @{
            jsonrpc = "2.0";
            method = "condenser_api.get_content";
            params = @($username[1],$url[1]);
            id = 1
            } | ConvertTo-Json
        $reply_response = Invoke-WebRequest -Uri $uri -Method Post -Body $get_reply -UseBasicParsing | ConvertFrom-Json | Select-Object -ExpandProperty result

        # trim $reply_response.body to 65 characters
        # IF $replay_response.body.length > 65, then it will be trimmed to 65 characters if not it will be printed as is
        if ($reply_response.body.Length -gt 65){
            Write-Host "$($reply_response.body.Substring(0,65))..."
        }
        else{
            Write-Host $reply_response.body
        }
        Write-Host ""
    }
}