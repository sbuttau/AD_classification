function CDRvalue = parseSubjectStatus(filepath)

    text = readtable(filepath,'ReadVariableNames',false);    
    
    if( isnumeric(text{6,2}) )
        CDRvalue = text{6,2};
    else
        CDRvalue = 0;
    end
    
end




