innovator = Innovator(100,160);
for i = 1:innovator.sequenceCount
    if sum(abs(innovator.NextInnovation()) - abs(innovator.codebook(i))) > 0
        fprintf('Codebook read %d failed.\n',i);
    else
        fprintf('Success\n');
    end
end