function new-psdiaobject ($name,$label,$shape,$color,$style,$fontcolor,$group,$rank,$type,$image,$from,$to,$dir,$legend,$order)
{
    $object = new-object -TypeName psobject -Property @{
        Name = $name
        Label = $label
        Shape = $shape
        Color = $color
        Style = $Style
        FontColor = $fontcolor
        From = $from
        To = $to        
        Dir = $dir
        Group = $group
        Rank = $rank
        Type = $type
        Image = $image
        Legend = $legend
        Order = $order
    }
    $object
}