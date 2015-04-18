m = 128;
n = 512;
ITERATIONS = 1000;
kRange = 20:45;
success = zeros(size(kRange));
tic
for k = kRange
    for i = 1:ITERATIONS
        samplingVector = P3(n,m)*I2(n);
        sparseVector = X1(k,n)';
        underSampledVector = samplingVector * sparseVector;
        cvx_begin quiet
            variable x(n)
            minimize( norm(samplingVector*x-underSampledVector,2) + norm(x,1) )
        cvx_end
        error = norm(x - sparseVector,2) / norm(sparseVector,2);
        if error < 1e-3
            success(k - min(kRange) + 1) = success(k - min(kRange) + 1) + 1;
        end
    end
end
save('i2p3x1','success');
plot(1:n,sparseVector,1:n,x);
legend('Original','Reconstructed');