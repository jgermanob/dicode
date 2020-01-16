import pandas as pd

def map_class(old_class, subarea):
    new_class = ''
    if old_class == 'Comercial, Ventas y Negocios':
        new_class = 'Ventas'
    elif old_class == 'Recursos Humanos y Capacitación':
        new_class = 'Recursos Humanos'
    elif old_class == 'Tecnología, Sistemas y Telecomunicaciones':
        new_class = 'Tecnología'
    elif old_class == 'Oficios y Otros':
        new_class = 'Oficios'
    elif old_class == 'Administración, Contabilidad y Finanzas':
        #Verificar subarea
        if subarea == 'Finanzas':
            new_class = 'Finanzas'
        else:
            new_class = 'Administración'
    elif old_class == 'Salud, Medicina y Farmacia':
        new_class = 'Salud'
    elif old_class == 'Atención al Cliente, Call Center y Telemarketing':
        new_class = 'Call Center'
    elif old_class == 'Legales':
        new_class = 'Legales'
    elif old_class == 'Ingenierías':
        new_class = 'Ingeniería'
    elif old_class == 'Diseño':
        new_class = 'Diseño'
    elif old_class == 'Abastecimiento y Logística':
        new_class = 'Logística'
    elif old_class == 'Seguros':
        new_class = 'Seguros'
    elif old_class == 'Gastronomía y Turismo':
        new_class = 'Gastronomía'
    elif old_class == 'Comunicación, Relaciones Institucionales y Públicas':
        new_class = 'Comunicación'
    elif old_class == 'Secretarias y Recepción':
        new_class = 'Secretaria'
    elif old_class == 'Aduana y Comercio Exterior':
        new_class = 'Comercio Exterior'
    elif old_class == 'Ingeniería Civil y Construcción':
        new_class = 'Construcción'
    elif old_class == 'Marketing y Publicidad':
        new_class = 'Mercadotecnia'
    elif old_class == 'Producción y Manufactura':
        new_class = 'Producción'
    elif old_class == 'Educación, Docencia e Investigación':
        new_class = 'Educación'
    elif old_class == 'Gerencia y Dirección General':
        new_class = 'Gerencia'
    elif old_class == 'Enfermería':
        new_class = 'Salud'
    elif old_class == 'Sociología / Trabajo Social':
        new_class = 'Oficios'
    elif old_class == 'Minería, Petróleo y Gas':
        new_class = 'Minería'
    return new_class



dataframe = pd.read_csv('/home/German/Descargas/xample_bumeran.csv', encoding='iso-8859-1')
old_areas = [area for area in dataframe['area_trab']]
subareas = [subarea for subarea in dataframe['subarea_trab']]
new_areas = []
size = len(old_areas)
for index in range(size):
    new_areas.append(map_class(old_areas[index],subareas[index]))

dataframe['area_trab'] = new_areas
dataframe.to_csv('xample_bumeran.csv', encoding='utf8')  