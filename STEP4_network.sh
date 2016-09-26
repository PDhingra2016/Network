#SCRIPT TO MAKE FINAL NETWORK (TF-target gene edges)

rm -rf NETWORK_OUTPUT
mkdir NETWORK_OUTPUT

dir="NETWORK_OUTPUT"

rm ENH_DHS_NETWORK  PRO_DHS_NETWORK

for i in `cat TFgene_list`
do 
	
	awk  -v i=$i -F "\t" '{OFS=FS;  print $1,$2,$3,$4,i,$10,"Enhancer"}' motif_ENHANCERS/$i"_all" >> $dir"/ENH_DHS_NETWORK"	
	awk -v i=$i  -F "\t" '{OFS=FS;  print $1,$2,$3,$4,i,$10,"Promoter"}' motif_PROMOTERS/$i"_all" >> $dir"/PRO_DHS_NETWORK"	
done


cd $dir
sort -u  ENH_DHS_NETWORK >unique_ENH_DHS_NETWORK
sort -u  PRO_DHS_NETWORK >unique_PRO_DHS_NETWORK
cat unique_ENH_DHS_NETWORK unique_PRO_DHS_NETWORK >FINAL_ENH_PRO_DHS_NETWORK
echo -e "TF - target gene edges with promoter and enhancer information are stored in FINAL_ENH_PRO_DHS_NETWORK file\n" >>../logfile
echo -e "TF\tTARGET_GENE" >TF_TARGET_EDGES.txt
awk '{print $5"\t"$4}' FINAL_ENH_PRO_DHS_NETWORK | sort |uniq >>TF_TARGET_EDGES.txt
echo -e "FINAL PROSTATE NETWORK WITH TF-TARGET GENE EDGES IS STORED IN TF_TARGET_EDGES.txt\n" >>../logfile
cd ../
