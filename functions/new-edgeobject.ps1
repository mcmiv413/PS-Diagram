function new-edgeobject ($from,$to,$label,$style='bold',$color='black',$fontcolor='black',$dir, $legend, $order)
{
    $edgeobject = new-object -TypeName psobject -Property @{
        From = $from
        To = $to
        Style = $Style
        Color = $color
        FontColor = $fontcolor
        Dir = $dir
        Legend = $legend
        Order = $order
        Label = $label
    }
    $edgeobject
}
