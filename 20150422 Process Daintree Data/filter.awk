BEGIN { FS = "\t" }

{
	# print line only if date does not match previous date
	# otherwise, there is a duplicate that will be processed below
	if (previousDate1 != previousDate2 && previousDate1 != $1)
		print previousDate2 "\t" previouskWh2;
	else if (previousDate1 != previousDate2 && previousDate2 != previousDate3)
		print previousDate2 "\t" previouskWh2;
	

	if (previousDate1 == previousDate2 && previousDate1 != $1)
	{
	# if duplicate, print if kWh matches previous kWh
	# this means that it is a duplicate record that may be a true 0 value
		if (previouskWh1 == previouskWh2)
			print previousDate2 "\t" previouskWh2
		else if (previouskWh1 > 0)
			print previousDate1 "\t" previouskWh1
		else if (previouskWh2 > 0)
			print previousDate2 "\t" previouskWh2
	}		
	
	previousDate3 = previousDate2
	previouskWh3 = previouskWh2
	
	previousDate2 = previousDate1
	previouskWh2 = previouskWh1
	
	previousDate1 = $1
	previouskWh1 = $2
}