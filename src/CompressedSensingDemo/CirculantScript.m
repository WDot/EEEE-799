DATA_PATH = strcat(fileparts(mfilename('fullpath')),'/../../data/');
m = 128;
n = 512;
ITERATIONS = 100;
kRange_1_6_7 = 20:50;
kRange_3_4 = 0:50;
tic
x1Job = batch('x1Results = X1Test(ITERATIONS,kRange_1_6_7,m,n)');
x3Job = batch('x3Results = X3Test(ITERATIONS,kRange_3_4,m,n)');
x4Job = batch('x4Results = X4Test(ITERATIONS,kRange_3_4,m,n)');
x5Job = batch('[x5Results,x5stdError] = X5Test(ITERATIONS,m,n)');
x6Job = batch('[x6Results,x6stdError] = X6Test(ITERATIONS,kRange_1_6_7,m,n)');
x7Job = batch('x7Results = X7Test(ITERATIONS,kRange_1_6_7,m,n)');
     
wait(x1Job);
x1Results = fetchOutputs(x1Job);
x1Results = x1Results{1,1}.x1Results;
save(strcat(DATA_PATH,'x1Results'),'x1Results');

wait(x3Job);
x3Results = fetchOutputs(x3Job);
x3Results = x3Results{1,1}.x3Results;
save(strcat(DATA_PATH,'x3Results'),'x3Results');

wait(x4Job);
x4Results = fetchOutputs(x4Job);
x4Results = x4Results{1,1}.x4Results;
save(strcat(DATA_PATH,'x4Results'),'x4Results');

wait(x5Job);
x5Results = fetchOutputs(x5Job);
x5stdError = x5Results{1,1}.x5stdError;
x5Results = x5Results{1,1}.x5Results;
save(strcat(DATA_PATH,'x5Results'),'x5Results');
save(strcat(DATA_PATH,'x5stdError'),'x5stdError');

wait(x6Job);
x6Results = fetchOutputs(x6Job);
x6stdError = x6Results{1,1}.x6stdError;
x6Results = x6Results{1,1}.x6Results;
save(strcat(DATA_PATH,'x6Results'),'x6Results');
save(strcat(DATA_PATH,'x6stdError'),'x6stdError');

wait(x7Job);
x7Results = fetchOutputs(x7Job);
x7Results = x7Results{1,1}.x7Results;
save(strcat(DATA_PATH,'x7Results'),'x7Results');

toc

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
