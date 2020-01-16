import pandas as pd
import sys
from sklearn.feature_extraction.text import CountVectorizer
from Tools import *
from sklearn.svm import SVC
from sklearn.preprocessing import LabelEncoder

"""
Función que permite verificar que los argumentos
introducidos en la terminal sean correctos para la
correcta ejecución del  programa
"""
def verify_args(argvs):
    if len(argvs)==5:
        if argvs[2].split('.')[1] == 'csv':
            filename = argvs[2]
        else:
            print("El archivo no está en formato .csv")
            print(argvs[2].split('.'))
            exit()
        if argvs[3].split('.')[1] == 'pkl' and argvs[4].split('.')[1] == 'pkl':
            model_name = argvs[3]
            vectorizer_name = argvs[4]
        else:
            print("Error, los archivos del modelo y vectorizador son incorrectos")
            exit()
    else:
        print("Error en los argumentos")
        exit()
    return filename, model_name, vectorizer_name

"""
Función para obtener los vectores de caracteristicas
de textos para predecir su clase
"""
def get_features(dataframe, vectorizer):
    texts = [text for text in dataframe['texto']]
    texts = normalize_text(texts)
    x = vectorizer.transform(texts)
    return x

#######################################
#       EJECUCIÓN DEL PROGRAMA        #
#######################################
filename, model_name, vectorizer_name = verify_args(sys.argv)
data = get_data(filename)
classifier = load_model(model_name)
vectorizer = load_model(vectorizer_name)
labelEncoder = load_model('labelEncoder.pkl')
x = get_features(data, vectorizer)
y = classifier.predict(x)
y = labelEncoder.inverse_transform(y)
data['area_trab'] = y
data.to_csv(filename,encoding='utf8')

