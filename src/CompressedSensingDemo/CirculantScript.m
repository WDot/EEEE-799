m = 128;
n = 512;
ITERATIONS = 2;
kRange_1_6_7 = 0:1;
kRange_3_4 = 0:1;
tic
% x1Results = X1Test(ITERATIONS,kRange_1_6_7,m,n);
% toc
% save('x1Results','x1Results');
% x3Results = X3Test(ITERATIONS,kRange_3_4,m,n);
% save('x3Results','x3Results');
% x4Results = X4Test(ITERATIONS,kRange_3_4,m,n);
% save('x4Results','x4Results');
%[x5Results,x5stdError] = X5Test(ITERATIONS,m,n);
%save('x5Results','x5Results');
%[x6Results,x6stdError] = X6Test(ITERATIONS,kRange_1_6_7,m,n);
%save('x6Results','x6Results');
x7Results = X7Test(ITERATIONS,kRange_1_6_7,m,n);
save('x7Results','x7Results');

figure(1)
hold on;
for i = 1:8
    plot(kRange_1_6_7,x1Results(i,:));
end
title('Test of Recovering Type-X1');
xlabel('Sparsity Level k');
ylabel('Freq. of (Rel. Err. < 1E-3)');
legend('A/R1/P1','A/R1/P3','A/R2/P1','A/D1/P3','A/D2/P3','A/D3/P3','A/I1','A/I2');
hold off;
figure(2)
hold on;
for i = 1:10
    plot(kRange_3_4,x3Results(i,:));
end
title('Test of Recovering Type-X3');
xlabel('Sparsity Level k');
ylabel('Freq. of (Rel. Err. < 1E-3)');
legend('A/R1/P1','A/R1/P2','A/R1/P3','A/R2/P1','A/D1/P2','A/D1/P3','A/D2/P3','A/D3/P3','A/I1','A/I2');
hold off;
figure(3)
hold on;
for i = 1:9
    plot(kRange_3_4,x4Results(i,:));
end
title('Test of Recovering Type-X4');
xlabel('Sparsity Level k');
ylabel('Freq. of (Rel. Err. < 1E-3)');
legend('A/R1/P1','A/R1/P2','A/R1/P3','A/R2/P1','A/D1/P2','A/D1/P3','A/D2/P3','A/D3/P3','A/I1');
hold off;
figure(4)
hold on;
for i = 1:8
    errorbar(log((1e-4).*2.^(0:8)),x5Results(i,:),x5stdError(i,:));
end
title('Test of Recovering Type-X5');
xlabel('log(noise sigma)');
ylabel('Rel. Err.');
legend('A/R1/P1','A/R1/P3','A/R2/P1','A/D1/P3','A/D3/P3','A/D3/P3','A/I1','A/I2');
hold off;
figure(5)
hold on;
for i = 1:8
    errorbar(kRange_1_6_7,x6Results(i,:),x6stdError(i,:));
end
title('Test of Recovering Type-X6');
xlabel('Sparsity Level k');
ylabel('Rel. Err.');
legend('A/R1/P1','A/R1/P3','A/R2/P1','A/D1/P3','A/D2/P3','A/D3/P3','A/I1','A/I2');
hold off;
figure(6)
hold on;
for i = 1:8
    plot(kRange_1_6_7,x7Results(i,:));
end
title('Test of Recovering Type-X7');
xlabel('Sparsity Level k');
ylabel('Freq. of (Rel. Err. < 1E-3)');
legend('A/R1/P1','A/R1/P3','A/R2/P1','A/D1/P3','A/D2/P3','A/D3/P3','A/I1','A/I2');
hold off;
