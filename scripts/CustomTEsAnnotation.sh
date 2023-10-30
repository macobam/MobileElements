#PROGRAMA: CustomTEsAnnotation.sh 
#OBJETIVO: Generar archivos de anotación personalizados para cada elemento transponible estructuralmente intacto anotado de novo en un genoma
#AUTOR: Manuel Alejandro Coba
#FECHA: 2023/10/25

(

#----------------------------
#
# Primera Parte
#
#----------------------------


# ----------------------------------------------------------------------------------------------------------------------------
# Identificar todas las superfamilias de elementos transponibles (TEs) estructuralmente intactos que se anotaron en el genoma
# ----------------------------------------------------------------------------------------------------------------------------

# Agregar el archivo de anotación de elementos transponibles a la variable $AnnotationFile

AnnotationFile=$1

# Verificar condiciones que el archivo proporcionado por el usuario debe cumplir para poder ser procesado:
# El archivo debe existir y contener alguna informacion
# El formato del archivo de anotación deberá estar dado en extension 'gff3' o 'gff'
# De no cumplir alguna condición, mostrar el mensaje de error correspondiente

if [[ -f $AnnotationFile ]]
then
    if [[ -s $AnnotationFile ]]
	then
		if [[ $AnnotationFile = *.gff  || $AnnotationFile = *.gff3 ]]
		then
			echo "El archivo proporcionado es correcto y puede ser leído."
		else
			echo -e "\nERROR: El archivo proporcionado existe, pero su extensión no corresponde al formato '.gff' o '.gff3'."
			echo -e "\nVerifique la extensión del archivo de anotación e intente nuevamente."
		exit 0
		fi
	else
		echo -e "\nERROR: El archivo de anotación está vacio y no contiene información. Verifique el contenido archivo e intente nuevamente."
	exit 0
	fi
else
	if [[ -d $AnnotationFile ]]
	then
		echo -e "\nERROR: Ha proporcionado un directorio. Intente nuevamente."
		exit 0
	else
		echo -e "\nERROR: El archivo proporcionado no existe. Verifique que el archivo de anotación sea válido e intente nuevamente."
		exit 0
	fi
fi

# Indicar el número de elementos transponibles se encontraron en el archivo de anotación 

echo -e "\nEn este genoma se encontró $(wc -l < $AnnotationFile) elementos transponibles que fueron anotados como estructuralmente intactos."

# Definir la carpeta principal donde se guardarán los resultados que se generarán en este script

Results_folder=~/Desktop/MobileElements/results/

# Extraer el tipo de característica (3ra columna) desde el archivo de anotación
# Contar el número de veces que aparece cada tipo de característica y ordenar de mayor a menor
# Guardar el resultado en el archivo "SummaryAnnotation.txt"

cat $AnnotationFile | grep -v "#" | cut -f 3 | sort | uniq -c | sort -k 1nr > ${Results_folder}SummaryAnnotation.txt

# Almacenar el archivo "SummaryAnnotation.txt" dentro de la variable $SummaryAnnotation

SummaryAnnotation=${Results_folder}SummaryAnnotation.txt

# Imprimir el contenido del archivo "SummaryAnnotation.txt"

echo -e "\nLas superfamilias de elementos transponibles encontradas fueron:\n"
cat $SummaryAnnotation

# Crear el archivo "NamesTEsAnnotation.txt" solamente con los nombres de las superfamilias de todos los elementos que se anotaron

awk '{print $2}' $SummaryAnnotation > ${Results_folder}NamesTEsAnnotation.txt

# Almacenar el archivo "NamesTEsAnnotation.txt" dentro de la variable $NamesTEsAnnotation

NamesTEsAnnotation=${Results_folder}NamesTEsAnnotation.txt

#----------------------------
#
# Segunda Parte
#
#----------------------------


# ----------------------------------------------------------------------------------------------------------------------------
# Generar archivos de anotación personalizados para cada superfamilia de TEs anotados en el genoma
# ----------------------------------------------------------------------------------------------------------------------------

# Crear una carpeta para guardar las anotaciones, verificando previamente si la carpeta ya existe

# Definir el nombre de la carpeta y la ruta donde se desea crear
CustomAnnotation_folder=~/Desktop/MobileElements/results/CustomAnnotation/

# Verificar si el directorio ya existe, caso contrario crear la carpeta
if [[ ! -d $CustomAnnotation_folder ]]
then
	mkdir $CustomAnnotation_folder
fi

# Verificar que el archivo de "NamesTEsAnnotation.txt" que contiene los nombres de las superfamilias de TEs no contiene líneas en blanco

# Definir variables que permitan encontrar líneas vacías en alguna posición del documento
count_line=0
empty_line=""

# Leer cada una de las líneas del archivo
while IFS="" read -r transposon
do
	count_line=$((counter_line + 1))
		if [[ -z $transposon ]]
		then
			empty_line="${empty_line}Línea $count_line\n"
		fi
done < $NamesTEsAnnotation

#Verificar si existen líneas vacias en el documento
if [[ -n $empty_line ]]
then
	echo -e "\nERROR: No se puede procesar el documento. Se encontraron líneas vacias en:"
	echo -e $empty_line
	exit 0
else
	count_line=0
	while IFS="" read -r transposon
	do
		count_line=$((count_line + 1))
		awk '{if($3 == "'$transposon'") print $3"\t"($5-$4)"\t"$1"\t"$7"\t"$9}' $AnnotationFile | sort -k 2 -n -r > ${CustomAnnotation_folder}${transposon}_custom.txt
	done < $NamesTEsAnnotation
	echo -e "\nSe leyeron correctamente $count_line líneas en '$(basename $NamesTEsAnnotation)', y se han creado los respectivos documentos personalizados"
fi

# Crear carpetas para cada superfamilia de los TEs anotados en el genoma

# Leer el nombre de la superfamilia de TEs en cada línea del en el archivo "NamesTEsAnnotation.txt"
while IFS="" read -r transposon
do
	if [[ $transposon == *"_TIR_transposon" ]]
	then
		TEs_folder=${CustomAnnotation_folder}TIR_Transposons
	elif [[ $transposon == *"_LTR_retrotransposon" ]]
	then
		TEs_folder=${CustomAnnotation_folder}LTR_Retrotransposons
	elif [[ $transposon == "helitron"* ]]
	then
		TEs_folder=${CustomAnnotation_folder}Helitron
	fi
if [[ ! -d $TEs_folder ]]
then
	mkdir $TEs_folder
fi
done < $NamesTEsAnnotation
rm -f $NamesTEsAnnotation


# Crear una carpeta adicional para MITEs solo sí se ha creado la carpeta de TIR_Transposons
if [[ ! -d ${CustomAnnotation_folder}MITEs/ && -d ${CustomAnnotation_folder}TIR_Transposons/ ]]
then
  mkdir ${CustomAnnotation_folder}MITEs
fi

# Almacenar las rutas de cada carpeta creada dentro de diferentes variables

TIR_Transposons_folder=${CustomAnnotation_folder}TIR_Transposons/
LTR_Retrotransposons_folder=${CustomAnnotation_folder}LTR_Retrotransposons/
MITEs_folder=${CustomAnnotation_folder}MITEs/
Helitron_folder=${CustomAnnotation_folder}Helitron/

# Procesar cada archivo personalizado para generar nuevos archivos individuales dentro de la carpeta correspondiente

# Verificar que el número de archivos que se procesarán es el mismo que el número de superfamilias identificadas en "NamesTEsAnnotation.txt"
if [[ $count_line -eq $(ls $CustomAnnotation_folder*_custom.txt | wc -l) ]]
then
	for file in $CustomAnnotation_folder*_custom.txt
	do
		echo -e "\n$(basename $file)"
		echo "Procesando el archivo: $(basename $file)"
		sed -e "s/;/\t/g" $file > $file.tmp
		mv $file.tmp $file
		if [[ "$(basename $file)" == *"_TIR_transposon_custom.txt" ]]
		then
			awk '{if($2 > 600) {print $1"\t"$2"\t"$3"\t"$4"\t"$6"\t"$7"\t"$11"\t"$12}}' $file > ${TIR_Transposons_folder}$(basename $file | sed "s/_TIR.*//").txt
			awk '{if($2 <= 600) {print $1"\t"$2"\t"$3"\t"$4"\t"$6"\t"$7"\t"$11"\t"$12}}' $file > ${MITEs_folder}$(basename $file | sed "s/_TIR.*//")_MITEs.txt
			echo "Se leyó correctamente el archivo: $(basename $file)"
		elif [[ "$(basename $file)" == *"helitron_custom.txt" ]]
		then
			awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$6}' $file > ${Helitron_folder}$(basename $file | sed "s/_.*//").txt
			echo "Se leyó correctamente el archivo: $(basename $file)"
		elif [[ "$(basename $file)" == *"_LTR_retrotransposon_custom.txt" ]]
		then
			awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$6"\t"$7"\t"$10"\t"$12"\t"$13}' $file > ${LTR_Retrotransposons_folder}$(basename $file | sed "s/_LTR.*//").txt
			echo "Se leyó correctamente el archivo: $(basename $file)"
		elif [[ "$(basename $file)" == "LTR_retrotransposon_custom.txt" ]]
		then
			awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$6"\t"$7"\t"$10"\t"$12"\t"$13}' $file > ${LTR_Retrotransposons_folder}Unknown_$(basename $file | sed "s/_LTR.*//").txt
			echo "Se leyó correctamente el archivo: $(basename $file)"
		elif [[ "$(basename $file)" == "long_terminal_repeat_custom.txt" ]]
		then
			awk '{if($8 == "Classification=LTR/Gypsy") print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$7"\t"$10"\t"$12"\t"$13}' $file > ${LTR_Retrotransposons_folder}Gypsy_$(basename $file | sed "s/long_.*//")LTR.txt
			awk '{if($8 == "Classification=LTR/Copia") print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$7"\t"$10"\t"$12"\t"$13}' $file > ${LTR_Retrotransposons_folder}Copia_$(basename $file | sed "s/long_.*//")LTR.txt
			awk '{if($8 == "Classification=LTR/unknown") print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$7"\t"$10"\t"$12"\t"$13}' $file > ${LTR_Retrotransposons_folder}Unknown_$(basename $file | sed "s/long_.*//")LTR.txt
			echo "Se leyó correctamente el archivo: $(basename $file)"
		elif [[ "$(basename $file)" == "repeat_region_custom.txt" ]]
		then
			awk '{if($7 == "Classification=LTR/Gypsy") print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$10"\t"$12"\t"$13}' $file > ${LTR_Retrotransposons_folder}Gypsy_$(basename $file | sed "s/repeat_.*//")RepeatRegion.txt
			awk '{if($7 == "Classification=LTR/Copia") print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$10"\t"$12"\t"$13}' $file > ${LTR_Retrotransposons_folder}Copia_$(basename $file | sed "s/repeat_.*//")RepeatRegion.txt
			awk '{if($7 == "Classification=LTR/unknown") print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$10"\t"$12"\t"$13}' $file > ${LTR_Retrotransposons_folder}Unknown_$(basename $file | sed "s/repeat_.*//")RepeatRegion.txt
			echo "Se leyó correctamente el archivo: $(basename $file)"
		elif [[ "$(basename $file)" == "target_site_duplication_custom.txt" ]]
		then
			awk '{if($7 == "Classification=LTR/Gypsy") print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$7"\t"$10"\t"$12"\t"$13}' $file > ${LTR_Retrotransposons_folder}Gypsy_$(basename $file | sed "s/target_.*//")TSD.txt
			awk '{if($7 == "Classification=LTR/Copia") print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$7"\t"$10"\t"$12"\t"$13}' $file > ${LTR_Retrotransposons_folder}Copia_$(basename $file | sed "s/target_.*//")TSD.txt
			awk '{if($7 == "Classification=LTR/unknown") print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$7"\t"$10"\t"$12"\t"$13}' $file > ${LTR_Retrotransposons_folder}Unknown_$(basename $file | sed "s/target_.*//")TSD.txt
			echo "Se leyó correctamente el archivo: $(basename $file)"
		fi
	done
