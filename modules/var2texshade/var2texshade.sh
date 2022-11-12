#!/bin/sh
# [[file:README.org::+BEGIN_SRC sh :tangle var2texshade.sh :comments both :shebang "#!/bin/sh"][No heading:2]]
set -o errexit
set -o nounset
if [ "${TRACE-0}" = "1" ]; then
    set -o xtrace
fi

if [ "${1-}" = "help" ]; then
    echo 'Usage: ./script.sh arg-one arg-two

This is an awesome bash script to make your life better.

'
    exit
fi

cd "$(dirname "$0")"

main() {
    # $1 is hgvsp NP_003385.2:p.His365Arg
    PADDING_LEFT=10
    PADDING_RIGHT=10

    TMPDIR=$(mktemp -d)
    HOMOLOGENEHTML=$(mktemp -p "$TMPDIR")
    MSA=$(mktemp -p "$TMPDIR")
    TEXFILE=$(mktemp -p "$TMPDIR")

    hgvsp="$1"
    proteinid=${hgvsp%:*}
    if [ "$proteinid" = "$hgvsp" ];then
      echo "couldn't parse the protein id"
      exit 1
    fi
    aachange=${hgvsp##*.}
    if [ "$aachange" = "$hgvsp" ];then
      echo "couldn't parse the aachange"
      exit 1
    fi
    position=$(echo "$aachange" | tr -cd 0-9)
    startpos=$((position - PADDING_LEFT))
    endpos=$((position + PADDING_RIGHT))

    homologeneid=$(zcat homologene.data | grep -m1 "$proteinid" | awk '{print $1}')
    if [ -z $homologeneid ]; then
        echo "couldn't find the gene"
        exit 1
    fi

    >&2 echo "hi0"
    wget -q -O "$HOMOLOGENEHTML" "https://www.ncbi.nlm.nih.gov/homologene/?cmd=Retrieve&dopt=MultipleAlignment&list_uids=$homologeneid"
    grep -B1 '^<a' "$HOMOLOGENEHTML" | sed 's/&nbsp;/ /g;s/<[^>]*>//g;' >"$MSA"
    >&2 echo "hi1"
    NAMES=$(awk -F "</*td>" '/<\/*td>/{print $1}' "$HOMOLOGENEHTML" | tail -n +6 | sed 's/<[^>]*>//g' | paste - - - | awk '{sub("\\.", ". ", $3);printf "\\nameseq{%s}{%s}\n", NR, $3}')
    export MSA aachange position startpos endpos NAMES
    envsubst <template.tex >"$TEXFILE"
    pdflatex -halt-on-error -output-directory="$TMPDIR" -jobname="$hgvsp" "$TEXFILE" >/dev/null
    >&2 echo "hi2"
    echo "$TMPDIR/$hgvsp.pdf"

    nohup sh -c 'sleep 10 && rm -rf "$TMPDIR"' &
}

main "$@"
# No heading:2 ends here
