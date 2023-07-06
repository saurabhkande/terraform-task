
#! /bin/bash

mkdir dir1 dir2 dir3 dir4
mkdir -p dir1/dir11
mkdir -p dir2/{dir21,dir22}
mkdir -p dir3/dir31
mkdir -p dir4/dir41
mkdir -p dir41/dir411

sudo touch dir1/dir11/file101
sudo chmod 777 dir1/dir11/file101

sudo touch dir2/file2
sudo touch dir2/dir22/file22
sudo chmod 777 dir2/file2
sudo chmod 777 dir2/dir22/file22

sudo touch dir3/dir31/file31
sudo chmod 777 dir3/dir31/file31

sudo touch dir4/dir41/file41
sudo touch dir41/dir411/file411
sudo chmod 644 dir4/dir41/file41
sudo chmod 644 dir41/dir411/file411

ln -s dir3/dir31/file31 /home/saurabh
ln -s dir4/dir41/file41 /home/saurabh
ln -s dir41/dir411/file411 /home/saurabh
sudo rm dir3/dir31/file31
sudo rm dir4/dir41/file41

echo "Finding nd removing the dangling files"
find . -xtype l | tee abc
for a in ` cat abc `
do 
   sudo rm -rf $a
done

echo "removing files with permission 777"
find -perm 777 | tee perm
for b in ` cat perm `
do
   sudo rm -rf $b
done 
