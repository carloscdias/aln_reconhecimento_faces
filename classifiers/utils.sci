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
        img = int_imread(file_list(i));
        img_size = size(img);
        if img_size(3) == 4 then
            img = img(:,:,1:3);
        end
        dataset(:, $ + 1) = img2vec(img);
        [a b c d] = regexp(file_list(i), '/(\d+)-(\d+)\.(?:jpg|png)/');
        labels($ + 1) = d(1);
    end
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
 * Executes 'n' splits, classifications and validations using 'simple_classifier' with 'dataset' and 'labels'
 *
 * dataset: matrix of all images as column-vectors
 * labels: vector of labels corresponding to 'dataset'
 * n: number of runs
 * fn_builder: function that builds the classifier model
 * fn_classifier: function that uses the model to predict a new instance
 * plot_errors: boolean flag indicating whether or not wrong classifications should be plotted
 *
 * score: general score after 'n' runs
 * cm: confusion matrix
 * cm_labels: confusion matrix labels
 * time: time in seconds spent to execute the 'n' runs
 */
function [score, cm, cm_labels, time] = cross_validation(dataset, labels, n, fn_builder, fn_classifier, plot_errors)
    tic();
    cm_labels = unique(labels);
    unique_labels_size = size(cm_labels, 1);
    cm = zeros(unique_labels_size, unique_labels_size);
    score = 1;
    plots = 0;
    for k = 1:n
        [i_train i_test] = split_train_test_indexes(labels, 1);
        [model model_labels] = fn_builder(i_train, dataset, labels);
        test_size = length(i_test);
        err = 0;
        for t = 1:test_size
            [predicted_class projection] = fn_classifier(dataset(:, i_test(t)), model, model_labels);
            i = find(cm_labels == labels(i_test(t)));
            j = find(cm_labels == predicted_class);
            cm(i, j) = cm(i, j) + 1;
            if predicted_class <> labels(i_test(t)) then
                err = err + 1;
                if plot_errors then
                    plot_predicted_real(plots, projection, dataset(:, i_test(t)));
                    plots = plots + 1;
                end
            end
        end
        score = score - err/(n*test_size);
    end
    time = toc();
endfunction

/**
 * Manhattan Distance between two vectors
 *
 * x: vector
 * y: vector
 *
 * manhattan: value of distance
*/
function manhattan = manhattan_distance(x, y)
    manhattan = sum(abs(x - y));
endfunction

/**
 * Euclidean Distance between two vectors
 *
 * x: vector
 * y: vector
 *
 * euclidean: value of distance
*/
function euclidean = euclidean_distance(x, y)
    euclidean = norm(x - y);
endfunction
