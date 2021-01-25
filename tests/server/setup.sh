# Check if marian-server is compiled
test -f $MRT_MARIAN/marian-server || exit $EXIT_CODE_SKIP
test -f $MRT_MODELS/wmt16_systems/en-de/model.npz || exit 1
python3 -c "import websocket"
