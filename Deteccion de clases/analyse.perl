#--------------------------- analyse.perl-------------------------------------
#    Analyse et extraction des données a partir des fichiers csv 
#    Copyright (C) 2019 Juan-Manuel Torres Moreno
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Contact: juan_manuel_torres@yahoo.com
#-------------------------------------------------------------------------
# Analyse de xample.preproc
# V0.011 28.11.2019
# V0.250 07.12.2019
# (C) 2019 Juan-Manuel Torres-Moreno
# entrée: fichier preprocesado por preproc.perl : fichier.preproc
# sortie: standard o > fichier.analyse
#-------------------------------------------------------------------------
# CAMPOS SALIDA
# 0	2		4		6		7		10	14	15	16	17		18	ENTRADA
# ID	empresa	categoria	salario	dedicacion	texto	beca	cdi	otro	comision	cdd	
# 0	1		2		3		4		5	6	7	8	9		10	SALIDA
#-------------------------------------------------------------------------
 use strict;

 my %offre=();			# Offres
 my %dedica=();			# Dededaction TC/MT
 my %salario=();			# Salario
 while(my $l=<>){ 			# Chaque ligne
	chomp $l; 			# elimine \n
	next if $l=~/^\s*$/;		# Lignes vides
	my @t=split/\t/,$l;		# Separation por \t
	
	my $id=$t[0];						# Identificateur unique
	$t[3] = "" if $t[3] =~ /No especificado/i;	# Salario no especificado 
	$salario{$id} = $t[3];				# creation tableau d'offres - salario
	$salario{$id}=normalise($salario{$id});		
	 $dedica{$id} = $t[4];				# creation tableau d'offres - dedicacation
	 $dedica{$id} = "" if $dedica{$id} == $salario{$id} ;	# Evitar dobles
	 
#	 $salario{$id} =~s/,//g; 
	 $salario{$id} =~s/\-/A/g; $salario{$id} =~s/AL MES/MENSUAL/ig; 
	 
	  $offre{$id} = $t[1]." ".$t[5];			# creation tableau d'offres - empresa + texte
	  $offre{$id} .= " ".$t[2] if ($offre{$id}=~/^\s*$/) ;	# offre vide: replit sur categoria (2)
 }

 print "#ID\tSEXO\t\tSALARIO\tEDAD\t\tHORARIO\t\tHORARIO_2\t\tDEDICACION\t\tTEXTO\n"; print "#"; print "-"x100; print "\n";
 my $sexo="INDISTINTO"; my $sueldo="BASE"; my $horario="AMPLIO"; my $age="INDISTINTA";	# Champs a extraire

 foreach my $key (sort {$a<=>$b} keys %offre){					# Boucle pour traiter chaque offre
	next if $key=~/^\s*$/;							# ID vide
	my $contenu=$offre{$key};							# Contenu = offre par key
	next if $contenu=~/^\s*$/;							# Contenu Vide
	next if $contenu=~/^\s(na|resumen|Bumeran)\s*$/i;			# Contenu vide
	next if $contenu=~/Nuestra Misión y Valores\/Our Mission \& Values/i; # Contenu vide

	$contenu=normalise($contenu);		# Normalisation du contenu: salaires, dates, espaces, etc 
	if ($contenu=~/^\s*$/) { $contenu = "__OFERTA__INEXISTENTE__"}
	else {
		$horario=dispo($contenu);		# Extrae disponibilidad 
		$sexo=sex($contenu);			# Extrae sexo 	
		$sueldo=ingreso($contenu);		# Extrae salario 
		$age=edad($contenu);			# Extrae edad 
	}		
#------------------------------------------- SORTIE
# 	champs separes par \t:  id   sexe   salaire   age   horaire	texte
	if ($sueldo !~ /\$/i and $salario{$key} =~/\$/) {$sueldo=$salario{$key}; $salario{$key}=""}	# Campo sueldo = base y el salario tienen un $ valor
	print $key,"\t",uc $sexo,"\t",uc $sueldo,"\t",uc $age,"\t",uc $horario,"\t",uc $dedica{$key},"\t",uc $salario{$key},"\t",$contenu,"\n";	# Registre
#	print $key,"\t",$contenu,"\n"; print "SEXO     :\t",uc $sexo,"\n"; print "SALARIO  :\t",uc $sueldo,"\n";	print "EDAD     :\t",uc $age,"\n";  print "HORARIO  :\t",uc $horario,"\n"; print "DEDICACION\t<",$dedica{$key},"\n";	print "SALARIO   \t<",$salario{$key},"\n\n";
 } # Fin de boucle d'offres

exit(0);
#------------------------ SUBS

