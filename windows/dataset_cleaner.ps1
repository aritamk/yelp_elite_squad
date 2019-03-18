Param([int]$ll=0, [string]$f = "")

[string]$dataDir = "datasets\"

[Hashtable]$logInfo = @{0="INFO"; 1="WARNING"; 2="DEBUG"}


Function PrintLine([string]$m, [string]$c = "White", [int]$l = 0 <#INFO #>)
{
	if ($l -le $LogLevel) { Write-host $m -ForegroundColor $c }
}

Set-variable -Name printContent -Value $false -Scope "Global"
[string[]]$content = get-content $f

Set-Variable -name LogLevel -value $ll -Scope "Global"
Set-Variable -name StartRow -value 1 -Scope "Global"
Set-Variable -name EndRow -value $content.length -Scope "Global"

[string]$lLevel = $logInfo[$logLevel]
[string[]]$config = @("CONFIG:", "Input File: $f", "Starting Row: $StartRow", "Ending Row: $EndRow", "Log Level: $lLevel", "`n`n")
foreach ($item in $config) { PrintLine -m "`t $item" -c "Cyan" }

[int]$count = $content[0].split(',').length
[int]$itemCount = $content.length
[int]$tPrintInterval = $itemCount / 20 
Set-Variable -Name printInterval -Value $tPrintInterval -Scope "Global"
PrintLine -m "Print interval: $printInterval" -l 0

PrintLine -m "Num columns: $count" -c "Cyan"

Function ValidateContent([string[]]$content)
{		
	PrintLine -m "Validating Content" -l 0
	[string[]]$headers = $content[0].split(',') | foreach {$_.Trim()}
	PrintLine -m $headers -c "Cyan" -l 0

	Set-Variable -name yelpStartIndex -Value $headers.indexof("yelping_since") -Scope "Global"
	Set-Variable -name userIdIndex -Value $headers.indexof("user_id") -Scope "Global"
	Set-Variable -name nameIndex -Value $headers.indexof("name") -Scope "Global"
	Set-Variable -name friendsIndex -Value $headers.indexof("friends") -Scope "Global"
	Set-Variable -name yrsEliteIndex -Value $headers.indexof("elite") -Scope "Global"
	Set-Variable -name complimentCoolIndex -Value $headers.indexof("compliment_hot") -Scope "Global"
	Set-Variable -name complimentProfileIndex -Value $headers.indexof("compliment_profile") -Scope "Global"

	if($yelpStartIndex -lt 0){ PrintLine -m "Failed to get Yelp Start Index" -c "red"; Start-Sleep -s 1; exit } else { PrintLine -m "Yelp Start Index: $yelpStartIndex" -l 2 }
	if($userIdIndex -lt 0)   { PrintLine -m "Failed to get User ID Index" -c "red"; Start-Sleep -s 1; exit } else { PrintLine -m "User ID Index: $userIdIndex" -l 2 }
	if($nameIndex -lt 0) 	 { PrintLine -m "Failed to get Name Index" -c "red"; Start-Sleep -s 1; exit } else { PrintLine -m "Name Index: $nameIndex" -l 2 }
	if($friendsIndex -lt 0)  { PrintLine -m "Failed to get Friends Index" -c "red"; Start-Sleep -s 1; exit } else { PrintLine -m "Friends Index: $friendsIndex" -l 2 }
	if($yrsEliteIndex -lt 0) { PrintLine -m "Failed to get Yrs Elite Index" -c "red"; Start-Sleep -s 1; exit } else { PrintLine -m "Years Elite Index: $yrsEliteIndex" -l 2 }
	if($complimentCoolIndex -lt 0) { PrintLine -m "Failed to get Compliment Hot Index" -c "red"; Start-Sleep -s 1; exit } else { PrintLine -m "Compliment Hot Index: $complimentCoolIndex" -l 2 }
	if($complimentProfileIndex -lt 0) { PrintLine -m "Failed to get Compliment Profile Index" -c "red"; Start-Sleep -s 1; exit } else { PrintLine -m "Compliment Profile Index: $complimentProfileIndex" -l 2 }
}

Function GetUniqueNumHash([string]$value)
{
	if (-not ($value)){ PrintLine -m "Input was empty"; return }
	PrintLine  -m "input UniquNumHash $value" -c "Yellow" -l 1
	$StringBuilder = New-Object System.Text.StringBuilder
	[string]$hashName = "MD5"
	
	[System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($value))|%{ [Void]$StringBuilder.Append($_.ToString("x2")) }
	[string]$hashVal = $stringbuilder.tostring() -replace "[^0-9]"
	[int]$iHashVal = $hashVal.Substring(0, 9)

	PrintLine -m "Calculated unique hash val $hashVal" -c "Yellow" -l 1
	return $iHashVal
}

Function ReencodeLine([string]$line)
{
	PrintLine -m "`nOriginal Content: $line`n" -l 2
	[string]$processedLine = $line -replace "None", 0
	$processedLine = $processedLine -replace ",", ", "
	$processedLine = $processedLine -replace "  ", " "
	
	PrintLine -m "Pre-encode: $line`n"	-l 2

	# convert Yelping-Since Date
	[string[]]$items = $processedLine.split(',')
	[string]$dateYelping = $items[$yelpStartIndex] # assumes that Date is first on the line
	$currentDate = get-date
	[int]$currentYear = $currentDate.year
	
	$dateYelpingFormatted = get-date $dateYelping -format "MM/dd/yyyy"
	$yelpingSinceDate = [datetime]::parseexact($dateYelpingFormatted, "MM/dd/yyyy", $null)
	[int]$yelpingSinceYear = $yelpingSinceDate.year
	[int]$yearsYelping = $currentYear - $yelpingSinceYear
	PrintLine -m "Years Yelping $yearYelping" -l 2
	$processedLine = $processedLine -replace $dateYelping, $yearsYelping
	
	PrintLine -m "Re-encode `n`t$processedLine`n" -l 2
	
	# remove unique user ID
	PrintLine -m "Removing User ID" -l 2
	$regEx = [regex]"[^ ]{22}"
	$match = $regex.match($processedLine)
	$userNameIndexStart = $match.index
	
	[string]$subStr = $processedLine.substring($userNameIndexStart, 22)
	$processedLine = $processedLine -replace $subStr, 0	
	
	# Update Friends count
	[int]$numFriends = 0

	$regExParen = [regex]"[^ ]{23}" # 'friend' + [1 for ',']
	$match = $regExParen.match($processedLine)
	[int]$friendsIndexStart = $match.index
	
	# check if at least one friend
	if ($friendsIndexStart -gt 0)
	{
		[string]$subStr = $processedLine.substring($friendsIndexStart, $processedLine.length - $friendsIndexStart - 1)
		# check for multiple friends
		if ($subStr -match '"')
		{
			[string[]]$items = $subStr.split('"')
			[string[]]$friendsList = $items[1].split(',')
			$subStr = $items[1] -replace '"', ' ' 
			$numFriends = $friendsList.count
		}	
		else
		{
			$subStr = $processedLine.substring($friendsIndexStart, 22)
			PrintLine -m "User has only one friend, $substr" -l 2
			$numFriends = 1
		}
	}
				
	[string]$replaceString = $substr
	# update line with replaced count of Friends 
	if ($numFriends -gt 1) { $replaceString = '"' + $replaceString + '"' }
	$processedLine = $processedLine -replace $replaceString, $numFriends
	
	# check for and convert elite years
	if ($processedLine -match ' \"[0-9]{4}' -or $processedLine -match '[0-9]{4},')
	{
		PrintLine -m "Converting Elite Years" -l 2
		
		# get start of Elite Years list
		$regEx = [regex]' \"[0-9]{4}'
		$match = $regEx.match($processedLine)
		$tElYrIndexStart = $match.index
		
		if ($tElYrIndexStart -le 0)
		{
			$regEx = [regex]'[0-9]{4},'
			$match = $regEx.match($processedLine)
			$tElYrIndexStart = $match.index
		}
	
		# get elite to string end
		[string]$subStr = $processedLine.substring($tElYrIndexStart, $processedLine.length - $tElYrIndexStart)

		# find next non-elite year item
		$regEx = [regex]'\", [0-9]{1}'
		$match = $regEx.match($subStr)
		$tElYrIndexEnd = $match.index
		if ($tElYrIndexEnd -lt 0)
		{
			$regEx = [regex]', [0-9]{1}'
			$match = $regEx.match($subStr)
			$tElYrIndexEnd = $match.index
		}

		$subStr = $subStr.substring(0, $tElYrIndexEnd + 1)
		
		[string[]]$items = $subStr.split(",")
		
		[string]$replaceString = $subStr
		[string]$yrsElite = [string]($items.count)
		PrintLine -m "years elite $yrsElite" -l 2
		PrintLine -m "replace string $replaceString" -l 2
		
		$processedLine = $processedLine -replace $replaceString, $yrsElite
		PrintLine -m "Update Elite String: $processedLine" -l 2
	}

	return $processedLine
}

Function ReencodeParameters([string[]]$lines)
{
	PrintLine -m "`n*****Reencoding Content*****" -c "Green" -l 0
	[int]$eliteCount = 0
	[int]$nEliteCount = 0

	[string[]]$reencodedLines = @()
	for ($i = $StartRow; $i -lt $EndRow; $i++)
	{
		if ($i % $printInterval -eq 0) { Set-Variable -Name printContent -Value $true -Scope "Global" }
		else { Set-variable -Name printContent -Value $false -Scope "Global" }
		
		Printline -m "`nProcessing item number: $i" -c "Green" -l 1
		
		[string]$line = ReencodeLine $lines[$i].trim()
		
		PrintLine -m "Final Line:`n`t $line" -l 1
		[string[]]$items = $line.split(',') | foreach {$_.Trim()}
		PrintLine -m ("No. Items: " + $items.count) -l 1
		
		# get no. years of elite
		[int]$noYrsElite = $items[$yrsEliteIndex]
		PrintLine -m "No Yrs Elite: $noYrsElite" -c "Yellow" -l 2
		
		[string[]]$finalItems = @()
		# could be removed completely
		$regex = "[a-zA-Z][^0-9]*"
		for ($t = 0; $t -lt $items.count; $t++)
		{				
			if ($t -eq $complimentCoolIndex)
			{
				PrintLine -m "Skipping complimentCoolIndex $complimentCoolIndex" -l 2
				continue
			}
			
			if ($t -eq $nameIndex)
			{
				PrintLine -m "Skipping name, index $nameIndex"  -l 2
				continue
			}
			
			# remove name
			if ($items[$t] -match $regex)
			{
				[string]$name = $items[$t]
				Write-host "Name: "$items[$t]
				PrintLine -m "Removed name: $name" -c "Yellow" -l 2
				$items[$t] = 0; 
				PrintLine -m "EXITING" -c "red" -l 2
				continue
			}
			
			$finalItems += $items[$t]
		}	
		
		# create classification based on whether previously elite or not
		if ($noYrsElite -gt 0){ $eliteCount += 1 } 
		else { $nEliteCount += 1 }
		
		[string]$result = ($noYrsElite -gt 0)
		$finalItems += $result
		PrintLine -m ("Final No. Items: " + $finalItems.count) -l 1
		
		# append all items into csv format
		[string]$output = $finalItems -join ","
		$output = $output -replace "-,", ""
		PrintLine -m "Output Content: [$output]`n" -l 1
		
		#if ($finalItems.count -ne 20) { write-host "Incorrect number of elements" $finalItems.count; continue }
		$reencodedLines += $output
	}

	Set-Variable -name printContent -Value $true -Scope "Global"
	PrintLine -m "Total number of elite: $eliteCount" -c "Green" -l 0
	PrintLine -m "Total number of non-elite: $nEliteCount" -c "Green"  -l 0
	PrintLine -m "`n*****Done processing*****" -c "Green" -l 0

	return $reencodedLines
}

Function PrintOutput([string[]]$output)
{
	PrintLine -m "Printing results" -l 0
	[int]$trainCount = $output.length * 0.8
	[int]$testCount = $output.length - $trainCount

	PrintLine -m ("Num items in Training Set: $trainCount") -l 0
	PrintLine -m ("Num items in Test Set: $testCount") -l 0

	[string[]]$trainSet = $output[1..$trainCount]
	[int]$trainCount = $trainSet.length
	[string[]]$testSet = $output[$trainCount..$output.length]
	[int]$testCount = $testSet.length

	PrintLine -m "Num in Train set: $trainCount"
	PrintLine -m "Num in Test set: $testCount"

	# Write output 
	$headers = $headers -join ","

	Write-Output $headers | Out-File $outFileTrain -encoding UTF8
	Write-Output $headers | Out-File $outFileTest -encoding UTF8

	Write-Output $trainSet | Out-File $outFileTrain -Append -encoding UTF8
	Write-Output $testSet | Out-File $outFileTest -Append -encoding UTF8
}

if (-not (Test-Path $dataDir)) { New-Item -itemType directory -path $dataDir; start-sleep -s 1 }

# split data into Train and Test sets
[string]$outfileTrain = $dataDir + "train.csv"
[string]$outfileTest = $dataDir + "test.csv"

if (Test-Path $outFileTrain) { Write-host "Removing old train data"; Remove-Item $outFileTrain; Start-sleep -s 1}
if (Test-Path $outFileTest) { Write-host "Removing old test data"; Remove-Item $outFileTest; Start-sleep -s 1 }

ValidateContent $content
[string[]]$outContent = ReencodeParameters $content
PrintOutput $outContent

PrintLine -m "DONE"