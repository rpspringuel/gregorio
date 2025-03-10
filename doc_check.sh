#! /usr/bin/env bash

# This script is used to compare the code base to the documentation and make
# sure that the two match up.
# It does this by creating two lists: one of all the macros defined in the TeX
# code, and one of all the macros documented in the documentation (plus all the
# macros in the code which are marked as deprecated or obsolete, and thus don't
# need documentation.  It then compares these two lists and outputs res.tex
# which contains a list of undocumented macros (preceded by >) and macros which
# are documented but which no longer appear in the code (preceded by <).

# The script is not perfect, and especially has trouble with classes of macros
# which have only one entry in the documentation.

#set -x #echo on

HERE=`pwd`

CODEFILE=$HERE/code.txt
DOCFILE=$HERE/doc.txt
DIFFFILE=$HERE/diff.txt
RESFILE=$HERE/res.txt

#Extraction from code
cd tex

#find definitions
grep -h '\\new[a-z]*\\.*' *.tex *.sty > $CODEFILE
grep -hE '\\[gex]?def\\.*' *.tex *.sty >> $CODEFILE
grep -hE '\\let\\.*' *.tex *.sty >> $CODEFILE
grep -h '\\font\\' *.tex *.sty >> $CODEFILE
grep -h '\\gredefsymbol{.*' *.tex *.sty >> $CODEFILE

#remove deprecated code
sed -i.temp 's:.*@empty@.*::' $CODEFILE
sed -i.temp 's:.*OBSOLETE.*::' $CODEFILE
sed -i.temp 's:.*DEPRECATED.*::' $CODEFILE

#remove trailing comments
sed -i.temp 's/%.*$//' $CODEFILE

#remove whitespace
sed -i.temp 's/^[[:space:]]*//;s/[[:space:]]*$//' $CODEFILE

#remove new and trailing code
sed -i.temp 's:.*\\new[a-z]*{*\(\\*[a-zA-Z@]*\)[\\}]*.*:\1:' $CODEFILE

#get rid of work around def
sed -i.temp 's/\\def\\x//' $CODEFILE

#accept only first def on line
sed -i.temp -E 's:\\[gex]?def:special:' $CODEFILE
#remove def and definition
sed -i.temp -E 's:.*special[a-z]*(\\[a-zA-Z@]*)[#{[].*:\1:' $CODEFILE

#remove let and definition
sed -i.temp 's:.*\\let[a-z]*\(\\[a-zA-Z@]*\)[\\=].*:\1:' $CODEFILE

#remove gredefsymbol and definition
sed -i.temp 's:.*\\gredefsymbol{\([A-Za-z]*\)}.*:\\\1:' $CODEFILE

#remove csname
sed -i.temp 's:.*\(\\csname.*\\endcsname\).*::' $CODEFILE

#colors
grep -hE '\\definecolor.*' *.sty >> $CODEFILE
sed -i.temp 's:\\definecolor{\([a-zA-Z]*\)}.*:\1:' $CODEFILE

#counts
sed -i.temp 's:.*gre@space@count@\([a-z@]*\).*:\1:' $CODEFILE

#distances
grep -h '\\gre@createdim{.*' gregoriotex-gsp-default.tex >> $CODEFILE
sed -i.temp 's:\\gre@createdim{\([a-z@]*\)}.*:\1:' $CODEFILE
sed -i.temp 's:.*gre@space@.*::' $CODEFILE

#styles
sed -i.temp 's:.*endgre@style@::' $CODEFILE
sed -i.temp 's:.*gre@style@::' $CODEFILE

#fonts
sed -i.temp 's:.*\\font\(\\.*\)=.*:\1:' $CODEFILE

#temp registers
sed -i.temp 's:.*dimen@temp@.*::' $CODEFILE
sed -i.temp 's:.*skip@temp@.*::' $CODEFILE
sed -i.temp 's:.*count@temp@.*::' $CODEFILE

#registers for saved values
sed -i.temp 's:\\gre@saved@.*::' $CODEFILE
sed -i.temp '/\\ifgre@saved@.*/d' $CODEFILE

#macros used to process options
sed -i.temp 's:\\gre@autocompile::' $CODEFILE
sed -i.temp 's:\\gre@forcecompile::' $CODEFILE
sed -i.temp 's:\\gre@nevercompile::' $CODEFILE

#block documented items
sed -i.temp 's:\\gre@pitch.*::' $CODEFILE
sed -i.temp 's:.*gre@char@he@.*::' $CODEFILE
sed -i.temp 's:\\gre@protrusionfactor@.*::' $CODEFILE

#remove LaTeX internal
sed -i '/\\input@path/d' $CODEFILE

#label file
echo "00 Macros Defined in TeX" >> $CODEFILE

#alphabetize and remove duplicates
sort -u -o$CODEFILE $CODEFILE


#Extraction from documentation
cd $HERE/doc

grep -h '\\macroname.*' *.tex > $DOCFILE
grep -h '\\stylename{.*' *.tex >> $DOCFILE
grep -h '\\begin{gdimension}{.*' *.tex >> $DOCFILE
grep -h '\\begin{gcount}{.*' *.tex >> $DOCFILE

#remove all but name
sed -i.temp 's:\\macroname{\([^}]*\)}.*:\1:' $DOCFILE

#replace TeX code with backslash
sed -i.temp 's:\\textbackslash :\\:' $DOCFILE

#styles
sed -i.temp 's:.*stylename{\([a-z]*\)}.*:\1:' $DOCFILE

#distances
sed -i.temp 's:\\begin{gdimension}{\([a-z@]*\)}.*:\1:' $DOCFILE

#counts
sed -i.temp 's:\\begin{gcount}{\([a-z@]*\)}.*:\1:' $DOCFILE

#block documentation items
sed -i.temp 's:.*\.\.\..*::' $DOCFILE
sed -i.temp 's:\\gre@pitch.*::' $DOCFILE

#Other things which need to be removed
sed -i.temp 's:\\newcommand.*::' $DOCFILE
sed -i.temp 's:MacroName::' $DOCFILE
sed -i.temp 's:\\usepackage::' $DOCFILE
sed -i.temp 's:\\NewDocumentEnvironment.*::' $DOCFILE
sed -i.temp 's:\\begin{gdimension.*::' $DOCFILE

#deprecated and obsolete functions (not in documentation because they don't need to be)
cd $HERE/tex

grep -h '\\gre@deprecated.*' *.tex | grep -v '\\def\\' >> $DOCFILE
grep -h '\\gre@obsolete.*' *.tex | grep -v '\\def\\' >> $DOCFILE

#remove whitespace
sed -i.temp 's/^[[:space:]]*//;s/[[:space:]]*$//' $DOCFILE

sed -i.temp 's:.*\\gre@deprecated{.*::' $DOCFILE
sed -i.temp 's:.*\\gre@obsolete{.*::' $DOCFILE
sed -i.temp 's:}.*::' $DOCFILE

#label file
echo "00 Macros Documented" >> $DOCFILE

#alphabetize and remove duplicates
sort -u -o$DOCFILE $DOCFILE


#find differences
diff -B $DOCFILE $CODEFILE > $DIFFFILE

grep -h '[<>]' $DIFFFILE > $RESFILE

sort -u -o$RESFILE $RESFILE

#cleanup
rm $DOCFILE.temp
rm $DOCFILE
rm $CODEFILE.temp
rm $CODEFILE
rm $DIFFFILE

cat $RESFILE
