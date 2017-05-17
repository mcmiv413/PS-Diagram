function new-header ( $logo, $logo2 )
{
    $legendpath = "c:\temp\legend.png"
    $bodyimg = new-object -ComObject wia.imagefile
    $bodyimg.loadfile("c:\temp\body.png")
    if ( test-path $legendpath ) 
    {
        $legendimg = new-object -ComObject wia.imagefile
        $legendimg.loadfile("$legendpath")
        $legendwidth = $legendimg.width
    }
    else { $legendwidth = 0 }
    #Dynamically size title properties based on generated graph
    $bodywidth = $bodyimg.width
    $logowidth = 200
    $logo2width = 200
    $height = 200
    $titlewidthstart = $bodywidth - $legendwidth - $logowidth - $logo2width
    if ($titlewidthstart -lt 100) { $titlewidthstart = 100}
    $titlewidth = $titlewidthstart *.75
    $space = ($titlewidthstart - $titlewidth)/2
    $header = graph basic {
        "struct2 [margin=0 shape=box, color=white, label=<<TABLE border=`"0`" cellborder=`"0`">
        <TR><TD width=`"$logowidth`" height=`"$height`" fixedsize=`"true`">" + $(if ( $logo ) { "<IMG SRC=`"$logo`" scale=`"true`"/>" } ) + "</TD>
        <TD width=`"$space`" height=`"$height`" fixedsize=`"true`"></TD>
        <TD><FONT POINT-SIZE='40'><B><U>$title</U></B></FONT></TD>
        <TD width=`"$space`" height=`"$height`" fixedsize=`"true`"></TD>
        <TD width=`"$logo2width`" height=`"$height`" fixedsize=`"true`">" + $(if ( $logo2 ) { "<IMG SRC=`"$logo2`" scale=`"true`"/>" } ) + "</TD>"
        if ( test-path $legendpath ) { "<TD width=`"$legendwidth`" height=`"$height`" fixedsize=`"true`"><IMG SRC=`"c:\temp\legend.png`" scale=`"true`"/></TD>" }
        "</TR>
        </TABLE>>];"
    } 
    $header
}