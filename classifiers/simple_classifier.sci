/**
 * Classifies a given column-vector into a class in 'model_labels'
 * according to the minimum distance given by 'fn_distance' between the x and
 * each row in 'model'
 *
 * x: image to be classified
 * model: matrix of all known images as column-vectors
 * model_labels: vector where the ith element corresponds to the label of the
 *               ith column in 'model'
 * fn_distance: function used to calculate distance between two vectors
 *
 * class: predicted class/label of image given by 'x'
 * projection: column-vector image as seen by the 'model' glass
 */
function [class, projection] = simple_classifier(x, model, model_labels, fn_distance)
    model_size = size(model, 2);
    min_distance = %inf;
    for i = 1:model_size
        distance = fn_distance(model(:, i), x);
        if distance < min_distance then
            min_distance = distance;
            class = model_labels(i);
            projection = model(:, i);
        end
    end
endfunction

/**
 * Same as 'simple_classifier' but with default 'manhattan_distance'
 */
function [class, projection] = simple_classifier_manhattan(x, model, model_labels)
    [class, projection] = simple_classifier(x, model, model_labels, manhattan_distance);
endfunction

/**
 * Same as 'simple_classifier' but with default 'euclidean_distance'
 */
function [class, projection] = simple_classifier_euclidean(x, model, model_labels)
    [class, projection] = simple_classifier(x, model, model_labels, euclidean_distance);
endfunction

/**
 * Builds a simple model with available 'train_indexes'
 *
 * train_indexes: vector of indexes used to build the model
 * dataset: matrix of all column-vector images available
 * labels: vector where the ith element corresponds to the label of the
 *         ith column in 'dataset'
 *
 * model: column-vector images that the classifier knows
 * model_labels: labels that the classifier knows
 */
function [model, model_labels] = simple_classifier_model(train_indexes, dataset, labels)
    model = dataset(:, train_indexes);
    model_labels = labels(train_indexes);
endfunction
