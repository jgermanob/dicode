import chardet
import pandas as pd
import pickle
from nltk.stem.snowball import SnowballStemmer
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn.svm import LinearSVC
from sklearn.naive_bayes import MultinomialNB
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
import re

"""
Función para obtener la codificación del archivo .csv
desde donde se obtienen los textos para entrenamiento y
evaluación del sistema
"""
def get_encoding(filename):
    f = open(filename, 'rb').read()
    result = chardet.detect(f)
    encoding = result['encoding']
    return encoding

"""
Función para obtener un dataframe a parir del
archivo .csv de entrada
"""
def get_data(filename):
    encoding = get_encoding(filename)
    dataframe = pd.read_csv(filename, encoding=encoding)
    return dataframe

def get_preprocessing_options(options_list):
    lowercase_option = options_list[0]
    stopwords_option = options_list[1]
    accents_option = options_list[2]
    punct_option = options_list[3]
    num_option = options_list[4]
    stemm_option = options_list[5]
    oneline_option = options_list[6]
    return lowercase_option, stopwords_option, accents_option, punct_option, num_option, stemm_option, oneline_option


def preprocessing(texts,lowercase_option=False, stopwords_option=False, accents_option=False, punct_option=False, num_option=False, stemm_option=False, oneline_option=False):
    texts = normalize_text(texts)
    if lowercase_option == True:
        texts = text2lowercase(texts)
    if stopwords_option == True:
        texts = removeStopwords(texts, list(stopwords.words('spanish')))
    if accents_option == True:
        texts = removeAccentsFromText(texts)
    if punct_option == True:
        texts = removePunctuation(texts)
    if num_option == True:
        texts = removeNumbersFromTexts(texts)
    if stemm_option == True:
        texts = stemmingTexts(texts, SnowballStemmer('spanish'))
    if oneline_option == True:
        texts = oneLineTexts(texts)
    return texts

"""
Función para obtener los vectorizadores necesarios
conforme a los parámetros de entrada
"""
def get_vectorizer(vect, ngram):
    if vect == 'count':
        vectorizer = CountVectorizer(ngram_range=(ngram,ngram))
        return vectorizer
    elif vect == 'tfidf':
        vectorizer = TfidfVectorizer(ngram_range=(ngram,ngram))
    return vectorizer

"""
Función para obtener el clasificador necesario
conforme a los parámetros de entrada
"""
def get_classifier(clf):
    if clf == 'svm':
        classifier = LinearSVC()
    elif clf == 'nv':
        classifier = MultinomialNB()
    elif clf == 'lr':
        classifier = LogisticRegression()
    elif clf == 'rf':
        classifier = RandomForestClassifier()
    return classifier

"""
Función que permite cargar los modelos del clasificador
y del vectorizador obtenidos durante la etapa de entrenamiento
para realizar predicciones.
"""
def load_model(model_name):
    model_file = open(model_name, 'rb')
    model = pickle.load(model_file)
    return model

#################################
# FUNCIONES DE PREPROCESAMIENTO #
################################# 
"""
Función que permite normalizar los textos
en caso de que estos estén vacios.
"""
def normalize_text(texts):
    for index in range(len(texts)):
        if isinstance(texts[index],float):
            texts[index]='-'
    return texts

"""
Función  que permite pasar a minusculas una colección de textos
contenidos en una columna de un dataframe de pandas.
"""
def text2lowercase(text_list):
    size = len(text_list)
    for index in range(size):
        text_list[index] = text_list[index].lower()
    return text_list

"""
Realiza el proceso de remoción de palabras funcionales
(stopwords) a partir de una lista de stopwords
"""
def removeStopwordsfromText(text, stopwords):
    clean_text = ''
    tokens = text.split(' ')
    for token in tokens:
        if token not in stopwords:
            clean_text += token + ' '
    return clean_text.strip()

def removeStopwords(text_list, stopwords):
    clean_texts = []
    for text in text_list:
        clean_texts.append(removeStopwordsfromText(text,stopwords))
    return clean_texts

