### Este repositorio permite extraer datos de un archivo de anotación de elementos transponibles (TEs) para generar archivos individuales personalizados de cada superfamilia de TEs. 

## 1. Generar archivos personalizados para TEs en un genoma

#### De acuerdo a la clasificación propuesta por Wicker et al.,(2007) (https://doi.org/10.1038/nrg2165), para cada superfamilia de elemento transponible que haya sido identificado en un genoma se generará un archivo con información que posteriormente facilite buscar secuencias para el análisis estructural y funcional de los TEs.

![Clasificación de TEs según (Wicker et al., 2007)](https://i.postimg.cc/13xcwj1L/Clasificacion-TEs-Wicker-et-al-2007.jpg)

#### La identificación y anotación de TEs debe ser realizada con el paquete **Extensive *de-novo* TE Annotator** (EDTA) (https://github.com/oushujun/EDTA/tree/master). 

#### A partir de los archivos de salida de EDTA se requiere el archivo `genome.fa.mod.EDTA.intact.gff3`, el cual contiene la anotación de elementos transponibles estructuralmente intactos.

#### El script necesario para esta etapa se encuentra en scripts/ 

### Al ejecutar el script se debe dar el argumento que corresponde al archivo de anotación.

`bash CustomTEsAnnotation.sh ../data/genome.fa.mod.EDTA.intact.gff3`

## Input

* `genome.fa.mod.EDTA.intact.gff3`: Este archivo contiene solo TEs estructuralmente intactos, incluyendo LTR, TIR y Helitrons en el genoma. 

## Outputs

* Archivos de texto por cada superfamilia anotada de TEs desde el archivo `genome.fa.mod.EDTA.intact.gff3`. Los archivos resultantes se encuentran en carpetas que llevan el mismo nombre de la superfamilia dentro de results/CustomAnnotation/
* `SummaryAnnotation.txt`: Archivo de resumen con el número de TEs intactos identificados.
* `TEs_intact_identified.txt`: Archivo de resumen con los TEs intactos identificados por superfamilia y orden.
* `out.logfile`: Archivo de registro que almacena stdout y stderr del script ejecutado.
