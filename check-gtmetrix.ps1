#
# Script.ps1
#

function add-credentials {
    # credentials is encrypted with
    # read-host -assecurestring | convertfrom-securestring | out-file C:\auth\password.txt
    $dbpassword = Get-Content C:\auth\sa.txt | convertto-securestring
    $dbcred = new-object -typename System.Management.Automation.PSCredential -argumentlist sa, $dbpassword
    set-variables
}
function set-variables {
    for ($i=0; $i -lt (Get-Content cfg-mgmt.conf).length; $i++) {
		$line = (Get-Content $randFolderName\$gitpath\cfg-mgmt.conf | select -first 1 -skip $i)
		write-host "creating value for "$line.Split('=')[0]
		New-Variable -Name $line.Split('=')[0] -Value $line.Split('=')[1]
	}
    get-sitesfromDB
}

function get-sitesfromDB {
    Invoke-
    set-header
}

function set-header {
	$user = $email
	$password = $apikey
	$pair = "${user}:${password}"
	$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
	$base64 = [System.Convert]::ToBase64String($bytes)
	$basicAuthValue = "Basic $base64"
	$headers = @{ Authorization = $basicAuthValue }
	start-test
}

function start-test {
    $postParams = @{"url"='https://increo.no';"x-metrix-adblock"=0;"location"=2;"browser"=1}
    $gtmetrix = (Invoke-webrequest -uri https://gtmetrix.com/api/0.1/test -method POST -Headers $headers -Body $postParams)
    $test_id = ($gtmetrix.Content | ConvertFrom-Json).test_id
    add-todatabase
}

function set-values {
    $gtreport = (Invoke-WebRequest -uri https://gtmetrix.com/api/0.1/test/$test_id -Headers $headers)
    $gtreport = $gtreport.Content | ConvertFrom-Json
    [float]$time = $gtreport.results.onload_time / 1000
    [int]$pageelements = $gtreport.results.page_elements
    [int]$yslow = $gtreport.results.yslow_score
    [int]$pagespeed = $gtreport.results.pagespeed_score
    add-2db
}

function add-2db {
    Invoke-Sqlcmd
}

add-credentials