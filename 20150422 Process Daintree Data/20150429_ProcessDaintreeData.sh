#First, hourly kwh files were downloaded from Daintree and concatenated
#Daintree truncates last records of data in date range; therefore, needed to download overlapping data.
#This script handels only "single" overlapped data
#Next, in order to parse the data from circuits, blank lines needed to be replaced by a unique string, "STOP" 

cat ./OriginalData/*.csv > AllData.txt

# Replace all blank lines with STOP
# http://stackoverflow.com/questions/16508701/bash-replace-empty-line-with-string
 while read line
 do
	 echo "${line:-STOP}"
 done < AllData.txt > AllDataProcessed.txt



#loop through each name of circuits as reported in the hourly kWh files exported from Daintree
#Names are contained in the AllMonitoredPoints.txt files which was manually created
n=0
while read circuit
do
echo $circuit
	#Print all lines between patterns. The patterns are the circuit name and STOP
	#http://www.cyberciti.biz/faq/sed-display-text/
		#sed -n '/$circuit/,/STOP/p' AllDataProcessed.txt | grep "^[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]" > "$circuit".data
		sed -n '/'"$circuit"'/,/STOP/p' AllDataProcessed.txt | grep "^[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]" > temp.txt
		
		#The time stamp must be parse and reconstructed as mm/dd/yyyy hh:mm to be processed by date below
		cut -f1 -d',' temp.txt > timestamps
		cut -f1 -d',' temp.txt | cut -f1 -d '/' > Day
		cut -f1 -d',' temp.txt | cut -f2 -d '/' > Month
		cut -f3 -d'/' temp.txt | cut -f1 -d ',' > Rest

		paste -d'/' Month Day Rest > NewDate
		
		#To guard against incorrect chronological ordering of data, time stamps are converted to seconds and data is sorted based on them.
		#Once data is sorted, it is reassembled into a .data file
		while read line
		do
			#date -d "string date" +"%s" converts a string date to epoch seconds 
			date -d "$line" +"%s"
		done < NewDate > Seconds

		cut -f2 -d',' temp.txt > data
		paste Seconds data | sort -k 1 > SortedSecondsData
		cut -f1 SortedSecondsData > SecondsSorted
		cut -f2 SortedSecondsData > DataSorted

		while read line
		do
			# date with the "-d @" option is used to convert epoch seconds to another format
			date -d \@$line +"%F %H:%M"
		done < SecondsSorted > SortedDates		
		
		paste SortedDates DataSorted | awk -f filter.awk | sort -u > "$n".data
		
	n=`echo $n + 1 | bc`
done < AllMonitoredPoints.txt

cut -f1 0.data > timestamp

for x in `seq 0 93`
do
	xPadded=`printf "%02d" $x`
	cut -f2 $x.data > $xPadded.data2	
done

paste timestamp *.data2 > CombinedData.txt	

echo YYYY-MM-DD HH:MM > temp

cat AllMonitoredPoints.txt | tr '\n' '\t' > temp2

paste temp temp2 > header

cat header CombinedData.txt > CombinedDataHeader.txt

sed 's/\t/,/g' CombinedDataHeader.txt > CombinedDataHeader.csv

#Cleanup
#Commnet first rm to keep data, just in case.
#rm *.data2
rm *.data
rm data
rm DataSorted
rm Day
rm CombinedData.txt
rm header
rm Month
rm NewDate
rm Rest
rm Seconds
rm SecondsSorted
rm SortedDates
rm SortedSecondsData
rm temp
rm temp2
rm temp.txt
rm timestamp
rm timestamps
rm CombinedDataHeader.txt
