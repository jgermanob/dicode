import pandas as pd
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
import numpy as np
import sys
import chardet
from sklearn.model_selection import KFold
from sklearn.svm import SVC, LinearSVC
from sklearn.naive_bayes import MultinomialNB
from sklearn.linear_model import LogisticRegression
from sklearn.neural_network import MLPClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
from sklearn.preprocessing import LabelEncoder
import pickle
sys.path.append('/home/German/Escritorio/dicode_personal')
from Tools import *
from nltk.stem.snowball import SnowballStemmer
from nltk.corpus import stopwords
from scipy.sparse import coo_matrix, hstack

"""
Función que permite verificar que los argumentos
introducidos en la terminal sean correctos para la
correcta ejecución del  programa
"""
def verify_args(argvs):
    # Valores de n, cuando se selecciona combinación de caracteristicas
    char_ngram_value = 0
    word_ngram_value = 0
    ngram_value = 0
    if len(argvs)==20:
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
        elif argvs[4][0] == 'a':
            features = 'comb'
            char_ngram_value = int(argvs[4][1])
            word_ngram_value = int(argvs[4][2])
        else:
            print("Error, caracteristicas no identificadas")
            exit()
        if argvs[6] == 'count':
            vect = 'count'
        elif argvs[6] == 'tfidf':
            vect = 'tfidf'
        else:
            print("Error, vectorizador no identificado")
            exit()
        if argvs[8] == 'svm':
            clf = 'svm'
        elif argvs[8] == 'nv':
            clf = 'nv'
        elif argvs[8] == 'lr':
            clf = 'lr'
        elif argvs[8] == 'rf':
            clf = 'rf'
        else:
            print('Error, clasificador no identificado')
            exit()
        if argvs[10].split('.')[1] == 'pkl':
            model_name = argvs[10]
        else:
            print("Error, el nombre no tiene extensión .pkl")
            exit()
        if argvs[11].split('.')[1] == 'pkl':
            vectorizer_name = argvs[11]
        else:
            print("Error, el nombre no tiene extensión .pkl")
            exit()
        # Obtener lista de combinación del pre-procesamiento
        preprocessing_options = []
        preprocessing_options.append(argvs[12].split('[')[1].split(',')[0])
        preprocessing_options.append(argvs[13].split(',')[0])
        preprocessing_options.append(argvs[14].split(',')[0])
        preprocessing_options.append(argvs[15].split(',')[0])
        preprocessing_options.append(argvs[16].split(',')[0])
        preprocessing_options.append(argvs[17].split(',')[0])
        preprocessing_options.append(argvs[18].split(']')[0])
        log_name = argvs[19]
    else:
        print(argvs, len(argvs))
        print("Error en los argumentos")
        exit()
    return filename, features, vect, clf, ngram_value, model_name, vectorizer_name, char_ngram_value, word_ngram_value, preprocessing_options, log_name

"""
Función para obtener los vectores
de cada ejemplo necesarios para entrenar el sistema.
"""
def get_features(dataframe, features, vect, ngram, preprocess_options, word_ngram=None, char_ngram=None):
    labelEncoder = LabelEncoder()
    texts = [text for text in dataframe['texto']]
    targets = [target for target in dataframe['area_trab']]
    lowercase_option, stopwords_option, accents_option, punct_option, num_option, stemm_option, oneline_option = get_preprocessing_options(preprocess_options)
    texts = preprocessing(texts,lowercase_option, stopwords_option, accents_option, punct_option, num_option, stemm_option, oneline_option)
    # Preprocesamiento del texto
    #texts = normalize_text(texts)
    #texts = text2lowercase(texts)
    #texts = removeStopwords(texts,sws)
    #texts = removeAccentsFromText(texts)
    #texts = removePunctuation(texts)
    #texts = removeNumbersFromTexts(texts)
    #texts = stemmingTexts(texts, stemmer)
    #texts = oneLineTexts(texts)
    #Obtención de vectores de caracteristicas
    if features == 'word':
        vectorizer = get_vectorizer(vect,ngram)
        x = vectorizer.fit_transform(texts)
    elif features == 'char':
        vectorizer = get_vectorizer(vect,ngram)
        x = vectorizer.fit_transform(texts)
    elif features == 'comb':
        word_vectorizer = get_vectorizer(vect, word_ngram)
        char_vectorizer = get_vectorizer(vect, char_ngram)
        word_x = word_vectorizer.fit_transform(texts)
        char_x = char_vectorizer.fit_transform(texts)
        #x = hstack([word_x,char_x]).toarray()
        x = hstack([word_x,char_x])
    # Codificación de las etiquetas
    y = labelEncoder.fit_transform(targets)
    save_models('labelEncoder.pkl',labelEncoder)
    return x, y

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
filename, features, vect, clf, ngram, model_name, vectorizer_name, char_ngram, word_ngram, preprocess_options, log_name = verify_args(sys.argv)
data = get_data(filename)
x, y = get_features(data, features, vect,ngram, preprocess_options, word_ngram, char_ngram)
#classifier = get_classifier(clf)
svm_classifier = get_classifier('svm')
nv_classifier = get_classifier('nv')
lr_classifier = get_classifier('lr')
rf_classifier = get_classifier('rf')