"""
Realiza la remoción de acentos de los textos
a clasificar
"""
def removeAccents(text):
    accents = ['á', 'é', 'í', 'ó', 'ú']
    no_accents = ['a', 'e', 'i', 'o', 'u']
    for index in range(len(accents)):
        text = text.replace(accents[index], no_accents[index])
    return text

def removeAccentsFromText(text_list):
    clean_text = []
    for text in text_list:
        clean_text.append(removeAccents(text))
    return clean_text

"""
Realiza la remoción de signos de puntuación de
los textos a clasificar
"""
def removePunctuationFromText(text, punctuation):
    text = str(text)
    for punct in punctuation:
        if punct in text:
            text = text.replace(punct,' ')
    return text

def removePunctuation(text_list):
    punct = [',', '.', '"', ':', ')', '(', '-', '!', '?', '|', ';', "'", '$', '&', '/', '[', ']', '>', '%', '=', '#', '*', '+', '\\', '•',  '~', '@', '£', 
 '·', '_', '{', '}', '©', '^', '®', '`',  '<', '→', '°', '€', '™', '›',  '♥', '←', '×', '§', '″', '′', 'Â', '█', '½', 'à', '…', 
 '“', '★', '”', '–', '●', 'â', '►', '−', '¢', '²', '¬', '░', '¶', '↑', '±', '¿', '▾', '═', '¦', '║', '―', '¥', '▓', '—', '‹', '─', 
 '▒', '：', '¼', '⊕', '▼', '▪', '†', '■', '’', '▀', '¨', '▄', '♫', '☆', 'é', '¯', '♦', '¤', '▲', 'è', '¸', '¾', 'Ã', '⋅', '‘', '∞', 
 '∙', '）', '↓', '、', '│', '（', '»', '，', '♪', '╩', '╚', '³', '・', '╦', '╣', '╔', '╗', '▬', '❤', 'ï', 'Ø', '¹', '≤', '‡', '√', ]
    clean_texts = []
    for text in text_list:
        clean_texts.append(removePunctuationFromText(text, punct))
    return clean_texts

"""
Realiza el proceso de remoción de números de 
los textos a clasificar
"""
def removeNumbers(text):
    if bool(re.search(r'\d', text)):
        text = re.sub('[0-9]{5,}', '#####', text)
        text = re.sub('[0-9]{4}', '####', text)
        text = re.sub('[0-9]{3}', '###', text)
        text = re.sub('[0-9]{2}', '##', text)
    return text

def removeNumbersFromTexts(text_list):
    clean_texts = []
    for text in text_list:
        clean_texts.append(removeNumbers(text))
    return clean_texts

"""
Realiza el proceso de colocar los textos en una sola linea
"""
def text2OneLineText(text):
    text = text.replace('\n', ' ')
    text = text.replace('\t', ' ')
    text = re.sub(' +', ' ', text)
    return text.strip()

def oneLineTexts(text_list):
    oneLine_texts = []
    for text in text_list:
        oneLine_texts.append(text2OneLineText(text))
    return oneLine_texts

"""
Permite realizar el proceso de stemming de un texto
utilizando nltk
"""
def stemming(text, stemmer):
    stem_text = ''
    tokens = text.split(' ')
    for token in tokens:
        stem_text += stemmer.stem(token) + ' '
    return stem_text.strip()

def stemmingTexts(text_list, stemmer):
    stem_texts = []
    for text in text_list:
        stem_texts.append(stemming(text,stemmer))
    return stem_texts

###################################
#           EVALUACIÓN            #
###################################
def performEvaluation(y_true, y_predicted):
    accuracy = accuracy_score(y_true, y_predicted)
    precision = precision_score(y_true, y_predicted, average='micro')
    recall = recall_score(y_true, y_predicted, average='micro')
    f1 = f1_score(y_true, y_predicted, average='micro')
    return accuracy, precision, recall, f1


