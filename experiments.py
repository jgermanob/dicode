import os
ngrams_options = [(1,1),(1,2),(1,3),(2,1),(2,2),(2,3),(3,1),(3,2),(3,3)]
preprocess_options = [[True,True,False,False,False,False,False], [True,False,True,False,False,False,False], [True,False,False,True,False,False,False],
                      [True,False,False,False,True,False,False], [True,False,False,False,False,True,False], [True,False,False,False,False,False,True],
                      [True,True,True,False,False,False,False], [True, True, False, True, False, False, False], [True,True,False,False,True,False,False],
                      [True,True,False,False,False,True,False], [True,True,False,False,False,False,True], [True,True,True,True,False,False,False],
                      [True,True,True,False,True,False,False], [True,True,True,False,False,True,False], [True,True,True,False,False,False,True],
                      [True,True,True,True,True,False,False], [True,True,True,True,False,True,False], [True,True,True,True,False,False,True],
                      [True,True,True,True,True,True,False], [True,True,True,True,True,False,True], [True,True,True,True,True,True,True]]
vectorizer_options = ['count', 'tfidf']
classifier_options = ['svm', 'nv', 'lr', 'rf']

#Prueba de todas las combinaciones posibles
aux = 0
for ngrams in ngrams_options:
    print(ngrams)
    for preprocess in preprocess_options:
        print(preprocess)
        for vec in vectorizer_options:
            print(vec)
            os.system('python3 Clasificador/trainClassifier.py -i xample_bumeran.csv -f a{}{} -v {} -c {} -o classifier.pkl vectorizer.pkl {} {}'.format(ngrams[0],ngrams[1],vec,'svm',preprocess,aux))
                


