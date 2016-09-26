#Program to generate DHS network for prostate. It use PIQ software output and performs intersection with promoters and enhancers
#STEP1: Find active promoter and enhancer regions in tissue and merged PIQ results files

if [ "$#" -ne 2 ];then echo -e "sh NETWORK_DHS_SCRIPT.sh <DHS_file> <PIQ_RESULT_DIR>\n"
else 
	echo -e "Finding active promoters and enhancers in prostate network\n" >logfile
	DHS_file=$1
	dir_PIQ_results=$2
	promoter_file="gencode.v16.promoter.bed"
	enhancer_file="enhancer.bed"
	home=`pwd`

	#PROMOTERS
	intersectBed -a gencode_promoter_uniq -b $DHS_file -wa -wb >tmp
	awk -F ";" '$1=$1' OFS="\t" tmp |awk -F "\t" '{OFS="\t";print $1,$2,$3,$4}'|sort|uniq >"active_promoters"

	#ENHANCERS
	awk -F "\t" '{print $1"\t"$2"\t"$3}' $enhancer_file |sort|uniq >sort_uniq_enhancer.bed
	sortBed -i sort_uniq_enhancer.bed | mergeBed >merged_sort_uniq_enhancer.bed
	intersectBed -a merged_sort_uniq_enhancer.bed -b $DHS_file -wa -wb >tmp
	awk -F "\t" '{print $1"\t"$2"\t"$3}' tmp |sort|uniq > Active_enhancers_Prostate
	intersectBed -a Active_enhancers_Prostate -b $enhancer_file -wa -wb | awk -F "\t" '{print $1"\t"$2"\t"$3"\t"$7}'| sort| uniq > "active_enhancers"
	rm tmp sort_uniq_enhancer.bed merged_sort_uniq_enhancer.bed Active_enhancers_Prostate

	echo -e "Active promoters and active enhancers are stored in active_promoters and active_enhancers file respectively\n" >>logfile

	# merge PIQ output files reverse and forward strand into one file.
	# This file has information about motif enrichment in DHS regions of tissue: chr, start, end, score, purity and strand information.
	# output of this program is stored in merged_files directory
	
#	cd $dir_PIQ_results
#	ls *RC*.csv >"/"$home"/temp"
#	cat temp | grep ".RC" |cut -d "." -f1|sort|uniq >"/"$home"/list"
#	cd $home

	echo -e  "Merging PIQ output files for reverse and forward strand motif enrichment into one common file" >>logfile

#	rm -rf  merged_files >/dev/null
#	mkdir merged_files			 #store all merged files in this folder
#	perl PIQ_merge.pl list $dir_PIQ_results
#	ls merged_files/* >merged_file_list
	ls $dir_PIQ_results/* >merged_file_list 
	
	echo -e "Merged files are store in $home/merged_files folder\n" >>logfile

#STEP2
#Identify motifs enriched in active promoters and active enhancer regions
	sh STEP2_network.sh

#STEP3
#Merge multiple motifs TF motifs into a single file.  This is done to make TF-gene connections
	sh STEP3_network.sh

#STEP4
#Generate TF-target gene edges
	sh STEP4_network.sh

#STEP5
#Calculate degree distribution for the network
	cd NETWORK_OUTPUT
	Rscript ../degree_script.R TF_TARGET_EDGES.txt 
	echo -e "Outdegree and Indegree values for TF_TARGET_EDGES.txt are stored in NETWORK_OUTPUT folder\n" >>../logfile

#STEP6
#final network stats

	num_of_TF_nodes=`awk '{print $1}' TF_TARGET_EDGES.txt |sort|uniq|wc -l`
	num_of_edges=`wc -l TF_TARGET_EDGES.txt`
	num_of_prostate_promoters=`wc -l ../active_promoters`
	num_of_prostate_enhancers=`wc -l ../active_enhancers`
	echo -e "NETWORK STATS\n" >>../logfile
	echo -e "NUMBER OF TF NODES=\t$num_of_TF_nodes" >>../logfile
	echo -e "NUMBER OF EDGES=\t$num_of_edges" >>../logfile
	echo -e "NUMBER oF PROSTATE PROMOTERS=\t$num_of_prostate_promoters" >>../logfile
	echo -e "NUMBER OF PROSTATE ENHANCERS=\t$num_of_prostate_enhancers" >>../logfile
	cd $home
	echo -e "NETWORK IS READY"
#STEP7
#cleaning
	rm tmp 
fi
