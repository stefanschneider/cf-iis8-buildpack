function test_verify
{
$env:PORT=31221
$env:VCAP_WINDOWS_USER="user"
$env:VCAP_WINDOWS_USER_PASSWORD="pass"
$env:VCAP_SERVICES="{}"

$testappPath=split-path $SCRIPT:MyInvocation.MyCommand.Path
$buildpackPath=$($testappPath | join-path -childpath "..\.." | resolve-path).path

Start-Process -FilePath "TestApps\iis8\iishwc\start.bat" -PassThru

$NrRetries=5
$Counter=1
$Success=$false

echo "Invoking web request"
while( $Success -eq $false )
{
  try
  {
    $statcode=$(invoke-webrequest http://localhost:${env:PORT}).statuscode
  }
  catch {}
  finally
  {
    if ( $statcode -ne 200 )
    {
      $Counter++
      if ( $Counter -eq $NrRetries ) { throw "App is not reachable on port ${env:PORT}" }
      echo "Sleeping 2 seconds"
      Start-Sleep -s 2
    }
    else
    {
      $Success=$true
      echo "Verify is ok"
    }
  }
}
}

function test_killIIS
{
echo "Killing iis process"
foreach ($ppid in $(gwmi win32_process | select ProcessID, CommandLine | Where-Object { $_.CommandLine -like "${buildpackPath}*" } | select ProcessID))
  {
  Stop-Process -force -id $ppid.ProcessID
  }
}

function test_compile
{
  $env:PORT=31221

  cmd /c .\bin\compile.bat TestApps\iis8 cache

  if ($LastExitCode -ne 0) {
    throw "Compile failed with exit code $LastExitCode."
  }

  echo "Compile is ok"
}

function test_detect
{
  cmd /c .\bin\detect.bat TestApps\iis8

  if ($LastExitCode -ne 0) {
    throw "Detect failed with exit code $LastExitCode."
  }

  echo "Detect is ok"
}

function test_release
{
  cmd /c .\bin\release.bat TestApps\iis8

  if ($LastExitCode -ne 0) {
    throw "Release failed with exit code $LastExitCode."
  }

  echo "Release is ok"
}

$testappPath=split-path $SCRIPT:MyInvocation.MyCommand.Path
$buildpackPath=$($testappPath | join-path -childpath "..\.." | resolve-path).path
cd $buildpackPath

test_detect
test_release
test_compile
test_verify
test_killIIS
