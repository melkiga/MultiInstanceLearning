cclear;
option = 1;
algorithms = dir('C:/Code/EclipseWorkspace/MultiInstanceSVM/src/mi/experimental/*.java');
datasets = dir('./Research/Cano/MultiInstanceClassification/WekaTesting/data/*.arff');

% creates bash script to run SOA in parallel
if option == 1
    try     
        fid = fopen('./Research/Cano/MultiInstanceClassification/WekaTesting/parallel_script.sh','w+');  % for removing the extension
        for alg = algorithms'
            algorithm = alg.name(1:end-5);
            string_comm = ['java -cp MIexperiments.jar mi.experimental.' algorithm];
            for data = datasets' % create a command for each dataset
                data_name = data.name(1:end-5);
                string_comm = [string_comm ' ' data_name];
            end
            string_comm = [string_comm ' &'];
            %disp(string_comm);
            fprintf(fid,'%s\n',string_comm);
        end
    catch
        fclose('all');
        exit;
    end
else
    for alg = algorithms'
        algorithm = alg.name(1:end-5);
        try
            fid = fopen(['./Research/Cano/MultiInstanceClassification/WekaTesting/' algorithm '.sh'],'w+');  % for removing the extension
            string_comm = ['java -cp MIexperiments.jar mi.experimental.' algorithm];
            for data = datasets'
                data_name = data.name(1:end-5);
                string_comm = [string_comm ' ' data_name];
            end
            %disp(string_comm);
            fprintf(fid,'%s\n',string_comm);
        catch
            fclose('all');
            exit;
        end
    end

end
fclose('all');