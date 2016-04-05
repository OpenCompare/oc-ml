# http://factominer.free.fr/classical-methods/analyse-en-composantes-principales.html
library(readr)
library(FactoMineR)

nclusters = 200

csv = readr::read_csv('outputhead.csv')
#csv = readr::read_csv('output.csv')

# long !
res.pca = PCA(csv[,-1], scale.unit = T, ncp = 5, graph = F)

k = kmeans(res.pca$ind$coord, nclusters)

features = colnames(csv)

is.nonzero = function(x) { x != 0 }

if(!dir.exists(paste("clusters", nclusters, sep="")))
{
  dir.create(paste("clusters", nclusters, sep=""))
}

for(cluster in 1:nclusters)
{
  sub = Filter(is.numeric, csv[k$cluster == cluster,])
  if(dim(sub)[1] > 1)
  {
    # Enlever cette ligne pour garder le nombre d'occurence d'origine
    sub = sapply(sub, is.nonzero)
    sub = colSums(sub)

    size = dim(csv[k$cluster == cluster,])[1]
    quality = max(sub) / size
  }
  else
  {
    size = 1
    quality = 1
  }

  # feature most representative
  name = features[which.max(sub) + 1] # +1 : décalage d'indice ?

  #file=paste("clusters", nclusters, "/", cluster, "_", quality, sep = "")
  file=paste("clusters", nclusters, "/", cluster, sep = "")
  header = data.frame(cluster, quality, size, name)

  write.table(header, file = file, row.names = F)
  write.table(csv[k$cluster == cluster, 1], file = file, col.names = F, row.names = F, quote = F, append = T)

  print(header)
}
