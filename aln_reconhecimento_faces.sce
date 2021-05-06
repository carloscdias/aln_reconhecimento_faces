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
//exec('3rd_party/sip_pca_test.sce', -1);

exec('classifiers/utils.sci', -1);
exec('classifiers/simple_classifier.sci', -1);
exec('classifiers/average_classifier.sci', -1);

[ds l] = read_dataset('recdev/hard');
[score, cm, cm_labels, time] = cross_validation(ds, l, 10, simple_classifier_model, simple_classifier_manhattan, %f);
// [score, cm, cm_labels, time] = cross_validation(ds, l, 10, simple_classifier_model, simple_classifier_euclidean, %f);
// [score, cm, cm_labels, time] = cross_validation(ds, l, 10, average_classifier_model, simple_classifier_manhattan, %f);
// [score, cm, cm_labels, time] = cross_validation(ds, l, 10, average_classifier_model, simple_classifier_euclidean, %f);

disp('score', score);
disp('time', time);
disp('labels', cm_labels);
disp('confusion matrix', cm);
