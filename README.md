# Projeto Reconhecimento de Faces

Código realizado no software Scilab pelos alunos Carlos Cardoso Dias e Maria Eduarda Ornelas Hisse para a disciplina Álgebra Linear Numérica, Engenharia de Computação, IPRJ/UERJ, Nova Friburgo, 2021.

### Desenvolvimento

1. Escrever rotinas para ler os arquivos de imagem em matrizes de pixels 2D e organizá-los em uma lista de vetores de pixels 1D;

2. Escrever o reconhecedor mais simples possível por similaridade de imagem direta (norma de imagem
  diferença, ou seja, distância euclidiana);

3. Escrever validação cruzada para o classificador simples:
  3.1 Separar as imagens em conjuntos de teste e treinamento;
  3.2 Produir a pontuação de reconhecimento (score), tempo de execução e a matriz de confusão.

4. Modificar a forma como se calcula a similaridade para incrementar a pontuação de reconhecimento.

### Usando os arquivos
  
  Ao baixar o repositório, executa-se o arquivo **aln_reconhecimento_faces.sce**, mas se atente ao fato de:

1. Ler os arquivos através da função **read_dataset**, passando como parâmetro o caminho da pasta com as imagens e obtendo como saída a matriz de todas as imagens como coluna-vetores e o vetor com a categoria de cada coluna da matriz;

2. Obter os resultados através da função **cross_validation**, passando como parâmetro as saídas da função **read_dataset**, o número de simulações desejadas, a função desejada para a construção do modelo, a função desejada para classificação e um parâmetro booleano que indica se a simulação deve ou não plottar as predições em que ocorreram falhas.

##### Exemplo de execução

Neste exemplo estamos usando a pasta hard e serão executadas 10 simulações utilizando o algoritmo de distância padrão,
onde cada imagem de treinamento e comparada com a imagem alvo e retorna-se a que tenha a menor distância, para esse
exemplo, a distância manhattan.

    [ds l] = read_dataset('recdev/hard');
    [score, cm, cm_labels, time] = cross_validation(ds, l, 10, simple_classifier_model, simple_classifier_manhattan, %f);

