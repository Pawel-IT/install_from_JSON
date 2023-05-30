$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

#Program Variables:
$comp_name = $(Get-WmiObject Win32_Computersystem).name
$software_json = Get-Content $ScriptDir\software_list.json | ConvertFrom-Json

#Functions
function check_if_installed($exe_path, $version)
{
    $path_exists = Test-Path -Path $exe_path
    if($path_exists)
    {
        $installed_version = (Get-Item $exe_path).VersionInfo.FileVersion
        if($installed_version -eq $version)
        {
            return 1;
        }
        else {
            return 0;
        }
    }
    else 
    {
        return 0;
    }

}

function Pause
{
   Read-Host 'Press Enter to exit.' | Out-Null
}
 

foreach ($item in $software_json.software_list)
{
    Write-Host "----Starting " $item.Name "------------"
    $is_installed = check_if_installed -exe_path $item.local_program_path -version $item.target_version

    if($is_installed -eq 0)
    {
        Write-Host "Installing: " $item.Name "Using Command: " $item.install_command
        Invoke-Expression $item.install_command
    }
    else 
    {
        Write-Host $item.Name "is already installed with version:" $item.target_version
    }
    
    # Uncomment next line if you want a log of what was installed
    #New-Item -Path "\\server.local\software\Test" -Name "$comp_name - $program_name.txt" -ItemType "file" -Value $installed_version
    Write-Host "-----------Moving To next--------------"
}

Pause