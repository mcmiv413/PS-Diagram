function new-nodeobject ($name,$label,$shape,$color='black',$group,$rank,$type,$image)
{
    $nodeobject = new-object -TypeName psobject -Property @{
        Name = $name
        Label = $label
        Shape = $shape
        Color = $color
        Group = $group
        Rank = $rank
        Type = $type
        Image = $image    
    }
    $nodeobject
}