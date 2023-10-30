# Escribe un código que imprima un numero y su cuadrado a lo largo de un rango de valores 
# Tambien que imprima la suma de todos los cuadrados de dicho rango

# Define el valor mínimo y el valor máximo
lower = 1
upper = 5

# Crea una variable que se llame "squaresum" que tenga al inicio 0
squaresum = 0

# Haz un loop a lo largo de ese rango y por cada valor"
	# 1. Imprime el valor y el valor al cuadrado
	# 2. Adiciona el valor al cuadrado a la variable "squaresum"

for (ii in lower:upper)
  {cat (ii, ii^2, "\n")
  squaresum = squaresum + ii^2
  }

cat("The sum of it all is", squaresum)