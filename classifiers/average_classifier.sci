/**
 * Builds an average model with available 'train_indexes'
 *
 * train_indexes: vector of indexes used to build the model
 * dataset: matrix of all column-vector images available
 * labels: vector where the ith element corresponds to the label of the
 *         ith column in 'dataset'
 *
 * model: column-vector images that the classifier knows averaged by label
 * model_labels: labels that the classifier knows
 */
function [model, model_labels] = average_classifier_model(train_indexes, dataset, labels)
    training_labels = labels(train_indexes);
    training_dataset = dataset(:, train_indexes);
    model_labels = unique(training_labels);
    model_labels_size = size(model_labels, 1);
    model = [];
    for p = 1:model_labels_size
        label = model_labels(p);
        l_indexes = find(training_labels == label);
        model(:, $ + 1) = mean(training_dataset(:, l_indexes), 2);
    end
endfunction
