#OMI Agent Installation 
cd c:\sungard_files\OMI
if(!$?){
		write-Output "ERROR::Could not find C:\sungard_files\OMI path!!." 
	    Exit 0
	}
#cscript c:\sungard_files\OMI\oainstall.vbs -i -a
cscript oainstall.vbs -i -a
if(!$?){
		write-Output "ERROR::Incomplete OM Agent install detected!!." 
	    Exit 0
	}
