cclear;

fid = fopen('./Research/MultiInstanceLearning/ArticleRevision/article/references.bib','r');
text = fscanf(fid,'%s');
fclose(fid);
text_trim = strtrim(text); % remove white spaces
text_trim_lower = lower(text_trim); % make all lower case
pat = 'journal=[{|"](\w)+[}|"]'; 
journals = regexp(text_trim_lower,pat,'tokens'); % find journal names
journals = [journals{:}]; % convert to cell array of strings

[unique_names, ~, inds] = unique(journals); 
counts = histc(inds, 1:numel(unique_names));

unique_journal_counts = table(unique_names',counts);
unique_journal_counts.Properties.VariableNames = {'JournalName','Count'};
unique_journal_counts
writetable(unique_journal_counts,'./Research/MultiInstanceLearning/ArticleRevision/journal_counts.csv');

clearvars fid text_trim text_trim_lower journals counts unique_names inds counts
