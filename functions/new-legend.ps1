function new-legend ( $legends )
{
    $legends = $legends | Sort-Object label,color,style
    #Legend - combine label color and style to determine number of unique combinations
    $legendcombined = @()
    foreach ( $legend in $legends )
    {
        $legendcombined += "$($legend.Label)|$($legend.color)|$($legend.style)"
    }
    $legendcombined = $legendcombined | Select-Object -Unique
    $legendlabels = $legends | Select-Object -ExpandProperty label -Unique | Sort-Object
    $legendsinfo = @()
    $labelcount = 0
    #Determine max label length
    $labelmax = ($legendlabels | Measure-Object -Maximum -Property Length).Maximum
    $mainlabel = ''
    #For each unique combo of label/color/style
    foreach ( $legend in $legendcombined)
    {
        $color = (($legend.split('|'))[1])
        $style = (($legend.split('|'))[2])
        $label = (($legend.split('|'))[0])
        #Add whitespace to each label up to the max char size
        $labelspaced = "$($label + $(' ' * $labelmax))"
        #Will make multiple label color/style blend into a single catagory
        if ($labelspaced -like $mainlabel) { $fontcolor = 'white' }
        else { $fontcolor = $color; $mainlabel = $labelspaced }
        $legendsinfo += new-edgeobject -label $labelspaced -color $color -style $style -fontcolor $fontcolor -order $labelcount
        $labelcount++
    }
    $itemcount = 0 #Number of legend items
    $rankcount = 1 #Rank is used to determine vertical position in the legend list, is reset after exceeding max
    if ($legendsinfo.count -gt 3) { $maxrank = 4 } else { $maxrank = $legendsinfo.count } #Max size vertical of the legend list
    $edgetop = 0
    $legendnodes = @()
    $legendedges = @()
    foreach ( $legend in $($legendsinfo | Where-Object { $_.label }) )
    {
        invoke-expression "`$rank$rankcount = @()"
        if ($rankcount -gt $maxrank) #resets rankcount if too large
        { 
            $edgetop = 1 
            $rankcount = 1 
        }
        invoke-expression "if ( !`$rank$rankcount ) { `$rank$rankcount = @() }"
        #Create new white point legend nodes (start and end of line)
        $legendnodes += new-psdiaobject -name "item$itemcount" -shape point -color white
        $legendnodes += new-psdiaobject -name "item$($itemcount + 1)" -shape point -color white
        invoke-expression "`$rank$rankcount += 'item$itemcount','item$($itemcount + 1)'" #add new nodes to list of rank items for this rank level
        $legendedges += new-edgeobject -from "item$itemcount" -to "item$($itemcount +1 )" -label $($legend.label) -style $($legend.style) -color $($legend.color) -fontcolor $($legend.fontcolor)
        #This sections adds invisible framework to structure the legend
        if ( $edgetop -eq 1 ) 
        { 
            #connects item1 to item8
            # i0---i1__i8---i9
            #  |    |
            # i2---i3
            #  |    |
            # i4---i5
            #  |    |
            # i6---i7
            $legendedges += new-edgeobject -from "item$($itemcount -7)" -to "item$itemcount" -color white
            $edgetop = 0 
        }
        if ( $rankcount -gt 1 )
        { 
            #connects item0 to item2 and item1 to item3
            # i0---i1
            #  |    |
            # i2---i3
            $legendedges += new-edgeobject -from "item$($itemcount -2)" -to "item$itemcount" -color white
            $legendedges += new-edgeobject -from "item$($itemcount -1)" -to "item$($itemcount+1)" -color white
        }
        $rankcount++
        $itemcount = $itemcount +2
    }
    $legendgraph = graph basic {
        'edge [arrowhead=none]'
        subgraph 0 -Attributes @{label='Legend'} {
            foreach ( $node in $($legendnodes | Sort-Object label) )
            {
                node $($node.name) @{shape = $($node.shape); color=$($node.color)}
            }
            foreach ($edge in $($legendedges | Sort-Object label))
            {
                edge $($edge.from) $($edge.to) @{label=$($edge.label);color=$($edge.color);style=$($edge.style);fontcolor=$($edge.color)}
            }
            $rank = 1
            do 
            {
                invoke-expression "rank `$rank$rank"
                $rank++
            } until ( $rank -gt $maxrank )
        }
    }
    $legendgraph
}