innovator = Innovator(100000,160);
range = -5:.1:5;
bincounts = zeros(size(range));
for i = 1:innovator.sequenceCount
    sequence = innovator.NextInnovation();
    bincounts = bincounts + histc(sequence,range);
end
plot(bincounts);