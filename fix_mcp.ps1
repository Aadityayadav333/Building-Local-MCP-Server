# MCP Server Fix Script
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "MCP SERVER FIX SCRIPT" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host "`n[Step 1/4] Installing missing dependencies..." -ForegroundColor Green
pip install trafilatura groq --quiet

Write-Host "`n[Step 2/4] Verifying installation..." -ForegroundColor Green
python -c "import fastmcp, httpx, trafilatura, groq; print('All packages installed')"

Write-Host "`n[Step 3/4] Testing MCP server startup..." -ForegroundColor Green
Set-Location "C:\Users\Aaditya\OneDrive\Desktop\Projects\AI with Hassan Projects\MCP Server Python"

$env:SERPER_API_KEY = "617c5374169f348a332d01ad386f34347ca53e69"
Write-Host "Starting server test (will auto-stop after 3 seconds)..."
$job = Start-Job -ScriptBlock { 
    param($pythonExe)
    & $pythonExe "C:\Users\Aaditya\OneDrive\Desktop\Projects\AI with Hassan Projects\MCP Server Python\mcp_server.py"
} -ArgumentList "C:\Users\Aaditya\anaconda3\python.exe"

Start-Sleep -Seconds 3
Stop-Job $job
$output = Receive-Job $job
Remove-Job $job

if ($output -match "MCP SERVER STARTED") {
    Write-Host "Server starts successfully!" -ForegroundColor Green
} else {
    Write-Host "Server failed to start" -ForegroundColor Red
    Write-Host $output
}

Write-Host "`n[Step 4/4] Configuration file fix..." -ForegroundColor Green
$configPath = "$env:APPDATA\Claude\claude_desktop_config.json"
$config = @{
    mcpServers = @{
        "docs-mcp" = @{
            command = "C:/Users/Aaditya/anaconda3/python.exe"
            args = @(
                "C:/Users/Aaditya/OneDrive/Desktop/Projects/AI with Hassan Projects/MCP Server Python/mcp_server.py"
            )
            env = @{
                SERPER_API_KEY = "617c5374169f348a332d01ad386f34347ca53e69"
            }
        }
    }
}

$config | ConvertTo-Json -Depth 10 | Set-Content $configPath
Write-Host "Config file updated at: $configPath" -ForegroundColor Green

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "SETUP COMPLETE!" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Close Claude Desktop COMPLETELY"
Write-Host "2. Wait 5 seconds"
Write-Host "3. Open Claude Desktop again"
Write-Host "4. Check if get_docs appears in Local MCP servers"
Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
