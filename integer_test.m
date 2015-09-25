function integer_test(hObj, eventdata )
%INTEGER_TEST Summary of this function goes here
%   Detailed explanation goes here
try
    handles = guidata(findobj('Tag','GUI'));
    taskinfo = handles.myData.tasks_out{handles.myData.iter};
    editCount_string = eventdata.Key;
    desc_digits = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9','backspace','delete','leftarrow','rightarrow'...
                   'numpad0','numpad1','numpad2','numpad3','numpad4','numpad5','numpad6','numpad7','numpad8','numpad9'};             
    test = max(strcmp(editCount_string, desc_digits));
    if test
        valiad_input=1;
    else
        desc = 'Input should be an integer';
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)
        valiad_input=0;
        set(handles.NextButton, 'Enable', 'off');

        return
    end
    taskinfo.valiad_input=valiad_input;
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(hObj, handles);
catch ME
    error_show(ME)
end

end

