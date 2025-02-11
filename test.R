library(ggplot2)
library(dplyr)

df <- data.frame(
  x = runif(10),
  y = runif(10)
)

ggplot(df) +
  geom_point(aes(x = x, y = y))

df %>%
  head()

# for statement 
for (i in 1:4){
  print(i)
}

# If statement
if (TRUE){
  print("hello")
}

# Curly brackets
{
  print("hello")
  print("bye")
}

