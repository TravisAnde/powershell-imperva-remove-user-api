# Modify the api key/id

$account_id = '12345678'
$api_id = '12345'
$api_key = '000000000-0000-0000-0000-0000000000000'
$params = @{
    # "accountId" = 0000000;
}
$url = 'https://api.imperva.com/identity-management/v3/users/list'
$headers = @{
    "x-API-Id" = $api_id;
    "x-API-Key" = $api_key;
    "Content-Type" = "application/json";
    "Accept" = "application/json";
}

$response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers

# Write-Host "Response exported to $outputFilePath"

$filteredResults = $response.data | Where-Object { $_.lastName -eq "Participant" }

# echo $filteredResults

$outputFilePath = "C:\pathtofile\output.json"

$filteredResults | ConvertTo-Json | Set-Content -Path $outputFilePath

# Extract and save email addresses
$emailAddresses = $filteredResults | ForEach-Object { $_.email }
$emailAddresses | Set-Content -Path "C:\pathtofile\email_addresses.txt"

# Display extracted email addresses
# Write-Host "Extracted email addresses:"
# $emailAddresses

# Define the base API endpoint for deletion
$deleteBaseUrl = 'https://api.imperva.com/user-management/v1/users'

# Set the headers for the DELETE request
$deleteHeaders = @{
    "x-API-Id" = $api_id;
    "x-API-Key" = $api_key;
    "accept" = "application/json";
}

# Read email addresses from the saved text file
$emailAddresses = Get-Content -Path "C:\pathtofile\email_addresses.txt"

# Loop through each email address and perform DELETE operation
foreach ($email in $emailAddresses) {
    $queryParams = @{
        accountId = [System.Uri]::EscapeDataString($account_id)
        userEmail = [System.Uri]::EscapeDataString($email)
    }
    echo $queryParams
    # Construct the query string
    $queryParameters = @()
    foreach ($param in $queryParams.GetEnumerator()) {
        $queryParameters += $($param.Key + '=' + $param.Value)
    }
    $queryString = $queryParameters -join '&'
    
    # Construct the complete URL
    $deleteUrl = "$deleteBaseUrl?$queryString"

    # echo "deleteurl: " $deleteBaseUrl"?"$deleteUrl
    # Perform the DELETE operation
    $deleteResponse = Invoke-RestMethod -Uri $deleteBaseUrl"?"$deleteUrl -Method Delete -Headers $deleteHeaders
    
    # Display result for each email address (optional)
    Write-Host "Deleted user with email: $email - Result: $($deleteResponse.message)"
}
