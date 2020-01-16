import pandas as pd
import xlsxwriter
import sys

areas = ['Ventas','Recursos Humanos','Tecnología','Oficios','Administración','Finanzas','Salud','Call center','Legales','Ingeniería','Diseño','Logística','Seguros','Gastronomía','Comunicación','Secretaria','Comercio Exterior','Construcción','Mercadotecnia','Producción','Educación','Gerencia','Minería']

def verify_args(argvs):
    if len(argvs)==4:
        if argvs[2].split('.')[1] == 'csv':
            filename = argvs[2]
        else:
            print("El archivo no está en formato .csv")
            exit()
        if argvs[3] in areas:
            area = argvs[3]
        else:
            print("Error, área no identificada")
            exit()
    else:
        print("Error en los argumentos")
        exit()
    return filename, area



def get_list(df, column_name):
    l = []
    for item in df[column_name]:
        if isinstance(item,str):
            element = item.split('.')
            for e in element:
                if e.strip() not in l:
                    l.append(e.strip())
    return l

def write_requirement(req_list, col, worksheet):
    row = 1
    for req in req_list:
        worksheet.write(row,col,req)
        row += 1

def search_requirements(df,area):
    df_area = df[(df.area == area)]
    columns = ['sexo','salario','edad','horario','competencia/habilidad','capacidad','experiencia','requisitos','funciones']
    # Llenado de listas
    generos = get_list(df_area,'sexo')
    salarios = get_list(df_area,'salario')
    edades = get_list(df_area,'edad')
    horarios = get_list(df_area,'horario')
    competencias = get_list(df_area,'competencia/habilidad')
    capacidades = get_list(df_area,'capacidad')
    experiencias = get_list(df_area,'experiencia')
    requisitos = get_list(df_area,'requisitos')
    funciones = get_list(df_area,'funciones')
    # Escritura de archivo xlsx
    workbook = xlsxwriter.Workbook('categorias_{}.xlsx'.format(area))
    worksheet = workbook.add_worksheet()
    # Escritura de titulos de columnas
    row = 0
    col = 0
    for column in columns:
        worksheet.write(row,col,column)
        col += 1
    #Escritura de contenido de cada columna
    write_requirement(generos,0,worksheet)
    write_requirement(salarios,1,worksheet)
    write_requirement(edades,2,worksheet)
    write_requirement(horarios,3,worksheet)
    write_requirement(competencias,4,worksheet)
    write_requirement(capacidades,5,worksheet)
    write_requirement(experiencias,6,worksheet)
    write_requirement(requisitos,7,worksheet)
    write_requirement(funciones,8,worksheet)
    workbook.close()
    
    return generos,salarios,edades,horarios,competencias,capacidades,experiencias,requisitos,funciones

############################
#  EJECUCIÓN DEL PROGRAMA  #
############################
filename, area = verify_args(sys.argv)
df = pd.read_csv(filename, encoding='utf8')
search_requirements(df, area)