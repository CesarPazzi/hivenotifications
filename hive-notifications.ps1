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

$latest_local_id = Get-Content -Path "$account.txt" -ErrorAction SilentlyContinue | Select-Object -First 1
$latest_id = $response[0].id

if ($latest_local_id -ne $latest_id){
        for ($i = 0; $i -lt $response.Count; $i++){
                if ($response.msg[$i].Contains("replied to your post") -or $response.msg[$i].Contains("replied to your comment") -or $response.msg[$i].Contains("mentioned you"))
                { 
                        if ($response.id[$i] -eq $latest_local_id){
                                
                                Write-Host "No new notifications for account $account"
                                break
                        }
                        else{
                                Write-Host "New notification found for account $account, id: $($response.id[$i])"
                                Write-Host $($response.id[$i])
                                Write-Host $($response.msg[$i])
                                Write-Host $($response.url[$i])

                                $url = $response.url[$i].Split("/")
                                $username = $url[0].Split("@")

                                $get_reply = @{
                                        jsonrpc = "2.0";
                                        method = "condenser_api.get_content";
                                        params = @($username[1],$url[1]);
                                        id = 1
                                        } | ConvertTo-Json
                                $reply_response = Invoke-WebRequest -Uri $uri -Method Post -Body $get_reply -UseBasicParsing | ConvertFrom-Json | Select-Object -ExpandProperty result

                                if ($reply_response.body.Length -gt 65){
                                        $trimmed_response = "$($reply_response.body.Substring(0,65))..."
                                        Write-Host $trimmed_response
                                        New-BurntToastNotification -Header (New-BTHeader -Title "Hive Notifications") -Button (New-BTButton -Content "See in PeakD" -Arguments "https://peakd.com/$($response.url[$i])") -AppLogo ".\hive-logo.png" -Text "$($response.msg[$i])","$trimmed_response"
                                }
                                else{
                                        Write-Host $reply_response.body
                                        New-BurntToastNotification -Header (New-BTHeader -Title "Hive Notifications") -Button (New-BTButton -Content "See in PeakD" -Arguments "https://peakd.com/$($response.url[$i])") -AppLogo ".\hive-logo.png" -Text "$($response.msg[$i])","$($reply_response.body)"
                                }
                                Write-Host ""
                        }
                }
        }
}
else{
        Write-Host "No new notifications for account $account"
}
$latest_id | Set-Content -Path "$account.txt" -Force