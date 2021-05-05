/*
 * Grupo:
 *  Carlos Cardoso Dias
 *  Maria Eduarda Ornelas Hisse
 *
 * Reconhecimento de faces
 */

// atomsInstall("IPCV")

// loading external routines
exec('3rd_party/sip_pca.sci', -1);
exec('3rd_party/sip_pca_project.sci', -1);
// exec('3rd_party/sip_pca_test.sce', -1);

/**
 * 
 * dataset_path: 'recdev/very-easy'
 */
function [dataset, labels] = read_dataset(dataset_path)
    jpg_pattern = strcat([pathconvert(dataset_path), '*.jpg']);
    png_pattern = strcat([pathconvert(dataset_path), '*.png']);
    file_list = listfiles([jpg_pattern, png_pattern]);
    dataset_size = size(file_list, 1);
    dataset = [];
    for i = 1:dataset_size
        img = imread(file_list(i));
        img_gray = rgb2gray(img);
        [r c] = size(img_gray);
        dataset(:, $ + 1) = matrix(double(img_gray), r*c, 1);
        [a b c d] = regexp(file_list(i), '/(\d+)-(\d+)\.(?:jpg|png)/');
        labels($ + 1) = d(1);
    end
endfunction

function class = simple_classifier(x, dataset, labels)
    dataset_size = size(dataset, 2);
    min_distance = %inf;
    for i = 1:dataset_size
        distance = norm(dataset(:, i) - x);
        if distance < min_distance then
            min_distance = distance;
            class = labels(i);
        end
    end
endfunction

function [score, cm, cm_labels, time] = cross_validation(dataset, labels, n)
    tic();
    cm_labels = unique(labels);
    unique_labels_size = size(cm_labels, 1);
    dataset_size = size(dataset, 2);
    cm = zeros(unique_labels_size, unique_labels_size);
    score = 0;
    for i = 1:n
        test_x = [];
        test_y = [];
        train_x = dataset;
        train_y = labels;
        for label_i = 1:unique_labels_size
            label_indexes = find(train_y == cm_labels(label_i));
            label_indexes_size = length(label_indexes);
            random_index = round(rand()*(label_indexes_size - 1) + 1);
            random_pick = label_indexes(random_index);
            test_x(:, $ + 1) = train_x(:, random_pick);
            test_y($ + 1) = train_y(random_pick);
            l = size(train_x, 2);
            train_x = train_x(:, 1:l <> random_pick);
            train_y = train_y(1:l <> random_pick);
        end
        
        test_size = size(test_x, 2);
        err = 0;
        for test_i = 1:test_size
            class = simple_classifier(test_x(:, test_i), train_x, train_y);
            i = find(cm_labels == test_y(test_i));
            j = find(cm_labels == class);
            cm(i, j) = cm(i, j) + 1;
            if class == test_y(test_i) then
                err = err + 1;
            end
        end
        score = score + err/(n*test_size);
    end
    time = toc();
endfunction

[ds l] = read_dataset('recdev/very-easy');
[score cm, cm_labels, time] = cross_validation(ds, l, 10);

disp('score', score);
disp('time', time);
disp('labels', cm_labels);
disp('confusion matrix', cm);

