%CHANGE OPTIMIZATION SO THAT Ax=B is a constraint, not an object of
%minimization
m = 128;
n = 512;
ITERATIONS = 10;
kRange = 0:1;
tic
x1Results = X1Test(ITERATIONS,kRange,m,n);
toc
save('x1Results','x1Results');
% x3Results = X3Test(ITERATIONS,kRange,m,n);
% save('x3Results','x3Results');
% x4Results = X4Test(ITERATIONS,kRange,m,n);
% save('x4Results','x4Results');
% x5Results = X5Test(ITERATIONS,m,n);
% save('x5Results','x5Results');
% x7Results = X7Test(ITERATIONS,kRange,m,n);
% save('x7Results','x7Results');