# ----------------------------
# Normalise le contenu
# ----------------------------
sub normalise{	
my ($contenu)=@_;
	$contenu=~s/Ø/ /g;							# PREPROC
	$contenu=~s/ü/ /g;							# PREPROC
	$contenu=~s/<U\+\w\w\s*\w\w>/ /g;					# PREPROC Hexadecimal	U+2605

	$contenu=~s/100\s*\%/ @ 100% /gi;					# 12345100% -> 12345 100%	Porcentajes
	$contenu=~s/(\d)([a-z])/$1 $2/ig;					# Nettoyage: Séparer digit suivi d'une lettre
	$contenu=~s/\s*(a|p)[\.:]\s*m[\s;\.]/ $1m /ig;			# horaires am pm a.m p.m.	
	$contenu=~s/(\d+)[\.:]\s*(\d+)\s*(a|p)m/ $1:$2 $3m /ig;		# 8.30 am	2: 00 pm
	$contenu=~s/(\d+)[\.:](a|p)m/ $1:00 $2m /ig;			# 12.pm
	$contenu=~s/ (\d+)\s*(a|p)m/ $1:00 $2m /ig;			# horaires  8 am		
	$contenu=~s/\s*(\d+):\s*(\d+)[\s\.\-;\,]/ $1:$2 /ig;		# horaires  2: 00 ->  2:00 	8: 30 22: 00,
	$contenu=~s/\s*(\d+)(a|p)m/ $1:00 $2 /ig;				# horaires  2am ->  2:00 am	
	$contenu=~s/\s*(\d){1-2}\.(\d+)/ $1:$2 /ig;			# horaires  7.00


	$contenu=~s/\$\s*(\d+)\.(\d+),00 / \$$1$2 /gi;			# $ 5.500,00


	$contenu=~s/\$\s*(\d+),(\d+)\.(\d+)/ \$$1$2 /gi;			# salario sin comas sin espacios sin centavos
	$contenu=~s/\$\s*(\d+)\s*,\s*(\d+)/ \$$1$2 /gi;			# $11 , 000   
	$contenu=~s/\$\s*(\d+)\s*\.\s*(\d+)/ \$$1 /gi;			# $4500 .00 	 $30000 . 00
	$contenu=~s/\$\s*(\d+)\s/ \$$1 /gi;				# salario sin comas sin espacios sin centavos
	$contenu=~s/\$\s*(\d+)\s*,\s*(\d+)\.00/ \$$1$2 /gi;		# $ 4,250.00	
	$contenu=~s/\$\s*(\d+)\s*,\s*(\d+)/ \$$1$2 /gi;			# $20 , 000
	$contenu=~s/\s*(\d+),(\d+)/ \$$1$2 /gi;				# salario sin comas sin espacios sin centavos
	$contenu=~s/\$\s*(\d+)\.(\d+)/ \$$1 /gi;				# $ 6000.00	
	$contenu=~s/\$*\s*(\d+)\s*(mil)/ \$$1 000 /gi;			# $ 16 mil		
	$contenu=~s/\$(\d+)\.(\d+)/ \$$1 /gi;				# $6500.00
	$contenu=~s/\$\s*(\d+)\s*(\d+)/ \$$1$2 /gi;			# $ 16 00
	$contenu=~s/·/ /gi;							# elimina -	
	$contenu=~s/ - / /gi;						# elimina -
	$contenu=~s/ : / /gi;						# elimina :	# $contenu=~s/[¡!]/ /gi;    # elimina ! causa problema utf8
	$contenu=~s/[;<>\(\)]/ /gi;						# elimina ; >	( )	
	$contenu=~s/ SAB / sabado /gi;					# SAB	
	$contenu=~s/ L V / lunes a viernes /gi;				# L V 		
	$contenu=~s/ S D / sabado a domingo /gi;				# S D 			
	$contenu=~s/ L\s*\-\s*V / lunes a viernes /gi;			# L-V 	 L- V 
	$contenu=~s/ L\s*\-\s*J / lunes a jueves /gi;			# L-J 	 L- J 		
	$contenu=~s/ L(un)* a V(ie)* / lunes a viernes /gi;		# L a V 	
	$contenu=~s/ L\s+a\s+S / lunes a sabado /gi;			# L a S
	$contenu=~s/ L\s*\-\s*S / lunes a sabado /gi;			# L-S	 	
	$contenu=~s/ L\s+a*\s+D / lunes a domingo /gi;			# L a D
	$contenu=~s/Vienes de /Viernes de /gi;				# Viernes
	$contenu=~s/ V / viernes /gi;					# V	

	$contenu=~s/\s+/ /g;							# Nettoyage: espaces
	return $contenu
}

