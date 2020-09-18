function CDRvalue = parseSubjectStatus(filepath)

    if verLessThan('matlab','9.8')
        % -- Code to run in MATLAB earlier than R2020a --
        text = readtable(filepath,'ReadVariableNames',false);

        if( isempty( str2num( text{7,2}{1} ) ) )
            CDRvalue = 0;
        else
            CDRvalue = str2double( text{7,2}{1} );
        end
    else
        % -- Code to run in MATLAB R2020a and later here --
        text = readtable(filepath,'ReadVariableNames',false);

        if( isnumeric( text{6,2} ) )
            CDRvalue = text{6,2};
        else
            CDRvalue = 0;
        end
    end

end
