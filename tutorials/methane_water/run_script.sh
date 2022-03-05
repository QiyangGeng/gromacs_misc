#!/bin/bash
################################################################################################
# A script for running my script for Ethan's free energy methane water gromacs tutorial
# Author:               Yang
# Created:              2022/02/13
# Last modified:        2022/02/13
################################################################################################
# To use this script, set the temperature in Kelvin to temp, and enter all the lambda values you
# want; alternatively, set a lambda parameter, and a list of temperatures, and change the loop
# variable to temps, to run the script for that.

# Set temps
temp="265"
lamb="6 12 18 24 3 9 27"

# Call the other script
for l in $lamb; do
	./FreeEnergyTutorial.sh $l $temp
done

# Another set
temp="60"
lamb="7 13 19 25 4 10 16 22"

for l in $lamb; do
	./FreeEnergyTutorial.sh $l $temp
done