#--------------------------------------------- AGE
sub edad{
my ($cont) = @_;
	my $age="indistinta";					# Défaut
	my $anios='(años|AÑOS)';    				# a incluye $1
	my $dd='\d\d';						# Edad de  al menos 2 digitos
	my $mayor='(arriba|MAYORIA|mayor|Mayores|mas|más|\+)';	# incluye $1
	my $a='( a | hasta | *\- *| y )*';				# incluye $1
	my $entre='(entre:* )';					# incluye $1	
	my $de='(de *:* |de *;* |de los *:* )*';			# incluye $1	
	my $hasta='(hasta *:* |hasta los *:* )*';			# incluye $1
	my $min_max='(Mínimo *:* |Máximo *:* |Minimo *:* |Maximo *:* )';	# incluye $1			
	my $en_adelante='(adelante|en adelante|o mas|o más|a partir )';	# incluye $1	
	my $sugerida='(sugerida *:* *|solicitada *:* *)';	# incluye $1			
	my $edad='Edad *:* *';					# Edad

	if    ($cont =~ /$edad($dd) $anios*$a($dd) $anios/i)		{ $age="$1 a $4" } 		# EDAD: 20 A 35 AÑOS | Edad: 25 45 años| Edad: 20 años hasta 26 años
	elsif ($cont =~ /$edad$entre ($dd)$a($dd) $anios/i) 		{ $age="$2 a $4" } 		# EDAD ENTRE 22 Y 30 AÑOS | Edad: entre 18 y 45 años		
	elsif ($cont =~ /$edad$de($dd)$a($dd) $anios*/i) 		{ $age="$2 a $4" }	      # EDAD: DE 25 A 35 AÑOS | 25 a; 40 años | Edad de 23- 55 | Edad: 25- 45 años
	elsif ($cont =~ /$de($dd)$a($dd) $anios/i) 			{ $age="$2 a $4" } 		# de 18 a 45 	
	elsif ($cont =~ /$edad$mayor $de($dd) $anios/i) 			{ $age="mayor de $3" } 	# edad: mayor de : 26 años | Edad: + 25 años	
	elsif ($cont =~ /$edad$de($dd) $anios* *$en_adelante/i)		{ $age="mayor de $3" }   # Edad: De 22; años en adelante | De 25 años en adelante | Edad 20 en adelante
	elsif ($cont =~ /$edad$de($dd) $anios*$a($dd) $anios/i) 	{ $age="$3 a $6" }		# EDAD 30 AÑOS 45 AÑOS
	elsif ($cont =~ /($dd) $anios $en_adelante/gi) 			{ $age="mayor de $1" } 	# 18 años en adelante
	elsif ($cont =~ /($dd)$a($dd) $anios $de$edad/i) 		{ $age="$1 a $3" } 		#  20 A 35 AÑOS de edad 		
	elsif ($cont =~ /$edad(indistinta|indiferente)/i)		{ $age="indistinta" }	# Indiferente
	elsif ($cont =~ /$edad$en_adelante$de($dd) $anios/i) 		{ $age="mayor de $3" } 	# Edad a partir de los 18 años
	elsif ($cont =~ /$edad$hasta($dd) $anios/i) 			{ $age="$1 $2" } 		# Edad hasta los 28 años	
	elsif ($cont =~ /$en_adelante$de($dd) $hasta($dd) $anios/i)	{ $age="$2 a $4" } 		# A partir de 18 hasta 56 años
	elsif ($cont =~ /$en_adelante$de($dd) $anios/i) 			{ $age="mayor de $3" } 	# A partir de 18 años		
	elsif ($cont =~ /$edad$sugerida ($dd)$a($dd) $anios/i) 		{ $age="$2 a $4" }
	elsif ($cont =~ /Jóvenes $de($dd)$a($dd)/i)			{ $age="$2 a $4" }
	elsif ($cont =~ /$edad$min_max($dd) $min_max($dd)/i)		{ $age="$2 a $3" }
	elsif ($cont =~ /$mayor $de($dd) $anios* *$a($dd)* *$anios* $de$edad/i) { $age="$3 a $6" } # más de 18 a 45 años de edad
	elsif ($cont =~ /$mayor $de($dd) $anios* *$a($dd)* *$anios*/i) { $age="$3 a $6" } 		# mas DE 25 A 35 AÑOS | mas 25 a; 40 años			
	elsif ($cont =~ /$mayor $de$edad/i) 				{ $age="mayor de 18" } 	# Mayor de edad
	elsif ($cont =~ /$hasta($dd) $anios/i) 				{ $age="hasta $2" } 		# hasta 24 años		
	elsif ($cont =~ /$entre ($dd)$a($dd) $anios/i) 			{ $age="$1 a $3" } 		# entre 25 y 40 años | entre 18- 28 años
	elsif ($cont =~ /($dd)$a($dd) $anios/i) 				{ $age="$1 a $3" } 		# 18 a 45 años | 30- 40 AÑOS | 18 55 años
	elsif ($cont =~ /($dd) $anios $de$edad/i) 			{ $age=$1 } 			# 17 años de edad
	elsif ($cont =~ /$edad($dd) $mayor/i) 				{ $age="mayor de $1" }	# Edad: 25+	
	elsif ($cont =~ /joven/i) 						{ $age="joven";  } 		# joven	

	if ($age=~/\s*(\d+)\s*/){		
		my $edad_real=$1; $edad_real =~s/\s+//g;
		$age = "indistinta" if ($edad_real<17 or $edad_real >85);	# verifica edades ilogicas <17 >85
		$age = "indistinta" if ($cont=~/$edad_real $anios de ex/);	# verifica anios de ex periencia|ito
	}
	if ($age!~/$anios/ and $age=~/$dd/) {$age .= " AÑOS"}; 			# Ajouter "AÑOS" si es numerico
	$age=~s/ +/ /g;								# Normaliser espaces
	return $age;
}

