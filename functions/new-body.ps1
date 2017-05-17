function new-body ($nodesinfo,$ranksinfo,$edgesinfo,$nodesep,$ranksep,$newrank)
{
    graph basic {
        "nodesep = $nodesep"
        "ranksep = $ranksep"
        "newrank= $newrank"
        #Nodes where there is no group defined
        $nogroup = $nodesinfo | Where-Object { $_.group -like '' }
        foreach ( $node in $nogroup ) 
        { 
            switch ( $node.style )
            {
                "filled" { $fillcolor = $node.color; $color = "black" }
                default { $fillcolor = ''; $color = $node.color }

            }
            node $($node.name) @{label=$($node.label); shape = $($node.shape); style = $($node.style); color = $color; fillcolor = $fillcolor} 
        }
        #Define nodes for each grouping
        foreach ($group in $groups)
        {
            $groupnodes = $nodesinfo | Where-Object { $_.group -like $group }
            subgraph $group {
                foreach ( $node in $groupnodes )
                {
                    node $($node.name) @{label=$($node.label); shape = $($node.shape); weight=$($([int]$($node.rank)) *10)}
                }
            }
        }
        #Group nodes of the same rank
        $ranksnum = $ranksinfo.count
        if ( $ranksnum -gt 1 )
        {
            for ([int]$rankitem = 0; $rankitem -lt $ranksnum; $rankitem++)
            { 
                $from = ''
                if ( $rankitem -eq 0 ) { "{rank=min;$(@($ranksinfo[$rankitem] -join ';'));$from}"  } 
                elseif ( $rankitem -eq $ranksnum -1 ) 
                { 
                    "{rank=max;$(@($ranksinfo[$rankitem] -join ';'));$from}" 
                } 
                else 
                { 
                    "{rank=same;$(@($ranksinfo[$rankitem] -join ';'));$from}" 
                }
            }
        }
        foreach ($edge in $edgesinfo)
        {
            edge $($edge.from) $($edge.to) @{label=$($edge.label);color=$($edge.color);style=$($edge.style);fontcolor=$($edge.color);dir=$($edge.dir)}
        }
    }
}