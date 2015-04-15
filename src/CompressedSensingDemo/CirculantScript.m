m = 128;
n = 512;
k = 45;
tic
samplingVector = P1(n,m)*R1(n);
sparseVector = X1(k,n)';
underSampledVector = samplingVector * sparseVector;
cvx_begin
    variable x(n)
    minimize( norm(samplingVector*x-underSampledVector,2) + norm(x,1) )
cvx_end
error = norm(x - sparseVector,2) / norm(sparseVector,2)
toc
plot(1:n,sparseVector,1:n,x);
legend('Original','Reconstructed');