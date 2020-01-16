#--------------------------- preproc.perl-------------------------------------
#    Pretraitement des données a partir des fichiers csv 
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
# Preproceso de fichier.csv
# Creation     V 0.010 28.11.2019
# Modification V 0.100 01.11.2019
# (C) 2019 Juan-Manuel Torres-Moreno
# entrée: fichier.csv
# sortie: standard o fichier.preproc
# -----------------------------------
# CAMPOS ORIGINALES
# 0  1         2        3       4        5           6        7          8     9    10	11	12	13
# ,Unnamed:0,empresa,puesto,categoria,publicacion,salario,dedicacion,contrato,area,texto,fconsul,url,portal,
#	14		15			16		17		18			19	20		21		22	23		24		25
# contrato_beca,contrato_indefinido,contrato_otro,contrato_comision,contrato_temporal,salariof,periodo_salario,tiene_dec,salarioi,salario_men_med2,cve_mun,alcaldia
# CAMPOS SALIDA
# 0	2		4		6		7		10	14	15	16	17		18	ENTRADA
# ID	empresa	categoria	salario	dedicacion	texto	beca	cdi	otro	comision	cdd	
# 0	1		2		3		4		5	6	7	8	9		10	SALIDA

use strict;
require Encode;
binmode(STDOUT, ":utf8");
binmode(STDIN, ":utf8");

my $text="";
my @texto=<>;
foreach my $linea (@texto){
	if ($linea =~/^(\d+),(\d+),/) { 
		my $a=$1; my $b=$2; 	# print "<$a> <$b>\n";
		if ($a+1 == $b) { $text.="\n\n"; } # reg consecutivos!
	} # print "\n\n"}
	chomp $linea;
	$linea =~ s/\s+/ /g;				# sans Espaces	
	$text.=$linea;				#	print "$linea";
}

#--------------------------- Nettoie caracteres de controle ?
$text =~ s/(\x{0085}|\x{0092}|\x{0093}|\x{0094}|\x{0095}|\x{0096}|\x{0099})/ /g;
$text =~ s/""/ /g;				# Comillas erroneas

my @offre=split/\n\n/,$text; 

foreach my $offre (@offre){
	next if $offre!~/^\d+/;

	my $coma=0; my $comilla=0; my $sep="µ";
	my @champ=split//,$offre;
	my $anuncio="";	
	foreach my $letra (@champ){
		if ($letra eq "\"" and $comilla==0) {$comilla=1; $letra=""} ;
		if ($letra eq ","  and $comilla==0) {$letra=$sep} ;
		if ($letra eq "\"" and $comilla==1) {$comilla=0; $letra=""} ;		
		$anuncio .= $letra;
	}

	my $i=0;	# campos
	my @anuncio=split/$sep/,$anuncio;	# Separer par des | les champs
	foreach my $champ (@anuncio){		# Para todos los campos	
		$champ = clean($champ) if ($i==10);		# clean
									# Quedan solo 11 campos: 0=ID 1=PUESTO 2=  5=TEXTO
		print "$champ\t"if($i==0 or $i==2 or $i==4 or $i==6 or $i==7 or $i==10 or $i==14 or $i==15 or $i==16 or $i==17 or $i==18);
		$i++;		# Control de 26 campos
		if ($i>26) {	print "\nATTENTION $i $champ\n$offre\n"; exit; }	# control de errores
	}
	print "\n";	# Autre registre
}	

exit;

#-------------------------- SUBS
# ------------- Nettoyage ------
sub clean{
	my ($texto) = @_;

	$texto=~s/[\s"]+/ /g;			# Preproceso
	$texto=~s/([\.\!\?])+/$1/g;			# Preproceso signos repetidos	
	$texto=~s/(\w)[\.\!\?]([A-Z])/$1. $2/g;	# Preproceso	
	$texto=~s/([a-z])([A-Z])/$1 $2/g;		# Preproceso	holaADIOS
	$texto=~s/_+/_/g;				# Preproceso			
	$texto=~s/\. \. /./g;			# Preproceso				

	$texto=~s/El contenido de este aviso es de propiedad del anunciante.*$//i; 	# Pub 
												# Pub OCCMundial
	$texto=~s/Compartir: .Consideras que es una vacante de fraude.*$//i; 		
	$texto=~s/(Ver men.Entrar Perfiles de empresas Perfiles laborales Educaci.n Blog Busco Personal Crear cuenta gratis Iniciar sesi.n Listado de Vacantes )/ /gi;

	$texto=~s/·/./g;
	$texto=~s/\. \*/. /g; 
	$texto=~s/: *\./: /g; 
#	$texto=~s/\- / /g;
	$texto =~ s/ /;/g;			# remplazar espacios INVISIBLES	
	$texto =~ s/^ *\. / /g;		# remplazar punto inicial	
	$texto =~ s/\sü\s/ /g;		# remplazar ü	
#	$texto =~ s/(;\s*)+/; /g;		# remplazar ;
	$texto =~ s/\*+/ /g;			# remplazar *	
	$texto =~ s/:\s*;/: /g;		# remplazar :;
	$texto =~ s/\-+/- /g;		# remplazar ---
	$texto =~ s/\.\.+/. /g;		# remplazar ...	
	$texto =~ s/(¡\s*)+/¡ /g;		# remplazar ¡
	$texto =~ s/:+/: /g;			# remplazar :		
	$texto =~ s/Ø/ /g;			# remplazar Ø	
	$texto =~ s/Æ/ /g;			# remplazar Æ		
	$texto =~ s/ +/ /g;			# remplazar espacios

	return $texto;	
}

