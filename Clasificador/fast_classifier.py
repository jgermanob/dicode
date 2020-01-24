import pandas as pd
import sys
sys.path.append('/home/German/Escritorio/dicode_personal')
from Tools import *
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.svm import LinearSVC
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
from nltk.corpus import stopwords
from nltk.stem.snowball import SnowballStemmer

dataframe = get_data('/home/German/Escritorio/dicode_personal/xample_bumeran.csv')
dataframe = dataframe[(dataframe.area_trab == 'Call Center') | (dataframe.area_trab == 'Administración') | (dataframe.area_trab == 'Tecnología')]
stemmer = SnowballStemmer('spanish')
sws = list(stopwords.words('spanish'))
# Get predictors and targets
texts = [text for text in dataframe['texto']]
#Pre-procesamiento
texts = normalize_text(texts)
texts = text2lowercase(texts)
texts = removeStopwords(texts, sws)
texts = removeAccentsFromText(texts)
texts = removePunctuation(texts)
texts = removeNumbersFromTexts(texts)
texts = stemmingTexts(texts,stemmer)
texts = oneLineTexts(texts)

targets = [target for target in dataframe['area_trab']]


vectorizer = TfidfVectorizer(stop_words=sws)

labelEncoder = LabelEncoder()

x = vectorizer.fit_transform(texts)
y = labelEncoder.fit_transform(targets)

x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.30, random_state=42)

classifier = LinearSVC()
classifier.fit(x_train, y_train)
y_pred = classifier.predict(x_test)

accuracy = accuracy_score(y_test, y_pred)
precision = precision_score(y_test, y_pred, average='macro')
recall = recall_score(y_test, y_pred, average='macro')
f1 = f1_score(y_test, y_pred, average='macro')

print('Accuracy = {}'.format(accuracy))
print('Precision = {}'.format(precision))
print('Recall = {}'.format(recall))
print('F1-score = {}'.format(f1))

