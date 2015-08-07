#25 Apr 2015 Corrected incorrect ordering

#Start Date (YYYY-MM-DD HH:00)
StartDate="2015-01-04 00:00"

#End Date (YYYY-MM-DD HH:00)
EndDate="2015-04-20 23:00"

#Sed Find and Display Text Between Two Strings or Words
sed -n "/$StartDate/,/$EndDate/p" ./CombinedDataHeaderWordDays.csv > TempFiltered.txt

i=0
while read Day
do
	grep $Day TempFiltered.txt > $i.TempFilteredDay
	i=`echo $i + 1 | bc`
done < Days.txt

cat *.TempFilteredDay > TempFilteredDay.txt

while read Hour
do
	grep "$Hour":00 TempFilteredDay.txt > $i.TempFilteredHour
	i=`echo $i + 1 | bc`
done < Hours.txt

cat *.TempFilteredHour > Filtered.csv

#Sum all columns
#http://stackoverflow.com/questions/22042400/awk-sum-multiple-columns

awk 'BEGIN{FS=OFS=","}
     {for (i=1;i<=NF;i++) a[i]+=$i}
     END{for (i=1;i<=NF;i++) printf a[i] OFS; printf "\n"}' Filtered.csv > awkSummed.csv

# Index Daintree points/column headers to output
# Reference file
cat ./CombinedDataHeaderWordDays.csv | tr ',' '\n' > transposed.txt

rm Columns2Output.txt 2> /dev/null
while read DaintreeItem
do
	ColumnNumber=`grep -nr "$DaintreeItem" transposed.txt | cut -d':' -f1`; printf "%02d" $ColumnNumber >> Columns2Output.txt; echo "" >> Columns2Output.txt
	#grep -nr "$DaintreeItem" transposed.txt | cut -d':' -f1 >> Columns2Output.txt
done < DaintreeItemsOfInterest.txt

rm HeaderTemp.txt 2> /dev/null
echo Start Date: $StartDate >> HeaderTemp.txt
echo End Date: $EndDate >> HeaderTemp.txt
echo Days: `cat Days.txt | tr '\n' ' '` >> HeaderTemp.txt
echo Hours: `cat Hours.txt | tr '\n' ' '` >> HeaderTemp.txt
echo "" >> HeaderTemp.txt

echo "Daintree Name" >> RowIDTemp.txt
echo "Energy (kWh)" >> RowIDTemp.txt

rm *.ColumnData 2> /dev/null
#Loop through columns
while read Column
do
	cut -d',' -f$Column awkSummed.csv > $Column.ColumnData
done < Columns2Output.txt

paste -d',' *.ColumnData > ColumnData.txt 

rm ItemsTemp.txt 2> /dev/null
cat DaintreeItemsOfInterest.txt | tr '\n' ',' > ItemsTemp.txt
echo "" >> ItemsTemp.txt
cat ColumnData.txt >> ItemsTemp.txt

paste -d',' RowIDTemp.txt ItemsTemp.txt > TimeOfUse_EnergyReportPre.csv

cat HeaderTemp.txt TimeOfUse_EnergyReportPre.csv > TimeOfUse_EnergyReport.csv

rm HeaderTemp.txt RowIDTemp.txt *.ColumnData ColumnData.txt ItemsTemp.txt TimeOfUse_EnergyReportPre.csv *.TempFilteredDay TempFiltered.txt TempFilteredDay.txt Filtered.csv transposed.txt RowIDTemp.txt *.TempFilteredHour awkSummed.csv Columns2Output.txt 2> /dev/null
 
 
 #rm HeaderTemp.txt RowIDTemp.txt *.ColumnData ColumnData.txt ItemsTemp.txt TimeOfUse_EnergyReportPre.csv *.TempFilteredDay TempFiltered.txt TempFilteredDay.txt Filtered.csv transposed.txt RowIDTemp.txt *.TempFilteredHour awkSummed.csv 2> /dev/null