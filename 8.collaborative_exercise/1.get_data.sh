#!/bin/bash
###################################
## PIG DATA (binary)
###################################

## set resources

## Download data (rice, continuous)
echo "Downloading xxx data ..."

### Check for dir, if not found create it using the mkdir ##
[ ! -d "data" ] && mkdir -p "data"  # mkdir = make directory called data in relative path ".."

cd data


echo "Average missing rate is ${avg_miss_rate}"
echo "DONE!"
