function COUNT = countmember(A,B)
% COUNTMEMBER - count members
%
%   COUNT = COUNTMEMBER(A,B) counts the number of times the elements of array A are
%   present in array B, so that C(k) equals the number of occurences of
%   A(k) in B. A may contain non-unique elements. C will have the same size as A.
%   A and B should be of the same type, and can be cell array of strings.
%
%   Examples:
%     countmember([1 2 1 3],[1 2 2 2 2])
%       %  -> 1     4     1     0
%     countmember({'a','b','c'},{'a','x','a'})
%       % -> 2     0     0
%
%   See also ISMEMBER, UNIQUE, HISTC

% tested in R2015a
% version 2.0 (apr 2016)
% (c) Jos van der Geest
% email: samelinoa@gmail.com

% History:
% 1.0 (2005) created
% 1.1 (??): removed dum variable from [AU,dum,j] = unique(A(:)) to reduce
%    overhead
% 1.2 (dec 2008) - added comments, fixed some spelling and grammar
%    mistakes, after being selected as Pick of the Week (dec 2008)
% 2.0 (apr 2016) - updated for R2015a

% input checks
narginchk(2,2) ;
if ~isequal(class(A), class(B)),
    error('Both inputs should be of the same class.') ;
end

if isempty(A) || isempty(B),
    % nothing to do
    COUNT = zeros(size(A)) ;
else    
    % which elements are unique in A,
    % also store the position to re-order later on
    [AUnique, ~, j] = unique(A(:)) ;
    % assign each element in B a number corresponding to the element of A
    [~, Loc] = ismember(B, AUnique) ;
    % count these numbers
    N = histc(Loc(:), 1:length(AUnique)) ;
    % re-order according to A, and reshape
    COUNT = reshape(N(j),size(A)) ;
end