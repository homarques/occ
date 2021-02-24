%DIPLIBWARN  Warn no DIPimage once

function diplibwarn

if isoctave, return; end

persistent DIPWARN

if isempty(DIPWARN)
  DIPWARN = 0;
  disp([prnewline '--> The DIPIMAGE package is not available. Replacements ' ...
    prnewline '--> will be used and may behave slightly different.' prnewline])
end

return