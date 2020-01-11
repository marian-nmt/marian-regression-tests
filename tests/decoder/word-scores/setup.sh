test -f $MRT_MODELS/wmt16_systems/en-de/model.npz || exit 1
# Check if marian is new enough to have the --word-scores option
$MRT_MARIAN/marian-decoder --help 2>&1 | grep -q -- "--word-scores"
