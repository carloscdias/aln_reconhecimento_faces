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
 * Transforms a normalized gray-scale column-vector image into a 100x100 gray-scale image
 *
 * vec: column-vector image
 *
 * img: output image
 */
function img = vec2img(vec)
    img = matrix(uint8(vec*255), 100, 100);
endfunction

/**
 * Transforms a RGB image into a normalized gray-scale column-vector of the image
 *
 * img: rgb image
 *
 * vec: output vector
 */
function vec = img2vec(img)
    img_gray = rgb2gray(img);
    [r c] = size(img_gray);
    vec = matrix(double(img_gray)/255, r*c, 1);
endfunction

/**
 * Reads all images inside 'dataset_path' that follows the format
 * 'dataset_path/(\d+)-(\d+).(jpg|png)'
 *
 * dataset_path: path where the images will be read from
 *               ex.: 'recdev/very-easy'
 *
 * dataset: matrix of all images as column-vectors
 * labels: vector where the ith element corresponds to the label of the
 *         ith column in 'dataset'
 */
function [dataset, labels] = read_dataset(dataset_path)
    jpg_pattern = strcat([pathconvert(dataset_path), '*.jpg']);
    png_pattern = strcat([pathconvert(dataset_path), '*.png']);
    file_list = listfiles([jpg_pattern, png_pattern]);
    dataset_size = size(file_list, 1);
    dataset = [];
    for i = 1:dataset_size
        img = imread(file_list(i));
        dataset(:, $ + 1) = img2vec(img);
        [a b c d] = regexp(file_list(i), '/(\d+)-(\d+)\.(?:jpg|png)/');
        labels($ + 1) = d(1);
    end
endfunction

/**
 * Classifies a given index belonging to 'full_dataset' in a class in 'full_labels'
 * according to the minimum euclidean distance between the the image given by x_index
 * and the images given by train_indexes
 *
 * x_index: index of 'full_dataset' where is the image to be classified
 * train_indexes: indexes in 'full_dataset' to consider when computing the euclidean distance
 * full_dataset: matrix of all images as column-vectors
 * full_labels: vector where the ith element corresponds to the label of the
 *              ith column in 'full_dataset'
 *
 * class: predicted class/label of image given by 'x_index'
 * closest: index of the column-vector image closest to the image given by 'x_index'
 *          according to euclidean distance
 */
function [class, closest] = simple_classifier(x_index, train_indexes, full_dataset, full_labels)
    dataset_size = length(train_indexes);
    min_distance = %inf;
    for i = 1:dataset_size
        distance = norm(full_dataset(:, train_indexes(i)) - full_dataset(:, x_index));
        if distance < min_distance then
            min_distance = distance;
            class = full_labels(train_indexes(i));
            closest = train_indexes(i);
        end
    end
endfunction

/**
 * Split a vector of labels into two vector of indexes
 *
 * labels: vector of labels
 * test_samples_per_class: integer indicating how many test samples per class are
 *                         going to be in 'i_test'
 *
 * i_train: vector of indexes supposed to be used as training
 * i_test: vector of indexes supposed to be used as test with 'test_samples_per_class'
 */
function [i_train, i_test] = split_train_test_indexes(labels, test_samples_per_class)
    unique_labels = unique(labels);
    unique_labels_size = size(unique_labels, 1);
    i_train = [];
    i_test = [];
    for class_i = 1:unique_labels_size
        class_i_train = find(labels == unique_labels(class_i));
        for k = 1:test_samples_per_class
            class_size = length(class_i_train);
            random_i = floor(rand()*class_size + 1);
            i_test($ + 1) = class_i_train(random_i);
            class_i_train = class_i_train(1:class_size <> random_i);
        end
        i_train = cat(1, i_train, class_i_train);
    end
    i_train = gsort(i_train, 'g', 'i');
    i_test = gsort(i_test, 'g', 'i');
endfunction

/**
 * Plot two images side by side with labels 'Predicted' and 'Real' in the n-th window
 *
 * n: window index handler
 * predicted_img: normalized colum-vector of the grayscale predicted image
 * real_img: normalized colum-vector of the grayscale real image
 */
function plot_predicted_real(n, predicted_img, real_img)
    scf(n);
    subplot(121);
    imshow(vec2img(predicted_img));
    xlabel('Predicted');
    subplot(122);
    imshow(vec2img(real_img));
    xlabel('Real');
endfunction

/**
 * Executes 'n' splits, classifications and validations using 'simple_classifier' with 'dataset' and 'labels'
 *
 * dataset: matrix of all images as column-vectors
 * labels: vector of labels corresponding to 'dataset'
 * n: number of runs
 * plot_errors: boolean flag indicating whether or not wrong classifications should be plotted
 *
 * score: general score after 'n' runs
 * cm: confusion matrix
 * cm_labels: confusion matrix labels
 * time: time in seconds spent to execute the 'n' runs
 */
function [score, cm, cm_labels, time] = cross_validation(dataset, labels, n, plot_errors)
    tic();
    cm_labels = unique(labels);
    unique_labels_size = size(cm_labels, 1);
    cm = zeros(unique_labels_size, unique_labels_size);
    score = 0;
    plots = 0;
    for k = 1:n
        [i_train i_test] = split_train_test_indexes(labels, 1);
        test_size = length(i_test);
        err = 0;
        for t = 1:test_size
            [predicted_class closest] = simple_classifier(i_test(t), i_train, dataset, labels);
            i = find(cm_labels == labels(i_test(t)));
            j = find(cm_labels == predicted_class);
            cm(i, j) = cm(i, j) + 1;
            if predicted_class == labels(i_test(t)) then
                err = err + 1;
            elseif plot_errors then
                plot_predicted_real(plots, dataset(:, closest), dataset(:, i_test(t)));
                plots = plots + 1;
            end
        end
        score = score + err/(n*test_size);
    end
    time = toc();
endfunction

[ds l] = read_dataset('recdev/medium');
[score, cm, cm_labels, time] = cross_validation(ds, l, 1, %t);

disp('score', score);
disp('time', time);
disp('labels', cm_labels);
disp('confusion matrix', cm);

