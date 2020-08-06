function CDRvalue = parseSubjectStatus(filepath)

    text = readtable(filepath,'ReadVariableNames',false);    
    
    if( isempty( str2num( text{7,2}{1} ) ) )
        CDRvalue = 0;
    else
        CDRvalue = str2double( text{7,2}{1} );
    end
    
end