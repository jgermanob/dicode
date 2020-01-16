import chardet
import pandas as pd
import pickle
from nltk.stem.snowball import SnowballStemmer
from nltk.tokenize import word_tokenize
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
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

