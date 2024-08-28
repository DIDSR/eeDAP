function closeAllUIObjects()
    % Get handles to all open figure windows
    figHandles = findall(0, 'Type', 'figure');
    
    % Loop through each figure handle and close it
    for i = 1:numel(figHandles)
        close(figHandles(i));
    end
end
