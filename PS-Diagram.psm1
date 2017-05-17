$FunctionsPath = split-path -parent $MyInvocation.MyCommand.Definition
. "$FunctionsPath\functions\new-edgeobject.ps1"
. "$FunctionsPath\functions\new-nodeobject.ps1"
. "$FunctionsPath\functions\new-body.ps1"
. "$FunctionsPath\functions\new-header.ps1"
. "$FunctionsPath\functions\new-legend.ps1"
. "$FunctionsPath\functions\new-psdiagram.ps1"
. "$FunctionsPath\functions\set-logo.ps1"
. "$FunctionsPath\functions\new-psdiacsv.ps1"
. "$FunctionsPath\functions\split-psdiacsv.ps1"
. "$FunctionsPath\functions\new-psdiaobject.ps1"
Export-ModuleMember -function new-psdiacsv
Export-ModuleMember -function new-psdiagram