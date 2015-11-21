#Analisi Generale
Prendiamo per esempio train. Ogni riga di subject_train.txt contiene un record
di attività, in particolare l'ID relativo al soggetto. Sono c.ca 7352 righe.
In y_train trovo per ogni riga l'attività specifica, la cui descrizione è 
contenuta in activity_labels.txt.
In x_train ho per ogni riga un vettore, ma non ho ancora capito di quanti elementi
e come collegarlo.
Nella cartella "Inertial Signals" trovo i rilevamenti relativi ai giroscopi nei tre assi.
Ogni riga corrisponde alle righe dei file precedenti (sempre le fatidiche 7352 righe).

Quindi, problema 1 - Come fare a interpretare X_train.txt e i vettori dei giroscopi.
Problema 2, come collego train con test ?

Problema 1 risolto. Ora ho un modo per leggere x_train e x_test e associarli ad una delle 561 features.

Il punto 1 richiede il merge. Non abbiamo elementi di merge per cui l'unica cosa che mi viene in mente è fare una sorta di union aggiungendo una colonna che identifica la tipologia di misura "test" o "training".

Punto 2, estrarre solo le misurazioni nella media e nella deviazione standard per ogni misura. (problema 2).
Risolto, ora ho un nuovo dataframe, tst.features.mainStd che contiene solo id colonna e nomi relativi a mean e std. Da risolvere Problema 2.1 (contenuto anche meanFreq() e non dovrebbe esserlo).
Risolto il problema 2.1 ho 66 colonne e devo ridurre il txt.train.xtrain in un dataframe con le 66 colonne contenute in tst.features.meanStd$feat_id.

Lo faccio con il seguente codice `tst.train.xtrain[,tst.features.meanStg$feat_id]`

Ok, ci siamo, ho prodotto i due data frame con test e training con descrizione delle attività.
Devo fare la union (fatta con rbind).

Abbiamo completato i primi 4 punti, ottimo.
E mo arriva il bello. 
Ora il dataset ha questa struttura: 
- subject : soggetto
- type : train o test
- act_id : codice dell'attività
- act_name : valore dell'attività
- ... circa 66 variabili 

Mi sono dimenticato il subject da qualche parte. Giusto, proprio all'inizio, devo caricare anche il file subject_train, altrimenti non c'è n'è per nessuno ... corretto.

Devo fare la media di ogni varibile (ovvero le colonne dalla 5 alla 70) raggruppato per act_name e subject.






##Problema 1 - x_train.txt
Ho esportato in excel una riga ed è effettivametne composta da 561 elementi (gli stessi elementi di features). 

##Problema 1.1 - Leggere x-train in un vettore di 561 elementi

```
tst.train.xtrain <- read.csv2("Data/train/X_train.txt",nrows=1,sep="",strip.white = TRUE,skipNul = TRUE)
```

Questo lo fa.

##Problema 2 - Estrarre solo misure di mean o deviazione standard
Ok, dalla tst.features devo estrarre solo le features che contengono mean() e std().
Devo utilizzare regexp.
Ok, con questa istruzione

```
grepl("mean\\(\\)|std\\(\\)",tst.features$feat_name)
```

ho un vettore logico con le sole features contenenti mean oppure std.
Ottengo un vettore con 79 indicatori

##Problema 2.1 - Come mai riporta anche meanFreq ?
Devo utilizzare mean\\(\\) per chiudere.
