#!/bin/sh
# #+title: Readme



# [[file:README.org::+BEGIN_SRC sh :tangle INSTALL.sh :comments both :shebang "#!/bin/sh"][No heading:1]]
# apt install texlive-full
wget -q -O- https://ftp.ncbi.nih.gov/pub/HomoloGene/current/homologene.data | gzip -c > homologene.data
# No heading:1 ends here
