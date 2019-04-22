function error_show(ME)

% This function helps identify errors.
% ME is a Matlab Exception structure with the following fields:
%     identifier
%     message
%     cause
%     stack (array of structures)
%         file (file name where error occured)
%         name (function name where error occured)
%         line (where error occured)
%
%         The stack field of the MException object identifies the line
%         number, function, and filename where the error was detected. If
%         the error occurs in a called function, the stack field contains
%         the line number, function name, and filename not only for the
%         location of the immediate error, but also for each of the calling
%         functions.

% The developer can step back to the function where the error originated
% and have the corresponding workspace available to troubleshoot the error.

% The function should be used as follows:
%     try
%          [function content]
%
%     catch ME
%          error_show(ME);
%     end

    temp = size(ME.stack);

    desc = ['ERROR: ', ME.message];
    disp(desc);
    disp(['ME.identifier: ', ME.identifier]);
    disp(['ME.cause: ', char(ME.cause)]);

    for iME=1:temp(1)-1
        disp([...
            'Line: ',num2str(ME.stack(iME).line),...
            ', Function: ', ME.stack(iME).name]);
    end
    
    dbstack()
    h_errordlg = errordlg(desc,'Application error','modal');
    uiwait(h_errordlg)
    keyboard

end