else
	echo "ERROR: El número de archivos generados no coincide con el número de superfamilias que se indica en el archivo "NamesTEsAnnotation.txt" los generados previamente."
	echo "Revise los archivos contenidos en "$CustomAnnotation_folder""
fi

# Generar un archivo de resumen con el número de TEs identificados en cada archivo de las superfamilias

# Verificar archivos vacios que se crearon sin información por no cumplir la coincidencia establecida anteriores
for folder in ${CustomAnnotation_folder}*
	do
	if [[ -d $folder ]]
	then
		find $folder -type f -size 0 -delete

# Excluir tipos de archivos que corresponden a partes de TEs y no son propiamente superfamilias
		list_files=$(ls $folder | grep -E -v "*_LTR*|*_TSD*|*_RepeatRegion*")
		for file in $list_files
		do
			numberTEs=$(wc -l < $folder/$file)
			echo -e "$numberTEs\t$(basename $file .txt)\t$(basename $folder)" >> ${Results_folder}TEs_intact_identified.txt.tmp
		done
	fi
	done

# Ordenar descendentemente el número de TEs que se identificaron
cat ${Results_folder}TEs_intact_identified.txt.tmp | column -t -s $'\t' | sort -k 1nr > ${Results_folder}TEs_intact_identified.txt
rm -f ${Results_folder}TEs_intact_identified.txt.tmp
) 2>&1 | tee -a out.logfile