#--------------------------------------------- SEXE
# Extraire le sexe
# ----------------------------
sub sex{
my ($cont)=@_;
	my $genero="indistinto";								# Défaut
	my $sexe="(sexo|Géneros*|Generos*)[:;]* *";					# ya contine $1
	my $preferente='(preferente|preferentemente|unicamente|únicamente)*:* *';	# ya contine $1
	my $solicita='(solicita|necesita)*:* *';						# ya contine $1

	   if ($cont =~ /$sexe$preferente(Indistinto|indefinido|HOMBRES . MUJERES|Hombres, Mujeres|masculino . femenino|ambos sexos)s*/i) { $genero="indistinto" }
	elsif ($cont =~ /$sexe$preferente(masculino|hombre|chico)(s)*/i) 	{ $genero="$2 masculino" } # Sexo: masculino
	elsif ($cont =~ /$sexe$preferente(femenino|mujer|chica)(s|es)*/i) 	{ $genero="$2 femenino" }  # Sexo: femenino		
	elsif ($cont =~ /$solicita(becaria|empleada|Ejecutiva|mujer)(s|es)*/i){ $genero="femenino" }
	elsif ($cont =~ /$solicita(Varon|Varón|hombre)(s|es)*/i)       	{ $genero="masculino" }
	elsif ($cont =~ /$sexe y estado civil[: ]*(\w+)[\.; ]/i)	   	{ $genero=$1 }		

	$genero=~s/ +/ /g;	# Normaliser les espaces
	return $genero;
}

