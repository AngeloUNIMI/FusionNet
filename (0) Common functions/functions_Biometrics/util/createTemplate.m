function template = createTemplate(result_f, general)

% if there isn't an enroll function stop the process
try
    template = feval(general.ENROLL_function, char(result_f(1)));
catch
    template = ''; % FTE value
end