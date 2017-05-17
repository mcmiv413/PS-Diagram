function set-logo ( $path )
{
    $guid = $([guid]::NewGuid() -split ('-'))[0]
    $ext = $path.split('.')[-1]
    if ( $path -like "*http*" )
    {
        if (!$(test-path "C:\temp" ) ){ mkdir "c:\temp" }
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile("$path","C:\temp\$guid.$ext")
        $path = "C:\temp\$guid.$ext"
    }
    elseif ( $ext )
    {
        if ( $(test-path $path ) )
        { 
            Copy-Item $path "C:\temp\$guid.$ext"
            $path = "C:\temp\$guid.$ext"
        }
        else { $path = '' }
    }
    $path
}