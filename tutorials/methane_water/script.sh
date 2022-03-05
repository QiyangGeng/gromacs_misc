#!/bin/bash
################################################################################################
# A script for running Ethan's free energymethane water gromacs tutorial
# Author:               Yang
# Created:              2022/02/13
# Last modified:        2022/03/04
################################################################################################
# To use this script, put this script in an empty folder. Then, type the following
# commands into the terminal, with said folder set to be the working directory:
#       chmod +x FreeEnergyTutorial.sh
#       ./FreeEnergyTutorial.sh [lambda] [t in Kelvin] {deleteFile: F to not}
# Then, wait a while, and it should be good
# Tested on Ubuntu 18.04 and 20.04.

# Check parameters
if [[ $# -lt 2 ]]; then
        echo "Illegal number of parameters"
        exit 64
fi

# We execute GMXRC just in case
source /usr/local/gromacs/bin/GMXRC

# URL to the github repository where files are located
github=https://raw.githubusercontent.com/QiyangGeng/gromacs_misc/main/tutorials/methane_water/

# Save parameters to variables
let lamb=$1
let temp=$2

# We set up a new directory
dir=methane_script_$lamb_$temp
[ ! -e $dir ] || rm -r $dir; mkdir $dir

# See if the necessary files exists in the current directory, otherwise download the necessary files
file_names="em_steep.mdp nvt.mdp npt.mdp md.mdp methane_water.gro topol.top"

for file in $file_names; do
        if [[ -f $file ]]; then
                echo "Found $file"
        else
                echo "Downloading $file"
                wget $github$file --no-check-certificate

		# We check that we have acquired the file
		if [[ ! $? ]]; then
			echo "Exiting: failed to acquire file $file"
			rm -r $dir
			exit 2
		fi        
	fi

	cp $file $dir/
	
        # We now change all the files to match the lambda and temp values
        sed -i -e '/init_lambda_state        =/s/= .*/= '"$lamb"'/' $dir/$file
        sed -i -e '/gen_temp                 =/s/= .*/= '"$temp"'/' $dir/$file
        sed -i -e '/ref_t                    =/s/= .*/= '"$temp"'/' $dir/$file
done

# We change our working directory
cd $dir

# We move a bunch of stuff
mkdir em;       mv em_steep.mdp em
mkdir nvt;      mv nvt.mdp nvt
mkdir npt;      mv npt.mdp npt
mkdir md;       mv md.mdp md


# We start to run the simulation, using commands provided by Ethan
cd em
gmx grompp -f em_steep.mdp -c ../methane_water.gro -p ../topol.top -o methane.tpr
gmx mdrun -v -deffnm methane

# We temporarily set 'gen-vel' to true for nvt.mdp for this step
cd ../nvt
sed -i -e '/gen_vel                  =/s/= .*/= yes/' nvt.mdp

gmx grompp -f nvt.mdp -c ../em/methane.gro -p ../topol.top -o methane.tpr
gmx mdrun -v -deffnm methane

# We set 'gen-vel' back to false
sed -i -e '/gen_vel                  =/s/= .*/= no/' nvt.mdp

gmx grompp -f nvt.mdp -c ../em/methane.gro -p ../topol.top -o methane.tpr
gmx mdrun -v -deffnm methane

cd ../npt
gmx grompp -f npt.mdp -c ../nvt/methane.gro -p ../topol.top -o methane.tpr -t ../nvt/methane.cpt
gmx mdrun -v -deffnm methane

cd ../md
gmx grompp -f md.mdp -c ../npt/methane.gro -p ../topol.top -o methane.tpr -t ../npt/methane.cpt
gmx mdrun -v -deffnm methane

cd ..
mv md/methane.xvg ../methane_$lamb_$temp.xvg


# Remove files unless told otherwise
if [[ $? -eq 0 && ( !$# -gt 2 || $3 != "F" ) ]]; then
        echo "Removing files"
        cd ..
        rm -r $dir
fi

