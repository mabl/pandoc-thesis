#/bin/env sh
set -e

BASEDIR=$(readlink -f ${1-./content})
OUTDIR=$(readlink -f ${2-./out})

# Additional resources
RESOURCES="figures/ references.bib"

# Document name
DOCUMENT="thesis"

BUILDDIR=$(mktemp -d --suffix="pandocThesis")

cd "$BASEDIR"

# Derived paths
CONTENTDIR=./content

TMP_LATEX="$BUILDDIR/latex"
#TMP_LATEX=${OUTDIR}/latex

DOCUMENT_FILE="$BUILDDIR/$DOCUMENT.md"

mkdir -p ${TMP_LATEX}
mkdir -p ${OUTDIR}

SOURCE_FORMAT="markdown+tex_math_dollars+tex_math_double_backslash+implicit_figures+citations"

echo -e "Building thesis in ${BASEDIR}..."
cat `find ${CONTENTDIR} -name "*.md" | sort` > ${DOCUMENT_FILE}

echo -n "Converting to: "
echo -n "Word.."
pandoc ${DOCUMENT_FILE} \
      --from=${SOURCE_FORMAT} \
      --to=odt \
      --table-of-contents \
      --bibliography="references.bib" \
      -o "${OUTDIR}/${DOCUMENT}.odt"

echo -n "html.."
pandoc ${DOCUMENT_FILE} \
      --standalone \
      --from=${SOURCE_FORMAT} \
      --to=html5 \
      --webtex \
      --table-of-contents \
      --bibliography="references.bib" \
      -o "${OUTDIR}/${DOCUMENT}.html"	

echo -n "tex.."
pandoc ${DOCUMENT_FILE} \
      --from=${SOURCE_FORMAT} \
      --to=latex \
      --chapters \
      --bibliography="references.bib" \
      --natbib \
      --standalone \
      --table-of-contents \
      --include-in-header=options.sty \
      --include-after-body=footer.sty\
      -M biblio-style="apalike2" \
      -o "${TMP_LATEX}/${DOCUMENT}.tex"
echo "DONE!"


echo -e -n "Copying resources to latex folder..."
cp -a ${RESOURCES} "${TMP_LATEX}"
echo "DONE!"

echo -e "Running LATEX..."
cd "${TMP_LATEX}"
xelatex ${DOCUMENT} -interaction=batchmode
bibtex ${DOCUMENT}
xelatex ${DOCUMENT} -interaction=batchmode
xelatex ${DOCUMENT} -interaction=batchmode
cp "${DOCUMENT}.pdf" "${OUTDIR}"
echo "DONE!"

echo -e -n "Deleting temporary build directory..."
rm -rf $BUILDDIR
echo "DONE!"