#--------------------------------------------- DISPONIBILITE	
sub dispo{
	my ($cont)=@_;
	my $VSD='jueves|viernes|sabado|SÁBADOs*|Sábados*|domingos*';
	my $S='sabado|SÁBADO|sábado|sábado . domingo';
	my $LM='Domingo|L|lunes|martes|MIÉRCOLES|miércoles';
	my $LJ='Lunes a Jueves';	
	my $semana='Lunes|martes|MIÉRCOLES|miércoles|Jueves|viernes|sabados*|SÁBADO*|Sábado*|domingo*';	# La semana!
	my $horas='\d+:\d+';										# REGEXP pour determiner une heure 20:00
	my $h='\d+';											# REGEXP pour determiner une heure 2	
	my $am='[ap]m|hrs|h||horas';								# am pm hrs
	my $tipo='Medio tiempo|Tiempo completo|jornada completa|Full[ \-]*time';		# tipo de puesto
	my $mat='matutino';	my $ves='vespertino';						# Matutino | Vespertino
	my $horario_de='Horarios* *[:\.]* *(de |de las |a elegir |disponibles* )*';				# Ya tiene $1 incluido
	my $horario_de_trabajo='Horarios* del* (Trabajo|Puesto|labores):* (de |de las )*';	# Ya tiene $2 incluidos !!!
	my $a='(a |a las|to |para )*';								# Ya tiene $1 incluido
	my $de='(de:* |d |from |de las )*';							# Ya tiene $1 incluido
	my $dispo="";		# Défaut

	if    ($cont =~ /$horario_de_trabajo($LM) $a($VSD) $de($horas|\d+)* *($am)* *$a($horas|\d+)* *($am)*/i){ $dispo="$3 $4 $5 $6 $7 $8 $9 $10 $11"; } # Horario de trabajo: lunes a viernes de 8:00 17:30  | Horario de Trabajo de Lunes a Viernes de 9:00 am a 6:00 pm | Horario de trabajo: Lunes a viernes 9:00 a 19:00
	elsif ($cont =~ /$horario_de_trabajo($horas|\d+) ($am)* *$a($horas|\d+) ($am)* *$de($LM)* *$a($VSD)*/i){ $dispo="$3 $4 $5 $6 $7 $8 $9 $10 $11" } # horario de trabajo de las 08:00 a las 17:00 hrs de lunes a viernes
	elsif ($cont =~ /Horarios* solicitado.* $de($LM) $a($VSD) $de($horas) ($am) $a($horas) ($am)/i) { $dispo="$2 a $4 $6 $7 a $9 $10" }
	elsif ($cont =~ /Horarios* (a|para) laborar:* $de($LM) $a($VSD) $de($horas|\d+)* *($am)* *$a($horas)* *($am)*/i) { $dispo=" $3 a $5 $7 $8 a $10 $11" } # Horario a laborar: lunes a viernes 08:00 am a 06:3 0 pm | Horario para laborar: Lunes a viernes de 10 a 18:00 | horario para laborar de lunes a domingo
	elsif ($cont =~ /Horarios* (Nocturno|vespertino)s* *$de($LM) $a($VSD) $de($horas) ($am) $a($horas) ($am)/i) { $dispo="$1 $3 a $5 $7 $8 a $10 $11" }
	elsif ($cont =~ /Horarios* (Nocturno|vespertino)s* *$de($LM) $a($VSD)/i) 		{ $dispo="$1 $3 a $5" }	# Horario: martes a domingo
	elsif ($cont =~ /$horario_de($LM) a ($VSD) $de($horas) ($am) $a($horas) ($am)/gi)   { $dispo="$2 a $3 $5 $6 a $8 $9"; } # HORARIO: Lunes a Viernes 8:00 am 6:00 pm
	elsif ($cont =~ /$horario_de($LM) a ($VSD) $de($horas|\d+) $a($horas) ($am)*/gi)	{ $dispo="$2 a $3 a $5 a $7 $8"; } # Horario: de lunes a viernes de 9 a 7 pm |  Horario. Lunes a viernes de 9:00 a 3:00 pm | Horario Lunes a Viernes 8 a 5:00 pm
	elsif ($cont =~ /$horario_de($LM) a ($S):* ($horas) ($am) $a($horas) ($am)/gi)	{ $dispo="$2 a $3 de $4 $5 a $7 $8" } # Horario: L a S: 11:00 am a 7:00 pm
	elsif ($cont =~ /$horario_de($horas) $a($horas) ($am) $de($LM) $a($VSD)/i) { $dispo="$2 $3 $4 $5 $7 $8 $9" } # Horario disponible 8:00 a 14:00 horas de lunes a sábado
	elsif ($cont =~ /$horario_de($horas) ($am)* *$a($horas) ($am)* *$de($horas)* ($am)* *$a($horas)* *($am)*/i) { $dispo="$2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12" } #Horarios a elegir 09:00 a 15:00 hrs 15:00 a 21:00 hrs
	elsif ($cont =~ /$horario_de($horas) $a($horas) ($am) $de($LM) $a($VSD)/i)      	{ $dispo="$2 $3 $4 $5 $7 $8 $9" } #horario de las 06:30 a las 14:30 horas de lunes a viernes
	elsif ($cont =~ /$horario_de($horas) ($am)* *$a($horas) ($am) $de($LM) $a($VSD)/i) 	{ $dispo="$2 $3 $4 $5 $6 $8 a $10" } # Horario de 3:00 pm a 8:00 pm de lunes a viernes | # HORARIO: 9:00 am 5:00 pm Lunes a Viernes  OK
	elsif ($cont =~ /$horario_de($horas) $a($horas) $de($LM) $a($VSD)/i) 			{ $dispo="$2 a $4 de $6 a $8" } # Horario 9:00 a 18:00 L a V
	elsif ($cont =~ /$horario_de($horas) ($am) $a($horas) ($am)/gi)			{ $dispo="$2 $3 a $5 $6" }  # Horario 9:00 am a 18:00 pm
	elsif ($cont =~ /$horario_de($horas|\d+) $a($horas|\d+) $de($LJ)*/i) 			{ $dispo="$2 $3 $4 $6" } # horario de: 14:00 24:00 HRS | Horario: 11 a 7
	elsif ($cont =~ /(Horario|Turno|Días Laborales|Tiempo)s* *:* *$de($LM) $a($VSD)/gi)	{ $dispo="$3 $4 $5" } # Horario: de Lunes a Viernes | Horario de lunes a viernes
	elsif ($cont =~ /(Horario|Turno)s* *:* *$de($horas|\d+) ($am) $a($horas)* *($am)*/i){ $dispo="$3 $4 $5 $6 $7" } #TURNOS: De 10:00 Am 4:00 Pm
	elsif ($cont =~ /Trabaja solo $de($LJ) $de($horas|\d+) ($am)* *$a($horas|\d+) ($am)*/gi) { $dispo="$2 $3 $4 $5 $6 $7 $8" } # Trabaja solo de Lunes a Jueves 9 a 7
	elsif ($cont =~ /$horario_de($LJ) $de($horas) ($am)* *$a($horas) ($am)*/gi) 		{ $dispo="$2 $3 $4 $5 $6 $7 $8" } # Horario: Lunes a Jueves de 09:00 Am a 06:00 Pm | Lunes a jueves 8:30 5:30
	elsif ($cont =~ /$horario_de($LM) $a($VSD) ($tipo)/i) 					{ $dispo="$2 $3 $4 $5" } # Horario de lunes a viernes jornada completa 
	elsif ($cont =~ /Horarios (accesibles):* *$de($LM) $a($VSD)/gi)			{ $dispo="$3 $4 $5 $1" } # Horarios accesibles Lunes a Viernes
	elsif ($cont =~ /($LM) $a($VSD) $de($horas) ($am)* *$a($horas) ($am)*/gi)		{ $dispo="$1 $2 $3 $4 $5 $6 $7 $8 $9" }  # from 8:00 am to 5:00 pm | lunes a Domingo de 10:00 am a 10:00 pm
	elsif ($cont =~ /$horario_de($tipo) (\d+) ($h) $de($LM) $a($VSD)/gi)     	     { $dispo="$2 $3 h $6 $7 $8" } # Horario: medio tiempo (6 horas) de lunes a viernes
	elsif ($cont =~ /($tipo)[,:]* $de($LM) $a($VSD)/gi) 					{ $dispo="$1 $3 $4 $5 $6" } # Medio Tiempo, Lunes a Viernes
	elsif ($cont =~ /($tipo)[,:]* $de($horas) ($am)* $a($horas) ($am)/gi) 		{ $dispo="$1 $3 $4 $5 $6 $7" } # Medio tiempo 12:00 Pm a 6:00 Pm	
	elsif ($cont =~ /($LM) $a($VSD) ($tipo)/i) 						{ $dispo="$1 $2 $3 $4" } # LUNES A VIERNES MEDIO TIEMPO
	elsif ($cont =~ /($LM) $a($VSD) $de($horas) ($am)* *$a($horas) ($am)*/i)		{ $dispo="$1 $2 $3 $4" } # Lunes a Jueves 10:00 a 19:00 hrs
	elsif ($cont =~ / (\d+) ($h)* *:* *$de($LM) $a($VSD)/gi)				{ $dispo="$1 h $4 $5 $6" } # 4 horas de Lunes a Viernes
	elsif ($cont =~ /Laborar*:* $de($LM) $a($VSD)/i) 					{ $dispo="$2 $3 $4" } # labora de Lunes a Domingo	

# --------------------- HORARIOS QUE SE AGREGAN SI NO HAY DIAS DE SEMANA
	if ($dispo !~/$semana/i) {						# replit si vide	NECESARIO?
		if ($cont =~ /(TIEMPO|HORARIOS*|Laborar)* *:* *$de($LM) $a($VSD)/gi) 		{ $dispo.=" [$3 $4 $5]" } # HORARIOS: Lunes a Domingo
	}
# --------------------- HORARIOS QUE SE AGREGAN
	if ($cont =~ /($mat):* *$de($LM)* *$a($VSD)* *$de($horas) ($am)* *$a($horas) ($am)*/gi) { $dispo.=" [$1 $3 $5 $6 $7 $8 $9 $10 $11]" } # MATUTINO de 9:00 am a 2:30 pm 
#Turno VESPERTINO: 12.pm a 6:00 pm
	if ($cont =~ /($ves):* *$de($LM)* *$a($VSD)* *$de($horas) ($am)* *$a($horas) ($am)*/gi) { $dispo.=" [$1 $3 $5 $6 $7 $8 $9 $10 $11]" } # VESPERTINO 2:30 pm a 8:00 pm
	if ($cont =~ /($horas) ($am)* *$a($horas) ($am)* *\(($mat|$ves)\)/gi) 		{ $dispo.=" [$1 $2 $3 $4 $5 $6]" } # 09:00 Am A 14:30 HRS (MATUTINO)
	if ($cont =~ /($horas) ($am)* *$a($horas) ($am)* *\(($mat|$ves)\)/gi) 	{ $dispo.=" [$1 $2 $3 $4 $5 $6]" } # 09:00 Am A 14:30 HRS (VESPERTINO)		
	# ------------- Ajouter a la dispo actuelle
	if ($cont =~ /(Jornada|Horario) laboral:* $de($LM) $a($VSD) $de($horas)* *($am)* *$a($horas)* *($am)*/i) { $dispo.=" [$3 $4 $5 $6 $7 $8 $9 $10 $11" } # Jornada Laboral:- De lunes a vienes de 9:00 am a 18:00 | Jornada Laboral: lunes a viernes 9:00 am a 6:00 pm | Jornada laboral de lunes a sabado	
	if ($cont =~ /(Jornada|Horario) laboral:* $de(\d+) ($am) (diarias)/i) 		{ $dispo.=" [$3 $4 $5" } # Jornada Laboral: De 7 h diarias
	if ($cont =~ /Horarios (verspertinos|nocturnos) ($horas) ($am) $a($horas) ($am)/gi) { $dispo.=" [$1 $2 $3 $4 $5 $6]" } # horarios vespertinos 2:00 pm a 11:00 pm 
	if ($cont =~ /(Tipo de puesto|Job type):* ($tipo),* *($tipo)*/gi) 			{ $dispo.=" [$2 $3]" } # Tipo de puesto: Tiempo completo, Medio tiempo
	if ($cont =~ /(Horario|Turno)s* *:* $de($tipo) (a elegir)*/gi) 			{ $dispo.=" [$3 $4]" }	# Horarios a elegir
	if ($cont =~ /(Contratación|Contratacion) $de($tipo)/gi) 				{ $dispo.=" [$3]" }	# Contratación de tiempo completo
	if ($cont =~ /(Horario|Turno)s* *:* (amigable|abierto|$mat . $ves|$mat. $ves|$mat|$ves|Nocturno|FIJO|flexible|Disponibilidad|Amplia disponibilidad|de Trabajo comercial)s*/i) 		 									{ $dispo.=" [$2]" } # Horario Matutino, Vespertino
	if ($cont =~ / ($S) $de($horas|\d+) $a($horas|\d+)/gi) 					{ $dispo.=" [$1 de $3 a $5]" } # S 9:00 14:00 OK
	if ($cont =~ /y* (los )*($S)s* $de($horas|\d+) ($am)* *$a($horas|\d+) ($am)*/gi) 	{ $dispo.=" [$2 de $4 $5 a $7 $8]" } # Sábado 8:30 am a 3:00 OK
	if ($cont =~ /y* (los )*($S)s* (medio día|medio dia|$tipo)/gi) 			{ $dispo.=" [$2 $3]" } # Sábados medio día		
	if ($cont =~ /y (viernes) $de($horas|\d+) ($am)* *$a($horas|\d+) ($am)*/gi)		{ $dispo.=" [$1 de $3 $4 a $6 $7]" } # y Viernes de 08:00 Am a 05:00 Pm 
	if ($cont =~ /(AMPLIA DISPONIBILIDAD|DISPONIBILIDAD ABSOLUTA|DISPONIBILIDAD|DISPÓNIBILIDAD TOTAL|FLEXIBILIDAD) (PARA|DE) (HORARIO|TIEMPO|EL TURNO|LABORAR)/i) 														{ $dispo.=" [$1]" } # FLEXIBILIDAD DE HORARIO
	if ($cont =~ /($tipo) . ($tipo)/gi) 							{ $dispo.=" [$1 $2]" } # Medio tiempo o tiempo completo
	if ($cont =~ /($mat).*(y|o)* ($ves)/gi) 							{ $dispo.=" [$1 $2 $3]" } # Matutino, Vespertino
	if ($cont =~ /(ratos libres|ro.ar turno|turnos ro.ados)/i) 				{ $dispo.=" [$1]" }				
	if ($dispo eq "" ) {						# replit si vide	
		if ($cont =~ /(TIEMPO|HORARIOS|Laborar)* *:* *$de($LM) $a($VSD)/gi) 		{ $dispo.=" [$3 $4 $5]" } # HORARIOS: Lunes a Domingo
	}
	$dispo=~s/^\s*//; $dispo="AMPLIO" if $dispo eq "";	# Default
	$dispo=~s/ +/ /g;	# Normaliser les espaces
	return $dispo;
}

