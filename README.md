# Projeto Reconhecimento de Faces

Código realizado no software Scilab pelos alunos Carlos Cardoso Dias e Maria Eduarda Ornelas Hisse para a disciplina Álgebra Linear Numérica, Engenharia de Computação, IPRJ/UERJ, Nova Friburgo, 2021.

### Desenvolvimento

1. Escrever rotinas para ler os arquivos de imagem em matrizes de pixels 2D e organizá-los em uma lista de vetores de pixels 1D;

2. Escrever o reconhecedor mais simples possível por similaridade de imagem direta (norma de imagem diferença, ou seja, distância euclidiana);

3. Escrever validação cruzada para o classificador simples:
  3.1 Separar as imagens em conjuntos de teste e treinamento;
  3.2 Produzir a pontuação de reconhecimento (score), tempo de execução e a matriz de confusão.

4. Modificar a forma como se calcula a similaridade para incrementar a pontuação de reconhecimento;

5. Implementar a técnica de PCA:
  5.1. empilhar os vetores de imagem como colunas de uma matriz de dados;
  5.2. opcionalmente subtrair o vetor médio de cada coluna;
  5.3. comprimir a matriz usando svd para dimensão n usando os n principais valores singulares;
  5.4. projetar cada nova imagem para o espaço das colunas na matriz;
  5.5. comparar semelhança de imagem com base em:
    5.5.1. distância entre vetores de dimensão reduzida;
    5.5.2. distância de projeção para cada subespaço de cada face;
    5.5.3. distância entre vetores reconstruídos.
  5.6. alterar n em (5, 3);
  5.7. taxas de reconhecimento de saída para cada alteração feita;

6. Executar os benchmarks no conjunto de dados;

7. Ajustar o algoritmo e estudar os casos de falha;

8. Dimensionar o código para o conjunto de dados médio;8

9. Implementar uma técnica mais complicada e taxas de reconhecimento de saída;

10. Escalar o algoritmo para o conjunto de dados rígido;

11. Testar os conjuntos de dados restantes, possivelmente antes de ir para o disco conjunto de dados

### Usando os arquivos
  
  Ao baixar o repositório, executa-se o arquivo **aln_reconhecimento_faces.sce**, mas se atente ao fato de:

1. Ler os arquivos através da função **read_dataset**, passando como parâmetro o caminho da pasta com as imagens e obtendo como saída a matriz de todas as imagens como coluna-vetores e o vetor com a categoria de cada coluna da matriz;

2. Obter os resultados com as técnicas mais simples através da função **cross_validation**, passando como parâmetro as saídas da função **read_dataset**, o número de simulações desejadas, a função desejada para a construção do modelo (simple_classifier_model ou average_classifier_model), a função desejada para classificação (simple_classifier_manhattan ou simple_classifier_euclidean) e um parâmetro booleano que indica se a simulação deve ou não plottar as predições em que ocorreram falhas;

3. Obter os resultados com a técnica do PCA através da função **cross_validation_pca**, passando como parâmetro as saídas da função **read_dataset**, o número de simulações desejadas, um parâmetro booleano que indica se a simulação deve ou não plottar as predições em que ocorreram falhas e o fator de compressão.

#### Exemplo de execução

Neste exemplo estamos usando a pasta hard e serão executadas 10 simulações utilizando o algoritmo de distância padrão,
onde cada imagem de treinamento e comparada com a imagem alvo e retorna-se a que tenha a menor distância, para esse
exemplo, a distância manhattan.

    [ds l] = read_dataset('recdev/hard');
    [score, cm, cm_labels, time] = cross_validation(ds, l, 10, simple_classifier_model, simple_classifier_manhattan, %f);

