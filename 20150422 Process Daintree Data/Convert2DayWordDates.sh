cut -f1 -d ',' CombinedDataHeader.csv > dates
while read line; do date -d "$line" +"%a %F %H:%M"; done < dates > DayWordDates
echo ‘ddd YYYY-MM-DD HH:MM’ > DayWordDatesHeader
cat DayWordDatesHeader DayWordDates > DayWordDatesFinal
cut -f2-1000 -d ',' CombinedDataHeader.csv > data
paste -d',' DayWordDatesFinal data > CombinedDataHeaderWordDays.csv
rm dates DayWordDates DayWordDatesHeader DayWordDatesFinal data