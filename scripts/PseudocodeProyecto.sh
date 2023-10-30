# Script para extraer informacion de un archivo de anotación

# Primera Parte:

# Guardar la ruta en la variable "Archivo" para el archivo de anotación que queremos leer

AnnotationFile=$1

# Verificar que el archivo seleccionado existe está en formato .gff o .gff3, o no se encuentra vacio, caso contrario mostrar
# un mensaje de error indicando que el formato del archivo no es correcto o está vacio

if [[ -f $AnnotationFile ]] ; then
	echo -e "\n"
	if [[ $AnnotationFile = *.gff  || $AnnotationFile = *.gff3 ]]; then
		echo "El archivo existe y su formato es válido"
	else
		echo "El archivo existe, pero su extensión no está en formato .gff o .gff3. Intente nuevamente"
		exit 0
	fi
else
	echo "El archivo no existe, intente nuevamente"
	exit 0
fi

# Mostrar información de la primera línea del archivo de anotación para visualizarlo

echo -e "\n"
echo "La información contenida en el archivo de anotación es:"
echo -e "\n"
head -n1 $AnnotationFile

# Definir la carpeta donde se guardarán los resultados

PathResults=~/Desktop/MobileElements/results/

# Extraer información solo de la tercera columna (nombres), contar el número de veces que aparece cada nombre,
# ordenar de mayor a menor y guardar en el archivo "SummaryAnnotation.txt"

cat $AnnotationFile | cut -f 3 | sort | uniq -c | sort -k 1nr > ${PathResults}SummaryAnnotation.txt

# Definir el archivo "SummaryAnnotation.txt" en una variable

SummaryAnnotation=${PathResults}SummaryAnnotation.txt

# Mostrar las 10 primeras líneas del archivo "SummaryAnnotation.txt"

echo -e "\n El resumen del archivo de anotación es: \n"
head -n20 $SummaryAnnotation

# Crear un archivo "NamesAnnotation.txt" solo con los nombres de todos los elementos que se anotaron 

awk '{print $2}' $SummaryAnnotation > ${PathResults}NamesAnnotation.txt

# Segunda Parte

# Definir el archivo "NamesAnnotation.txt" en una variable

NamesAnnotation=${PathResults}NamesAnnotation.txt

# Hacer un loop para generar archivos de anotación independientes para cada nombre de los 
# elementos del archivo "NamesAnnotation.txt"

PersonalizedAnnotation=${PathResults}PersonalizedAnnotation/
counter=0
blank_line=true


while IFS="" read -r transposon
do
counter=$((counter + 1))
if [[ -z $transposon ]]; then
blank_line=false
echo "Se encontró una línea en blanco en la línea $counter. No se puede continuar"
exit 1
fi
if [[ $blank_line = true ]]; then
awk '{if($3 == "'$transposon'") print $3"\t"($5-$4)"\t"$1"\t"$7"\t"$9}' $AnnotationFile | sort -k 2 -n -r > ${PersonalizedAnnotation}$transposon.gff3
fi
	
	#if [[ $transposon = "" ]]; then
	#	echo "Se llegó al final del documento. El bucle ha terminado"
	#	break
	#fi

#awk '{if($3 == "'$transposon'") print $3"\t"($5-$4)"\t"$1"\t"$7"\t"$9}' $AnnotationFile | sort -k 2 -n -r > ${PersonalizedAnnotation}$transposon.gff3

done < ~/Desktop/MobileElements/results/NamesAnnotation1.txt #$NamesAnnotation

if [[ $blank_line = true ]]; then
	echo "No se encontraron lineas en blanco"
	echo "Se llegó al final del documento correctamente. Se leyó $count lineas"
fi



#echo $transposon
