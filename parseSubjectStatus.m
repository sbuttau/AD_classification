function CDRvalue = parseSubjectStatus(filepath)

    strLength = 14;
    text = fileread(filepath);
    expression = 'CDR';
    startIndex = regexp(text, expression, 'forceCellOutput');
    CDRstring = text(startIndex{1}:startIndex{1}+strLength);
    CDRvalue = str2num(CDRstring(end));
    
end


