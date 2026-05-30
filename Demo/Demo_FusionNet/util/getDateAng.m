function date2 = getDateAng()

dateRaw = datestr(now);
date1 = strrep(dateRaw, ' ', '_');
date2 = strrep(date1, ':', '_');
