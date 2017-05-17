function new-psdiagram ($inputcsv, $destination, $logo, $logo2, $title, [switch]$enableheader, [switch]$enablelegend, [switch]$invokediagram, [switch]$outputgraphtext, $nodesep=.5, $ranksep=1.5,[bool]$newrank=$true)
{
    import-module psgraph
    if (!$(test-path "C:\temp" ) ){ mkdir "c:\temp" }
    if ($logo){$logo = set-logo -path $logo}
    if ($logo2){$logo2 = set-logo -path $logo2}
    if ( !$inputcsv )
    {
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
        $Dialog = New-Object System.Windows.Forms.OpenFileDialog
        $Dialog.initialDirectory = 'C:\temp'
        $Dialog.Title = 'Please select CSV to import.'
        $Dialog.filter = "All files (*.csv)| *.csv"
        $Dialog.ShowDialog() | Out-Null
        $inputcsv = $Dialog.filename
    }
    if ( !$title ) { $title = $($(Get-ChildItem $inputcsv).basename) }
    $destpath = "$($(Get-ChildItem $inputcsv).directory)"; 
    if (!$destination) { $destination = "$destpath\$($(Get-ChildItem $inputcsv).basename).png" }
    $csvfiles = split-psdiacsv -file $inputcsv
    foreach ( $file in $csvfiles ) 
    {
        $csv = import-csv $file
        [array]$nodes += $csv | Where-Object { $_.object -like "*Node" } | Select-Object *,@{n='varname';e={"a$([guid]::NewGuid())" -replace '[^\w\d]',''}}
        [array]$routes += $csv | Where-Object { $_.object -like 'Route' } | Select-Object *,@{n='from';e={$_.fromtype}},@{n='dir';e={$_.direction}},@{n='to';e={$_.totype}} -ExcludeProperty fromtype,totype,direction
        if ( test-path $file) {Remove-Item $file}
    }
    $legends = @() #Legend edge info
    $ranks = $nodes | Select-Object -ExpandProperty Rank -unique | Where-Object { $_ } | Sort-Object
    $groups = $nodes | Select-Object -ExpandProperty Group -unique | Sort-Object | Where-Object { $_ } 
    $types = $nodes | Select-Object -ExpandProperty type -unique | Sort-Object
    $subcount = 0
    $rankcmd = @()
    $nodesinfo = @() #Graph Nodes
    $ranksinfo = @() #Rank order information
    $edgesinfo = @() #Graph Edges
    $rawadditionalnodeprops = (Get-Content $inputcsv)[0].split(',') | Where-Object { @('Object','Name','Shape','Color','Style','Type','Rank','Group') -notcontains $_ }
    foreach ($raw in $rawadditionalnodeprops)
    {
        $additionalprop = New-Object -TypeName psobject -Property @{
            Name = $raw.split('-')[0]
            Attributes =  $raw.split('-')[1]
            RawName = $raw
        }
        [array]$additionalnodeprops+=$additionalprop
    }
    $additionalnodeprops | out-file c:\temp\items.txt -append
    foreach ( $node in $nodes )
    {
        $name = "<TABLE BORDER='0' CELLBORDER='0' CELLSPACING='0'>"
        foreach ( $line in $($($node.name) -split ("`n")) )
        {
            $name += "<TR><TD><FONT POINT-SIZE='20'><B><U>$line</U></B></FONT></TD></TR>"
        }
        $details = @()
        foreach ( $prop in $additionalnodeprops )
        {
            if ( $node.$($prop.rawname) ) 
            { 
                $htmlformatstart = ''
                $htmlformatend = ''
                $align = "center"
                $proplabel = "$($prop.name): " 
                switch -wildcard ($prop.attributes)
                {
                    "*b*" { $htmlformatstart += "<B>"; $htmlformatend = "</B>" + $htmlformatend}
                    "*u*" { $htmlformatstart += "<U>"; $htmlformatend = "</U>" + $htmlformatend}
                    "*i*" { $htmlformatstart += "<I>"; $htmlformatend = "</I>" + $htmlformatend}
                    "*l*" { $align = "Left"}
                    "*r*" { $align = "Right"}
                    "*c*" { $align = "Center"}
                    "*n*" { $proplabel = '' }
                    Default { }
                }
                foreach ( $line in $($($node.$($prop.rawname)) -split ("`n")) )
                {
                    [array]$details += "<TR><TD Align='$align' >$htmlformatstart$proplabel$line$htmlformatend</TD></TR>" 
                }
            }      
        }
        $label = "<$name</TABLE>>"
        if ( $node.object -like 'ClusterNode' )
        { 
            if ( test-path "$($(Get-ChildItem $inputcsv).directory)\$($node.name).csv") 
            { 
                new-psdiagram -inputcsv "$destpath\$($node.name).csv" -destination "$destpath\$($node.name).png"
            }
            $image = "$destpath\$($node.name).png"
            [array]$details += "<TR><TD><IMG SRC='$image'/></TD></TR>"
        }
        else { $image = '' }
        if ( $details ) { $label = "<$name`n$details</TABLE>>" }
        $nodesinfo += new-psdiaobject -name $($node.varname) -label $label -shape $node.shape -group $node.group -rank $node.rank -color $node.color -style $node.style
    }
    $nodesinfo = $nodesinfo | Sort-Object rank,name

    foreach ( $rank in $ranks )
    {
        $ranksinfo += $($nodes | Where-Object { $_.rank -like $rank } | Select-Object -ExpandProperty varname -unique ) -join ','
    }
    if ($ranksinfo.count -lt 2){ $enablelegend = $false }
    #$ranksinfo
    foreach ( $type in $types )
    {
        invoke-expression "`$$type = @( `$(`$nodes | where { `$_.type -like '$type' } | select -expandproperty varname) )"
    }
    foreach ( $route in $routes )
    {
        if ( $route.legend ) 
        { 
            $label = $route.label
            $color = $route.color
            $style = $route.style
            $legends += new-edgeobject -label $route.legend -color $color -style $style
        }
        else { $label = $route.label }
        $color = $route.color
        $style = $route.style
        $dir = $route.dir
        $edgesinfo += new-edgeobject -from $(invoke-expression "`$$($route.from)") -to $(invoke-expression "`$$($route.to)") -label $label -style $style -color $color -dir $dir
    }
    $edgesinfo = $edgesinfo | Sort-Object from,to
    $bodytext = new-body -nodesinfo $nodesinfo -ranksinfo $ranksinfo -edgesinfo $edgesinfo -nodesep $nodesep -ranksep $ranksep -newrank $newrank
    $bodytext = $bodytext -replace '"<<','<<'
    $bodytext = $bodytext -replace '>>"','>>'
    #Create body and legend images to determine header sizing
    $bodytext | Export-PSGraph -DestinationPath C:\temp\body.png -OutputFormat png | out-null
    if ($enableheader)
    {
        if ($enablelegend)
        { 
            $legendtext = new-legend -legends $legends
            $legendtext | Export-PSGraph -DestinationPath C:\temp\legend.png -OutputFormat png | out-null
        }   
        $headertext = new-header -logo $logo -logo2 $logo2
        $headertext | Export-PSGraph -DestinationPath c:\temp\header.png -OutputFormat png | out-null
        graph basic {
            "struct1 [margin=0 shape=box, color=white, label=<<TABLE border=`"0`" cellborder=`"0`">
                <TR><TD><IMG SRC=`"c:\temp\header.png`" scale=`"true`"/></TD></TR>
                </TABLE>>];"
            "struct2 [margin=0 shape=box, color=white, label=<<TABLE border=`"0`" cellborder=`"0`">
                <TR><TD><IMG SRC=`"c:\temp\body.png`" scale=`"true`"/></TD></TR>
                </TABLE>>];"
            edge struct1 struct2 @{color='white'}
        } | Export-PSGraph -DestinationPath $destination -OutputFormat png | out-null
    }
    else { copy-item c:\temp\body.png $destination } 
    if ( $invokediagram ) { Invoke-Item $destination }
    if ( $outputgraphtext )
    {
        $bodytext | out-file c:\temp\body.txt -Encoding ascii
        $legendtext  | out-file c:\temp\legend.txt -Encoding ascii
        $headertext  | out-file c:\temp\header.txt -Encoding ascii
    }
    $images = $logo,$logo2,"C:\temp\legend.png","C:\temp\header.png","C:\temp\body.png"
    foreach ( $image in $images ) 
    {
        if ( $image ){if ( test-path $image) {Remove-Item $image}}
    }
}