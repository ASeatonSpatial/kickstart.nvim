# This is a test to see what the LSP
# does
library(ggplot2)
df <- data.frame(
  x = runif(10),
  y = runif(10)
)
ggplot(df) +
  geom_point(aes(x = x, y = y))

