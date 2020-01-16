import pandas as pd
from Tools import *
import xlsxwriter
import sys
import re
import spacy

def verify_args(argvs):
    if len(argvs)== 3:
        if argvs[2].split('.')[1] == 'csv':
            input_file = argvs[2]
        else:
            print("El archivo no está en formato .csv")
            exit()
    else:
        print("Error en los argumentos")
        exit()
    return input_file, output_file

def reduce_requirements(requirements_list):
    final_req_list = []
    for requirement in requirements_list:
        if requirement not in final_req_list:
            final_req_list.append(requirement)
    return final_req_list

def search_requirements(text, requirements):
    text = text.lower()
    text = removeAccents(text)
    req_list = list()
    for requirement in requirements:
        size = len(re.findall(r'\b{}\b'.format(requirement),text))
        if size > 0:
            req_list.append(requirement)
    reqs = ''
    for req in req_list:
        reqs += req + '. '
    reqs = reqs.strip()
    limit = len(reqs)-1
    return reqs[0:limit]

# Lectura del archivo .xlsx que contiene los requerimientos a buscar en el texto libre
columns = ['COMPETENCIA/HABILIDAD', 'CAPACIDAD', 'EXPERIENCIA', 'REQUISITOS','FUNCIONES']
data = pd.read_excel('Diccionarios.xlsx', sheet_name='Buena', usecols=columns)

# Almacenamiento de los requerimientos en listas
competencias = [competencia for competencia in data[columns[0]] if isinstance(competencia,str)]
capacidades = [capacidad for capacidad in data[columns[1]] if isinstance(capacidad,str)]
experiencias = [experiencia for experiencia in data[columns[2]] if isinstance(experiencia,str)]
requisitos = [requisito for requisito in data[columns[3]] if isinstance(requisito,str)]
funciones = [funcion for funcion in data[columns[4]] if isinstance(funcion,str)]

# Pre-procesamiento de los requerimientos para reducir la variabilidad
competencias = text2lowercase(competencias)
capacidades = text2lowercase(capacidades)
experiencias = text2lowercase(experiencias)
requisitos = text2lowercase(requisitos)
funciones = text2lowercase(funciones)

competencias = removeAccentsFromText(competencias)
capacidades = removeAccentsFromText(capacidades)
experiencias = removeAccentsFromText(experiencias)
requisitos = removeAccentsFromText(requisitos)
funciones = removeAccentsFromText(funciones)

competencias = reduce_requirements(competencias)
capacidades = reduce_requirements(capacidades)
experiencias = reduce_requirements(experiencias)
requisitos = reduce_requirements(requisitos)
funciones = reduce_requirements(funciones)

##################################################
#             EJECUCIÓN DEL PROGRAMA             #
##################################################

# Verificación de argumentos
input_file, output_file = verify_args(sys.argv)

#Lectura del archivo de entrada que contiene el texto libre de las ofertas de trabajo
data = pd.read_csv(input_file, encoding='utf8')
texts = [text for text in data['texto']]
texts = normalize_text(texts)

#Listas para almacenar los requerimientos de cada oferta de trabajo
comp_list = [search_requirements(text,competencias) for text in texts]
cap_list = [search_requirements(text,capacidades) for text in texts]
exp_list = [search_requirements(text,experiencias) for text in texts]
req_list = [search_requirements(text,requisitos) for text in texts]
func_list = [search_requirements(text,funciones) for text in texts]



# Escritura de las nuevas columnas en el dataframe
data[columns[0].lower()] = comp_list
data[columns[1].lower()] = cap_list
data[columns[2].lower()] = exp_list
data[columns[3].lower()] = req_list
data[columns[4].lower()] = func_list

data.to_csv(input_file, encoding='utf8', index=False)


