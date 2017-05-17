function new-psdiacsv ( $csvfilename )
{
    $template = @'
Object,Name,Shape,Color,Style,Type,Rank,Group,CPU,MEM,HDD,OS,IP,Vlan,Note
Help,Object Name,http://www.graphviz.org/content/node-shapes,http://www.graphviz.org/content/color-names,http://www.graphviz.org/doc/info/attrs.html#k:style,object type,vertical level,number to group nodes together,"additional properties are arbitrary and can be any string,attributes can also use a - switch for builrcn(bold,underline,italic,left,right,center,no label")
Help,Clusternode for nested diagrams
Node,
,,,,,,,,,,,,
Object,FromType,ToType,Label,Color,Style,Legend,Direction
Help,,,Line Label,http://www.graphviz.org/content/color-names,http://www.graphviz.org/doc/info/attrs.html#k:style,legend label,http://www.graphviz.org/doc/info/attrs.html#k:dirType
Route,
'@
    $template | out-file $csvfilename -Encoding ascii
}
