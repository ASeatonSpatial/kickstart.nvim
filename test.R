# This is a test to see what the LSP
# does
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

for (i in 1:4){
  print(i)
  # Here is a comment
}

{
  print("hello") 
  1 + 1
}

