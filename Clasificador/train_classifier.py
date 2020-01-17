import pandas as pd
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
import numpy as np
import sys
import chardet
from sklearn.model_selection import KFold
from sklearn.svm import SVC, LinearSVC
from sklearn.naive_bayes import GaussianNB, MultinomialNB
from sklearn.linear_model import LogisticRegression
from sklearn.neural_network import MLPClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, classification_report
from sklearn.preprocessing import LabelEncoder
import pickle
sys.path.append('/home/German/Escritorio/dicode_personal')
from Tools import *
from nltk.stem.snowball import SnowballStemmer
from nltk.corpus import stopwords
#from imblearn.over_sampling import SMOTE
from collections import Counter

"""
Función que permite verificar que los argumentos
introducidos en la terminal sean correctos para la
correcta ejecución del  programa
"""
def verify_args(argvs):
    if len(argvs)==8:
        if argvs[2].split('.')[1] == 'csv':
            filename = argvs[2]
        else:
            print("El archivo no está en formato .csv")
            print(argvs[2].split('.'))
            exit()
        if argvs[4][0] == 'w':
            features = 'word'
            ngram_value = int(argvs[4][1])
        elif argvs[4][0] == 'c':
            features = 'char'
            ngram_value = int(argvs[4][1])
        else:
            print(argvs[4].split(''))
            print("Error, caracteristicas no identificadas")
            exit()
        model_name = argvs[6]
        vectorizer_name = argvs[7]
    else:
        print("Error en los argumentos")
        exit()
    return filename, features, ngram_value, model_name, vectorizer_name

"""
Función para obtener los vectores de características y las etiquetas
de cada ejemplo necesarios para entrenar el sistema.
"""
def get_features(dataframe, features, ngram):
    labelEncoder = LabelEncoder()
    stemmer = SnowballStemmer('spanish')
    sws = list(stopwords.words('spanish'))
    dataframe = dataframe[(dataframe.area_trab == 'Administración') | (dataframe.area_trab == 'Call Center')]
    texts = [text for text in dataframe['texto']]
    targets = [target for target in dataframe['area_trab']]
    # Preprocesamiento del textoLogisticRegression()
    texts = normalize_text(texts)
    #texts = text2lowercase(texts)
    #texts = removeStopwords(texts,sws)
    #texts = removeAccentsFromText(texts)
    #texts = removePunctuation(texts)
    #texts = removeNumbersFromTexts(texts)
    #texts = stemmingTexts(texts, stemmer)
    #texts = oneLineTexts(texts)
    if features == 'word':
        vectorizer = CountVectorizer(ngram_range=(ngram,ngram))
        x = vectorizer.fit_transform(texts)
    elif features == 'char':
        vectorizer = CountVectorizer(ngram_range=(ngram,ngram), analyzer='char')
        x = vectorizer.fit_transform(texts)
    y = labelEncoder.fit_transform(targets)
    #Over-sampling data using SMOTE
    #sampler = SMOTE(k_neighbors=1)
    #x, y = sampler.fit_resample(x, y)
    #print(sorted(Counter(y).items()))
    save_models('labelEncoder.pkl',labelEncoder)
    return x, y, vectorizer

"""
Función para guardar los modelos del clasificador,
vectorizador y codificador de etiquetas
"""
def save_models(model_name, model):
    model_file = open(model_name,'wb')
    pickle.dump(model, model_file)

#######################################
#       EJECUCIÓN DEL PROGRAMA        #
#######################################
filename, features, ngram, model_name, vectorizer_name = verify_args(sys.argv)
data = get_data(filename)
x, y, vectorizer = get_features(data, features, ngram)
accuracy_results = []
precision_results = []
recall_results = []
f1_results = []
classifier = LinearSVC()

#####################
# Log de evaluación #
#####################
evaluation_file = open('evaluation_'+str(features)+str(ngram)+'_.txt', 'w', encoding='utf8')
evaluation_file.write('Features: '+ features + ' ngram_value:' + str(ngram)+ '\n')
evaluation_file.write('Model: ' + type(classifier).__name__ +'\n\n')

kfold = KFold(n_splits=10)
index = 1
for train_index, test_index in kfold.split(x,y):
    x_train, x_test = x[train_index], x[test_index]
    y_train, y_test = y[train_index], y[test_index]
    classifier.fit(x_train,y_train)
    y_pred = classifier.predict(x_test)
    #Evaluación del modelo
    accuracy = accuracy_score(y_test, y_pred)
    precision = precision_score(y_test, y_pred)
    recall = recall_score(y_test, y_pred)
    f1 = f1_score(y_test, y_pred)
    #report = classification_report(y_test, y_pred)
    #evaluation_file.write('{}\n'.format(report))
    evaluation_file.write(str(index) + '-fold: Accuracy = ' + str(accuracy) + '\n\tPrecision = ' + str(precision) + '\n\tRecall = ' + str(recall) + '\n\tF1-score = ' + str(f1) + '\n\n')
    accuracy_results.append(accuracy)
    precision_results.append(precision)
    recall_results.append(recall)
    f1_results.append(f1)
    index += 1

evaluation_file.write('\n\nAccuracy (Average) = {}'.format(np.mean(accuracy_results)))
evaluation_file.write('\nPrecision (Average) = {}'.format(np.mean(precision_results)))
evaluation_file.write('\nRecall (Average) = {}'.format(np.mean(recall_results)))
evaluation_file.write('\nF1-score (Average) = {}'.format(np.mean(f1_results)))
save_models(model_name, classifier)
save_models(vectorizer_name, vectorizer)












LogisticRegression()