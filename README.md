# Clasificación de ofertas de trabajo

## Dependencias necesarias
Las bibliotecas necesarias para el funcionamiento del sistema son:
* [Pandas](https://pandas.pydata.org/)
* [Sklearn](https://scikit-learn.org/stable/)
* [NumPy](https://numpy.org/)
* [chardet](https://chardet.github.io/)
* [NLTK](https://www.nltk.org/)

## Usos

### Entrenamiento
```
python3 train_classifier.py -i input_data.csv -f fn -o classifier_name.pkl vectorizer_name.pkl
```
Donde:
#### Entrada:
* input_data.csv: archivo de entrada en formato .csv donde se encuentran los textos a clasificar y las etiquetas de cada uno de estos textos.
* f: Indica las características a obtener de los textos. _Para esta versión solo es posible utilizar w, para indicar n-gramas de palabras_.
* n: Indica el valor de los n-gramas a calcular.
#### Salida:
* classifier_name: Indica el nombre del archivo donde se guardará el modelo del clasificador para utilizarse durante la etapa de predicción.
* vectorizer_name: Indica el nombre del archivo donde se guardará el modelo del vectorizador para utilizarse durante la etapa de predicción.

### Predicción
```
python3 test_classifier.py -i data.csv classifier.pkl vectorizer.pkl
```
Donde:
#### Entrada:
* data.csv: Archivo que contiene el texto para realizar predicciones sobre él.
* classifier.pkl: Archivo que contiene el modelo del clasificador obtenido durante el entrenamiento y que permitrá la predicción de los textos nuevos.
* vectorizer.pkl: Archivo que contiene el modelo del vectorizador obtenido durante el entrenamiento y que permitrá la predicción de los textos nuevos.
#### Salida:
* La salida del proceso de predicción será el mismo archivo data.csv, con la adición de la nueva columna donde se indica la clase de cada uno de los textos.