#--------------------------------------------- SALARIO
sub ingreso{
	my ($cont) = @_;
	my $sueldo ="";	# Défaut
	my $pesos  ='\$\d+';	# REGEXP pour deterliner salaire
	my $a      ='(a |to |y |hasta |o )*';										# Ya tiene $1 incluido
	my $slash  ='(\-|\/|;)* *';												# Ya tiene $1 incluido	
	my $de     ='(de:* |desde |entre |de los )*';									# Ya tiene $1 incluido	
	my $bono   ='(bonos*)';												# Ya tiene $1 incluido
	my $salario='(salario|sueldo|Salary|Pago|Ingresos*|beca|Oferta laboral|Apoyo econ.mico|Condiciones retributivas):*';	# Ya tiene $1 incluido
	my $mensual='(mensual|mensuales|mes|por mes|por semana|semanal*|semanales|quincenal*|month|hora)';	# Ya tiene $1 incluido
	my $base     ='(base|inicial|libres*|netos*|brutos*|fijo)';							# Ya tiene $1
	my $comision ='(comisi.n|comisión|comisiones|Variables*|incentivos*)';					# Ya tiene $1
	my $mas      ='(superiores|superior|mas|\+|mayor|arriba)';							# Ya tiene $1	
	my $ofrecemos='(Ofrecemos|Beneficios*):*';											

	if    ($cont =~ /$salario $base*:* * ($pesos) $mensual/i) 			{ $sueldo="$3 $4"; }	
	elsif ($cont =~ /$de($pesos) $a($pesos) (USD|MXN) $mensual*/gi)		{ $sueldo="$2 a $4 $5 $6"; }
	elsif ($cont =~ /$salario ($pesos) $a($pesos) $slash$mensual*/gi)		{ $sueldo="$2 a $4 $6"; } # inglés				
	elsif ($cont =~ /$salario ($pesos) $slash$mensual*/i)				{ $sueldo="$2 $4"; } # Salary: $10000 /month | Salario: $6000 / mensual | Sueldo: $11000 mensuales	
	elsif ($cont =~ /$salario $de($pesos) $a($pesos) $slash$mensual*/i)		{ $sueldo="$3 $4 $5 $7" }  # Salario: $30 a $37 /hora | Salario: $6000 a $7000 mes | Sueldo: Entre $25000.00 y $30000.00 | Salario: $7020 a $7021 /mes 
	elsif ($cont =~ /$salario $mensual:* $base* *$de($pesos) $a($pesos)*/i) 	{ $sueldo="$5 $6 $7 $2 $3" } # Sueldo mensual bruto de $7000.00 - $10000.00	| # Sueldo Neto Mensual $19000 a $22000 | Sueldo mensual de $9500 a $11000 | Pago semanal $1450 | Sueldo mensual $11000 | Sueldo base $23544
	elsif ($cont =~ /$salario $base*:* *$mensual*:* *$de$a($pesos) $a($pesos)*/i){ $sueldo="$6 $7 $8 $2 $3" } # Sueldo base desde $6900 a $9200 | Pago semanal $1450 | Sueldo mensual $11000 | Sueldo base $23544 | Salario fijo $60000 $75000 | Sueldo base $9000 a $12000 | Salario bruto mensual: $6563
###	elsif ($cont =~ /$salario $base*:* *$mensual*:* *$de$a($pesos) $a($pesos)*/i){ $sueldo=" $2 $3 $6 a $8"; } #  Salario base mensual entre $3500 a $4600 | Salario base mensual desde $8600 hasta $9200 | Salario base mensual de hasta $6000 a $7900 | Salario base mensual entre $7300 $8200
	elsif ($cont =~ /$salario $de($pesos) $base*/i)  				{ $sueldo="$3 $4" }  # SALARIO DE $25000 NETOS | ingresos de $60000
	elsif ($cont =~ /$salario garant.a:* $de$a($pesos) $mensual*/gi) 		{ $sueldo="$4 $5" }  # Sueldo garantía $3187 mensuales
	elsif ($cont =~ /$salario $de($pesos) mil $a($pesos) mil/i)			{ $sueldo="$3 $4 $5"; }
	elsif ($cont =~ /$salario (base|inicial|mensual) (libre|mensual|bruto|garantizado) (cerca)* *$de($pesos)/i) { $sueldo="$2 $3 $6" } # Sueldo base garantizado cerca de los $4000 | Sueldo Base mensual $6000 | Sueldo mensual libre de: $12683 | Sueldo mensual bruto de $20000
	elsif ($cont =~ /$salario $base*:* *$mas ($pesos)* *$de($comision)/i)		{ $sueldo="$2 $3 $4 $5 $6"; } # sueldo base + $10000 incentivos
	elsif ($cont =~ /$salario $mas $a$de($pesos)/i) 					{ $sueldo="$2 $3 $5" } # SUELDO MAYOR DE $12000
	elsif ($cont =~ /$salario (mínimos )*$mensual $de($pesos) $a($pesos)*/i)	{ $sueldo="$5 $6 $7 $3" } # Ingresos semanales de $3000 $5000 | Ingreso mensual de $5800 
	elsif ($cont =~ /$salario $de$de($pesos) $a($pesos)/i) 				{ $sueldo="$4 $5 $6" } # Ingresos de entre $40000 a $60000 mensuales
	elsif ($cont =~ /$salario $de$a($pesos) $mensual/i) 				{ $sueldo="$4 $5" } # ingresos de hasta $12000 mensual
	elsif ($cont =~ /$bono $mensual* *$de($pesos) $a($pesos)*/i) 			{ $sueldo="$1 $4 $5 $6 $2" }  # bonos desde $10000 hasta $35000 | Bono mensual $1300
	elsif ($cont =~ /$ofrecemos $bono $de($pesos) $a$de($pesos)/i) 		{ $sueldo="$2 $4 $5 $6" } # Ofrecemos: Bonos desde $10000 hasta de $30000 
	elsif ($cont =~ /$ofrecemos $salario $base ($pesos) $a($pesos)/i) 		{ $sueldo="$4 $5 $6 $3" } # Ofrecemos: sueldo base $4000 o $5200
	elsif ($cont =~ /$ofrecemos $de($pesos) $a($pesos)* *$mensual*/i) 		{ $sueldo="$3 $4 $5 $6" } # Ofrecemos De $5000 a $8000 | Ofrecemos $11000 a $13000 mensuales
	elsif ($cont =~ /$ofrecemos $salario (base|mensual):* $de($pesos)/i) 		{ $sueldo="$5 $3" } # OFRECEMOS: Sueldo Base $9500 | Beca mensual: $5000  
	elsif ($cont =~ /$ofrecemos $salario $de($pesos)/i) 				{ $sueldo="$4" } # OFRECEMOS SUELDO: De $10000 		
	elsif ($cont =~ /$ofrecemos ($pesos) $mensual*/i) 				{ $sueldo="$2 $3" }  # Ofrecemos: $10000 | OFRECEMOS: $10000 MENSUALES
	elsif ($cont =~ /$mas $de$a($pesos) $de($pesos)* *$mensual*/i)  		{ $sueldo="$4 $5 $6 $7" }	# SUPERIORES A 20,000 MENSUAL | ARRIBA DE LOS $20000 $25000	
	elsif ($cont =~ /($pesos) (\+ comisi.n(es)*|\+ variable|libre|neto|mensual|brutos|quincenal|CONTRATACI.N)(es)* /i) { $sueldo.=" [$1 $2]" } # $9000 brutos | $10000 mensuales
	elsif ($cont =~ /($pesos) $a($pesos) (libre|neto|mensual|bruto|\/mes)s*/i) 	{ $sueldo="$1 $2 $3 $4" } 	# $35000 a $45000 libres | $1500 a $2000 /mes
	elsif ($cont =~ /$salario (Inicial|mensual|por)*[;:]* (ABIERTO|.*A NEGOCIAR)/i) { $sueldo="$3"; } # Sueldo Inicial; ABIERTO | Sueldo Mensual: A negociar 
	elsif ($cont =~ /$salario competitivo:* ($pesos)/i) 				{ $sueldo=$2; } # Salario competitivo $25000

	if ($cont =~ /(buenos ingresos|Ganancias semanales)/i) 				{ $sueldo.=" [$1]"; }
	if ($cont =~ /($comision no topada)/i) 						{ $sueldo.=" [$1]"; }				
 	my $A='buen sueldo|SUELDO|salario|pago|Sueldo y beneficios|ingreso|excelente';
 	my $B='y comisión|LIBRE DE IMPUESTOS|según aptitudes|de acuerdo a aptitudes|de acuerdo con la experiencia|de acuerdo a experiencia|semanal|quincenal|por consulta|nominal|ingreso|a convenir|negociable|competitivo|competente|atractivo';
	if ($cont =~ /($A)[s:; ]*($B)s*/i)							{ $sueldo.=" [$1 $2]"; } # SUELDO LIBRE DE IMPUESTOS | buen sueldo y comisión
	if ($cont =~ /(\d+\s*%) $de$comision/i) 						{ $sueldo.=" [$1 $3]"; }

	$sueldo ="BASE" if $sueldo=~/^$/;
	$sueldo=~s/ +/ /g;	# Normaliser les espaces
	return $sueldo;
}

