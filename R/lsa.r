library(readr)

argv <- commandArgs(TRUE)
file <- "output200.csv"	#matrice d'occurences
valfile <- "./values200.csv"	#
r = 80			# nombre de concepts que l'on veut -> utilser la fonction clusters(n°du cluster) pour savoir ce qu'il y a dedans
pvalue <- 0.8		# seuil a depasser pour chacun des clusters
output = 'res200.txt'	# le fichier de resultat
headcsv = 'head.csv'	# le fichier contenant la 1ere ligne de file (TODO, ne plus utiliser ce fichier)
input <- readr::read_csv(file)

sink('log.txt')		# le fichier pour verifier combien de temps prend chaque etape


time1 = Sys.time()

### PARTIE LSA ###
print('begin lsa')

X <- svd(input)
S <- diag(X$d)
Sk = S[1:r,1:r]
Uk = X$u[,1:r]
M <- solve(Sk)%*%t(Uk)

print('end lsa')
time2 = Sys.time()
tdiff = difftime(time2,time1)
print(tdiff)

### AFFICHAGE ###
#attach(mtcars)/*{{{*/
#par(mfrow=c(r,1))
#barplot(M[1,])
#barplot(M[2,])
#barplot(M[3,])
#barplot(M[4,])
#barplot(M[5,])
#/*}}}*/

### TRI DES VALEURS DE M et PREMIERE RECHERCHE DE CLUSTER (sans pvalue) ###
print('begin tri')
am = abs(M)
f = t(apply(am, 1, function(line) {
sort(line, decreasing=TRUE, index.return=TRUE)$x
 } ) )

fid = t(apply(am, 1, function(line) {
sort(line, decreasing=TRUE, index.return=TRUE)$ix
 } ) )

labels = read.csv(file=valfile,head=FALSE,sep=",")	#les headers sont les labels donc laisser head=FALSE
qlabels = apply(fid, 1,function(x){ labels[1,x]})

print('end tri')
time3 = Sys.time()
tdiff = difftime(time3,time2)
print(tdiff)

#############################################

### AFFINAGE DES CLUSTERS ###
Sy <- rowSums(am)


nb_sign <- function (vecteur, pval)	#return int
{/*{{{*/
	s <- sum(vecteur)
	i <- 1
	while ((1/s*sum(vecteur[1:i])) < pval){
		i <- i + 1
	}
	i <- i +1 	#pour depasser la pvalue
	return (i)
}/*}}}*/

print('begin nb valeurs signicatives')

nb_val_sign = apply(f, 1, function(x){ nb_sign(x,pvalue) })

print('end nb valeurs signicatives')
time4 = Sys.time()
tdiff = difftime(time4,time3)
print(tdiff)

clusters <- function (concept_line)
{/*{{{*/
	gid <- fid[concept_line, (1:nb_val_sign[concept_line]) ]
	glabels = labels[1,gid]
	return (glabels)
}/*}}}*/

###########################################################



getfeat <- function (concept_line)	#return (feats$x,feats$ix), ie features + feature_id
{/*{{{*/
	gid <- fid[concept_line, (1:nb_val_sign[concept_line]) ]
	feats <- sort(colSums(input[gid[1:nb_val_sign[concept_line]],]),decreasing=TRUE,index.return=TRUE)
	return (feats)
}/*}}}*/

qualite <- function (concept_line)	#return int
{/*{{{*/
	gid <- fid[concept_line, (1:nb_val_sign[concept_line]) ] #pas encore assez optimise
	feats_freq <- getfeat(concept_line)
	feat_id <- feats_freq$ix[1] # la feature la plus representee dans le concept
	qual <- 1 - sum(input[gid,][feat_id] == 0)/nb_val_sign[concept_line]
	return (qual)
}/*}}}*/
head = read.csv(file=headcsv,head=FALSE,sep=",")

###########################################################

print ('begin ecrire les resultats')

for (i in 1:r){
	write.table(head[getfeat(i)$ix[1]],row.names=FALSE,col.names=FALSE,file=output,append=T)
	write.table(qualite(i),output,row.names=FALSE,col.names=FALSE,append=T)
	write.table(clusters(i),output,row.names=FALSE,col.names=FALSE,append=T)
	cat("\n",file=output,append=TRUE)
}

print('end ecrire les resultats')
time4 = Sys.time()
tdiff = difftime(time4,time3)
print(tdiff)
sink()


aff <- function (deb, fin, tsleep)	#return void
{ /*{{{*/
	for (i in deb:fin){
		Sys.sleep(tsleep)
		print(i)
		print(qualite(i))
		x = seq(from =1 , to=nb_val_sign[i]+10, by=1)
		tmp=f[i,1:(nb_val_sign[i]+10)]
		barplot(tmp,xlab=qualite(i) , ylab=i, col=ifelse(x<= nb_val_sign[i],'grey','blue'))
	}
}/*}}}*/
