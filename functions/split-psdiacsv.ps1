function split-psdiacsv ( $file )
{
    $csvcontents = Get-Content $file
    $csvcontentend = $csvcontents.ReadCount[-1]
    [array]$propcount = ($csvcontents | Where-Object {$_ -match "^object"}).ReadCount
    for ($propindex = 0; $propindex -lt ($propcount.count); $propindex++)
    { 
        $start = ($propcount[$propindex])-1
        $end = (($propcount[$propindex+1])-2)
        if ($end -lt 0) { $end = $csvcontentend }
        $contentout = $csvcontents[$start..$end]
        $csvfile = "c:\temp\diagramcsv$propindex.csv"
        $contentout | out-file $csvfile -Encoding ascii
        [array]$csvfiles += $csvfile
    }
    $csvfiles
}