#####################
# Log de evaluación #
#####################
lowercase_option, stopwords_option, accents_option, punct_option, num_option, stemm_option, oneline_option = get_preprocessing_options(preprocess_options)
evaluation_file = open('Results/evaluation_{}.txt'.format(log_name), 'w', encoding='utf8')
evaluation_file.write('Preprocess: Lowercase:{}, stopwords:{}, accents:{}, punct:{}, numbers:{}, stemming:{}, one-line:{}\n'.format(lowercase_option,stopwords_option,accents_option,punct_option, num_option, stemm_option, oneline_option))
evaluation_file.write('Features: {}, word_ngram= {} char_ngram= {}\n'.format(features, word_ngram, char_ngram))
evaluation_file.write('Vectorizer:{}\n'.format(vect))

x_train, x_test, y_train, y_test = train_test_split(x,y, test_size=0.30, random_state=42)
#Training classifiers
svm_classifier.fit(x_train,y_train)
nv_classifier.fit(x_train,y_train)
lr_classifier.fit(x_train,y_train)
rf_classifier.fit(x_train,y_train)
    
#SVM
y_pred = svm_classifier.predict(x_test)
#Evaluación del modelo
accuracy = accuracy_score(y_test, y_pred)
precision = precision_score(y_test, y_pred, average='macro')
recall = recall_score(y_test, y_pred, average='macro')
f1 = f1_score(y_test, y_pred, average='macro')
evaluation_file.write('\n\nSupport Vector Machine:')
evaluation_file.write('\nAccuracy = {}'.format(accuracy))
evaluation_file.write('\nPrecision = {}'.format(precision))
evaluation_file.write('\nRecall = {}'.format(recall))
evaluation_file.write('\nF1-score = {}'.format(f1))

#Naive-Bayes
y_pred = nv_classifier.predict(x_test)
#Evaluación del modelo
accuracy = accuracy_score(y_test, y_pred)
precision = precision_score(y_test, y_pred, average='macro')
recall = recall_score(y_test, y_pred, average='macro')
f1 = f1_score(y_test, y_pred, average='macro')
evaluation_file.write('\n\nNaive Bayes:')
evaluation_file.write('\nAccuracy = {}'.format(accuracy))
evaluation_file.write('\nPrecision = {}'.format(precision))
evaluation_file.write('\nRecall = {}'.format(recall))
evaluation_file.write('\nF1-score = {}'.format(f1))

#Logistic Regression
y_pred = lr_classifier.predict(x_test)
#Evaluación del modelo
accuracy = accuracy_score(y_test, y_pred)
precision = precision_score(y_test, y_pred, average='macro')
recall = recall_score(y_test, y_pred, average='macro')
f1 = f1_score(y_test, y_pred, average='macro')
evaluation_file.write('\n\nLogistic Regression:')
evaluation_file.write('\nAccuracy = {}'.format(accuracy))
evaluation_file.write('\nPrecision = {}'.format(precision))
evaluation_file.write('\nRecall = {}'.format(recall))
evaluation_file.write('\nF1-score = {}'.format(f1))

# Random Forest
y_pred = rf_classifier.predict(x_test)
#Evaluación del modelo
accuracy = accuracy_score(y_test, y_pred)
precision = precision_score(y_test, y_pred, average='macro')
recall = recall_score(y_test, y_pred, average='macro')
f1 = f1_score(y_test, y_pred, average='macro')
evaluation_file.write('\n\nRandom forest:')
evaluation_file.write('\nAccuracy = {}'.format(accuracy))
evaluation_file.write('\nPrecision = {}'.format(precision))
evaluation_file.write('\nRecall = {}'.format(recall))
evaluation_file.write('\nF1-score = {}'.format(f1))